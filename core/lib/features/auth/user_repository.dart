import 'dart:convert';
import 'dart:developer';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/features/shop/model/splashResponse.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/datasource/api/custom_api_client.dart';
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';

abstract class IUserRepository {
  Future<BaseModel> login(String email, String password, String workspace);
  Future<bool> saveAgentDataToPreference(LoginResponse agentInfo);
  Future<LoginResponse> getAgentDataFromPref();
  Future<List<User>> getUsers();
  Future<bool> insertUsersToDb(List<User> userList);

  Future<CustomerResponse> getCustomersFromApi(int shopId , String offset , String limit);
  Future<List<Customer>> getCustomersFromDb();
  Future<bool> insertCustomers(List<Customer> customers);
  Future<bool> setWorkspaceUrlToPreference(String workspaceUrl);
  Future<String?> getWorkspaceUrlFromPreference();
  Future<bool> removeAllPreferenceData();
  
}

class UserRepository implements IUserRepository {
  IDbRepository? dbRepository;
  ISharedPrefRepository? sharedPrefRepository;

  UserRepository({this.dbRepository, this.sharedPrefRepository = const SharedPreferenceRepository()});

  final apiEndpoint = CustomApiClient.getClient();

  @override
  Future<BaseModel> login(
      String email, String password, String workspace) async {
    try {
      await _setWorkspace(workspace);
      
      var apiClient = await CustomApiClient.getClient();
      var loginInfoMap = <String, String>{"login": email, "pwd": password};
      await _setLoginKey(loginInfoMap);
      var response = await apiClient.loginPage();
      // api respond with 200 status code even if bad request or unauthorized request is sent
      // below code is to handle such kind of error
      if(response.success ==false){
        return Future.error(AppException(message: response.message , statusCode: response.responseCode));
      }
      return response;
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  Future<bool> insertUsersToDb(List<User> userList) async {
    try{
      await Future.forEach(userList, (user)async{
        await dbRepository!.create<int , User>(DBRepository.USERS_TABLE, user);
      });
      return true;
    }catch (ex) {
      log("${ex.toString()}" , name: "insert users to db error");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  Future<List<User>> getUsers() async {
    try{
       var mapResult = await dbRepository!.getAll<Map<String,dynamic>>(DBRepository.USERS_TABLE);
       var userResult = mapResult.map((e) => User.fromJson(e)).toList();
       return userResult;
    }catch (ex) {
      log("${ex.toString()}" , name: "get users from db error");
      return Future.error(AppException().identifyErrorType(ex));
    }  
  }

  Future<bool> _setLoginKey(Map<String, String> keyInfo) async {
    try {
      String credentials = json.encode(keyInfo).toString();
      Codec<String, String> stringToBase64 = utf8.fuse(base64);
      String encodedLoginKey =
          stringToBase64.encode(credentials); // dXNlcm5hbWU6cGFzc3dvcmQ
      var result = await sharedPrefRepository!.create<bool, String>(
          SharedPreferenceRepository.LOGIN_KEY, encodedLoginKey);

      return result;
    } catch (ex) {
      return Future.error(AppException(
          message: "Unable to save login key", type: AppException.PREFERENCE_STORAGE_EXCEPTION));
    }
  }

  Future<bool> _setWorkspace(String workspace) async {
    try {
      var result = await sharedPrefRepository!.create<bool, String>(
          SharedPreferenceRepository.WORK_SPACE_URL, workspace);
      return result;
    } catch (ex) {
      return Future.error(AppException(
          message: "Unable to workspace key", type: AppException.PREFERENCE_STORAGE_EXCEPTION));
    }
  }


  
  @override
  Future<bool> saveAgentDataToPreference(LoginResponse agentInfo) async{
    try {
      await sharedPrefRepository!.create<bool, int>(SharedPreferenceRepository.USER_ID, agentInfo.user_id!);
      await sharedPrefRepository!.create<bool, int>(SharedPreferenceRepository.AGENT_ID, agentInfo.agent_id!);
      await sharedPrefRepository!.create<bool, String>(SharedPreferenceRepository.AGEBNT_PROFILE_IMAGE, agentInfo.agentProfileImage!);
      await sharedPrefRepository!.create<bool, String>(SharedPreferenceRepository.AGENT_NAME, agentInfo.agent_name!);
      await sharedPrefRepository!.create<bool, String>(SharedPreferenceRepository.AGENT_EMAIL, agentInfo.agent_email!);
      await sharedPrefRepository!.create<bool, String>(SharedPreferenceRepository.AGENT_LANG, agentInfo.agent_lang!);
      return true;
    } catch (ex) {
      return Future.error(AppException(
          message: "Unable to save agent info", type: AppException.PREFERENCE_STORAGE_EXCEPTION));
    }
  }
  
  @override
  Future<LoginResponse> getAgentDataFromPref() async {
    try{
      String? image = await  sharedPrefRepository!.get<String>(SharedPreferenceRepository.AGEBNT_PROFILE_IMAGE);
      String? name = await sharedPrefRepository!.get<String>(SharedPreferenceRepository.AGENT_NAME);
      String? email = await  sharedPrefRepository!.get<String>(SharedPreferenceRepository.AGENT_EMAIL);
    return LoginResponse(null, null, image, name, email, null, null, null);
    }catch (ex) {
      return Future.error(AppException(
          message: "Unable to get agent info", type: AppException.PREFERENCE_STORAGE_EXCEPTION));
    }
  }
  
  @override
  Future<CustomerResponse> getCustomersFromApi(int shopId, String offset, String limit) async {
   try{
      var apiClient = await CustomApiClient.getClient();
      var customerResponse = await apiClient.getCustomers(shopId.toString() , offset , limit);
      return customerResponse;
   }catch(ex){
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> insertCustomers(List<Customer> customers) async {
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
  Future<String?> getWorkspaceUrlFromPreference() async {
    try{
      var result = await sharedPrefRepository!.get<String>(SharedPreferenceRepository.WORK_SPACE_URL);
      return result;
    } catch(ex){
      return Future.error(ex);
    }
  }
  
  @override
  Future<bool> removeAllPreferenceData() async {
    try{
      var result = await sharedPrefRepository!.removeAllDataFromPreference();
      return result;
    } catch(ex){
      return Future.error(ex);
    }
  }
  
  @override
  Future<bool> setWorkspaceUrlToPreference(String workspaceUrl) async {
    try{
      var result = await sharedPrefRepository!.create<bool , String>(SharedPreferenceRepository.WORK_SPACE_URL, workspaceUrl);
      return result;
    } catch(ex){
      return Future.error(ex);
    }
  }
}
