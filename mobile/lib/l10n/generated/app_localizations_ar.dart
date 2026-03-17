// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مدير نقاط الاتصال MikroTik';

  @override
  String get wassal => 'وصّال';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInSubtitle => 'سجل دخولك لإدارة نقاط الاتصال MikroTik';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMinLength => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get forgotPasswordQ => 'نسيت كلمة المرور؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ ';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get cannotConnectServer =>
      'لا يمكن الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get connectionTimeout => 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';

  @override
  String get invalidCredentials =>
      'بريد إلكتروني أو كلمة مرور غير صحيحة. حاول مرة أخرى.';

  @override
  String get checkInputTryAgain =>
      'يرجى التحقق من المدخلات والمحاولة مرة أخرى.';

  @override
  String get serverError => 'خطأ في الخادم. يرجى المحاولة لاحقاً.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get signUpSubtitle => 'سجل للبدء في إدارة MikroTik';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get enterFullName => 'أدخل اسمك الكامل';

  @override
  String get pleaseEnterName => 'يرجى إدخال اسمك';

  @override
  String get nameMinLength => 'الاسم يجب أن يكون 3 أحرف على الأقل';

  @override
  String get createPassword => 'أنشئ كلمة مرور';

  @override
  String get pleaseEnterAPassword => 'يرجى إدخال كلمة مرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get reenterPassword => 'أعد إدخال كلمة المرور';

  @override
  String get pleaseConfirmPassword => 'يرجى تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get emailAlreadyRegistered =>
      'هذا البريد مسجل بالفعل. يرجى تسجيل الدخول بدلاً من ذلك.';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رمز إعادة التعيين.';

  @override
  String get sendResetCode => 'إرسال رمز إعادة التعيين';

  @override
  String get resetCodeSent =>
      'تم إرسال رمز إعادة التعيين! تحقق من بريدك الإلكتروني.';

  @override
  String get failedSendResetCode =>
      'فشل إرسال رمز إعادة التعيين. حاول مرة أخرى.';

  @override
  String get somethingWentWrong => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String resetPasswordSubtitle(String email) {
    return 'أدخل الرمز المكون من 6 أرقام المرسل إلى $email وكلمة المرور الجديدة.';
  }

  @override
  String get resetCode => 'رمز إعادة التعيين';

  @override
  String get enterResetCode => 'أدخل الرمز المكون من 6 أرقام';

  @override
  String get pleaseEnterResetCode => 'يرجى إدخال رمز إعادة التعيين';

  @override
  String get codeMustBe6Digits => 'الرمز يجب أن يكون 6 أرقام';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get enterNewPassword => 'أدخل كلمة المرور الجديدة';

  @override
  String get pleaseEnterNewPassword => 'يرجى إدخال كلمة مرور جديدة';

  @override
  String get passwordMin8Chars => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';

  @override
  String get reenterNewPassword => 'أعد إدخال كلمة المرور الجديدة';

  @override
  String get passwordResetSuccess =>
      'تم إعادة تعيين كلمة المرور بنجاح! يرجى تسجيل الدخول.';

  @override
  String get failedResetPassword =>
      'فشل إعادة تعيين كلمة المرور. حاول مرة أخرى.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get management => 'الإدارة';

  @override
  String get monitoringAnalytics => 'المراقبة والتحليلات';

  @override
  String get monitoringSubtitle => 'إحصائيات مباشرة وعرض النطاق والحالة';

  @override
  String get salesReports => 'المبيعات والتقارير';

  @override
  String get salesReportsSubtitle => 'مبيعات القسائم والإيرادات والتصدير';

  @override
  String get general => 'عام';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get viewPlansManageSub => 'عرض الخطط وإدارة الاشتراك';

  @override
  String get active => 'نشط';

  @override
  String get expired => 'منتهي';

  @override
  String get none => 'لا يوجد';

  @override
  String get noActivePlanSelect => 'لا توجد خطة نشطة — اختر واحدة';

  @override
  String get billsPayments => 'الفواتير والمدفوعات';

  @override
  String get viewPaymentHistory => 'عرض سجل المدفوعات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get manageYourAccount => 'إدارة حسابك';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get configureAlerts => 'إعداد التنبيهات';

  @override
  String get about => 'حول';

  @override
  String get appVersion => 'إصدار التطبيق 1.0.0';

  @override
  String get language => 'اللغة';

  @override
  String get languageSubtitle => 'تغيير لغة التطبيق';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String hello(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get hotspotOverview => 'إليك نظرة عامة على نقاط الاتصال';

  @override
  String get totalRouters => 'إجمالي الراوترات';

  @override
  String get online => 'متصل';

  @override
  String get activeUsers => 'المستخدمون النشطون';

  @override
  String get users => 'مستخدمون';

  @override
  String get totalUsers => 'إجمالي المستخدمين';

  @override
  String get registered => 'مسجلون';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get activeUsersRealtime => 'المستخدمون النشطون - مباشر';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get addRouter => 'إضافة راوتر';

  @override
  String get printVoucher => 'طباعة قسيمة';

  @override
  String get loadingDashboard => 'جاري تحميل لوحة التحكم...';

  @override
  String get failedLoadDashboard => 'فشل تحميل لوحة التحكم';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get subscriptionRequired => 'مطلوب اشتراك';

  @override
  String get subscriptionRequiredMessage =>
      'تحتاج إلى اشتراك نشط لاستخدام هذه الميزة. هل تريد عرض الخطط المتاحة؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get viewPlans => 'عرض الخطط';

  @override
  String daysRemaining(int days) {
    return '$days يوم متبقي';
  }

  @override
  String get noPlan => 'لا توجد خطة';

  @override
  String get noSubscription => 'لا يوجد اشتراك';

  @override
  String get tapToSelectPlan => 'اضغط لاختيار خطة';

  @override
  String get tapToManagePlan => 'اضغط لإدارة خطتك';

  @override
  String get routers => 'الراوترات';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get vouchers => 'القسائم';

  @override
  String get loadingRouters => 'جاري تحميل الراوترات...';

  @override
  String get loadingStats => 'جاري تحميل الإحصائيات...';

  @override
  String get connectionFailed => 'فشل الاتصال';

  @override
  String get goBack => 'رجوع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noRoutersFound => 'لم يتم العثور على راوترات';

  @override
  String get addRouterToMonitor => 'أضف راوتر للبدء بالمراقبة';

  @override
  String get tapRefreshLoadStats => 'اضغط تحديث لتحميل الإحصائيات';

  @override
  String get routerOnline => 'الراوتر متصل';

  @override
  String get routerOffline => 'الراوتر غير متصل';

  @override
  String uptime(String value) {
    return 'وقت التشغيل: $value';
  }

  @override
  String get bandwidth => 'عرض النطاق';

  @override
  String get cpuLoad => 'حمل المعالج';

  @override
  String get memory => 'الذاكرة';

  @override
  String get routerDetails => 'تفاصيل الراوتر';

  @override
  String get routerName => 'اسم الراوتر';

  @override
  String get ipAddress => 'عنوان IP';

  @override
  String get apiPort => 'منفذ API';

  @override
  String get model => 'الموديل';

  @override
  String get dailySales => 'المبيعات اليومية';

  @override
  String get monthlySales => 'المبيعات الشهرية';

  @override
  String dataPoints(int count) {
    return '$count نقطة بيانات';
  }

  @override
  String get daily => 'يومي';

  @override
  String get monthly => 'شهري';

  @override
  String get noSalesData => 'لا توجد بيانات مبيعات';

  @override
  String get salesWillAppear => 'ستظهر المبيعات هنا عند إجراء أول عملية بيع';

  @override
  String get error => 'خطأ';

  @override
  String get recentSales => 'المبيعات الأخيرة';

  @override
  String get viewSalesHistory => 'عرض سجل المبيعات';

  @override
  String get loadingSalesHistory => 'جاري تحميل سجل المبيعات...';

  @override
  String get availablePlans => 'الخطط المتاحة';

  @override
  String get selectPlanFits => 'اختر الخطة المناسبة لاحتياجاتك';

  @override
  String get noActiveSubscription => 'لا يوجد اشتراك نشط';

  @override
  String get choosePlanBelow => 'اختر خطة أدناه للبدء';

  @override
  String get subscriptionExpired => 'انتهى الاشتراك';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get expires => 'ينتهي';

  @override
  String get maxRouters => 'أقصى عدد راوترات';

  @override
  String get maxHotspotUsers => 'أقصى عدد مستخدمي نقطة الاتصال';

  @override
  String get unlimited => 'غير محدود';

  @override
  String get failedLoadPlans => 'فشل تحميل الخطط';

  @override
  String get checkConnectionTryAgain =>
      'يرجى التحقق من اتصالك والمحاولة مرة أخرى';

  @override
  String get noPlansAvailable => 'لا توجد خطط متاحة';

  @override
  String get contactAdminPlans => 'تواصل مع المسؤول لإعداد خطط الاشتراك';

  @override
  String get current => 'الحالي';

  @override
  String get currentPlan => 'الخطة الحالية';

  @override
  String get selectPlan => 'اختيار الخطة';

  @override
  String upToRouters(int count) {
    return 'حتى $count راوتر';
  }

  @override
  String get unlimitedHotspotUsers => 'مستخدمون غير محدودين';

  @override
  String upToHotspotUsers(int count) {
    return 'حتى $count مستخدم';
  }

  @override
  String get voucherSystemIncluded => 'نظام القسائم مشمول';

  @override
  String get noVoucherSystem => 'بدون نظام قسائم';

  @override
  String get reportsAnalytics => 'التقارير والتحليلات';

  @override
  String get noReports => 'بدون تقارير';

  @override
  String get requestSubmitted => 'تم إرسال الطلب';

  @override
  String paymentFor(String plan) {
    return 'الدفع لـ $plan';
  }

  @override
  String get bankInfo => 'معلومات البنك';

  @override
  String get uploadProof => 'رفع الإثبات';

  @override
  String get transferInstructions =>
      'حوّل المبلغ أدناه إلى الحساب البنكي، ثم ارفع تأكيد الدفع.';

  @override
  String get bank => 'البنك';

  @override
  String get accountName => 'اسم الحساب';

  @override
  String get accountNumber => 'رقم الحساب';

  @override
  String get amount => 'المبلغ';

  @override
  String get iveSentMoney => 'لقد أرسلت المبلغ';

  @override
  String get failedLoadBankInfo => 'فشل تحميل معلومات البنك';

  @override
  String failedCreateRequest(String error) {
    return 'فشل إنشاء الطلب: $error';
  }

  @override
  String get uploadPaymentProof => 'ارفع لقطة شاشة أو صورة لتأكيد الدفع.';

  @override
  String get tapToSelectImage => 'اضغط لاختيار صورة';

  @override
  String get pngJpgUpTo5mb => 'PNG، JPG حتى 5 ميجابايت';

  @override
  String get changeImage => 'تغيير الصورة';

  @override
  String get skipForNow => 'تخطي الآن';

  @override
  String get requestSavedUploadLater =>
      'تم حفظ الطلب. يمكنك رفع الإثبات من الفواتير لاحقاً.';

  @override
  String get submitProof => 'إرسال الإثبات';

  @override
  String failedUploadProof(String error) {
    return 'فشل رفع الإثبات: $error';
  }

  @override
  String get paymentProofSubmitted => 'تم إرسال إثبات الدفع';

  @override
  String get subscriptionRequestSubmitted =>
      'تم إرسال طلب الاشتراك.\nسيقوم المسؤول بمراجعة دفعتك وتفعيل خطتك.';

  @override
  String get done => 'تم';

  @override
  String get copiedToClipboard => 'تم النسخ';

  @override
  String get failedLoadPayments => 'فشل تحميل المدفوعات';

  @override
  String get noPaymentsYet => 'لا توجد مدفوعات بعد';

  @override
  String get paymentHistoryAppear => 'سيظهر سجل المدفوعات هنا';

  @override
  String get approved => 'موافق عليه';

  @override
  String get rejected => 'مرفوض';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get date => 'التاريخ';

  @override
  String get method => 'الطريقة';

  @override
  String get planDuration => 'مدة الخطة';

  @override
  String daysDuration(int days) {
    return '$days يوم';
  }

  @override
  String get notes => 'ملاحظات';

  @override
  String get reviewed => 'تمت المراجعة';

  @override
  String get paymentProof => 'إثبات الدفع';

  @override
  String get failedLoadImage => 'فشل تحميل الصورة';

  @override
  String get uploading => 'جاري الرفع...';

  @override
  String get proofUploadedSuccess => 'تم رفع الإثبات بنجاح';

  @override
  String failedUpload(String error) {
    return 'فشل الرفع: $error';
  }

  @override
  String get noProofUploaded => 'لم يتم رفع إثبات';

  @override
  String get searchByCodeOrPlan => 'البحث بالرمز أو الخطة...';

  @override
  String get filterVouchers => 'تصفية القسائم';

  @override
  String get all => 'الكل';

  @override
  String get unused => 'غير مستخدم';

  @override
  String get total => 'الإجمالي';

  @override
  String selected(int count) {
    return 'تم اختيار $count';
  }

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get deselectAll => 'إلغاء تحديد الكل';

  @override
  String get generate => 'إنشاء';

  @override
  String get loadingVouchers => 'جاري تحميل القسائم...';

  @override
  String get scrollForMore => 'اسحب لعرض المزيد';

  @override
  String get shareVoucher => 'مشاركة القسيمة';

  @override
  String get shareAsImage => 'مشاركة كصورة';

  @override
  String get beautifulStyledCard => 'بطاقة قسيمة مصممة بشكل جميل';

  @override
  String get shareAsText => 'مشاركة كنص';

  @override
  String get plainTextFormat => 'تنسيق نص عادي';

  @override
  String get shareQRCode => 'مشاركة رمز QR';

  @override
  String get scannableQRImage => 'صورة QR قابلة للمسح';

  @override
  String get printVoucherAction => 'طباعة القسيمة';

  @override
  String get shareVoucherAction => 'مشاركة القسيمة';

  @override
  String get copyCode => 'نسخ الرمز';

  @override
  String get codeCopied => 'تم نسخ الرمز';

  @override
  String get showQRCode => 'عرض رمز QR';

  @override
  String get deleteVoucher => 'حذف القسيمة';

  @override
  String get deleteVoucherConfirm =>
      'هل أنت متأكد من حذف هذه القسيمة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get delete => 'حذف';

  @override
  String get deleteVouchers => 'حذف القسائم';

  @override
  String deleteVouchersConfirm(int count) {
    return 'هل أنت متأكد من حذف $count قسيمة؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get deletingVouchers => 'جاري حذف القسائم...';

  @override
  String get scanToConnect => 'امسح للاتصال';

  @override
  String get close => 'إغلاق';

  @override
  String get print => 'طباعة';

  @override
  String get share => 'مشاركة';

  @override
  String get generateVoucher => 'إنشاء قسيمة';

  @override
  String get selectRouter => 'اختيار الراوتر';

  @override
  String get chooseRouterForVouchers => 'اختر الراوتر لإنشاء القسائم';

  @override
  String get configure => 'إعداد';

  @override
  String get confirm => 'تأكيد';

  @override
  String get configurePlan => 'إعداد الخطة';

  @override
  String get setupVoucherDetails => 'إعداد تفاصيل القسيمة';

  @override
  String get limitType => 'نوع الحد';

  @override
  String get timeLimit => 'حد الوقت';

  @override
  String get dataLimit => 'حد البيانات';

  @override
  String get totalUse => 'إجمالي الاستخدام';

  @override
  String get totalOnlineTime => 'إجمالي وقت الاتصال';

  @override
  String get countsOnlyConnected => 'يحسب فقط عند الاتصال';

  @override
  String get totalTime => 'إجمالي الوقت';

  @override
  String get countsEvenOffline => 'يحسب حتى عند عدم الاتصال';

  @override
  String get validityDuration => 'مدة الصلاحية';

  @override
  String get price => 'السعر';

  @override
  String get quantity => 'الكمية';

  @override
  String get required => 'مطلوب';

  @override
  String get advancedOptions => 'خيارات متقدمة';

  @override
  String get codeFormat => 'تنسيق الرمز';

  @override
  String get numbersOnly => 'أرقام فقط (مثال: 12345678)';

  @override
  String get numbersAndLetters => 'أرقام وحروف (مثال: AB12CD34)';

  @override
  String get lettersOnly => 'حروف فقط (مثال: ABCDEFGH)';

  @override
  String get continueBtn => 'متابعة';

  @override
  String get confirmGenerate => 'تأكيد وإنشاء';

  @override
  String get reviewVoucherSettings => 'راجع إعدادات القسيمة';

  @override
  String get plan => 'الخطة';

  @override
  String get duration => 'المدة';

  @override
  String get router => 'الراوتر';

  @override
  String vouchersCount(int count) {
    return '$count قسيمة';
  }

  @override
  String get priceEach => 'سعر القسيمة';

  @override
  String get noRoutersFoundAdd => 'لم يتم العثور على راوترات';

  @override
  String get addRouterFirst => 'أضف راوتر أولاً لإنشاء القسائم';

  @override
  String get unknownRouter => 'راوتر غير معروف';

  @override
  String get noIP => 'بدون IP';

  @override
  String get loadingProfiles => 'جاري تحميل الملفات...';

  @override
  String get noProfilesOnRouter => 'لم يتم العثور على ملفات في هذا الراوتر';

  @override
  String generateVouchersBtn(int count) {
    return 'إنشاء $count قسيمة';
  }

  @override
  String get printVouchers => 'طباعة القسائم';

  @override
  String get printSettings => 'إعدادات الطباعة';

  @override
  String get paperFormat => 'حجم الورق';

  @override
  String get a4Paper => 'ورق A4';

  @override
  String get thermal58mm => 'حراري 58مم';

  @override
  String get thermal80mm => 'حراري 80مم';

  @override
  String get cardDesign => 'تصميم البطاقة';

  @override
  String get classic => 'كلاسيكي';

  @override
  String get modern => 'حديث';

  @override
  String get minimal => 'بسيط';

  @override
  String columns(int count) {
    return 'الأعمدة: $count';
  }

  @override
  String get applyChanges => 'تطبيق التغييرات';

  @override
  String vouchersGenerated(int count) {
    return 'تم إنشاء $count قسيمة!';
  }

  @override
  String get voucherGenerated => 'تم إنشاء القسيمة!';

  @override
  String get vouchersReadyToUse => 'قسائمك جاهزة للاستخدام';

  @override
  String get copy => 'نسخ';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get emailAddressLabel => 'البريد الإلكتروني';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get networkSettings => 'إعدادات الشبكة';

  @override
  String get networkName => 'اسم الشبكة';

  @override
  String get networkNameHelper => 'يظهر هذا الاسم على القسائم المطبوعة';

  @override
  String get security => 'الأمان';

  @override
  String get leaveEmptyKeepPassword =>
      'اتركه فارغاً للإبقاء على كلمة المرور الحالية';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get confirmLogout => 'تأكيد الخروج';

  @override
  String get confirmLogoutMessage => 'هل أنت متأكد من تسجيل الخروج من حسابك؟';

  @override
  String get logout => 'خروج';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get configureNotifications =>
      'حدد الإشعارات التي تريد تلقيها من التطبيق.';

  @override
  String get routerAlerts => 'تنبيهات الراوتر';

  @override
  String get routerStatus => 'حالة الراوتر';

  @override
  String get routerStatusSubtitle =>
      'احصل على إشعار عندما تتصل أو تنقطع راوتراتك';

  @override
  String get routerStatusEnabled => 'تم تفعيل إشعارات حالة الراوتر';

  @override
  String get routerStatusDisabled => 'تم تعطيل إشعارات حالة الراوتر';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get soon => 'قريباً';

  @override
  String get lowBalanceAlert => 'تنبيه الرصيد المنخفض';

  @override
  String get lowBalanceSubtitle => 'احصل على إشعار عند انخفاض رصيد القسائم';

  @override
  String get dailySalesReport => 'تقرير المبيعات اليومي';

  @override
  String get dailySalesSubtitle => 'استلم ملخص المبيعات اليومي';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get checkInternetConnection =>
      'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get connectionError => 'خطأ في الاتصال';

  @override
  String get serverErrorTitle => 'خطأ في الخادم';

  @override
  String get serverErrorMessage =>
      'نواجه مشكلة في الاتصال بالخادم. يرجى المحاولة لاحقاً.';

  @override
  String get monitoring => 'المراقبة';

  @override
  String get reports => 'التقارير';

  @override
  String get noRoutersYet => 'لا توجد أجهزة توجيه بعد';

  @override
  String get noRoutersMessage =>
      'أضف أول راوتر MikroTik لبدء إدارة قسائم نقاط الاتصال ومراقبة الاتصالات.';

  @override
  String get noVouchersYet => 'لا توجد قسائم بعد';

  @override
  String get noVouchersMessage =>
      'أنشئ أول قسيمة لبدء بيع الوصول للإنترنت. تأكد من إضافة راوتر أولاً.';

  @override
  String get createVoucher => 'إنشاء قسيمة';

  @override
  String get noSalesYet => 'لا توجد مبيعات بعد';

  @override
  String get noSalesMessage =>
      'سيظهر سجل مبيعاتك هنا عند بدء بيع القسائم للعملاء.';

  @override
  String get noActiveSessions => 'لا توجد جلسات نشطة';

  @override
  String get noActiveSessionsMessage =>
      'لا يوجد مستخدمون متصلون حالياً بنقطة الاتصال. ستظهر الجلسات النشطة هنا.';

  @override
  String get noResultsFound => 'لم يتم العثور على نتائج';

  @override
  String noResultsMessage(String query) {
    return 'لم نتمكن من العثور على نتائج لـ \"$query\". جرب مصطلح بحث مختلف.';
  }

  @override
  String get somethingWentWrongTitle => 'حدث خطأ ما';

  @override
  String get subscriptionRequiredTitle => 'مطلوب اشتراك';

  @override
  String get subscriptionRequiredBody =>
      'تحتاج إلى اشتراك نشط للوصول إلى هذه الميزة. يرجى الاشتراك في خطة للمتابعة.';

  @override
  String get goToSubscriptions => 'الذهاب للاشتراكات';

  @override
  String get manual => 'يدوي';

  @override
  String get byScript => 'بالسكربت';

  @override
  String get routerAddedSuccess => 'تمت إضافة الراوتر بنجاح!';

  @override
  String get locationOptional => 'الموقع (اختياري)';

  @override
  String vpnIpAssigned(String ip) {
    return 'تم تعيين IP الـ VPN: $ip';
  }

  @override
  String get runCommandsOnMikroTik =>
      'نفذ هذه الأوامر في طرفية MikroTik (RouterOS v7):';

  @override
  String get importantNotes => 'ملاحظات مهمة:';

  @override
  String get importantNotesBody =>
      '• يتطلب RouterOS v7 أو أحدث (دعم WireGuard)\n• نفذ كل أمر بالترتيب في طرفية MikroTik\n• نفق VPN يربط الراوتر بوصّال بأمان';

  @override
  String get copyAllCommands => 'نسخ جميع الأوامر';

  @override
  String get allCommandsCopied => 'تم نسخ جميع الأوامر!';

  @override
  String stepCopied(int number) {
    return 'تم نسخ الخطوة $number!';
  }

  @override
  String get noSetupSteps => 'لا توجد خطوات إعداد متاحة.';

  @override
  String get needSubscriptionAddRouters =>
      'تحتاج إلى اشتراك نشط لإضافة راوترات. يرجى الاشتراك في خطة للمتابعة.';

  @override
  String get needSubscriptionFeature =>
      'تحتاج إلى اشتراك نشط لاستخدام هذه الميزة. هل تريد عرض الخطط المتاحة؟';

  @override
  String get errorConnectionTimeout =>
      'انتهت مهلة الاتصال.\n\nقد يكون الخادم مشغولاً أو غير متاح. يرجى المحاولة بعد قليل.';

  @override
  String get errorConnectionFailed =>
      'تعذر الاتصال بالخادم.\n\nيرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorDnsFailure =>
      'فشل تحليل DNS.\n\nقد تكون شبكتك تحظر هذا النطاق. جرب التبديل إلى شبكة مختلفة.';

  @override
  String get errorConnectionRefused =>
      'تم رفض الاتصال.\n\nالخادم لا يقبل الاتصالات. يرجى المحاولة لاحقاً.';

  @override
  String get errorTlsFailure =>
      'فشل الاتصال الآمن.\n\nقد تكون شبكتك تعترض حركة البيانات. جرب شبكة مختلفة.';

  @override
  String get errorNetworkUnreachable =>
      'الشبكة غير قابلة للوصول.\n\nيرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get errorAuthFailed =>
      'فشلت المصادقة.\n\nربما انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorPermissionDenied =>
      'تم رفض الإذن.\n\nليس لديك صلاحية الوصول إلى هذا المورد.';

  @override
  String get errorNotFound =>
      'المورد غير موجود.\n\nلم يتم العثور على البيانات المطلوبة.';

  @override
  String errorServerGeneric(int statusCode) {
    return 'خطأ في الخادم ($statusCode).\n\nيرجى المحاولة لاحقاً.';
  }

  @override
  String get errorRequestCancelled => 'تم إلغاء الطلب.';

  @override
  String get errorNetwork =>
      'خطأ في الشبكة.\n\nيرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorUnexpected => 'حدث خطأ غير متوقع.';

  @override
  String get ok => 'حسناً';

  @override
  String get dismiss => 'تجاهل';

  @override
  String get sessions => 'الجلسات';

  @override
  String get activeSessions => 'الجلسات النشطة';

  @override
  String get allSessions => 'جميع الجلسات';

  @override
  String get sessionDetails => 'تفاصيل الجلسة';

  @override
  String get terminateSession => 'إنهاء الجلسة';

  @override
  String get sessionTerminated => 'تم إنهاء الجلسة بنجاح';

  @override
  String get noSessionsFound => 'لم يتم العثور على جلسات';

  @override
  String get hotspotProfiles => 'ملفات تعريف الهوت سبوت';

  @override
  String get createProfile => 'إنشاء ملف';

  @override
  String get profileName => 'اسم الملف';

  @override
  String get rateLimit => 'حد السرعة';

  @override
  String get sharedUsers => 'المستخدمون المشتركون';

  @override
  String get sessionTimeout => 'مهلة الجلسة';

  @override
  String get idleTimeout => 'مهلة الخمول';

  @override
  String get keepaliveTimeout => 'مهلة البقاء متصلاً';

  @override
  String get deleteRouter => 'حذف الراوتر';

  @override
  String get deleteRouterConfirm =>
      'هل أنت متأكد من حذف هذا الراوتر؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get routerDeleted => 'تم حذف الراوتر بنجاح';

  @override
  String get editRouter => 'تعديل الراوتر';

  @override
  String get routerUpdated => 'تم تحديث الراوتر بنجاح';

  @override
  String get failedDeleteRouter => 'فشل حذف الراوتر';

  @override
  String get failedUpdateRouter => 'فشل تحديث الراوتر';

  @override
  String get rebootRouter => 'إعادة تشغيل الراوتر';

  @override
  String get rebootRouterConfirm => 'هل أنت متأكد من إعادة تشغيل هذا الراوتر؟';

  @override
  String get rebootSuccess => 'تم بدء إعادة تشغيل الراوتر';

  @override
  String get splashConnecting => 'جاري الاتصال بالخادم...';

  @override
  String get splashCheckingAuth => 'جاري التحقق من المصادقة...';

  @override
  String get splashLoadingProfile => 'جاري تحميل الملف الشخصي...';

  @override
  String get splashReady => 'جاهز!';

  @override
  String get splashFailed => 'فشل الاتصال';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get contactUsSubtitle => 'أرسل رسالة إلى فريق الإدارة';

  @override
  String get subject => 'الموضوع';

  @override
  String get message => 'الرسالة';

  @override
  String get sendMessage => 'إرسال الرسالة';

  @override
  String get messageSent => 'تم إرسال الرسالة بنجاح!';

  @override
  String get myMessages => 'رسائلي';

  @override
  String get noMessages => 'لا توجد رسائل بعد';

  @override
  String get replied => 'تمت الإجابة';

  @override
  String get unread => 'غير مقروءة';

  @override
  String get read => 'مقروءة';

  @override
  String get adminReply => 'رد الإدارة';

  @override
  String get subjectRequired => 'يرجى إدخال الموضوع';

  @override
  String get messageRequired => 'يرجى إدخال الرسالة';

  @override
  String get sendMessageFailed => 'فشل إرسال الرسالة. يرجى المحاولة مرة أخرى.';

  @override
  String get myRouters => 'أجهزة التوجيه';

  @override
  String get addFirstRouterHint => 'أضف أول راوتر MikroTik للبدء.';

  @override
  String get errorLoadingRouters => 'خطأ في تحميل أجهزة التوجيه';

  @override
  String get deleteRouterTitle => 'حذف الراوتر';

  @override
  String deleteRouterMsg(String routerName) {
    return 'هل أنت متأكد من حذف \'\'$routerName\'\'؟';
  }

  @override
  String get addProfile => 'إضافة ملف تعريف';

  @override
  String get failedLoadProfiles => 'فشل تحميل الملفات';

  @override
  String get noProfilesFound => 'لا توجد ملفات تعريف';

  @override
  String get noProfilesHint => 'اضغط على الزر أدناه لإنشاء أول ملف تعريف';

  @override
  String get aboutTitle => 'حول وصّال';

  @override
  String get aboutDescription => 'منصة إدارة هوت سبوت MikroTik';

  @override
  String get version => 'الإصدار';

  @override
  String get networkDiagnostics => 'تشخيص الشبكة';

  @override
  String get diagnoseNetwork => 'تشخيص الشبكة';

  @override
  String get runningDiagnostics => 'جاري التشخيص...';

  @override
  String get diagWifiConnectivity => 'WiFi / بيانات الجوال';

  @override
  String get diagDnsApi => 'DNS: api.wassal.tech';

  @override
  String get diagDnsGoogle => 'DNS: google.com';

  @override
  String get diagHttpHealth => 'HTTP: حالة الخادم';

  @override
  String get diagIpVersion => 'إصدار IP';

  @override
  String get diagResponseTime => 'وقت الاستجابة';

  @override
  String get diagPassed => 'نجح';

  @override
  String get diagFailed => 'فشل';

  @override
  String get diagSkipped => 'تم التخطي';

  @override
  String get diagRunAgain => 'إعادة التشخيص';

  @override
  String diagResolvedTo(String ip) {
    return 'تم التحليل إلى $ip';
  }

  @override
  String diagResponseMs(int ms) {
    return '$ms مللي ثانية';
  }

  @override
  String get diagNoConnection => 'لم يتم اكتشاف اتصال بالشبكة';

  @override
  String get diagDnsFailed => 'تعذر تحليل اسم المضيف';

  @override
  String get diagServerOk => 'الخادم قابل للوصول';

  @override
  String get diagServerUnreachable => 'الخادم غير قابل للوصول';

  @override
  String get diagIpv4 => 'IPv4';

  @override
  String get diagIpv6 => 'IPv6';

  @override
  String get diagIpv4And6 => 'IPv4 + IPv6';

  @override
  String get diagSummaryAllGood =>
      'جميع الفحوصات نجحت. اتصالك بالخادم يعمل بشكل صحيح.';

  @override
  String get diagSummaryDnsIssue =>
      'فشل تحليل DNS. قد تكون شبكتك تحظر هذا النطاق.';

  @override
  String get diagSummaryServerDown =>
      'DNS يعمل لكن الخادم غير قابل للوصول. قد يكون الخادم معطلاً.';

  @override
  String get diagSummaryNoInternet =>
      'لم يتم اكتشاف اتصال بالإنترنت. تحقق من WiFi أو بيانات الجوال.';
}
