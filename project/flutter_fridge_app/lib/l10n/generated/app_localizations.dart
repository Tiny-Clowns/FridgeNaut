import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'FridgeNaut'**
  String get appTitle;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Fridge navigation label
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get fridge;

  /// Reports navigation label
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Settings navigation label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Low stock alert label
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStock;

  /// Expiring soon alert label
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get expiringSoon;

  /// Expired alert label
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Out of stock alert label
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// Planned to buy alert label
  ///
  /// In en, this message translates to:
  /// **'Planned to buy'**
  String get plannedToBuy;

  /// Error message when alerts fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load alerts'**
  String get failedToLoadAlerts;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error message when reports fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load reports'**
  String get failedToLoadReports;

  /// Cost label with amount
  ///
  /// In en, this message translates to:
  /// **'Cost: {amount}'**
  String cost(String amount);

  /// This week report range
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// This month report range
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// This year report range
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Theme setting helper text
  ///
  /// In en, this message translates to:
  /// **'Choose the app\'s color theme.'**
  String get themeHelperText;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Language section title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get languageLabel;

  /// Language setting helper text
  ///
  /// In en, this message translates to:
  /// **'Choose the app\'s display language.'**
  String get languageHelperText;

  /// System default language option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// Text shown to indicate the active locale when system default is selected
  ///
  /// In en, this message translates to:
  /// **'currently using'**
  String get currentlyUsing;

  /// Prices section title
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get prices;

  /// Price symbol setting label
  ///
  /// In en, this message translates to:
  /// **'Price symbol'**
  String get priceSymbol;

  /// Price symbol setting helper text
  ///
  /// In en, this message translates to:
  /// **'Used when displaying prices (e.g. £12.34).'**
  String get priceSymbolHelperText;

  /// Extra section title
  ///
  /// In en, this message translates to:
  /// **'Extra :)'**
  String get extra;

  /// Expiry soon days setting label
  ///
  /// In en, this message translates to:
  /// **'Expiry Soon Days'**
  String get expirySoonDays;

  /// Expiry soon days setting helper text
  ///
  /// In en, this message translates to:
  /// **'Between {min} and {max}. Default is {defaultValue}.'**
  String expirySoonDaysHelperText(int min, int max, int defaultValue);

  /// Abbreviation shown before expiry dates (e.g. 'exp 2025-12-25')
  ///
  /// In en, this message translates to:
  /// **'exp'**
  String get expiryAbbrev;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Saved confirmation message
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Reset settings dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// Reset settings confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to their default values? This action cannot be undone.'**
  String get resetSettingsConfirmation;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Settings reset confirmation message
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetToDefaults;

  /// In stock filter label
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// All filter label
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Add item button/title
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// Edit item button/title
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Quantity field label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Unit field label
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// Price field label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Expiry date field label
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// Low stock threshold field label
  ///
  /// In en, this message translates to:
  /// **'Low Stock Threshold'**
  String get lowStockThreshold;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// Confirm delete dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDeleteMessage;

  /// No items message
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItems;

  /// Message shown at the bottom of item lists to indicate all items are displayed
  ///
  /// In en, this message translates to:
  /// **'All items shown above'**
  String get endOfList;

  /// Error message when items fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load items'**
  String get failedToLoadItems;

  /// Search items placeholder
  ///
  /// In en, this message translates to:
  /// **'Search items...'**
  String get searchItems;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// To buy checkbox label
  ///
  /// In en, this message translates to:
  /// **'To Buy'**
  String get toBuy;

  /// Price per unit field label
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get pricePerUnit;

  /// Low threshold field label
  ///
  /// In en, this message translates to:
  /// **'Low threshold'**
  String get lowThreshold;

  /// Expiration date field label
  ///
  /// In en, this message translates to:
  /// **'Expiration date'**
  String get expirationDate;

  /// None label for empty values
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Notify on expire switch label
  ///
  /// In en, this message translates to:
  /// **'Notify on expire'**
  String get notifyOnExpire;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Invalid number validation message
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get invalidNumber;

  /// Minimum zero validation message
  ///
  /// In en, this message translates to:
  /// **'Min 0'**
  String get minZero;

  /// Duplicate name warning message
  ///
  /// In en, this message translates to:
  /// **'This name already exists, but you can still create a new one with the same name.'**
  String get duplicateNameWarning;

  /// Past expiry date note
  ///
  /// In en, this message translates to:
  /// **'Note: this expiration date is in the past.'**
  String get pastExpiryNote;

  /// Discard changes dialog title
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChanges;

  /// Discard changes dialog message
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them?'**
  String get discardChangesMessage;

  /// Keep editing button label
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// Discard button label
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Search placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchPlaceholder;

  /// Weekly report range label
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Monthly report range label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Annual report range label
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// Add picture button label
  ///
  /// In en, this message translates to:
  /// **'Add picture'**
  String get addPicture;

  /// Change picture button label
  ///
  /// In en, this message translates to:
  /// **'Change picture'**
  String get changePicture;

  /// British Pound currency name
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get britishPound;

  /// US Dollar currency name
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get usDollar;

  /// Euro currency name
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get euro;

  /// Japanese Yen currency name
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get japaneseYen;

  /// Hong Kong Dollar currency name
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Dollar'**
  String get hongKongDollar;

  /// Australian Dollar currency name
  ///
  /// In en, this message translates to:
  /// **'Australian Dollar'**
  String get australianDollar;

  /// Canadian Dollar currency name
  ///
  /// In en, this message translates to:
  /// **'Canadian Dollar'**
  String get canadianDollar;

  /// Indian Rupee currency name
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee'**
  String get indianRupee;

  /// South Korean Won currency name
  ///
  /// In en, this message translates to:
  /// **'South Korean Won'**
  String get southKoreanWon;

  /// Swiss Franc currency name
  ///
  /// In en, this message translates to:
  /// **'Swiss Franc'**
  String get swissFranc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
