import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/ui/widgets/custom_text_field.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkPrinterScannerDialog extends StatefulWidget {
  NetworkPrinterAction action;
  Function(String ip , String? port)? onConfirm;
  NetworkPrinterScannerDialog({required this.action, this.onConfirm});

  @override
  State<NetworkPrinterScannerDialog> createState() =>
      _NetworkPrinterScannerDialogState();
}

class _NetworkPrinterScannerDialogState
    extends State<NetworkPrinterScannerDialog> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var headerText = widget.action == NetworkPrinterAction.CONNECT
        ? AppLocalizations.of(context)!.connect_to_printer
        : AppLocalizations.of(context)!.scan_network_printer;
    var buttonText =
        widget.action == NetworkPrinterAction.CONNECT ? AppLocalizations.of(context)!.printer_connect : AppLocalizations.of(context)!.scan;
    return Center(
      child: Material(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              SizedBox(
                width: Helper.isTablet(context)
                    ? MediaQuery.of(context).size.width * 0.5
                    : MediaQuery.of(context).size.width * 0.8,
                child: Padding(
                  padding:
                       EdgeInsets.all(Helper.isTablet(context) ? 70 : 30),
                  child: SingleChildScrollView(
                      child: Column(
                    children: [
                      const SizedBox(height: 30),
                      TextView(headerText,
                          textStyle: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(height: 40),
                      CustomTextField(
                        controller: _ipController,
                        inputType:
                            const TextInputType.numberWithOptions(signed: true),
                        label: AppLocalizations.of(context)!.ip_address,
                        prefixIcon: Icons.wifi,
                        onchanged: (p0) {
                          setState(() {});
                        },
                      ),
                      if (widget.action == NetworkPrinterAction.CONNECT) ...[
                        const SizedBox(height: 32),
                        CustomTextField(
                            controller: _portController,
                            inputType: const TextInputType.numberWithOptions(
                                signed: true),
                            label: AppLocalizations.of(context)!.port,
                            prefixIcon: Icons.numbers_outlined,
                            onchanged: (value) {
                              setState(() {});
                            }),
                      ],
                      const SizedBox(height: 24), 
                      FilledButton(
                          onPressed: canEnableBtn() ? () {
                            Navigator.of(context).pop();
                            widget.onConfirm?.call(_ipController.text , _portController.text);
                          } : null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Text(buttonText))),
                      const SizedBox(height: 16),
                      
                    ],
                  )),
                ),
              ),
              Positioned(
                  right: 16,
                  top: 16,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close),
                  ))
            ],
          )),
    );
  }

  canEnableBtn(){
    if(widget.action == NetworkPrinterAction.CONNECT){
      return _ipController.text.isNotEmpty && _portController.text.isNotEmpty ;
    }
    else{
     return _ipController.text.isNotEmpty;
    }
  }
}
