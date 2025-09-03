import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/menu/nav_bar.dart' show PlayerNavigationBar;

abstract class BasicErrorPage extends ConsumerStatefulWidget {
  final String message;
  final bool showNavigation;
  final Widget? actionWidget;
  const BasicErrorPage({super.key, this.message = 'We lost the beat...', this.actionWidget, this.showNavigation = false});
}

class BasicErrorPageState<T extends BasicErrorPage> extends ConsumerState<T> {
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          bottomNavigationBar: widget.showNavigation ? const PlayerNavigationBar() : null,
          body: SafeArea(
              child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.music_off, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            Expanded(child: Text(widget.message, style: const TextStyle(color: Color.fromARGB(255, 171, 35, 35), fontSize: 20), overflow: TextOverflow.visible, softWrap: true)),
            const SizedBox(height: 10),
            Column(children: [
              widget.actionWidget == null
                  ? ElevatedButton.icon(
                      onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Exit'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent))
                  : widget.actionWidget!,
              const SizedBox(height: 10)
            ])
          ])))));
}
