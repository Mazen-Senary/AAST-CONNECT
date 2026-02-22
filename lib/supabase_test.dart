import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTest extends StatefulWidget {
  const SupabaseTest({super.key});

  @override
  State<SupabaseTest> createState() => _SupabaseTestState();
}

class _SupabaseTestState extends State<SupabaseTest> {
  String _connectionStatus = 'Testing connection...';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('_test_connection').select().limit(1);

      setState(() {
        _connectionStatus = 'Connected to Supabase successfully!';
        _isConnected = true;
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection failed: ${e.toString()}';
        _isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isConnected ? Icons.check_circle : Icons.error,
              size: 64,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _connectionStatus,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _testConnection,
              child: const Text('Test Again'),
            ),
          ],
        ),
      ),
    );
  }
}
