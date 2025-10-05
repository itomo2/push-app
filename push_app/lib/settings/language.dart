import 'package:flutter/material.dart';
import 'package:push_app/widgets/widgets.dart';
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
  // _LanguagePageState({super.key}); // コンストラクタ;

  @override
  Widget build(BuildContext context) {
    // 画面のUI構築
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF2D2D35), // AppBar背景色
        titleSpacing: 0, // タイトルの余白
        toolbarHeight: 70,
        title: Text(
          t('language'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SettingsList(
        darkTheme: const SettingsThemeData(
          settingsListBackground: Color(0xFF2D2D35),
          settingsSectionBackground: Color(0xFF3C3C45),
          titleTextColor: Colors.white,
          trailingTextColor: Colors.grey,
        ),
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: language == 'English'
                    ? Icon(Icons.check, color: Colors.black)
                    : Icon(Icons.check, color: Colors.transparent),
                title: const Text('English'),
                trailing: SizedBox.shrink(),
                onPressed: (context) async {
                  print("en");
                  if (language != 'English') {
                    final flag = await showDialog(
                      context: context,
                      builder: (context) => AlertDialogSettings(),
                    );
                    if (flag == true) {
                      setState(() {
                        language = 'English';
                      });
                    }
                  }
                },
              ),
              SettingsTile.navigation(
                leading: language == '日本語'
                    ? Icon(Icons.check, color: Colors.black)
                    : Icon(Icons.check, color: Colors.transparent),
                title: const Text('日本語'),
                trailing: SizedBox.shrink(),
                onPressed: (context) async {
                  print("jp");
                  if (language != '日本語') {
                    final flag = await showDialog(
                      context: context,
                      builder: (context) => AlertDialogSettings(),
                    );
                    if (flag == true) {
                      setState(() {
                        language = '日本語';
                      });
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
