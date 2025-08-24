import 'package:flutter/widgets.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations.dart';

//import 'localization/app_localizations.dart';
extension LocalizedBuildContext on BuildContext {
  AppLocalizations? get locale => AppLocalizations.of(this);
}
