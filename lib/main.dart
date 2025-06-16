import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xintel/core/utils/log_util.dart';

import 'core/configs/env_config.dart';
import 'data/preferences/app_preferences.dart';
import 'presentation/features/auth/auth_controller.dart';
import 'presentation/routing/routers/app_pages.dart';
import 'repositories/base/graphql_service.dart';
import 'repositories/chat_repository.dart';
import 'repositories/storage_repo.dart';
import 'repositories/user_repository.dart';
import 'services/chat_socket_service.dart';

Future<void> main() async {
  await runZonedGuarded(_runMyApp, _reportError);
}

Future<void> _runMyApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    LogUtil.i('Initializing app...');

    await _loadEnv();
    LogUtil.i('Environment loaded successfully');

    // Initialize GraphQL service
    Get.put(graphQLService);

    runApp(const MyApp());
    LogUtil.i('App started successfully');
  } catch (e, stackTrace) {
    LogUtil.e('Failed to initialize app', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

void _reportError(Object error, StackTrace stackTrace) {
  LogUtil.e('Unhandled error occurred', error: error, stackTrace: stackTrace);
  // report by Firebase Crashlytics here
}

Future<void> _loadEnv() async {
  try {
    await Get.putAsync<EnvConfig>(() async {
      await dotenv.load();
      return EnvConfig(dotenv.env);
    });
  } catch (e, stackTrace) {
    LogUtil.e('Failed to load environment', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Xintel',
          debugShowCheckedModeBanner: false,
          initialBinding: InitialBinding(),
          initialRoute: AppPages.initialRoute,
          getPages: AppPages.routes,
        );
      },
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize core services first
    Get.put<AppPreferences>(AppPreferences(), permanent: true);
    Get.put<EventBus>(EventBus(), permanent: true);

    // Initialize repositories
    Get.lazyPut<StorageRepository>(() => StorageRepository(), fenix: true);
    Get.lazyPut<ChatRepository>(() => ChatRepository(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);

    // Initialize controllers
    Get.put<AuthController>(AuthController(), permanent: true);

    // Initialize socket service - this will auto-connect when user is logged in
    Get.lazyPut<ChatSocketService>(() => ChatSocketService(), fenix: true);
  }
}
