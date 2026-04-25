import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAEAw91s451HcijHg_mnBjz0AKUv9m_LCs",
      authDomain: "cyclone-ai-logic.firebaseapp.com",
      projectId: "cyclone-ai-logic",
      storageBucket: "cyclone-ai-logic.firebasestorage.app",
      messagingSenderId: "941988263074",
      appId: "1:941988263074:web:19d91137e782ec805693fb",
    ),
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyclone Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.amber,
      ),
      home: const AdminPanel(),
    );
  }
}

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final TextEditingController _logicController = TextEditingController();
  String _currentLogicKey = 'Loading...';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLogic();
  }

  void _loadCurrentLogic() async {
    final doc = await FirebaseFirestore.instance
        .collection('gameLogic')
        .doc('currentSettings')
        .get();
    
    if (doc.exists) {
      setState(() {
        _currentLogicKey = doc.get('Logickey') ?? '1,5,3,8';
      });
      _logicController.text = _currentLogicKey;
    }
  }

  void _updateLogic() async {
    setState(() => _isUpdating = true);
    
    try {
      await FirebaseFirestore.instance
          .collection('gameLogic')
          .doc('currentSettings')
          .update({
        'Logickey': _logicController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Logic Updated!'), backgroundColor: Colors.green),
      );
      
      _loadCurrentLogic();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
    
    setState(() => _isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👑 CYCLONE ADMIN'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  const Text('CURRENT LOGIC KEY', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 10),
                  Text(
                    _currentLogicKey,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('UPDATE LOGIC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _logicController,
              decoration: InputDecoration(
                hintText: 'Enter numbers, e.g., 1,5,3,8',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFF1a1a2e),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _updateLogic,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isUpdating
                    ? const CircularProgressIndicator()
                    : const Text('UPDATE LOGIC', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}