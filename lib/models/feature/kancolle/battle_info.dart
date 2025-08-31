import 'dart:developer';

import 'package:conning_tower/main.dart';
import 'package:conning_tower/models/data/kcsapi/kcsapi.dart';
import 'package:conning_tower/models/feature/kancolle/battle_result.dart';
import 'package:conning_tower/models/feature/log/kancolle_ship_log.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../utils/toast.dart';
import '../../../generated/l10n.dart';
import 'map_info.dart';
import 'ship.dart';
import 'squad.dart';

part 'battle_info.freezed.dart';

const kSecondSquadIndexStart = 6;

@unfreezed
sealed class BattleInfo with _$BattleInfo {
  factory BattleInfo({
    int? mvp,
    List<Squad>? enemySquads,
    List<Squad>? inBattleSquads,
    List<Squad>? friendSquads,
    Map<int, int>? dmgTakenMap,
    Map<int, int>? dmgMap,
    int? airSuperiorityFlag,
    int? formation,
    int? eFormation,
    int? contact,
    MapInfo? mapInfo,
    int? mapRoute,
    List<Ship>? readyEscapeShips,
    String? note,
    BattleResult? battleResult,
  }) = _BattleInfo;

  const BattleInfo._();

  /// Returns the air superiority status as a string based on the `airSuperiorityFlag`.
  String get airSuperiority => switch (airSuperiorityFlag) {
        0 => S.current.KCAirBattleParity,
        1 => S.current.KCAirBattleSupremacy,
        2 => S.current.KCAirBattleSuperiority,
        3 => S.current.KCAirBattleDenial,
        4 => S.current.KCAirBattleIncapability,
        _ => '',
      };

  List<Ship> get allEnemyShips =>
      enemySquads!.expand((squad) => squad.ships).toList();

  List<Ship> get allOurShips =>
      inBattleSquads!.expand((squad) => squad.ships).toList();

  List<Ship> get allShips => allEnemyShips + allOurShips;

  String get contactStatus => switch (contact) {
        1 => S.current.KCBattleContactStatus1,
        2 => S.current.KCBattleContactStatus2,
        3 => S.current.KCBattleContactStatus3,
        4 => S.current.KCBattleContactStatus4,
        _ => "",
      };

  List<String> get damagedShipNames {
    final names = <String>[];
    for (final squad in inBattleSquads!) {
      for (final ship in squad.ships) {
        if (ship.damaged && ship.escape != true) {
          names.add(ship.name ?? "Ship ${ship.shipId}");
        }
      }
    }
    return names;
  }

  String get enemyFormation {
    return getFormationText(eFormation ?? 0);
  }

  String get ourFormation {
    return getFormationText(formation ?? 0);
  }

  void airBaseAttackRound(AirBaseAttackRound? data) {
    if (data == null) return;
    if (data.apiStageFlag == null) return;
    for (final (index, flag) in data.apiStageFlag!.indexed) {
      if (flag == 1) {
        switch (index) {
          case 0:
            break;
          case 1:
            break;
          case 2:
            if (data.apiStage3Combined != null) {
              airBaseDamageCount(
                  data.apiStage3?.apiEdam, data.apiStage3Combined?.apiEdam);
            } else {
              airBaseDamageCount(data.apiStage3?.apiEdam, null);
            }
        }
      }
    }
  }

  void airBaseDamageCount(
      List<num?>? enemyDamageList, List<num?>? enemyCombinedDamageList) {
    if (enemyDamageList != null) {
      for (final (index, damage) in enemyDamageList.indexed) {
        calculateDamageTaken(getEShip1(index).hashCode, damage!);
      }
    }
    if (enemyCombinedDamageList != null) {
      for (final (index, damage) in enemyCombinedDamageList.indexed) {
        calculateDamageTaken(getEShip2(index).hashCode, damage!);
      }
    }
  }

