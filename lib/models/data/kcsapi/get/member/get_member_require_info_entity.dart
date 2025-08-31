import 'package:conning_tower/models/data/kcsapi/item_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'get_member_useitem_entity.dart';

part 'get_member_require_info_entity.freezed.dart';

part 'get_member_require_info_entity.g.dart';

@unfreezed
sealed class GetMemberRequireInfoEntity with _$GetMemberRequireInfoEntity {
  static const source = '/api_get_member/require_info';

  factory GetMemberRequireInfoEntity({
    @JsonKey(name: 'api_result') required int apiResult,
    @JsonKey(name: 'api_result_msg') required String apiResultMsg,
    @JsonKey(name: 'api_data')
    required GetMemberRequireInfoApiDataEntity apiData,
  }) = _GetMemberRequireInfoEntity;

  factory GetMemberRequireInfoEntity.fromJson(Map<String, dynamic> json) =>
      _$GetMemberRequireInfoEntityFromJson(json);
}

@unfreezed
sealed class GetMemberRequireInfoApiDataEntity
    with _$GetMemberRequireInfoApiDataEntity {
  factory GetMemberRequireInfoApiDataEntity({
    @JsonKey(name: 'api_basic')
    required GetMemberRequireInfoApiDataApiBasicEntity apiBasic,
    @JsonKey(name: 'api_slot_item')
    List<GetMemberRequireInfoApiDataApiSlotItemEntity>? apiSlotItem,
    @JsonKey(name: 'api_unsetslot') dynamic apiUnsetslot,
    @JsonKey(name: 'api_kdock')
    List<GetMemberRequireInfoApiDataApiKdockEntity>? apiKdock,
    @JsonKey(name: 'api_useitem')
    List<GetMemberUseitemApiDataEntity>? apiUseitem,
    @JsonKey(name: 'api_furniture')
    List<GetMemberRequireInfoApiDataApiFurnitureEntity>? apiFurniture,
    @JsonKey(name: 'api_extra_supply') List<int>? apiExtraSupply,
    @JsonKey(name: 'api_oss_setting')
    GetMemberRequireInfoApiDataApiOssSettingEntity? apiOssSetting,
    @JsonKey(name: 'api_skin_id') required int apiSkinId,
    @JsonKey(name: 'api_position_id') required int apiPositionId,
  }) = _GetMemberRequireInfoApiDataEntity;

  factory GetMemberRequireInfoApiDataEntity.fromJson(
          Map<String, dynamic> json) =>
      _$GetMemberRequireInfoApiDataEntityFromJson(json);
}

@unfreezed
sealed class GetMemberRequireInfoApiDataApiBasicEntity
    with _$GetMemberRequireInfoApiDataApiBasicEntity {
  factory GetMemberRequireInfoApiDataApiBasicEntity({
    @JsonKey(name: 'api_member_id') required int apiMemberId,
    @JsonKey(name: 'api_firstflag') required int apiFirstflag,
  }) = _GetMemberRequireInfoApiDataApiBasicEntity;

  factory GetMemberRequireInfoApiDataApiBasicEntity.fromJson(
          Map<String, dynamic> json) =>
      _$GetMemberRequireInfoApiDataApiBasicEntityFromJson(json);
}

@unfreezed
sealed class GetMemberRequireInfoApiDataApiSlotItemEntity
    with _$GetMemberRequireInfoApiDataApiSlotItemEntity
    implements SlotItem {
  factory GetMemberRequireInfoApiDataApiSlotItemEntity({
    @JsonKey(name: 'api_id') required int apiId,
    @JsonKey(name: 'api_slotitem_id') required int apiSlotitemId,
    @JsonKey(name: 'api_locked') required int apiLocked,
    @JsonKey(name: 'api_level') required int apiLevel,
    @JsonKey(name: 'api_alv') int? apiAlv,
  }) = _GetMemberRequireInfoApiDataApiSlotItemEntity;

  factory GetMemberRequireInfoApiDataApiSlotItemEntity.fromJson(
          Map<String, dynamic> json) =>
      _$GetMemberRequireInfoApiDataApiSlotItemEntityFromJson(json);
}

@unfreezed
sealed class GetMemberRequireInfoApiDataApiKdockEntity
    with _$GetMemberRequireInfoApiDataApiKdockEntity {
  factory GetMemberRequireInfoApiDataApiKdockEntity({
    @JsonKey(name: 'api_id') required int apiId,
    @JsonKey(name: 'api_state') required int apiState,
    @JsonKey(name: 'api_created_ship_id') required int apiCreatedShipId,
    @JsonKey(name: 'api_complete_time') required int apiCompleteTime,
    @JsonKey(name: 'api_complete_time_str') required String apiCompleteTimeStr,
    @JsonKey(name: 'api_item1') required int apiItem1,
    @JsonKey(name: 'api_item2') required int apiItem2,
    @JsonKey(name: 'api_item3') required int apiItem3,
    @JsonKey(name: 'api_item4') required int apiItem4,
    @JsonKey(name: 'api_item5') required int apiItem5,
  }) = _GetMemberRequireInfoApiDataApiKdockEntity;

  factory GetMemberRequireInfoApiDataApiKdockEntity.fromJson(
          Map<String, dynamic> json) =>
      _$GetMemberRequireInfoApiDataApiKdockEntityFromJson(json);
}

@unfreezed
sealed class GetMemberRequireInfoApiDataApiFurnitureEntity
    with _$GetMemberRequireInfoApiDataApiFurnitureEntity {
  factory GetMemberRequireInfoApiDataApiFurnitureEntity({
    @JsonKey(name: 'api_id') required int apiId,
    @JsonKey(name: 'api_furniture_type') required int apiFurnitureType,
    @JsonKey(name: 'api_furniture_no') required int apiFurnitureNo,
    @JsonKey(name: 'api_furniture_id') required int apiFurnitureId,
  }) = _GetMemberRequireInfoApiDataApiFurnitureEntity;

  factory GetMemberRequireInfoApiDataApiFurnitureEntity.fromJson(
          Map<String, dynamic> json) =>
      _$GetMemberRequireInfoApiDataApiFurnitureEntityFromJson(json);
}

@unfreezed
sealed class GetMemberRequireInfoApiDataApiOssSettingEntity
    with _$GetMemberRequireInfoApiDataApiOssSettingEntity {
  factory GetMemberRequireInfoApiDataApiOssSettingEntity({
    @JsonKey(name: 'api_language_type') required int apiLanguageType,
    @JsonKey(name: 'api_oss_items') List<int>? apiOssItems,
  }) = _GetMemberRequireInfoApiDataApiOssSettingEntity;

  factory GetMemberRequireInfoApiDataApiOssSettingEntity.fromJson(
          Map<String, dynamic> json) =>
      _$GetMemberRequireInfoApiDataApiOssSettingEntityFromJson(json);
}
