import 'dart:io';

import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/theme/theme_provider.dart';
import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/services/goal_template_service.dart';
import 'package:aspire/services/notification_service.dart';
import 'package:aspire/services/revenue_cat_service.dart';
import 'package:aspire/services/tip_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:toastification/toastification.dart';
import 'package:upgrader/upgrader.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register FCM background handler (must be done before runApp)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Seed Firestore collections if needed (non-blocking)
  TipService().seedTipsIfEmpty();
  GoalTemplateService().seedTemplatesIfNeeded();

  // Initialize timezone for scheduled notifications
  tz.initializeTimeZones();

  // Initialize RevenueCat
  await RevenueCatService().initialize();

  runApp(const ProviderScope(child: AspireApp()));
}

class AspireApp extends ConsumerWidget {
  const AspireApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Aspire',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: router,
        builder: (context, child) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: UpgradeAlert(
              dialogStyle: Platform.isIOS
                  ? UpgradeDialogStyle.cupertino
                  : UpgradeDialogStyle.material,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
