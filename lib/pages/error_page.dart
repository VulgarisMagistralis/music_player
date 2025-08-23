import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show SystemChannels;

class ErrorPage extends ConsumerStatefulWidget {
  final String? message;
  const ErrorPage({super.key, this.message});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ErrorPageState();
}

class _ErrorPageState extends ConsumerState<ErrorPage> {
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.music_off, size: 80, color: Colors.redAccent),
        const SizedBox(height: 20),
        Text(widget.message ?? 'We lost the beat...', style: const TextStyle(color: Color.fromARGB(255, 171, 35, 35), fontSize: 20)),
        const SizedBox(height: 10),
        ElevatedButton.icon(
            onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            icon: const Icon(Icons.exit_to_app_outlined),
            label: const Text('Exit'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent))
      ]));
}
