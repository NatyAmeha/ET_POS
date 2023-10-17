import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';
import 'package:hozmacore/features/order/repo/product_repoisitory.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/features/order/services/barcode_service.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/util/helper.dart';


import '../model/product/uomResponse.dart';

class ProductUsecase{
  IProductRepository productRepo;
  IBarcodeService? barcodeService;

  List<Product> totalProductsFetchedFromApi = [];

  ProductUsecase({required this.productRepo , this.barcodeService});

  Future<Product?> getProductFromBarcode(String lineColor , bool showFlashLight) async{
     var barcodeResult = await barcodeService!.scanBarCode(lineColor, showFlashLight);
     var productResult = await productRepo.getProductsFromDb("barcode = ?", [barcodeResult]);
     return productResult.firstOrNull;
  }

  Future<Product?> getProductByIdFromDb(int id) async{
     var productResult = await productRepo.getProductsFromDb("id = ?", [id.toString()]);
     return productResult.firstOrNull;
  }

  Future<List<Product>> searchProducts(String name) async {
    var searchResult = await productRepo.getProductsFromDb("display_name like ?", ['%${name}%']);
    return searchResult;
  }

  Future<List<Product>> getCartProducts() async{
    var result = await productRepo.getCartProductsFromDb();
    return result;
  }

  Future<bool> addProductToCart(Product productInfo) async{
    var result = await productRepo.insertProductToCartTable(productInfo);
    return result;
  }

  Future<bool> updateCartProduct(Product produtInfo) async{
    var result = true;
    if(produtInfo.unitCount == 0){
      result = await productRepo.deleteProductFromCartTable(produtInfo.id!);
    }
    else {
      result = await productRepo.updateCartProduct(produtInfo);
    }
    return result;
  }

  Future<bool> removeAllProductsFromCart() async {
    var result = await productRepo.deleteCartTable();
    return result;
  }

  Future<List<Product>> getProductsAndUOM() async{
    var shopId = await Helper.getDataFromPreference<int>(SharedPreferenceRepository.SHOP_ID);
    if(shopId != null){
      var uomResult = await productRepo.getUOMFromApi(shopId);
      var products = await productRepo.getAllProductsFromDb();
      if(products.isNotEmpty){
        addUOMToProduct(uomResult, products);
        return products;
      }else{
        return await _getAllProductsFromTheApiAndSaveToDb(uomResult, shopId, 0, 20);
      }
    }else{
      return Future.error(AppException(message: "Unable to get shop id"));
    }
  }

  Future<List<Tax>> getTaxes() async {
    var taxesFromDb = await productRepo.getTaxesFromDb();
    if(taxesFromDb.isEmpty){
      var taxResponseFromApi = await productRepo.getTaxInfoFromApi();
      
      var taxesFromApi = taxResponseFromApi.taxes ?? [];
      await productRepo.insertTaxesToDb(taxesFromApi);
      return taxesFromApi;
    }
    else{
      return taxesFromDb;
    }
  }

  Future<List<Product>> _getAllProductsFromTheApiAndSaveToDb(UOMResponse uomResponse ,  int shopId , int offset , int limit ) async{
    var productResponse = await productRepo.getProductsFromApi(shopId, offset.toString(), limit.toString());
    if(productResponse.success== true){
      productResponse.products.forEach((product) {
        product.unitTax = _calcualateProductUnitTax(product);
      });
      addUOMToProduct(uomResponse, productResponse.products);
      totalProductsFetchedFromApi.addAll(productResponse.products);
      var result = await productRepo.insertProductToDb(productResponse.products);
      var totalProductFromApi = productResponse.product_count ?? -1;
      if(totalProductFromApi == -1 || offset+limit <= totalProductFromApi){
        return await _getAllProductsFromTheApiAndSaveToDb(uomResponse, shopId, offset+limit, limit);
      }
      else{
        return totalProductsFetchedFromApi; 
      }
    }
    else{
      return [];
    }
  }

  String _calcualateProductUnitTax(Product product){
    return (((double.parse(product.price_tax_inclusive!) - (double.parse(product.unit_price!))) /double.parse(product.unit_price!))).toString();
  }

  addUOMToProduct(UOMResponse? response, List<Product> productList) {
    if (response?.uomList?.isNotEmpty == true) {
      productList.forEach((product) {
        var model = response!.uomList?.where((unit_of_measure) {
          return unit_of_measure.id == product.uom_id;
        }).toList();
        if (model != null && model.length > 0) {
          product.uom_id = model[0].id;
          product.uom_name = model[0].name;
        }
      });
    }
  }
}