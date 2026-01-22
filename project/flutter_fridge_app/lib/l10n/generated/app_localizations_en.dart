// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FridgeNaut';

  @override
  String get home => 'Home';

  @override
  String get fridge => 'Fridge';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get lowStock => 'Low stock';

  @override
  String get expiringSoon => 'Expiring soon';

  @override
  String get expired => 'Expired';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get plannedToBuy => 'Planned to buy';

  @override
  String get failedToLoadAlerts => 'Failed to load alerts';

  @override
  String get retry => 'Retry';

  @override
  String get failedToLoadReports => 'Failed to load reports';

  @override
  String cost(String amount) {
    return 'Cost: $amount';
  }

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeHelperText => 'Choose the app\'s color theme.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageLabel => 'App Language';

  @override
  String get languageHelperText => 'Choose the app\'s display language.';

  @override
  String get languageSystem => 'System Default';

  @override
  String get currentlyUsing => 'currently using';

  @override
  String get prices => 'Prices';

  @override
  String get priceSymbol => 'Price symbol';

  @override
  String get priceSymbolHelperText =>
      'Used when displaying prices (e.g. £12.34).';

  @override
  String get extra => 'Extra :)';

  @override
  String get expirySoonDays => 'Expiry Soon Days';

  @override
  String expirySoonDaysHelperText(int min, int max, int defaultValue) {
    return 'Between $min and $max. Default is $defaultValue.';
  }

  @override
  String get expiryAbbrev => 'exp';

  @override
  String get save => 'Save';

  @override
  String get reset => 'Reset';

  @override
  String get saved => 'Saved';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsConfirmation =>
      'Are you sure you want to reset all settings to their default values? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get settingsResetToDefaults => 'Settings reset to defaults';

  @override
  String get inStock => 'In stock';

  @override
  String get all => 'All';

  @override
  String get addItem => 'Add Item';

  @override
  String get editItem => 'Edit Item';

  @override
  String get name => 'Name';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get price => 'Price';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get lowStockThreshold => 'Low Stock Threshold';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this item?';

  @override
  String get noItems => 'No items found';

  @override
  String get endOfList => 'All items shown above';

  @override
  String get failedToLoadItems => 'Failed to load items';

  @override
  String get searchItems => 'Search items...';

  @override
  String get category => 'Category';

  @override
  String get notes => 'Notes';

  @override
  String get toBuy => 'To Buy';

  @override
  String get pricePerUnit => 'Price per unit';

  @override
  String get lowThreshold => 'Low threshold';

  @override
  String get expirationDate => 'Expiration date';

  @override
  String get none => 'None';

  @override
  String get notifyOnLow => 'Notify on low';

  @override
  String get notifyOnExpire => 'Notify on expire';

  @override
  String get required => 'Required';

  @override
  String get invalidNumber => 'Number';

  @override
  String get minZero => 'Min 0';

  @override
  String get duplicateNameWarning =>
      'This name already exists, but you can still create a new one with the same name.';

  @override
  String get pastExpiryNote => 'Note: this expiration date is in the past.';

  @override
  String get discardChanges => 'Discard changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved changes. Do you want to discard them?';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get searchPlaceholder => 'Search...';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get annual => 'Annual';

  @override
  String get addPicture => 'Add picture';

  @override
  String get changePicture => 'Change picture';

  @override
  String get britishPound => 'British Pound';

  @override
  String get usDollar => 'US Dollar';

  @override
  String get euro => 'Euro';

  @override
  String get japaneseYen => 'Japanese Yen';

  @override
  String get hongKongDollar => 'Hong Kong Dollar';

  @override
  String get australianDollar => 'Australian Dollar';

  @override
  String get canadianDollar => 'Canadian Dollar';

  @override
  String get indianRupee => 'Indian Rupee';

  @override
  String get southKoreanWon => 'South Korean Won';

  @override
  String get swissFranc => 'Swiss Franc';
}
