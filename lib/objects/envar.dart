
import 'package:intl/intl.dart';

class EnVar {
  static const String API_URL_HOME =
      'https://rest-dreampay.sekolahimpian.com/api';
      //'http://10.90.90.36:8080/api';
  static Map<String, String> HTTP_HEADERS({String? token}) {
    if (token != null) {
      return <String, String> {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'token $token',
      };
    }

    return <String, String> {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  static String moneyFormat(dynamic number) => NumberFormat.currency(
    symbol: 'IDR ',
    decimalDigits: 0,
  ).format(number);

  static String getAllIdsAsString(List<String> ids) {
    String content = ids.first;
    for (var i = 1; i < ids.length; ++i) {
      final o = ids[i];
      content += ', $o';
    }
    return content;
  }
}