  void aircraftRound(List<int> airStageFlag, AircraftRound airBattle) {
    for (final (index, flag) in airStageFlag.indexed) {
      if (flag == 1) {
        switch (index) {
          case 0:
            airSuperiorityFlag = airBattle.apiStage1?.apiDispSeiku;
            break;
          case 1:
            log("stage2");
            break;
          case 2:
            aircraftRoundDamageCount(airBattle);
        }
      }
    }
  }

  void aircraftRoundDamageCount(AircraftRound airBattle,
      {bool isFriendlyBattle = false}) {
    if (airBattle.apiStage3?.apiFdam != null && !isFriendlyBattle) {
      for (final (index, damage) in airBattle.apiStage3!.apiFdam!.indexed) {
        calculateDamageTaken(getOShip1(index).hashCode, damage!);
      }
    }
    if (airBattle.apiStage3?.apiEdam != null) {
      for (final (index, damage) in airBattle.apiStage3!.apiEdam!.indexed) {
        calculateDamageTaken(getEShip1(index).hashCode, damage!);
      }
    }
    if (airBattle.apiStage3Combined != null) {
      if (airBattle.apiStage3Combined?.apiFdam != null && !isFriendlyBattle) {
        for (final (index, damage)
            in airBattle.apiStage3Combined!.apiFdam!.indexed) {
          calculateDamageTaken(getOShip2(index).hashCode, damage!);
        }
      }
      if (airBattle.apiStage3Combined?.apiEdam != null) {
        for (final (index, damage)
            in airBattle.apiStage3Combined!.apiEdam!.indexed) {
          calculateDamageTaken(getEShip2(index).hashCode, damage!);
        }
      }
    }
  }

  /// Calculates the damage dealt by a ship during combat.
  void calculateDamageDealt(int actShipHash, num damage) {
    if (!dmgMap!.containsKey(actShipHash)) {
      return;
    }
    assert(damage >= 0);
    dmgMap![actShipHash] = dmgMap![actShipHash]! + damage.truncate();
  }

  /// Calculates the damage taken by a ship during combat.
  void calculateDamageTaken(int defShipHash, num damage) {
    if (!dmgTakenMap!.containsKey(defShipHash)) {
      return;
    }
    assert(damage >= 0);
    dmgTakenMap![defShipHash] = dmgTakenMap![defShipHash]! - damage.truncate();
  }

  void clear({bool resetMapInfo = false, bool pointChanged = false}) {
    mvp = null;
    airSuperiorityFlag = null;
    formation = null;
    eFormation = null;
    contact = null;
    enemySquads?.clear();
    friendSquads?.clear();
    battleResult ??= BattleResult(ourBattleScore: 0, enemyBattleScore: 0);
    if (pointChanged) {
      dmgMap = null;
      dmgTakenMap = null;
      battleResult = BattleResult(ourBattleScore: 0, enemyBattleScore: 0);
    }
    note = null;
    if (resetMapInfo) {
      mapInfo = null;
      mapRoute = null;
    }
  }

  void confirmEscapeShip() {
    if (readyEscapeShips != null) {
      for (final ship in readyEscapeShips!) {
        ship.escape = true;
      }
      readyEscapeShips = [];
    }
  }

  void doubleOurSideBattlePrepare(DoubleOurBattleData data) {
    updateEscapeFlagInBattle(
        indexes: data.apiEscapeIdx, combinedIndexes: data.apiEscapeIdxCombined);
    initShipHP(
      fNow: data.apiFNowhps,
      fMax: data.apiFMaxhps,
      fNow2: data.apiFNowhpsCombined,
      fMax2: data.apiFMaxhpsCombined,
    );
  }

  void friendlyBattleCalculate({
    BattleFriendlyInfo? info,
    FriendlyFleetBattle? battle,
    AircraftRoundData? airBattle,
  }) {
    if (info == null) return;

    initFriendSquads(info);

    if (battle != null) {
      gunFireRound(battle.apiHougeki!, isFriendlyBattle: true);
    }
    if (airBattle != null) {
      aircraftRoundDamageCount(airBattle, isFriendlyBattle: true);
    }
  }

  Ship getEShip1(int index) => enemySquads![0].ships[index];

