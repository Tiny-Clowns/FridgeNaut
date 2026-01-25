// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'FridgeNaut';

  @override
  String get home => 'ホーム';

  @override
  String get fridge => '冷蔵庫';

  @override
  String get reports => 'レポート';

  @override
  String get settings => '設定';

  @override
  String get lowStock => '在庫不足';

  @override
  String get expiringSoon => 'まもなく期限切れ';

  @override
  String get expired => '期限切れ';

  @override
  String get outOfStock => '在庫切れ';

  @override
  String get plannedToBuy => '購入予定';

  @override
  String get failedToLoadAlerts => 'アラートの読み込みに失敗しました';

  @override
  String get retry => '再試行';

  @override
  String get failedToLoadReports => 'レポートの読み込みに失敗しました';

  @override
  String cost(String amount) {
    return '費用：$amount';
  }

  @override
  String get thisWeek => '今週';

  @override
  String get thisMonth => '今月';

  @override
  String get thisYear => '今年';

  @override
  String get appearance => '外観';

  @override
  String get theme => 'テーマ';

  @override
  String get themeHelperText => 'アプリのカラーテーマを選択します。';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get language => '言語';

  @override
  String get languageLabel => 'アプリの言語';

  @override
  String get languageHelperText => 'アプリの表示言語を選択します。';

  @override
  String get languageSystem => 'システムのデフォルト';

  @override
  String get currentlyUsing => '現在使用中';

  @override
  String get prices => '価格';

  @override
  String get priceSymbol => '価格記号';

  @override
  String get priceSymbolHelperText => '価格表示に使用されます（例：¥1234）。';

  @override
  String get extra => 'その他 :)';

  @override
  String get expirySoonDays => '期限切れ間近の日数';

  @override
  String expirySoonDaysHelperText(int min, int max, int defaultValue) {
    return '$minから$maxの間。デフォルトは$defaultValueです。';
  }

  @override
  String get expiryAbbrev => '賞味期限';

  @override
  String get save => '保存';

  @override
  String get reset => 'リセット';

  @override
  String get saved => '保存しました';

  @override
  String get resetSettings => '設定をリセット';

  @override
  String get resetSettingsConfirmation =>
      'すべての設定をデフォルト値にリセットしてもよろしいですか？この操作は元に戻せません。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get settingsResetToDefaults => '設定がデフォルトにリセットされました';

  @override
  String get inStock => '在庫あり';

  @override
  String get all => 'すべて';

  @override
  String get addItem => 'アイテムを追加';

  @override
  String get editItem => 'アイテムを編集';

  @override
  String get name => '名前';

  @override
  String get quantity => '数量';

  @override
  String get unit => '単位';

  @override
  String get price => '価格';

  @override
  String get expiryDate => '賞味期限';

  @override
  String get lowStockThreshold => '在庫不足のしきい値';

  @override
  String get delete => '削除';

  @override
  String get confirmDelete => '削除の確認';

  @override
  String get confirmDeleteMessage => 'このアイテムを削除してもよろしいですか？';

  @override
  String get noItems => 'アイテムが見つかりません';

  @override
  String get endOfList => 'すべてのアイテムを上に表示';

  @override
  String get failedToLoadItems => 'アイテムの読み込みに失敗しました';

  @override
  String get searchItems => 'アイテムを検索...';

  @override
  String get category => 'カテゴリ';

  @override
  String get notes => 'メモ';

  @override
  String get toBuy => '購入予定';

  @override
  String get pricePerUnit => '単価';

  @override
  String get lowThreshold => '在庫不足のしきい値';

  @override
  String get expirationDate => '賞味期限';

  @override
  String get none => 'なし';

  @override
  String get notifyOnExpire => '期限切れ時に通知';

  @override
  String get required => '必須';

  @override
  String get invalidNumber => '数字';

  @override
  String get minZero => '最小 0';

  @override
  String get duplicateNameWarning => 'この名前は既に存在しますが、同じ名前で新しいアイテムを作成できます。';

  @override
  String get pastExpiryNote => '注意：この賞味期限は過去の日付です。';

  @override
  String get discardChanges => '変更を破棄しますか？';

  @override
  String get discardChangesMessage => '保存されていない変更があります。破棄しますか？';

  @override
  String get keepEditing => '編集を続ける';

  @override
  String get discard => '破棄';

  @override
  String get searchPlaceholder => '検索...';

  @override
  String get weekly => '週次';

  @override
  String get monthly => '月次';

  @override
  String get annual => '年次';

  @override
  String get addPicture => '画像を追加';

  @override
  String get changePicture => '画像を変更';

  @override
  String get britishPound => '英ポンド';

  @override
  String get usDollar => '米ドル';

  @override
  String get euro => 'ユーロ';

  @override
  String get japaneseYen => '日本円';

  @override
  String get hongKongDollar => '香港ドル';

  @override
  String get australianDollar => '豪ドル';

  @override
  String get canadianDollar => 'カナダドル';

  @override
  String get indianRupee => 'インドルピー';

  @override
  String get southKoreanWon => '韓国ウォン';

  @override
  String get swissFranc => 'スイスフラン';
}
