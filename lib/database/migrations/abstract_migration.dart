import 'package:sqflite/sqflite.dart';

abstract class AbstractMigration {
  int getVersion();
  Future<Batch> up(Batch batch);
  Future<Batch> down(Batch batch);
}
