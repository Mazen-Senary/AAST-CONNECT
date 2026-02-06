import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signIn.dart';
import 'Admin/ui/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://apamfyhadndbvhjuzbcn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFwYW1meWhhZG5kYnZoanV6YmNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAwNDMwNjIsImV4cCI6MjA4NTYxOTA2Mn0.bGmXHHzbmLCV30TqBW_R63SvqomaS_Q4EHm7AuWfuxA',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        primaryColor: const Color(0xFF1565C0),
      ),
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
