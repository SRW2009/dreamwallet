
import 'dart:async';

import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/account/account_privilege.dart';
import 'package:dreamwallet/objects/request/request.dart';
import 'package:dreamwallet/screen/admins/accountdetailscreen.dart';
import 'package:dreamwallet/style/buttonstyle.dart';
import 'package:flutter/material.dart';

import 'package:dreamwallet/objects/account/privileges/root.dart';

class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({Key? key}) : super(key: key);

  @override
  _AdminAccountScreenState createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {

  int _rebuildListCount = 0;
  late Future<List<Account>> _list;
  final _formKey = GlobalKey<FormState>();
  final _nameCon = TextEditingController();
  final _mobileCon = TextEditingController();
  int _statusCon = 0;

  Future<void> _add() async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading...')));

    final phone = '62'+_mobileCon.text;
    final name = _nameCon.text;

    int statusCode = 0;
    if (AccountPrivilege.parseInt(_statusCon) is Seller) {
      statusCode = await Request().adminCreateMerchant(phone, name);
    }
    else if (AccountPrivilege.parseInt(_statusCon) is Cashier) {
      statusCode = await Request().adminCreateCashier(phone, name);
    }
    if (statusCode == 201) {
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

  Future<void> _onVerifyClient(int clientId) async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading...')));

    final statusCode = await Request().adminVerifyClient(clientId);
    if (statusCode == 201) {
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

  Future<List<Account>> _getList() async =>
      await Request().adminGetAccounts();
  
  Widget _addView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add', style: Theme.of(context).textTheme.headline4,),
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
                            value: Seller().toInt(),
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
                            value: Cashier().toInt(),
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
                            child: Text('Cashier', style: Theme.of(context).textTheme.bodyText2,),
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
              Expanded(
                child: ElevatedButton(
                  style: MyButtonStyle.primaryElevatedButtonStyle(context),
                  child: const Text('Add'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _add();
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
                child: _addView(),
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
                            onVerifyClient: (id) => _onVerifyClient(id),
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
  final void Function(int clientId) onVerifyClient;

  const _ListView(this.list, {Key? key,
    required this.onVerifyClient,
  }) : super(key: key);

  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends State<_ListView> {
  int _filterCount = 0;

  static const ACTIVE_ALL = 0;
  static const ACTIVE_ACTIVATED = 1;
  static const ACTIVE_NOTACTIVATED = 2;

  String query = '';
  late List<Account> _filteredList;

  final int nameFlex = 1;
  final int mobileFlex = 1;
  final int statusFlex = 1;
  final int isActiveFlex = 1;

  int activeGroup = 0;

  void filter() {
    _filteredList = widget.list;
    // filter query
    _filteredList = _filteredList.where((element) => element.name.toLowerCase().contains(query.toLowerCase())).toList();
    // filter activated
    switch (activeGroup) {
      case ACTIVE_ACTIVATED:
        _filteredList = _filteredList.where((element) => element.is_active ?? true).toList();
        break;
      case ACTIVE_NOTACTIVATED:
        _filteredList = _filteredList.where((element) => !(element.is_active ?? true)).toList();
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
                        Checkbox(value: o.is_active ?? true, onChanged: (!o.is_active!) ? (val) {
                          widget.onVerifyClient(o.id);
                        } : null),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text((o.is_active ?? true) ? 'Active' : 'Not Active', style: Theme.of(context).textTheme.bodyText2,),
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
                            child: const Text('DETAIL'),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (c) => AdminAccountDetailScreen(account: o)));
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
