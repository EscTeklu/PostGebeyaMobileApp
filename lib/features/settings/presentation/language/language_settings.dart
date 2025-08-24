import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/features/app/locale/app_locale_provider.dart';
import 'package:nopcommerce_mobile/features/settings/presentation/settings_providers.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class LanguageSettings extends ConsumerStatefulWidget {
  const LanguageSettings({super.key, required this.languageSelector});

  final LanguageSelectorModelDtoBuilder languageSelector;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<LanguageSettings> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      languageControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.locale!.settings_language,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white38),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  dropdownColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  value: widget.languageSelector.currentLanguageId,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[900],
                  ),
                  isExpanded: true,
                  itemHeight: null,
                  style: Theme.of(context).textTheme.bodyMedium,
                  items:
                      widget.languageSelector.availableLanguages
                          .build()
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [Text(item.name ?? "")],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (int? value) async {
                    //cnange locale
                    var locale =
                        widget.languageSelector.availableLanguages
                            .build()
                            .where((languageModel) => languageModel.id == value)
                            .first;

                    ref
                        .read(appLocaleStateProvider.notifier)
                        .toggleAppLocale(
                          context,
                          ref,
                          locale.name!.toLowerCase(),
                        );

                    //send to server
                    final controller = ref.read(
                      languageControllerProvider.notifier,
                    );
                    await controller.setLanguage(
                      widget.languageSelector.currentLanguageId ?? 0,
                    );

                    setState(() {
                      widget.languageSelector.currentLanguageId = value!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
