import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:hozmacore/features/customer/services/multi_window_service.dart';
import 'package:hozmacore/constants/constants.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/customer/customer_repository.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/util/helper.dart';

class CustomerUsecase {
  ICustomerRepository? customerRepo;
  IWindowService? windowService;
  var allCustomersFromApi = <Customer>[];

  CustomerUsecase({this.customerRepo, this.windowService});

  Future<List<Customer>> findCustomer(String filter) async {
    var result = await customerRepo!.filterCustomersFromDb(filter);
    return result;
  }

  Future<List<Customer>> getCustomersFromDb() async {
    var result = await customerRepo!.getCustomersFromDb();
    return result;
  }

  Future<List<Customer>> getCustomersFromApiAndInsertToDb(int offset , int limit) async{
    var shopId = await Helper.getDataFromPreference<int>(SharedPreferenceRepository.SHOP_ID);
    if(shopId != null){
      var customerReponse = await customerRepo!.getCustomersFromApi(shopId, offset.toString(), limit.toString());
       print("customer save api ${customerReponse.message} ${customerReponse.success}");
      if(customerReponse.success == true && customerReponse.customers?.isNotEmpty == true){
        allCustomersFromApi.addAll(customerReponse.customers!);
        //insert customer to db
        var a = await customerRepo!.insertMultipleCustomersToDb(customerReponse.customers!);
        print("customer save $a");
        var totalCustomerFromApi = customerReponse.customer_count ?? -1;
        if(totalCustomerFromApi == -1 || offset+limit < totalCustomerFromApi){
          return getCustomersFromApiAndInsertToDb(offset+limit, limit);
        }else{
           return allCustomersFromApi;
        }
      }else{
        return [];
      }
    }else{
      return Future.error(AppException(message: "Unable to get shop id"));
    }
  }

  Future<bool> addNewCustomerandSyncWithDb(Customer customerInfo) async {
    var apiResult = await customerRepo!.createCustomerOnApi(customerInfo);
    if(apiResult.success == true){
      customerInfo.id == apiResult.partnerId;
      customerInfo.status = "synced";
    } else {
      customerInfo.id == apiResult.partnerId;
      customerInfo.status = "unsynced";
    }
    var result  = await customerRepo!.insertCustomerToDb(customerInfo);
    return result;
  }

  Future<bool> updateCustomerInfo(int id , Customer customer) async{
    var apiResult = await customerRepo!.updateCustomerOnApi(id.toString(), customer);
    if(apiResult.success == true){
      customer.id == apiResult.partnerId;
      customer.status = "synced";
      var result  = await customerRepo!.updateCustomerOnDb(customer);
      return result;
    }else {
      customer.id == apiResult.partnerId;
      customer.status = "unsynced";
      var result  = await customerRepo!.updateCustomerOnDb(customer);
      return result;
    }
  }

  Future<int> openCustomerDisplayScreen(String arg) async {
    var window = await windowService!.openNewWindow(arg);
    return window;
  }

  Future<void> sendCartInfoToCustomerDisplay(int windowId, String arg) async {
    await windowService!.sendMessageToWindows(windowId, arg);
  }
}
