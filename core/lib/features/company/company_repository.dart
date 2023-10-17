import 'package:hozmacore/features/company/model/company_response.dart';
import 'package:hozmacore/datasource/api/ApiEndpoint.dart';
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/exception/app_exception.dart';

abstract class ICompanyRepository {
  Future<CompanyResponse> getcompanyInfoFromApi();
}

class CompanyRepository implements ICompanyRepository {
  APIEndPoint? apiClient;
  IDbRepository? dbRepository;
  ISharedPrefRepository? sharedPrefRepo;

  CompanyRepository({
    this.apiClient,
    this.dbRepository,
    this.sharedPrefRepo = const SharedPreferenceRepository(),
  });

  @override
  Future<CompanyResponse> getcompanyInfoFromApi() async {
    try {
      var companyResponse = await apiClient!.getCompanies();
      return companyResponse;
    } catch (ex) {
      print("exception ${ex.toString()}");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
}
