// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get drawingHeader => 'Draw a Digit Below';

  @override
  String get resetBtn => 'Reset Drawing';

  @override
  String get showBtn => 'Show Mnemosyne';

  @override
  String get drawAgainBtn => 'Draw again';

  @override
  String finalResult(Object Digit) {
    return 'Mnemosyne sees a $Digit';
  }
}
