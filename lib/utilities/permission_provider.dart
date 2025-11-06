import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'permission_provider.g.dart';

@Riverpod(keepAlive: false)
class PermissionNotifier extends _$PermissionNotifier {
  @override
  Future<PermissionStatus> build() async => await Permission.audio.status;
  Future<void> checkPermission() async => state = AsyncData(await Permission.audio.status);
  Future<void> requestPermission() async => state = AsyncData(await Permission.audio.request());
}
