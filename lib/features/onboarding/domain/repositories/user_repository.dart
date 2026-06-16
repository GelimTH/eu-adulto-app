import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUser();
  Future<void> saveUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Future<bool> hasUser();
}
