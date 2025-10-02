import 'package:flutter/material.dart';
import 'package:push_app/screens/screens.dart';
import 'package:push_app/main.dart';

class ResultScreen extends StatefulWidget {
  // 結果画面（状態を持つ）
  ResultScreen({super.key}); // コンストラクタ

  @override
  State<ResultScreen> createState() => _ResultScreenState(); // 状態管理クラスを生成
}

class _ResultScreenState extends State<ResultScreen> {
  // 状態管理クラス
  // _ResultScreenState({super.key}); // コンストラクタ

  @override
  void initState() {
    super.initState();
    highlightDays = box.get('highlight') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // 画面のUI構築
    return Scaffold(
      backgroundColor: const Color(0xFFD5FF5F), // 背景色
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: [
            Icon(Icons.task_alt, size: 100, color: Colors.black), // 完了アイコン
            SizedBox(height: 20),
            const Text(
              "Finish!", // 完了メッセージ
              style: TextStyle(fontSize: 32, color: Colors.black), // 文字サイズと色
            ),
            const SizedBox(height: 20), // 余白
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // ボタンの背景色
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ), // ボタンの内側の余白
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // ボタンの角を丸くする
                ),
              ),
              onPressed: () {
                // ボタン押下時の処理 // データ保存sinai
                final now = DateTime.now();
                highlightDays.add(DateTime(now.year, now.month, now.day));
                box.put("highlight", highlightDays);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Calendar(),
                  ), // カレンダー画面へ戻る
                  (Route<dynamic> route) => false, // 履歴を全て消す
                );
              },
              child: const Text(
                'Back to Calendar',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ), // ボタンのラベル
            ),
          ],
        ),
      ),
    );
  }
}
