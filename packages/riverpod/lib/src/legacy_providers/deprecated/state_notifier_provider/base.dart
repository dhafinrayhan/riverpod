part of '../state_notifier_provider.dart';

/// {@macro riverpod.provider_ref_base}
abstract class StateNotifierProviderRef<NotifierT extends StateNotifier<T>, T>
    implements Ref<T> {
  /// The [StateNotifier] currently exposed by this provider.
  ///
  /// Cannot be accessed while creating the provider.
  NotifierT get notifier;
}

/// {@template riverpod.statenotifierprovider}
/// Creates a [StateNotifier] and exposes its current state.
///
/// This provider is used in combination with `package:state_notifier`.
///
/// Combined with [StateNotifier], [StateNotifierProvider] can be used to manipulate
/// advanced states, that would otherwise be difficult to represent with simpler
/// providers such as [Provider] or [FutureProvider].
///
/// For example, you may have a todo-list, where you can add and remove
/// and complete a todo.
/// Using [StateNotifier], you could represent such state as:
///
/// ```dart
/// class TodosNotifier extends StateNotifier<List<Todo>> {
///   TodosNotifier(): super([]);
///
///   void add(Todo todo) {
///     state = [...state, todo];
///   }
///
///   void remove(String todoId) {
///     state = [
///       for (final todo in state)
///         if (todo.id != todoId) todo,
///     ];
///   }
///
///   void toggle(String todoId) {
///     state = [
///       for (final todo in state)
///         if (todo.id == todoId) todo.copyWith(completed: !todo.completed),
///     ];
///   }
/// }
/// ```
///
/// Which you can then pass to a [StateNotifierProvider] like so:
///
/// ```dart
/// final todosProvider = StateNotifierProvider<TodosNotifier, List<Todo>>((ref) => TodosNotifier());
/// ```
///
/// And finally, you can interact with it inside your UI:
///
/// ```dart
/// Widget build(BuildContext context, WidgetRef ref) {
///   // rebuild the widget when the todo list changes
///   List<Todo> todos = ref.watch(todosProvider);
///
///   return ListView(
///     children: [
///       for (final todo in todos)
///         CheckboxListTile(
///            value: todo.completed,
///            // When tapping on the todo, change its completed status
///            onChanged: (value) => ref.read(todosProvider.notifier).toggle(todo.id),
///            title: Text(todo.description),
///         ),
///     ],
///   );
/// }
/// ```
/// {@endtemplate}
class StateNotifierProvider<NotifierT extends StateNotifier<T>, T>
    extends _StateNotifierProviderBase<NotifierT, T> {
  /// {@macro riverpod.statenotifierprovider}
  StateNotifierProvider(
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
  StateNotifierProvider.internal(
    this._createFn, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    super.from,
    super.argument,
  });

  /// {@macro riverpod.autoDispose}
  static const autoDispose = AutoDisposeStateNotifierProviderBuilder();

  /// {@macro riverpod.family}
  static const family = StateNotifierProviderFamilyBuilder();

  final NotifierT Function(StateNotifierProviderRef<NotifierT, T> ref)
      _createFn;

  @override
  NotifierT _create(StateNotifierProviderElement<NotifierT, T> ref) {
    return _createFn(ref);
  }

  @override
  StateNotifierProviderElement<NotifierT, T> createElement(
    ProviderContainer container,
  ) {
    return StateNotifierProviderElement._(this, container);
  }

  @override
  late final Refreshable<NotifierT> notifier = _notifier(this);

  /// {@macro riverpod.override_with}
  Override overrideWith(
    Create<NotifierT, StateNotifierProviderRef<NotifierT, T>> create,
  ) {
    return ProviderOverride(
      origin: this,
      providerOverride: StateNotifierProvider<NotifierT, T>.internal(
        create,
        from: from,
        argument: argument,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        name: null,
      ),
    );
  }
}

/// The element of [StateNotifierProvider].
class StateNotifierProviderElement<NotifierT extends StateNotifier<T>, T>
    extends ProviderElementBase<T>
    implements StateNotifierProviderRef<NotifierT, T> {
  StateNotifierProviderElement._(this.provider, super.container);

  @override
  final _StateNotifierProviderBase<NotifierT, T> provider;

  @override
  NotifierT get notifier => _notifierNotifier.value;
  final _notifierNotifier = ProxyElementValueNotifier<NotifierT>();

  void Function()? _removeListener;

  @override
  void create({required bool didChangeDependency}) {
    final notifier =
        _notifierNotifier.result = Result.guard(() => provider._create(this));

    _removeListener = notifier
        // TODO test requireState, as ref.read(p) is expected to throw if notifier creation failed
        .requireState
        .addListener(setState, fireImmediately: true);
  }

  @override
  bool updateShouldNotify(T previous, T next) {
    // TODO test that updateShouldNotify is applied
    return _notifierNotifier.result!.requireState
        // ignore: invalid_use_of_protected_member
        .updateShouldNotify(previous, next);
  }

  @override
  void runOnDispose() {
    super.runOnDispose();

    _removeListener?.call();
    _removeListener = null;

    final notifier = _notifierNotifier.result?.stateOrNull;
    if (notifier != null) {
      // TODO test STateNotifier.dispose is guarded
      runGuarded(notifier.dispose);
    }
    _notifierNotifier.result = null;
  }

  @override
  void visitChildren({
    required void Function(ProviderElementBase<Object?> element) elementVisitor,
    required void Function(ProxyElementValueNotifier<Object?> element)
        notifierVisitor,
  }) {
    super.visitChildren(
      elementVisitor: elementVisitor,
      notifierVisitor: notifierVisitor,
    );
    notifierVisitor(_notifierNotifier);
  }
}

/// The [Family] of [StateNotifierProvider].
class StateNotifierProviderFamily<NotifierT extends StateNotifier<T>, T, Arg>
    extends FamilyBase<StateNotifierProviderRef<NotifierT, T>, T, Arg,
        NotifierT, StateNotifierProvider<NotifierT, T>> {
  /// The [Family] of [StateNotifierProvider].
  StateNotifierProviderFamily(
    super._createFn, {
    super.name,
    super.dependencies,
  }) : super(
          providerFactory: StateNotifierProvider.internal,
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
          debugGetCreateSourceHash: null,
        );

  /// {@macro riverpod.override_with}
  Override overrideWith(
    NotifierT Function(StateNotifierProviderRef<NotifierT, T> ref, Arg arg)
        create,
  ) {
    return FamilyOverride(
      from: this,
      createElement: (container, provider) {
        provider as StateNotifierProvider<NotifierT, T>;

        return StateNotifierProvider<NotifierT, T>.internal(
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
