import 'package:flutter/material.dart';
import 'package:push_app/main.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:push_app/settings/settings.dart';

class SettingsScreen extends StatefulWidget {
  // 運動選択画面（状態を持つ）
  const SettingsScreen({super.key}); // コンストラクタ

  @override
  State<SettingsScreen> createState() => _SettingsScreenState(); // 状態管理クラスを生成
}

class _SettingsScreenState extends State<SettingsScreen> {
  void initState() {
    super.initState();
    language = box.get('language', defaultValue: 'English');
  }

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
          t('settings'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(Icons.menu, size: 40, color: Colors.white),
              onPressed: () => showMenuDialog(context, month),
            ),
          ),
        ],
      ),

      body: SettingsList(
        darkTheme: const SettingsThemeData(
          settingsListBackground: Color(0xFF2D2D35),
          settingsSectionBackground: Color(0xFF3C3C45),
          titleTextColor: Colors.white,
          trailingTextColor: Colors.grey,
        ),
        brightness: Brightness.dark, // ← ここでダークモード固定！
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: Text('${t("language")}'),
                value: Text('$language'),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LanguagePage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
