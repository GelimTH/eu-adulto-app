class DatabaseException implements Exception {
  final String message;
  const DatabaseException([this.message = 'Erro de banco de dados.']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Registro não encontrado.']);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}