  Ship getEShip2(int index) => enemySquads![1].ships[index];

  GunFireRound getGunFireData(FullGunFireRoundBattle data, int index) {
    switch (index) {
      case 0:
        return data.apiHougeki1!;
      case 1:
        return data.apiHougeki2!;
      case 2:
        return data.apiHougeki3!;
      default:
        throw Exception("hourai flag out of range");
    }
  }

  Ship getOShip1(int index) => inBattleSquads![0].ships[index];

  Ship getOShip2(int index) => inBattleSquads![1].ships[index];

  Ship getShip(FleetSide side, int index) {
    // 游擊部隊 squad len is 7, index need less than first squad len
    // combine and normal squad len max is 6
    if (side == FleetSide.our) {
      final firstLength = inBattleSquads![0].ships.length;
      if (firstLength > index) return getOShip1(index);
      return getOShip2(index - kSecondSquadIndexStart); // len may be always 6
    } else {
      final firstLength = enemySquads![0].ships.length;
      if (firstLength > index) return getEShip1(index);
      return getEShip2(index - kSecondSquadIndexStart);
    }
  }

  // index start from 1
  Ship getShipByNumero(FleetSide side, int num) => getShip(side, num - 1);

  void gunFireRound(GunFireRound data, {bool isFriendlyBattle = false}) {
    if (data.apiAtEflag == null) return;
    for (final (index, flag) in data.apiAtEflag!.indexed) {
      if (flag != 1 && flag != 0) {
        log("unhandled active flag");
        continue;
      }
      final actIndex = data.apiAtList![index];

      final ourSquads = isFriendlyBattle ? friendSquads! : inBattleSquads!;

      final actSquads = flag == 0 ? ourSquads : enemySquads!;
      final defSquads = flag == 1 ? ourSquads : enemySquads!;

      final damages = data.apiDamage![index];
      final defList = data.apiDfList![index];

      for (final (index, damage) in damages.indexed) {
        final defIndex = defList[index];
        // "防御艦のインデックス　[][攻撃対象数]　0基点　単発カットイン攻撃では [防御艦, -1, -1] になる" Not Understand this case yet
        if (defIndex == -1) continue;
        late final Ship defShip;
        if (defIndex < defSquads[0].ships.length) {
          defShip = defSquads[0].ships[defIndex];
        } else {
          defShip = defSquads[1].ships[defIndex -
              kSecondSquadIndexStart]; // second squad index start from 6
        }
        calculateDamageTaken(defShip.hashCode, damage);

        late final Ship actShip;
        if (actIndex < actSquads[0].ships.length) {
          actShip = actSquads[0].ships[actIndex];
        } else {
          actShip = actSquads[1].ships[actIndex - kSecondSquadIndexStart];
        }

        calculateDamageDealt(actShip.hashCode, damage);
      }
    }
  }

  void initDMGMap() {
    dmgTakenMap = {for (var ship in allShips) ship.hashCode: 0};
    dmgMap = {for (var ship in allShips) ship.hashCode: 0};
  }

  void initDoubleEnemySquads(DoubleEnemyBattleData data) {
    enemySquads = [
      Squad.fromSingleEnemy(
          data.apiShipKe, data.apiShipLv, data.apiEMaxhps, data.apiENowhps, data.apiESlot),
      Squad.fromSingleEnemy(data.apiShipKeCombined!, data.apiShipLvCombined!,
          data.apiEMaxhpsCombined!, data.apiENowhpsCombined!, data.apiESlotCombined!),
    ];
  }

  void initFriendSquads(BattleFriendlyInfo info) {
    friendSquads = [
      Squad.fromSingleFriend(
          info.apiShipId, info.apiShipLv, info.apiMaxhps, info.apiNowhps)
    ];
    updateDMGMap();
  }

  void initShipHP(
      {required List<int> fNow,
      required List<int> fMax,
      List<int>? fNow2,
      List<int>? fMax2}) {
    if (fNow2 == null || fMax2 == null) {
      initShipHPSingleSquad(fNow: fNow, fMax: fMax);
    } else {
      initShipHPDoubleSquad(fNow: fNow, fMax: fMax, fNow2: fNow2, fMax2: fMax2);
    }
  }

