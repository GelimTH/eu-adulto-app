import '../../../../core/use_case/use_case.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserUseCase implements UseCaseNoParams<UserEntity?> {
  final UserRepository _repository;

  const GetUserUseCase(this._repository);

  @override
  Future<UserEntity?> call() async {
    return _repository.getUser();
  }
}
