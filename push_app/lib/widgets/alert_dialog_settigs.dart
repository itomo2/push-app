import 'package:flutter/cupertino.dart';
import 'package:push_app/main.dart';

class AlertDialogSettings extends StatefulWidget {
  // 結果画面（状態を持つ）
  AlertDialogSettings({super.key}); // コンストラクタ

  @override
  State<AlertDialogSettings> createState() => _ADSettingsState(); // 状態管理クラスを生成
}

class _ADSettingsState extends State<AlertDialogSettings> {
  bool flag = false;
  // 状態管理クラス
  @override
  Widget build(BuildContext context) {
    // ダイアログのUIを構築
    return CupertinoAlertDialog(
      title: Text(t("change language")),
      content: Text(t("restart app")),
      actions: [
        CupertinoDialogAction(
          child: Text(t("ok")),
          onPressed: () => Navigator.pop(context, flag = true),
        ),
        CupertinoDialogAction(
          child: Text(t("cancel")),
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context, flag = false),
        ),
      ],
    );
  }
}