  void initShipHPDoubleSquad(
      {required List<int> fNow,
      required List<int> fMax,
      required List<int> fNow2,
      required List<int> fMax2}) {
    initShipHPSingleSquad(fNow: fNow, fMax: fMax);
    for (final (index, now) in fNow2.indexed) {
      final max = fMax2[index];
      final ship = getOShip2(index);
      ship.nowHP = now;
      ship.maxHP = max;
    }
  }

  void initShipHPSingleSquad(
      {required List<int> fNow, required List<int> fMax}) {
    for (final (index, now) in fNow.indexed) {
      final max = fMax[index];
      final ship = getOShip1(index);
      ship.nowHP = now;
      ship.maxHP = max;
    }
  }

  void initSingleEnemySquads(BattleBasicModel data) {
    enemySquads = [
      Squad.fromSingleEnemy(
          data.apiShipKe, data.apiShipLv, data.apiEMaxhps, data.apiENowhps, data.apiESlot)
    ];
  }

  void parseBattle(BattleBasicModel data, List<Squad> squads) {
    clear();
    inBattleSquads = squads;

    if (data is DoubleVsDoubleBattleData) {
      // FIXME: need check `api_deck_id`, if not 1, then it's not combined battle?
      doubleOurSideBattlePrepare(data);
      initDoubleEnemySquads(data);
    } else if (data is SingleVsDoubleBattleData) {
      singleOurSideBattlePrepare(data);
      initDoubleEnemySquads(data);
    } else if (data is DoubleVsSingleBattleData) {
      doubleOurSideBattlePrepare(data);
      initSingleEnemySquads(data);
    } else {
      singleOurSideBattlePrepare(data);
      initSingleEnemySquads(data);
    }

    initDMGMap();

    setFormation(data.apiFormation);

    _parseBasicBattleApi(data);

    _parseRoundBattleApi(data);

    updateShipHP();
  }

  void parsePracticeBattle(ReqPracticeBattleApiDataEntity data, Squad squad) {
    clear(resetMapInfo: true, pointChanged: true);
    initSingleEnemySquads(data);

    inBattleSquads = [Squad.fromJson(squad.toJson())]; // deep copy

    initDMGMap();

    initShipHPSingleSquad(fNow: data.apiFNowhps, fMax: data.apiFMaxhps);

    setFormation(data.apiFormation);

    if (data.apiInjectionKouku != null) {
      aircraftRoundDamageCount(data.apiInjectionKouku!);
    }

    //api_kouku
    aircraftRound(data.apiStageFlag!, data.apiKouku!);

    //api_opening_taisen
    if (data.apiOpeningTaisenFlag == 1) {
      gunFireRound(data.apiOpeningTaisen!);
    }

    //api_opening_atack
    if (data.apiOpeningFlag == 1) {
      torpedoFireRoundWithItem(data.apiOpeningAtack!);
    }

    for (final (index, flag) in data.apiHouraiFlag.indexed) {
      if (flag == 1) {
        if (index >= 0 && index <= 2) {
          gunFireRound(getGunFireData(data, index));
        } else if (index == 3) {
          torpedoFireRound(data.apiRaigeki!);
        } else {
          log("unhandled hourai flag");
        }
      }
    }

    updateShipHP();
  }

  void parsePracticeMidnightBattle(
      ReqPracticeMidnightBattleApiDataEntity data, Squad squad) {
    clear();
    initSingleEnemySquads(data);

    inBattleSquads = [Squad.fromJson(squad.toJson())]; // deep copy

    initDMGMap();

    initShipHPSingleSquad(fNow: data.apiFNowhps, fMax: data.apiFMaxhps);

    setFormation(data.apiFormation);

    gunFireRound(data.apiHougeki!);

    updateShipHP();
  }

