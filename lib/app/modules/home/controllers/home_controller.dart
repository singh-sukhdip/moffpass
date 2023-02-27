import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moffpass/app/data/models/menu_option.dart';
import 'package:moffpass/app/data/services/db_service.dart';
import 'package:moffpass/app/data/services/log_service.dart';
import 'package:moffpass/app/data/services/password_generator.dart';
import 'package:moffpass/app/routes/app_pages.dart';
import 'package:moffpass/app/utils/styles.dart';
import 'package:moffpass/app/widgets/custom_slider.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  static HomeController get to => Get.find<HomeController>();
  var categories = [];
  //var menuOptions = ['Add new category', 'Settings', 'About'];
  var menuOptions = [
    MenuOptionModel(
        value: 'Add new category', iconData: Icons.add, onTap: () {}),
    MenuOptionModel(
        value: 'Delete category', iconData: Icons.delete, onTap: () {}),
    MenuOptionModel(
        value: 'Settings',
        iconData: Icons.settings,
        onTap: () {
          Get.toNamed(Routes.SETTINGS);
        }),
    MenuOptionModel(
        value: 'About',
        iconData: Icons.info,
        onTap: () {
          Get.toNamed(Routes.ABOUT);
        }),
  ];
  late TabController tabController;
  var noOfRows = 1.obs;
  var titleValueTextController = TextEditingController();
  var labelNamesTextController = <TextEditingController>[];
  var labelValuesTextController = <TextEditingController>[];
  var formKeys = GlobalKey<FormState>();
  var categoriesData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    categories = DbService.to.categories;
    categoriesData = DbService.to.categoriesData;
    tabController = TabController(length: categoriesData.length, vsync: this);
    labelNamesTextController =
        List.generate(noOfRows.value, (index) => TextEditingController());
    labelValuesTextController =
        List.generate(noOfRows.value, (index) => TextEditingController());
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    tabController.dispose();
    labelNamesTextController.forEach((element) {
      element.dispose();
    });
    labelValuesTextController.forEach((element) {
      element.dispose();
    });
    super.onClose();
  }

  resetNoOfRows() {
    noOfRows.value = 1;
    labelNamesTextController.clear();
    labelValuesTextController.clear();
    titleValueTextController.clear();
    labelNamesTextController =
        List.generate(noOfRows.value, (index) => TextEditingController());
    labelValuesTextController =
        List.generate(noOfRows.value, (index) => TextEditingController());
  }

  String generateUniqueValue(
      {int length = 8,
      bool includeNumbers = true,
      bool includeSpecialChars = true}) {
    return PasswordGenerator.generatePassword(
        length: length,
        isNumber: includeNumbers,
        isSpecial: includeSpecialChars);
  }

  saveRecord(String category) {
    //TODO:add validation check before saving record
    Map<String, dynamic> data = {};
    data['title'] = titleValueTextController.text;
    for (int i = 0; i < labelNamesTextController.length; i++) {
      data[labelNamesTextController[i].text] =
          labelValuesTextController[i].text;
    }
    // categoriesData.forEach((key, value) {
    //   if (key == category) {
    //     var v = value as List;
    //     v.add(data);
    //   }
    // });
    Get.back();
    resetNoOfRows();
    //LogService.to.logger.i(categoriesData);
    DbService.to.saveRecord(category, data);
    getRecordsFromDb();
  }

  addNewRow() {
    noOfRows++;
    labelNamesTextController.add(TextEditingController());
    labelValuesTextController.add(TextEditingController());
  }

  String getCategoryFromIndex(int index) {
    return categories[index];
  }

  getRecordsFromDb() {
    DbService.to.getAllRecords();
  }

  void handlePopMenuButton(MenuOptionModel optionModel) {
    switch (optionModel.value) {
      case "Add new category":
        openAddCategoryDialog();
        break;
      case "Delete category":
        openCategoryDeleteDialog();
        break;
      case "Settings":
        Get.toNamed(Routes.SETTINGS);
        break;
      case "About":
        Get.toNamed(Routes.ABOUT);
        break;
    }
  }

  deleteRecord(int id) {
    var category = getCategoryFromIndex(tabController.index);
    DbService.to.deleteRecord(category, id);
  }

  void openSureDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure to delete this record?'),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                'No',
                style: TextStyle(color: AppStyles.errorColor, fontSize: 16),
              )),
          TextButton(
              onPressed: () {
                deleteRecord(id);
                Get.back();
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: AppStyles.successColor, fontSize: 16),
              ))
        ],
      ),
    );
    // Get.defaultDialog(
    //     title: 'Are you sure to delete this record?',
    //     middleText: '',
    //     actions: [
    //       TextButton(
    //           onPressed: () {
    //             Get.back();
    //           },
    //           child: const Text('No')),
    //       TextButton(
    //           onPressed: () {
    //             deleteRecord(id);
    //           },
    //           child: const Text('Yes'))
    //     ]);
  }

  addNLengthRows(int n) {
    noOfRows.value = n;
    for (int i = 0; i < noOfRows.value - 1; i++) {
      labelNamesTextController.add(TextEditingController());
      labelValuesTextController.add(TextEditingController());
    }
  }

  updateRecord(String category, int id) {
    Map<String, dynamic> data = {};
    data['title'] = titleValueTextController.text;
    data['id'] = id;
    for (int i = 0; i < labelNamesTextController.length; i++) {
      data[labelNamesTextController[i].text] =
          labelValuesTextController[i].text;
    }
    Get.back();
    resetNoOfRows();
    //LogService.to.logger.i(categoriesData);
    DbService.to.updateRecord(category, data);
    getRecordsFromDb();
  }

  deleteRow(int index) {
    labelNamesTextController.removeAt(index);
    labelValuesTextController.removeAt(index);
    noOfRows--;
  }

  openAddCategoryDialog() {
    var categoryTextController = TextEditingController();
    Get.defaultDialog(
        title: 'Add new category',
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    if (categoryTextController.text.isEmpty) {
                      //TODO: show snacbar
                    } else {
                      addNewCategory(categoryTextController.text.trim());
                      Get.back();
                    }
                  },
                  child: const Text('Add')),
            ],
          )
        ],
        content: Column(
          children: [
            TextField(
              controller: categoryTextController,
              decoration: const InputDecoration(hintText: 'Category name'),
              textCapitalization: TextCapitalization.words,
            )
          ],
        ));
  }

  addNewCategory(String category) {
    DbService.to.addNewcategory(category);
    tabController.dispose();
    categoriesData = DbService.to.categoriesData;
    tabController = TabController(length: categoriesData.length, vsync: this);
    //update();
  }

  openCategoryDeleteDialog() {
    Get.defaultDialog(
        title: 'Delete Category',
        middleText: 'Warning',
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Done')),
            ],
          )
        ],
        content: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Warning!!! This action can\'t be undone. Please be careful.',
                style: TextStyle(color: AppStyles.errorColor),
              ),
            ),
            Obx(() => Column(
                  children: categoriesData.entries.map((e) {
                    return ListTile(
                      title: Text(e.key),
                      trailing: IconButton(
                        onPressed: () {
                          deleteCategory(e.key);
                          tabController.dispose();
                          categoriesData = DbService.to.categoriesData;
                          tabController = TabController(
                              length: categoriesData.length, vsync: this);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: AppStyles.errorColor,
                        ),
                      ),
                    );
                  }).toList(),
                )),
          ],
        ));
  }

  deleteCategory(String category) {
    if (category.isNotEmpty) {
      DbService.to.deleteCategories(category);
    }
  }

  openPasswordGenerateDialog(int index) {
    var passwordLength = 8.obs;
    var includeNumbers = true.obs;
    var includeSpecialChars = true.obs;
    var password = ''.obs;
    password.value = generateUniqueValue();
    Get.defaultDialog(
        title: 'Generate Password',
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                password.value = generateUniqueValue(
                    length: passwordLength.value,
                    includeNumbers: includeNumbers.value,
                    includeSpecialChars: includeSpecialChars.value);
              },
              child: const Text('New')),
          TextButton(
              onPressed: () {
                labelValuesTextController[index].text = password.value;
                Get.back();
              },
              child: const Text('Save')),
        ],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Password Length',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            //const SizedBox(height: 10),
            SliderFb4(
                min: 8,
                max: 16,
                divisions: 8,
                initialValue: 8,
                onChange: (value) {
                  passwordLength.value = value.toInt();
                  password.value = generateUniqueValue(
                      length: passwordLength.value,
                      includeNumbers: includeNumbers.value,
                      includeSpecialChars: includeSpecialChars.value);
                }),
            Obx(() => CheckboxListTile(
                title: const Text('Include Numbers'),
                value: includeNumbers.value,
                onChanged: (value) {
                  includeNumbers.value = value!;
                  password.value = generateUniqueValue(
                      length: passwordLength.value,
                      includeNumbers: includeNumbers.value,
                      includeSpecialChars: includeSpecialChars.value);
                })),
            Obx(() => CheckboxListTile(
                title: const Text('Include Special chars'),
                value: includeSpecialChars.value,
                onChanged: (value) {
                  includeSpecialChars.value = value!;
                  password.value = generateUniqueValue(
                      length: passwordLength.value,
                      includeNumbers: includeNumbers.value,
                      includeSpecialChars: includeSpecialChars.value);
                })),
            const SizedBox(
              height: 10,
            ),
            Center(
                child: Obx(() => Text(
                      password.value,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ))),
          ],
        ));
  }
}
