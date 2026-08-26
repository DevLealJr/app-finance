import 'package:dio/dio.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateService {
  // Altere para a URL onde seu JSON de versão e APK estão hospedados
  static const String _versionUrl = 'https://seu-servidor.com/version.json';

  static Future<void> checkAndInstallUpdate() async {
    try {
      if (kIsWeb ||
          defaultTargetPlatform != TargetPlatform.android ||
          _versionUrl.contains('seu-servidor.com')) {
        return;
      }
      final dio = Dio();

      // 1. Obtém a versão atual do app (definida no pubspec.yaml)
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // ex: "1.0.0"

      // 2. Busca a versão mais recente no servidor
      final response = await dio.get(_versionUrl);
      final data = response.data;
      if (data is! Map ||
          data['latest_version'] is! String ||
          data['apk_url'] is! String) {
        return;
      }
      final latestVersion = data['latest_version'] as String; // ex: "1.0.1"
      final apkUrl = data['apk_url'] as String;

      // 3. Se houver versão nova, faz o download e instala
      if (_isNewerVersion(latestVersion, currentVersion)) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/app-update.apk';

        // Download do novo APK
        await dio.download(apkUrl, filePath);

        // Dispara a instalação nativa do Android
        final FlutterAppInstaller appInstaller = FlutterAppInstaller();
        await appInstaller.installApk(filePath: filePath);
      }
    } catch (e) {
      // Trate erros de conexão ou permissão se necessário
      debugPrint('Erro ao verificar atualização: $e');
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    List<int>? parse(String version) {
      final parts = version.split('.');
      if (parts.length != 3) return null;
      final values = parts.map(int.tryParse).toList();
      return values.every((value) => value != null) ? values.cast<int>() : null;
    }

    final latestParts = parse(latest);
    final currentParts = parse(current);
    if (latestParts == null || currentParts == null) return false;
    for (var index = 0; index < latestParts.length; index++) {
      if (latestParts[index] != currentParts[index]) {
        return latestParts[index] > currentParts[index];
      }
    }
    return false;
  }
}
