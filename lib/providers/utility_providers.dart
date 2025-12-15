import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'utility_providers.g.dart';

@riverpod
Future<String?> storeVersionInfo(Ref ref) async => (await NewVersionPlus(androidId: 'com.cenkt.music_player').getVersionStatus())?.storeVersion;

@riverpod
Future<String> localPackageInfo(Ref ref) async => (await PackageInfo.fromPlatform()).version;
