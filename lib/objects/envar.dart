
class EnVar {
  static const String API_URL_HOME = 'https://rest-dreampay.sekolahimpian.com/api';
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
}