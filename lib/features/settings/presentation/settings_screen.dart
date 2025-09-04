import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/responsive_scrollable.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/features/app/theme/app_theme_provider.dart';
import 'package:nopcommerce_mobile/features/settings/presentation/currency/currency_settings.dart';
import 'package:nopcommerce_mobile/features/settings/presentation/language/language_settings.dart';
import 'package:nopcommerce_mobile/features/settings/presentation/settings_providers.dart';
import 'package:nopcommerce_mobile/features/settings/presentation/tax/tax_settings.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const offset = SizedBox(height: 8.0);
    final items = <Widget>[];

    final languageSelector = ref.watch(languageSelectorProvider);
    final currencySelector = ref.watch(currencySelectorProvider);
    final taxTypeSelector = ref.watch(taxTypeSelectorProvider);
    bool darkTheme = ref.watch(appThemeStateProvider);
    /*items.add(
      AsyncValueWidget<LanguageSelectorModelDto?>(
        value: languageSelector,
        data:
            (languageSelector) => LanguageSettings(
              languageSelector: languageSelector!.toBuilder(),
            ),
      ),
    );
    items.add(offset);*/

    items.add(
      AsyncValueWidget<CurrencySelectorModelDto?>(
        value: currencySelector,
        data:
            (currencySelector) => CurrencySettings(
              currencySelector: currencySelector!.toBuilder(),
            ),
      ),
    );
    items.add(offset);

    items.add(
      AsyncValueWidget<TaxTypeSelectorModelDto?>(
        value: taxTypeSelector,
        data:
            (taxSelector) => TaxSettings(taxSelector: taxSelector!.toBuilder()),
      ),
    );
    items.add(offset);

    /* items.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            darkTheme
                ? context.locale!.auth_light_mode
                : context.locale!.auth_dark_mode,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: darkTheme,
            onChanged:
                (value) => {
                  ref
                      .read(appThemeStateProvider.notifier)
                      .toggleAppTheme(context, ref),
                },
          ),
        ],
      ),
    );

    items.add(offset); */

    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        backgroundColor: GlobalVariables.accentColor,
        title: Text(
          context.locale!.settings,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg5.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          ResponsiveScrollable(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items,
            ),
          ),
        ],
      )
    );
  }
}
