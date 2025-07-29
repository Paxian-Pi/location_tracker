import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

Logger logger = Logger();

void logResponse(http.Response response) {
  logger.i("${response.request?.method} ${response.request!.url}\n"
      "${response.statusCode} : ${response.reasonPhrase}\n"
      "${response.body}\n");
}

void logPrint(Object? object) {
  logger.i(object);
}

void logTimeoutException(TimeoutException error) {
  logger.e("${error.duration} \t ${error.message}");
}
