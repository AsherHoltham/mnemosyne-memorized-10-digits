// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get drawingHeader => 'Dibuja un Dígito a Continuación';

  @override
  String get resetBtn => 'Restablecer Dibujo';

  @override
  String get showBtn => 'Enséñaselo a Mnemosyne';

  @override
  String get drawAgainBtn => 'Dibujar de nuevo';

  @override
  String finalResult(Object Digit) {
    return 'Mnemosyne ve una $Digit';
  }
}
