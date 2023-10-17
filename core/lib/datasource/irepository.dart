abstract class IRepository<T> {
  Future<List<R>> getAll<R>(String path,
      {Map<String, dynamic>? queryParameters});

  Future<R?> get<R>(String path, {Map<String, dynamic>? queryParameters});

  Future<R> create<R, S>(String path, S body,
      {Map<String, dynamic>? queryParameters});

  Future<R> update<R, S>(String path,
      {S? body, Map<String, dynamic>? queryParameters});

  Future<bool> delete(String path, {Map<String, dynamic>? queryParameters});
}
