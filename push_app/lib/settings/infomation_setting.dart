import 'package:push_app/main.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import '../screens/screens.dart';

class InfoPage extends StatelessWidget {
  // 日付選択時に表示するダイアログ

  @override
  Widget build(BuildContext context) {
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
          t("infomation"),
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
                title: Text(t("version")),
                trailing: Text("1.0.0"),
                onPressed: (context) {},
              ),
              SettingsTile.navigation(
                title: Text(t("explanation")),
                trailing: SizedBox.shrink(),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Information()),
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
