import 'dart:math';
import 'dart:ui';

import 'package:conning_tower/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'joystick_provider.freezed.dart';

part 'joystick_provider.g.dart';

@freezed
sealed class JoystickState with _$JoystickState {
  factory JoystickState(
      {required bool enable,
      required JoystickDir joystickDir,
      required Map<JoystickAct, FunctionName> actFuncMap}) = _JoystickState;
}

@riverpod
class Joystick extends _$Joystick {
  @override
  JoystickState build() {
    final Map<JoystickAct, FunctionName> actFuncMap = {
      JoystickAct.doubleClick: FunctionName.none,
      JoystickAct.dragDown: FunctionName.naviDashboard,
      JoystickAct.dragUp: FunctionName.screenShot,
      JoystickAct.dragRight: FunctionName.toolBox,
      JoystickAct.dragLeft: FunctionName.hideControls,
      JoystickAct.longTouch: FunctionName.none
    };
    return JoystickState(
        enable: true, joystickDir: JoystickDir.center, actFuncMap: actFuncMap);
  }

  void onTouchEnd(Map<FunctionName, Function> functionMap) {
    runFunction(functionMap, "drag");
  }

  void updateState(Offset delta) {
    if (delta.dx <= -45.0) {
      if (-5.0 <= delta.dy && delta.dy <= 5.0)  {
        debugPrint('Left');
        changeDir(JoystickDir.left);
      }
    } else if (delta.dy >= 45.0) {
      if (-5.0 <= delta.dx && delta.dx <= 5.0) {
        debugPrint('Down');
        changeDir(JoystickDir.down);
      }
    } else if (delta.dx >= 45.0) {
      if (-5.0 <= delta.dy && delta.dy <= 5.0)  {
        debugPrint('Right');
        changeDir(JoystickDir.right);
      }
    } else if (delta.dy <= -40.0) {
      if (-5.0 <= delta.dx && delta.dx <= 5.0) {
        debugPrint('Up');
        changeDir(JoystickDir.up);
      }
    }
    // double angle = delta.direction;
    //
    // if (angle >= -3 * pi / 4 && angle <= -pi / 4) {
    //   // debugPrint('Up');
    //   changeDir(JoystickDir.up);
    // } else if (angle >= pi / 4 && angle <= 3 * pi / 4) {
    //   // debugPrint('Down');
    //   changeDir(JoystickDir.down);
    // } else if (angle > -pi / 4 && angle < pi / 4) {
    //   // debugPrint('Right');
    //   changeDir(JoystickDir.right);
    // } else {
    //   // if (details.delta.dx < -8) {
    //   //   // Swipe left to hide controls
    //   //   showControls = false;
    //   //   widget.notifyParent();
    //   // }
    //   // debugPrint('Left');
    //   changeDir(JoystickDir.left);
    // }
  }

  void changeDir(JoystickDir joystickDir) {
    state = state.copyWith(joystickDir: joystickDir);
  }

  void runFunction(Map<FunctionName, Function> functionMap, String actType) {
    if (actType == "drag") {
      var funcMap = state.actFuncMap;
      switch (state.joystickDir) {
        case JoystickDir.up:
          functionMap[funcMap[JoystickAct.dragUp]]!();
          break;
        case JoystickDir.down:
          functionMap[funcMap[JoystickAct.dragDown]]!();
          break;
        case JoystickDir.left:
          functionMap[funcMap[JoystickAct.dragLeft]]!();
          break;
        case JoystickDir.right:
          functionMap[funcMap[JoystickAct.dragRight]]!();
          break;
        case JoystickDir.center:
          functionMap[FunctionName.none]!();
          break;
      }
    } else if (actType == "doubleClick") {
      functionMap[FunctionName.none]!();
    } else if (actType == "longTouch") {
      functionMap[FunctionName.none]!();
    }
  }
}
