import 'package:flutter/material.dart';
import 'package:grad_project/Admin/presentation/views/splashscreen.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'signIn.dart';
import 'Admin/presentation/views/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://apamfyhadndbvhjuzbcn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFwYW1meWhhZG5kYnZoanV6YmNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAwNDMwNjIsImV4cCI6MjA4NTYxOTA2Mn0.bGmXHHzbmLCV30TqBW_R63SvqomaS_Q4EHm7AuWfuxA',
  );

  runApp(
    ProviderScope(
      child: provider.ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MyApp(),
      ),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAST Connect Staff',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        primaryColor: const Color(0xFF1565C0),
      ),
      routes: {
        '/signin': (context) => const SignInScreen(),
      },
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
