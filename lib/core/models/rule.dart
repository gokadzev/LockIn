import 'package:hive_ce/hive.dart';
part 'rule.g.dart';

@HiveType(typeId: 5)
class Rule extends HiveObject {
  @HiveField(0)
  late String trigger;
  @HiveField(1)
  late String action;
  @HiveField(2)
  bool active = true;
}
