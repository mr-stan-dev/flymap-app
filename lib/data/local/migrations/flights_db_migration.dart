import 'package:sembast/sembast.dart';

abstract class FlightsDbMigration {
  int get targetVersion;

  Future<void> run(Database db);
}
