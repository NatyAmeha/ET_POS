import 'package:hozmacore/features/payment/model/payment.dart';
import 'package:hozmacore/features/payment/payment_repository.dart';

class PaymentUsecase{
  IPaymentRepository paymentRepo;

  PaymentUsecase({required this.paymentRepo});

  Future<List<Payment>> getPaymentMethodsFromDb() async{
    var payments = await paymentRepo.getPaymentsFromDb();
    return payments;
  }
}