  void parseReqCombinedBattleResultEntity(
      ReqCombinedBattleResultApiDataEntity data, {required String admiral}) {
    if (data.apiEscape != null) {
      setReadyEscapeShip(data.apiEscape!);
    }
    Toast.battleResultNotify(damagedShipNames);
    battleResult?.actual = data.apiWinRank;
    final dropName = data.apiGetShip?.apiShipName;
    battleResult?.dropShipName = dropName;
    if (dropName != null) {
      objectbox.saveShipLog(
          admiral: admiral, type: ShipLogType.drop, shipName: dropName);
    }
    if (enemySquads != null) {
      for (var squad in enemySquads!) {
        if (data.apiEnemyInfo != null) {
          squad.name = data.apiEnemyInfo?.apiDeckName ??
              S.current.KCDashboardBattleEnemy;
        }
      }
    }
    mvp = data.apiMvp;
    if (data.apiGetExmapUseitemId != null &&
        data.apiGetExmapUseitemId != 0 &&
        data.apiGetExmapUseitemId != '') {
      if (data.apiGetExmapUseitemId is int) {
        battleResult?.dropItemId = data.apiGetExmapUseitemId;
      }
      if (data.apiGetExmapUseitemId is String) {
        try {
          battleResult?.dropItemId = int.parse(data.apiGetExmapUseitemId);
        } catch (e) {
          battleResult?.dropItemId = null;
        }
      }
    }
  }

  void parseReqSortieBattleResult(ReqSortieBattleResultApiDataEntity data, {required String admiral}) {
    if (data.apiEscape != null) {
      setReadyEscapeShip(data.apiEscape!);
    }
    Toast.battleResultNotify(damagedShipNames);
    battleResult?.actual = data.apiWinRank;
    final dropName = data.apiGetShip?.apiShipName;
    battleResult?.dropShipName = dropName;
    if (dropName != null) {
      objectbox.saveShipLog(
          admiral: admiral, type: ShipLogType.drop, shipName: dropName);
    }
    if (enemySquads != null) {
      for (var squad in enemySquads!) {
        squad.name =
            data.apiEnemyInfo.apiDeckName ?? S.current.KCDashboardBattleEnemy;
      }
    }
    mvp = data.apiMvp;
    var item = data.apiGetUseitem;
    if (item != null) {
      battleResult?.dropItemId = item.apiUseitemId;
      if (item.apiUseitemName != '') {
        battleResult?.dropItemName = item.apiUseitemName;
      }
    } else if (data.apiGetExmapUseitemId != null &&
        data.apiGetExmapUseitemId != 0 &&
        data.apiGetExmapUseitemId != '') {
      // only record one of apiGetExmapUseitemId and apiGetExmapUseitemName now
      if (data.apiGetExmapUseitemId is int) {
        battleResult?.dropItemId = data.apiGetExmapUseitemId;
      }
      if (data.apiGetExmapUseitemId is String) {
        try {
          battleResult?.dropItemId = int.parse(data.apiGetExmapUseitemId);
        } catch (e) {
          battleResult?.dropItemId = null;
        }
      }
    }
  }

  void setFormation(List<int> apiFormation) {
    formation = apiFormation[0];
    eFormation = apiFormation[1];
    contact = apiFormation[2];
    if (mapInfo != null && mapRoute != null) {
      objectbox.saveRouteLog(
          mapId: mapInfo!.id, routeId: mapRoute, formation: formation!);
    }
  }

  void setReadyEscapeShip(BattleResultEscapeEntity data) {
    readyEscapeShips ??= [];
    if (data.apiEscapeIdx.isNotEmpty) {
      readyEscapeShips
          ?.add(getShipByNumero(FleetSide.our, data.apiEscapeIdx.first));
    }
    if (data.apiTowIdx != null && data.apiTowIdx!.isNotEmpty) {
      readyEscapeShips
          ?.add(getShipByNumero(FleetSide.our, data.apiTowIdx!.first));
    }
  }

