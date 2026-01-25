// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'FridgeNaut';

  @override
  String get home => '首页';

  @override
  String get fridge => '冰箱';

  @override
  String get reports => '报告';

  @override
  String get settings => '设置';

  @override
  String get lowStock => '库存不足';

  @override
  String get expiringSoon => '即将过期';

  @override
  String get expired => '已过期';

  @override
  String get outOfStock => '缺货';

  @override
  String get plannedToBuy => '计划购买';

  @override
  String get failedToLoadAlerts => '无法加载警报';

  @override
  String get retry => '重试';

  @override
  String get failedToLoadReports => '无法加载报告';

  @override
  String cost(String amount) {
    return '费用：$amount';
  }

  @override
  String get thisWeek => '本周';

  @override
  String get thisMonth => '本月';

  @override
  String get thisYear => '今年';

  @override
  String get appearance => '外观';

  @override
  String get theme => '主题';

  @override
  String get themeHelperText => '选择应用程序的颜色主题。';

  @override
  String get themeSystem => '系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get language => '语言';

  @override
  String get languageLabel => '应用语言';

  @override
  String get languageHelperText => '选择应用程序的显示语言。';

  @override
  String get languageSystem => '系统默认';

  @override
  String get currentlyUsing => '当前使用';

  @override
  String get prices => '价格';

  @override
  String get priceSymbol => '价格符号';

  @override
  String get priceSymbolHelperText => '用于显示价格（例如 ¥12.34）。';

  @override
  String get extra => '额外 :)';

  @override
  String get expirySoonDays => '即将过期天数';

  @override
  String expirySoonDaysHelperText(int min, int max, int defaultValue) {
    return '介于 $min 和 $max 之间。默认为 $defaultValue。';
  }

  @override
  String get expiryAbbrev => '保质期';

  @override
  String get save => '保存';

  @override
  String get reset => '重置';

  @override
  String get saved => '已保存';

  @override
  String get resetSettings => '重置设置';

  @override
  String get resetSettingsConfirmation => '您确定要将所有设置重置为默认值吗？此操作无法撤销。';

  @override
  String get cancel => '取消';

  @override
  String get settingsResetToDefaults => '设置已重置为默认值';

  @override
  String get inStock => '有库存';

  @override
  String get all => '全部';

  @override
  String get addItem => '添加项目';

  @override
  String get editItem => '编辑项目';

  @override
  String get name => '名称';

  @override
  String get quantity => '数量';

  @override
  String get unit => '单位';

  @override
  String get price => '价格';

  @override
  String get expiryDate => '有效期';

  @override
  String get lowStockThreshold => '低库存阈值';

  @override
  String get delete => '删除';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get confirmDeleteMessage => '您确定要删除此项目吗？';

  @override
  String get noItems => '找不到项目';

  @override
  String get endOfList => '所有项目已显示在上方';

  @override
  String get failedToLoadItems => '无法加载项目';

  @override
  String get searchItems => '搜索项目...';

  @override
  String get category => '类别';

  @override
  String get notes => '备注';

  @override
  String get toBuy => '待购买';

  @override
  String get pricePerUnit => '单价';

  @override
  String get lowThreshold => '低库存阈值';

  @override
  String get expirationDate => '有效期';

  @override
  String get none => '无';

  @override
  String get notifyOnExpire => '过期时通知';

  @override
  String get required => '必填';

  @override
  String get invalidNumber => '数字';

  @override
  String get minZero => '最小 0';

  @override
  String get duplicateNameWarning => '此名称已存在，但您仍可以创建同名的新项目。';

  @override
  String get pastExpiryNote => '注意：此有效期已过。';

  @override
  String get discardChanges => '放弃更改？';

  @override
  String get discardChangesMessage => '您有未保存的更改。要放弃吗？';

  @override
  String get keepEditing => '继续编辑';

  @override
  String get discard => '放弃';

  @override
  String get searchPlaceholder => '搜索...';

  @override
  String get weekly => '每周';

  @override
  String get monthly => '每月';

  @override
  String get annual => '每年';

  @override
  String get addPicture => '添加图片';

  @override
  String get changePicture => '更换图片';

  @override
  String get britishPound => '英镑';

  @override
  String get usDollar => '美元';

  @override
  String get euro => '欧元';

  @override
  String get japaneseYen => '日元';

  @override
  String get hongKongDollar => '港币';

  @override
  String get australianDollar => '澳元';

  @override
  String get canadianDollar => '加元';

  @override
  String get indianRupee => '印度卢比';

  @override
  String get southKoreanWon => '韩元';

  @override
  String get swissFranc => '瑞士法郎';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'FridgeNaut';

  @override
  String get home => '首页';

  @override
  String get fridge => '冰箱';

  @override
  String get reports => '报告';

  @override
  String get settings => '设置';

  @override
  String get lowStock => '库存不足';

  @override
  String get expiringSoon => '即将过期';

  @override
  String get expired => '已过期';

  @override
  String get outOfStock => '缺货';

  @override
  String get plannedToBuy => '计划购买';

  @override
  String get failedToLoadAlerts => '无法加载警报';

  @override
  String get retry => '重试';

  @override
  String get failedToLoadReports => '无法加载报告';

  @override
  String cost(String amount) {
    return '费用：$amount';
  }

  @override
  String get thisWeek => '本周';

  @override
  String get thisMonth => '本月';

  @override
  String get thisYear => '今年';

  @override
  String get appearance => '外观';

  @override
  String get theme => '主题';

  @override
  String get themeHelperText => '选择应用程序的颜色主题。';

  @override
  String get themeSystem => '系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get language => '语言';

  @override
  String get languageLabel => '应用语言';

  @override
  String get languageHelperText => '选择应用程序的显示语言。';

  @override
  String get languageSystem => '系统默认';

  @override
  String get currentlyUsing => '当前使用';

  @override
  String get prices => '价格';

  @override
  String get priceSymbol => '价格符号';

  @override
  String get priceSymbolHelperText => '用于显示价格（例如 ¥12.34）。';

  @override
  String get extra => '额外 :)';

  @override
  String get expirySoonDays => '即将过期天数';

  @override
  String expirySoonDaysHelperText(int min, int max, int defaultValue) {
    return '介于 $min 和 $max 之间。默认为 $defaultValue。';
  }

  @override
  String get expiryAbbrev => '保质期';

  @override
  String get save => '保存';

  @override
  String get reset => '重置';

  @override
  String get saved => '已保存';

  @override
  String get resetSettings => '重置设置';

  @override
  String get resetSettingsConfirmation => '您确定要将所有设置重置为默认值吗？此操作无法撤销。';

  @override
  String get cancel => '取消';

  @override
  String get settingsResetToDefaults => '设置已重置为默认值';

  @override
  String get inStock => '有库存';

  @override
  String get all => '全部';

  @override
  String get addItem => '添加项目';

  @override
  String get editItem => '编辑项目';

  @override
  String get name => '名称';

  @override
  String get quantity => '数量';

  @override
  String get unit => '单位';

  @override
  String get price => '价格';

  @override
  String get expiryDate => '有效期';

  @override
  String get lowStockThreshold => '低库存阈值';

  @override
  String get delete => '删除';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get confirmDeleteMessage => '您确定要删除此项目吗？';

  @override
  String get noItems => '找不到项目';

  @override
  String get endOfList => '所有项目已显示在上方';

  @override
  String get failedToLoadItems => '无法加载项目';

  @override
  String get searchItems => '搜索项目...';

  @override
  String get category => '类别';

  @override
  String get notes => '备注';

  @override
  String get toBuy => '待购买';

  @override
  String get pricePerUnit => '单价';

  @override
  String get lowThreshold => '低库存阈值';

  @override
  String get expirationDate => '有效期';

  @override
  String get none => '无';

  @override
  String get notifyOnExpire => '过期时通知';

  @override
  String get required => '必填';

  @override
  String get invalidNumber => '数字';

  @override
  String get minZero => '最小 0';

  @override
  String get duplicateNameWarning => '此名称已存在，但您仍可以创建同名的新项目。';

  @override
  String get pastExpiryNote => '注意：此有效期已过。';

  @override
  String get discardChanges => '放弃更改？';

  @override
  String get discardChangesMessage => '您有未保存的更改。要放弃吗？';

  @override
  String get keepEditing => '继续编辑';

  @override
  String get discard => '放弃';

  @override
  String get searchPlaceholder => '搜索...';

  @override
  String get weekly => '每周';

  @override
  String get monthly => '每月';

  @override
  String get annual => '每年';

  @override
  String get addPicture => '添加图片';

  @override
  String get changePicture => '更换图片';

  @override
  String get britishPound => '英镑';

  @override
  String get usDollar => '美元';

  @override
  String get euro => '欧元';

  @override
  String get japaneseYen => '日元';

  @override
  String get hongKongDollar => '港币';

  @override
  String get australianDollar => '澳元';

  @override
  String get canadianDollar => '加元';

  @override
  String get indianRupee => '印度卢比';

  @override
  String get southKoreanWon => '韩元';

  @override
  String get swissFranc => '瑞士法郎';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'FridgeNaut';

  @override
  String get home => '首頁';

  @override
  String get fridge => '冰箱';

  @override
  String get reports => '報告';

  @override
  String get settings => '設定';

  @override
  String get lowStock => '庫存不足';

  @override
  String get expiringSoon => '即將過期';

  @override
  String get expired => '已過期';

  @override
  String get outOfStock => '缺貨';

  @override
  String get plannedToBuy => '計劃購買';

  @override
  String get failedToLoadAlerts => '無法載入警示';

  @override
  String get retry => '重試';

  @override
  String get failedToLoadReports => '無法載入報告';

  @override
  String cost(String amount) {
    return '費用：$amount';
  }

  @override
  String get thisWeek => '本週';

  @override
  String get thisMonth => '本月';

  @override
  String get thisYear => '今年';

  @override
  String get appearance => '外觀';

  @override
  String get theme => '主題';

  @override
  String get themeHelperText => '選擇應用程式的顏色主題。';

  @override
  String get themeSystem => '系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get language => '語言';

  @override
  String get languageLabel => '應用程式語言';

  @override
  String get languageHelperText => '選擇應用程式的顯示語言。';

  @override
  String get languageSystem => '系統預設';

  @override
  String get currentlyUsing => '目前使用';

  @override
  String get prices => '價格';

  @override
  String get priceSymbol => '價格符號';

  @override
  String get priceSymbolHelperText => '用於顯示價格（例如 NT\$12.34）。';

  @override
  String get extra => '額外 :)';

  @override
  String get expirySoonDays => '即將過期天數';

  @override
  String expirySoonDaysHelperText(int min, int max, int defaultValue) {
    return '介於 $min 和 $max 之間。預設為 $defaultValue。';
  }

  @override
  String get expiryAbbrev => '保存期限';

  @override
  String get save => '保存';

  @override
  String get reset => '重設';

  @override
  String get saved => '已儲存';

  @override
  String get resetSettings => '重設設定';

  @override
  String get resetSettingsConfirmation => '您確定要將所有設定重設為預設值嗎？此操作無法撤銷。';

  @override
  String get cancel => '取消';

  @override
  String get settingsResetToDefaults => '設定已重設為預設值';

  @override
  String get inStock => '有庫存';

  @override
  String get all => '全部';

  @override
  String get addItem => '新增項目';

  @override
  String get editItem => '編輯項目';

  @override
  String get name => '名稱';

  @override
  String get quantity => '數量';

  @override
  String get unit => '單位';

  @override
  String get price => '價格';

  @override
  String get expiryDate => '有效期限';

  @override
  String get lowStockThreshold => '低庫存門檻';

  @override
  String get delete => '刪除';

  @override
  String get confirmDelete => '確認刪除';

  @override
  String get confirmDeleteMessage => '您確定要刪除此項目嗎？';

  @override
  String get noItems => '找不到項目';

  @override
  String get endOfList => '所有項目已顯示在上方';

  @override
  String get failedToLoadItems => '無法載入項目';

  @override
  String get searchItems => '搜尋項目...';

  @override
  String get category => '類別';

  @override
  String get notes => '備註';

  @override
  String get toBuy => '待購買';

  @override
  String get pricePerUnit => '單價';

  @override
  String get lowThreshold => '低庫存門檻';

  @override
  String get expirationDate => '有效期限';

  @override
  String get none => '無';

  @override
  String get notifyOnExpire => '過期時通知';

  @override
  String get required => '必填';

  @override
  String get invalidNumber => '數字';

  @override
  String get minZero => '最小 0';

  @override
  String get duplicateNameWarning => '此名稱已存在，但您仍可以建立同名的新項目。';

  @override
  String get pastExpiryNote => '注意：此有效期限已過。';

  @override
  String get discardChanges => '捨棄更改？';

  @override
  String get discardChangesMessage => '您有未儲存的更改。要捨棄嗎？';

  @override
  String get keepEditing => '繼續編輯';

  @override
  String get discard => '捨棄';

  @override
  String get searchPlaceholder => '搜尋...';

  @override
  String get weekly => '每週';

  @override
  String get monthly => '每月';

  @override
  String get annual => '每年';

  @override
  String get addPicture => '新增圖片';

  @override
  String get changePicture => '更換圖片';

  @override
  String get britishPound => '英鎊';

  @override
  String get usDollar => '美元';

  @override
  String get euro => '歐元';

  @override
  String get japaneseYen => '日圓';

  @override
  String get hongKongDollar => '港幣';

  @override
  String get australianDollar => '澳幣';

  @override
  String get canadianDollar => '加幣';

  @override
  String get indianRupee => '印度盧比';

  @override
  String get southKoreanWon => '韓元';

  @override
  String get swissFranc => '瑞士法郎';
}
