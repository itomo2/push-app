import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:push_app/main.dart';
import 'explanations.dart';

class Startlanguage extends StatefulWidget {
  // 結果画面（状態を持つ）
  Startlanguage({super.key}); // コンストラクタ

  @override
  State<Startlanguage> createState() => _StartLanguageState(); // 状態管理クラスを生成
}

class _StartLanguageState extends State<Startlanguage> {
  // 状態管理クラス
  @override
  Widget build(BuildContext context) {
    // 画面のUI構築
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2D35), // AppBar背景色
        titleSpacing: 0, // タイトルの余白
        toolbarHeight: 70,
        title: Text(
          "language",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 画面の余白を設定
          Column(
            children: [
              Expanded(
                child: SettingsList(
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
                              setState(() {
                                language = 'English';
                              });
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
                              setState(() {
                                language = '日本語';
                                box.put("language", language);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    box.put("language", language);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Information(),
                      ), // カレンダー画面へ戻る
                      (Route<dynamic> route) => false, // 履歴を全て消す
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      212,
                      255,
                      95,
                    ), // ボタンの背景色
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ), // ボタンの内側の余白
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50), // ボタンの角を丸くする
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 30.0, color: Colors.black),
                  ), // ボタンのラベル
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
