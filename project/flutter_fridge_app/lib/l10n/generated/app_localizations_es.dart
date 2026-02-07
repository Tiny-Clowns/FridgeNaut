// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Fridge Naut';

  @override
  String get home => 'Inicio';

  @override
  String get fridge => 'Nevera';

  @override
  String get reports => 'Informes';

  @override
  String get settings => 'Ajustes';

  @override
  String get lowStock => 'Stock bajo';

  @override
  String get expiringSoon => 'Por caducar';

  @override
  String get expired => 'Caducado';

  @override
  String get outOfStock => 'Sin stock';

  @override
  String get plannedToBuy => 'Planificado comprar';

  @override
  String get failedToLoadAlerts => 'Error al cargar las alertas';

  @override
  String get retry => 'Reintentar';

  @override
  String get failedToLoadReports => 'Error al cargar los informes';

  @override
  String cost(String amount) {
    return 'Coste: $amount';
  }

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get thisYear => 'Este año';

  @override
  String get appearance => 'Apariencia';

  @override
  String get theme => 'Tema';

  @override
  String get themeHelperText => 'Elige el tema de color de la aplicación.';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get languageLabel => 'Idioma de la aplicación';

  @override
  String get languageHelperText =>
      'Elige el idioma de visualización de la aplicación.';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get currentlyUsing => 'actualmente en uso';

  @override
  String get prices => 'Precios';

  @override
  String get dates => 'Fechas';

  @override
  String get dateFormat => 'Formato de fecha';

  @override
  String get dateFormatHelperText => 'Elige cómo se muestran las fechas.';

  @override
  String get priceSymbol => 'Símbolo de precio';

  @override
  String get priceSymbolHelperText =>
      'Se usa al mostrar precios (ej. 12,34 €).';

  @override
  String get extra => 'Extra :)';

  @override
  String get expirySoonDays => 'Días para caducidad';

  @override
  String expirySoonDaysHelperText(int min, int max, int defaultValue) {
    return 'Entre $min y $max. Por defecto $defaultValue.';
  }

  @override
  String get expiryAbbrev => 'cad.';

  @override
  String get save => 'Guardar';

  @override
  String get reset => 'Restablecer';

  @override
  String get saved => 'Guardado';

  @override
  String get resetSettings => 'Restablecer ajustes';

  @override
  String get resetSettingsConfirmation =>
      '¿Estás seguro de que quieres restablecer todos los ajustes a sus valores predeterminados? Esta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get settingsResetToDefaults => 'Ajustes restablecidos';

  @override
  String get inStock => 'En stock';

  @override
  String get all => 'Todo';

  @override
  String get addItem => 'Añadir artículo';

  @override
  String get editItem => 'Editar artículo';

  @override
  String get name => 'Nombre';

  @override
  String get quantity => 'Cantidad';

  @override
  String get unit => 'Unidad';

  @override
  String get price => 'Precio';

  @override
  String get expiryDate => 'Fecha de caducidad';

  @override
  String get lowStockThreshold => 'Umbral de stock bajo';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String get confirmDeleteMessage =>
      '¿Estás seguro de que quieres eliminar este artículo?';

  @override
  String get noItems => 'No se encontraron artículos';

  @override
  String get endOfList => 'Todos los artículos mostrados arriba';

  @override
  String get failedToLoadItems => 'Error al cargar los artículos';

  @override
  String get searchItems => 'Buscar artículos...';

  @override
  String get category => 'Categoría';

  @override
  String get notes => 'Notas';

  @override
  String get toBuy => 'Por comprar';

  @override
  String get pricePerUnit => 'Precio unitario';

  @override
  String get lowThreshold => 'Umbral bajo';

  @override
  String get expirationDate => 'Fecha de caducidad';

  @override
  String get none => 'Ninguna';

  @override
  String get notifyOnExpire => 'Notificar si caducado';

  @override
  String get required => 'Requerido';

  @override
  String get invalidNumber => 'Número';

  @override
  String get minZero => 'Mín 0';

  @override
  String get duplicateNameWarning =>
      'Este nombre ya existe, pero puedes crear uno nuevo con el mismo nombre.';

  @override
  String get pastExpiryNote =>
      'Nota: esta fecha de caducidad está en el pasado.';

  @override
  String get discardChanges => '¿Descartar cambios?';

  @override
  String get discardChangesMessage =>
      'Tienes cambios sin guardar. ¿Quieres descartarlos?';

  @override
  String get keepEditing => 'Seguir editando';

  @override
  String get discard => 'Descartar';

  @override
  String get searchPlaceholder => 'Buscar...';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get annual => 'Anual';

  @override
  String get addPicture => 'Añadir imagen';

  @override
  String get changePicture => 'Cambiar imagen';

  @override
  String get britishPound => 'Libra esterlina';

  @override
  String get usDollar => 'Dólar estadounidense';

  @override
  String get euro => 'Euro';

  @override
  String get japaneseYen => 'Yen japonés';

  @override
  String get hongKongDollar => 'Dólar de Hong Kong';

  @override
  String get australianDollar => 'Dólar australiano';

  @override
  String get canadianDollar => 'Dólar canadiense';

  @override
  String get indianRupee => 'Rupia india';

  @override
  String get southKoreanWon => 'Won surcoreano';

  @override
  String get swissFranc => 'Franco suizo';
}
