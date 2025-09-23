import 'package:flutter/material.dart'; // FlutterのUI部品を使うためのパッケージをインポート
import 'screens/screens.dart';
import 'package:hive_flutter/hive_flutter.dart'; // HiveのFlutter用パッケージをインポート
import 'package:push_app/models/models.dart';
export 'package:push_app/models/models.dart';
part 'main.g.dart'; // Hive Generator用（TypeAdapter自動生成ファイル）

late Box box; // HiveのBox（データ保存領域）をグローバル変数として宣言
late List<dynamic> highlightDays = [];

void main() async {
  // Hive初期化 & info型の保存を可能にする
  await Hive.initFlutter(); // Hiveの初期化（Flutter用）
  Hive.registerAdapter(infoAdapter()); // info型のアダプターを登録（これがないと保存時にクラッシュ）
  box = await Hive.openBox('app_info'); // 'pushup_info'という名前のBoxを開く（なければ作成）
  runApp(const PushApp()); // アプリのエントリーポイント。PushAppウィジェットを起動
}

class PushApp extends StatelessWidget {
  // アプリ全体のウィジェット（Stateless: 状態を持たない）
  const PushApp({super.key}); // コンストラクタ（keyはウィジェットの識別用）

  @override
  Widget build(BuildContext context) {
    // アプリのUI構築
    return const MaterialApp(
      title: 'PushApp', // アプリのタイトル
      home: Calendar(), // メイン画面としてCalendarウィジェットを表示
    );
  }
}

String formatDuration(Duration duration) {
  //渡されたDuration型の変数を受け取る
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  //数字を二桁の文字列に直す関数、padLeftは「二桁になるように左を0で埋める」役割
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  //duration.inSecondsは経過時間の合計秒（分も同じ）、remainder(60)で0から59秒に制限する
  return "$minutes:$seconds"; //この形で返す
}

Duration parseDuration(String formatted) {
  // 文字列形式の時間（"MM:SS"）を受け取る関数
  final parts = formatted.split(':');
  // ':'で文字列を分割し、分と秒の部分を取得
  if (parts.length != 2) {
    // 分と秒の形式でない場合はゼロのDurationを返す
    return Duration.zero;
  }
  final minutes = int.tryParse(parts[0]) ?? 0;
  // 分の文字列を整数に変換。変換できなければ0とする
  final seconds = int.tryParse(parts[1]) ?? 0;
  // 秒の文字列を整数に変換。変換できなければ0とする
  return Duration(minutes: minutes, seconds: seconds);
  // 変換した分と秒からDurationオブジェクトを作成し返す
}
