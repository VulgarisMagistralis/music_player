import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/theme_colors.dart' show playerThemeProvider;

abstract class BasicErrorPage extends ConsumerStatefulWidget {
  final String message;
  final bool showNavigation;
  final Widget? actionWidget;
  const BasicErrorPage({super.key, this.message = 'We lost the beat...', this.actionWidget, this.showNavigation = false});
}

class BasicErrorPageState<T extends BasicErrorPage> extends ConsumerState<T> {
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ref.watch(playerThemeProvider),
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_off, size: 80, color: Colors.redAccent),
                const SizedBox(height: 20),
                Text(
                  widget.message,
                  style: const TextStyle(color: Color.fromARGB(255, 171, 35, 35), fontSize: 20),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    if (widget.actionWidget != null) ...[widget.actionWidget!, const SizedBox(height: 20)],
                    ElevatedButton.icon(
                      onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Exit'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
