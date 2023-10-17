import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

abstract class IConnectivityService {
  Stream<String> getConnectivityStatus();
  Future<String?> getIPAddressOfConnectedNetwork();
}

class ConnectivityService extends IConnectivityService {
  static const ONLINE = "Online";
  static const OFFLINE = "Offline";
  @override
  Stream<String> getConnectivityStatus(){
    var statusResult = Connectivity().onConnectivityChanged.map((ConnectivityResult result){
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
            return  ConnectivityService.ONLINE;
      }
      else {
         return  ConnectivityService.OFFLINE;
      }
    });
    return statusResult;
    
  }
  
  @override
  Future<String?> getIPAddressOfConnectedNetwork() async {
    try {
      var networkInfo = NetworkInfo();
      var ipAddress = await networkInfo.getWifiIP();
      return ipAddress;
    } catch (ex) {
      log(name: "connectivity error","Unable to get ip address");
      return null;
    }
  }
}
