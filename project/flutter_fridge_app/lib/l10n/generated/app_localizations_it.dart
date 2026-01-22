// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'FridgeNaut';

  @override
  String get home => 'Home';

  @override
  String get fridge => 'Frigo';

  @override
  String get reports => 'Rapporti';

  @override
  String get settings => 'Impostazioni';

  @override
  String get lowStock => 'Scorte basse';

  @override
  String get expiringSoon => 'In scadenza';

  @override
  String get expired => 'Scaduto';

  @override
  String get outOfStock => 'Esaurito';

  @override
  String get plannedToBuy => 'Da acquistare';

  @override
  String get failedToLoadAlerts => 'Caricamento avvisi non riuscito';

  @override
  String get retry => 'Riprova';

  @override
  String get failedToLoadReports => 'Caricamento rapporti non riuscito';

  @override
  String cost(String amount) {
    return 'Costo: $amount';
  }

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String get thisMonth => 'Questo mese';

  @override
  String get thisYear => 'Quest\'anno';

  @override
  String get appearance => 'Aspetto';

  @override
  String get theme => 'Tema';

  @override
  String get themeHelperText => 'Scegli il tema colore dell\'app.';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get language => 'Lingua';

  @override
  String get languageLabel => 'Lingua dell\'app';

  @override
  String get languageHelperText =>
      'Scegli la lingua di visualizzazione dell\'app.';

  @override
  String get languageSystem => 'Predefinito di sistema';

  @override
  String get currentlyUsing => 'attualmente in uso';

  @override
  String get prices => 'Prezzi';

  @override
  String get priceSymbol => 'Simbolo prezzo';

  @override
  String get priceSymbolHelperText =>
      'Usato per visualizzare i prezzi (es. €12,34).';

  @override
  String get extra => 'Extra :)';

  @override
  String get expirySoonDays => 'Giorni prima della scadenza';

  @override
  String expirySoonDaysHelperText(int min, int max, int defaultValue) {
    return 'Tra $min e $max. Predefinito $defaultValue.';
  }

  @override
  String get expiryAbbrev => 'scad.';

  @override
  String get save => 'Salva';

  @override
  String get reset => 'Reimposta';

  @override
  String get saved => 'Salvato';

  @override
  String get resetSettings => 'Reimposta impostazioni';

  @override
  String get resetSettingsConfirmation =>
      'Sei sicuro di voler reimpostare tutte le impostazioni ai valori predefiniti? Questa azione non può essere annullata.';

  @override
  String get cancel => 'Annulla';

  @override
  String get settingsResetToDefaults => 'Impostazioni reimpostate';

  @override
  String get inStock => 'Disponibile';

  @override
  String get all => 'Tutto';

  @override
  String get addItem => 'Aggiungi articolo';

  @override
  String get editItem => 'Modifica articolo';

  @override
  String get name => 'Nome';

  @override
  String get quantity => 'Quantità';

  @override
  String get unit => 'Unità';

  @override
  String get price => 'Prezzo';

  @override
  String get expiryDate => 'Data di scadenza';

  @override
  String get lowStockThreshold => 'Soglia scorte basse';

  @override
  String get delete => 'Elimina';

  @override
  String get confirmDelete => 'Conferma eliminazione';

  @override
  String get confirmDeleteMessage =>
      'Sei sicuro di voler eliminare questo articolo?';

  @override
  String get noItems => 'Nessun articolo trovato';

  @override
  String get endOfList => 'Tutti gli articoli mostrati sopra';

  @override
  String get failedToLoadItems => 'Caricamento articoli non riuscito';

  @override
  String get searchItems => 'Cerca articoli...';

  @override
  String get category => 'Categoria';

  @override
  String get notes => 'Note';

  @override
  String get toBuy => 'Da comprare';

  @override
  String get pricePerUnit => 'Prezzo unitario';

  @override
  String get lowThreshold => 'Soglia bassa';

  @override
  String get expirationDate => 'Data di scadenza';

  @override
  String get none => 'Nessuna';

  @override
  String get notifyOnLow => 'Notifica se scorte basse';

  @override
  String get notifyOnExpire => 'Notifica se scaduto';

  @override
  String get required => 'Richiesto';

  @override
  String get invalidNumber => 'Numero';

  @override
  String get minZero => 'Min 0';

  @override
  String get duplicateNameWarning =>
      'Questo nome esiste già, ma puoi comunque crearne uno nuovo con lo stesso nome.';

  @override
  String get pastExpiryNote => 'Nota: questa data di scadenza è nel passato.';

  @override
  String get discardChanges => 'Annullare le modifiche?';

  @override
  String get discardChangesMessage =>
      'Hai modifiche non salvate. Vuoi annullarle?';

  @override
  String get keepEditing => 'Continua';

  @override
  String get discard => 'Annulla';

  @override
  String get searchPlaceholder => 'Cerca...';

  @override
  String get weekly => 'Settimanale';

  @override
  String get monthly => 'Mensile';

  @override
  String get annual => 'Annuale';

  @override
  String get addPicture => 'Aggiungi immagine';

  @override
  String get changePicture => 'Cambia immagine';

  @override
  String get britishPound => 'Sterlina britannica';

  @override
  String get usDollar => 'Dollaro americano';

  @override
  String get euro => 'Euro';

  @override
  String get japaneseYen => 'Yen giapponese';

  @override
  String get hongKongDollar => 'Dollaro di Hong Kong';

  @override
  String get australianDollar => 'Dollaro australiano';

  @override
  String get canadianDollar => 'Dollaro canadese';

  @override
  String get indianRupee => 'Rupia indiana';

  @override
  String get southKoreanWon => 'Won sudcoreano';

  @override
  String get swissFranc => 'Franco svizzero';
}