  void singleOurSideBattlePrepare(BattleBasicModel data) {
    updateEscapeFlagInBattle(indexes: data.apiEscapeIdx);
    initShipHP(fNow: data.apiFNowhps, fMax: data.apiFMaxhps);
  }

  void supportBattleAircraftRound(AircraftRound? data) {
    if (data == null) return;
    for (final (index, ship) in allEnemyShips.indexed) {
      calculateDamageTaken(ship.hashCode, data.apiStage3!.apiEdam![index]!);
    }
  }

  void supportBattleGunFireRound(BattleGunfireSupport? data) {
    if (data == null) return;
    for (final (index, ship) in allEnemyShips.indexed) {
      calculateDamageTaken(ship.hashCode, data.apiDamage![index]);
    }
  }

  void supportBattleRound(BattleSupportInfo? data) {
    if (data == null) return;
    supportBattleGunFireRound(data.apiSupportHourai);
    supportBattleAircraftRound(data.apiSupportAiratack);
  }

  void torpedoFireRound(TorpedoRoundEntity data) {
    for (final (actIndex, defIndex) in data.apiFrai.indexed) {
      if (defIndex != -1) {
        final Ship actShip = getShip(FleetSide.our, actIndex);
        final Ship defShip = getShip(FleetSide.enemy, defIndex);
        final actShipHash = actShip.hashCode;
        final defShipHash = defShip.hashCode;
        calculateDamageDealt(actShipHash, data.apiFydam[actIndex]);
        calculateDamageTaken(defShipHash, data.apiFydam[actIndex]);
      }
    }
    for (final (actIndex, defIndex) in data.apiErai.indexed) {
      if (defIndex != -1) {
        final Ship actShip = getShip(FleetSide.enemy, actIndex);
        final Ship defShip = getShip(FleetSide.our, defIndex);
        final actShipHash = actShip.hashCode;
        final defShipHash = defShip.hashCode;
        calculateDamageDealt(actShipHash, data.apiEydam[actIndex]);
        calculateDamageTaken(defShipHash, data.apiEydam[actIndex]);
      }
    }
  }

  void torpedoFireRoundWithItem(OpeningTorpedoRoundEntity data) {
    for (final (actIndex, defIndexList) in data.apiFraiListItems.indexed) {
      if (defIndexList != null) {
        final Ship actShip = getShip(FleetSide.our, actIndex);
        final actShipHash = actShip.hashCode;
        final dmgList = data.apiFydamListItems[actIndex];
        assert(dmgList?.length == defIndexList.length,
            "Opening torpedo calc error, data not match: $dmgList & $defIndexList");
        for (final (itemIndex, defIndex) in defIndexList.indexed) {
          if (defIndex > -1) {
            final Ship defShip = getShip(FleetSide.enemy, defIndex);
            final defShipHash = defShip.hashCode;
            final dmg = dmgList![itemIndex];
            calculateDamageDealt(actShipHash, dmg);
            calculateDamageTaken(defShipHash, dmg);
          }
        }
      }
    }
    for (final (actIndex, defIndexList) in data.apiEraiListItems.indexed) {
      if (defIndexList != null) {
        final Ship actShip = getShip(FleetSide.enemy, actIndex);
        final actShipHash = actShip.hashCode;
        final dmgList = data.apiEydamListItems[actIndex];
        assert(dmgList?.length == defIndexList.length,
            "Opening torpedo calc error, data not match: $dmgList & $defIndexList");
        for (final (itemIndex, defIndex) in defIndexList.indexed) {
          if (defIndex > -1) {
            final Ship defShip = getShip(FleetSide.our, defIndex);
            final defShipHash = defShip.hashCode;
            final dmg = dmgList![itemIndex];
            calculateDamageDealt(actShipHash, dmg);
            calculateDamageTaken(defShipHash, dmg);
          }
        }
      }
    }
  }

  void updateDMGMap() {
    if (friendSquads != null) {
      for (final ship in friendSquads!.first.ships) {
        dmgMap?[ship.hashCode] = 0;
        dmgTakenMap?[ship.hashCode] = 0;
      }
    }
  }

