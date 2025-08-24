import 'package:flutter/material.dart';

/// Custom primary button based on [ElevatedButton].
/// @param text - text to display on the button.
/// @param isLoading - if true, a loading indicator will be displayed instead of
/// the text.
/// @param onPressed - callback to be called when the button is pressed.
class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({
    super.key,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.onPressed,
    this.isBigButton = false,
  });

  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool isBigButton;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(colorScheme.primary),
      shadowColor: WidgetStateProperty.all<Color>(colorScheme.shadow),
      overlayColor: WidgetStateProperty.all<Color>(colorScheme.inversePrimary),
      foregroundColor: WidgetStateProperty.all<Color>(colorScheme.onPrimary),
      elevation: WidgetStateProperty.all<double>(0),
      padding:
          isBigButton
              ? WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.fromLTRB(17, 15, 17, 15),
              )
              : null,
      textStyle:
          isBigButton
              ? WidgetStateProperty.all<TextStyle>(
                Theme.of(context).textTheme.titleMedium!,
              )
              : null,
    );

    return icon == null
        ? ElevatedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: isLoading ? const CircularProgressIndicator() : Text(text),
        )
        : ElevatedButton.icon(
          icon: Icon(icon),
          onPressed: onPressed,
          label: Text(text),
          style: buttonStyle,
        );
  }
}
