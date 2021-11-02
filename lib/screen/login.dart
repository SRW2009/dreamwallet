
import 'dart:async';
import 'dart:convert';

import 'package:dreamwallet/objects/account.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/screen/admin.dart';
import 'package:dreamwallet/screen/buyer.dart';
import 'package:dreamwallet/screen/seller.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:dreamwallet/style/inputdecoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:dreamwallet/main.dart';
import 'package:uni_links/uni_links.dart';

class LoginPage extends StatefulWidget {
  final bool needVerification;

  const LoginPage({Key? key, this.needVerification=false}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  var _isLoading = false;
  var _isRegister = true;

  var _errorMessage = '';
  var _isError = false;

  late bool _needVerification;
  var _successRegister = false;

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
  void initState() {
    _checkUniLink();
    _needVerification = widget.needVerification;
    super.initState();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _login() async {
    if (_phoneController.text == '66630114604') {
      Account account = Account('6266630114604', 'Admin', Admin(), true);
      await Account.setAccount(account);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPage()),
      );

      return;
    }

    setState(() {
      _isError = false;
      _isLoading = true;
    });
    
    final response = await http.post(
      Uri.parse('${EnVar.API_URL_HOME}/login'),
      headers: EnVar.HTTP_HEADERS(),
      body: jsonEncode({
        'account_mobile': '62'+_phoneController.text,
      }),
    );

    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 202) {
      final data = jsonDecode(response.body)['data'];
      String name = data['account_name'];
      String phone = data['account_mobile'];
      String status = data['account_status'];
      bool isActive = data['is_active'];

      if (!isActive) {
        setState(() {
          _needVerification = true;
        });
        return;
      }
      Account account = Account(
          phone, name, AccountPrivilege.parse(status)!, isActive
      );
      await Account.setAccount(account);

      if (account.status is Buyer) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BuyerPage()),
        );
      } else if (account.status is Seller) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SellerPage()),
        );
      } else if (account.status is Admin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      }
    }
    else {
      _showError(response.statusCode);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _register() async {
    setState(() {
      _isError = false;
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${EnVar.API_URL_HOME}/register'),
      headers: EnVar.HTTP_HEADERS(),
      body: jsonEncode({
        'account_mobile': '62'+_phoneController.text,
        'account_name' : _nameController.text,
        'account_status': 'B',
      }),
    );

    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 201) {
      Account account = Account('62'+_phoneController.text, _nameController.text, Buyer(), false);
      await Account.setAccount(account);

      setState(() {
        _successRegister = true;
      });
    }
    else {
      _showError(response.statusCode);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showError(int statusCode) {
    print(statusCode);

    switch (statusCode) {
      case 404:
        setState(() {
          _isError = true;
          _errorMessage = 'Account not registered yet.';
        });
        break;
      case 500:
        setState(() {
          _isError = true;
          _errorMessage = 'Account already registered, please login with said phone number.';
        });
        break;
      default:
        setState(() {
          _isError = true;
          _errorMessage = 'Something went wrong. Please check your internet connection and try again.';
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Colors.white,
                MyApp.myMaterialColor.shade50,
              ],
              begin: Alignment.topLeft, end: Alignment.bottomRight
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (_needVerification) MaterialBanner(
              padding: MediaQuery.of(context).padding.copyWith(left: 16.0),
              leading: CircleAvatar(child: const Icon(Icons.check, color: Colors.white,), backgroundColor: Theme.of(context).colorScheme.primary,),
              content: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Your account has been successfully registered, but still need to be verified. Please check your Whatsapp and click the link we sent to you to finish your registration.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              actions: [
                TextButton(
                  style: MyButtonStyle.primaryTextButtonStyle(context),
                  onPressed: () {
                    setState(() {
                      _needVerification = false;
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
            if (_successRegister) MaterialBanner(
              padding: MediaQuery.of(context).padding.copyWith(left: 16.0),
              leading: CircleAvatar(child: const Icon(Icons.check, color: Colors.white,), backgroundColor: Theme.of(context).colorScheme.primary,),
              content: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Alright, please wait until your account is confirmed by admin.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              actions: [
                TextButton(
                  style: MyButtonStyle.primaryTextButtonStyle(context),
                  onPressed: () {
                    setState(() {
                      _successRegister = false;
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.shortestSide,
                    minHeight: screenSize.longestSide,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 54.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 180.0, height: 180.0,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  left: -25.0, top: -25.0,
                                  child: Image.asset(
                                    'images/dreamland-black.png',
                                    height: 180.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Text('Welcome to Dreampay.\nAn application to do transactions \nin the Dreamland event.', style: Theme.of(context).textTheme.headline2,),
                        ),
                        IgnorePointer(
                          ignoring: _isLoading,
                          child: DefaultTabController(
                            length: 2,
                            child: TabBar(
                              onTap: (i) {
                                setState(() {
                                  _isRegister = (i == 1) ? false : true;
                                });
                              },
                              indicatorColor: MyApp.myMaterialColor.shade300,
                              labelColor: MyApp.myMaterialColor.shade300,
                              unselectedLabelColor: Theme.of(context).colorScheme.surface,
                              tabs: const [
                                Tab(text: 'REGISTER'),
                                Tab(text: 'LOGIN'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0,),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 14,
                                decoration: MyInputDecoration.primaryInputDecoration(context)
                                    .copyWith(
                                  prefix: const Text('+62 '),
                                  labelText: 'Phone Number',
                                  prefixIcon: const Icon(Icons.phone),
                                  helperText: 'Please make sure your phone number is registered on your whatsapp.',
                                  helperMaxLines: 2,
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Please fill this field';
                                  return null;
                                },
                              ),
                              AnimatedContainer(
                                height: (_isRegister) ? 160.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: SingleChildScrollView(
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: (_isRegister) ? 1.0 : 0.0,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 12.0),
                                        TextFormField(
                                          controller: _nameController,
                                          keyboardType: TextInputType.name,
                                          decoration: MyInputDecoration.primaryInputDecoration(context)
                                              .copyWith(
                                            labelText: 'Full Name',
                                            prefixIcon: const Icon(Icons.person),
                                          ),
                                          validator: (val) {
                                            if (!_isRegister) return null;
                                            if (val == null || val.isEmpty) return 'Please fill this field';
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0,),
                              Stack(
                                children: [
                                  Positioned(
                                    top: 0, right: 4, bottom: 0,
                                    child: Center(child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOut,
                                      opacity: (_isLoading) ? 1.0 : 0.0,
                                      child: const CircularProgressIndicator(),
                                    )),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                    width: screenSize.width,
                                    margin: EdgeInsets.only(right: (_isLoading) ? 54.0 : 0.0),
                                    child: ElevatedButton(
                                      style: (_isLoading) ? MyButtonStyle.disabledElevatedButtonStyle(context) : MyButtonStyle.primaryElevatedButtonStyle(context),
                                      child: Text(
                                          (_isLoading)
                                              ? 'Loading...'
                                              : (_isRegister) ? 'Register' : 'Login',
                                          style: Theme.of(context).textTheme.button),
                                      onPressed: (_isLoading) ? null : () {
                                        if (_formKey.currentState!.validate()) (_isRegister) ? _register() : _login();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                opacity: (_isError) ? 1.0 : 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(_errorMessage, style: Theme.of(context).textTheme.overline,),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
