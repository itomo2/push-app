import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:push_app/main.dart';

class LanguagePage extends StatefulWidget {
  // 結果画面（状態を持つ）
  LanguagePage({super.key}); // コンストラクタ

  @override
  State<LanguagePage> createState() => _LanguagePageState(); // 状態管理クラスを生成
}

class _LanguagePageState extends State<LanguagePage> {
  // 状態管理クラス
  // _LanguagePageState({super.key}); // コンストラクタ
  String language = "eigo";

  _putdata(String language) {
    box.put('language', language);
  }

  void initState() {
    super.initState();
    language = box.get('language', defaultValue: 'eigo');
  }

  @override
  Widget build(BuildContext context) {
    // 画面のUI構築
    return Scaffold(
      backgroundColor: const Color(0xFFD5FF5F), // 背景色
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, language);
          },
        ),
        backgroundColor: Color(0xFF2D2D35), // AppBar背景色
        titleSpacing: 0, // タイトルの余白
        toolbarHeight: 70,
        title: Text(
          "Language",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: language == 'eigo'
                    ? Icon(Icons.check, color: Colors.black)
                    : Icon(Icons.check, color: Colors.transparent),
                title: const Text('eigo'),
                trailing: SizedBox.shrink(),
                onPressed: (context) {
                  setState(() {
                    language = 'eigo';
                  });
                  _putdata(language);
                },
              ),
              SettingsTile.navigation(
                leading: language == 'nihongo'
                    ? Icon(Icons.check, color: Colors.black)
                    : Icon(Icons.check, color: Colors.transparent),
                title: const Text('nihongo'),
                trailing: SizedBox.shrink(),
                onPressed: (context) {
                  setState(() {
                    language = 'nihongo';
                  });
                  _putdata(language);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
