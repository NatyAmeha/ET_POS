import 'package:flutter/material.dart';
import 'package:hozmacore/features/shop/model/categoryResponse.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';


class CategoryList extends StatelessWidget {
  List<Category> categoryList;
  int selectedIndex;
  Function(int)? onCategorySelected;
  CategoryList(
      {super.key,
      required this.categoryList,
      required this.selectedIndex,
      this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      alignment: AlignmentDirectional.topStart,
      height: Helper.isTablet(context) ?  70 : 60,
      color: Colors.white,
      customPadding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: categoryList.length,
        itemBuilder: (context, index) => CategoryTile(
          categoryInfo: categoryList[index],
          index: index,
          selectedIndex: selectedIndex,
          isLast: index == categoryList.length - 1,
          onCategorySelected: () {
            onCategorySelected?.call(index);
          },
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  Category categoryInfo;
  int index;
  int selectedIndex;
  bool isLast;
  Function? onCategorySelected;
  CategoryTile({
    required this.categoryInfo,
    required this.index,
    required this.selectedIndex,
    required this.isLast,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        this.onCategorySelected?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16 ),
        margin:  (!Helper.isTablet(context) ? const EdgeInsets.symmetric(horizontal: 6) : null),
        decoration: BoxDecoration(
          color: selectedIndex == index ? Theme.of(context).colorScheme.secondaryContainer : Colors.white,
          borderRadius: BorderRadiusDirectional.only(
            topStart: index == 0 ? Radius.circular(32) : (!Helper.isTablet(context) ? Radius.circular(32) :  Radius.zero),
            bottomStart: index == 0 ? Radius.circular(32) : (!Helper.isTablet(context) ? Radius.circular(32) :  Radius.zero),
            topEnd: isLast ? Radius.circular(32) : (!Helper.isTablet(context) ? Radius.circular(32) :  Radius.zero),
            bottomEnd: isLast ? Radius.circular(32) : (!Helper.isTablet(context) ? Radius.circular(32) :  Radius.zero),
          ),
          border: Border.all(color: selectedIndex == index ? Theme.of(context).colorScheme.secondary :  Colors.grey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedIndex == index) Icon(Icons.check, color: Theme.of(context).colorScheme.secondary),
            TextView(
              "${categoryInfo.name}",textStyle: selectedIndex == index ? Theme.of(context).textTheme.titleSmall : Theme.of(context).textTheme.titleSmall,
              textColor:  selectedIndex == index ? Theme.of(context).colorScheme.secondary :  Colors.black,
            )
          ],
        ),
      ),
    );
  }
}
