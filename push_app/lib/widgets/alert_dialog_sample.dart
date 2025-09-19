import 'package:push_app/main.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用パッケージをインポート
import 'package:flutter/material.dart';

class AlertDialogSample extends StatelessWidget {
  // 日付選択時に表示するダイアログ
  const AlertDialogSample(this.selectedDay); // コンストラクタ
  final DateTime selectedDay; // 選択された日付

  @override
  Widget build(BuildContext context) {
    // ダイアログのUIを構築
    int pushupcount, situpcount;
    String pushuptime, situptime;

    try {
      final key = DateFormat('yyyy-MM-dd').format(selectedDay); // 日付をキーに変換
      final infoData = box.get(key); // Hiveからデータ取得
      pushupcount = infoData?.pushupcount ?? 0;
      situpcount = infoData?.situpcount ?? 0; // データがなければ0
      pushuptime = formatDuration(infoData?.pushuptime ?? Duration.zero);
      situptime = formatDuration(infoData?.situptime ?? Duration.zero);
    } catch (e) {
      pushupcount = 0;
      situpcount = 0;
      pushuptime = "00:00";
      situptime = "00:00";
    }
    return AlertDialog(
      backgroundColor: const Color(0xFFD5FF5F), // ダイアログの背景色
      title: Text(
        "${DateFormat(' yyyy.M.d').format(selectedDay)}", // 選択日を表示
        textAlign: TextAlign.left, // 左寄せ
        style: TextStyle(
          color: const Color(0xFF14151A), // 文字色
          fontSize: 32, // 文字サイズ
          fontFamily: 'Inter', // フォント
          fontWeight: FontWeight.w600, // 太字
        ),
      ),
      // content: Icon(Icons.circle), // アイコン（未使用）
      actions: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            '  Push-up：$pushupcount回　$pushuptime\n  Sit-up    ：$situpcount回　$situptime', // サンプルデータ（本来は保存データを表示する）
            style: TextStyle(
              color: const Color(0xFF14151A), // 文字色
              fontSize: 20, // 文字サイズ
              fontFamily: 'Inter', // フォント
              fontWeight: FontWeight.w500, // 太字
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
