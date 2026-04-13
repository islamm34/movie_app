

import 'entities/user_entity.dart';
import '../domain/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  UserEntity? execute() {
    return repository.currentUser;
  }
}