import 'dart:convert';

DouYinSingleImages fromJson(String str) =>
    DouYinSingleImages.fromJson(json.decode(str));

String toJson(DouYinSingleImages data) => json.encode(data.toJson());

class DouYinSingleImages {
  DouYinSingleImages({this.code, this.coverImageUrlList = const [], this.desc});

  int? code;
  List<String> coverImageUrlList = [];
  String? desc;

  factory DouYinSingleImages.fromJson(Map<String, dynamic> json) =>
      DouYinSingleImages(
          code: json["code"],
          desc: json["image_desc"],
          coverImageUrlList:
              List<String>.from(json["image_url_list"].map((x) => x)));

  Map<String, dynamic> toJson() => {
        "code": code,
        "image_url_list": List<dynamic>.from(coverImageUrlList.map((x) => x)),
        "desc": desc
      };
}
