// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(readFiles)
const readFilesProvider = ReadFilesFamily._();

final class ReadFilesProvider
    extends $FunctionalProvider<AsyncValue, Object?, Stream>
    with $FutureModifier<Object?>, $StreamProvider<Object?> {
  const ReadFilesProvider._(
      {required ReadFilesFamily super.from, required Directory super.argument})
      : super(
          retry: null,
          name: r'readFilesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$readFilesHash();

  @override
  String toString() {
    return r'readFilesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Object?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream create(Ref ref) {
    final argument = this.argument as Directory;
    return readFiles(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReadFilesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readFilesHash() => r'7c8275bd4c7e4dd6f81bf4e8e69a6948b8a4d483';

final class ReadFilesFamily extends $Family
    with $FunctionalFamilyOverride<Stream, Directory> {
  const ReadFilesFamily._()
      : super(
          retry: null,
          name: r'readFilesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ReadFilesProvider call(
    Directory musicDirectory,
  ) =>
      ReadFilesProvider._(argument: musicDirectory, from: this);

  @override
  String toString() => r'readFilesProvider';
}

@ProviderFor(readSongFileList)
const readSongFileListProvider = ReadSongFileListFamily._();

final class ReadSongFileListProvider extends $FunctionalProvider<
        AsyncValue<List<FileSystemEntity>>,
        List<FileSystemEntity>,
        FutureOr<List<FileSystemEntity>>>
    with
        $FutureModifier<List<FileSystemEntity>>,
        $FutureProvider<List<FileSystemEntity>> {
  const ReadSongFileListProvider._(
      {required ReadSongFileListFamily super.from,
      required List<String> super.argument})
      : super(
          retry: null,
          name: r'readSongFileListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$readSongFileListHash();

  @override
  String toString() {
    return r'readSongFileListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FileSystemEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<FileSystemEntity>> create(Ref ref) {
    final argument = this.argument as List<String>;
    return readSongFileList(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReadSongFileListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readSongFileListHash() => r'45d5b146895208939d81018ab86c6b8a1ff92293';

final class ReadSongFileListFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<FileSystemEntity>>,
            List<String>> {
  const ReadSongFileListFamily._()
      : super(
          retry: null,
          name: r'readSongFileListProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ReadSongFileListProvider call(
    List<String> musicDirectoryList,
  ) =>
      ReadSongFileListProvider._(argument: musicDirectoryList, from: this);

  @override
  String toString() => r'readSongFileListProvider';
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
