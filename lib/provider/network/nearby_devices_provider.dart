import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localsend_app/model/device.dart';
import 'package:localsend_app/model/dto/info_dto.dart';
import 'package:localsend_app/model/nearby_devices_state.dart';
import 'package:localsend_app/provider/dio_provider.dart';
import 'package:localsend_app/util/api_route_builder.dart';
import 'package:localsend_app/util/task_runner.dart';

final nearbyDevicesProvider = StateNotifierProvider<NearbyDevicesNotifier, NearbyDevicesState>((ref) {
  final dio = ref.watch(dioProvider(DioType.discovery));
  return NearbyDevicesNotifier(dio);
});

Map<String, TaskRunner> _runners = {};

class NearbyDevicesNotifier extends StateNotifier<NearbyDevicesState> {
  final Dio dio;
  NearbyDevicesNotifier(this.dio) : super(const NearbyDevicesState(runningIps: {}, devices: {}));

  Future<void> startScan({required int port, required String localIp}) async {
    if (state.runningIps.contains(localIp)) {
      // already running for the same localIp
      return;
    }

    state = state.copyWith(runningIps: {...state.runningIps, localIp});

    await _getStream(localIp, port).forEach((device) {
      state = state.copyWith(
        devices: {...state.devices}..update(device.ip, (_) => device, ifAbsent: () => device),
      );
    });

    state = state.copyWith(runningIps: state.runningIps.where((ip) => ip != localIp).toSet());
  }

  Stream<Device> _getStream(String localIp, int port) {
    final ipList = List.generate(256, (i) => '${localIp.split('.').take(3).join('.')}.$i').where((ip) => ip != localIp).toList();
    _runners[localIp]?.stop();
    _runners[localIp] = TaskRunner<Device?>(
      initialTasks: List.generate(
        ipList.length,
        (index) => () => _doRequest(dio, ipList[index], port),
      ),
      concurrency: 50,
    );

    return _runners[localIp]!.stream.where((device) => device != null).cast<Device>();
  }
}

Future<Device?> _doRequest(Dio dio, String currentIp, int port) async {
  print('Requesting $currentIp');
  final url = ApiRoute.info.targetRaw(currentIp, port);
  Device? device;
  try {
    final response = await dio.get(url);
    final dto = InfoDto.fromJson(response.data);
    device = dto.toDevice(currentIp, port);
  } on DioError catch (_) {
    device = null;
    // print('$url: ${e.error}');
  } catch (e) {
    device = null;
    // print(e);
  }
  return device;
}
