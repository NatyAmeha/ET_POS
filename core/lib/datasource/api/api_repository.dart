

import 'package:hozmacore/datasource/api/custom_api_client.dart';
import 'package:hozmacore/datasource/irepository.dart';

abstract class IApiRepository<T> extends IRepository<T> {

}


// api request implementation are handled by retrofit. Retrofit generate api implementation based
// on ApiEndpoint.dart class
//  if we want to replace retrofit with other api package we will implement this class to handle the api request

class ApiRepository<T> implements IApiRepository<T>{
  ApiRepository();
  final apiClient = CustomApiClient.getClient();
  @override
  Future<R> create<R, S>(String path, S body, {Map<String, dynamic>? queryParameters}) async {
    // TODO: implement create
    var api = await apiClient;
    
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(String path, {Map<String, dynamic>? queryParameters}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<R?> get<R>(String path, {Map<String, dynamic>? queryParameters}) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<List<R>> getAll<R>(String path, {Map<String, dynamic>? queryParameters}) {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<R> update<R, S>(String path, {S? body, Map<String, dynamic>? queryParameters}) {
    // TODO: implement update
    throw UnimplementedError();
  }

}