class AppConfig {
  String baseUrl = "";
  static AppConfig shared = AppConfig.create();

  factory AppConfig.create({String baseUrl = ""}) {
    return shared = AppConfig(baseUrl);
  }

  AppConfig(this.baseUrl);
}
