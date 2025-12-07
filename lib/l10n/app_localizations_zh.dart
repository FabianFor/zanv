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
  String get invoices => '收据';

  @override
  String get settings => '设置';

  @override
  String get profile => '个人资料';

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
  String get food => '食物';

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
  String get noInvoices => '没有收据';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get currency => '货币';

  @override
  String get selectCurrency => '选择货币';

  @override
  String get businessProfile => '业务资料';

  @override
  String get businessName => '公司名称';

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
  String get customerName => '客户名称';

  @override
  String get customerNameRequired => '客户名称 *';

  @override
  String get phoneOptional => '电话（可选）';

  @override
  String get nameRequired => '名称为必填项';

  @override
  String get addProduct => '添加产品';

  @override
  String get editProduct => '编辑产品';

  @override
  String get minCharacters => '至少2个字符';

  @override
  String get priceRequired => '价格为必填项';

  @override
  String get invalidPrice => '价格无效';

  @override
  String get stockRequired => '库存为必填项';

  @override
  String get invalidStock => '库存无效';

  @override
  String get addToOrder => '至少添加一个产品到订单';

  @override
  String get insufficientStock => '库存不足';

  @override
  String totalItems(int count) {
    return '总计（$count项）：';
  }

  @override
  String get clear => '清除';

  @override
  String get orderCreatedSuccess => '订单和收据创建成功';

  @override
  String get orderCreatedError => '创建订单时出错';

  @override
  String get noProductsAvailable => '没有可用的产品';

  @override
  String get noProductsFound => '未找到产品';

  @override
  String get productAddedSuccess => '产品添加成功';

  @override
  String get productUpdatedSuccess => '产品更新成功';

  @override
  String get imageSelectedSuccess => '图片选择成功';

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
  String get lowStockProducts => '低库存产品';

  @override
  String get tapToChangeLogo => '点击更改徽标';

  @override
  String get businessNameRequired => '公司名称为必填项';

  @override
  String get invalidEmail => '请输入有效的电子邮件';

  @override
  String get profileUpdated => '个人资料更新成功';

  @override
  String get logoSelected => '徽标选择成功';

  @override
  String get needPermissions => '您需要授予权限才能选择图片';

  @override
  String get imageSelectionError => '选择图片时出错';

  @override
  String get darkModeSubtitle => '激活深色主题';

  @override
  String get businessProfileSubtitle => '编辑您的业务信息';

  @override
  String get version => '版本';

  @override
  String get filterByDate => '按日期筛选';

  @override
  String results(int count) {
    return '$count个结果';
  }

  @override
  String get noInvoicesFound => '未找到收据';

  @override
  String get clearFilters => '清除筛选';

  @override
  String productsCount(int count) {
    return '$count个产品';
  }

  @override
  String get deleteInvoice => '删除收据';

  @override
  String deleteInvoiceConfirm(int number) {
    return '您确定要删除收据#$number吗？\n\n此操作无法撤消。';
  }

  @override
  String get invoiceDeleted => '收据已删除';

  @override
  String get needPermissionsToShare => '需要权限才能分享';

  @override
  String get needPermissionsToDownload => '需要权限才能下载';

  @override
  String get savedToGallery => '已保存到图库';

  @override
  String get customerData => '客户数据';

  @override
  String get nameField => '名称 *';

  @override
  String get nameRequiredField => '名称为必填项';

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
  String get productDeleted => '产品删除成功';

  @override
  String get permissionsNeeded => '您需要授予权限才能选择图像';

  @override
  String get permissionsMessage =>
      '此应用需要访问您的照片以向产品添加图片。\n\n请前往：\n设置 → 应用 → Proïon → 权限 → 照片和媒体';

  @override
  String get openSettings => '打开设置';

  @override
  String get needPermissionToSelectImage => '您需要授予权限才能选择图片';

  @override
  String get trySelectAnyway => '仍然尝试选择图片';

  @override
  String invoiceNumber(int number) {
    return '收据#$number';
  }

  @override
  String get businessNameLabel => '公司名称';

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
    return '收据#$number';
  }

  @override
  String get productsSuffix => '产品：';

  @override
  String get totalSuffix => '总计：';

  @override
  String get deleteReceipt => '删除收据';

  @override
  String deleteReceiptConfirm(int number) {
    return '您确定要删除收据#$number吗？\n\n此操作无法撤消。';
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
    return '$count个结果';
  }

  @override
  String get noReceiptsFound => '未找到收据';

  @override
  String productsCountLabel(int count) {
    return '$count个产品';
  }

  @override
  String get warningPermissionsDenied => '⚠️ 权限被拒绝';

  @override
  String get successImageSelected => '✅ 图片选择成功';

  @override
  String get errorOccurred => '❌ 错误';

  @override
  String get successProductAdded => '✅ 产品添加成功';

  @override
  String get successProductUpdated => '✅ 产品更新成功';

  @override
  String errorWithMessage(String message) {
    return '❌ 错误：$message';
  }

  @override
  String get successOrderCreated => '✅ 订单和收据创建成功';

  @override
  String get errorOrderCreation => '❌ 创建订单时出错';

  @override
  String get errorAddToOrder => '❌ 至少添加一个产品到订单';

  @override
  String errorInsufficientStock(String product) {
    return '❌ $product库存不足';
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
  String get customerNameMinLength => '名称至少需要2个字符';

  @override
  String get customerNameMaxLength => '名称太长';

  @override
  String get phoneNumberInvalid => '电话号码无效';

  @override
  String get phoneMinLength => '电话至少需要7位数字';

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
  String get verifying => '正在验证...';

  @override
  String get defaultPassword => '默认密码：1234';

  @override
  String get pleaseEnterPassword => '请输入密码';

  @override
  String get incorrectPassword => '密码错误';

  @override
  String get loadingData => '正在加载数据...';

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
  String get logout => '退出';

  @override
  String get statistics => '统计';

  @override
  String get sales => '销售';

  @override
  String get today => '今天';

  @override
  String get thisWeek => '本周';

  @override
  String get thisMonth => '本月';

  @override
  String get allTime => '全部';

  @override
  String invoicesCount(int count) {
    return '$count个收据';
  }

  @override
  String get topProducts => '最畅销产品';

  @override
  String unitsSold(int count) {
    return '已售出$count件';
  }

  @override
  String get stockAlerts => '库存警报';

  @override
  String get allGood => '一切正常';

  @override
  String get noLowStockProducts => '没有低库存产品';

  @override
  String outOfStock(int count) {
    return '缺货（$count）';
  }

  @override
  String lowStock(int count) {
    return '库存不足（$count）';
  }

  @override
  String get noSalesRecorded => '没有销售记录';

  @override
  String get todayLabel => '今天';

  @override
  String get weekLabel => '周';

  @override
  String get monthLabel => '月';

  @override
  String get allLabel => '全部';

  @override
  String get customRange => '范围';

  @override
  String get selectRange => '选择范围';

  @override
  String get periodTotal => '期间总计：';

  @override
  String get noBilletsInPeriod => '此期间没有收据';

  @override
  String billetCount(int count) {
    return '$count个收据';
  }

  @override
  String get filterToday => '今天';

  @override
  String get filterWeek => '周';

  @override
  String get filterMonth => '月';

  @override
  String get filterAll => '全部';

  @override
  String get filterRange => '范围';

  @override
  String get selectDateRange => '选择范围';

  @override
  String todayDate(String date) {
    return '今天 - $date';
  }

  @override
  String get thisWeekLabel => '本周';

  @override
  String thisMonthDate(String date) {
    return '本月 - $date';
  }

  @override
  String get allDates => '所有日期';

  @override
  String get customRangeLabel => '自定义范围';

  @override
  String dateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get clearAllFilters => '清除筛选';

  @override
  String get noBilletsInPeriodShort => '此期间没有收据';

  @override
  String get getStarted => '开始使用！';

  @override
  String get setupYourBusiness => '设置您的业务以开始';

  @override
  String get businessSetup => '初始设置';

  @override
  String get step => '步骤';

  @override
  String get ofPreposition => '共';

  @override
  String get businessInfo => '业务信息';

  @override
  String get enterBusinessName => '您的公司名称';

  @override
  String get businessNameHint => '例如：我的商店';

  @override
  String get businessLogo => '徽标（可选）';

  @override
  String get tapToAddLogo => '点击添加徽标';

  @override
  String get contactInfo => '联系信息';

  @override
  String get phoneNumber => '电话';

  @override
  String get phoneHint => '例如：+86 138 0000 0000';

  @override
  String get emailAddress => '电子邮件';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get optionalField => '（可选）';

  @override
  String get preferences => '偏好设置';

  @override
  String get selectYourLanguage => '选择您的语言';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Português';

  @override
  String get chinese => '中文';

  @override
  String get selectYourCurrency => '货币';

  @override
  String get security => '安全';

  @override
  String get createAdminPassword => '创建管理员密码';

  @override
  String get passwordHint => '至少6个字符';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get confirmPasswordHint => '重复密码';

  @override
  String get passwordMismatch => '密码不匹配';

  @override
  String get passwordTooShort => '至少6个字符';

  @override
  String get adminPasswordInfo => '保护管理员功能';

  @override
  String get finish => '完成';

  @override
  String get skip => '跳过';

  @override
  String get next => '下一步';

  @override
  String get previous => '上一步';

  @override
  String get allSet => '全部完成！';

  @override
  String get readyToStart => '您的业务已准备好开始';

  @override
  String get startNow => '立即开始';

  @override
  String get proioApp => 'Proïon';

  @override
  String get businessManagementSystem => '管理系统';

  @override
  String get loginAsAdministrator => '作为管理员登录';

  @override
  String get enterPassword => '密码';

  @override
  String get loginButton => '作为管理员登录';

  @override
  String get continueAsUser => '作为用户继续';

  @override
  String get userOnlyMode => '用户：仅查看和创建订单';

  @override
  String get adminAccessRequired => '需要管理员访问权限';

  @override
  String get adminLoginRequired => '您需要作为管理员登录';

  @override
  String get tryAgain => '重试';

  @override
  String get completeAllFields => '请填写所有字段';

  @override
  String get passwordMinLength => '密码至少需要4个字符';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get passwordConfiguredSuccessfully => '密码配置成功';

  @override
  String get errorConfiguringPassword => '配置密码时出错';

  @override
  String get initialSetup => '初始设置';

  @override
  String get configureAdminPassword => '配置您的管理员密码';

  @override
  String get firstTimeMessage => '这是您第一次使用该应用程序。请配置一个安全密码。';

  @override
  String get newPassword => '新密码';

  @override
  String get minimumCharacters => '至少4个字符';

  @override
  String get confirmPasswordLabel => '确认密码';

  @override
  String get repeatPassword => '重复密码';

  @override
  String get configureAndContinue => '配置并继续';

  @override
  String get savePasswordSecurely => '🔒 请将此密码保存在安全的地方';

  @override
  String get loading => '正在加载...';

  @override
  String get legalDisclaimer => '⚠️ 此收据仅供内部控制使用，不构成有效的税务凭证。';

  @override
  String get adminOnly => '仅限管理员';

  @override
  String get adminOnlyCurrencyMessage => '只有管理员可以更改业务货币。';

  @override
  String get understood => '明白了';

  @override
  String minNameCharacters(int count) {
    return '名称必须至少 $count 个字符';
  }

  @override
  String get nameTooLong => '名称太长';

  @override
  String get invalidPhoneNumber => '电话号码无效';

  @override
  String unexpectedError(String error) {
    return '意外错误：$error';
  }

  @override
  String get logoSelectedSuccess => '成功选择徽标';

  @override
  String errorSelectingImage(String error) {
    return '选择图像时出错：$error';
  }

  @override
  String get profileUpdatedSuccess => '个人资料已成功更新';

  @override
  String get errorSavingProfile => '保存个人资料时出错';
}
