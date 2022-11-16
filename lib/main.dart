import 'package:drawing_app/constants/app_module.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import 'app/routes/app_pages.dart';

final getIt = GetIt.instance;
void main() {
  setUp();
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
