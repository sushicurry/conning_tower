import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'web_info.freezed.dart';


@freezed
sealed class WebInfo with _$WebInfo {
  const factory WebInfo({
    required String url,
    required List<Cookie> cookies,
    required int statusCode,
    required String title,
    Favicon? favicon,
}) = _WebInfo;
}
