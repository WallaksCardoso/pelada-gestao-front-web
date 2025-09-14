import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Utils {
  static void showToast(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showLoading(BuildContext context, bool show) {
    if (show) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    } else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token") ?? "";
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
}
