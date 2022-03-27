
import 'package:dreamwallet/components/form_decoration.dart';
import 'package:dreamwallet/components/form_dropdown_search.dart';
import 'package:dreamwallet/dialogs/base_dialog.dart';
import 'package:dreamwallet/objects/account/account.dart';
import 'package:dreamwallet/objects/request/request.dart';
import 'package:dreamwallet/objects/tempdata.dart';
import 'package:flutter/material.dart';

class MigrateDialog extends StatefulWidget {
  final Account selectedClient;
  final Function() onSave;

  const MigrateDialog({Key? key,
    required this.selectedClient, required this.onSave,
  }) : super(key: key);

  @override
  State<MigrateDialog> createState() => _MigrateDialogState();
}

class _MigrateDialogState extends State<MigrateDialog> {
  final _key = GlobalKey<FormState>();
  Account? _clientCon;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Migrate',
      contents: [
        SingleChildScrollView(
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    widget.selectedClient.name,
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text('Pick which account from past event you want to migrate from.'),
                ),
                FormDropdownSearch<Account>(
                  label: 'Client',
                  compareFn: (o1, o2) => o1?.id == o2?.id,
                  onPick: (item) {
                    setState(() {
                      _clientCon = item;
                    });
                  },
                  showItem: (item) => '${item.mobile} - ${item.name}',
                  onFind: (query) async => Temp.oldAccountList!,
                ),
              ],
            ),
          ),
        ),
        Stack(
          children: [
            if (!_isLoading) BaseDialogActions(
              formKey: _key,
              onSave: () async {
                setState(() {
                  _isLoading = true;
                });
                final isSuccess = await Request().adminMigrate(_clientCon!, widget.selectedClient);
                setState(() {
                  _isLoading = false;
                });
                if (isSuccess) {
                  await Temp.fillTopupData();
                  await widget.onSave();
                  Navigator.pop(context);
                  return;
                }
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Terjadi masalah saat migrasi. Tolong ulangi lagi.')));
              },
            ),
            if (_isLoading) const Align(
              alignment: Alignment.centerRight,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ],
    );
  }
}