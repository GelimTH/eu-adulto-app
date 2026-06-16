import '../../../../core/use_case/use_case.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class SaveUserUseCase implements UseCase<void, UserEntity> {
  final UserRepository _repository;

  const SaveUserUseCase(this._repository);

  @override
  Future<void> call(UserEntity params) async {
    final exists = await _repository.hasUser();
    if (exists) {
      await _repository.updateUser(params);
    } else {
      await _repository.saveUser(params);
    }
  }
}
