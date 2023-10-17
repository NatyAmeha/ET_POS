import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';

class CartAndMoneyReturnIndicator extends StatelessWidget {
  String carttotalPrice;
  Function? onMoneyReturnClic;
  Function? onShoppingCartClicked;
  CartAndMoneyReturnIndicator({
    required this.carttotalPrice,
    this.onMoneyReturnClic,
    this.onShoppingCartClicked,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: SizedBox(
        height: 90,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: CustomContainer(
            alignment: Alignment.topCenter,
            width: double.infinity,
            child: Row(
              children: [
                FilledButton(
                    onPressed: () {
                      onMoneyReturnClic?.call();
                    },
                    child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Icon(Icons.rotate_left))),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      onShoppingCartClicked?.call();
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.shopping_cart),
                          TextView(carttotalPrice,textColor: Colors.white,  textStyle : Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
