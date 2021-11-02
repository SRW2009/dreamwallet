
import 'dart:async';
import 'dart:convert';

import 'package:dreamwallet/objects/account.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminAccountScreen extends StatefulWidget {
  final void Function(String accountId) openTransactionWithAccountId;

  const AdminAccountScreen(this.openTransactionWithAccountId, {Key? key}) : super(key: key);

  @override
  _AdminAccountScreenState createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {

  int _rebuildListCount = 0;
  final _formKey = GlobalKey<FormState>();
  String? _updateId;
  final _nameCon = TextEditingController();
  final _mobileCon = TextEditingController();
  int _statusCon = 0;

  Future<void> _add([int retryCount=0]) async {
    try {
      if (retryCount != 3) {
        if (retryCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading...')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Retrying...')));
        }

        final response = await http.post(
          Uri.parse('${EnVar.API_URL_HOME}/register'),
          headers: EnVar.HTTP_HEADERS(),
          body: jsonEncode({
            'account_mobile': '62'+_mobileCon.text,
            'account_name' : _nameCon.text,
            'account_status': AccountPrivilege.parseInt(_statusCon)!.toChar(),
          }),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success')));

          setState(() {
            _rebuildListCount++;
          });
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')));
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed after 3 retry.')));
      }

    } on TimeoutException {_add(++retryCount);}
  }

  Future<void> _update([int retryCount=0, Account? account]) async {
    try {
      if (retryCount != 3) {
        if (retryCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading...')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Retrying...')));
        }

        String url;
        http.Response response;
        if (account != null) {
          url = '${EnVar.API_URL_HOME}/update/${account.mobile}';
          response = await http.post(
            Uri.parse(url),
            headers: EnVar.HTTP_HEADERS(),
            body: jsonEncode({
              //"account_mobile": account.mobile,
              "account_name": account.name,
              "account_status": account.status.toChar(),
              "is_active": account.isActive,
            }),
          );
        }
        else {
          url = '${EnVar.API_URL_HOME}/update/$_updateId';
          response = await http.post(
            Uri.parse(url),
            headers: EnVar.HTTP_HEADERS(),
            body: jsonEncode({
              "account_mobile": _mobileCon.text,
              "account_name": _nameCon.text,
              "account_status": AccountPrivilege.parseInt(_statusCon)!.toChar(),
            }),
          );
        }

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 202) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success')));

          setState(() {
            _updateId = null;
            _nameCon.text = '';
            _mobileCon.text = '';
            _statusCon = 0;

            _rebuildListCount++;
          });
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')));
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed after 3 retry.')));
      }

    } on TimeoutException {_update(++retryCount, account);}
  }

  Future<void> _delete(String id, [int retryCount=0]) async {
    try {
      if (retryCount != 3) {
        if (retryCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading...')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Retrying...')));
        }

        final url = '${EnVar.API_URL_HOME}/delete/$id';
        final response = await http.post(
          Uri.parse(url),
          headers: EnVar.HTTP_HEADERS(),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 202) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success')));

          setState(() {
            _rebuildListCount++;
          });
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')));
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed after 3 retry.')));
      }

    } on TimeoutException {_delete(id, ++retryCount);}
  }

  Future<List<Account>> _getList([int retryCount=0]) async {
    try {
      if (retryCount != 3) {
        const url = '${EnVar.API_URL_HOME}/account';
        final response = await http.get(
          Uri.parse(url),
          headers: EnVar.HTTP_HEADERS(),
        );

        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200) {
          final list = jsonDecode(response.body)['response'] as List;

          return list.map<Account>((e) => Account.parse(e)).toList();
        }

        return _getList(++retryCount);
      }
      else {
        throw Exception();
      }
    } on TimeoutException {return _getList(++retryCount);}
  }
  
  Widget _addOrUpdateView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text((_updateId == null) ? 'Add' : 'Update ID: $_updateId', style: Theme.of(context).textTheme.headline4,),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _nameCon,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              return null;
            },
          ),
          TextFormField(
            enabled: (_updateId == null),
            controller: _mobileCon,
            decoration: const InputDecoration(
              labelText: 'Mobile',
            ),
            validator: (e) {
              if (e == null || e.isEmpty) return 'Please fill the field.';
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: FormField<int>(
              initialValue: _statusCon,
              validator: (val) {
                if (val == null || val == 0) return 'Please select one of these actions.';
                return null;
              },
              builder: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Radio<int>(
                            value: 1,
                            groupValue: _statusCon,
                            onChanged: (val) {
                              if (val != null) {
                                state.didChange(val);
                                setState(() {
                                  _statusCon = val;
                                });
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text('Buyer', style: Theme.of(context).textTheme.bodyText2,),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            value: 2,
                            groupValue: _statusCon,
                            onChanged: (val) {
                              if (val != null) {
                                state.didChange(val);
                                setState(() {
                                  _statusCon = val;
                                });
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text('Seller', style: Theme.of(context).textTheme.bodyText2,),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            value: 3,
                            groupValue: _statusCon,
                            onChanged: (val) {
                              if (val != null) {
                                state.didChange(val);
                                setState(() {
                                  _statusCon = val;
                                });
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text('Admin', style: Theme.of(context).textTheme.bodyText2,),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (state.hasError && state.errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(state.errorText!, style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12.0,
                      )),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if  (_updateId != null) Expanded(
                child: ElevatedButton(
                  style: MyButtonStyle.primaryElevatedButtonStyle(context),
                  child: const Text('Cancel'),
                  onPressed: () {
                    setState(() {
                      _updateId = null;
                      _nameCon.text = '';
                      _mobileCon.text = '';
                      _statusCon = 0;
                    });
                  },
                ),
              ),
              if  (_updateId != null) const SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton(
                  style: MyButtonStyle.primaryElevatedButtonStyle(context),
                  child: Text((_updateId == null) ? 'Add' : 'Update'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      (_updateId == null) ? _add() : _update();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _listView(List<Account> list) {
    int nameFlex = 1;
    int mobileFlex = 1;
    int statusFlex = 1;
    int isActiveFlex = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: nameFlex, child: Text('Name', style: Theme.of(context).textTheme.headline6,)),
            const SizedBox(width: 8.0,),
            Expanded(flex: mobileFlex, child: Text('Mobile', style: Theme.of(context).textTheme.headline6,)),
            const SizedBox(width: 8.0,),
            Expanded(flex: statusFlex, child: Text('Status', style: Theme.of(context).textTheme.headline6,)),
            const SizedBox(width: 8.0,),
            Expanded(flex: isActiveFlex, child: Text('Active', style: Theme.of(context).textTheme.headline6,)),
            const SizedBox(width: 8.0,),
            SizedBox(width: 180.0, child: Text('Transaction', style: Theme.of(context).textTheme.headline6,)),
            const SizedBox(width: 8.0,),
            SizedBox(width: 80.0, child: Text('Action', style: Theme.of(context).textTheme.headline6,)),
          ],
        ),
        const Divider(height: 24.0, thickness: 1.0, color: Colors.black,),
        for (var o in list)
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: nameFlex, child: Text(o.name, style: Theme.of(context).textTheme.bodyText2,)),
                  const SizedBox(width: 8.0,),
                  Expanded(flex: mobileFlex, child: Text(o.mobile, style: Theme.of(context).textTheme.bodyText2,)),
                  const SizedBox(width: 8.0,),
                  Expanded(flex: statusFlex, child: Text(o.status.toString(), style: Theme.of(context).textTheme.bodyText2,)),
                  const SizedBox(width: 8.0,),
                  Expanded(flex: isActiveFlex, child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(value: o.isActive, onChanged: (o.isActive) ? null : (val) {
                        Account account = Account(o.mobile, o.name, o.status, !o.isActive);
                        _update(0, account);
                      }),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(o.isActive ? 'Active' : 'Not Active', style: Theme.of(context).textTheme.bodyText2,),
                      ),
                    ],
                  )),
                  const SizedBox(width: 8.0,),
                  SizedBox(width: 180.0, child: TextButton(
                    style: MyButtonStyle.primaryTextButtonStyle(context),
                    child: const Text('SHOW TRANSACTIONS'),
                    onPressed: () {
                      widget.openTransactionWithAccountId(o.mobile);
                    },
                  ),),
                  const SizedBox(width: 8.0,),
                  SizedBox(
                    width: 80.0,
                    child: Column(
                      children: [
                        TextButton(
                          style: MyButtonStyle.primaryTextButtonStyle(context),
                          child: const Text('UPDATE'),
                          onPressed: () {
                            setState(() {
                              _updateId = o.mobile;
                              _nameCon.text = o.name;
                              _mobileCon.text = o.mobile;
                              _statusCon = o.status.toInt();
                            });

                            _scrollController.jumpTo(0.0);
                          },
                        ),
                        TextButton(
                          style: MyButtonStyle.primaryTextButtonStyle(context),
                          child: const Text('DELETE'),
                          onPressed: () async {
                            final isDelete = await Navigator.push<bool>(context,
                                DialogRoute(context: context, builder: (c) => AlertDialog(
                                  content: Text('Delete ID: ${o.mobile} ?'),
                                  actions: [
                                    TextButton(onPressed: () {return Navigator.pop(c, false);}, child: const Text('No')),
                                    TextButton(onPressed: () {return Navigator.pop(c, true);}, child: const Text('Yes')),
                                  ],
                                )));

                            if (isDelete != null && isDelete) {
                              _delete(o.mobile);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1.0,),
            ],
          ),
      ],
    );
  }

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Account', style: Theme.of(context).textTheme.headline3,),
        )),
        Card(child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _addOrUpdateView(),
        )),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<Account>>(
              key: ValueKey(_rebuildListCount),
              future: _getList(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _listView(snapshot.data!);
                }
                else if (snapshot.hasError) {
                  return Column(
                    children: const [
                      Text('Terjadi Kesalahan')
                    ],
                  );
                }

                return const Center(child: CircularProgressIndicator());
              }
            ),
          ),
        ),
      ],
    );
  }
}
