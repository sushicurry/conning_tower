import 'package:conning_tower/models/data/kcsapi/kcsapi.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_info.freezed.dart';
part 'map_info.g.dart';

enum AreaType { normal, event }

@freezed
sealed class MapArea with _$MapArea {
  const factory MapArea({
    required int id,
    required String name,
    required List<MapInfo> map,
    required AreaType areaType,
  }) = _MapArea;

  factory MapArea.fromApi(GetDataApiDataApiMstMapareaEntity areaData,
      List<GetDataApiDataApiMstMapinfoEntity> mapData) {
    final map = [
      for (var data in mapData)
        if (data.apiMapareaId == areaData.apiId) MapInfo.fromApi(data)
    ];

    return MapArea(
      id: areaData.apiId,
      name: areaData.apiName,
      map: map,
      areaType: areaData.apiType == 0 ? AreaType.normal : AreaType.event,
    );
  }
}

@freezed
sealed class MapInfo with _$MapInfo {
  const MapInfo._();

  const factory MapInfo({
    required int id,
    required int num,
    required int areaId,
    required String name,
    required String operationName,
  }) = _MapInfo;

  factory MapInfo.fromApi(GetDataApiDataApiMstMapinfoEntity data) {
    return MapInfo(
      id: data.apiId,
      num: data.apiNo,
      areaId: data.apiMapareaId,
      name: data.apiName,
      operationName: data.apiOpetext,
    );
  }

  String get areaCode => areaId > 10 ? 'E' : '$areaId';

  factory MapInfo.fromJson(Map<String, dynamic> json) =>
      _$MapInfoFromJson(json);
}

@freezed
sealed class MapInfoLog with _$MapInfoLog {
  const factory MapInfoLog({
    required int id,
  }) = _MapInfoLog;

  factory MapInfoLog.fromJson(Map<String, dynamic> json) =>
      _$MapInfoLogFromJson(json);

  factory MapInfoLog.fromEntity(MapInfo mapInfo) => MapInfoLog(id: mapInfo.id);
}
