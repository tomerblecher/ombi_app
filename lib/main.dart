import 'dart:io';

import 'package:fimber_io/fimber_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:ocnera/services/local_settings.dart';
import 'package:ocnera/services/network/http_override.dart';
import 'package:ocnera/services/router.dart';
import 'package:ocnera/services/secure_storage_service.dart';
import 'package:ocnera/utils/logger.dart';
import 'package:ocnera/utils/theme.dart';
import 'package:path_provider/path_provider.dart';

class OcneraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    logger.d("MAIN APP");
    return MaterialApp(
      theme: AppTheme.theme(context),
      onGenerateRoute: generateRoute,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("config");
  await configureLogger();
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: AppTheme.APP_BACKGROUND.withOpacity(1),
  // ));

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white, // Color for Android
      statusBarBrightness:
          Brightness.dark // Dark == white status bar -- for IOS.
      ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  //Override default HttpClient to solve SSL problems.
  HttpOverrides.global = MyHttpOverrides();

  await secureStorage.init();
  await localSettings.init();

  runApp(OcneraApp());
}

Future<void> configureLogger() async {
  Fimber.plantTree(DebugTree());
  Directory extDir = await getApplicationDocumentsDirectory();
  String path = '${extDir.path}/${GlobalConfiguration().getValue('LOG_DIR')}';
  logger.i("Generating folder for local images $path");
  await Directory(path).create(recursive: true);
  deletePreviousFiles(path,
      fileCount: GlobalConfiguration().getValue("LOG_HISTORY_FILES"));
  var fileTree = TimedRollingFileTree(
      timeSpan: TimedRollingFileTree.dailyTime,
      filenamePrefix: '$path/appLog_',
      filenamePostfix: '.log',
      logLevels: ['I', 'W', 'E']);

  Fimber.plantTree(fileTree);
}

void deletePreviousFiles(String path, {int fileCount = 3}) {
  var logDir = Directory(path);
  var files = logDir.listSync();
  files.forEach((element) {
    if (shouldFileBeDeleted(element, fileCount)) {
      element.deleteSync();
    }
  });
}

bool shouldFileBeDeleted(FileSystemEntity file, int fileCount) {
  var fileStats = file.statSync();
  final now = DateTime.now();
  var date = fileStats.modified;
  if (now.difference(date).inHours >= fileCount) {
    return true;
  }

  return false;
}
