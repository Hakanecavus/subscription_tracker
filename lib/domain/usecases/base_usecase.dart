
import 'package:subscription_tracker/core/utils/result.dart';

/// Base UseCase class for all use cases
/// [Type] - The return type
/// [Params] - The parameter type
abstract class BaseUseCase<Type, Params> {
  const BaseUseCase();

  /// Executes the use case
  Future<Result<Type>> call(Params params);
}

/// UseCase without parameters
abstract class NoParamsUseCase<Type> extends BaseUseCase<Type, void> {
  const NoParamsUseCase();

  /// Executes the use case without parameters
  Future<Result<Type>> execute() => call(null);

  @override
  Future<Result<Type>> call(void params);
}

/// UseCase with single parameter
abstract class SingleParamUseCase<Type, Param> extends BaseUseCase<Type, Param> {
  const SingleParamUseCase();

  /// Executes with single parameter
  Future<Result<Type>> execute(Param param) => call(param);
}

/// UseCase with optional parameters
abstract class OptionalParamsUseCase<Type, Params> extends BaseUseCase<Type, Params?> {
  const OptionalParamsUseCase();

  /// Executes with optional parameters
  Future<Result<Type>> execute([Params? params]) => call(params);
}

/// Params base class for type safety
abstract class Params {
  const Params();
}

/// Use this class for use cases that don't require parameters
class NoParams extends Params {
  const NoParams();
}

/// Pagination params
class PaginationParams extends Params {
  final int page;
  final int limit;

  const PaginationParams({
    this.page = 1,
    this.limit = 20,
  });

  int get offset => (page - 1) * limit;
}

/// Date range params
class DateRangeParams extends Params {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRangeParams({
    this.startDate,
    this.endDate,
  });
}

/// ID params
class IdParams extends Params {
  final String id;

  const IdParams(this.id);
}

/// Search params
class SearchParams extends Params {
  final String query;
  final int? limit;
  final int? offset;

  const SearchParams({
    required this.query,
    this.limit,
    this.offset,
  });
}
