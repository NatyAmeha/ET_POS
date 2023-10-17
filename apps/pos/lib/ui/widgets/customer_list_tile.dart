import 'package:flutter/material.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/resource/myStyle/MyColors.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';

class CustomerListTile extends StatelessWidget {
  Customer customerInfo;
  int index;
  int selectedIndex;
  Function? onClick;
  Function? onEditClicked;
  CustomerListTile({
    required this.customerInfo,
    required this.index,
    required this.selectedIndex,
    this.onClick,
    this.onEditClicked,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onClick?.call();
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color: index == selectedIndex ? Colors.greenAccent : Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5.0)]),
        child: Helper.isTablet(context)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextView(customerInfo.name),
                        TextView(customerInfo.street),
                        TextView(customerInfo.phone),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    child: IconButton(
                        onPressed: () {
                          selectedIndex = index;
                          onEditClicked?.call();
                        },
                        icon: Icon(Icons.edit, size: 18)),
                  )
                ],
              )
            : Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: TextView(customerInfo.name)),
                    Expanded(child: TextView(customerInfo.street)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextView(customerInfo.phone, textColor: MyColors.grey),
                    IconButton(
                        onPressed: () {
                          selectedIndex = index;
                          onEditClicked?.call();
                        },
                        icon: Icon(Icons.edit, size: 18))
                  ],
                ),
              ]),
      ),
    );
  }
}
