import 'package:riverpod/src/framework.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'async.g.dart';

@riverpod
Future<List<T>> generic<T extends num>(GenericRef<T> ref) async {
  return <T>[];
}

@riverpod
class GenericClass<T extends num> extends _$GenericClass<T> {
  @override
  Future<List<T>> build() async {
    return <T>[];
  }
}

@riverpod
FutureOr<String> public(PublicRef ref) {
  return 'Hello world';
}

const privateProvider = _privateProvider;

@riverpod
Future<String> _private(_PrivateRef ref) async {
  return 'Hello world';
}

@riverpod
FutureOr<String> familyOr(FamilyOrRef ref, int first) {
  return '(first: $first)';
}

@riverpod
Future<String> family(
  FamilyRef ref,
  int first, {
  String? second,
  required double third,
  bool fourth = true,
  List<String>? fifth,
}) async {
  return '(first: $first, second: $second, third: $third, fourth: $fourth, fifth: $fifth)';
}

@riverpod
class PublicClass extends _$PublicClass {
  PublicClass([this.param]);

  final Object? param;

  @override
  FutureOr<String> build() {
    return 'Hello world';
  }
}

final privateClassProvider = _privateClassProvider;

@riverpod
class _PrivateClass extends _$PrivateClass {
  @override
  Future<String> build() async {
    return 'Hello world';
  }
}

@riverpod
class FamilyOrClass extends _$FamilyOrClass {
  @override
  FutureOr<String> build(int first) {
    return '(first: $first)';
  }
}

@riverpod
class FamilyClass extends _$FamilyClass {
  FamilyClass([this.param]);

  final Object? param;

  @override
  Future<String> build(
    int first, {
    String? second,
    required double third,
    bool fourth = true,
    List<String>? fifth,
  }) async {
    return '(first: $first, second: $second, third: $third, fourth: $fourth, fifth: $fifth)';
  }
}
