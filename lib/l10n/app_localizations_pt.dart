// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get dashboard => 'Painel';

  @override
  String get products => 'Produtos';

  @override
  String get orders => 'Pedidos';

  @override
  String get invoices => 'Faturas';

  @override
  String get settings => 'Configurações';

  @override
  String get profile => 'Perfil';

  @override
  String get add => 'Adicionar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get name => 'Nome';

  @override
  String get description => 'Descrição';

  @override
  String get price => 'Preço';

  @override
  String get stock => 'Estoque';

  @override
  String get category => 'Categoria';

  @override
  String get food => 'Comida';

  @override
  String get drinks => 'Bebidas';

  @override
  String get desserts => 'Sobremesas';

  @override
  String get others => 'Outros';

  @override
  String get total => 'Total';

  @override
  String get confirmDelete => 'Confirmar exclusão';

  @override
  String get cannotUndo => 'Esta ação não pode ser desfeita';

  @override
  String get noProducts => 'Sem produtos';

  @override
  String get noOrders => 'Sem pedidos';

  @override
  String get noInvoices => 'Sem faturas';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get currency => 'Moeda';

  @override
  String get selectCurrency => 'Selecionar moeda';

  @override
  String get businessProfile => 'Perfil do Negócio';

  @override
  String get businessName => 'Nome do Negócio';

  @override
  String get address => 'Endereço';

  @override
  String get phone => 'Telefone';

  @override
  String get email => 'E-mail';

  @override
  String get share => 'Compartilhar';

  @override
  String get download => 'Baixar';

  @override
  String get error => 'Erro';

  @override
  String get addImage => 'Adicionar imagem';

  @override
  String get changeImage => 'Alterar imagem';

  @override
  String get businessManagement => 'Gestão do Negócio';

  @override
  String get productsRegistered => 'Produtos Registrados';

  @override
  String get ordersPlaced => 'Pedidos Realizados';

  @override
  String get totalRevenue => 'Receita Total';

  @override
  String get createOrder => 'Criar Pedido';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get theme => 'Tema';

  @override
  String get searchProducts => 'Buscar produtos...';

  @override
  String get searchByCustomer => 'Buscar por cliente ou número...';

  @override
  String get customerName => 'Nome do Cliente';

  @override
  String get customerNameRequired => 'Nome do Cliente *';

  @override
  String get phoneOptional => 'Telefone (opcional)';

  @override
  String get nameRequired => 'O nome é obrigatório';

  @override
  String get addProduct => 'Adicionar Produto';

  @override
  String get editProduct => 'Editar Produto';

  @override
  String get minCharacters => 'Mínimo 2 caracteres';

  @override
  String get priceRequired => 'O preço é obrigatório';

  @override
  String get invalidPrice => 'Preço inválido';

  @override
  String get stockRequired => 'O estoque é obrigatório';

  @override
  String get invalidStock => 'Estoque inválido';

  @override
  String get addToOrder => 'Adicione pelo menos um produto ao pedido';

  @override
  String get insufficientStock => 'Estoque insuficiente para';

  @override
  String totalItems(int count) {
    return 'Total ($count itens):';
  }

  @override
  String get clear => 'Limpar';

  @override
  String get orderCreatedSuccess => 'Pedido e fatura criados com sucesso';

  @override
  String get orderCreatedError => 'Erro ao criar pedido';

  @override
  String get noProductsAvailable => 'Nenhum produto disponível';

  @override
  String get noProductsFound => 'Nenhum produto encontrado';

  @override
  String get productAddedSuccess => 'Produto adicionado com sucesso';

  @override
  String get productUpdatedSuccess => 'Produto atualizado com sucesso';

  @override
  String get imageSelectedSuccess => 'Imagem selecionada com sucesso';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get permissionsDenied => 'Permissões negadas';

  @override
  String get close => 'Fechar';

  @override
  String get cart => 'Carrinho';

  @override
  String get viewCart => 'Ver Carrinho';

  @override
  String get quickAccess => 'Acesso Rápido';

  @override
  String get lowStockProducts => 'Produtos com estoque baixo';

  @override
  String get tapToChangeLogo => 'Toque para alterar o logo';

  @override
  String get businessNameRequired => 'O nome do negócio é obrigatório';

  @override
  String get invalidEmail => 'Digite um e-mail válido';

  @override
  String get profileUpdated => 'Perfil atualizado com sucesso';

  @override
  String get logoSelected => 'Logo selecionado com sucesso';

  @override
  String get needPermissions =>
      'Você precisa conceder permissões para escolher uma imagem';

  @override
  String get imageSelectionError => 'Erro ao selecionar imagem';

  @override
  String get darkModeSubtitle => 'Ativar tema escuro';

  @override
  String get businessProfileSubtitle => 'Edite as informações do seu negócio';

  @override
  String get version => 'Versão';

  @override
  String get filterByDate => 'Filtrar por data';

  @override
  String results(int count) {
    return '$count resultado(s)';
  }

  @override
  String get noInvoicesFound => 'Nenhuma fatura encontrada';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String productsCount(int count) {
    return '$count produto(s)';
  }

  @override
  String get deleteInvoice => 'Excluir fatura';

  @override
  String deleteInvoiceConfirm(int number) {
    return 'Tem certeza de que deseja excluir a Fatura #$number?\n\nEsta ação não pode ser desfeita.';
  }

  @override
  String get invoiceDeleted => 'Fatura excluída';

  @override
  String get needPermissionsToShare =>
      'Permissões necessárias para compartilhar';

  @override
  String get needPermissionsToDownload => 'Permissões necessárias para baixar';

  @override
  String get savedToGallery => 'Salvo na galeria';

  @override
  String get customerData => 'Dados do Cliente';

  @override
  String get nameField => 'Nome *';

  @override
  String get nameRequiredField => 'Nome obrigatório';

  @override
  String get phoneField => 'Telefone (opcional)';

  @override
  String get confirm => 'Confirmar';

  @override
  String get units => 'unidades';

  @override
  String get deleteProduct => 'Excluir produto';

  @override
  String get deleteProductConfirm =>
      'Tem certeza de que deseja excluir este produto?';

  @override
  String get productDeleted => 'Produto excluído com sucesso';

  @override
  String get permissionsNeeded => 'Permissões necessárias';

  @override
  String get permissionsMessage =>
      'Este aplicativo precisa de acesso às suas fotos para adicionar imagens aos produtos.\n\nVá para:\nConfigurações → Aplicativos → MeuNegócio → Permissões → Fotos e mídia';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get needPermissionToSelectImage =>
      'Você precisa conceder permissão para selecionar imagens';

  @override
  String get trySelectAnyway => 'Tentar selecionar a imagem mesmo assim';

  @override
  String invoiceNumber(int number) {
    return 'Fatura #$number';
  }

  @override
  String get businessNameLabel => 'Nome do negócio';

  @override
  String get addressLabel => 'Endereço';

  @override
  String get phoneLabel => 'Telefone';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get productList => 'Lista de produtos';

  @override
  String get quantity => 'Quantidade';

  @override
  String get quantityShort => 'Qtd.';

  @override
  String get unitPrice => 'Preço';

  @override
  String get totalPrice => 'Total';

  @override
  String get receipt => 'Recibo';

  @override
  String receiptNumber(int number) {
    return 'Recibo #$number';
  }

  @override
  String get productsSuffix => 'Produtos:';

  @override
  String get totalSuffix => 'Total:';

  @override
  String get deleteReceipt => 'Excluir recibo';

  @override
  String deleteReceiptConfirm(int number) {
    return 'Tem certeza de que deseja excluir o Recibo #$number?\n\nEsta ação não pode ser desfeita.';
  }

  @override
  String get receiptDeleted => 'Recibo excluído';

  @override
  String get warningNeedPermissionsToShare =>
      '⚠️ Permissões necessárias para compartilhar';

  @override
  String get warningNeedPermissionsToDownload =>
      '⚠️ Permissões necessárias para baixar';

  @override
  String get successSavedToGallery => '✅ Salvo na galeria';

  @override
  String get searchByCustomerOrNumber => 'Buscar por cliente ou número...';

  @override
  String resultsCount(int count) {
    return '$count resultado(s)';
  }

  @override
  String get noReceiptsFound => 'Nenhum recibo encontrado';

  @override
  String productsCountLabel(int count) {
    return '$count produto(s)';
  }

  @override
  String get warningPermissionsDenied => '⚠️ Permissões negadas';

  @override
  String get successImageSelected => '✅ Imagem selecionada com sucesso';

  @override
  String get errorOccurred => '❌ Erro';

  @override
  String get successProductAdded => '✅ Produto adicionado com sucesso';

  @override
  String get successProductUpdated => '✅ Produto atualizado com sucesso';

  @override
  String errorWithMessage(String message) {
    return '❌ Erro: $message';
  }

  @override
  String get successOrderCreated => '✅ Pedido e fatura criados com sucesso';

  @override
  String get errorOrderCreation => '❌ Erro ao criar pedido';

  @override
  String get errorAddToOrder => '❌ Adicione pelo menos um produto ao pedido';

  @override
  String errorInsufficientStock(String product) {
    return '❌ Estoque insuficiente para $product';
  }

  @override
  String get totalLabel => 'Total:';

  @override
  String get minStockCharacters => 'O estoque mínimo é 0';

  @override
  String get maxStockValue => 'O estoque máximo é 999999';

  @override
  String get validStockRequired => 'Digite um estoque válido';

  @override
  String get minPriceValue => 'O preço mínimo é 0.01';

  @override
  String get maxPriceValue => 'O preço máximo é 99999999';

  @override
  String get validPriceRequired => 'Digite um preço válido';

  @override
  String get customerNameMinLength => 'O nome deve ter pelo menos 2 caracteres';

  @override
  String get customerNameMaxLength => 'O nome é muito longo';

  @override
  String get phoneNumberInvalid => 'Número de telefone inválido';

  @override
  String get phoneMinLength => 'O telefone deve ter pelo menos 7 dígitos';

  @override
  String get downloadFormat => 'Formato de download';

  @override
  String get downloadFormatImage => 'Imagem (PNG)';

  @override
  String get downloadFormatPdf => 'Documento (PDF)';

  @override
  String get loginTitle => 'MeuNegócio';

  @override
  String get loginSubtitle => 'Sistema de Gestão';

  @override
  String get loginAsEmployee => 'Entrar como Funcionário';

  @override
  String get loginAsAdmin => 'Entrar como Admin';

  @override
  String get administrator => 'Administrador';

  @override
  String get password => 'Senha';

  @override
  String get verifying => 'Verificando...';

  @override
  String get defaultPassword => 'Senha padrão: 1234';

  @override
  String get pleaseEnterPassword => 'Por favor, insira a senha';

  @override
  String get incorrectPassword => 'Senha incorreta';

  @override
  String get loadingData => 'Carregando dados...';

  @override
  String get exportProducts => 'Exportar Produtos';

  @override
  String get importProducts => 'Importar Produtos';

  @override
  String get exportFullBackup => 'Exportar Tudo';

  @override
  String get importFullBackup => 'Importar Tudo';

  @override
  String get exportSuccess => 'Exportado com sucesso';

  @override
  String get importSuccess => 'Importado com sucesso';

  @override
  String get exportError => 'Erro ao exportar';

  @override
  String get importError => 'Erro ao importar';

  @override
  String get fileNotSelected => 'Nenhum arquivo selecionado';

  @override
  String get logout => 'Sair';
}
