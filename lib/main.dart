import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:aast_connect/providers/CachedChatProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'supabase_config.dart';
import 'services/theme_provider.dart';
import 'fresh_grads/utils/profile_provider.dart';
import 'fresh_grads/utils/opportunities_provider.dart';
import 'signIn.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CachedChatProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => OpportunitiesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final view = WidgetsBinding.instance.platformDispatcher.views.first;
          final mediaQueryData = MediaQueryData.fromView(view);
          final effectiveWidth = kIsWeb
              ? math.min(mediaQueryData.size.width, 430.0)
              : mediaQueryData.size.width;
          final effectiveMediaQuery = mediaQueryData.copyWith(
            size: ui.Size(effectiveWidth, mediaQueryData.size.height),
          );

          return MediaQuery(
            data: effectiveMediaQuery,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: effectiveWidth,
                child: ScreenUtilInit(
                  designSize: const Size(375, 812),
                  minTextAdapt: true,
                  splitScreenMode: true,
                  builder: (context, child) => MaterialApp(
                    title: 'AAST Connect',
                    debugShowCheckedModeBanner: false,
                    theme: themeProvider.lightTheme,
                    darkTheme: themeProvider.darkTheme,
                    themeMode: themeProvider.isDark
                        ? ThemeMode.dark
                        : ThemeMode.light,
                    home: const SignInScreen(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
