import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('am')
  ];

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get account;

  /// No description provided for @account_add_new_address.
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get account_add_new_address;

  /// No description provided for @account_address.
  ///
  /// In en, this message translates to:
  /// **'My addresses'**
  String get account_address;

  /// No description provided for @account_address_button_add.
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get account_address_button_add;

  /// No description provided for @account_address_no_found.
  ///
  /// In en, this message translates to:
  /// **'No addresses'**
  String get account_address_no_found;

  /// No description provided for @account_back_in_stock_dismissed.
  ///
  /// In en, this message translates to:
  /// **'dismissed'**
  String get account_back_in_stock_dismissed;

  /// No description provided for @account_back_in_stock_subscriptions.
  ///
  /// In en, this message translates to:
  /// **'My back in stock subscriptions'**
  String get account_back_in_stock_subscriptions;

  /// No description provided for @account_back_in_stock_subscriptions_no_found.
  ///
  /// In en, this message translates to:
  /// **'You are not currently subscribed to any Back In Stock notification lists'**
  String get account_back_in_stock_subscriptions_no_found;

  /// No description provided for @account_change_password.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get account_change_password;

  /// No description provided for @account_change_password_button.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get account_change_password_button;

  /// No description provided for @account_change_password_changed.
  ///
  /// In en, this message translates to:
  /// **'Password was changed'**
  String get account_change_password_changed;

  /// No description provided for @account_change_password_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get account_change_password_confirm;

  /// No description provided for @account_change_password_new.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get account_change_password_new;

  /// No description provided for @account_change_password_old.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get account_change_password_old;

  /// No description provided for @account_downloadable_products.
  ///
  /// In en, this message translates to:
  /// **'My downloadable products'**
  String get account_downloadable_products;

  /// No description provided for @account_downloadable_products_button_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get account_downloadable_products_button_download;

  /// No description provided for @account_downloadable_products_button_download_not.
  ///
  /// In en, this message translates to:
  /// **'n/a'**
  String get account_downloadable_products_button_download_not;

  /// No description provided for @account_downloadable_products_button_order_details.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get account_downloadable_products_button_order_details;

  /// No description provided for @account_downloadable_products_message_completed.
  ///
  /// In en, this message translates to:
  /// **'Download completed'**
  String get account_downloadable_products_message_completed;

  /// No description provided for @account_downloadable_products_message_failed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get account_downloadable_products_message_failed;

  /// No description provided for @account_downloadable_products_no_found.
  ///
  /// In en, this message translates to:
  /// **'There are no downloadable products'**
  String get account_downloadable_products_no_found;

  /// No description provided for @account_downloadable_products_order_date.
  ///
  /// In en, this message translates to:
  /// **'Order date: '**
  String get account_downloadable_products_order_date;

  /// No description provided for @account_downloadable_products_order_number.
  ///
  /// In en, this message translates to:
  /// **'Order #%s'**
  String get account_downloadable_products_order_number;

  /// No description provided for @account_downloadable_products_user_agreement.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get account_downloadable_products_user_agreement;

  /// No description provided for @account_downloadable_products_user_agreement_agree.
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get account_downloadable_products_user_agreement_agree;

  /// No description provided for @account_downloadable_products_user_agreement_donot_agree.
  ///
  /// In en, this message translates to:
  /// **'I don\'t agree'**
  String get account_downloadable_products_user_agreement_donot_agree;

  /// No description provided for @account_edit_address.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get account_edit_address;

  /// No description provided for @account_gdpr_tools.
  ///
  /// In en, this message translates to:
  /// **'GDPR tools'**
  String get account_gdpr_tools;

  /// No description provided for @account_gdpr_tools_right_title.
  ///
  /// In en, this message translates to:
  /// **'Right to be Forgotten'**
  String get account_gdpr_tools_right_title;

  /// No description provided for @account_gdpr_tools_right_text.
  ///
  /// In en, this message translates to:
  /// **'You can use the button below to remove your personal and other data from our store. Keep in mind that this process will delete your account, so you will no longer be able to access or use it anymore.'**
  String get account_gdpr_tools_right_text;

  /// No description provided for @account_gdpr_tools_right_button.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get account_gdpr_tools_right_button;

  /// No description provided for @account_info.
  ///
  /// In en, this message translates to:
  /// **'My account info'**
  String get account_info;

  /// No description provided for @account_info_company.
  ///
  /// In en, this message translates to:
  /// **'Company details'**
  String get account_info_company;

  /// No description provided for @account_info_company_name.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get account_info_company_name;

  /// No description provided for @account_info_company_vat.
  ///
  /// In en, this message translates to:
  /// **'VAT number'**
  String get account_info_company_vat;

  /// No description provided for @account_info_contact.
  ///
  /// In en, this message translates to:
  /// **'Сontact information'**
  String get account_info_contact;

  /// No description provided for @account_info_contact_fax.
  ///
  /// In en, this message translates to:
  /// **'Fax'**
  String get account_info_contact_fax;

  /// No description provided for @account_info_contact_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get account_info_contact_phone;

  /// No description provided for @account_info_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get account_info_gender;

  /// No description provided for @account_info_personal.
  ///
  /// In en, this message translates to:
  /// **'Your personal details'**
  String get account_info_personal;

  /// No description provided for @account_info_personal_date_birth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get account_info_personal_date_birth;

  /// No description provided for @account_info_personal_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get account_info_personal_email;

  /// No description provided for @account_info_personal_first_name.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get account_info_personal_first_name;

  /// No description provided for @account_info_personal_last_name.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get account_info_personal_last_name;

  /// No description provided for @account_info_personal_username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get account_info_personal_username;

  /// No description provided for @account_menu_addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get account_menu_addresses;

  /// No description provided for @account_menu_avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get account_menu_avatar;

  /// No description provided for @account_menu_back_in_stock_subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Back in stock subscriptions'**
  String get account_menu_back_in_stock_subscriptions;

  /// No description provided for @account_menu_change_password.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get account_menu_change_password;

  /// No description provided for @account_menu_customer_info.
  ///
  /// In en, this message translates to:
  /// **'Customer info'**
  String get account_menu_customer_info;

  /// No description provided for @account_menu_downloadable_products.
  ///
  /// In en, this message translates to:
  /// **'Downloadable products'**
  String get account_menu_downloadable_products;

  /// No description provided for @account_menu_my_product_reviews.
  ///
  /// In en, this message translates to:
  /// **'My product reviews'**
  String get account_menu_my_product_reviews;

  /// No description provided for @account_menu_gdpr_tools.
  ///
  /// In en, this message translates to:
  /// **'GDPR tools'**
  String get account_menu_gdpr_tools;

  /// No description provided for @account_menu_orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get account_menu_orders;

  /// No description provided for @account_menu_return_requests.
  ///
  /// In en, this message translates to:
  /// **'Return requests'**
  String get account_menu_return_requests;

  /// No description provided for @account_menu_reward_points.
  ///
  /// In en, this message translates to:
  /// **'Reward points'**
  String get account_menu_reward_points;

  /// No description provided for @account_orders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get account_orders;

  /// No description provided for @account_orders_details.
  ///
  /// In en, this message translates to:
  /// **'Order information'**
  String get account_orders_details;

  /// No description provided for @account_orders_details_billing_address.
  ///
  /// In en, this message translates to:
  /// **'Billing address:'**
  String get account_orders_details_billing_address;

  /// No description provided for @account_orders_details_button.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get account_orders_details_button;

  /// No description provided for @account_orders_details_button_pdf_invoice.
  ///
  /// In en, this message translates to:
  /// **'PDF invoice'**
  String get account_orders_details_button_pdf_invoice;

  /// No description provided for @account_orders_details_create_date.
  ///
  /// In en, this message translates to:
  /// **'Order date: '**
  String get account_orders_details_create_date;

  /// No description provided for @account_orders_details_create_date_undefined.
  ///
  /// In en, this message translates to:
  /// **'undefined'**
  String get account_orders_details_create_date_undefined;

  /// No description provided for @account_orders_details_date_delivered.
  ///
  /// In en, this message translates to:
  /// **'Date delivered:'**
  String get account_orders_details_date_delivered;

  /// No description provided for @account_orders_details_date_ready_for_pickup.
  ///
  /// In en, this message translates to:
  /// **'Date ready for pickup:'**
  String get account_orders_details_date_ready_for_pickup;

  /// No description provided for @account_orders_details_date_shipped.
  ///
  /// In en, this message translates to:
  /// **'Date shipped:'**
  String get account_orders_details_date_shipped;

  /// No description provided for @account_orders_details_number.
  ///
  /// In en, this message translates to:
  /// **'Order #%s'**
  String get account_orders_details_number;

  /// No description provided for @account_orders_details_order_total.
  ///
  /// In en, this message translates to:
  /// **'Order total: '**
  String get account_orders_details_order_total;

  /// No description provided for @account_orders_details_payment_info.
  ///
  /// In en, this message translates to:
  /// **'Payment info:'**
  String get account_orders_details_payment_info;

  /// No description provided for @account_orders_details_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment method:'**
  String get account_orders_details_payment_method;

  /// No description provided for @account_orders_details_payment_status.
  ///
  /// In en, this message translates to:
  /// **'Payment status:'**
  String get account_orders_details_payment_status;

  /// No description provided for @account_orders_details_pdf_invoice_download_completed.
  ///
  /// In en, this message translates to:
  /// **'Download completed'**
  String get account_orders_details_pdf_invoice_download_completed;

  /// No description provided for @account_orders_details_pdf_invoice_download_failed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get account_orders_details_pdf_invoice_download_failed;

  /// No description provided for @account_orders_details_pickup_point_address.
  ///
  /// In en, this message translates to:
  /// **'Pickup point address:'**
  String get account_orders_details_pickup_point_address;

  /// No description provided for @account_orders_details_products.
  ///
  /// In en, this message translates to:
  /// **'product(s):'**
  String get account_orders_details_products;

  /// No description provided for @account_orders_details_reorder.
  ///
  /// In en, this message translates to:
  /// **'Re-order'**
  String get account_orders_details_reorder;

  /// No description provided for @account_orders_details_return_items.
  ///
  /// In en, this message translates to:
  /// **'Return Item(s)'**
  String get account_orders_details_return_items;

  /// No description provided for @account_orders_details_shipment_number.
  ///
  /// In en, this message translates to:
  /// **'Shipment #'**
  String get account_orders_details_shipment_number;

  /// No description provided for @account_orders_details_shipments.
  ///
  /// In en, this message translates to:
  /// **'Shipments:'**
  String get account_orders_details_shipments;

  /// No description provided for @account_orders_details_shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping:'**
  String get account_orders_details_shipping;

  /// No description provided for @account_orders_details_shipping_address.
  ///
  /// In en, this message translates to:
  /// **'Shipping address:'**
  String get account_orders_details_shipping_address;

  /// No description provided for @account_orders_details_shipping_info.
  ///
  /// In en, this message translates to:
  /// **'Shipping info:'**
  String get account_orders_details_shipping_info;

  /// No description provided for @account_orders_details_shipping_method.
  ///
  /// In en, this message translates to:
  /// **'Shipping method:'**
  String get account_orders_details_shipping_method;

  /// No description provided for @account_orders_details_shipping_status.
  ///
  /// In en, this message translates to:
  /// **'Shipping status:'**
  String get account_orders_details_shipping_status;

  /// No description provided for @account_orders_details_sku.
  ///
  /// In en, this message translates to:
  /// **'SKU:'**
  String get account_orders_details_sku;

  /// No description provided for @account_orders_details_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Sub-total:'**
  String get account_orders_details_subtotal;

  /// No description provided for @account_orders_details_tax.
  ///
  /// In en, this message translates to:
  /// **'Tax:'**
  String get account_orders_details_tax;

  /// No description provided for @account_orders_details_total.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get account_orders_details_total;

  /// No description provided for @account_orders_details_tracking_number.
  ///
  /// In en, this message translates to:
  /// **'Tracking number:'**
  String get account_orders_details_tracking_number;

  /// No description provided for @account_orders_no_found.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get account_orders_no_found;

  /// No description provided for @account_return_requests.
  ///
  /// In en, this message translates to:
  /// **'Return requests'**
  String get account_return_requests;

  /// No description provided for @account_return_requests_no_found.
  ///
  /// In en, this message translates to:
  /// **'No return requests'**
  String get account_return_requests_no_found;

  /// No description provided for @account_return_request_number.
  ///
  /// In en, this message translates to:
  /// **'Return #%s'**
  String get account_return_request_number;

  /// No description provided for @account_return_request_requested_date.
  ///
  /// In en, this message translates to:
  /// **'Date requested: '**
  String get account_return_request_requested_date;

  /// No description provided for @account_return_request_requested_date_undefined.
  ///
  /// In en, this message translates to:
  /// **'undefined'**
  String get account_return_request_requested_date_undefined;

  /// No description provided for @account_return_request_return_item.
  ///
  /// In en, this message translates to:
  /// **'Returned item: '**
  String get account_return_request_return_item;

  /// No description provided for @account_return_request_return_reason.
  ///
  /// In en, this message translates to:
  /// **'Return reason: '**
  String get account_return_request_return_reason;

  /// No description provided for @account_return_request_return_action.
  ///
  /// In en, this message translates to:
  /// **'Return action: '**
  String get account_return_request_return_action;

  /// No description provided for @account_reviews.
  ///
  /// In en, this message translates to:
  /// **'My product reviews'**
  String get account_reviews;

  /// No description provided for @account_reviews_no_found.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t written any reviews yet'**
  String get account_reviews_no_found;

  /// No description provided for @account_reward_points.
  ///
  /// In en, this message translates to:
  /// **'My reward points'**
  String get account_reward_points;

  /// No description provided for @account_reward_points_balance_money.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get account_reward_points_balance_money;

  /// No description provided for @account_reward_points_balance_points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get account_reward_points_balance_points;

  /// No description provided for @account_reward_points_history.
  ///
  /// In en, this message translates to:
  /// **'Reward points history'**
  String get account_reward_points_history;

  /// No description provided for @account_reward_points_history_end.
  ///
  /// In en, this message translates to:
  /// **'Points valid until:'**
  String get account_reward_points_history_end;

  /// No description provided for @account_reward_points_history_no_found.
  ///
  /// In en, this message translates to:
  /// **'There is no balance history yet'**
  String get account_reward_points_history_no_found;

  /// No description provided for @account_wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get account_wishlist;

  /// No description provided for @account_wishlist_add_all.
  ///
  /// In en, this message translates to:
  /// **'Add all to cart'**
  String get account_wishlist_add_all;

  /// No description provided for @account_wishlist_empty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get account_wishlist_empty;

  /// No description provided for @account_wishlist_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh wishlist'**
  String get account_wishlist_refresh;

  /// No description provided for @address_card_dalete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get address_card_dalete;

  /// No description provided for @address_card_delete_text.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get address_card_delete_text;

  /// No description provided for @address_card_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete address'**
  String get address_card_delete_title;

  /// No description provided for @address_card_deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get address_card_deleted;

  /// No description provided for @address_card_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get address_card_edit;

  /// No description provided for @address_card_email.
  ///
  /// In en, this message translates to:
  /// **'Email:'**
  String get address_card_email;

  /// No description provided for @address_card_fax.
  ///
  /// In en, this message translates to:
  /// **'Fax:'**
  String get address_card_fax;

  /// No description provided for @address_card_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get address_card_phone;

  /// No description provided for @address_form_address1.
  ///
  /// In en, this message translates to:
  /// **'Address1'**
  String get address_form_address1;

  /// No description provided for @address_form_address2.
  ///
  /// In en, this message translates to:
  /// **'Address2'**
  String get address_form_address2;

  /// No description provided for @address_form_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get address_form_city;

  /// No description provided for @address_form_company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get address_form_company;

  /// No description provided for @address_form_county.
  ///
  /// In en, this message translates to:
  /// **'County'**
  String get address_form_county;

  /// No description provided for @address_form_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get address_form_email;

  /// No description provided for @address_form_fax.
  ///
  /// In en, this message translates to:
  /// **'Fax'**
  String get address_form_fax;

  /// No description provided for @address_form_first_name.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get address_form_first_name;

  /// No description provided for @address_form_last_name.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get address_form_last_name;

  /// No description provided for @address_form_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get address_form_phone;

  /// No description provided for @address_form_select_country.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get address_form_select_country;

  /// No description provided for @address_form_select_state.
  ///
  /// In en, this message translates to:
  /// **'Select state'**
  String get address_form_select_state;

  /// No description provided for @address_form_zip.
  ///
  /// In en, this message translates to:
  /// **'Zip postal code'**
  String get address_form_zip;

  /// No description provided for @app_applied_filters_price.
  ///
  /// In en, this message translates to:
  /// **'Price:'**
  String get app_applied_filters_price;

  /// No description provided for @app_bad_request.
  ///
  /// In en, this message translates to:
  /// **'Error 400 - Bad request'**
  String get app_bad_request;

  /// No description provided for @app_bad_request_path.
  ///
  /// In en, this message translates to:
  /// **'Path:'**
  String get app_bad_request_path;

  /// No description provided for @app_bad_request_request_data.
  ///
  /// In en, this message translates to:
  /// **'Request data:'**
  String get app_bad_request_request_data;

  /// No description provided for @app_bad_request_stack_trace.
  ///
  /// In en, this message translates to:
  /// **'Stack trace:'**
  String get app_bad_request_stack_trace;

  /// No description provided for @app_base_menu_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get app_base_menu_account;

  /// No description provided for @app_base_menu_cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get app_base_menu_cart;

  /// No description provided for @app_base_menu_catalog.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get app_base_menu_catalog;

  /// No description provided for @app_base_menu_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get app_base_menu_home;

  /// No description provided for @app_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get app_cancel;

  /// No description provided for @app_continue_shopping.
  ///
  /// In en, this message translates to:
  /// **'Continue shopping'**
  String get app_continue_shopping;

  /// No description provided for @app_error_message_data_is_null.
  ///
  /// In en, this message translates to:
  /// **'data is null'**
  String get app_error_message_data_is_null;

  /// No description provided for @app_error_message_request.
  ///
  /// In en, this message translates to:
  /// **'Request:'**
  String get app_error_message_request;

  /// No description provided for @app_error_message_response.
  ///
  /// In en, this message translates to:
  /// **'Response:'**
  String get app_error_message_response;

  /// No description provided for @app_home_featured_products.
  ///
  /// In en, this message translates to:
  /// **'Featured products'**
  String get app_home_featured_products;

  /// No description provided for @app_home_popular_categories.
  ///
  /// In en, this message translates to:
  /// **'Popular categories'**
  String get app_home_popular_categories;

  /// No description provided for @app_is_not_valid_date.
  ///
  /// In en, this message translates to:
  /// **'is not a valid date'**
  String get app_is_not_valid_date;

  /// No description provided for @app_is_not_valid_date_range.
  ///
  /// In en, this message translates to:
  /// **'Please enter date in valid range'**
  String get app_is_not_valid_date_range;

  /// No description provided for @app_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get app_ok;

  /// No description provided for @app_page_not_found.
  ///
  /// In en, this message translates to:
  /// **'Error 404 - Page not found'**
  String get app_page_not_found;

  /// No description provided for @app_no_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get app_no_internet_connection;

  /// No description provided for @app_no_internet_connection_message.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get app_no_internet_connection_message;

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'PostGebeya mobile app'**
  String get app_title;

  /// No description provided for @app_validators_can_not_be_empty.
  ///
  /// In en, this message translates to:
  /// **'can\'t be empty'**
  String get app_validators_can_not_be_empty;

  /// No description provided for @app_validators_email_is_not_valid.
  ///
  /// In en, this message translates to:
  /// **'Email is not valid'**
  String get app_validators_email_is_not_valid;

  /// No description provided for @app_validators_must_be_at_least.
  ///
  /// In en, this message translates to:
  /// **'must be at least %s characters long'**
  String get app_validators_must_be_at_least;

  /// No description provided for @app_validators_must_be_at_most.
  ///
  /// In en, this message translates to:
  /// **'must be at most %s characters long'**
  String get app_validators_must_be_at_most;

  /// No description provided for @auth_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get auth_address;

  /// No description provided for @auth_address_county.
  ///
  /// In en, this message translates to:
  /// **'County/region'**
  String get auth_address_county;

  /// No description provided for @auth_address_select_country.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get auth_address_select_country;

  /// No description provided for @auth_address_select_state.
  ///
  /// In en, this message translates to:
  /// **'Select state'**
  String get auth_address_select_state;

  /// No description provided for @auth_address_street.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get auth_address_street;

  /// No description provided for @auth_address_street2.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get auth_address_street2;

  /// No description provided for @auth_address_zip.
  ///
  /// In en, this message translates to:
  /// **'Zip postal code'**
  String get auth_address_zip;

  /// No description provided for @auth_are_you_sure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get auth_are_you_sure;

  /// No description provided for @auth_company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get auth_company;

  /// No description provided for @auth_company_details.
  ///
  /// In en, this message translates to:
  /// **'Company details'**
  String get auth_company_details;

  /// No description provided for @auth_contact_info.
  ///
  /// In en, this message translates to:
  /// **'Сontact information'**
  String get auth_contact_info;

  /// No description provided for @auth_contact_info_fax.
  ///
  /// In en, this message translates to:
  /// **'Fax'**
  String get auth_contact_info_fax;

  /// No description provided for @auth_contact_info_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get auth_contact_info_phone;

  /// No description provided for @auth_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Enable dark mode'**
  String get auth_dark_mode;

  /// No description provided for @auth_date_of_birth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get auth_date_of_birth;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_first_name.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get auth_first_name;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get auth_forgot_password;

  /// No description provided for @auth_forgot_password_recovery.
  ///
  /// In en, this message translates to:
  /// **'Password recovery'**
  String get auth_forgot_password_recovery;

  /// No description provided for @auth_forgot_password_recovery_body.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address below. You will receive a link to reset your password.'**
  String get auth_forgot_password_recovery_body;

  /// No description provided for @auth_forgot_password_recovery_button.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get auth_forgot_password_recovery_button;

  /// No description provided for @auth_not_registered.
  ///
  /// In en, this message translates to:
  /// **'Not registered? Sign up here'**
  String get auth_not_registered;

  /// No description provided for @auth_already_registered.
  ///
  /// In en, this message translates to:
  /// **'Already Registered? Log in Here'**
  String get auth_already_registered;

  /// No description provided for @auth_last_name.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get auth_last_name;

  /// No description provided for @auth_light_mode.
  ///
  /// In en, this message translates to:
  /// **'Enable light mode'**
  String get auth_light_mode;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get auth_login;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get auth_logout;

  /// No description provided for @auth_newsletter.
  ///
  /// In en, this message translates to:
  /// **'Newsletter'**
  String get auth_newsletter;

  /// No description provided for @auth_options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get auth_options;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_password_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get auth_password_confirm;

  /// No description provided for @auth_personal_details.
  ///
  /// In en, this message translates to:
  /// **'Your personal details'**
  String get auth_personal_details;

  /// No description provided for @auth_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_register;

  /// No description provided for @auth_username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get auth_username;

  /// No description provided for @auth_vat.
  ///
  /// In en, this message translates to:
  /// **'VAT number'**
  String get auth_vat;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get cart;

  /// No description provided for @cart_add_to.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get cart_add_to;

  /// No description provided for @cart_discount_enter_code.
  ///
  /// In en, this message translates to:
  /// **'Enter your coupon here'**
  String get cart_discount_enter_code;

  /// No description provided for @cart_empty.
  ///
  /// In en, this message translates to:
  /// **'Your shopping cart is empty'**
  String get cart_empty;

  /// No description provided for @cart_disabled.
  ///
  /// In en, this message translates to:
  /// **'Shopping cart is disabled'**
  String get cart_disabled;

  /// No description provided for @cart_gift_card_enter_code.
  ///
  /// In en, this message translates to:
  /// **'Enter gift card code'**
  String get cart_gift_card_enter_code;

  /// No description provided for @cart_gift_card_entered_code.
  ///
  /// In en, this message translates to:
  /// **'Entered gift card - %s'**
  String get cart_gift_card_entered_code;

  /// No description provided for @cart_item_price.
  ///
  /// In en, this message translates to:
  /// **'Price: %s'**
  String get cart_item_price;

  /// No description provided for @cart_item_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity: %s'**
  String get cart_item_quantity;

  /// No description provided for @cart_item_sku.
  ///
  /// In en, this message translates to:
  /// **'SKU: %s'**
  String get cart_item_sku;

  /// No description provided for @cart_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh shopping cart'**
  String get cart_refresh;

  /// No description provided for @cart_term_of_service.
  ///
  /// In en, this message translates to:
  /// **'I agree with the terms of service and I adhere to them unconditionally '**
  String get cart_term_of_service;

  /// No description provided for @cart_term_of_service_link.
  ///
  /// In en, this message translates to:
  /// **'(read)'**
  String get cart_term_of_service_link;

  /// No description provided for @cart_term_of_service_box_title.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get cart_term_of_service_box_title;

  /// No description provided for @cart_total_calc_during_checkout.
  ///
  /// In en, this message translates to:
  /// **'Calculated during checkout'**
  String get cart_total_calc_during_checkout;

  /// No description provided for @cart_total_discount.
  ///
  /// In en, this message translates to:
  /// **'Discount:'**
  String get cart_total_discount;

  /// No description provided for @cart_total_gift_card.
  ///
  /// In en, this message translates to:
  /// **'Gift card: (%s) \n %s remaining'**
  String get cart_total_gift_card;

  /// No description provided for @cart_total_payment_additional_fee.
  ///
  /// In en, this message translates to:
  /// **'Payment method additional fee:'**
  String get cart_total_payment_additional_fee;

  /// No description provided for @cart_total_reward_points.
  ///
  /// In en, this message translates to:
  /// **'%s reward points:'**
  String get cart_total_reward_points;

  /// No description provided for @cart_total_shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping:'**
  String get cart_total_shipping;

  /// No description provided for @cart_total_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Sub-total:'**
  String get cart_total_subtotal;

  /// No description provided for @cart_total_tax.
  ///
  /// In en, this message translates to:
  /// **'Tax:'**
  String get cart_total_tax;

  /// No description provided for @cart_total_tax_rates.
  ///
  /// In en, this message translates to:
  /// **'Tax: %s% -- %s'**
  String get cart_total_tax_rates;

  /// No description provided for @cart_total_will_earn_reward_points.
  ///
  /// In en, this message translates to:
  /// **'%s points'**
  String get cart_total_will_earn_reward_points;

  /// No description provided for @cart_total_will_earn_reward_points_title.
  ///
  /// In en, this message translates to:
  /// **'You will earn:'**
  String get cart_total_will_earn_reward_points_title;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @checkout_invalid_address_message.
  ///
  /// In en, this message translates to:
  /// **'Invalid existing address'**
  String get checkout_invalid_address_message;

  /// No description provided for @checkout_new_address.
  ///
  /// In en, this message translates to:
  /// **'Create new address'**
  String get checkout_new_address;

  /// No description provided for @checkout_steps_button_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get checkout_steps_button_continue;

  /// No description provided for @checkout_steps_billing.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get checkout_steps_billing;

  /// No description provided for @checkout_steps_billing_address_title.
  ///
  /// In en, this message translates to:
  /// **'Enter your billing address'**
  String get checkout_steps_billing_address_title;

  /// No description provided for @checkout_steps_billing_ship_same_address.
  ///
  /// In en, this message translates to:
  /// **'Ship to the same address'**
  String get checkout_steps_billing_ship_same_address;

  /// No description provided for @checkout_steps_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get checkout_steps_confirm;

  /// No description provided for @checkout_steps_confirm_billing_address.
  ///
  /// In en, this message translates to:
  /// **'Billing address'**
  String get checkout_steps_confirm_billing_address;

  /// No description provided for @checkout_steps_confirm_pickup_point_address.
  ///
  /// In en, this message translates to:
  /// **'Pickup point address'**
  String get checkout_steps_confirm_pickup_point_address;

  /// No description provided for @checkout_steps_confirm_shipping_address.
  ///
  /// In en, this message translates to:
  /// **'Shipping address'**
  String get checkout_steps_confirm_shipping_address;

  /// No description provided for @checkout_steps_confirm_shipping_method.
  ///
  /// In en, this message translates to:
  /// **'Shipping method: %s'**
  String get checkout_steps_confirm_shipping_method;

  /// No description provided for @checkout_steps_confirm_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment method: %s'**
  String get checkout_steps_confirm_payment_method;

  /// No description provided for @checkout_steps_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get checkout_steps_confirm_button;

  /// No description provided for @checkout_steps_payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get checkout_steps_payment;

  /// No description provided for @checkout_steps_payment_method_title.
  ///
  /// In en, this message translates to:
  /// **'Select payment method'**
  String get checkout_steps_payment_method_title;

  /// No description provided for @checkout_steps_shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get checkout_steps_shipping;

  /// No description provided for @checkout_steps_shipping_address_title.
  ///
  /// In en, this message translates to:
  /// **'Enter your shipping address'**
  String get checkout_steps_shipping_address_title;

  /// No description provided for @checkout_steps_shipping_method_title.
  ///
  /// In en, this message translates to:
  /// **'Select shipping method'**
  String get checkout_steps_shipping_method_title;

  /// No description provided for @checkout_steps_shipping_not_selected.
  ///
  /// In en, this message translates to:
  /// **'Please select shipping method'**
  String get checkout_steps_shipping_not_selected;

  /// No description provided for @checkout_steps_shipping_not_required.
  ///
  /// In en, this message translates to:
  /// **'Shipping method not required'**
  String get checkout_steps_shipping_not_required;

  /// No description provided for @checkout_steps_shipping_not_available.
  ///
  /// In en, this message translates to:
  /// **'No shipping methods available'**
  String get checkout_steps_shipping_not_available;

  /// No description provided for @checkout_steps_shipping_pickup_points_switch.
  ///
  /// In en, this message translates to:
  /// **'Pick up your items at the store'**
  String get checkout_steps_shipping_pickup_points_switch;

  /// No description provided for @checkout_steps_shipping_pickup_points_title.
  ///
  /// In en, this message translates to:
  /// **'Select pickup point'**
  String get checkout_steps_shipping_pickup_points_title;

  /// No description provided for @checkout_steps_shipping_pickup_points_not_selected.
  ///
  /// In en, this message translates to:
  /// **'Please select pickup point'**
  String get checkout_steps_shipping_pickup_points_not_selected;

  /// No description provided for @catalog.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get catalog;

  /// No description provided for @catalog_filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get catalog_filters;

  /// No description provided for @catalog_filters_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get catalog_filters_apply;

  /// No description provided for @catalog_filters_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get catalog_filters_clear;

  /// No description provided for @catalog_filters_manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get catalog_filters_manufacturer;

  /// No description provided for @catalog_filters_price_range.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get catalog_filters_price_range;

  /// No description provided for @catalog_items_number_many.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get catalog_items_number_many;

  /// No description provided for @catalog_items_number_one.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get catalog_items_number_one;

  /// No description provided for @catalog_manufacturers.
  ///
  /// In en, this message translates to:
  /// **'Manufacturers'**
  String get catalog_manufacturers;

  /// No description provided for @catalog_search_in_catalog.
  ///
  /// In en, this message translates to:
  /// **'Search in category'**
  String get catalog_search_in_catalog;

  /// No description provided for @catalog_search_in_catalog_no_found.
  ///
  /// In en, this message translates to:
  /// **'No products were found that matched your criteria'**
  String get catalog_search_in_catalog_no_found;

  /// No description provided for @catalog_vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get catalog_vendor;

  /// No description provided for @contact_us.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contact_us;

  /// No description provided for @contact_us_subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get contact_us_subject;

  /// No description provided for @contact_us_submit.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get contact_us_submit;

  /// No description provided for @contact_us_your_email.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get contact_us_your_email;

  /// No description provided for @contact_us_your_enquiry.
  ///
  /// In en, this message translates to:
  /// **'Your enquiry'**
  String get contact_us_your_enquiry;

  /// No description provided for @contact_us_your_name.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get contact_us_your_name;

  /// No description provided for @global_button_apply.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get global_button_apply;

  /// No description provided for @global_button_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get global_button_save;

  /// No description provided for @global_dropdown_default_select.
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get global_dropdown_default_select;

  /// No description provided for @global_fix_error.
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors.'**
  String get global_fix_error;

  /// No description provided for @global_items_not_available.
  ///
  /// In en, this message translates to:
  /// **'Sorry! No items available'**
  String get global_items_not_available;

  /// No description provided for @global_message_save.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get global_message_save;

  /// No description provided for @global_passwords_mismatch.
  ///
  /// In en, this message translates to:
  /// **'The password and confirmation password do not match'**
  String get global_passwords_mismatch;

  /// No description provided for @global_required.
  ///
  /// In en, this message translates to:
  /// **'*required'**
  String get global_required;

  /// No description provided for @global_validator_is_required.
  ///
  /// In en, this message translates to:
  /// **'Is required'**
  String get global_validator_is_required;

  /// No description provided for @product_add_to_card.
  ///
  /// In en, this message translates to:
  /// **'The product has been added to your shopping cart'**
  String get product_add_to_card;

  /// No description provided for @product_add_to_wishlist.
  ///
  /// In en, this message translates to:
  /// **'The product has been added to your wishlist'**
  String get product_add_to_wishlist;

  /// No description provided for @product_call_for_price.
  ///
  /// In en, this message translates to:
  /// **'Call for price'**
  String get product_call_for_price;

  /// No description provided for @product_delivery_date.
  ///
  /// In en, this message translates to:
  /// **'Delivery date:'**
  String get product_delivery_date;

  /// No description provided for @product_delivery_info_free_shipping.
  ///
  /// In en, this message translates to:
  /// **'Free shipping'**
  String get product_delivery_info_free_shipping;

  /// No description provided for @product_enter_price.
  ///
  /// In en, this message translates to:
  /// **'Enter your price:'**
  String get product_enter_price;

  /// No description provided for @product_gift_card_info.
  ///
  /// In en, this message translates to:
  /// **'Gift card info:'**
  String get product_gift_card_info;

  /// No description provided for @product_gift_card_info_message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get product_gift_card_info_message;

  /// No description provided for @product_gift_card_info_recipient_email.
  ///
  /// In en, this message translates to:
  /// **'Recipient\'s email*'**
  String get product_gift_card_info_recipient_email;

  /// No description provided for @product_gift_card_info_recipient_name.
  ///
  /// In en, this message translates to:
  /// **'Recipient\'s name*'**
  String get product_gift_card_info_recipient_name;

  /// No description provided for @product_gift_card_info_sender_email.
  ///
  /// In en, this message translates to:
  /// **'Your email*'**
  String get product_gift_card_info_sender_email;

  /// No description provided for @product_gift_card_info_sender_name.
  ///
  /// In en, this message translates to:
  /// **'Your name*'**
  String get product_gift_card_info_sender_name;

  /// No description provided for @product_gtin.
  ///
  /// In en, this message translates to:
  /// **'GTIN:'**
  String get product_gtin;

  /// No description provided for @product_manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer:'**
  String get product_manufacturer;

  /// No description provided for @product_manufacturer_part_number.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer part number:'**
  String get product_manufacturer_part_number;

  /// No description provided for @product_new_product_label.
  ///
  /// In en, this message translates to:
  /// **'new'**
  String get product_new_product_label;

  /// No description provided for @product_related_products.
  ///
  /// In en, this message translates to:
  /// **'Related products'**
  String get product_related_products;

  /// No description provided for @product_rental_info_end_date.
  ///
  /// In en, this message translates to:
  /// **'End date*'**
  String get product_rental_info_end_date;

  /// No description provided for @product_rental_info_rent_period.
  ///
  /// In en, this message translates to:
  /// **'Rent period:'**
  String get product_rental_info_rent_period;

  /// No description provided for @product_rental_info_start_date.
  ///
  /// In en, this message translates to:
  /// **'Start date*'**
  String get product_rental_info_start_date;

  /// No description provided for @product_sample_download.
  ///
  /// In en, this message translates to:
  /// **'Product sample download'**
  String get product_sample_download;

  /// No description provided for @product_sku.
  ///
  /// In en, this message translates to:
  /// **'SKU:'**
  String get product_sku;

  /// No description provided for @product_spec.
  ///
  /// In en, this message translates to:
  /// **'Products specifications:'**
  String get product_spec;

  /// No description provided for @product_subscription_dialog_already_subscribed.
  ///
  /// In en, this message translates to:
  /// **'You\'re already subscribed for this product back in stock notification'**
  String get product_subscription_dialog_already_subscribed;

  /// No description provided for @product_subscription_dialog_maximum_subscriptions.
  ///
  /// In en, this message translates to:
  /// **'You cannot subscribe. Maximum number of allowed subscriptions is %s'**
  String get product_subscription_dialog_maximum_subscriptions;

  /// No description provided for @product_subscription_dialog_not_allowed.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions are not allowed for this product'**
  String get product_subscription_dialog_not_allowed;

  /// No description provided for @product_subscription_dialog_notify_me.
  ///
  /// In en, this message translates to:
  /// **'Notify me'**
  String get product_subscription_dialog_notify_me;

  /// No description provided for @product_subscription_dialog_notify_me_when_available.
  ///
  /// In en, this message translates to:
  /// **'Notify me when available'**
  String get product_subscription_dialog_notify_me_when_available;

  /// No description provided for @product_subscription_dialog_only_registered.
  ///
  /// In en, this message translates to:
  /// **'Only registered customers can use this feature'**
  String get product_subscription_dialog_only_registered;

  /// No description provided for @product_subscription_dialog_popup_title.
  ///
  /// In en, this message translates to:
  /// **'Receive an email when this arrives in stock'**
  String get product_subscription_dialog_popup_title;

  /// No description provided for @product_subscription_dialog_tooltip.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive a onetime e-mail when this product is available for ordering again. We will not send you any other e-mails or add you to our newsletter; you will only be e-mailed about this product!'**
  String get product_subscription_dialog_tooltip;

  /// No description provided for @product_subscription_dialog_unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get product_subscription_dialog_unsubscribe;

  /// No description provided for @product_tier_prices_price.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get product_tier_prices_price;

  /// No description provided for @product_tier_prices_quantity.
  ///
  /// In en, this message translates to:
  /// **'QUANTITY'**
  String get product_tier_prices_quantity;

  /// No description provided for @product_vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor:'**
  String get product_vendor;

  /// No description provided for @return_request_title.
  ///
  /// In en, this message translates to:
  /// **'Return item(s) from order #%s'**
  String get return_request_title;

  /// No description provided for @return_request_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit return request'**
  String get return_request_submit;

  /// No description provided for @return_request_select_product.
  ///
  /// In en, this message translates to:
  /// **'Which items do you want to return?'**
  String get return_request_select_product;

  /// No description provided for @return_request_why_returning.
  ///
  /// In en, this message translates to:
  /// **'Why are you returning these item?'**
  String get return_request_why_returning;

  /// No description provided for @return_request_return_reason.
  ///
  /// In en, this message translates to:
  /// **'Select return reason'**
  String get return_request_return_reason;

  /// No description provided for @return_request_return_action.
  ///
  /// In en, this message translates to:
  /// **'Select return action'**
  String get return_request_return_action;

  /// No description provided for @return_request_no_items.
  ///
  /// In en, this message translates to:
  /// **'No items to return'**
  String get return_request_no_items;

  /// No description provided for @return_request_comments.
  ///
  /// In en, this message translates to:
  /// **'Return request comments'**
  String get return_request_comments;

  /// No description provided for @return_request_comments_hint.
  ///
  /// In en, this message translates to:
  /// **'Please provide any additional information about your return request'**
  String get return_request_comments_hint;

  /// No description provided for @reviews_add_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get reviews_add_submit;

  /// No description provided for @reviews_add_title.
  ///
  /// In en, this message translates to:
  /// **'Write your review'**
  String get reviews_add_title;

  /// No description provided for @reviews_add_your_text.
  ///
  /// In en, this message translates to:
  /// **'Your review text'**
  String get reviews_add_your_text;

  /// No description provided for @reviews_add_your_title.
  ///
  /// In en, this message translates to:
  /// **'Your review title'**
  String get reviews_add_your_title;

  /// No description provided for @reviews_date.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get reviews_date;

  /// No description provided for @reviews_for.
  ///
  /// In en, this message translates to:
  /// **'Review for:'**
  String get reviews_for;

  /// No description provided for @reviews_from.
  ///
  /// In en, this message translates to:
  /// **'From: '**
  String get reviews_from;

  /// No description provided for @reviews_helpful.
  ///
  /// In en, this message translates to:
  /// **'Was this review helpful?'**
  String get reviews_helpful;

  /// No description provided for @reviews_items.
  ///
  /// In en, this message translates to:
  /// **'review(s)'**
  String get reviews_items;

  /// No description provided for @reviews_no_found.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review this product'**
  String get reviews_no_found;

  /// No description provided for @reviews_title.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews_title;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settings_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settings_currency;

  /// No description provided for @settings_currency_hint.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get settings_currency_hint;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_hint.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get settings_language_hint;

  /// No description provided for @settings_tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get settings_tax;

  /// No description provided for @settings_tax_hint.
  ///
  /// In en, this message translates to:
  /// **'Select tax'**
  String get settings_tax_hint;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'am'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'am': return AppLocalizationsAm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
