import 'package:flutter/material.dart';
import 'signIn.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fresh_grads/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'fresh_grads/utils/profile_provider.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://apamfyhadndbvhjuzbcn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFwYW1meWhhZG5kYnZoanV6YmNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAwNDMwNjIsImV4cCI6MjA4NTYxOTA2Mn0.bGmXHHzbmLCV30TqBW_R63SvqomaS_Q4EHm7AuWfuxA',
  );

  runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
    ],
    child: const MyApp(),
  ),
);
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAST Connect',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
