extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  String beautifyFolderPath() {
    if (startsWith('/storage/emulated/0/')) {
      return replaceFirst('/storage/emulated/0/', 'Internal Storage/');
    } else if (startsWith('/storage/')) {
      return replaceFirst(RegExp(r'^/storage/[^/]+/'), 'SD Card/');
    }
    return this;
  }
}
