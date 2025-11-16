import 'package:get_it/get_it.dart';
import 'package:voice_transscript/core/services/translation_service.dart';
import 'package:voice_transscript/core/services/tts_service.dart';
import 'package:voice_transscript/view_model/assistant_controller.dart';
import 'package:voice_transscript/view_model/connectivity_controller.dart';
import 'package:voice_transscript/view_model/pilgrim_controller.dart';
import 'package:voice_transscript/view_model/info_controller.dart';
import 'package:voice_transscript/view_model/navigation_controller.dart';
import 'package:voice_transscript/view_model/settings_controller.dart';
import 'package:voice_transscript/view_model/splash_controller.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton(() => TranslationService());
  sl.registerLazySingleton(() => TTSService());
  sl.registerLazySingleton(() => PilgrimController());
  sl.registerFactory(() => SplashController());
  sl.registerLazySingleton(() => ConnectivityController());
  sl.registerLazySingleton(() => NavigationController());
  sl.registerLazySingleton(() => AssistantController());
  sl.registerLazySingleton(() => InfoController());
  sl.registerLazySingleton(() => SettingsController());
}
