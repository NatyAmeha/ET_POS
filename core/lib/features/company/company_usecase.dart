import 'package:hozmacore/features/company/model/company.dart';
import 'package:hozmacore/features/company/company_repository.dart';

class CompanyUsecase{
  ICompanyRepository companyRepo;
  CompanyUsecase({required this.companyRepo});

  Future<Company?> getCompanyInfo() async{
    var companyResponse =await companyRepo.getcompanyInfoFromApi();
    return companyResponse.companies?.firstOrNull;
  }
}