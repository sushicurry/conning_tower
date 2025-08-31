import 'package:conning_tower/models/data/kcsapi/item_data.dart';
import 'package:conning_tower/models/data/kcsapi/kcsapi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rank_icons/rank_icons.dart';

import '../../data/ooyodo/akashi_schedule.dart';

part 'equipment.freezed.dart';
part 'equipment.g.dart';

@unfreezed
sealed class Equipment with _$Equipment {
  const Equipment._();

  factory Equipment({
    required int id,
    int? sortNo,
    int? itemId,
    int? locked,
    int? level,
    int? proficiency,
    String? name,
    List<int>? type,
    int? hp, // api_taik 耐久
    int? armor, // api_souk 装甲
    int? firepower, // api_houg 火力
    int? torpedo, // api_raig 雷装
    int? speed, // api_soku 速力
    int? bomber, // api_baku 爆装
    int? aa, // api_tyku 对空
    int? asw, // api_tais 对潜
    int? atap, // api_atap 不明
    int? hit, // api_houm 命中 対爆(局地戦闘機の場合)
    int? torpedoHit, // api_raim 雷击命中
    int? evasion, // api_houk 回避 迎撃(局地戦闘機の場合)
    int? torpedoEvasion, // api_raik 雷击回避
    int? bombEvasion, // api_bakk 爆击回避
    int? los, // api_saku 索敌
    int? antiLos, // api_sakb 索敌妨害
    int? luck, // api_luck 运
    int? range, // api_leng 射程
    int? cost, // api_cost 航空機のコスト
    int? distance, // api_distance 航空機の航続距離
  }) = _Equipment;

  Map<String, int> toNoro6Data() => {
        "api_slotitem_id": itemId ?? 0,
        "api_level": level ?? 0,
      };

  factory Equipment.fromApi(SlotItem item,
      Map<int, GetDataApiDataApiMstSlotitemEntity>? slotItemInfoMap) {
    Equipment equipment = Equipment(
        id: item.apiId,
        itemId: item.apiSlotitemId,
        locked: item.apiLocked,
        level: item.apiLevel,
        proficiency: item.apiAlv);
    if (slotItemInfoMap != null) {
      final slotItemInfo = slotItemInfoMap[item.apiSlotitemId];
      if (slotItemInfo != null) {
        equipment = equipment.copyWith(
            sortNo: slotItemInfo.apiSortno,
            name: slotItemInfo.apiName,
            type: slotItemInfo.apiType,
            hp: slotItemInfo.apiTaik,
            armor: slotItemInfo.apiSouk,
            firepower: slotItemInfo.apiHoug,
            torpedo: slotItemInfo.apiRaig,
            speed: slotItemInfo.apiSoku,
            bomber: slotItemInfo.apiBaku,
            aa: slotItemInfo.apiTyku,
            asw: slotItemInfo.apiTais,
            atap: slotItemInfo.apiAtap,
            hit: slotItemInfo.apiHoum,
            torpedoHit: slotItemInfo.apiRaim,
            evasion: slotItemInfo.apiHouk,
            torpedoEvasion: slotItemInfo.apiRaik,
            bombEvasion: slotItemInfo.apiBakk,
            los: slotItemInfo.apiSaku,
            antiLos: slotItemInfo.apiSakb,
            luck: slotItemInfo.apiLuck,
            range: slotItemInfo.apiLeng,
            cost: slotItemInfo.apiCost,
            distance: slotItemInfo.apiDistance);
      }
    }
    return equipment;
  }

  factory Equipment.fromJson(Map<String, dynamic> json) =>
      _$EquipmentFromJson(json);

  bool get isAirCraft => (type?[4] ?? 0) > 0;

  String text({int? onSlot, Map<String, String>? l10nMap}) {
    String name = this.name ?? "N/A";
    if (l10nMap != null && l10nMap.containsKey(name)) {
      name = l10nMap[name]!;
    }

    late String info;

    if (level! > 0) {
      info = "$name - ★$level";
    } else {
      info = name;
    }

    if (onSlot == null) {
      return info;
    } else {
      if (onSlot > 0 && isAirCraft) {
        // aircraft
        info = "$name : $onSlot";
        if (level! > 0) {
          info = "$name - ★$level : $onSlot";
        }
      }
    }

    return info;
  }

  IconData? get proficiencyIcon => switch (proficiency ?? 0) {
        1 => RankIcons.w1,
        2 => RankIcons.w2,
        3 => RankIcons.w3,
        4 => RankIcons.o1,
        5 => RankIcons.o2,
        6 => RankIcons.o3,
        >= 7 => RankIcons.o5,
        _ => null,
      };

  Color? get proficiencyColor => switch (proficiency ?? 0) {
        1 || 2 || 3 => const Color(0xFF95B1CE),
        >= 4 => const Color(0xFFE6C470),
        _ => null,
      };
}

@freezed
sealed class EquipmentImprove with _$EquipmentImprove {
  const factory EquipmentImprove({
    required String name,
    required List<EquipmentImproveData> data,
  }) = _EquipmentImprove;

  const EquipmentImprove._();

