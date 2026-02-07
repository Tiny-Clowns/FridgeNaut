// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Fridge Naut';

  @override
  String get home => 'Startseite';

  @override
  String get fridge => 'Kühlschrank';

  @override
  String get reports => 'Berichte';

  @override
  String get settings => 'Einstellungen';

  @override
  String get lowStock => 'Niedriger Bestand';

  @override
  String get expiringSoon => 'Bald ablaufend';

  @override
  String get expired => 'Abgelaufen';

  @override
  String get outOfStock => 'Nicht vorrätig';

  @override
  String get plannedToBuy => 'Geplant zu kaufen';

  @override
  String get failedToLoadAlerts => 'Fehler beim Laden der Warnungen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get failedToLoadReports => 'Fehler beim Laden der Berichte';

  @override
  String cost(String amount) {
    return 'Kosten: $amount';
  }

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get thisMonth => 'Dieser Monat';

  @override
  String get thisYear => 'Dieses Jahr';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get theme => 'Thema';

  @override
  String get themeHelperText => 'Wählen Sie das Farbthema der App.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get language => 'Sprache';

  @override
  String get languageLabel => 'App-Sprache';

  @override
  String get languageHelperText => 'Wählen Sie die Anzeigesprache der App.';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get currentlyUsing => 'aktuell verwendet';

  @override
  String get prices => 'Preise';

  @override
  String get dates => 'Daten';

  @override
  String get dateFormat => 'Datumsformat';

  @override
  String get dateFormatHelperText =>
      'Wählen Sie, wie Datumsangaben angezeigt werden.';

  @override
  String get priceSymbol => 'Preissymbol';

  @override
  String get priceSymbolHelperText =>
      'Wird bei der Anzeige von Preisen verwendet (z.B. 12,34 €).';

  @override
  String get extra => 'Extra :)';

  @override
  String get expirySoonDays => 'Tage bis Ablauf';

  @override
  String expirySoonDaysHelperText(int min, int max, int defaultValue) {
    return 'Zwischen $min und $max. Standard ist $defaultValue.';
  }

  @override
  String get expiryAbbrev => 'MHD';

  @override
  String get save => 'Speichern';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get saved => 'Gespeichert';

  @override
  String get resetSettings => 'Einstellungen zurücksetzen';

  @override
  String get resetSettingsConfirmation =>
      'Sind Sie sicher, dass Sie alle Einstellungen auf die Standardwerte zurücksetzen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get settingsResetToDefaults => 'Einstellungen zurückgesetzt';

  @override
  String get inStock => 'Auf Lager';

  @override
  String get all => 'Alle';

  @override
  String get addItem => 'Artikel hinzufügen';

  @override
  String get editItem => 'Artikel bearbeiten';

  @override
  String get name => 'Name';

  @override
  String get quantity => 'Menge';

  @override
  String get unit => 'Einheit';

  @override
  String get price => 'Preis';

  @override
  String get expiryDate => 'Ablaufdatum';

  @override
  String get lowStockThreshold => 'Schwelle für niedrigen Bestand';

  @override
  String get delete => 'Löschen';

  @override
  String get confirmDelete => 'Löschen bestätigen';

  @override
  String get confirmDeleteMessage =>
      'Sind Sie sicher, dass Sie diesen Artikel löschen möchten?';

  @override
  String get noItems => 'Keine Artikel gefunden';

  @override
  String get endOfList => 'Alle Artikel oben angezeigt';

  @override
  String get failedToLoadItems => 'Fehler beim Laden der Artikel';

  @override
  String get searchItems => 'Artikel suchen...';

  @override
  String get category => 'Kategorie';

  @override
  String get notes => 'Notizen';

  @override
  String get toBuy => 'Zu kaufen';

  @override
  String get pricePerUnit => 'Preis pro Einheit';

  @override
  String get lowThreshold => 'Niedriger Schwellenwert';

  @override
  String get expirationDate => 'Ablaufdatum';

  @override
  String get none => 'Keine';

  @override
  String get notifyOnExpire => 'Bei Ablauf benachrichtigen';

  @override
  String get required => 'Erforderlich';

  @override
  String get invalidNumber => 'Zahl';

  @override
  String get minZero => 'Min 0';

  @override
  String get duplicateNameWarning =>
      'Dieser Name existiert bereits, aber Sie können trotzdem einen neuen mit demselben Namen erstellen.';

  @override
  String get pastExpiryNote =>
      'Hinweis: Dieses Ablaufdatum liegt in der Vergangenheit.';

  @override
  String get discardChanges => 'Änderungen verwerfen?';

  @override
  String get discardChangesMessage =>
      'Sie haben nicht gespeicherte Änderungen. Möchten Sie diese verwerfen?';

  @override
  String get keepEditing => 'Weiter bearbeiten';

  @override
  String get discard => 'Verwerfen';

  @override
  String get searchPlaceholder => 'Suchen...';

  @override
  String get weekly => 'Wöchentlich';

  @override
  String get monthly => 'Monatlich';

  @override
  String get annual => 'Jährlich';

  @override
  String get addPicture => 'Bild hinzufügen';

  @override
  String get changePicture => 'Bild ändern';

  @override
  String get britishPound => 'Britisches Pfund';

  @override
  String get usDollar => 'US-Dollar';

  @override
  String get euro => 'Euro';

  @override
  String get japaneseYen => 'Japanischer Yen';

  @override
  String get hongKongDollar => 'Hongkong-Dollar';

  @override
  String get australianDollar => 'Australischer Dollar';

  @override
  String get canadianDollar => 'Kanadischer Dollar';

  @override
  String get indianRupee => 'Indische Rupie';

  @override
  String get southKoreanWon => 'Südkoreanischer Won';

  @override
  String get swissFranc => 'Schweizer Franken';
}
