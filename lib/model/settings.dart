import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:localsend_app/gen/strings.g.dart';

part 'settings.freezed.dart';

@freezed
class Settings with _$Settings {
  const factory Settings({
    required String alias,
    required ThemeMode theme,
    required AppLocale? locale,
    required int port,
    required String? destination, // null = default
    required bool saveToGallery, // only Android, iOS
    required bool quickSave, // automatically accept file requests
    required bool minimizeToTray, // minimize to tray instead of exiting the app
    required bool launchAtStartup, // launch on start / login
    required bool launchMinimized, // start hidden in tray (only available when launchAtStartup is true)
  }) = _Settings;
}
