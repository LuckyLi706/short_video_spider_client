import 'dart:convert';

DouYinSingle fromJson(String str) => DouYinSingle.fromJson(json.decode(str));

String toJson(DouYinSingle data) => json.encode(data.toJson());

class DouYinSingle {
  DouYinSingle({
    this.code,
    this.coverImageUrl,
    this.videoUrl,
    this.videoDesc,
  });

  int? code;
  String? coverImageUrl;
  String? videoUrl;
  String? videoDesc;

  factory DouYinSingle.fromJson(Map<String, dynamic> json) => DouYinSingle(
      code: json["code"],
      coverImageUrl: json["cover_image_url"],
      videoUrl: json["video_url"],
      videoDesc: json["video_desc"]);

  Map<String, dynamic> toJson() => {
        "code": code,
        "cover_image_url": coverImageUrl,
        "video_url": videoUrl,
        "video_desc": videoDesc,
      };
}
