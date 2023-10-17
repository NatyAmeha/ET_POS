import 'dart:io';

import 'package:hozmacore/exception/app_exception.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

abstract class IFileService{
  Future<bool> openfile(File file);
  Future<File> saveFile(String fileName , List<int> bytes);
}

class FileService implements IFileService{
  const FileService();
  @override
  Future<bool> openfile(File file) async {
    try{
       var result = await OpenFile.open(file.path);
       if(result.type == ResultType.done){
        return true;
       }
       else {
        return Future.error(AppException(message: result.message));
       }   
    }catch(ex){
      return Future.error(AppException(message: "Error occured while opening file"));
    }
  }

  @override
  Future<File> saveFile(String fileName , List<int> bytes) async {
    try{
      final appDocDir = await getApplicationDocumentsDirectory();
      final appDocPath = appDocDir.path;
      final file = File(appDocPath + '/' + fileName);
      var fileWriteResult = await file.writeAsBytes(bytes);
      return fileWriteResult;
    } catch(ex){
      return Future.error(AppException(message: "Unable to save file"));
    }
  }
}