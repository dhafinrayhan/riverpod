part of '../future_provider.dart';

/// {@macro riverpod.provider_ref_base}
/// - [state], the value currently exposed by this provider.
abstract class FutureProviderRef<State> implements Ref<AsyncValue<State>> {
  /// Obtains the state currently exposed by this provider.
  ///
  /// Mutating this property will notify the provider listeners.
  ///
  /// Cannot be called while a provider is creating, unless the setter was called first.
  ///
  /// Will return [AsyncLoading] if used during the first initialization.
  /// Subsequent initializations will contain an [AsyncValue] with the previous
  /// state and [AsyncValueX.isRefreshing]/[AsyncValueX.isReloading] set accordingly.
  AsyncValue<State> get state;
  set state(AsyncValue<State> newState);

  /// Obtains the [Future] associated to this provider.
  ///
  /// This is equivalent to doing `ref.read(myProvider.future)`.
  /// See also [FutureProvider.future].
  Future<State> get future;
}

/// {@macro riverpod.future_provider}
class FutureProvider<T> extends _FutureProviderBase<T> {
  /// {@macro riverpod.future_provider}
  FutureProvider(
    this._createFn, {
    super.name,
    super.dependencies,
  }) : super(
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
          from: null,
          argument: null,
          debugGetCreateSourceHash: null,
        );

  /// An implementation detail of Riverpod
  @internal
  FutureProvider.internal(
    this._createFn, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    super.from,
    super.argument,
  });

  /// {@macro riverpod.autoDispose}
  static const autoDispose = AutoDisposeFutureProviderBuilder();

  /// {@macro riverpod.family}
  static const family = FutureProviderFamilyBuilder();

  final Create<FutureOr<T>, FutureProviderRef<T>> _createFn;

  @override
  late final Refreshable<Future<T>> future = _future(this);

  @override
  FutureOr<T> _create(FutureProviderElement<T> ref) => _createFn(ref);

  @override
  FutureProviderElement<T> createElement(ProviderContainer container) {
    return FutureProviderElement(this, container);
  }

  /// {@macro riverpod.override_with}
  Override overrideWith(Create<FutureOr<T>, FutureProviderRef<T>> create) {
    return ProviderOverride(
      origin: this,
      providerOverride: FutureProvider.internal(
        create,
        from: from,
        argument: argument,
        debugGetCreateSourceHash: null,
        dependencies: null,
        allTransitiveDependencies: null,
        name: null,
      ),
    );
  }
}

/// The element of a [FutureProvider]
class FutureProviderElement<T> extends ProviderElementBase<AsyncValue<T>>
    with FutureHandlerProviderElementMixin<T>
    implements FutureProviderRef<T> {
  /// The element of a [FutureProvider]
  @internal
  FutureProviderElement(this.provider, super.container);

  @override
  final _FutureProviderBase<T> provider;

  @override
  Future<T> get future {
    flush();
    return futureNotifier.value;
  }

  @override
  void create({required bool didChangeDependency}) {
    handleFuture(
      () => provider._create(this),
      didChangeDependency: didChangeDependency,
    );
  }
}

/// The [Family] of a [FutureProvider]
class FutureProviderFamily<R, Arg> extends FamilyBase<FutureProviderRef<R>,
    AsyncValue<R>, Arg, FutureOr<R>, FutureProvider<R>> {
  /// The [Family] of a [FutureProvider]
  FutureProviderFamily(
    super._createFn, {
    super.name,
    super.dependencies,
  }) : super(
          providerFactory: FutureProvider<R>.internal,
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
          debugGetCreateSourceHash: null,
        );

  /// Implementation detail of the code-generator.
  @internal
  FutureProviderFamily.generator(
    super._createFn, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
  }) : super(providerFactory: FutureProvider<R>.internal);

  /// {@macro riverpod.override_with}
  Override overrideWith(
    FutureOr<R> Function(FutureProviderRef<R> ref, Arg arg) create,
  ) {
    return FamilyOverride(
      from: this,
      createElement: (container, provider) {
        provider as FutureProvider<R>;

        return FutureProvider<R>.internal(
          (ref) => create(ref, provider.argument as Arg),
          from: provider.from,
          argument: provider.argument,
          dependencies: null,
          allTransitiveDependencies: null,
          debugGetCreateSourceHash: null,
          name: null,
        ).createElement(container);
      },
    );
  }
}
