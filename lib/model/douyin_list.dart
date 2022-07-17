import 'dart:convert';

DouYinList fromJson(String str) => DouYinList.fromJson(json.decode(str));

String toJson(DouYinList data) => json.encode(data.toJson());

class DouYinList {
  DouYinList({
    this.code,
    this.coverImageUrlList = const [],
    this.hasMore,
    this.maxCursor,
    this.videoUrlList = const [],
  });

  int? code;
  List<String> coverImageUrlList = [];
  bool? hasMore;
  int? maxCursor;
  List<String> videoUrlList = [];

  factory DouYinList.fromJson(Map<String, dynamic> json) => DouYinList(
        code: json["code"],
        coverImageUrlList:
            List<String>.from(json["cover_image_url_list"].map((x) => x)),
        hasMore: json["has_more"],
        maxCursor: json["max_cursor"],
        videoUrlList: List<String>.from(json["video_url_list"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "cover_image_url_list":
            List<dynamic>.from(coverImageUrlList.map((x) => x)),
        "has_more": hasMore,
        "max_cursor": maxCursor,
        "video_url_list": List<dynamic>.from(videoUrlList.map((x) => x)),
      };
}
