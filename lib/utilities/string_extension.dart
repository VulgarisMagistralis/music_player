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

  String get camelCaseToSpaced {
    final withSpaces = toString().split('.').last.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}');
    return withSpaces[0].toLowerCase() + withSpaces.substring(1).toLowerCase();
  }

  String get reverseWordOrder => trim().split(RegExp(r'\s+')).reversed.join(' ');
}
