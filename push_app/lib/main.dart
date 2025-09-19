import 'package:flutter/material.dart'; // FlutterのUI部品を使うためのパッケージをインポート
import 'screens/screens.dart';
import 'package:hive_flutter/hive_flutter.dart'; // HiveのFlutter用パッケージをインポート
part 'main.g.dart'; // Hive Generator用（TypeAdapter自動生成ファイル）

// infoクラス: 運動名(subject)と回数(count)を保持するデータモデル
@HiveType(typeId: 0) // Hive用の型IDを指
class info {
  @HiveField(0) // Hiveで保存するフィールド番号
  int pushupcount; // 運動名（例：腕立て伏せ）
  @HiveField(1) // Hiveで保存するフィールド番号
  int situpcount; // 回数
  @HiveField(2)
  Duration? pushuptime;
  @HiveField(3)
  Duration? situptime;
  info(
    this.pushupcount,
    this.situpcount,
    this.pushuptime,
    this.situptime,
  ); // コンストラクタ
}

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
