
import 'package:dreamwallet/components/form_decoration.dart';
import 'package:dreamwallet/components/form_dropdown_search.dart';
import 'package:dreamwallet/dialogs/base_dialog.dart';
import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/request/request.dart';
import 'package:flutter/material.dart';

class TopupCreateDialog extends StatefulWidget {
  final Function(int clientId, double total) onSave;

  const TopupCreateDialog({Key? key, required this.onSave,
  }) : super(key: key);

  @override
  State<TopupCreateDialog> createState() => _TopupCreateDialogState();
}

class _TopupCreateDialogState extends State<TopupCreateDialog> {
  final _key = GlobalKey<FormState>();
  Account? _clientCon;
  late final TextEditingController _totalCon;
  List<Account>? _clientList;

  @override
  void initState() {
    _totalCon = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Topup',
      contents: [
        SingleChildScrollView(
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormDropdownSearch<Account>(
                  label: 'Client',
                  compareFn: (o1, o2) => o1?.id == o2?.id,
                  onPick: (item) {
                    setState(() {
                      _clientCon = item;
                    });
                  },
                  showItem: (item) => '${item.id} - ${item.name}',
                  onFind: (query) async {
                    _clientList ??= await Request().cashierGetClients();
                    if (query == null || query.isEmpty) return _clientList!;
                    return _clientList!.where((element) {
                      if (element.id.toString().contains(query)) return true;
                      if (element.name.toLowerCase().contains(query)) return true;
                      return false;
                    }).toList();
                  },
                ),
                TextFormField(
                  controller: _totalCon,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Total',
                    prefixText: 'IDR ',
                  ),
                  validator: (e) {
                    if (e == null || e.isEmpty) return 'Please fill the field.';
                    int? value = int.tryParse(_totalCon.text);
                    if (value == null) return 'Only input numbers in this field.';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        BaseDialogActions(
          formKey: _key,
          onSave: () => widget.onSave(_clientCon!.id, double.tryParse(_totalCon.text)!),
        ),
      ],
    );
  }
}