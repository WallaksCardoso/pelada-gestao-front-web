import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String mensagem;
  final int codigo;
  final bool sessaoExpirada;

  const ApiException(this.mensagem, this.codigo, {this.sessaoExpirada = false});

  @override
  String toString() => mensagem;
}

class Api {
  static const _storage = FlutterSecureStorage();

  static Future<void> salvarToken(String token) =>
      _storage.write(key: "token", value: token);

  static Future<void> sair() => _storage.delete(key: "token");

  static Future<String?> usuarioLogado() async {
    final token = await _storage.read(key: "token");
    if (token == null) return null;
    try {
      final payload = base64Url.normalize(token.split(".")[1]);
      return jsonDecode(utf8.decode(base64Url.decode(payload)))["sub"];
    } catch (_) {
      return null;
    }
  }

  static Future<dynamic> get(String url) =>
      _enviar((cabecalhos) => http.get(Uri.parse(url), headers: cabecalhos));

  static Future<dynamic> post(String url, Map<String, dynamic> corpo) =>
      _enviar(
        (cabecalhos) => http.post(
          Uri.parse(url),
          headers: cabecalhos,
          body: jsonEncode(corpo),
        ),
      );

  static Future<dynamic> delete(String url) =>
      _enviar((cabecalhos) => http.delete(Uri.parse(url), headers: cabecalhos));

  static Future<dynamic> _enviar(
    Future<http.Response> Function(Map<String, String>) requisicao,
  ) async {
    final token = await _storage.read(key: "token");
    final cabecalhos = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final http.Response res;
    try {
      res = await requisicao(cabecalhos);
    } on http.ClientException {
      throw const ApiException("Não foi possível falar com o servidor.", 0);
    }

    final corpo = _decodificar(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return corpo;
    final mensagem = _mensagemDoServidor(corpo);
    if (mensagem != null) throw ApiException(mensagem, res.statusCode);
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw ApiException(
        "Sua sessão expirou. Entre novamente.",
        res.statusCode,
        sessaoExpirada: true,
      );
    }
    throw ApiException("Não foi possível concluir a operação.", res.statusCode);
  }

  static dynamic _decodificar(http.Response res) {
    if (res.bodyBytes.isEmpty) return null;
    final texto = utf8.decode(res.bodyBytes);
    try {
      return jsonDecode(texto);
    } catch (_) {
      return texto;
    }
  }

  static String? _mensagemDoServidor(dynamic corpo) {
    if (corpo is! Map) return null;
    final mensagem =
        corpo["mensagem"] ??
        corpo.values.firstWhere((v) => v is String, orElse: () => null);
    return mensagem is String && mensagem.isNotEmpty ? mensagem : null;
  }
}
