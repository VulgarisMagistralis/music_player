// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(PlayerRoute)
const playerRouteProvider = PlayerRouteProvider._();

final class PlayerRouteProvider
    extends $NotifierProvider<PlayerRoute, PlayerRouteEnum> {
  const PlayerRouteProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'playerRouteProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$playerRouteHash();

  @$internal
  @override
  PlayerRoute create() => PlayerRoute();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerRouteEnum value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerRouteEnum>(value),
    );
  }
}

String _$playerRouteHash() => r'4d548feac13547231cea51eecc083cf9783af8e3';

abstract class _$PlayerRoute extends $Notifier<PlayerRouteEnum> {
  PlayerRouteEnum build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PlayerRouteEnum, PlayerRouteEnum>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PlayerRouteEnum, PlayerRouteEnum>,
        PlayerRouteEnum,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
