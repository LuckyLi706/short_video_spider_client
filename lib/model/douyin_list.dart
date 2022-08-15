import 'dart:convert';

DouYinList fromJson(String str) => DouYinList.fromJson(json.decode(str));

String toJson(DouYinList data) => json.encode(data.toJson());

class DouYinList {
  DouYinList({
    this.code,
    this.coverImageUrlList = const [],
    this.hasMore,
    this.maxCursor,
    this.secUid,
    this.videoUrlList = const [],
    this.videoDescList = const [],
  });

  int? code;
  List<String> coverImageUrlList = [];
  List<String> videoDescList = [];
  bool? hasMore;
  int? maxCursor;
  List<String> videoUrlList = [];
  String? secUid;

  factory DouYinList.fromJson(Map<String, dynamic> json) => DouYinList(
      code: json["code"],
      coverImageUrlList:
          List<String>.from(json["cover_image_url_list"].map((x) => x)),
      videoDescList: List<String>.from(json["video_desc_list"].map((x) => x)),
      hasMore: json["has_more"],
      maxCursor: json["max_cursor"],
      videoUrlList: List<String>.from(json["video_url_list"].map((x) => x)),
      secUid: json["sec_uid"]);

  Map<String, dynamic> toJson() => {
        "code": code,
        "cover_image_url_list":
            List<dynamic>.from(coverImageUrlList.map((x) => x)),
        "has_more": hasMore,
        "max_cursor": maxCursor,
        "sec_uid": secUid,
        "video_url_list": List<dynamic>.from(videoUrlList.map((x) => x)),
        "video_desc_list": List<dynamic>.from(videoDescList.map((x) => x)),
      };
}
