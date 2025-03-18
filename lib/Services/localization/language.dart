//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

// ignore: todo
//TODO:---- All localizations settings----

class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;
  final String languageNameInEnglish;

  Language(this.id, this.flag, this.name, this.languageCode,
      this.languageNameInEnglish);

  static List<Language> languageList() {
    //list changed by JH:
    return <Language>[
      Language(1, "🇺🇸", "English", "en", "English"),
      Language(2, "🇨🇳", "Chinese", "zh", "Chinese"),
      Language(3, "🇪🇸", "Spanish", "es", "Spanish"),
      Language(4, "🇫🇷", "French", "fr", "French"),
      Language(5, "🇩🇪", "German", "de", "German"),
      Language(6, "🇯🇵", "Japanese", "ja", "Japanese"),
      Language(7, "🇷🇺", "Russian", "ru", "Russian"),
      Language(8, "🇰🇷", "Korean", "ko", "Korean"),
      Language(9, "🇵🇹", "Portuguese", "pt", "Portuguese"),
      Language(10, "🇮🇹", "Italian", "it", "Italian"),
      Language(11, "🇳🇱", "Dutch", "nl", "Dutch"),
      Language(12, "🇸🇪", "Swedish", "sv", "Swedish"),
      Language(13, "🇹🇷", "Turkish", "tr", "Turkish"),
      Language(14, "🇸🇦", "Arabic", "ar", "Arabic"),
      Language(15, "🇵🇱", "Polish", "pl", "Polish"),
      Language(16, "🇹🇭", "Thai", "th", "Thai"),
      Language(17, "🇨🇿", "Czech", "cs", "Czech"),
      Language(18, "🇭🇺", "Hungarian", "hu", "Hungarian"),
      Language(19, "🇩🇰", "Danish", "da", "Danish"),
      Language(20, "🇫🇮", "Finnish", "fi", "Finnish"),
      Language(21, "🇳🇴", "Norwegian", "no", "Norwegian"),
      Language(22, "🇸🇰", "Slovak", "sk", "Slovak"),
      Language(23, "🇬🇷", "Greek", "el", "Greek"),
      Language(24, "🇷🇴", "Romanian", "ro", "Romanian"),
      Language(25, "🇮🇩", "Indonesian", "id", "Indonesian"),
      Language(26, "🇲🇾", "Malay", "ms", "Malay"),
      Language(27, "🇻🇳", "Vietnamese", "vi", "Vietnamese"),
      Language(28, "🇮🇳", "Hindi", "hi", "Hindi"),
      Language(29, "🇮🇱", "Hebrew", "he", "Hebrew"),
      Language(30, "🇺🇦", "Ukrainian", "uk", "Ukrainian"),
      Language(31, "🇪🇸", "Catalan", "ca", "Catalan"),
      Language(32, "🇭🇷", "Croatian", "hr", "Croatian"),
      Language(33, "🇧🇬", "Bulgarian", "bg", "Bulgarian"),
      Language(34, "🇷🇸", "Serbian", "sr", "Serbian"),
      Language(35, "🇱🇹", "Lithuanian", "lt", "Lithuanian"),
      Language(36, "🇸🇮", "Slovenian", "sl", "Slovenian"),
      Language(37, "🇱🇻", "Latvian", "lv", "Latvian"),
      Language(38, "🇪🇪", "Estonian", "et", "Estonian"),
      Language(39, "🇮🇸", "Icelandic", "is", "Icelandic"),
      Language(40, "🇲🇹", "Maltese", "mt", "Maltese")
    ];
  }
}
