// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'FridgeNaut';

  @override
  String get home => 'Início';

  @override
  String get fridge => 'Geladeira';

  @override
  String get reports => 'Relatórios';

  @override
  String get settings => 'Configurações';

  @override
  String get lowStock => 'Estoque baixo';

  @override
  String get expiringSoon => 'Vencendo em breve';

  @override
  String get expired => 'Vencido';

  @override
  String get outOfStock => 'Sem estoque';

  @override
  String get plannedToBuy => 'Planejado para comprar';

  @override
  String get failedToLoadAlerts => 'Falha ao carregar alertas';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get failedToLoadReports => 'Falha ao carregar relatórios';

  @override
  String cost(String amount) {
    return 'Custo: $amount';
  }

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mês';

  @override
  String get thisYear => 'Este ano';

  @override
  String get appearance => 'Aparência';

  @override
  String get theme => 'Tema';

  @override
  String get themeHelperText => 'Escolha o tema de cores do aplicativo.';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get language => 'Idioma';

  @override
  String get languageLabel => 'Idioma do aplicativo';

  @override
  String get languageHelperText =>
      'Escolha o idioma de exibição do aplicativo.';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get currentlyUsing => 'atualmente em uso';

  @override
  String get prices => 'Preços';

  @override
  String get priceSymbol => 'Símbolo de preço';

  @override
  String get priceSymbolHelperText => 'Usado ao exibir preços (ex. R\$12,34).';

  @override
  String get extra => 'Extra :)';

  @override
  String get expirySoonDays => 'Dias para vencimento';

  @override
  String expirySoonDaysHelperText(int min, int max, int defaultValue) {
    return 'Entre $min e $max. Padrão é $defaultValue.';
  }

  @override
  String get expiryAbbrev => 'val.';

  @override
  String get save => 'Salvar';

  @override
  String get reset => 'Redefinir';

  @override
  String get saved => 'Salvo';

  @override
  String get resetSettings => 'Redefinir configurações';

  @override
  String get resetSettingsConfirmation =>
      'Tem certeza de que deseja redefinir todas as configurações para os valores padrão? Esta ação não pode ser desfeita.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get settingsResetToDefaults => 'Configurações redefinidas';

  @override
  String get inStock => 'Em estoque';

  @override
  String get all => 'Todos';

  @override
  String get addItem => 'Adicionar item';

  @override
  String get editItem => 'Editar item';

  @override
  String get name => 'Nome';

  @override
  String get quantity => 'Quantidade';

  @override
  String get unit => 'Unidade';

  @override
  String get price => 'Preço';

  @override
  String get expiryDate => 'Data de validade';

  @override
  String get lowStockThreshold => 'Limite de estoque baixo';

  @override
  String get delete => 'Excluir';

  @override
  String get confirmDelete => 'Confirmar exclusão';

  @override
  String get confirmDeleteMessage =>
      'Tem certeza de que deseja excluir este item?';

  @override
  String get noItems => 'Nenhum item encontrado';

  @override
  String get endOfList => 'Todos os itens mostrados acima';

  @override
  String get failedToLoadItems => 'Falha ao carregar itens';

  @override
  String get searchItems => 'Pesquisar itens...';

  @override
  String get category => 'Categoria';

  @override
  String get notes => 'Notas';

  @override
  String get toBuy => 'Para comprar';

  @override
  String get pricePerUnit => 'Preço unitário';

  @override
  String get lowThreshold => 'Limite baixo';

  @override
  String get expirationDate => 'Data de validade';

  @override
  String get none => 'Nenhuma';

  @override
  String get notifyOnExpire => 'Notificar se vencido';

  @override
  String get required => 'Obrigatório';

  @override
  String get invalidNumber => 'Número';

  @override
  String get minZero => 'Mín 0';

  @override
  String get duplicateNameWarning =>
      'Este nome já existe, mas você ainda pode criar um novo com o mesmo nome.';

  @override
  String get pastExpiryNote => 'Nota: esta data de validade está no passado.';

  @override
  String get discardChanges => 'Descartar alterações?';

  @override
  String get discardChangesMessage =>
      'Você tem alterações não salvas. Deseja descartá-las?';

  @override
  String get keepEditing => 'Continuar editando';

  @override
  String get discard => 'Descartar';

  @override
  String get searchPlaceholder => 'Pesquisar...';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensal';

  @override
  String get annual => 'Anual';

  @override
  String get addPicture => 'Adicionar imagem';

  @override
  String get changePicture => 'Alterar imagem';

  @override
  String get britishPound => 'Libra esterlina';

  @override
  String get usDollar => 'Dólar americano';

  @override
  String get euro => 'Euro';

  @override
  String get japaneseYen => 'Iene japonês';

  @override
  String get hongKongDollar => 'Dólar de Hong Kong';

  @override
  String get australianDollar => 'Dólar australiano';

  @override
  String get canadianDollar => 'Dólar canadense';

  @override
  String get indianRupee => 'Rupia indiana';

  @override
  String get southKoreanWon => 'Won sul-coreano';

  @override
  String get swissFranc => 'Franco suíço';
}
