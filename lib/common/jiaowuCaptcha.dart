import 'dart:typed_data';
import 'dart:ui' as ui;

class JiaowuCaptcha {

  int height = 22;
  int width = 62;
  int rgbThres = 150;

  int _GetRGB(List RGBAList, int x, int y) {
    int base = x * 4 + y * 4 * this.width;
    int r = RGBAList[base];
    int g = RGBAList[base+1];
    int b = RGBAList[base+2];
    int rtn = (r * 256 + g) * 256 + b;
    return rtn;
  }

  Future<List> _GetRGBA(Uint8List uInt8ListImg) async {
    ui.Image img = (await (await ui.instantiateImageCodec(uInt8ListImg)).getNextFrame()).image;
    ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    List RGBAList = byteData.buffer.asUint8List().toList();
    return RGBAList;
  }

  //二值化
  List _Binary(List RGBAList) {
    List imgList = List.generate(height, (i) => List(width), growable: false);
    for(int x = 0;x < width; ++x) {
      for(int y = 0;y < height; ++y) {
        int pixel = _GetRGB(RGBAList, x, y);
        if (((pixel & 0xff0000) >> 16) < rgbThres && ((pixel & 0xff00) >> 8) < rgbThres && (pixel & 0xff) < rgbThres) {
          imgList[y][x] = 0;
        } else {
          imgList[y][x] = 1;
        }
      }
    }
    return imgList;
  }

  //去除干扰线
  void _RemoveByLine(List imgList) {
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        if (imgList[y][x] == 0) {
          //print("Found! y: " + y.toString() + " x: " + x.toString());
          int count = imgList[y][x - 1] + imgList[y][x + 1] + imgList[y + 1][x] + imgList[y - 1][x];
          if (count > 2) imgList[y][x] = 1;
        }
      }
    }
  }

  //裁剪
  List _Cut(List imgList, List xCut, List yCut, int num) {
    List imgListList = List.generate(num, (i) =>
        List.generate(yCut[0][1] - yCut[0][0], (j) =>
            List(xCut[0][1] - xCut[0][0]), growable: false), growable: false);
    for (int i = 0; i < num; ++i) {
      for (int j = yCut[i][0]; j < yCut[i][1]; ++j) {
        for (int k = xCut[i][0]; k < xCut[i][1]; ++k) {
          imgListList[i][j-yCut[i][0]][k-xCut[i][0]] = imgList[j][k];
        }
      }
    }
    return imgListList;
  }

  //转字符串
  String _GetString(List imgList) {
    String s = "";
    int unitHeight = imgList.length;
    int unitWidth = imgList[0].length;
    for (int y = 0; y < unitHeight; ++y) {
      for (int x = 0; x < unitWidth; ++x) {
        s += (imgList[y][x]).toString();
      }
    }
    return s;
  }

  //相同大小比对
  int _CompareText(String s1, String s2) {
    int n = s1.length;
    int percent = 0;
    for(int i = 0; i < n ; ++i) {
      if (s1[i] == s2[i]) percent++;
    }
    return percent;
  }

  //匹配识别
  String _MatchCode(List imgListList) {
    String s = "";
    var charMap = _GetCharMap();
    for(var imgList in imgListList) {
      int maxMatch = 0;
      String tempRecord = "";
      charMap.forEach((key, value) {
        int percent = _CompareText(_GetString(imgList), value);
        if(percent > maxMatch) {
          maxMatch = percent;
          tempRecord = key;
        }
      });
      s += tempRecord;
    }
    return s;
  }

  Future<String> GetText(Uint8List uInt8ListImg) async {
    //零、获取RGBA信息
    List RGBAList = await _GetRGBA(uInt8ListImg);
    print("CAPTCHA 0: Get RGBAList OK!");
    //print(RGBAList);
    //一、二值化
    List imgList = _Binary(RGBAList);
    print("CAPTCHA 1: Binary OK!");
    //print(imgList);
    //二、去除干扰线
    _RemoveByLine(imgList);
    print("CAPTCHA 2: Remove Line OK!");
    //print(imgList);
    //三、裁剪
    List imgListList = _Cut(imgList, [[4,13],[14,23],[24,33],[34,43]], [[4,16],[4,16],[4,16],[4,16]], 4);
    print("CAPTCHA 3: Cut OK!");
    //四、识别
    String captchaText = _MatchCode(imgListList);
    print("CAPTCHA 4: Get Text: " + captchaText);
    return captchaText;
  }
  Map _GetCharMap() {
    const charMap = {
    "1":"111100111110000111110000111111100111111100111111100111111100111111100111111100111111100111110000001110000001",
    "2":"100000111000000011111111001111111001111111001111110011111000111110011111100111111001111111000000001000000001",
    "3":"100000111000000011111110001111111001111110011110000111110000011111110001111111001111110001100000011100000111",
    "b":"001111111001111111001111111001000011000000001000111000001111100001111100001111100000111000000000001001000011",
    "c":"111111111111111111111111111110000011100000011000111111001111111001111111001111111000111111100000011110000011",
    "m":"111111111111111111111111111001000011000000000000111000001111001001111001001111001001111001001111001001111001",
    "n":"111111111111111111111111111001100001001000000000011100000111100001111100001111100001111100001111100001111100",
    "v":"111111111111111111111111111111111011001110011001110011001110011100100111100100111100100111110001111110001111",
    "x":"111111111111111111111111111001110011001110011100100111110001111110001111110001111100100111001110011001110011",
    "z":"111111111111111111111111111000000011000000011111100111111001111110011111100111111001111111000000011000000011"
    };
    return charMap;
  }
}
