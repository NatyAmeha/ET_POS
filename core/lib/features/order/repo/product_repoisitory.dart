import 'dart:developer';
import 'package:get/get.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/order/model/product/productResponse.dart';
import 'package:hozmacore/features/order/model/product/uomResponse.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';
import 'package:hozmacore/features/order/model/tax/tax_response.dart';
import 'package:hozmacore/datasource/api/ApiEndpoint.dart';
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/exception/app_exception.dart';

abstract class IProductRepository{
  Future<ProductResponse> getProductsFromApi(int shopId , String offset , String limit);
  Future<List<Product>> getAllProductsFromDb();
  Future<bool> insertProductToDb(List<Product> products);
  Future<UOMResponse> getUOMFromApi(int shopId);
  Future<List<Product>> getProductsFromDb(String where , List<String> whereArgs);
  Future<List<Product>> getCartProductsFromDb();
  Future<bool> insertProductToCartTable(Product productInfo);
  Future<bool> updateCartProduct(Product produtInfo);
  Future<bool> deleteProductFromCartTable(int productId);
  Future<bool> deleteCartTable();

  Future<TaxResponse> getTaxInfoFromApi();
  Future<List<Tax>> getTaxesFromDb();
  Future<bool> insertTaxesToDb(List<Tax> taxes);
}

class ProductRepository extends IProductRepository{
  APIEndPoint? apiClient;
  IDbRepository? dbRepository;
  ISharedPrefRepository sharedPrefRepo;

  ProductRepository({this.apiClient, this.dbRepository, this.sharedPrefRepo = const SharedPreferenceRepository()});
  
  @override
  Future<ProductResponse> getProductsFromApi(int shopId , String offset , String limit) async {
    try{
      var productResponseResult = await apiClient!.getProducts(shopId , offset , limit);
      if(productResponseResult.success ==false){
        return Future.error(AppException(message: productResponseResult.message , statusCode: productResponseResult.responseCode));
      }
      return productResponseResult;
    }catch(ex){
      print("exception api ${ex.toString()}");
       return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<List<Product>> getAllProductsFromDb() async {
    try {
      var mapResult = await dbRepository!.getAll<Map<String, dynamic>>(DBRepository.PRODUCT_TABLE);
      var productResults = mapResult.map((e){
        // convert product vat String to list of int
      Map<String, dynamic> productMapInfo = {};
        if(e["taxes_id"]?.toString().isNotEmpty == true){
          var taxIds = (e["taxes_id"] as String?)?.split(",").map((e) => int.parse(e)).toList();
          productMapInfo = {...e, "taxes_id": taxIds};
        } else {
          productMapInfo = {...e, "taxes_id" : []};
        }
        return Product.fromJson(productMapInfo);
      }).toList();
      return productResults;   
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> insertProductToDb(List<Product> products) async {
   try {
      await Future.forEach(products, (product) async{
        await dbRepository!.create<int , Product>(DBRepository.PRODUCT_TABLE, product);
      });
      return true;       
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<UOMResponse> getUOMFromApi(int shopId) async {
    try{
      var uomResponse = await apiClient!.getUOM(shopId.toString());
      if(uomResponse.success ==false){
        return Future.error(AppException(message: uomResponse.message , statusCode: uomResponse.responseCode));
      }
      return uomResponse;
    }catch(ex){
      print("exception home api ${ex.toString()}");
       return Future.error(AppException().identifyErrorType(ex));
    }
  }

  @override
  Future<List<Product>> getProductsFromDb(String where, List<String> whereArgs) async {
    try{
       var mapResult = await dbRepository!.queryWithFilter<Map<String,dynamic>>(DBRepository.PRODUCT_TABLE , where , whereArgs);
       var productResults = mapResult.map((e) {
        // convert product vat String to list of int
       Map<String, dynamic> productMapInfo = {};
       if(e["taxes_id"]?.toString().isNotEmpty == true){
        var taxIds = (e["taxes_id"] as String).split(",").map((e) => int.parse(e)).toList();
        productMapInfo = {...e, "taxes_id": taxIds};
       }
       else{ 
        productMapInfo = {...e, "taxes_id": []};
       }
       return Product.fromJson(productMapInfo);
       }).toList();
       return productResults;
    }catch (ex) {
      log("${ex.toString()}" , name: "get products from db error");
      return Future.error(AppException().identifyErrorType(ex));

    }
  }
  
  @override
  Future<List<Product>> getCartProductsFromDb() async {
    try {
      var mapResult = await dbRepository!.getAll<Map<String, dynamic>>(DBRepository.CART_TABLE);
      var cartProducts = mapResult.map((e){
        Map<String, dynamic> productMapInfo = {};
        if(e["taxes_id"]?.toString().isNotEmpty == true){
          // convert product vat String to list of int
          var taxIds = (e["taxes_id"] as String).split(",").map((e) => int.parse(e)).toList();
          productMapInfo = {...e, "taxes_id": taxIds};
        }
        else{
          productMapInfo = {...e, "taxes_id": []};
        }
        return Product.fromJson(productMapInfo);
      }).toList();
      return cartProducts;   
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> deleteCartTable() async {
    try {
      var result = await dbRepository!.delete(DBRepository.CART_TABLE);
      return result;
    } catch (ex) {
      return Future.error(ex);
    }
  }
  
  @override
  Future<bool> deleteProductFromCartTable(int productId) async {
    try {
      var result = await dbRepository!.deleteWithFilter(DBRepository.CART_TABLE,"id",[productId.toString()]);
      return result;
    } catch (ex) {
      return Future.error(ex);
    }
  }
  
  @override
  Future<bool> insertProductToCartTable(Product productInfo) async {
    try {
      var insertResult = await dbRepository!.create<int , Product>(DBRepository.CART_TABLE, productInfo);
      return insertResult > 0;      
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> updateCartProduct(Product productInfo) async {
    try {
      var productJsonInfo = productInfo.toJson();
      // convert taxes id array to string
      productJsonInfo["taxes_id"] = productInfo.taxes_id?.map((e) => e.toString()).join(",");
      var updateResult = await dbRepository!.updateWithFilter(DBRepository.CART_TABLE, productJsonInfo , "id = ?", [productInfo.id] );
      return updateResult;      
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<TaxResponse> getTaxInfoFromApi() async {
    try{
      var shopId = await sharedPrefRepo.get<int>(SharedPreferenceRepository.SHOP_ID);
      var taxInfo = await apiClient!.taxes(shopId.toString());
      if(taxInfo.success ==false){
        return Future.error(AppException(message: taxInfo.message , statusCode: taxInfo.code));
      }
      return taxInfo;
    }catch(ex){
       return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<List<Tax>> getTaxesFromDb() async {
    try {
      var mapResult = await dbRepository!.getAll<Map<String, dynamic>>(DBRepository.TAX_TABLE);
      var taxes = mapResult.map((e){
        var taxInfo = {...e , "price_include" : bool.parse(e["price_include"] as String), "include_base_amount" : bool.parse(e["include_base_amount"] as String)};
        return Tax.fromJson(taxInfo);
      }).toList();
      return taxes;   
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> insertTaxesToDb(List<Tax> taxes) async {
    try {
      await Future.forEach(taxes, (tax) async{
        await dbRepository!.create<int , Tax>(DBRepository.TAX_TABLE, tax);
      });
      return true;       
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }  
}