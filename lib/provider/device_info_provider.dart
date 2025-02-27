import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localsend_app/model/device.dart';
import 'package:localsend_app/provider/network/server_provider.dart';
import 'package:localsend_app/provider/network_info_provider.dart';
import 'package:localsend_app/util/device_info_helper.dart';

final deviceRawInfoProvider = Provider<DeviceInfoResult>((ref) {
  throw Exception('settingsProvider not initialized');
});

final deviceInfoProvider = Provider((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  final serverState = ref.watch(serverProvider);
  final rawInfo = ref.watch(deviceRawInfoProvider);
  return Device(
    ip: networkInfo?.localIps.firstOrNull ?? '-',
    port: serverState?.port ?? -1,
    alias: serverState?.alias ?? '-',
    deviceModel: rawInfo.deviceModel,
    deviceType: rawInfo.deviceType,
  );
});
