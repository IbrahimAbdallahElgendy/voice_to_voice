class LanguageModel {
  final String code;
  final String name;
  final String flag;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class Languages {
  static const List<LanguageModel> all = [
    LanguageModel(code: 'en', name: 'English', flag: '🇬🇧'),
    LanguageModel(code: 'ar', name: 'العربية', flag: '🇸🇦'),
    LanguageModel(code: 'ur', name: 'اردو', flag: '🇵🇰'),
    LanguageModel(code: 'id', name: 'Bahasa', flag: '🇮🇩'),
    LanguageModel(code: 'bn', name: 'বাংলা', flag: '🇧🇩'),
    LanguageModel(code: 'tr', name: 'Türkçe', flag: '🇹🇷'),
  ];

  static LanguageModel? getByCode(String code) {
    try {
      return all.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }
}

