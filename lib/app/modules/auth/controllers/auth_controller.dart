import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:moffpass/app/data/services/local_auth.dart';
import 'package:moffpass/app/routes/app_pages.dart';

class AuthController extends GetxController {
  var hasFingerprint = false.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() async {
    super.onReady();
    // final biometrics = await LocalAuthApi.getBiometrics();
    // debugPrint(biometrics.toString());
    // hasFingerprint.value = biometrics.contains(BiometricType.fingerprint);
    final isAuthenticated = await LocalAuthApi.authenticate();
    if (isAuthenticated) {
      Get.offNamed(Routes.HOME);
    }
    // if (hasFingerprint.value) {
    //   final isAuthenticated = await LocalAuthApi.authenticate();
    //   if (isAuthenticated) {
    //     Get.offNamed(Routes.HOME);
    //   }
    // } else {
    //   Get.defaultDialog(
    //       title: 'Error!!!',
    //       contentPadding: const EdgeInsets.symmetric(horizontal: 15),
    //       actions: [
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.end,
    //           children: [
    //             //TODOopen settings page
    //             TextButton(
    //                 onPressed: () {
    //                   Get.back();
    //                 },
    //                 child: const Text('Ok'))
    //           ],
    //         ),
    //       ],
    //       content: const Text(
    //         'Fingerprint authentication is not set. Please set it in settings.',
    //         style: TextStyle(fontSize: 17),
    //       ),
    //       barrierDismissible: false);
    // }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