  void updateEscapeFlagInBattle(
      {List<int>? indexes, List<int>? combinedIndexes}) {
    if (indexes != null) {
      _updateEscapeFlag(0, indexes);
    }
    if (combinedIndexes != null) {
      _updateEscapeFlag(1, combinedIndexes);
    }
  }

  void updateShipHP() {
    Map<int, int> hpChangeMap = {};
    if (battleResult?.enemyHPTotal == null) {
      final enemyHPTotal = allEnemyShips.fold(0, (t, e) => t + e.nowHP);
      battleResult?.enemyHPTotal = enemyHPTotal;
    }
    if (battleResult?.ourHPTotal == null) {
      final ourHPTotal = allOurShips.fold(0, (t, e) => t + e.nowHP);
      battleResult?.ourHPTotal = ourHPTotal;
    }

    if (dmgTakenMap != null) {
      final shipsMap = {for (Ship ship in allShips) ship.hashCode: ship};

      dmgTakenMap?.forEach((shipHash, damage) {
        if (damage != 0) {
          final hpChange = shipsMap[shipHash]?.onHPChange(damage);
          if (hpChange != null) {
            hpChangeMap[shipHash] = hpChange;
          }
        }
      });
    }
    battleResult?.parseExpected(
      allOurShips,
      allEnemyShips,
      enemySquads!,
      hpChangeMap,
    );
  }

  void _parseBasicBattleApi(BattleBasicModel data) {
    if (data is NormalBattleData) {
      //api_air_base_injection
      if (data.apiAirBaseInjection != null) {
        if (data.apiAirBaseInjection?.apiStage3Combined != null) {
          airBaseDamageCount(data.apiAirBaseInjection?.apiStage3?.apiEdam,
              data.apiAirBaseInjection?.apiStage3Combined?.apiEdam);
        } else {
          airBaseDamageCount(
              data.apiAirBaseInjection?.apiStage3?.apiEdam, null);
        }
      }
      // api_air_base_attack
      if (data.apiAirBaseAttack != null) {
        for (final airBaseAttack in data.apiAirBaseAttack!) {
          airBaseAttackRound(airBaseAttack);
        }
      }
      // api_injection_kouku
      if (data.apiInjectionKouku != null) {
        aircraftRoundDamageCount(data.apiInjectionKouku!);
      }
      // api_kouku
      aircraftRound(data.apiStageFlag!, data.apiKouku!);
      // api_support_info
      supportBattleRound(data.apiSupportInfo);
      //api_opening_taisen
      if (data.apiOpeningTaisenFlag == 1) {
        gunFireRound(data.apiOpeningTaisen!);
      }
      //api_opening_atack
      if (data.apiOpeningFlag == 1) {
        torpedoFireRoundWithItem(data.apiOpeningAtack!);
      }

      if (data is ReqSortieBattleApiDataEntity) {
        friendlyBattleCalculate(
            info: data.apiFriendlyInfo,
            battle: data.apiFriendlyBattle,
            airBattle: data.apiFriendlyKouku);
      } else {
        friendlyBattleCalculate(
            info: data.apiFriendlyInfo, airBattle: data.apiFriendlyKouku);
      }
    } else if (data is NightBattleData) {
      friendlyBattleCalculate(
          info: data.apiFriendlyInfo, battle: data.apiFriendlyBattle);
      if (data.apiHougeki != null) {
        gunFireRound(data.apiHougeki!);
      }
      if (data is NightBattleWithSupportData) {
        supportBattleRound(data.apiNSupportInfo);
      }
    } else if (data is ReqSortieLdAirbattleApiDataEntity) {
      aircraftRound(data.apiStageFlag!, data.apiKouku!);
    } else if (data is ReqCombinedBattleLdAirbattleApiDataEntity) {
      aircraftRound(data.apiStageFlag!, data.apiKouku!);
    } else if (data is ReqSortieAirbattleApiDataEntity) {
      if (data.apiStageFlag != null) {
        aircraftRound(data.apiStageFlag!, data.apiKouku!);
      }
      supportBattleRound(data.apiSupportInfo);
      if (data.apiStageFlag2 != null) {
        aircraftRound(data.apiStageFlag2!, data.apiKouku2!);
      }
    }
  }

