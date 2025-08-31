import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../generated/l10n.dart';
import 'ship.dart';

part 'squad.freezed.dart';
part 'squad.g.dart';

@unfreezed
sealed class Squad with _$Squad {
  const Squad._();

  factory Squad({
    required int id,
    required String name,
    int? operation,
    required List<Ship> ships,
  }) = _Squad;

  String get aircraftPower {
    num sum = 0;
    for (final ship in ships) {
      sum += ship.aircraftPower().min;
    }
    if (sum == 0) {
      return '0';
    }
    return '$sum+';
  }

  /* rebuild from poi javascript function: getSaku33(shipsData, equipsData, teitokuLv, mapModifier = 1.0, slotCount = 6)
  views/utils/game-utils.es
  */
  LoS los(
      {required int admiralLevel, num mapModifier = 1.0, int maxShips = 6}) {
    int emptyShipCount = maxShips - ships.length;
    num losShip = 0;
    num losEquip = 0;
    num losAdmiral = 0;
    num losTotal = 0;
    for (final ship in ships) {
      losShip += sqrt(ship.losShip);
      losEquip += ship.losEquip;
    }
    losEquip *= mapModifier;
    losAdmiral = (admiralLevel * 0.4).ceil();
    losTotal = losShip + losEquip - losAdmiral + 2 * emptyShipCount;

    return LoS(
      ship: losShip,
      equip: losEquip,
      admiral: losAdmiral,
      total: losTotal,
    );
  }

  factory Squad.fromSingleEnemy(List<int> enemyId, List<int> enemyLv,
      List<dynamic> enemyMaxHP, List<dynamic> enemyNowHP, List<List<int>> slotData) {
    assert(
        enemyId.length == enemyLv.length &&
            enemyLv.length == enemyMaxHP.length &&
            enemyMaxHP.length == enemyNowHP.length,
        'length not equal');
    List<Ship> ships = [];
    for (var i = 0; i < enemyId.length; i++) {
      var id = enemyId[i];
      var level = enemyLv[i];
      var nowHP = enemyNowHP[i];
      var maxHP = enemyMaxHP[i];
      var slot = slotData[i];
      ships.add(Ship.enemy(id: id, level: level, nowHP: nowHP, maxHP: maxHP, slot: slot));
    }
    return Squad(id: 1, name: S.current.KCDashboardBattleEnemy, ships: ships);
  }

  factory Squad.fromSingleFriend(List<int> friendId, List<int> friendLv,
      List<int> friendMaxHP, List<int> friendNowHP) {
    assert(
        friendId.length == friendLv.length &&
            friendLv.length == friendMaxHP.length &&
            friendMaxHP.length == friendNowHP.length,
        'length not equal');
    List<Ship> ships = [];
    for (var i = 0; i < friendId.length; i++) {
      var id = friendId[i];
      var level = friendLv[i];
      var nowHP = friendNowHP[i];
      var maxHP = friendMaxHP[i];
      ships.add(Ship.friend(id: id, level: level, nowHP: nowHP, maxHP: maxHP));
    }
    return Squad(id: 1, name: '友軍艦隊', ships: ships);
  }

  factory Squad.fromJson(Map<String, dynamic> json) => _$SquadFromJson(json);
}

class LoS {
  late final num ship;
  late final num equip;
  late final num admiral;
  late final num total;

  LoS({
    required this.ship,
    required this.equip,
    required this.admiral,
    required this.total,
  });
}
