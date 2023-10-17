import 'dart:convert';

import 'package:hozmacore/features/customer/model/addCustomerResponse.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/datasource/api/ApiEndpoint.dart';
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/exception/app_exception.dart';

abstract class ICustomerRepository{
   Future<List<Customer>> filterCustomersFromDb(String enteredText);
   Future<bool> insertCustomerToDb(Customer customerInfo);
   Future<AddCustomerResponse> createCustomerOnApi(Customer customerInfo);
   Future<bool> insertMultipleCustomersToDb(List<Customer> customers);
   Future<bool> updateCustomerOnDb(Customer customer);
   Future<AddCustomerResponse> updateCustomerOnApi(String id , Customer customerInfo);
   Future<CustomerResponse> getCustomersFromApi(int shopId, String offset, String limit);
   Future<List<Customer>> getCustomersFromDb();
}

class CustomerRepository extends ICustomerRepository{
  APIEndPoint? apiClient;
  IDbRepository? dbRepository;
  ISharedPrefRepository? sharedPrefRepo;

  CustomerRepository({this.apiClient, this.dbRepository, this.sharedPrefRepo = const SharedPreferenceRepository()});
  
  @override
  Future<List<Customer>> getCustomersFromDb() async {
    try {
      var mapResult = await dbRepository!.getAll<Map<String, dynamic>>(DBRepository.CUSTOMER_TABLE);
      var customerResults = mapResult.map((e) => Customer.fromJson(e)).toList();
      return customerResults;   
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  @override
  Future<CustomerResponse> getCustomersFromApi(int shopId, String offset, String limit) async {
   try{
      var customerResponse = await apiClient!.getCustomers(shopId.toString() , offset , limit);
      return customerResponse;
   }catch(ex){
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<List<Customer>> filterCustomersFromDb(String enteredText) async {
     try {
      var mapResult = await dbRepository!.queryWithFilter(DBRepository.CUSTOMER_TABLE , "name LIKE ? OR phone LIKE ? OR street LIKE ?" , ['%$enteredText%' , '%$enteredText%' , '%$enteredText%']);
      var customerResult = mapResult.map((e) => Customer.fromJson(e)).toList();
      return customerResult;   
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  Future<bool> insertMultipleCustomersToDb(List<Customer> customers) async {
    try {
      await Future.forEach(customers, (customer) async{
        await dbRepository!.create<int , Customer>(DBRepository.CUSTOMER_TABLE, customer);
      });
      return true;       
    } catch (ex) {
      var excep = ex as AppException;
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> updateCustomerOnDb(Customer customer) async {
    try {
      var updateResult = await dbRepository!.updateWithFilter(DBRepository.CUSTOMER_TABLE, customer.toJson() , "id = ?", [customer.id] );
      return updateResult;      
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> insertCustomerToDb(Customer customerInfo) async {
    try {
      var result = await dbRepository!.create<int , Customer>(DBRepository.CUSTOMER_TABLE, customerInfo);
      return result > 0;       
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<AddCustomerResponse> createCustomerOnApi(Customer customerInfo) async {
    try{
      Map<String, dynamic> dataToSendToApi = <String, dynamic>{
      "zip": customerInfo.zip,
      "city": customerInfo.city,
      "barcode": customerInfo.barcode,
      "vat": customerInfo.vat,
      "phone": customerInfo.phone,
      "street": customerInfo.street,
      "country_id": customerInfo.country_id,
      "name": customerInfo.name,
      "email": customerInfo.email
      };
      var result = await apiClient!.createCustomer(json.encode(dataToSendToApi));
      return result;
    }catch(ex){
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<AddCustomerResponse> updateCustomerOnApi(String id , Customer customerInfo) async {
    try{
      Map<String, dynamic> dataToSendToApi = <String, dynamic>{
      "zip": customerInfo.zip,
      "city": customerInfo.city,
      "barcode": customerInfo.barcode,
      "vat": customerInfo.vat,
      "phone": customerInfo.phone,
      "street": customerInfo.street,
      "country_id": customerInfo.country_id,
      "name": customerInfo.name,
      "email": customerInfo.email
      };
      var result = await apiClient!.editCustomer(customerInfo.id.toString(),  json.encode(dataToSendToApi));
      return result;
    }catch(ex){
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

}