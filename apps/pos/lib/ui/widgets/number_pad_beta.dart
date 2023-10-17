import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hozmacore/constants/constants.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';

// will replace number pad widget
class NumberPadBeta extends StatefulWidget {
  bool disableQty;
  bool disablePrice;
  bool disableDiscount;
  bool hideActionPad;
  String? initialAction;
  List<Widget>? additionalActions;
  double heightFactorForActionPad;
  double widthFactorForActionPad;
  Function(String)? onNumberClicked;
  Function(String)? onActionSelected;
  NumberPadBeta(
      {this.disableQty = false,
      this.disablePrice = false,
      this.disableDiscount = false,
      this.hideActionPad = false,
      this.additionalActions,
      this.initialAction = "QTY",
      this.heightFactorForActionPad = 4,
      this.widthFactorForActionPad = 2,
      this.onNumberClicked,
      this.onActionSelected});

  @override
  State<NumberPadBeta> createState() => _NumberPadBetaState();
}

class _NumberPadBetaState extends State<NumberPadBeta> {
  var selectedAction = "";
  var value = "";

  @override
  void initState() {
    selectedAction = widget.initialAction!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          if (widget.additionalActions != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.additionalActions!
                  .map((element) => SizedBox(
                      height: constraints.maxHeight /
                          widget.heightFactorForActionPad,
                      width: (constraints.maxWidth /
                          (((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad) /
                              widget.widthFactorForActionPad)),
                      child: element))
                  .toList(),
            ),
          Column(
            children: [
              CustomContainer(
                padding: 0,
                onTap: () {
                  setState(() {
                    value = value + "1";
                    widget.onNumberClicked?.call("1");
                  });
                },
                borderRadius: 0,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView("1",
                    textStyle: Theme.of(context).textTheme.titleMedium),
              ),
              CustomContainer(
                padding: 0,
                onTap: () {
                  setState(() {
                    value = value + "4";
                    widget.onNumberClicked?.call("4");
                  });
                },
                borderRadius: 0,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView("4",
                    textStyle: Theme.of(context).textTheme.titleMedium),
              ),
              CustomContainer(
                padding: 0,
                onTap: () {
                  setState(() {
                    value = value + "7";
                    widget.onNumberClicked?.call("7");
                  });
                },
                borderRadius: 0,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView("7",
                    textStyle: Theme.of(context).textTheme.titleMedium),
              ),
              CustomContainer(
                padding: 0,
                onTap: () {},
                borderRadius: 0,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView(""),
              )
            ],
          ),
          Column(
            children: [
              CustomContainer(
                padding: 0,
                onTap: () {
                  setState(() {
                    value = value + "2";
                    widget.onNumberClicked?.call("2");
                  });
                },
                borderRadius: 0,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView("2",
                    textStyle: Theme.of(context).textTheme.titleMedium),
              ),
              CustomContainer(
                padding: 0,
                onTap: () {
                  setState(() {
                    value = value + "5";
                    widget.onNumberClicked?.call("5");
                  });
                },
                borderRadius: 0,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView("5",
                    textStyle: Theme.of(context).textTheme.titleMedium),
              ),
              CustomContainer(
                padding: 0,
                onTap: () {
                  setState(() {
                    value = value + "8";
                    widget.onNumberClicked?.call("8");
                  });
                },
                borderRadius: 0,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView("8",
                    textStyle: Theme.of(context).textTheme.titleMedium),
              ),
              CustomContainer(
                padding: 0,
                onTap: () {
                  setState(() {
                    value = value + "0";
                    widget.onNumberClicked?.call("0");
                  });
                },
                borderRadius: 0,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView("0",
                    textStyle: Theme.of(context).textTheme.titleMedium),
              )
            ],
          ),
          Column(
            children: [
              CustomContainer(
                padding: 0,
                selectedBorderSidesForRadius: widget.hideActionPad ? [0,8,0,0] : null,
                onTap: () {
                  setState(() {
                    value = value + "3";
                    widget.onNumberClicked?.call("3");
                  });
                },
                borderRadius: 0,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView("3",
                    textStyle: Theme.of(context).textTheme.titleMedium),
              ),
              CustomContainer(
                padding: 0,
                onTap: () {
                  setState(() {
                    value = value + "6";
                    widget.onNumberClicked?.call("6");
                  });
                },
                borderRadius: 0,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView("6",
                    textStyle: Theme.of(context).textTheme.titleMedium),
              ),
              CustomContainer(
                padding: 0,
                onTap: () {
                  setState(() {
                    value = value + "9";
                    widget.onNumberClicked?.call("9");
                  });
                },
                borderRadius: 0,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView("9",
                    textStyle: Theme.of(context).textTheme.titleMedium),
              ),
              CustomContainer(
                padding: 0,
                onTap: () {
                  setState(() {
                    value = value + ".";
                    widget.onNumberClicked?.call(".");
                  });
                },
                selectedBorderSidesForRadius: widget.hideActionPad ? [0,0,9,0] : null,
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView(".",
                    textStyle: Theme.of(context).textTheme.titleMedium),
              )
            ],
          ),
          if(!widget.hideActionPad)
          Column(
            children: [
              CustomContainer(
                padding: 0,
                onTap: !widget.disableQty
                    ? () {
                        setState(() {
                          selectedAction = NumberPadAction.QTY.name;
                        });
                        widget.onActionSelected?.call(NumberPadAction.QTY.name);
                      }
                    : null,
                selectedBorderSidesForRadius: [0, 8, 0, 0],
                borderColor: selectedAction == NumberPadAction.QTY.name
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey[400],
                color: widget.disableQty
                    ? Colors.grey[200]
                    : (selectedAction == NumberPadAction.QTY.name
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : null),
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView(AppLocalizations.of(context)!.cartQty,
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    textColor: widget.disableQty ? Colors.grey : null),
              ),
              CustomContainer(
                padding: 0,
                onTap: !widget.disableDiscount
                    ? () {
                        setState(() {
                          selectedAction = NumberPadAction.DISCOUNT.name;
                        });
                        widget.onActionSelected?.call(NumberPadAction.DISCOUNT.name);
                      }
                    : null,
                color: widget.disableDiscount
                    ? Colors.grey[200]
                    : (selectedAction == NumberPadAction.DISCOUNT.name
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : null),
                borderColor: selectedAction == NumberPadAction.DISCOUNT.name
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView(
                  AppLocalizations.of(context)!.cartDisc,
                  textStyle: Theme.of(context).textTheme.titleMedium,
                  textColor: widget.disableDiscount ? Colors.grey : null,
                ),
              ),
              CustomContainer(
                padding: 0,
                onTap: !widget.disablePrice
                    ? () {
                        setState(() {
                          selectedAction = NumberPadAction.PRICE.name;
                        });
                        widget.onActionSelected?.call(NumberPadAction.PRICE.name);
                      }
                    : null,
                color: widget.disablePrice
                    ? Colors.grey[200]
                    : (selectedAction == NumberPadAction.PRICE.name
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : null),
                borderColor: selectedAction == NumberPadAction.PRICE.name
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: TextView(AppLocalizations.of(context)!.cartPrice,
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    textColor: widget.disablePrice ? Colors.grey : null),
              ),
              CustomContainer(
                padding: 0,
                onTap: () {
                        widget.onActionSelected?.call(NumberPadAction.DELETE.name);
                      },
                selectedBorderSidesForRadius: [0,0,8,0],
                borderColor: Colors.grey[400],
                height: constraints.maxHeight / 4,
                width: widget.additionalActions != null
                    ? constraints.maxWidth /
                        ((widget.hideActionPad? 3 : 4) + widget.widthFactorForActionPad)
                    : constraints.maxWidth / 4,
                alignment: Alignment.center,
                child: Icon(Icons.backspace),
              )
            ],
          ),
        ],
      );
    });
  }
}
