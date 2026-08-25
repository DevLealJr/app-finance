import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateService {
  // Altere para a URL onde seu JSON de versão e APK estão hospedados
  static const String _versionUrl = 'https://seu-servidor.com/version.json';

  static Future<void> checkAndInstallUpdate() async {
    try {
      final dio = Dio();
      
      // 1. Obtém a versão atual do app (definida no pubspec.yaml)
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // ex: "1.0.0"

      // 2. Busca a versão mais recente no servidor
      final response = await dio.get(_versionUrl);
      final latestVersion = response.data['latest_version']; // ex: "1.0.1"
      final apkUrl = response.data['apk_url'];

      // 3. Se houver versão nova, faz o download e instala
      if (latestVersion != currentVersion) {
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
      print('Erro ao verificar atualização: $e');
    }
  }
}