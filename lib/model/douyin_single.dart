import 'dart:convert';

DouYinSingle fromJson(String str) => DouYinSingle.fromJson(json.decode(str));

String toJson(DouYinSingle data) => json.encode(data.toJson());

class DouYinSingle {
  DouYinSingle({
    this.code,
    this.coverImageUrl,
    this.videoUrl,
  });

  int? code;
  String? coverImageUrl;
  String? videoUrl;

  factory DouYinSingle.fromJson(Map<String, dynamic> json) => DouYinSingle(
        code: json["code"],
        coverImageUrl: json["cover_image_url"],
        videoUrl: json["video_url"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "cover_image_url": coverImageUrl,
        "video_url": videoUrl,
      };
}