  void _parseRoundBattleApi(BattleBasicModel data) {
    if (data is ReqSortieBattleApiDataEntity) {
      for (final (index, flag) in data.apiHouraiFlag!.indexed) {
        if (flag == 1) {
          if (index >= 0 && index <= 2) {
            gunFireRound(getGunFireData(data, index));
          } else if (index == 3) {
            torpedoFireRound(data.apiRaigeki!);
          } else {
            log("unhandled hourai flag");
          }
        }
      }
    } else if (data is CarrierOrEscortBattleData) {
      for (final (index, flag) in data.apiHouraiFlag!.indexed) {
        if (flag == 1) {
          switch (index) {
            case 0:
              gunFireRound(data.apiHougeki1!);
              break;
            case 1:
              torpedoFireRound(data.apiRaigeki!);
              break;
            case 2:
              gunFireRound(data.apiHougeki2!);
              break;
            case 3:
              gunFireRound(data.apiHougeki3!);
              break;
            default:
              log("unhandled hourai flag");
          }
        }
      }
    } else if (data is ReqCombinedBattleEachBattleApiDataEntity) {
      for (final (index, flag) in data.apiHouraiFlag!.indexed) {
        if (flag == 1) {
          switch (index) {
            case 0:
              gunFireRound(data.apiHougeki1!);
              break;
            case 1:
              gunFireRound(data.apiHougeki2!);
              break;
            case 2:
              torpedoFireRound(data.apiRaigeki!);
              break;
            case 3:
              gunFireRound(data.apiHougeki3!);
              break;
            default:
              log("unhandled hourai flag");
          }
        }
      }
    } else if (data is SurfaceForceBattleData) {
      for (final (index, flag) in data.apiHouraiFlag!.indexed) {
        if (flag == 1) {
          switch (index) {
            case 0:
              gunFireRound(data.apiHougeki1!);
              break;
            case 1:
              gunFireRound(data.apiHougeki2!);
              break;
            case 2:
              gunFireRound(data.apiHougeki3!);
              break;
            case 3:
              torpedoFireRound(data.apiRaigeki!);
              break;
            default:
              log("unhandled hourai flag");
          }
        }
      }
    }
  }

  void _updateEscapeFlag(int squadIndex, List<int> numList) {
    for (final (index, ship) in inBattleSquads![squadIndex].ships.indexed) {
      if (numList.contains(index + 1)) {
        ship.escape = true;
      } else {
        ship.escape = false;
      }
    }
  }

  static String getFormationText(int flag) {
    String formation;

    formation = switch (flag) {
      -1 => "N/A",
      1 => S.current.KCBattleFormation1,
      2 => S.current.KCBattleFormation2,
      3 => S.current.KCBattleFormation3,
      4 => S.current.KCBattleFormation4,
      5 => S.current.KCBattleFormation5,
      6 => S.current.KCBattleFormation6,
      11 => S.current.KCBattleFormation11,
      12 => S.current.KCBattleFormation12,
      13 => S.current.KCBattleFormation13,
      14 => S.current.KCBattleFormation14,
      _ => ""
    };

    return formation;
  }

  void parseReqPracticeBattleResult(ReqPracticeBattleResultApiDataEntity? data) {
    Toast.battleResultNotify([]);
    battleResult?.actual = data?.apiWinRank;
    if (enemySquads != null) {
      for (var squad in enemySquads!) {
        squad.name =
            data?.apiEnemyInfo?.apiDeckName ?? S.current.KCDashboardBattleEnemy;
      }
    }
    mvp = data?.apiMvp;
  }
}

enum CombinedFleetType {
  sortieFleet,
  carrierTaskForce, // 空母機動部隊
  surfaceTaskForce, // 水上打撃部隊
  transportEscort, // 輸送護衛部隊
}

enum FleetSide { our, enemy }
