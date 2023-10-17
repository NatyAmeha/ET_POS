import 'package:flutter/material.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrinterReceptDebug extends StatefulWidget {
  bool smallScreen;
  Function? onBackButton;
  PrinterReceptDebug({super.key, this.smallScreen = false, this.onBackButton});

  @override
  State<PrinterReceptDebug> createState() => _PrinterReceptDebugState();
}

class _PrinterReceptDebugState extends State<PrinterReceptDebug> {
  final pageViewController = PageController(initialPage: 0);
  var currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomContainer(
          padding: 8,
          alignment: Alignment.topCenter,
          width: Helper.isTablet(context)
              ? MediaQuery.of(context).size.width * 0.5
              : MediaQuery.of(context).size.width,
          height: Helper.isTablet(context)
              ? MediaQuery.of(context).size.height * 0.8
              : MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                 SizedBox(height: Helper.isTablet(context) ? 52 : 16),
                TextView(
                  AppLocalizations.of(context)!.erro_occured_please_try_again,
                  textStyle: Helper.isTablet(context) ? Theme.of(context).textTheme.displayMedium : Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextView(
                    AppLocalizations.of(context)!.printer_setup_error_description,
                    maxline: 2,
                    textAlignment: TextAlign.center,
                    textStyle: Helper.isTablet(context) ? Theme.of(context).textTheme.bodyLarge : Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: widget.smallScreen ? 16 :  40),
                widget.smallScreen
                    ? buildDebugInfoForSmallScreen()
                    : buildDebugInfoForLargeScreen(context),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FilledButton(
                onPressed: () {
                  this.widget.onBackButton?.call();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(AppLocalizations.of(context)!.back_to_printer_setting),
                ),
              ),
            ))
      ],
    );
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }

  buildDebugInfoForSmallScreen() {
    return Stack(
      children: [
        CustomContainer(
          borderColor: Colors.grey[300],
          borderRadius: 8,
          customMargin: const EdgeInsets.symmetric(horizontal: 24),
          height: 575,
          child: PageView(
            controller: pageViewController,
            onPageChanged: (value) {
              updatePage(value);
            },
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [ 
                Padding(
                  padding:  const EdgeInsets.symmetric(horizontal: 50),
                  child: Image.asset("assets/images/receipt1.png", height: 400, width: 200, fit: BoxFit.cover)),
                const SizedBox(height: 16),
                TextView(
                      AppLocalizations.of(context)!.change_receipt_papersize_description,
                      textStyle: Theme.of(context).textTheme.titleLarge,
                      maxline: 10,
                      textAlignment: TextAlign.center,
                    )
              ],),
               Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50),
                        child: Image.asset("assets/images/receipt2.png",
                            height: 400, width: 200, fit: BoxFit.cover)),
                    const SizedBox(height: 16),
                    TextView(
                      AppLocalizations.of(context)!.choose_smaller_receipt_papersize_description,
                      textStyle: Theme.of(context).textTheme.titleLarge,
                      maxline: 10,
                      textAlignment: TextAlign.center,
                    )
                  ],
                ),
                 Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50),
                        child: Image.asset("assets/images/receipt3.png",
                            height: 400, width: 200, fit: BoxFit.cover)),
                    const SizedBox(height: 16),
                    TextView(
                      AppLocalizations.of(context)!.change_receipt_protocol_description,
                      textStyle: Theme.of(context).textTheme.titleLarge,
                      maxline: 10,
                      textAlignment: TextAlign.center,
                    )
                  ], 
                )
            ],
        )),
        Positioned(
          left: 32 , right: 32, top: 16 , bottom: 26,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filled(onPressed: (){
                pageViewController.animateToPage(currentPage-1, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
              }, icon: Icon(Icons.arrow_back_ios)),
              IconButton.filled(onPressed: (){
                pageViewController.animateToPage(currentPage+1, duration: Duration(milliseconds: 200), curve: Curves.easeIn);

              }, icon: Icon(Icons.arrow_forward_ios))
            ],
          )
        ),
        Positioned(
          left: 0, right: 0,  bottom: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomContainer(child: SizedBox(), color: currentPage == 0 ? Colors.blue : Colors.grey[300], width: 8, height: 8, borderRadius: 10, margin: 4),
              CustomContainer(child: SizedBox(), color: currentPage == 1 ? Colors.blue : Colors.grey[300], width: 8, height: 8, borderRadius: 10,margin: 4),
              CustomContainer(child: SizedBox(), color: currentPage == 2 ? Colors.blue : Colors.grey[300], width: 8, height: 8, borderRadius: 10,margin: 4)

          ],),
        )
      ],
    );
  }

  buildDebugInfoForLargeScreen(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: CustomContainer(
            alignment: Alignment.topCenter,
            borderRadius: 8,
            borderColor: Colors.grey[300],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/receipt1.png",
                    height: 400, width: 250, fit: BoxFit.cover),
                const SizedBox(height: 24),
                TextView(
                  AppLocalizations.of(context)!.change_receipt_papersize_description,
                  textStyle: Theme.of(context).textTheme.titleLarge,
                  maxline: 10,
                  textAlignment: TextAlign.center,
                )
              ],
            ),
          ),
        ),
        SizedBox(width: 40),
        Expanded(
          flex: 1,
          child: CustomContainer(
            alignment: Alignment.topCenter,
            borderRadius: 8,
            borderColor: Colors.grey[200],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/receipt2.png",
                    height: 450, width: 250, fit: BoxFit.cover),
                const SizedBox(height: 24),
                TextView(
                  AppLocalizations.of(context)!.choose_smaller_receipt_papersize_description,
                  textStyle: Theme.of(context).textTheme.titleLarge,
                  maxline: 10,
                  textAlignment: TextAlign.center,
                )
              ],
            ),
          ),
        ),
        SizedBox(width: 40),
        Expanded(
          flex: 1,
          child: CustomContainer(
            alignment: Alignment.topCenter,
            borderRadius: 8,
            borderColor: Colors.grey[200],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/receipt3.png",
                    height: 400, width: 250, fit: BoxFit.cover),
                const SizedBox(height: 24),
                TextView(
                  AppLocalizations.of(context)!.change_receipt_protocol_description,
                  textStyle: Theme.of(context).textTheme.titleLarge,
                  maxline: 10,
                  textAlignment: TextAlign.center,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  updatePage(int selectedPage){
    setState(() {
      currentPage = selectedPage;
    });
  }
}
