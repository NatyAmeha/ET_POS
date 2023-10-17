import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/shop/model/country.dart';
import 'package:hozmacore/shared_models/Response.dart' as AppResponse;
import 'package:hozmacore/features/customer/customer_repository.dart';
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/features/shop/shop_repository.dart';
import 'package:hozmacore/features/customer/customer_usecase.dart';
import 'package:hozmacore/features/shop/shop_usecase.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class CustomerController extends GetxController{
  var appController = Get.find<AppController>();

  var _customers = AppResponse.Response<List<Customer>>.loading(null).obs;
  AppResponse.Status get  customerResponseStatus => _customers.value.status;
  List<Customer> get customers => _customers.value.data ?? [];
  String get errorMessage  => _customers.value.message ?? "";

  var countries = <Country>[].obs;
  
  getCustomers(BuildContext context) async{
    try {
      var customerUsecase = CustomerUsecase(customerRepo: CustomerRepository(dbRepository: DBRepository(DbName: appController.dbName!)));
      var result = await customerUsecase.getCustomersFromDb();
      if(result.isNotEmpty){
        _customers.value = AppResponse.Response.completed(result);
      }else{
        _customers.value = AppResponse.Response.error(AppLocalizations.of(context)!.no_customer_found);
      }
    } catch (ex) {
      _customers.value = AppResponse.Response.error(AppLocalizations.of(context)!.no_customer_found);
      Helper.showSnackbar(context, AppLocalizations.of(context)!.erro_occured_please_try_again);
    }
  }

  searchCustomerByName(String query , BuildContext context) async{
    try {
      var customerUsecase = CustomerUsecase(customerRepo: CustomerRepository(dbRepository: DBRepository(DbName: appController.dbName!)));
      var result = await customerUsecase.findCustomer(query);
      if(result.isNotEmpty){
        _customers.value = AppResponse.Response.completed(result);
      }else{
        _customers.value = AppResponse.Response.error(AppLocalizations.of(context)!.no_customer_found);
      }
    } catch (ex) {
      _customers.value = AppResponse.Response.error(AppLocalizations.of(context)!.no_customer_found);
      Helper.showSnackbar(context, AppLocalizations.of(context)!.erro_occured_please_try_again);
    }
  }


  addNewCustomer(Customer customer, BuildContext context) async{
    try {
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var customerUsecase = CustomerUsecase(customerRepo: CustomerRepository(apiClient : appController.apiClient!, dbRepository: dbRepo));
      var result = await customerUsecase.addNewCustomerandSyncWithDb(customer);
      var newCustomersList = _customers.value.data ?? [];
      newCustomersList.add(customer);
      _customers.value = AppResponse.Response.completed(newCustomersList);
    } catch (ex) {
      Helper.showSnackbar(context, AppLocalizations.of(context)!.erro_occured_please_try_again , color: Colors.red);
    }
  }

  Future<bool> updateCustomer(Customer customer, BuildContext context) async{
    try {
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var customerUsecase = CustomerUsecase(customerRepo: CustomerRepository(apiClient : appController.apiClient!, dbRepository: dbRepo));
      var result = await customerUsecase.updateCustomerInfo(customer.id!,  customer);
      if(result){
        var updatedCustomerList = _customers.value.data ?? [];
        updatedCustomerList[updatedCustomerList.indexWhere((element) => element.id == customer.id)] = customer;
        _customers.value = AppResponse.Response.completed(updatedCustomerList);
      }else{
        Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_update_customer);
      }
      return result;
    } catch (ex) {
      Helper.showSnackbar(context, AppLocalizations.of(context)!.erro_occured_please_try_again , color: Colors.red);
      return false;
    }
  }

  getCountries(BuildContext context) async {
    try{
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var shopUsecase = ShopUsecase(shopRepo: ShopRepository(dbRepository: dbRepo));
      var countriesResult = await shopUsecase.getCountriesFromDb();
      countries.value = countriesResult;
    } on AppException catch(ex){
      Helper.showSnackbar(context, AppLocalizations.of(context)!.erro_occured_please_try_again , color: Colors.red);
   }
  }
}