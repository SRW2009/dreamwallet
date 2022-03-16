
class UniLink {
  late StreamSubscription _sub;
  Future<void> _checkUniLink() async {
    try {
      final initialUri = await getInitialUri();
      print('initial uri: ${initialUri.toString()}');

      if (initialUri != null) _uniLinkAction(initialUri);
    }
    on FormatException catch (e) {
      print('initial uri format exception: ${e.message}');
    }
    on PlatformException catch (e) {
      print('initial uri platform exception: ${e.message}');
    }

    _sub = uriLinkStream.listen((Uri? uri) {
      print('stream uri: ${uri.toString()}');

      if (uri != null) _uniLinkAction(uri);
    }, onError: (err) {
      print(err);
    });
  }

  void _uniLinkAction(Uri uri) async {
    try {
      String phone = (await Account.getAccount())!.mobile;

      final response = await http.post(
        Uri.parse('${EnVar.API_URL_HOME}/verification'),
        headers: EnVar.HTTP_HEADERS(),
        body: jsonEncode({
          "mobile": phone,
        }),
      );

      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 202) {
        Account account = (await Account.getAccount())!;
        account.isActive = true;
        await Account.setAccount(account);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BuyerPage())
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _checkUniLink();
    _needVerification = widget.needVerification;
    super.initState();
  }
}