  String allShipNames(Map<int, String> shipMap, {weekday = 0}) {
    List<String> names = [];
    for (final data in this.data) {
      for (final req in data.req!.nonNulls) {
        if (weekday != 0 && !req.isAbleOn(weekday)) {
          continue;
        }
        final ships = req.shipNameList(shipMap);
        if (ships.isNotEmpty) {
          names.addAll(ships);
        }
      }
    }
    return names.toSet().join("|");
  }

  factory EquipmentImprove.fromData(
      ImproveItem data,
      Map<int, String> slotItemMap,
      Map<int, String> useItemMap,
      Map<int, String> shipMap) {
    final name = slotItemMap[data.id] ?? "SlotItem ${data.id}";
    List<EquipmentImproveData> list = [];
    if (data.improvement != null) {
      for (final improveData in data.improvement!) {
        if (improveData != null) {
          list.add(EquipmentImproveData.fromData(
              improveData, slotItemMap, useItemMap, shipMap));
        }
      }
    }
    return EquipmentImprove(name: name, data: list);
  }

  factory EquipmentImprove.fromJson(Map<String, dynamic> json) =>
      _$EquipmentImproveFromJson(json);
}

@freezed
sealed class EquipmentImproveData with _$EquipmentImproveData {
  const factory EquipmentImproveData({
    required String upgradeName,
    required ImproveResourceEntity resource,
    required List<ImproveReq>? req,
  }) = _EquipmentImproveData;

  factory EquipmentImproveData.fromData(
      ImproveData data,
      Map<int, String> slotItemMap,
      Map<int, String> useItemMap,
      Map<int, String> shipMap) {
    final resource = ImproveResourceEntity.fromData(data.resource!);
    if (data.upgrade == null) {
      return EquipmentImproveData(
          upgradeName: "",
          resource: resource,
          req: data.req!.nonNulls.toList());
    }
    final upgradeName =
        slotItemMap[data.upgrade?.id] ?? "SlotItem ${data.upgrade?.id}";
    return EquipmentImproveData(
        upgradeName: upgradeName,
        resource: resource,
        req: data.req!.nonNulls.toList());
  }

  factory EquipmentImproveData.fromJson(Map<String, dynamic> json) =>
      _$EquipmentImproveDataFromJson(json);
}

@freezed
sealed class ImproveResourceEntity with _$ImproveResourceEntity {
  const factory ImproveResourceEntity({
    required int oil,
    required int ammo,
    required int steel,
    required int bauxite,
    required List<ImproveResourceExtra> extra,
  }) = _ImproveResourceEntity;

  const ImproveResourceEntity._();

  factory ImproveResourceEntity.fromData(ImproveResource data) {
    final oil = data.base?[0] ?? 0;
    final ammo = data.base?[1] ?? 0;
    final steel = data.base?[2] ?? 0;
    final bauxite = data.base?[3] ?? 0;
    final extra = data.extra?.nonNulls.toList() ?? [];
    return ImproveResourceEntity(
        oil: oil, ammo: ammo, steel: steel, bauxite: bauxite, extra: extra);
  }

  factory ImproveResourceEntity.fromJson(Map<String, dynamic> json) =>
      _$ImproveResourceEntityFromJson(json);
}

@freezed
sealed class EquipmentCollection with _$EquipmentCollection {
  factory EquipmentCollection({
    required int id,
    required String name,
    required List<Equipment> equipments,
    required List<int> type,
    required int sortNo,
  }) = _EquipmentCollection;

  /// Returns a unique sort ID for the equipment collection.
  ///
  /// The sort ID is calculated by shifting the subType2 value 10 bits to the left
  /// and then performing a bitwise OR operation with the sortNo value.
  ///
  /// Biggest sortNo is 549(三式指揮連絡機改二) now, so 10 bits should be enough
  ///
  /// This allows for a unique sorting of equipment collections based on their
  /// subType2 and sortNo values.
  int get sortId => subType2 << 10 | sortNo;

  int get mainType => type.first;

  int get subType1 => type[1]; // 図鑑表示

  int get subType2 => type[2]; // api_mst_slotitem_equiptype

  int get subType3 => type[3]; // アイコンID

  int get subType4 => type[4]; // 航空機カテゴリ

  factory EquipmentCollection.fromJson(Map<String, dynamic> json) =>
      _$EquipmentCollectionFromJson(json);

  const EquipmentCollection._();

  String get levelMessage {
    final map = levelTotalView;
    final list = map.entries.toList();
    list.sort((a, b) => b.key.compareTo(a.key));
    if (list.isEmpty) return "";
    if (list.length == 1 && list[0].key == 0) return "";
    return list.map((e) => "★+${e.key}:${e.value}").join(" ");
  }

  Map<int, int> get levelTotalView {
    final map = <int, int>{};
    for (final equipment in equipments) {
      map[equipment.level!] = (map[equipment.level!] ?? 0) + 1;
    }
    return map;
  }

  Map<int, int> get proficiencyTotalView {
    final map = <int, int>{};
    for (final equipment in equipments) {
      map[equipment.proficiency!] = (map[equipment.proficiency!] ?? 0) + 1;
    }
    return map;
  }
}
