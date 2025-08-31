import 'package:freezed_annotation/freezed_annotation.dart';

import 'req_combined_battle_result_entity.dart';

part 'req_sortie_battle_result_entity.freezed.dart';
part 'req_sortie_battle_result_entity.g.dart';

@unfreezed
sealed class ReqSortieBattleResultEntity with _$ReqSortieBattleResultEntity {
  static const source = "/api_req_sortie/battleresult";

  factory ReqSortieBattleResultEntity({
    @JsonKey(name: 'api_result') required int apiResult,
    @JsonKey(name: 'api_result_msg') required String apiResultMsg,
    @JsonKey(name: 'api_data')
    required ReqSortieBattleResultApiDataEntity apiData,
  }) = _ReqSortieBattleResultEntity;

  factory ReqSortieBattleResultEntity.fromJson(Map<String, dynamic> json) =>
      _$ReqSortieBattleResultEntityFromJson(json);
}

@unfreezed
sealed class ReqSortieBattleResultApiDataEntity
    with _$ReqSortieBattleResultApiDataEntity {
  factory ReqSortieBattleResultApiDataEntity({
    @JsonKey(name: 'api_ship_id') required List<int> apiShipId,
    @JsonKey(name: 'api_win_rank') required String apiWinRank,
    @JsonKey(name: 'api_get_exp') required int apiGetExp,
    @JsonKey(name: 'api_mvp') required int apiMvp,
    @JsonKey(name: 'api_member_lv') required int apiMemberLv,
    @JsonKey(name: 'api_member_exp') required int apiMemberExp,
    @JsonKey(name: 'api_get_base_exp') required int apiGetBaseExp,
    @JsonKey(name: 'api_get_ship_exp') required List<int> apiGetShipExp,
    @JsonKey(name: 'api_get_exp_lvup') required List<dynamic> apiGetExpLvup,
    @JsonKey(name: 'api_dests') required int apiDests,
    @JsonKey(name: 'api_destsf') required int apiDestsf,
    @JsonKey(name: 'api_quest_name') required String apiQuestName,
    @JsonKey(name: 'api_quest_level') required int apiQuestLevel,
    @JsonKey(name: 'api_enemy_info')
    required BattleResultEnemyInfoEntity apiEnemyInfo,
    @JsonKey(name: 'api_first_clear') required int apiFirstClear,
    @JsonKey(name: 'api_mapcell_incentive') required int apiMapcellIncentive,
    @JsonKey(name: 'api_get_flag') List<int>? apiGetFlag,
    @JsonKey(name: 'api_get_ship') BattleResultGetShipEntity? apiGetShip,
    ReqSortieBattleResultApiDataApiGetUseitemEntity? apiGetUseitem,
    @JsonKey(name: 'api_get_eventflag') int? apiGetEventflag,
    @JsonKey(name: 'api_get_exmap_rate') dynamic apiGetExmapRate,
    @JsonKey(name: 'api_get_exmap_useitem_id') dynamic apiGetExmapUseitemId,
    @JsonKey(name: 'api_escape_flag') int? apiEscapeFlag,
    @JsonKey(name: 'api_escape') BattleResultEscapeEntity? apiEscape,
    @JsonKey(name: 'api_m2') int? apiM2,
  }) = _ReqSortieBattleResultApiDataEntity;

  factory ReqSortieBattleResultApiDataEntity.fromJson(
          Map<String, dynamic> json) =>
      _$ReqSortieBattleResultApiDataEntityFromJson(json);
}

@unfreezed
sealed class ReqSortieBattleResultApiDataApiGetUseitemEntity
    with _$ReqSortieBattleResultApiDataApiGetUseitemEntity {
  factory ReqSortieBattleResultApiDataApiGetUseitemEntity({
    @JsonKey(name: 'api_useitem_id') int? apiUseitemId,
    @JsonKey(name: 'api_useitem_name') String? apiUseitemName,
  }) = _ReqSortieBattleResultApiDataApiGetUseitemEntity;

  factory ReqSortieBattleResultApiDataApiGetUseitemEntity.fromJson(
          Map<String, dynamic> json) =>
      _$ReqSortieBattleResultApiDataApiGetUseitemEntityFromJson(json);
}
