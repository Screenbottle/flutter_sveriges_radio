class Schedule {
  String? copyRight;
  List<Program> schedule;

  Pagination pagination;

  Schedule({this.copyRight, required this.schedule, required this.pagination});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final scheduleData = json['schedule'] as List<dynamic>?;
    final paginationData = json['pagination'];
    return Schedule(
      copyRight: json['copyright'],
      schedule: scheduleData != null
          ? scheduleData
              .map((programData) =>
                  Program.fromJson(programData as Map<String, dynamic>))
              .toList()
          : <Program>[],
      pagination: Pagination.fromJson(paginationData),
    );
  }
}

class Program {
  int? episodeId;
  String title;
  String? subtitle;
  String description;

  String? imageUrl;
  String? imageUrlTemplate;
  String defaultImageUrl =
      'https://static-cdn.sr.se/images/164/2186756_512_512.jpg?preset=api-default-square';

  String startTimeUTC;
  String endTimeUTC;

  Program(
      {this.episodeId,
      required this.title,
      this.subtitle,
      required this.description,
      required this.imageUrl,
      required this.imageUrlTemplate,
      required this.startTimeUTC,
      required this.endTimeUTC});

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      episodeId: json['episodeid'],
      title: json['title'],
      subtitle: json['subtitle'] ?? '',
      description: json['description'],
      imageUrl: json['imageurl'],
      imageUrlTemplate: json['imageurltemplate'],
      startTimeUTC: json['starttimeutc'],
      endTimeUTC: json['endtimeutc'],
    );
  }
}

class Pagination {
  int page;
  int size;

  int totalHits;
  int totalPages;

  Pagination(
      {required this.page,
      required this.size,
      required this.totalHits,
      required this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'],
      size: json['size'],
      totalHits: json['totalhits'],
      totalPages: json['totalpages'],
    );
  }
}
