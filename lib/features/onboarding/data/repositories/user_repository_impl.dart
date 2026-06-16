import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDatasource _datasource;

  const UserRepositoryImpl(this._datasource);

  @override
  Future<UserEntity?> getUser() async {
    return _datasource.getUser();
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    await _datasource.saveUser(UserModel.fromEntity(user));
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await _datasource.updateUser(UserModel.fromEntity(user));
  }

  @override
  Future<bool> hasUser() async {
    return _datasource.hasUser();
  }
}
