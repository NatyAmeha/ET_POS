import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/shop/model/country.dart';

class CountrySelector extends StatelessWidget {
  List<Country> countries;
  Country initialSelectedCountry;
  Function(Country?)? onSelected;

  CountrySelector({required this.countries , required this.initialSelectedCountry , this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
        margin: EdgeInsets.only(top: 8.0, left: 36, right: 36),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[600]!, width: 1),
            borderRadius: BorderRadius.circular(4)),
        child: DropdownButton<Country>(
          isExpanded: true,
          value: initialSelectedCountry,
          menuMaxHeight: MediaQuery.of(context).size.height,
          iconEnabledColor: Colors.white,
          iconDisabledColor: Colors.white,
          onChanged: (Country? newValue) {
            onSelected?.call(newValue);
          },
          items: countries.map<DropdownMenuItem<Country>>((Country value) {
            return DropdownMenuItem<Country>(
              value: value,
              child: TextView(value.name, maxline: 1,),
            );
          }).toList(),
        ));
  }
}