import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'utility_providers.g.dart';

@riverpod
Future<String> localPackageInfo(Ref ref) async => (await PackageInfo.fromPlatform()).version;
