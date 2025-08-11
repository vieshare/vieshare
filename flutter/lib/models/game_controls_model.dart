import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:get/get.dart';
import 'package:flutter_hbb/mobile/widgets/lol_controls.dart';
import 'package:flutter_hbb/consts.dart';

import 'model.dart';

enum GameMode {
  none,
  leagueOfLegends,
}

class GameControlsModel {
  final RxBool _isLoLMode = false.obs;
  final Rx<GameMode> _currentMode = GameMode.none.obs;
  final RxBool _autoDetectionEnabled = true.obs;
  
  OverlayEntry? _overlayEntry;
  Timer? _detectionTimer;
  final WeakReference<FFI> parent;

  GameControlsModel(this.parent) {
    _startAutoDetection();
  }

  bool get isLoLMode => _isLoLMode.value;
  GameMode get currentMode => _currentMode.value;
  RxBool get isLoLModeRx => _isLoLMode;
  bool get autoDetectionEnabled => _autoDetectionEnabled.value;

  void enableLoLMode() {
    _currentMode.value = GameMode.leagueOfLegends;
    _isLoLMode.value = true;
    _enableTouchMode();
  }

  void disableGameMode() {
    _currentMode.value = GameMode.none;
    _isLoLMode.value = false;
    _disableTouchMode();
  }

  void _enableTouchMode() {
    final ffi = parent.target;
    if (ffi != null) {
      // Simply enable touch mode - let the existing touch system handle taps
      if (!ffi.ffiModel.touchMode) {
        ffi.ffiModel.toggleTouchMode();
        bind.sessionPeerOption(
          sessionId: ffi.sessionId, 
          name: kOptionTouchMode, 
          value: 'Y'
        );
      }
    }
  }

  void _disableTouchMode() {
    // Don't automatically disable touch mode when disabling LoL controls
    // User can manually switch back to mouse mode if they want
  }

  void toggleLoLMode() {
    if (_isLoLMode.value) {
      disableGameMode();
    } else {
      enableLoLMode();
    }
  }

  void _startAutoDetection() {
    _detectionTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_autoDetectionEnabled.value) {
        _checkForLoLGame();
      }
    });
  }

  void _checkForLoLGame() {
    final ffi = parent.target;
    if (ffi == null) return;

    // Get window title or active application info
    // This is a simplified detection - in a real implementation,
    // you might want to check the remote desktop's active window title
    // For now, we'll use a mock detection
    _detectGameFromTitle();
  }

  void _detectGameFromTitle() {
    // Mock detection - you can enhance this to check actual window titles
    // from the remote desktop through FFI calls
    // For demonstration, this would be called when LoL is detected
    
    // Example: if window title contains "League of Legends" and not already in LoL mode
    // enableLoLMode();
    
    // Example: if window title doesn't contain game names and in LoL mode
    // disableGameMode();
  }

  void setAutoDetection(bool enabled) {
    _autoDetectionEnabled.value = enabled;
  }

  Widget? buildLoLOverlay() {
    final ffi = parent.target;
    if (ffi == null || !_isLoLMode.value) return null;
    
    return LoLControlsOverlay(
      ffi: ffi,
      onClose: () => disableGameMode(),
    );
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void dispose() {
    _detectionTimer?.cancel();
    _hideOverlay();
  }
}