import 'package:hozmacore/features/payment/model/payment.dart';
import 'package:hozmacore/datasource/api/ApiEndpoint.dart';
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/exception/app_exception.dart';

abstract class IPaymentRepository{
  Future<List<Payment>> getPaymentMethodFromApi(int shopId);
  Future<bool> insertPaymentMethodsToDb(List<Payment> payments);
  Future<List<Payment>> getPaymentsFromDb();
}

class PaymentRepository extends IPaymentRepository{
  APIEndPoint? apiClient;
  IDbRepository? dbRepository;
  ISharedPrefRepository? sharedPrefRepo;

  PaymentRepository({this.apiClient , this.dbRepository , this.sharedPrefRepo});

  @override
  Future<List<Payment>> getPaymentMethodFromApi(int shopId) async {
    try {
      var paymentResult = await apiClient!.payments(shopId.toString());
      if(paymentResult.success ==false ){
        return Future.error(AppException(message: paymentResult.message , statusCode: paymentResult.responseCode));
      }
      else if(paymentResult.success == true && paymentResult.payments?.isNotEmpty == true){
         return paymentResult.payments!;
      }
      else{
         return <Payment>[];
      }
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  @override
  Future<bool> insertPaymentMethodsToDb(List<Payment> payments) async {
    try {
      await Future.forEach(payments, (payment)async{
        //insert data to database
        await dbRepository!.create<int , Payment>(DBRepository.PAYMENT_TABLE, payment);
      });
      return true;
       
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
   
  }
  
  @override
  Future<List<Payment>> getPaymentsFromDb() async{
    try {
      var mapResult = await dbRepository!.getAll<Map<String, dynamic>>(DBRepository.PAYMENT_TABLE);
      var paymentResult = mapResult.map((e) => Payment.fromJson(e)).toList();
      return paymentResult;
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
}