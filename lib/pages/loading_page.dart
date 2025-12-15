import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/utility_providers.dart';

class LoadingPage extends ConsumerWidget {
  const LoadingPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              const Spacer(),
              Image.asset('assets/icons/note_2.png', width: 140),
              const Spacer(),
              const CircularProgressIndicator(color: Colors.white),
              const Spacer(),
              const Spacer(),
              Text(
                ref.watch(localPackageInfoProvider).when(data: (data) => 'Version: $data', error: (_, __) => '', loading: () => 'Reading version information'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color.fromARGB(106, 122, 122, 122)),
              ),
              Text(
                ref.watch(storeVersionInfoProvider).when(data: (data) => 'New Version Available: $data', error: (_, __) => '', loading: () => ''),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color.fromARGB(106, 122, 122, 122)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
