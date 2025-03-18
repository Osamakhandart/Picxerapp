//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:fiberchat/Configs/optional_constants.dart';
import 'package:fiberchat/Services/localization/demo_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: todo
//TODO:---- All localizations settings----
const String LAGUAGE_CODE = 'languageCode';

// languages code
const String ENGLISH = 'en';
const String CHINESE = 'zh';
const String SPANISH = 'es';
const String FRENCH = 'fr';
const String GERMAN = 'de';
const String JAPANESE = 'ja';
const String RUSSIAN = 'ru';
const String KOREAN = 'ko';
const String PORTUGUESE = 'pt';
const String ITALIAN = 'it';
const String DUTCH = 'nl';
const String SWEDISH = 'sv';
const String TURKISH = 'tr';
const String ARABIC = 'ar';
const String POLISH = 'pl';
const String THAI = 'th';
const String CZECH = 'cs';
const String HUNGARIAN = 'hu';
const String DANISH = 'da';
const String FINNISH = 'fi';
const String NORWEGIAN = 'no';
const String SLOVAK = 'sk';
const String GREEK = 'el';
const String ROMANIAN = 'ro';
const String INDONESIAN = 'id';
const String MALAY = 'ms';
const String VIETNAMESE = 'vi';
const String HINDI = 'hi';
const String HEBREW = 'he';
const String UKRAINIAN = 'uk';
const String CATALAN = 'ca';
const String CROATIAN = 'hr';
const String BULGARIAN = 'bg';
const String SERBIAN = 'sr';
const String LITHUANIAN = 'lt';
const String SLOVENIAN = 'sl';
const String LATVIAN = 'lv';
const String ESTONIAN = 'et';
const String ICELANDIC = 'is';
const String MALTESE = 'mt';

List languagelist = [
  ENGLISH,
  CHINESE,
  SPANISH,
  FRENCH,
  GERMAN,
  JAPANESE,
  RUSSIAN,
  KOREAN,
  PORTUGUESE,
  ITALIAN,
  DUTCH,
  SWEDISH,
  TURKISH,
  ARABIC,
  POLISH,
  THAI,
  CZECH,
  HUNGARIAN,
  DANISH,
  FINNISH,
  NORWEGIAN,
  SLOVAK,
  GREEK,
  ROMANIAN,
  INDONESIAN,
  MALAY,
  VIETNAMESE,
  HINDI,
  HEBREW,
  UKRAINIAN,
  CATALAN,
  CROATIAN,
  BULGARIAN,
  SERBIAN,
  LITHUANIAN,
  SLOVENIAN,
  LATVIAN,
  ESTONIAN,
  ICELANDIC,
  MALTESE
];
List<Locale> supportedlocale = [
  Locale(ENGLISH, 'US'),
  Locale(CHINESE, 'CN'),
  Locale(SPANISH, 'ES'),
  Locale(FRENCH, 'FR'),
  Locale(GERMAN, 'DE'),
  Locale(JAPANESE, 'JP'),
  Locale(RUSSIAN, 'RU'),
  Locale(KOREAN, 'KR'),
  Locale(PORTUGUESE, 'PT'),
  Locale(ITALIAN, 'IT'),
  Locale(DUTCH, 'NL'),
  Locale(SWEDISH, 'SE'),
  Locale(TURKISH, 'TR'),
  Locale(ARABIC, 'AE'),
  Locale(POLISH, 'PL'),
  Locale(THAI, 'TH'),
  Locale(CZECH, 'CZ'),
  Locale(HUNGARIAN, 'HU'),
  Locale(DANISH, 'DK'),
  Locale(FINNISH, 'FI'),
  Locale(NORWEGIAN, 'NO'),
  Locale(SLOVAK, 'SK'),
  Locale(GREEK, 'GR'),
  Locale(ROMANIAN, 'RO'),
  Locale(INDONESIAN, 'ID'),
  Locale(MALAY, 'MY'),
  Locale(VIETNAMESE, 'VN'),
  Locale(HINDI, 'IN'),
  Locale(HEBREW, 'IL'),
  Locale(UKRAINIAN, 'UA'),
  Locale(CATALAN, 'ES'), // Catalan uses the Spanish country code
  Locale(CROATIAN, 'HR'),
  Locale(BULGARIAN, 'BG'),
  Locale(SERBIAN, 'RS'),
  Locale(LITHUANIAN, 'LT'),
  Locale(SLOVENIAN, 'SI'),
  Locale(LATVIAN, 'LV'),
  Locale(ESTONIAN, 'EE'),
  Locale(ICELANDIC, 'IS'),
  Locale(MALTESE, 'MT')
];

