// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get dashboard => '仪表板';

  @override
  String get products => '产品';

  @override
  String get orders => '订单';

  @override
  String get invoices => '发票';

  @override
  String get settings => '设置';

  @override
  String get profile => '档案';

  @override
  String get add => '添加';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get name => '名称';

  @override
  String get description => '描述';

  @override
  String get price => '价格';

  @override
  String get stock => '库存';

  @override
  String get category => '类别';

  @override
  String get food => '食品';

  @override
  String get drinks => '饮料';

  @override
  String get desserts => '甜点';

  @override
  String get others => '其他';

  @override
  String get total => '总计';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get cannotUndo => '此操作无法撤消';

  @override
  String get noProducts => '没有产品';

  @override
  String get noOrders => '没有订单';

  @override
  String get noInvoices => '没有发票';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get currency => '货币';

  @override
  String get selectCurrency => '选择货币';

  @override
  String get businessProfile => '商业资料';

  @override
  String get businessName => '商家名称';

  @override
  String get address => '地址';

  @override
  String get phone => '电话';

  @override
  String get email => '电子邮件';

  @override
  String get share => '分享';

  @override
  String get download => '下载';

  @override
  String get error => '错误';

  @override
  String get addImage => '添加图片';

  @override
  String get changeImage => '更改图片';

  @override
  String get businessManagement => '业务管理';

  @override
  String get productsRegistered => '已注册产品';

  @override
  String get ordersPlaced => '已下订单';

  @override
  String get totalRevenue => '总收入';

  @override
  String get createOrder => '创建订单';

  @override
  String get darkMode => '深色模式';

  @override
  String get theme => '主题';

  @override
  String get searchProducts => '搜索产品...';

  @override
  String get searchByCustomer => '按客户或编号搜索...';

  @override
  String get customerName => '客户姓名';

  @override
  String get customerNameRequired => '客户姓名 *';

  @override
  String get phoneOptional => '电话（可选）';

  @override
  String get nameRequired => '名称为必填项';

  @override
  String get addProduct => '添加产品';

  @override
  String get editProduct => '编辑产品';

  @override
  String get minCharacters => '最少2个字符';

  @override
  String get priceRequired => '价格为必填项';

  @override
  String get invalidPrice => '价格无效';

  @override
  String get stockRequired => '库存为必填项';

  @override
  String get invalidStock => '库存无效';

  @override
  String get addToOrder => '至少在订单中添加一个产品';

  @override
  String get insufficientStock => '库存不足';

  @override
  String totalItems(int count) {
    return '总计（$count项）：';
  }

  @override
  String get clear => '清除';

  @override
  String get orderCreatedSuccess => '订单和发票已成功创建';

  @override
  String get orderCreatedError => '创建订单时出错';

  @override
  String get noProductsAvailable => '没有可用产品';

  @override
  String get noProductsFound => '未找到产品';

  @override
  String get productAddedSuccess => '产品已成功添加';

  @override
  String get productUpdatedSuccess => '产品已成功更新';

  @override
  String get imageSelectedSuccess => '图片已成功选择';

  @override
  String get retry => '重试';

  @override
  String get permissionsDenied => '权限被拒绝';

  @override
  String get close => '关闭';

  @override
  String get cart => '购物车';

  @override
  String get viewCart => '查看购物车';

  @override
  String get quickAccess => '快速访问';

  @override
  String get lowStockProducts => '库存不足的产品';

  @override
  String get tapToChangeLogo => '点击更改徽标';

  @override
  String get businessNameRequired => '商家名称为必填项';

  @override
  String get invalidEmail => '请输入有效的电子邮件';

  @override
  String get profileUpdated => '资料已成功更新';

  @override
  String get logoSelected => '徽标已成功选择';

  @override
  String get needPermissions => '您需要授予权限以选择图片';

  @override
  String get imageSelectionError => '选择图片时出错';

  @override
  String get darkModeSubtitle => '激活深色主题';

  @override
  String get businessProfileSubtitle => '编辑您的商业信息';

  @override
  String get version => '版本';

  @override
  String get filterByDate => '按日期过滤';

  @override
  String results(int count) {
    return '$count 个结果';
  }

  @override
  String get noInvoicesFound => '未找到发票';

  @override
  String get clearFilters => '清除过滤器';

  @override
  String productsCount(int count) {
    return '$count 个产品';
  }

  @override
  String get deleteInvoice => '删除发票';

  @override
  String deleteInvoiceConfirm(int number) {
    return '您确定要删除发票 #$number 吗？\n\n此操作无法撤消。';
  }

  @override
  String get invoiceDeleted => '发票已删除';

  @override
  String get needPermissionsToShare => '需要权限才能分享';

  @override
  String get needPermissionsToDownload => '需要权限才能下载';

  @override
  String get savedToGallery => '已保存到图库';

  @override
  String get customerData => '客户数据';

  @override
  String get nameField => '姓名 *';

  @override
  String get nameRequiredField => '姓名为必填项';

  @override
  String get phoneField => '电话（可选）';

  @override
  String get confirm => '确认';

  @override
  String get units => '单位';

  @override
  String get deleteProduct => '删除产品';

  @override
  String get deleteProductConfirm => '您确定要删除此产品吗？';

  @override
  String get productDeleted => '产品已成功删除';

  @override
  String get permissionsNeeded => '需要权限';

  @override
  String get permissionsMessage =>
      '此应用需要访问您的照片以将图片添加到产品中。\n\n前往：\n设置 → 应用 → 我的业务 → 权限 → 照片和媒体';

  @override
  String get openSettings => '打开设置';

  @override
  String get needPermissionToSelectImage => '您需要授予选择图片的权限';

  @override
  String get trySelectAnyway => '仍然尝试选择图片';

  @override
  String invoiceNumber(int number) {
    return '发票 #$number';
  }

  @override
  String get businessNameLabel => '商家名称';

  @override
  String get addressLabel => '地址';

  @override
  String get phoneLabel => '电话';

  @override
  String get emailLabel => '电子邮件';

  @override
  String get productList => '产品列表';

  @override
  String get quantity => '数量';

  @override
  String get quantityShort => '数量';

  @override
  String get unitPrice => '价格';

  @override
  String get totalPrice => '总计';

  @override
  String get receipt => '收据';

  @override
  String receiptNumber(int number) {
    return '收据 #$number';
  }

  @override
  String get productsSuffix => '产品：';

  @override
  String get totalSuffix => '总计：';

  @override
  String get deleteReceipt => '删除收据';

  @override
  String deleteReceiptConfirm(int number) {
    return '您确定要删除收据 #$number 吗？\n\n此操作无法撤消。';
  }

  @override
  String get receiptDeleted => '收据已删除';

  @override
  String get warningNeedPermissionsToShare => '⚠️ 需要权限才能分享';

  @override
  String get warningNeedPermissionsToDownload => '⚠️ 需要权限才能下载';

  @override
  String get successSavedToGallery => '✅ 已保存到图库';

  @override
  String get searchByCustomerOrNumber => '按客户或编号搜索...';

  @override
  String resultsCount(int count) {
    return '$count 个结果';
  }

  @override
  String get noReceiptsFound => '未找到收据';

  @override
  String productsCountLabel(int count) {
    return '$count 个产品';
  }

  @override
  String get warningPermissionsDenied => '⚠️ 权限被拒绝';

  @override
  String get successImageSelected => '✅ 图片已成功选择';

  @override
  String get errorOccurred => '❌ 错误';

  @override
  String get successProductAdded => '✅ 产品已成功添加';

  @override
  String get successProductUpdated => '✅ 产品已成功更新';

  @override
  String errorWithMessage(String message) {
    return '❌ 错误：$message';
  }

  @override
  String get successOrderCreated => '✅ 订单和发票已成功创建';

  @override
  String get errorOrderCreation => '❌ 创建订单时出错';

  @override
  String get errorAddToOrder => '❌ 至少在订单中添加一个产品';

  @override
  String errorInsufficientStock(String product) {
    return '❌ $product 库存不足';
  }

  @override
  String get totalLabel => '总计：';

  @override
  String get minStockCharacters => '最小库存为0';

  @override
  String get maxStockValue => '最大库存为999999';

  @override
  String get validStockRequired => '请输入有效库存';

  @override
  String get minPriceValue => '最低价格为0.01';

  @override
  String get maxPriceValue => '最高价格为99999999';

  @override
  String get validPriceRequired => '请输入有效价格';

  @override
  String get customerNameMinLength => '姓名至少需要2个字符';

  @override
  String get customerNameMaxLength => '姓名太长';

  @override
  String get phoneNumberInvalid => '电话号码无效';

  @override
  String get phoneMinLength => '电话号码至少需要7位数字';

  @override
  String get downloadFormat => '下载格式';

  @override
  String get downloadFormatImage => '图片（PNG）';

  @override
  String get downloadFormatPdf => '文档（PDF）';

  @override
  String get loginTitle => '我的业务';

  @override
  String get loginSubtitle => '管理系统';

  @override
  String get loginAsEmployee => '作为员工登录';

  @override
  String get loginAsAdmin => '作为管理员登录';

  @override
  String get administrator => '管理员';

  @override
  String get password => '密码';

  @override
  String get verifying => '验证中...';

  @override
  String get defaultPassword => '默认密码：1234';

  @override
  String get pleaseEnterPassword => '请输入密码';

  @override
  String get incorrectPassword => '密码错误';

  @override
  String get loadingData => '加载数据中...';

  @override
  String get exportProducts => '导出产品';

  @override
  String get importProducts => '导入产品';

  @override
  String get exportFullBackup => '导出全部';

  @override
  String get importFullBackup => '导入全部';

  @override
  String get exportSuccess => '导出成功';

  @override
  String get importSuccess => '导入成功';

  @override
  String get exportError => '导出错误';

  @override
  String get importError => '导入错误';

  @override
  String get fileNotSelected => '未选择文件';

  @override
  String get logout => '登出';
}
