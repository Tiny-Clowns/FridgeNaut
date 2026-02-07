// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Fridge Naut';

  @override
  String get home => 'Accueil';

  @override
  String get fridge => 'Frigo';

  @override
  String get reports => 'Rapports';

  @override
  String get settings => 'Paramètres';

  @override
  String get lowStock => 'Stock bas';

  @override
  String get expiringSoon => 'Expire bientôt';

  @override
  String get expired => 'Expiré';

  @override
  String get outOfStock => 'Rupture de stock';

  @override
  String get plannedToBuy => 'Prévu d\'acheter';

  @override
  String get failedToLoadAlerts => 'Échec du chargement des alertes';

  @override
  String get retry => 'Réessayer';

  @override
  String get failedToLoadReports => 'Échec du chargement des rapports';

  @override
  String cost(String amount) {
    return 'Coût : $amount';
  }

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get thisYear => 'Cette année';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get themeHelperText =>
      'Choisissez le thème de couleur de l\'application.';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get language => 'Langue';

  @override
  String get languageLabel => 'Langue de l\'application';

  @override
  String get languageHelperText =>
      'Choisissez la langue d\'affichage de l\'application.';

  @override
  String get languageSystem => 'Par défaut du système';

  @override
  String get currentlyUsing => 'actuellement utilisé';

  @override
  String get prices => 'Prix';

  @override
  String get dates => 'Dates';

  @override
  String get dateFormat => 'Format de date';

  @override
  String get dateFormatHelperText =>
      'Choisissez la façon dont les dates sont affichées.';

  @override
  String get priceSymbol => 'Symbole de prix';

  @override
  String get priceSymbolHelperText =>
      'Utilisé lors de l\'affichage des prix (ex. 12,34 €).';

  @override
  String get extra => 'Extra :)';

  @override
  String get expirySoonDays => 'Jours avant expiration';

  @override
  String expirySoonDaysHelperText(int min, int max, int defaultValue) {
    return 'Entre $min et $max. Par défaut $defaultValue.';
  }

  @override
  String get expiryAbbrev => 'exp.';

  @override
  String get save => 'Enregistrer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get saved => 'Enregistré';

  @override
  String get resetSettings => 'Réinitialiser les paramètres';

  @override
  String get resetSettingsConfirmation =>
      'Êtes-vous sûr de vouloir réinitialiser tous les paramètres à leurs valeurs par défaut ? Cette action est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get settingsResetToDefaults => 'Paramètres réinitialisés';

  @override
  String get inStock => 'En stock';

  @override
  String get all => 'Tout';

  @override
  String get addItem => 'Ajouter un article';

  @override
  String get editItem => 'Modifier l\'article';

  @override
  String get name => 'Nom';

  @override
  String get quantity => 'Quantité';

  @override
  String get unit => 'Unité';

  @override
  String get price => 'Prix';

  @override
  String get expiryDate => 'Date d\'expiration';

  @override
  String get lowStockThreshold => 'Seuil de stock bas';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String get confirmDeleteMessage =>
      'Êtes-vous sûr de vouloir supprimer cet article ?';

  @override
  String get noItems => 'Aucun article trouvé';

  @override
  String get endOfList => 'Tous les articles affichés ci-dessus';

  @override
  String get failedToLoadItems => 'Échec du chargement des articles';

  @override
  String get searchItems => 'Rechercher des articles...';

  @override
  String get category => 'Catégorie';

  @override
  String get notes => 'Notes';

  @override
  String get toBuy => 'À acheter';

  @override
  String get pricePerUnit => 'Prix unitaire';

  @override
  String get lowThreshold => 'Seuil bas';

  @override
  String get expirationDate => 'Date d\'expiration';

  @override
  String get none => 'Aucune';

  @override
  String get notifyOnExpire => 'Notifier si expiré';

  @override
  String get required => 'Requis';

  @override
  String get invalidNumber => 'Nombre';

  @override
  String get minZero => 'Min 0';

  @override
  String get duplicateNameWarning =>
      'Ce nom existe déjà, mais vous pouvez quand même en créer un nouveau avec le même nom.';

  @override
  String get pastExpiryNote => 'Note : cette date d\'expiration est passée.';

  @override
  String get discardChanges => 'Abandonner les modifications ?';

  @override
  String get discardChangesMessage =>
      'Vous avez des modifications non enregistrées. Voulez-vous les abandonner ?';

  @override
  String get keepEditing => 'Continuer';

  @override
  String get discard => 'Abandonner';

  @override
  String get searchPlaceholder => 'Rechercher...';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get annual => 'Annuel';

  @override
  String get addPicture => 'Ajouter une image';

  @override
  String get changePicture => 'Changer l\'image';

  @override
  String get britishPound => 'Livre sterling';

  @override
  String get usDollar => 'Dollar américain';

  @override
  String get euro => 'Euro';

  @override
  String get japaneseYen => 'Yen japonais';

  @override
  String get hongKongDollar => 'Dollar de Hong Kong';

  @override
  String get australianDollar => 'Dollar australien';

  @override
  String get canadianDollar => 'Dollar canadien';

  @override
  String get indianRupee => 'Roupie indienne';

  @override
  String get southKoreanWon => 'Won sud-coréen';

  @override
  String get swissFranc => 'Franc suisse';
}
