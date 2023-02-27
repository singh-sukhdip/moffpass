import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:moffpass/app/data/services/log_service.dart';

class DbService extends GetxService {
  static DbService get to => Get.find<DbService>();

  var categories = <String>[].obs;
  var categoriesData = <String, dynamic>{}.obs;
  late Box databaseBox;

  Future<DbService> init() async {
    databaseBox = await Hive.openBox('database');
    //databaseBox.clear();
    if (databaseBox.isEmpty) {
      categories.value = ['Work', 'Finance', 'Personal'];
      categories.forEach((element) {
        databaseBox.put(element, []);
      });
    } else {
      //print(databaseBox.toMap());
      getAllRecords();
      categoriesData.keys.forEach((element) {
        categories.add(element);
      });

      LogService.to.logger.d(categoriesData);
      // data.values.forEach((element) {
      //   var e = element as List;
      //   e.forEach((element) {
      //     var map = <String, dynamic>{};
      //     element.forEach((key, value) {
      //       map[key as String] = value;
      //     });

      //   });
      // });
      // databaseBox.values.forEach((element) {
      //   categoriesData.add(element);
      // });
      //getRecords('Finance');
    }
    return this;
  }

  void addNewcategory(String category) {
    if (!databaseBox.containsKey(category)) {
      databaseBox.put(category, []);
      getAllRecords();
    }
  }

  void saveRecord(String category, Map<String, dynamic> data) {
    if (databaseBox.containsKey(category)) {
      var entries = databaseBox.get(category) as List;
      data['id'] = entries.length + 1;
      entries.add(data);
      databaseBox.put(category, entries);
    } else {
      data['id'] = 1;
      databaseBox.put(category, [data]);
    }
  }

  updateRecord(String category, Map<String, dynamic> data) {
    if (databaseBox.containsKey(category)) {
      var entries = databaseBox.get(category) as List;
      for (int i = 0; i < entries.length; i++) {
        if (entries[i]['id'] == data['id']) {
          entries[i] = data;
          break;
        }
      }
      //LogService.to.logger.d(entries);
      databaseBox.put(category, entries);
    }
  }

  deleteRecord(String category, int id) {
    if (databaseBox.containsKey(category)) {
      List<Map<String, dynamic>> records = getRecords(category);
      for (int i = 0; i < records.length; i++) {
        if (records[i]['id'] == id) {
          records.removeAt(i);
          break;
        }
      }
      databaseBox.put(category, records);
      getAllRecords();
    }
  }

  List<Map<String, dynamic>> getRecords(String category) {
    List<Map<String, dynamic>> result = [];
    if (databaseBox.isNotEmpty) {
      if (!databaseBox.containsKey(category)) return [];
      var entries = databaseBox.get(category) as List;
      entries.forEach((element) {
        var map = <String, dynamic>{};
        element.forEach((key, value) {
          map[key as String] = value;
        });
        result.add(map);
      });
      LogService.to.logger.d(result);
      return result;
    }
    return [];
  }

  void getAllRecords() {
    categoriesData.value = databaseBox.toMap().cast();
  }

  deleteCategories(String category) {
    databaseBox.delete(category);
    getAllRecords();
  }

  @override
  void onClose() {
    databaseBox.close();
    super.onClose();
  }
}
