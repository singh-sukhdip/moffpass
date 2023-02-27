import 'package:get/get.dart';
import 'package:logger/logger.dart';

class LogService extends GetxService {
  static LogService get to => Get.find<LogService>();
  late Logger logger;

  Future<LogService> init() async {
    logger = Logger(printer: PrettyPrinter());
    return this;
  }
}
