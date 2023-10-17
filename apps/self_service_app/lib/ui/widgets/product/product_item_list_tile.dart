import 'package:flutter/material.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class ProductItemListTile extends StatelessWidget {
  Function? onDeleteClicked;
  Function? onOptionSelected;
  bool isIncluded;
  ProductItemListTile({
    super.key,
    this.isIncluded = false,
    this.onOptionSelected,
    this.onDeleteClicked,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerHelper(
      borderRadius: 20,
      padding: 10,
      borderColor: Colors.grey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ContainerHelper(
                borderRadius: 20,
                width: double.infinity,
                height: 150,
                color: Theme.of(context).colorScheme.background,
                child: Image.asset("assets/images/product_item_sample.png",
                    width: 150, height: 120),
              ),
              if (isIncluded)
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.delete,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextViewHelper("Beaf meat",
                  textStyle: Theme.of(context).textTheme.displaySmall),
              TextViewHelper(
                "0.00",
                textStyle: Theme.of(context).textTheme.displaySmall,
                textColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          if (isIncluded) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ContainerHelper(
                      customPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      width: null,
                      borderRadius: 30,
                      color: index == 0
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      borderColor: Colors.grey,
                      onTap: () {},
                      child: TextViewHelper("Option ${index + 1}",
                          textStyle: Theme.of(context).textTheme.titleMedium,
                          textColor: index == 0 ? Colors.white : Colors.grey),
                    ),
                  ),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}
