
import 'dart:async';
import 'dart:convert';

import 'package:dreamwallet/objects/account.dart';
import 'package:dreamwallet/objects/envar.dart';
import 'package:dreamwallet/screen/admins/withdrawscreen.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminAccountScreen extends StatefulWidget {
  final void Function(Account account) openTransactionWithAccount;
  final void Function(Account account) openWithdrawWithAccount;

  const AdminAccountScreen(this.openTransactionWithAccount, this.openWithdrawWithAccount, {Key? key}) : super(key: key);

  @override
  _AdminAccountScreenState createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {

  int _rebuildListCount = 0;
  late Future<List<Account>> _list;
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
            _list = _getList();
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

            _list = _getList();
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
            _list = _getList();
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
              prefixText: '+62 ',
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

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _list = _getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (context, orientation) {
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
                    future: _list,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (orientation == Orientation.portrait) {
                          return SizedBox.fromSize(
                            size: MediaQuery.of(context).size,
                            child: Center(
                              child: Text('Rotate to landscape to see data.', style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
                            ),
                          );
                        } else {
                          return _ListView(
                            snapshot.data!,
                            onUpdate: _update,
                            onPressUpdate: (o) {
                              setState(() {
                                _updateId = o.mobile;
                                _nameCon.text = o.name;
                                _mobileCon.text = o.mobile;
                                _statusCon = o.status.toInt();
                              });

                              _scrollController.jumpTo(0.0);
                            },
                            onDelete: _delete,
                            onPressTransactions: widget.openTransactionWithAccount,
                            onPressWithdraws: widget.openWithdrawWithAccount
                          );
                        }
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
    );
  }
}

class _ListView extends StatefulWidget {
  final List<Account> list;
  final Future<void> Function([int retryCount, Account? account]) onUpdate;
  final void Function(Account o) onPressUpdate;
  final Future<void> Function(String id, [int retryCount]) onDelete;
  final void Function(Account account) onPressTransactions;
  final void Function(Account account) onPressWithdraws;

  const _ListView(this.list, {Key? key,
    required this.onUpdate, required this.onPressUpdate, required this.onDelete,
    required this.onPressTransactions, required this.onPressWithdraws,
  }) : super(key: key);

  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends State<_ListView> {
  int _filterCount = 0;

  static const STATUS_ALL = 0;
  static const STATUS_BUYER = 1;
  static const STATUS_SELLER = 2;
  static const STATUS_ADMIN = 3;

  static const ACTIVE_ALL = 0;
  static const ACTIVE_ACTIVATED = 1;
  static const ACTIVE_NOTACTIVATED = 2;

  String query = '';
  late List<Account> _filteredList;

  final int nameFlex = 1;
  final int mobileFlex = 1;
  final int statusFlex = 1;
  final int isActiveFlex = 1;

  int statusGroup = 0;
  int activeGroup = 0;

  void filter() {
    _filteredList = widget.list;
    // filter query
    _filteredList = _filteredList.where((element) => element.name.toLowerCase().contains(query.toLowerCase())).toList();
    // filter status
    switch (statusGroup) {
      case STATUS_BUYER:
        _filteredList = _filteredList.where((element) => element.status is Buyer).toList();
        break;
      case STATUS_SELLER:
        _filteredList = _filteredList.where((element) => element.status is Seller).toList();
        break;
      case STATUS_ADMIN:
        _filteredList = _filteredList.where((element) => element.status is Admin).toList();
        break;
      default:
        break;
    }
    // filter activated
    switch (activeGroup) {
      case ACTIVE_ACTIVATED:
        _filteredList = _filteredList.where((element) => element.isActive).toList();
        break;
      case ACTIVE_NOTACTIVATED:
        _filteredList = _filteredList.where((element) => !element.isActive).toList();
        break;
      default:
        break;
    }

    setState(() {
      _filterCount++;
    });
  }

  @override
  void initState() {
    _filteredList = widget.list;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search...',
                ),
                onSubmitted: (val) {
                  query = val;
                  filter();
                },
              ),
              const SizedBox(height: 16.0,),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio<int>(
                            value: STATUS_ALL,
                            groupValue: statusGroup,
                            onChanged: (val) {
                              if (val != null && statusGroup != val) {
                                statusGroup = STATUS_ALL;
                                filter();
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('Show all', style: Theme.of(context).textTheme.caption,),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            value: STATUS_BUYER,
                            groupValue: statusGroup,
                            onChanged: (val) {
                              if (val != null && statusGroup != val) {
                                statusGroup = STATUS_BUYER;
                                filter();
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('Show buyer only', style: Theme.of(context).textTheme.caption,),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            value: STATUS_SELLER,
                            groupValue: statusGroup,
                            onChanged: (val) {
                              if (val != null && statusGroup != val) {
                                statusGroup = STATUS_SELLER;
                                filter();
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('Show seller only', style: Theme.of(context).textTheme.caption,),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            value: STATUS_ADMIN,
                            groupValue: statusGroup,
                            onChanged: (val) {
                              if (val != null && statusGroup != val) {
                                statusGroup = STATUS_ADMIN;
                                filter();
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('Show admin only', style: Theme.of(context).textTheme.caption,),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 20.0,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio<int>(
                            value: ACTIVE_ALL,
                            groupValue: activeGroup,
                            onChanged: (val) {
                              if (val != null && activeGroup != val) {
                                activeGroup = ACTIVE_ALL;
                                filter();
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('Show all', style: Theme.of(context).textTheme.caption,),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            value: ACTIVE_ACTIVATED,
                            groupValue: activeGroup,
                            onChanged: (val) {
                              if (val != null && activeGroup != val) {
                                activeGroup = ACTIVE_ACTIVATED;
                                filter();
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('Show activated account only', style: Theme.of(context).textTheme.caption,),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            value: ACTIVE_NOTACTIVATED,
                            groupValue: activeGroup,
                            onChanged: (val) {
                              if (val != null && activeGroup != val) {
                                activeGroup = ACTIVE_NOTACTIVATED;
                                filter();
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('Show unactivated account only', style: Theme.of(context).textTheme.caption,),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
            SizedBox(width: 140.0, child: Text('Action', style: Theme.of(context).textTheme.headline6,)),
          ],
        ),
        const Divider(height: 24.0, thickness: 1.0, color: Colors.black,),
        ListView.builder(
          key: ValueKey(_filterCount),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredList.length,
          itemBuilder: (context, i) {
            final o = _filteredList[i];
            return Column(
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
                          widget.onUpdate(0, account);
                        }),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(o.isActive ? 'Active' : 'Not Active', style: Theme.of(context).textTheme.bodyText2,),
                        ),
                      ],
                    )),
                    const SizedBox(width: 8.0,),
                    SizedBox(
                      width: 140.0,
                      child: Column(
                        children: [
                          TextButton(
                            style: MyButtonStyle.primaryTextButtonStyle(context),
                            child: const Text('UPDATE'),
                            onPressed: () => widget.onPressUpdate(o),
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
                                widget.onDelete(o.mobile);
                              }
                            },
                          ),
                          if (o.status is! Admin) TextButton(
                            style: MyButtonStyle.primaryTextButtonStyle(context),
                            child: const Text('TRANSACTIONS'),
                            onPressed: () {
                              widget.onPressTransactions(o);
                            },
                          ),
                          if (o.status is Seller) TextButton(
                            style: MyButtonStyle.primaryTextButtonStyle(context),
                            child: const Text('WITHDRAWS'),
                            onPressed: () {
                              widget.onPressWithdraws(o);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(thickness: 1.0,),
              ],
            );
          },
        ),
      ],
    );
  }
}
