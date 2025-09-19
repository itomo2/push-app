import 'package:hive/hive.dart'; // Hive（ローカルDB）を使うためのパッケージをインポート
import 'package:hive_flutter/hive_flutter.dart'; // HiveのFlutter用パッケージをインポート

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
