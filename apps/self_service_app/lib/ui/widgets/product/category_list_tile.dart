import 'package:flutter/material.dart';
import 'package:hozmacore/features/shop/model/categoryResponse.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class CategoryListTile extends StatelessWidget {
  Category categoryInfo;
  int index;
  int selectedIndex;
  Function? onCategorySelected;
  CategoryListTile(
      {super.key,
      required this.categoryInfo,
      required this.index,
      required this.selectedIndex,
      this.onCategorySelected,
      });

  @override
  Widget build(BuildContext context) {
    return ContainerHelper(
      color: Colors.white,
      onTap: (){
        this.onCategorySelected?.call();
      },
        borderColor: index == selectedIndex ? Theme.of(context).colorScheme.primary : null,
        padding: 8,
        borderRadius: 40,
        child: ContainerHelper(
          color: Theme.of(context).colorScheme.background,
          borderRadius: 40,
          child: Column(
            children: [
              Image.asset("assets/images/eat_in.png", width: 40, height: 40),
              const SizedBox(height: 8),
              TextViewHelper(
                categoryInfo.name,
                textAlignment: TextAlign.center,
                textStyle: index == selectedIndex ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.titleSmall  ,
                textColor:
                    index == selectedIndex ? Colors.black : Colors.grey[500],
              ),
            ],
          ),
        ));
  }
}
