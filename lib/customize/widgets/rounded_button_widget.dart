import 'package:flutter/material.dart';

const rubikLight = TextStyle(
  fontFamily: 'Rubik',
  fontWeight: FontWeight.w300,
);

const rubikRegular = TextStyle(
  fontFamily: 'Rubik',
  fontWeight: FontWeight.w400,
);

const rubikMedium = TextStyle(
  fontFamily: 'Rubik',
  fontWeight: FontWeight.w500,
);

const rubikSemiBold = TextStyle(
  fontFamily: 'Rubik',
  fontWeight: FontWeight.w600,
);
class RoundedButtonWidget extends StatelessWidget {
  final String? buttonText;
  final Function? onTap;
  final bool isSkip;
  const RoundedButtonWidget({super.key, this.buttonText = '', this.onTap, this.isSkip = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeExtraLarge),
      ),
      child: CustomInkWellWidget(
        onTap: onTap as void Function()?,
        radius: Dimensions.radiusSizeExtraLarge,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: isSkip ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall),
          child: Text(
            buttonText!,
            style: rubikRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
      ),
    );
  }
}
class Dimensions {
  static const double fontSizeExtraSmall = 8.0;
  static const double fontSizeSmall = 10.0;
  static const double fontSizeDefault = 13.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeSemiLarge = 18.0;
  static const double fontSizeExtraLarge = 20.0;
  static const double fontSizeExtraOverLarge = 22.0;
  static const double fontSizeOverOverLarge = 28.0;

  static const double paddingSizeSuperExtraSmall = 2.0;
  static const double paddingSizeExtraSmall = 5.0;
  static const double paddingSizeSmall = 10.0;
  static const double paddingSizeDefault = 16.0;
  static const double paddingSizeLarge = 20.0;
  static const double paddingSizeExtraLarge = 25.0;
  static const double paddingSizeExtraExtraLarge = 32.0;
  static const double paddingSizeOverLarge = 45.0;
  static const double paddingSizeExtraOverLarge = 55.0;


  static const double radiusSizeVerySmall = 4.0;
  static const double radiusSizeExtraSmall = 8.0;
  static const double radiusSizeSmall = 12.0;
  static const double radiusSizeDefault = 16.0;
  static const double radiusSizeLarge = 20.0;
  static const double radiusSizeExtraLarge = 30.0;
  static const double radiusSizeExtraExtraLarge = 40.0;
  static const double radiusSizeOverLarge = 50.0;
  static const double radiusProfileAvatar = 25.0;


  static const double dividerSizeSmall = 1.0;
  static const double dividerSizeExtraSmall = 0.5;
  static const double dividerSizeMedium = 2.0;
  static const double dividerSizeLarge = 4.0;
  static const double dividerSizeExtraLarge = 4.0;

  static const double themeThreeTransactionCardWidth = 115.0;


}
class CustomInkWellWidget extends StatelessWidget {
  final double? radius;
  final Widget child;
  final VoidCallback? onTap;
  final Color? highlightColor;
  const CustomInkWellWidget({super.key, this.radius,required this.child,required this.onTap, this.highlightColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius??0.0),
        highlightColor: highlightColor ?? Theme.of(context).primaryColor.withValues(alpha:0.5),
        hoverColor: Theme.of(context).primaryColor,
        child: child,
      ),
    );
  }
}
