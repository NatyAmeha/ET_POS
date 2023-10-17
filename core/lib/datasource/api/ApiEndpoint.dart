import 'package:dio/dio.dart';
import 'package:hozmacore/constants/api_constants.dart';
import 'package:hozmacore/features/shop/model/cashClose.dart';
import 'package:hozmacore/features/shop/model/cashOpen.dart';
import 'package:hozmacore/features/shop/model/categoryResponse.dart';
import 'package:hozmacore/features/company/model/company_response.dart';
import 'package:hozmacore/features/customer/model/addCustomerResponse.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/features/payment/model/payment.dart';
import 'package:hozmacore/features/payment/model/pricelistResponse.dart';
import 'package:hozmacore/features/order/model/product/productResponse.dart';
import 'package:hozmacore/features/order/model/product/uomResponse.dart';
import 'package:hozmacore/features/shop/model/splashResponse.dart';
import 'package:hozmacore/features/order/model/tax/tax_response.dart';
import 'package:hozmacore/datasource/api/APIs.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';
import 'package:hozmacore/shared_models/session.dart';
import 'package:retrofit/http.dart';

part 'ApiEndpoint.g.dart';


// This class eventually replace Api client
@RestApi(baseUrl: ApiConstants.BASE_URL)
abstract class APIEndPoint {
  factory APIEndPoint(Dio dio, {String baseUrl}) = _APIEndPoint;

  @GET(API.SPLASH_DATA_API)
  Future<SplashResponse> splashData();

  @POST(API.LOGIN_API)
  @FormUrlEncoded()
  
  Future<BaseModel> loginPage();

  @GET(API.SHOP_SESSION_API)
  Future<Session> shopSession(@Query("config_id") String configId);

  @GET(API.CATEGORY_LIST_API)
  Future<CategoryResponse> getCategories(@Query("config_id") String configId,
      @Query("offset") String offset, @Query("limit") String limit);

  @GET(API.PAYMENT_LIST_API)
  Future<PaymentResponse> payments(@Query("config_id") String configId);

  @GET(API.TAX_LIST_API)
  Future<TaxResponse> taxes(@Query("config_id") String configId);

  @GET(API.UOM_LIST_API)
  Future<UOMResponse> getUOM(@Query("config_id") String configId);

  @GET(API.PRODUCT_LIST_API)
  Future<ProductResponse> getProducts(@Query("config_id") int? configId,
      @Query("offset") String offset, @Query("limit") String limit);

  @GET(API.CUSTOMER_LIST_API)
  Future<CustomerResponse> getCustomers(@Query("config_id") String configId,
      @Query("offset") String offset, @Query("limit") String limit);

  @POST(API.SYNC_ORDER_API)
  Future<LoginResponse> orderSync(@Body() dynamic body);

  @GET(API.DASHBOARD_API)
  Future<LoginResponse> shopData();

  @POST(API.CREATE_CUSTOMER_API)
  Future<AddCustomerResponse> createCustomer(@Body() dynamic body);

  @PUT(API.EDIT_CUSTOMER_API)
  Future<AddCustomerResponse> editCustomer(
      @Path("customer_id") String customerId, @Body() dynamic body);

  @GET(API.PRICELIST)
  Future<PriceListResponse> getPriceListData(
      @Query("config_id") String configId);

  @GET(API.CASH_OPEN)
  Future<CashOpen> getCashOpen(@Path("config_id") String configId);

  @POST(API.CASH_OPEN)
  Future<BaseModel> setCashOpen(
      @Path("config_id") String configId, @Body() dynamic body);

  @GET(API.CASH_CLOSE)
  Future<CashClose> getCashClose(@Path("config_id") String configId);

  @POST(API.CASH_CLOSE)
  Future<BaseModel> setCashClose(
      @Path("config_id") String configId, @Body() dynamic body);

  @GET(API.COMPANIES)
  Future<CompanyResponse> getCompanies();
}
