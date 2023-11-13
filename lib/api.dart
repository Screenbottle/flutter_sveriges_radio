import "package:dio/dio.dart";

import "package:flutter_sveriges_radio/models/schedule.dart";

const baseUrl =
    'https://api.sr.se/api/v2/scheduledepisodes?channelid=164&format=json&page=';

class API {
  static Future<Schedule> getData(page) async {
    var url = baseUrl + page.toString();

    Dio dio = Dio();
    Response response = await dio.get(url);
    Schedule schedule = Schedule.fromJson(response.data);
    return schedule; // JSON response data
  }
}
