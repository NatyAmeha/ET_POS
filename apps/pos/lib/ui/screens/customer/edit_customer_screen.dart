import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/customer_controller.dart';
import 'package:odoo_pos/resource/myStyle/MyColors.dart';
import 'package:odoo_pos/resource/strings/string.dart';
import 'package:odoo_pos/ui/widgets/country_selector.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/shop/model/country.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class EditCustomerScreen extends StatefulWidget {
  Customer? customer;
  EditCustomerScreen(Customer customer){
    this.customer = customer;
  }
  @override
  State<StatefulWidget> createState() => _EditCustomer(this.customer);
}

class _EditCustomer extends State<EditCustomerScreen> {
  var customerController = Get.find<CustomerController>();
  Customer? customer;
  _EditCustomer( this.customer);
  TextEditingController nameControler = new TextEditingController();
  TextEditingController emailControler = new TextEditingController();
  TextEditingController phoneControler = new TextEditingController();
  TextEditingController streetControler = new TextEditingController();
  TextEditingController cityControler = new TextEditingController();
  TextEditingController postCodeControler = new TextEditingController();
  TextEditingController barcodeControler = new TextEditingController();
  TextEditingController taxControler = new TextEditingController();
  Customer? customerFromDb = null;
  Country? selectedCountry = null;
  bool isLoading = false;
  bool firstCheck = false;
  double _width = 98;
  double _height = 48;
  String text = "Save";
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(8);

  @override
  void initState(){
    text = AppLocalizations.of(context)!.save;
    super.initState();
    selectedCountry =  customerController.countries
      .elementAtOrNull(customerController.countries.indexWhere((element) => element.id! == (customer?.country_id ?? 1))) 
      ?? customerController.countries[0];
    nameControler..text = customer!.name!;
    emailControler..text = customer!.email!;
    phoneControler..text = customer!.phone!;
    streetControler..text = customer!.street!;
    cityControler..text = customer!.city!;
    postCodeControler..text = customer!.zip!;
    barcodeControler..text = customer!.barcode!;
    taxControler..text = customer!.vat!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.edit_customer),
      ),
      body: createForm(),
    );
  }

  TextInputField(TextEditingController controller, String hint) {
    return Container(
        margin: EdgeInsets.only(top: 8.0, left: 36, right: 36),
        child: TextFormField(
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.go,
          controller: controller,
          decoration:
          InputDecoration(border: OutlineInputBorder(), hintText: hint),
        ));
  }

  TextTitle(String title) {
    return Container(
      margin: EdgeInsets.only(top: 22.0, left: 36, right: 36),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  createForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        TextTitle(AppLocalizations.of(context)!.name),
        TextInputField(nameControler, Strings.PROMPT_NAME),
        TextTitle(AppLocalizations.of(context)!.email),
        TextInputField(emailControler, Strings.PROMPT_EMAIL),
        TextTitle(AppLocalizations.of(context)!.phone),
        TextInputField(phoneControler, Strings.PROMPT_PHONE),
        TextTitle(AppLocalizations.of(context)!.street),
        TextInputField(streetControler, Strings.PROMPT_STREET),
        TextTitle(AppLocalizations.of(context)!.city),
        TextInputField(cityControler, Strings.PROMPT_CITY),
        TextTitle(AppLocalizations.of(context)!.post_code),
        TextInputField(postCodeControler, Strings.PROMPT_POSTCODE),
        TextTitle(AppLocalizations.of(context)!.barcode),
        TextInputField(barcodeControler, Strings.PROMPT_BARCODE),
        TextTitle(AppLocalizations.of(context)!.tax),
        TextInputField(taxControler, Strings.PROMPT_TAX),
        TextTitle(AppLocalizations.of(context)!.country),
        CountryField(),
        isLoading ? CircularProgressIndicator() : animationButton()
      ]),
    );
  }

  animationButton() {
    return AnimatedContainer(
      // Use the properties stored in the State class.
      width: _width,
      height: _height,
      margin: const EdgeInsets.only(top: 14, bottom: 22),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(primary: MyColors.accentColor),
          child: Text(text),
          onPressed: () {
            handleCreateButtonClick();
          }),
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
      ),
      // Define how long the animation should take.
      duration: Duration(milliseconds: 600),
      // Provide an optional curve to make the animation feel smoother.
      curve: Curves.fastOutSlowIn,
    );
  }

 

  CountryField() {
    return Obx(() => customerController.countries.isNotEmpty
      ? CountrySelector(countries: customerController.countries, initialSelectedCountry: selectedCountry! , onSelected: (newCountry){
        setState(() {
          selectedCountry = newCountry;
        });
      },) 
      : Container());
  }

  void handleCreateButtonClick() async {
    if(!validData()){
       return;
    }
    setState(() {
      isLoading = true;
      _width = 30;
      text = "";
      _borderRadius = BorderRadius.circular(100);
    });

    var newCustomerInfo = Customer(widget.customer!.id, nameControler.text, streetControler.text, "0", cityControler.text,taxControler.text, selectedCountry?.id, 0, phoneControler.text, postCodeControler.text, "0", emailControler.text, barcodeControler.text, phoneControler.text, "", "unsynced");
    var result = await customerController.updateCustomer(newCustomerInfo, context);
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  bool validData() {
    var valid = true;
    late String msg;
    if(nameControler.text.isEmpty){
      valid =false;
      msg = AppLocalizations.of(context)!.customer_name_field_error;
    }
    if(emailControler.text.isEmpty){
      valid =false;
      msg = AppLocalizations.of(context)!.customer_email_field_error;
    }
    if(phoneControler.text.isEmpty){
      valid =false;
      msg = AppLocalizations.of(context)!.customer_phone_field_error;
    }
    if(!valid){
      Helper.showSnackbar(context, msg , color: Colors.red);
    }
    return valid;
  }
}
