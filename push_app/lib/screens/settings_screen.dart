import 'package:flutter/material.dart';
import 'package:push_app/main.dart';
import 'screens.dart';

class SettingsScreen extends StatefulWidget {
  // 運動選択画面（状態を持つ）
  const SettingsScreen({super.key}); // コンストラクタ

  @override
  State<SettingsScreen> createState() => _SettingsScreenState(); // 状態管理クラスを生成
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // 画面のUI構築
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        backgroundColor: Color(0xFF2D2D35), // AppBar背景色
        titleSpacing: 0, // タイトルの余白
        toolbarHeight: 70,
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Positioned(
            right: 20,
            top: 10,
            child: IconButton(
              icon: Icon(Icons.menu, size: 40, color: Colors.white),
              // メニューボタンが押されたときにカスタムダイアログを表示
              onPressed: () => showMenuDialog(context, month),
            ),
          ),
        ],
      ),

      body: Center(
        child: Text('Settings Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
