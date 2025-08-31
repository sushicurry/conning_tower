import 'package:conning_tower/models/data/kcsapi/deck_data.dart';
import 'package:conning_tower/models/data/kcsapi/ship_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'port_entity.freezed.dart';

part 'port_entity.g.dart';

@unfreezed
sealed class PortEntity with _$PortEntity {
  factory PortEntity({
    @JsonKey(name: 'api_result') required int apiResult,
    @JsonKey(name: 'api_result_msg') required String apiResultMsg,
    @JsonKey(name: 'api_data') required PortApiDataEntity apiData,
  }) = _PortEntity;

  static const source = "/api_port/port";

  factory PortEntity.fromJson(Map<String, dynamic> json) =>
      _$PortEntityFromJson(json);
}

@unfreezed
sealed class PortApiDataEntity with _$PortApiDataEntity {
  factory PortApiDataEntity({
    @JsonKey(name: 'api_event_object')
    PortApiDataApiEventObjectEntity? apiEventObject,
    @JsonKey(name: 'api_material')
    required List<PortApiDataApiMaterialEntity> apiMaterial,
    @JsonKey(name: 'api_deck_port')
    required List<PortApiDataApiDeckPortEntity> apiDeckPort,
    @JsonKey(name: 'api_ndock')
    required List<PortApiDataApiNdockEntity> apiNdock,
    @JsonKey(name: 'api_ship') required List<ShipDataEntity> apiShip,
    @JsonKey(name: 'api_basic') required PortApiDataApiBasicEntity apiBasic,
    @JsonKey(name: 'api_log') required List<PortApiDataApiLogEntity> apiLog,
    @JsonKey(name: 'api_combined_flag') int? apiCombinedFlag,
    @JsonKey(name: 'api_p_bgm_id') required int apiPBgmId,
    @JsonKey(name: 'api_parallel_quest_count')
    required int apiParallelQuestCount,
    // @JsonKey(name: 'api_dest_ship_slot') required int apiDestShipSlot,
    // @JsonKey(name: 'api_c_flags') List<int>? apiCFlags,
  }) = _PortApiDataEntity;

  factory PortApiDataEntity.fromJson(Map<String, dynamic> json) =>
      _$PortApiDataEntityFromJson(json);
}

@unfreezed
sealed class PortApiDataApiEventObjectEntity with _$PortApiDataApiEventObjectEntity {
  factory PortApiDataApiEventObjectEntity({
    @JsonKey(name: 'api_c_num') int? apiCNum,
    @JsonKey(name: 'api_m_flag') int? apiMFlag,
    @JsonKey(name: 'api_m_flag2') int? apiMFlag2,
  }) = _PortApiDataApiEventObjectEntity;

  factory PortApiDataApiEventObjectEntity.fromJson(Map<String, dynamic> json) =>
      _$PortApiDataApiEventObjectEntityFromJson(json);
}

@unfreezed
sealed class PortApiDataApiMaterialEntity with _$PortApiDataApiMaterialEntity {
  factory PortApiDataApiMaterialEntity({
    @JsonKey(name: 'api_member_id') required int apiMemberId,
    @JsonKey(name: 'api_id') required int apiId,
    @JsonKey(name: 'api_value') required int apiValue,
  }) = _PortApiDataApiMaterialEntity;

  factory PortApiDataApiMaterialEntity.fromJson(Map<String, dynamic> json) =>
      _$PortApiDataApiMaterialEntityFromJson(json);
}

@unfreezed
sealed class PortApiDataApiDeckPortEntity
    with _$PortApiDataApiDeckPortEntity
    implements DeckData {
  factory PortApiDataApiDeckPortEntity({
    @JsonKey(name: 'api_member_id') required int apiMemberId,
    @JsonKey(name: 'api_id') required int apiId,
    @JsonKey(name: 'api_name') required String apiName,
    @JsonKey(name: 'api_name_id') required String apiNameId,
    @JsonKey(name: 'api_mission') required List<int> apiMission,
    @JsonKey(name: 'api_flagship') required String apiFlagship,
    @JsonKey(name: 'api_ship') required List<int> apiShip,
  }) = _PortApiDataApiDeckPortEntity;

  factory PortApiDataApiDeckPortEntity.fromJson(Map<String, dynamic> json) =>
      _$PortApiDataApiDeckPortEntityFromJson(json);
}

