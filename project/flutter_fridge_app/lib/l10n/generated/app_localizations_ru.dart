// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'FridgeNaut';

  @override
  String get home => 'Главная';

  @override
  String get fridge => 'Холодильник';

  @override
  String get reports => 'Отчёты';

  @override
  String get settings => 'Настройки';

  @override
  String get lowStock => 'Мало на складе';

  @override
  String get expiringSoon => 'Скоро истекает';

  @override
  String get expired => 'Истёк срок';

  @override
  String get outOfStock => 'Нет в наличии';

  @override
  String get plannedToBuy => 'Планируется купить';

  @override
  String get failedToLoadAlerts => 'Не удалось загрузить оповещения';

  @override
  String get retry => 'Повторить';

  @override
  String get failedToLoadReports => 'Не удалось загрузить отчёты';

  @override
  String cost(String amount) {
    return 'Стоимость: $amount';
  }

  @override
  String get thisWeek => 'Эта неделя';

  @override
  String get thisMonth => 'Этот месяц';

  @override
  String get thisYear => 'Этот год';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get theme => 'Тема';

  @override
  String get themeHelperText => 'Выберите цветовую тему приложения.';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get language => 'Язык';

  @override
  String get languageLabel => 'Язык приложения';

  @override
  String get languageHelperText => 'Выберите язык отображения приложения.';

  @override
  String get languageSystem => 'По умолчанию системы';

  @override
  String get currentlyUsing => 'в настоящее время используется';

  @override
  String get prices => 'Цены';

  @override
  String get priceSymbol => 'Символ валюты';

  @override
  String get priceSymbolHelperText =>
      'Используется при отображении цен (напр. ₽12,34).';

  @override
  String get extra => 'Дополнительно :)';

  @override
  String get expirySoonDays => 'Дней до истечения';

  @override
  String expirySoonDaysHelperText(int min, int max, int defaultValue) {
    return 'От $min до $max. По умолчанию $defaultValue.';
  }

  @override
  String get expiryAbbrev => 'годн.';

  @override
  String get save => 'Сохранить';

  @override
  String get reset => 'Сбросить';

  @override
  String get saved => 'Сохранено';

  @override
  String get resetSettings => 'Сбросить настройки';

  @override
  String get resetSettingsConfirmation =>
      'Вы уверены, что хотите сбросить все настройки до значений по умолчанию? Это действие нельзя отменить.';

  @override
  String get cancel => 'Отмена';

  @override
  String get settingsResetToDefaults => 'Настройки сброшены';

  @override
  String get inStock => 'В наличии';

  @override
  String get all => 'Все';

  @override
  String get addItem => 'Добавить товар';

  @override
  String get editItem => 'Редактировать товар';

  @override
  String get name => 'Название';

  @override
  String get quantity => 'Количество';

  @override
  String get unit => 'Единица';

  @override
  String get price => 'Цена';

  @override
  String get expiryDate => 'Срок годности';

  @override
  String get lowStockThreshold => 'Порог низкого запаса';

  @override
  String get delete => 'Удалить';

  @override
  String get confirmDelete => 'Подтвердить удаление';

  @override
  String get confirmDeleteMessage =>
      'Вы уверены, что хотите удалить этот товар?';

  @override
  String get noItems => 'Товары не найдены';

  @override
  String get endOfList => 'Все товары показаны выше';

  @override
  String get failedToLoadItems => 'Не удалось загрузить товары';

  @override
  String get searchItems => 'Поиск товаров...';

  @override
  String get category => 'Категория';

  @override
  String get notes => 'Заметки';

  @override
  String get toBuy => 'Купить';

  @override
  String get pricePerUnit => 'Цена за единицу';

  @override
  String get lowThreshold => 'Порог низкого запаса';

  @override
  String get expirationDate => 'Срок годности';

  @override
  String get none => 'Нет';

  @override
  String get notifyOnLow => 'Уведомить при низком запасе';

  @override
  String get notifyOnExpire => 'Уведомить при истечении';

  @override
  String get required => 'Обязательно';

  @override
  String get invalidNumber => 'Число';

  @override
  String get minZero => 'Мин 0';

  @override
  String get duplicateNameWarning =>
      'Это название уже существует, но вы все равно можете создать новый с таким же названием.';

  @override
  String get pastExpiryNote => 'Примечание: этот срок годности уже прошёл.';

  @override
  String get discardChanges => 'Отменить изменения?';

  @override
  String get discardChangesMessage =>
      'У вас есть несохранённые изменения. Хотите их отменить?';

  @override
  String get keepEditing => 'Продолжить редактирование';

  @override
  String get discard => 'Отменить';

  @override
  String get searchPlaceholder => 'Поиск...';

  @override
  String get weekly => 'Еженедельно';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get annual => 'Ежегодно';

  @override
  String get addPicture => 'Добавить изображение';

  @override
  String get changePicture => 'Изменить изображение';

  @override
  String get britishPound => 'Британский фунт';

  @override
  String get usDollar => 'Доллар США';

  @override
  String get euro => 'Евро';

  @override
  String get japaneseYen => 'Японская иена';

  @override
  String get hongKongDollar => 'Гонконгский доллар';

  @override
  String get australianDollar => 'Австралийский доллар';

  @override
  String get canadianDollar => 'Канадский доллар';

  @override
  String get indianRupee => 'Индийская рупия';

  @override
  String get southKoreanWon => 'Южнокорейская вона';

  @override
  String get swissFranc => 'Швейцарский франк';
}
