import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/controller/customer_controller.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/shared_models/Response.dart';
import 'package:odoo_pos/resource/myStyle/MyColors.dart';
import 'package:odoo_pos/ui/screens/customer/add_customer_screen.dart';
import 'package:odoo_pos/ui/screens/customer/edit_customer_screen.dart';
import 'package:odoo_pos/ui/widgets/CommonWidgets.dart';
import 'package:odoo_pos/ui/widgets/customer_list_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class CustomerSelectionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CustomerSelection();
}

class CustomerSelection extends State<CustomerSelectionPage> {
  var customerController = Get.put(CustomerController());
  Icon _searchIcon = new Icon(Icons.search);
  final TextEditingController _filter = new TextEditingController();
  Widget _appBarTitle = new Text("Select customer");
  String _searchText = "";
  List<Customer> filteredCustomer = [];
  int mSelectedIndex = -1;

  void _searchPressed() {
    _filter.text = AppLocalizations.of(context)!.select_customer;
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          onChanged: (text) {
            customerController.searchCustomerByName(text, context);
          },
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: AppLocalizations.of(context)!.search),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text(AppLocalizations.of(context)!.select_customer);
        _filter.clear();
      }
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero , (){
      customerController.getCustomers(context);
      customerController.getCountries(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: _appBarTitle,
            actions: [
              IconButton(
                icon: _searchIcon,
                onPressed: _searchPressed,
              ),
              TextButton(
                  onPressed: () {
                    if (mSelectedIndex != -1)
                      Navigator.pop(context, customerController.customers[mSelectedIndex]);
                    else
                      Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.done,
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
          body: SafeArea(
            child: Obx((){
              switch (customerController.customerResponseStatus) {
                case Status.LOADING:
                  return CommonWidgets.showProgressbar();
                case Status.COMPLETED:
                  return Container(
                    child: ListView.builder(
                      itemCount: customerController.customers.length,
                      itemBuilder: (BuildContext context, int index) {
                        var customer = customerController.customers[index];
                        return CustomerListTile(customerInfo: customer, index:  index, selectedIndex: mSelectedIndex, onClick: (){
                          setState(() {
                            if (index == mSelectedIndex){
                              mSelectedIndex = -1;
                            }else
                              mSelectedIndex = index;
                            });
                        }, onEditClicked: (){
                          setState(() {
                            mSelectedIndex = index;
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditCustomerScreen(customerController.customers[mSelectedIndex])));
                        });
                        
                    })
                  );
                case Status.ERROR:
                  return CommonWidgets.showErrorMessage(context, customerController.errorMessage);
              }
            })
        
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => AddCustomerScreen()));
            },
            hoverColor: MyColors.textColorOnAccent,
            child: Icon(Icons.person_add_rounded,
                color: MyColors.textColorOnAccent),
            backgroundColor: MyColors.accentColor,
          ),
        );
  }
}
