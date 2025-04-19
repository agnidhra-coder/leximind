// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemma_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gemmaServiceHash() => r'9b87220c8001dca2118b6ec960ce5e10b9dfd171';

/// See also [gemmaService].
@ProviderFor(gemmaService)
final gemmaServiceProvider = AutoDisposeProvider<GemmaService>.internal(
  gemmaService,
  name: r'gemmaServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gemmaServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GemmaServiceRef = AutoDisposeProviderRef<GemmaService>;
String _$locationProcessorHash() => r'8519be4bfa9912296f1ab46f3b74da33ffbbec2a';

// /// See also [locationProcessor].
// @ProviderFor(locationProcessor)
// final locationProcessorProvider =
//     AutoDisposeProvider<LocationProcessor>.internal(
//       locationProcessor,
//       name: r'locationProcessorProvider',
//       debugGetCreateSourceHash:
//           const bool.fromEnvironment('dart.vm.product')
//               ? null
//               : _$locationProcessorHash,
//       dependencies: null,
//       allTransitiveDependencies: null,
//     );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
// typedef LocationProcessorRef = AutoDisposeProviderRef<LocationProcessor>;
String _$chatNotifierHash() => r'b351fe08fc17db237870a47bbeb34fa067b7a151';

/// See also [ChatNotifier].
@ProviderFor(ChatNotifier)
final chatNotifierProvider =
    AutoDisposeNotifierProvider<ChatNotifier, List<Message>>.internal(
      ChatNotifier.new,
      name: r'chatNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$chatNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatNotifier = AutoDisposeNotifier<List<Message>>;
String _$isLoadingHash() => r'd93ff819986049614e6c73bb8d08af430d333ac6';

/// See also [IsLoading].
@ProviderFor(IsLoading)
final isLoadingProvider = AutoDisposeNotifierProvider<IsLoading, bool>.internal(
  IsLoading.new,
  name: r'isLoadingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IsLoading = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
