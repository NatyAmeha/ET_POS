
import 'package:flutter/material.dart';
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PrinterListTile extends StatelessWidget {
  HTPrinter device;
  Function(String)? onActionSelected;
  bool isConnected;
  bool isPairedBefore;
  PrinterListTile({
    required this.device,
    this.isConnected = false,
    this.onActionSelected,
    this.isPairedBefore = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer( 
        borderRadius: 16,
        borderColor: Colors.grey[300], 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: TextView(device.deviceName,
                        maxline: 2,
                        textStyle: Theme.of(context).textTheme.bodyMedium)),
                Spacer(),
                PopupMenuButton<String>(
                  offset: Offset(20, 40),
                  onSelected: (value) {
                    onActionSelected?.call(value);
                  },
                  itemBuilder: (context) {
                    return [
                      !isConnected
                          ? PopupMenuItem(
                              value: PrinterAction.Connect.name,
                              child: Row(
                                children: [
                                  Icon(Icons.cloud_done_outlined),
                                  const SizedBox(width: 10),
                                  TextView(PrinterAction.Connect.name,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ],
                              ))
                          : PopupMenuItem(
                              value: PrinterAction.Disconnect.name,
                              child: Row(
                                children: [
                                  Icon(Icons.cloud_off_outlined),
                                  const SizedBox(width: 10),
                                  TextView(PrinterAction.Disconnect.name,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ],
                              )),
                      if (isConnected)
                        PopupMenuItem(
                            value: PrinterAction.TestPrint.name,
                            child: Row(
                              children: [
                                Icon(Icons.print),
                                const SizedBox(width: 10),
                                TextView(AppLocalizations.of(context)!.test_print,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ],
                            )),
                      if (isPairedBefore)
                        PopupMenuItem(
                            value: PrinterAction.Remove.name,
                            child: Row(
                              children: [
                                Icon(Icons.remove_circle_outline),
                                const SizedBox(width: 10),
                                TextView(PrinterAction.Remove.name,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ],
                            )),
                      if(isConnected)
                      PopupMenuItem(
                          value: PrinterAction.Info.name,
                          child: Row(
                            children: [
                              Icon(Icons.info_outline),
                              const SizedBox(width: 10),
                              TextView(PrinterAction.Info.name,
                                  textStyle:
                                      Theme.of(context).textTheme.titleMedium),
                            ],
                          ))
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.check_circle,
                  color: isConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: TextView(
                        isConnected ? AppLocalizations.of(context)!.connected  : AppLocalizations.of(context)!.not_connected,
                        textStyle: Theme.of(context).textTheme.titleMedium)),
                selectIcon()
              ],
            ),
          ],
        ));
  }

  

  Widget selectIcon() {
    IconData icon = Icons.language;
    if (device.typePrinter == HTPrinterType.USB.name) {
      icon = Icons.usb;
    } else if (device.typePrinter == HTPrinterType.NETWORK.name) {
      icon = Icons.wifi;
    } else if (device.typePrinter == HTPrinterType.BLUTOOTH.name) {
      icon = Icons.bluetooth;
    }
    return IconButton(
        onPressed: null,
        icon: Icon(icon,
            color: isConnected ? Colors.green : Colors.grey));
  }
}
