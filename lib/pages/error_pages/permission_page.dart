import 'package:flutter/material.dart';
import 'package:music_player/common/toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:music_player/pages/error_pages/basic_error_page.dart';

class PermissionErrorPage extends BasicErrorPage {
  PermissionErrorPage({super.key})
      : super(
            message: 'Permission required to continue',
            actionWidget: ElevatedButton.icon(
                onPressed: () async => await openAppSettings() ? null : ToastManager().showErrorToast('Could not open settings'),
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent)));
  @override
  ConsumerState<PermissionErrorPage> createState() => BasicErrorPageState<PermissionErrorPage>();
}
