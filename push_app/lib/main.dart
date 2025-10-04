import 'package:flutter/material.dart'; // FlutterのUI部品を使うためのパッケージをインポート
import 'package:flutter/services.dart';
import 'screens/screens.dart';
import 'package:hive_flutter/hive_flutter.dart'; // HiveのFlutter用パッケージをインポート
import 'package:push_app/models/models.dart';
import 'package:push_app/strings/strings.dart';
export 'package:push_app/models/models.dart';
export 'package:push_app/strings/strings.dart';

part 'main.g.dart'; // Hive Generator用（TypeAdapter自動生成ファイル）

late Box box; // HiveのBox（データ保存領域）をグローバル変数として宣言
late List<dynamic> highlightDays = [];

late String language;

int month = DateTime.now().month;

String t(String key) {
  return appStrings[language]?[key] ?? key;
}

void showMenuDialog(BuildContext context, int month) {
  showGeneralDialog(
    context: context, // ダイアログの表示に使うBuildContext
    barrierDismissible: true, // ダイアログ外のタップで閉じるか
    barrierLabel: t("menu"), // アクセシビリティ用のラベル
    barrierColor: Colors.black54, // ダイアログ表示時の背景色
    transitionDuration: Duration(milliseconds: 300), // ダイアログの表示/非表示アニメーションの時間
    // ダイアログの中身を構築するコールバック
    pageBuilder: (context, animation, secondaryAnimation) {
      // Alignで右側に寄せて表示
      return Align(
        alignment: Alignment.centerRight, // 右端中央に配置
        child: Material(
          color: Color.fromARGB(255, 212, 255, 95), // ダイアログの背景色
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ), // 左側を丸くする
          child: SizedBox(
            width: 150, // ダイアログの幅
            height: 300, // ダイアログの高さ
            child: Column(
              children: [
                // Homeメニュー
                ListTile(
                  title: Text(t("home")),
                  leading: Icon(Icons.home),
                  onTap: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                // Activityメニュー
                ListTile(
                  title: Text(t("activity")),
                  leading: Icon(Icons.bar_chart),
                  onTap: () {
                    // Activityはグラフ画面に遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GraphScreen(month),
                      ),
                    );
                  },
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                // Settingsメニュー
                ListTile(
                  title: Text(t("settings")),
                  leading: Icon(Icons.settings),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    ); // Settings画面に遷移
                  },
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      );
    },
    // ダイアログの表示アニメーションを定義
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // 右からスライドインするアニメーション
      final offsetAnimation = Tween<Offset>(
        //Tweenは滑らかに変化させる仕組み
        begin: Offset(1, 0), // 画面右端からOffsetの単位は自分の幅
        end: Offset(0, 0), // 画面中央へ
      ).animate(animation);
      return SlideTransition(
        position: offsetAnimation, // アニメーション位置
        child: child, // アニメーションさせるダイアログ本体
      );
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 縦画面（portraitUp と portraitDown の両方）を許可
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Hive初期化 & info型の保存を可能にする
  await Hive.initFlutter(); // Hiveの初期化（Flutter用）
  Hive.registerAdapter(infoAdapter()); // info型のアダプターを登録（これがないと保存時にクラッシュ）
  box = await Hive.openBox('app_info'); // 'pushup_info'という名前のBoxを開く（なければ作成）
  box.get('language') == null
      ? language = 'English'
      : language = box.get('language');
  print("this:${t("this month's goal")}");
  runApp(const PushApp()); // アプリのエントリーポイント。PushAppウィジェットを起動
}

class PushApp extends StatelessWidget {
  // アプリ全体のウィジェット（Stateless: 状態を持たない）
  const PushApp({super.key}); // コンストラクタ（keyはウィジェットの識別用）

  @override
  Widget build(BuildContext context) {
    // アプリのUI構築
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // デバッグバナーを非表示
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
