// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(PlayerRoute)
const playerRouteProvider = PlayerRouteProvider._();

final class PlayerRouteProvider
    extends $NotifierProvider<PlayerRoute, PlayerPageEnum> {
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
  Override overrideWithValue(PlayerPageEnum value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerPageEnum>(value),
    );
  }
}

String _$playerRouteHash() => r'fc4589896f47965e89af52548fc89dc86d4ef15b';

abstract class _$PlayerRoute extends $Notifier<PlayerPageEnum> {
  PlayerPageEnum build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PlayerPageEnum, PlayerPageEnum>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PlayerPageEnum, PlayerPageEnum>,
        PlayerPageEnum,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
