enum CustomActionMode {
  repeatMode,
  shuffleMode;

  static CustomActionMode? getCustomActionOrNull(String action) {
    if (action == repeatMode.name) return repeatMode;
    if (action == shuffleMode.name) return shuffleMode;
    return null;
  }
}
