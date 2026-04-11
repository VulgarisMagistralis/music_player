const String _artworkAuthority = 'com.cenkt.music_player.artwork';

String getThumbnailUri(String filePath) => Uri(scheme: 'content', host: _artworkAuthority, path: filePath).toString();
