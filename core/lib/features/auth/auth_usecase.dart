// this file will be responsible to implement auth usecases like login, logout
// will replace loginbloc.dart class


import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/features/shop/model/splashResponse.dart';
import 'package:hozmacore/features/auth/user_repository.dart';

import 'package:hozmacore/shared_models/BaseModel.dart';

class AuthUsecase {
  IUserRepository userRepository;

  var allCustomersFromApi = <Customer>[];

  AuthUsecase({required this.userRepository});

  Future<BaseModel> login(String email, String password , String workspace) async {
    var loginResult = await userRepository.login(email , password , workspace);
    return loginResult;
  }

  Future<bool> saveAgentInfo(LoginResponse agentInfo) async {
      var result = await userRepository.saveAgentDataToPreference(agentInfo);
      return result;
  }

  Future<List<User>> getCashiersFromDb() async {
    var result = await userRepository.getUsers();
    return result;
  }
 
  Future<LoginResponse> getAgentInfo() async{
    var agentResult = await userRepository.getAgentDataFromPref();
    return agentResult; 
  }  

  Future<String?> getWorkspaceUrl() async {
    var result = await userRepository.getWorkspaceUrlFromPreference();
    return result;
  }

  Future<void> logout() async {
    var workSpace = await userRepository.getWorkspaceUrlFromPreference();
    await userRepository.removeAllPreferenceData();
    if (workSpace != null) {
      await userRepository.setWorkspaceUrlToPreference(workSpace);
    }
  }
}