Future<Locale> setLocale(String languageCode) async {
  // print(languageCode);
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  // print(LAGUAGE_CODE);
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode =
      _prefs.getString(LAGUAGE_CODE) ?? DEFAULT_LANGUAGE_FILE_CODE;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return Locale(ENGLISH, 'US');
    case CHINESE:
      return Locale(CHINESE, 'CN');
    case SPANISH:
      return Locale(SPANISH, 'ES');
    case FRENCH:
      return Locale(FRENCH, 'FR');
    case GERMAN:
      return Locale(GERMAN, 'DE');
    case JAPANESE:
      return Locale(JAPANESE, 'JP');
    case RUSSIAN:
      return Locale(RUSSIAN, 'RU');
    case KOREAN:
      return Locale(KOREAN, 'KR');
    case PORTUGUESE:
      return Locale(PORTUGUESE, 'PT');
    case ITALIAN:
      return Locale(ITALIAN, 'IT');
    case DUTCH:
      return Locale(DUTCH, 'NL');
    case SWEDISH:
      return Locale(SWEDISH, 'SE');
    case TURKISH:
      return Locale(TURKISH, 'TR');
    case ARABIC:
      return Locale(ARABIC, 'AE');
    case POLISH:
      return Locale(POLISH, 'PL');
    case THAI:
      return Locale(THAI, 'TH');
    case CZECH:
      return Locale(CZECH, 'CZ');
    case HUNGARIAN:
      return Locale(HUNGARIAN, 'HU');
    case DANISH:
      return Locale(DANISH, 'DK');
    case FINNISH:
      return Locale(FINNISH, 'FI');
    case NORWEGIAN:
      return Locale(NORWEGIAN, 'NO');
    case SLOVAK:
      return Locale(SLOVAK, 'SK');
    case GREEK:
      return Locale(GREEK, 'GR');
    case ROMANIAN:
      return Locale(ROMANIAN, 'RO');
    case INDONESIAN:
      return Locale(INDONESIAN, 'ID');
    case MALAY:
      return Locale(MALAY, 'MY');
    case VIETNAMESE:
      return Locale(VIETNAMESE, 'VN');
    case HINDI:
      return Locale(HINDI, 'IN');
    case HEBREW:
      return Locale(HEBREW, 'IL');
    case UKRAINIAN:
      return Locale(UKRAINIAN, 'UA');
    case CATALAN:
      return Locale(CATALAN, 'ES'); // Assuming Catalonia region of Spain
    case CROATIAN:
      return Locale(CROATIAN, 'HR');
    case BULGARIAN:
      return Locale(BULGARIAN, 'BG');
    case SERBIAN:
      return Locale(SERBIAN, 'RS');
    case LITHUANIAN:
      return Locale(LITHUANIAN, 'LT');
    case SLOVENIAN:
      return Locale(SLOVENIAN, 'SI');
    case LATVIAN:
      return Locale(LATVIAN, 'LV');
    case ESTONIAN:
      return Locale(ESTONIAN, 'EE');
    case ICELANDIC:
      return Locale(ICELANDIC, 'IS');
    case MALTESE:
      return Locale(MALTESE, 'MT');
    default:
      return Locale(ENGLISH, 'US');
  }
}

String getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context)!.translate(key) ?? '';
}
