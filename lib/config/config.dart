class AppConfig {
  static const String apiAuthBase = String.fromEnvironment(
    'API_AUTH',
    defaultValue: 'http://localhost:8081',
  );
  static const String apiPeladaBase = String.fromEnvironment(
    'API_PELADA',
    defaultValue: 'http://localhost:8080',
  );

  static const String apiAuth = '$apiAuthBase/api/auth';
  static const String apiPessoas = '$apiAuthBase/api/pessoas';
  static const String apiSorteios = '$apiPeladaBase/api';
}
