import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});
  @override
  State<StatefulWidget> createState() => _LoadingState();
}

class _LoadingState extends State<LoadingPage> {
  String? storeVersion;
  Future<PackageInfo> readPackageInfo() async {
    try {
      final VersionStatus? versionStatus =
          await NewVersionPlus(androidId: 'com.cenkt.music_player')
              .getVersionStatus();
      storeVersion = versionStatus?.storeVersion;
    } catch (e) {
      /// optional
    }
    return await PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
              child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 24),
            const Spacer(),
            Image.asset('assets/icons/note_2.png', width: 140),
            const Spacer(),
            const CircularProgressIndicator(color: Colors.white),
            const Spacer(),
            FutureBuilder(
                future: readPackageInfo(),
                builder: (context, snapshot) => snapshot.connectionState ==
                            ConnectionState.done &&
                        snapshot.hasData
                    ? Text(
                        'Version: ${snapshot.data?.version} ${storeVersion != null ? '\n New Version Available: ${storeVersion!}' : ''}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(106, 122, 122, 122)))
                    : const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('Reading version information',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(106, 122, 122, 122)))))
          ])))));
}
