import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moffpass/app/data/services/db_service.dart';
import 'package:moffpass/app/data/services/log_service.dart';
import 'package:moffpass/app/utils/styles.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Get.putAsync<LogService>(
    () => LogService().init(),
  );
  await Get.putAsync<DbService>(
    () => DbService().init(),
  );

  runApp(
    GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: "mOffPass",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        theme: ThemeData(
          fontFamily: 'poppins',
          appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: AppStyles.appBarTitleColor,
              titleTextStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.appBarTitleColor),
              actionsIconTheme: IconThemeData(color: AppStyles.blackColor)),
          scaffoldBackgroundColor: AppStyles.scaffoldBackgroundColor,
          // tabBarTheme: TabBarTheme(
          //     indicator: BoxDecoration(color: AppStyles.primaryColor),
          //     indicatorSize: TabBarIndicatorSize.label),
        )),
  );
}
