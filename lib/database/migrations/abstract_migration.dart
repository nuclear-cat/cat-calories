import 'package:sqflite/sqflite.dart';

abstract class AbstractMigration {
  Future<void> up(Batch batch);
  Future<void> down(Batch batch);
}
