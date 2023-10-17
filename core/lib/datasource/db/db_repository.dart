import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';
import 'package:hozmacore/constants/constants.dart';
import 'package:hozmacore/features/shop/model/categoryResponse.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/payment/model/payment.dart';
import 'package:hozmacore/features/payment/model/pricelistResponse.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/shop/model/country.dart';
import 'package:hozmacore/features/shop/model/splashResponse.dart';
import 'package:hozmacore/datasource/irepository.dart';

import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/exception/db_exception.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// this code file evenutually replace database.dart file

abstract class IDbRepository<T> extends IRepository<T> {
  //  Future<int> insert(String table , Map<String, dynamic> data);
  //  Future<List<int>> insertMany();
  Future<List<R>> queryWithFilter<R>(String tableName , String where , List<Object?> whereArgs);
  Future<bool> rawInsert(String sqlQuery, List<Object> arguments);
  Future<bool> rawUpdate(String sqlQuery , List<Object> arguments);
  Future<bool> deleteWithFilter(String tableName , String where , List<String?>? whereArgs);
  Future<bool> updateWithFilter(String tableName , Map<String, dynamic> newInfo,  String where , List<Object?>? whereArgs);
}

class DBRepository<T> implements IDbRepository<T> {
  static const int DATABASE_VERSION = 5;
  String DbName;

//Tables
  static const String COUNTRY_TABLE = "country";
  static const String PRODUCT_TABLE = "products";
  static const String CUSTOMER_TABLE = "customers";
  static const String PAYMENT_TABLE = "payment_methods";
  static const String TAX_TABLE = "taxes";
  static const String CART_TABLE = "cart";
  static const String HOLD_CART = "hold_cart";
  static const String ORDER_TABLE = "orders";
  static const String CATEGORY_TABLE = "category";
  static const String USERS_TABLE = "users";
  static const String PRICELIST_TABLE = "pricelist";

  static Database? mDatabase;



  DBRepository({required this.DbName}){
    initDb(DbName);
  }

  Future<Database> get database async {
    if (mDatabase != null) return mDatabase!;
    return mDatabase!;
  }

