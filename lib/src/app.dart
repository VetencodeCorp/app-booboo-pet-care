import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/app_update/presentation/force_update_gate.dart';
import 'features/notifications/data/push_notification_service.dart';

class BoobooApp extends ConsumerWidget {
  const BoobooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final push = ref.watch(pushNotificationServiceProvider);

    ref.listen(authControllerProvider, (_, next) {
      if (next.asData?.value != null) {
        unawaited(push.registerCurrentDevice());
      }
    });
    unawaited(
      push.initialize().then((_) {
        if (ref.read(authControllerProvider).asData?.value != null) {
          return push.registerCurrentDevice();
        }
      }),
    );

    return MaterialApp.router(
      title: 'Booboo Pet Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        return ForceUpdateGate(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
