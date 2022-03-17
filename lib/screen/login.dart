
import 'dart:async';

import 'package:dreamwallet/screen/cashier.dart';
import 'package:flutter/material.dart';
import 'package:dreamwallet/objects/account/account_privilege.dart';
import 'package:dreamwallet/objects/account/privileges/root.dart';
import 'package:dreamwallet/objects/request/request.dart';
import 'package:dreamwallet/screen/admin.dart';
import 'package:dreamwallet/screen/buyer.dart';
import 'package:dreamwallet/screen/seller.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:dreamwallet/style/inputdecoration.dart';
import 'package:dreamwallet/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  var _isLoading = false;
  var _isRegister = true;
  var _isAdminActivated = false;
  AccountPrivilege _loginRadioGroup = Buyer();

  var _errorMessage = '';
  var _isError = false;

  var _needVerification = false;
  var _successRegister = false;

  Future<void> _login() async {
    if (_phoneController.text == '69420') {
      setState(() {
        _phoneController.text = '';
        _isAdminActivated = true;
        _loginRadioGroup = Admin();
      });
      return;
    }

    setState(() {
      _isError = false;
      _isLoading = true;
    });

    final loginResponse = await Request().login(_phoneController.text, _loginRadioGroup);
    if (loginResponse.statusCode == 201) {
      final account = loginResponse.account;
      if (account == null) {
        setState(() {
          _needVerification = true;
        });
        return;
      }

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
      } else if (account.status is Cashier) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CashierPage()),
        );
      }
    }
    else {
      _showError(loginResponse.errorMessage);
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

    final response = await Request().clientRegister(_phoneController.text, _nameController.text);
    if (response.statusCode == 201) {
      setState(() {
        _successRegister = true;
      });
    }
    else {
      _showError(response.errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showError(String? errorMessage) {
    setState(() {
      _isError = true;
      _errorMessage = '$errorMessage';
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Colors.white,
                (_isAdminActivated)
                    ? Colors.red.shade300
                    : MyApp.myMaterialColor.shade50,
              ],
              begin: Alignment.topLeft, end: Alignment.bottomRight
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (_needVerification) _needVerificationBanner(context),
            if (_successRegister) _successRegisterBanner(context),
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
                              AnimatedContainer(
                                height: (_isRegister) ? 0.0 : 60.0,
                                duration: const Duration(milliseconds: 300),
                                child: SingleChildScrollView(
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: (_isRegister) ? 0.0 : 1.0,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 12.0),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(right: 12.0),
                                                child: Text(
                                                  'Login As',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              _loginRadio(Buyer(), 'Guest'),
                                              _loginRadio(Seller(), 'Merchant'),
                                              _loginRadio(Cashier(), 'Cashier'),
                                              if (_isAdminActivated) _loginRadio(Admin(), 'Admin'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
                                height: (_isRegister) ? 90.0 : 0.0,
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

  MaterialBanner _needVerificationBanner(BuildContext context) => MaterialBanner(
    padding: MediaQuery.of(context).padding.copyWith(left: 16.0),
    leading: CircleAvatar(child: const Icon(Icons.check, color: Colors.white,), backgroundColor: Theme.of(context).colorScheme.primary,),
    content: const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        'Your account has been successfully registered, but still need to be verified. Please wait until admin verify your account.',
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
  );

  MaterialBanner _successRegisterBanner(BuildContext context) => MaterialBanner(
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
  );

  Widget _loginRadio(AccountPrivilege value, String title) => Row(
    children: [
      Radio<AccountPrivilege>(
        value: value,
        groupValue: _loginRadioGroup,
        onChanged: (val) {
          if (val == null) return;
          setState(() {
            _loginRadioGroup = val;
          });
        },
      ),
      Padding(
        padding: const EdgeInsets.only(left: 2.0, right: 8.0),
        child: Text(title),
      ),
    ],
  );
}