  // The path will be table name
  @override
  Future<R> create<R, S>(String path, S body,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      var dbClient = await database;

      // convert data class to map 
      Map<String, dynamic> dataToInsert = {};

      if (S.toString() == (Category).toString()) {
        var data = body as Category;
        if (data.parent_id is bool){
          data.parent_id = (data.parent_id as bool) ? "1" : "0";
        }
        dataToInsert = data.toJson();
      }
      else if(S.toString() == (Tax).toString()){
        var data = body as Tax;
        dataToInsert = data.toJson();
        dataToInsert["price_include"] = data.price_include.toString();
        dataToInsert["include_base_amount"] = data.include_base_amount.toString();
      }
      else if (S.toString() == (User).toString()) {
        var data = body as User;
         if(data.pos_security_pin is bool){
          (data.pos_security_pin as bool) ? "1" : "0";
        }
        dataToInsert = data.toJson();
      }
      else if(S.toString() == (Country).toString()){
        var data = body as Country;
        if (data.vat_label is bool){
          data.vat_label = (data.vat_label as bool) ? "1" : "0";
        }
        dataToInsert = data.toJson();
      }
      else if(S.toString() == (Product).toString()){
        var data = body as Product;
        if (data.to_weight is bool){
          data.to_weight = (data.to_weight as bool) ? "1" : "0";
        }
        if (data.pos_categ_id is bool){
          data.pos_categ_id = (data.pos_categ_id as bool) ? "1" : "0";
        }
        var taxIdsConvertedToString = (data.taxes_id?.map((e) => e.toString()))?.join(",");
        dataToInsert = data.toJson();
        dataToInsert["taxes_id"] = taxIdsConvertedToString;
      }
      else if(S.toString() == (Customer).toString()){
        var data = body as Customer;
        if (data.status == null){
          data.status = "synced";
        } 
        if (data.state_id is bool){
          data.state_id = (data.state_id as bool) ? "1" : "0";
        }
        if (data.country_id is bool){
          data.country_id = (data.country_id as bool) ? "1" : "0";
        }
        if (data.property_account_position_id is bool){
          data.property_account_position_id = (data.property_account_position_id as bool) ? "1" : "0";
        }
        dataToInsert = data.toJson();
      }
      else if (S.toString() == (Payment).toString()) {
        dataToInsert = (body as Payment).toJson();
      } else if (S.toString() == (PriceListItem).toString()) {
        var data = body as PriceListItem;
        // must be transformed manually b/c  price_list_item class contains list that can't be inserted to db directly
        dataToInsert = {
          "id": data.id,
          "name": data.name,
          "data": jsonEncode(data.data)
        };
      }
      var dbConflictAlogorithim = (queryParameters?[Constant.DB_CONFLICT_ALOGRITHIM_TYPE] as String?) ?? DbConflictAlgorithim.REPLACE.name;
      var insertResult = await dbClient.insert(path, dataToInsert ,conflictAlgorithm: dbConflictAlogorithim == DbConflictAlgorithim.IGNORE.name ? ConflictAlgorithm.ignore :  ConflictAlgorithm.replace);
      return insertResult as R;
    } catch (ex) {
      log("${ex.toString()}", name: "db $path insert error");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  @override
  Future<bool> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try{
      var dbClient = await database;
      var result = await dbClient.delete(path);
      return result > 0;
    }catch(ex){
      log("${ex.toString()}", name: "db $path delete all error");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

   @override
  Future<bool> deleteWithFilter(String tableName, String where, List<String?>? whereArgs) async{
    try{
      var dbClient = await database;
      var result =  await dbClient.delete(tableName ,where: "$where = ?",whereArgs: whereArgs);
      return result > 0; 
    }catch(ex){
      log("${ex.toString()}", name: "db $tableName delete with filter error");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  @override
  Future<List<R>> queryWithFilter<R>(String tableName, String where, List<Object?> whereArgs) async {
    try {
      var dbClient = await database;
      var result = await dbClient.query(tableName , where: where , whereArgs: whereArgs);
      if(result.isEmpty){
        return [];
      }
      return result.cast<R>();
    } catch(ex){
      log("${ex.toString()}", name: "db $tableName query with filter error");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  //queryparameter will be used to filter the db result
  // path is table name
  @override
  Future<R?> get<R>(String path, {Map<String, dynamic>? queryParameters}) async{
   
    throw UnimplementedError();
  }

  @override
  Future<List<R>> getAll<R>(String path,
      {Map<String, dynamic>? queryParameters}) async {
     try {
      var dbClient = await database;
      List<Map<String , Object?>> queryResult = [];
      if(queryParameters != null){
        var where = queryParameters.keys.join("= ?,");
        var whereArgs = queryParameters.values.toList();
        queryResult = await dbClient.query(path , where: where , whereArgs: whereArgs);
      }
      else{
        queryResult = await dbClient.query(path);
      }
      return queryResult.cast<R>();
    } catch (ex) {
      log("${ex.toString()}", name: "db $path table query error");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  @override
  Future<R> update<R, S>(String path,
      {S? body, Map<String, dynamic>? queryParameters}) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<bool> rawInsert(String sqlQuery , List<Object> arguments) async{
    try{
      var dbClient = await database;
      var rawInsertResult = await dbClient.rawInsert(sqlQuery , arguments);
      return rawInsertResult > 0;

    }catch (ex) {
      log("${ex.toString()}", name: "db raw insert error");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  @override
  Future<bool> rawUpdate(String sqlQuery, List<Object> arguments) async {
    try{
      var dbClient = await database;
      var rawUpdateResult = await dbClient.rawUpdate(sqlQuery, arguments);
      print("db raw update result $rawUpdateResult");
      return rawUpdateResult > 0;
    }catch(ex){
      log("${ex.toString()}", name: "db raw update error");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  @override
  Future<bool> updateWithFilter(String tableName, Map<String, dynamic> newInfo, String where, List<Object?>? whereArgs) async {
    try{
      var dbClient = await database;
      var updateResult = await dbClient.update(tableName, newInfo,  where : where , whereArgs: whereArgs, conflictAlgorithm: ConflictAlgorithm.replace);
      return updateResult > 0;
    }catch(ex){
      log("${ex.toString()}", name: "db raw update error");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  Future<Database> initDb(String dbname) async {
    WidgetsFlutterBinding.ensureInitialized();
    
    String dbpath;
     if(Platform.isAndroid){
       var directory = await getApplicationDocumentsDirectory();
       dbpath = directory.path;
     }
     else{
      dbpath = await databaseFactory.getDatabasesPath();
     }
    log("dbpath: ${dbpath} $dbname");
    // Open the database and store the reference.
    mDatabase = await openDatabase(
      join(dbpath, dbname),    
      version: DATABASE_VERSION,
      onCreate: (db, version) async {
        print("Inside onCreate DB...");
        await db.execute(
          "CREATE TABLE " +
              COUNTRY_TABLE +
              "(id INTEGER PRIMARY KEY, name TEXT, vat_label TEXT)",
        );

        await db.execute(
          "CREATE TABLE " +
              PRODUCT_TABLE +
              "(id INTEGER PRIMARY KEY, uom_id INTEGER, unit_count INTEGER, display_name TEXT, lst_price TEXT, unit_price TEXT, price_tax_exclusive TEXT, price_tax_inclusive TEXT, unitTax TEXT, "
                  "image_url TEXT, pos_categ_id TEXT, barcode TEXT, to_weight TEXT, discount TEXT, uom_name TEXT, taxes_id TEXT)",
        );

        await db.execute(
          "CREATE TABLE " +
              CUSTOMER_TABLE +
              "(id INTEGER PRIMARY KEY, name TEXT, street TEXT, state_id INTEGER, city TEXT, vat TEXT, country_id INTEGER, "
                  "property_product_pricelist INTEGER, phone TEXT, zip TEXT, property_account_position_id TEXT, "
                  "barcode TEXT, mobile TEXT, write_date TEXT, email TEXT, sync_status TEXT)",
        );

        await db.execute(
          "CREATE TABLE " +
              CART_TABLE +
              "(id INTEGER PRIMARY KEY, uom_id INTEGER, unit_count INTEGER, display_name TEXT, lst_price TEXT, unit_price TEXT, price_tax_exclusive TEXT, price_tax_inclusive TEXT, unitTax TEXT,"
                  "image_url TEXT, pos_categ_id TEXT, barcode TEXT, to_weight TEXT, discount TEXT, uom_name TEXT , taxes_id TEXT)",
        );

        await db.execute(
          "CREATE TABLE " +
              PAYMENT_TABLE +
              "(id INTEGER PRIMARY KEY, name TEXT, type TEXT, amountTendered TEXT, amountReturned TEXT)",
        );

        await db.execute(
          "CREATE TABLE " +
              ORDER_TABLE +
              "(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, creation_date INTEGER, status TEXT, content TEXT)",
        );

        await db.execute(
          "CREATE TABLE " +
              HOLD_CART +
              "(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, holdModelList TEXT)",
        );

        await db.execute(
          "CREATE TABLE " +
              CATEGORY_TABLE +
              "(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, parent_id TEXT, product_count INTEGER)",
        );
        await db.execute(
          "CREATE TABLE " +
              USERS_TABLE +
              "(id INTEGER PRIMARY KEY, name TEXT, pos_security_pin TEXT)",
        );

        await db.execute(
          "CREATE TABLE " +
              PRICELIST_TABLE +
              "(id INTEGER PRIMARY KEY, name TEXT, data TEXT)",
        );

      await db.execute(
        "CREATE TABLE " +
            TAX_TABLE +
            "(id INTEGER PRIMARY KEY, name TEXT, amount INTEGER, price_include BOOLEAN, include_base_amount BOOLEAN, amount_type TEXT)",
      );
    }, readOnly: false);
    return mDatabase!;
  }
}
