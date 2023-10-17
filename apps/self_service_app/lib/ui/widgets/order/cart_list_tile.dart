import 'package:flutter/material.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class CartListTile extends StatefulWidget {
  Product productInfo;
  String priceInfo;
  Function(int)? onQtyUpdated;
  Function? onDelete;
  Function? onEdit;
  CartListTile({
    super.key,
    required this.productInfo,
    required this.priceInfo,
    this.onQtyUpdated,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<CartListTile> createState() => _CartListTileState();
}

class _CartListTileState extends State<CartListTile> {
  var showDeleteUI = false;
  @override
  Widget build(BuildContext context) {
    return ContainerHelper(
      width: double.infinity,
      borderRadius: 12,
      padding: 20,
      borderColor: Colors.grey[300],
      child: Column(
        children: [
          Row(
            children: [
              ContainerHelper(
                borderColor: Theme.of(context).colorScheme.background,
                borderRadius: 20,
                width: 120,
                height: 130,
                color: Theme.of(context).colorScheme.background,
                child: Image.network(widget.productInfo.image_url!,
                    width: 90, height: 90),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextViewHelper(
                              widget.productInfo.display_name,
                              textStyle:
                                  Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(
                              2,
                              (index) => Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 25,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(width: 4),
                                  TextViewHelper(
                                      widget.productInfo.display_name,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                        TextViewHelper(widget.priceInfo,
                            textStyle:
                                Theme.of(context).textTheme.displayMedium,
                            setBold: true)
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 32)),
                          onPressed: () {
                            widget.onEdit?.call();
                          },
                          child: Text("Edit"),
                        ),
                        Spacer(),
                        ContainerHelper(
                          width: null,
                          color: Theme.of(context).colorScheme.background,
                          margin: 4,
                          padding: 0,
                          borderRadius: 6,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                showDeleteUI = !showDeleteUI;
                              });
                            },
                            icon: Icon(Icons.delete_outline),
                          ),
                        ),
                        const SizedBox(width: 32),
                        IconButton(
                            onPressed: () {
                              this
                                  .widget
                                  .onQtyUpdated
                                  ?.call(widget.productInfo.unitCount! - 1);
                            },
                            icon: Icon(Icons.remove)),
                        const SizedBox(width: 16),
                        TextViewHelper("${widget.productInfo.unitCount}",
                            textStyle: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(width: 16),
                        ContainerHelper(
                          width: null,
                          color: Theme.of(context).colorScheme.background,
                          margin: 4,
                          padding: 0,
                          borderRadius: 6,
                          child: IconButton(
                              onPressed: () {
                                this
                                    .widget
                                    .onQtyUpdated
                                    ?.call(widget.productInfo.unitCount! + 1);
                              },
                              icon: Icon(Icons.add)),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          Visibility(
            visible: showDeleteUI,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Divider(height: 16),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 75),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            setState(() {
                              showDeleteUI = false;
                            });
                          },
                          child: Text("No, Don't remove item")),
                      FilledButton(
                        onPressed: () {
                          this.widget.onDelete?.call();
                          setState(() {
                            showDeleteUI = false;
                          });
                        },
                        child: Text("Yes, Remove item"),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