@unfreezed
sealed class PortApiDataApiNdockEntity with _$PortApiDataApiNdockEntity {
  factory PortApiDataApiNdockEntity({
    @JsonKey(name: 'api_member_id') required int apiMemberId,
    @JsonKey(name: 'api_id') required int apiId,
    @JsonKey(name: 'api_state') required int apiState,
    @JsonKey(name: 'api_ship_id') required int apiShipId,
    @JsonKey(name: 'api_complete_time') required int apiCompleteTime,
    @JsonKey(name: 'api_complete_time_str') required String apiCompleteTimeStr,
    @JsonKey(name: 'api_item1') required int apiItem1,
    @JsonKey(name: 'api_item2') required int apiItem2,
    @JsonKey(name: 'api_item3') required int apiItem3,
    @JsonKey(name: 'api_item4') required int apiItem4,
  }) = _PortApiDataApiNdockEntity;

  factory PortApiDataApiNdockEntity.fromJson(Map<String, dynamic> json) =>
      _$PortApiDataApiNdockEntityFromJson(json);
}

@unfreezed
sealed class PortApiDataApiBasicEntity with _$PortApiDataApiBasicEntity {
  factory PortApiDataApiBasicEntity({
    @JsonKey(name: 'api_member_id') required String apiMemberId,
    @JsonKey(name: 'api_nickname') required String apiNickname,
    @JsonKey(name: 'api_nickname_id') required String apiNicknameId,
    @JsonKey(name: 'api_active_flag') required int apiActiveFlag,
    @JsonKey(name: 'api_starttime') required int apiStarttime,
    @JsonKey(name: 'api_level') required int apiLevel,
    @JsonKey(name: 'api_rank') required int apiRank,
    @JsonKey(name: 'api_experience') required int apiExperience,
    @JsonKey(name: 'api_fleetname') required dynamic apiFleetname,
    @JsonKey(name: 'api_comment') required String apiComment,
    @JsonKey(name: 'api_comment_id') required String apiCommentId,
    @JsonKey(name: 'api_max_chara') required int apiMaxChara,
    @JsonKey(name: 'api_max_slotitem') required int apiMaxSlotitem,
    @JsonKey(name: 'api_max_kagu') required int apiMaxKagu,
    @JsonKey(name: 'api_playtime') required int apiPlaytime,
    @JsonKey(name: 'api_tutorial') required int apiTutorial,
    @JsonKey(name: 'api_furniture') required List<int> apiFurniture,
    @JsonKey(name: 'api_count_deck') required int apiCountDeck,
    @JsonKey(name: 'api_count_kdock') required int apiCountKdock,
    @JsonKey(name: 'api_count_ndock') required int apiCountNdock,
    @JsonKey(name: 'api_fcoin') required int apiFcoin,
    @JsonKey(name: 'api_st_win') required int apiStWin,
    @JsonKey(name: 'api_st_lose') required int apiStLose,
    @JsonKey(name: 'api_ms_count') required int apiMsCount,
    @JsonKey(name: 'api_ms_success') required int apiMsSuccess,
    @JsonKey(name: 'api_pt_win') required int apiPtWin,
    @JsonKey(name: 'api_pt_lose') required int apiPtLose,
    @JsonKey(name: 'api_pt_challenged') required int apiPtChallenged,
    @JsonKey(name: 'api_pt_challenged_win') required int apiPtChallengedWin,
    @JsonKey(name: 'api_firstflag') required int apiFirstflag,
    @JsonKey(name: 'api_tutorial_progress') required int apiTutorialProgress,
    @JsonKey(name: 'api_pvp') required List<int> apiPvp,
    @JsonKey(name: 'api_medals') required int apiMedals,
    @JsonKey(name: 'api_large_dock') required int apiLargeDock,
  }) = _PortApiDataApiBasicEntity;

  factory PortApiDataApiBasicEntity.fromJson(Map<String, dynamic> json) =>
      _$PortApiDataApiBasicEntityFromJson(json);
}

@unfreezed
sealed class PortApiDataApiLogEntity with _$PortApiDataApiLogEntity {
  factory PortApiDataApiLogEntity({
    @JsonKey(name: 'api_no') required int apiNo,
    @JsonKey(name: 'api_type') required String apiType,
    @JsonKey(name: 'api_state') required String apiState,
    @JsonKey(name: 'api_message') required String apiMessage,
  }) = _PortApiDataApiLogEntity;

  factory PortApiDataApiLogEntity.fromJson(Map<String, dynamic> json) =>
      _$PortApiDataApiLogEntityFromJson(json);
}
