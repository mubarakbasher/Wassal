// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MikroTik Hotspot Manager';

  @override
  String get wassal => 'Wassal';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInSubtitle => 'Sign in to manage your MikroTik hotspots';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get forgotPasswordQ => 'Forgot Password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get cannotConnectServer =>
      'Cannot connect to server. Please check your internet connection.';

  @override
  String get connectionTimeout => 'Connection timeout. Please try again.';

  @override
  String get invalidCredentials =>
      'Invalid email or password. Please try again.';

  @override
  String get checkInputTryAgain => 'Please check your input and try again.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpSubtitle =>
      'Sign up to get started with MikroTik management';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get nameMinLength => 'Name must be at least 3 characters';

  @override
  String get createPassword => 'Create a password';

  @override
  String get pleaseEnterAPassword => 'Please enter a password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get reenterPassword => 'Re-enter your password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get emailAlreadyRegistered =>
      'This email is already registered. Please login instead.';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address and we will send you a reset code.';

  @override
  String get sendResetCode => 'Send Reset Code';

  @override
  String get resetCodeSent =>
      'Reset code sent! Check your email or server logs.';

  @override
  String get failedSendResetCode => 'Failed to send reset code. Try again.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String resetPasswordSubtitle(String email) {
    return 'Enter the 6-digit code sent to $email and your new password.';
  }

  @override
  String get resetCode => 'Reset Code';

  @override
  String get enterResetCode => 'Enter 6-digit code';

  @override
  String get pleaseEnterResetCode => 'Please enter the reset code';

  @override
  String get codeMustBe6Digits => 'Code must be 6 digits';

  @override
  String get newPassword => 'New Password';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get passwordMin8Chars => 'Password must be at least 8 characters';

  @override
  String get reenterNewPassword => 'Re-enter new password';

  @override
  String get passwordResetSuccess =>
      'Password reset successfully! Please log in.';

  @override
  String get failedResetPassword => 'Failed to reset password. Try again.';

  @override
  String get settings => 'Settings';

  @override
  String get management => 'Management';

  @override
  String get monitoringAnalytics => 'Monitoring & Analytics';

  @override
  String get monitoringSubtitle => 'Real-time stats, bandwidth, and health';

  @override
  String get salesReports => 'Sales & Reports';

  @override
  String get salesReportsSubtitle => 'Voucher sales, revenue, and exports';

  @override
  String get general => 'General';

  @override
  String get subscription => 'Subscription';

  @override
  String get viewPlansManageSub => 'View plans and manage subscription';

  @override
  String get active => 'Active';

  @override
  String get expired => 'Expired';

  @override
  String get none => 'None';

  @override
  String get noActivePlanSelect => 'No active plan — select one';

  @override
  String get billsPayments => 'Bills & Payments';

  @override
  String get viewPaymentHistory => 'View your payment history';

  @override
  String get profile => 'Profile';

  @override
  String get manageYourAccount => 'Manage your account';

  @override
  String get notifications => 'Notifications';

  @override
  String get configureAlerts => 'Configure alerts';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App version 1.0.0';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Change app language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String hello(String name) {
    return 'Hello, $name';
  }

  @override
  String get hotspotOverview => 'Here is your hotspot overview';

  @override
  String get totalRouters => 'Total Routers';

  @override
  String get online => 'Online';

  @override
  String get activeUsers => 'Active Users';

  @override
  String get users => 'Users';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get registered => 'Registered';

  @override
  String get revenue => 'Revenue';

  @override
  String get activeUsersRealtime => 'Active Users Real-time';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addRouter => 'Add Router';

  @override
  String get printVoucher => 'Print Voucher';

  @override
  String get loadingDashboard => 'Loading dashboard...';

  @override
  String get failedLoadDashboard => 'Failed to Load Dashboard';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get subscriptionRequired => 'Subscription Required';

  @override
  String get subscriptionRequiredMessage =>
      'You need an active subscription to use this feature. Would you like to view available plans?';

  @override
  String get cancel => 'Cancel';

  @override
  String get viewPlans => 'View Plans';

  @override
  String daysRemaining(int days) {
    return '$days days remaining';
  }

  @override
  String get noPlan => 'No Plan';

  @override
  String get noSubscription => 'No Subscription';

  @override
  String get tapToSelectPlan => 'Tap to select a plan';

  @override
  String get tapToManagePlan => 'Tap to manage your plan';

  @override
  String get routers => 'Routers';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get vouchers => 'Vouchers';

  @override
  String get loadingRouters => 'Loading routers...';

  @override
  String get loadingStats => 'Loading stats...';

  @override
  String get connectionFailed => 'Connection Failed';

  @override
  String get goBack => 'Go Back';

  @override
  String get retry => 'Retry';

  @override
  String get noRoutersFound => 'No Routers Found';

  @override
  String get addRouterToMonitor => 'Add a router to start monitoring';

  @override
  String get tapRefreshLoadStats => 'Tap refresh to load stats';

  @override
  String get routerOnline => 'Router Online';

  @override
  String get routerOffline => 'Router Offline';

  @override
  String uptime(String value) {
    return 'Uptime: $value';
  }

  @override
  String get bandwidth => 'Bandwidth';

  @override
  String get cpuLoad => 'CPU Load';

  @override
  String get memory => 'Memory';

  @override
  String get routerDetails => 'Router Details';

  @override
  String get routerName => 'Router Name';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get apiPort => 'API Port';

  @override
  String get model => 'Model';

  @override
  String get dailySales => 'Daily Sales';

  @override
  String get monthlySales => 'Monthly Sales';

  @override
  String dataPoints(int count) {
    return '$count data points';
  }

  @override
  String get daily => 'Daily';

  @override
  String get monthly => 'Monthly';

  @override
  String get noSalesData => 'No Sales Data';

  @override
  String get salesWillAppear =>
      'Sales will appear here when you make your first sale';

  @override
  String get error => 'Error';

  @override
  String get recentSales => 'Recent Sales';

  @override
  String get viewSalesHistory => 'View Sales History';

  @override
  String get loadingSalesHistory => 'Loading sales history...';

  @override
  String get availablePlans => 'Available Plans';

  @override
  String get selectPlanFits => 'Select a plan that fits your needs';

  @override
  String get noActiveSubscription => 'No Active Subscription';

  @override
  String get choosePlanBelow => 'Choose a plan below to get started';

  @override
  String get subscriptionExpired => 'Subscription expired';

  @override
  String get startDate => 'Start Date';

  @override
  String get expires => 'Expires';

  @override
  String get maxRouters => 'Max Routers';

  @override
  String get maxHotspotUsers => 'Max Hotspot Users';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get failedLoadPlans => 'Failed to load plans';

  @override
  String get checkConnectionTryAgain =>
      'Please check your connection and try again';

  @override
  String get noPlansAvailable => 'No plans available';

  @override
  String get contactAdminPlans =>
      'Contact your administrator to set up subscription plans';

  @override
  String get current => 'CURRENT';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get selectPlan => 'Select Plan';

  @override
  String upToRouters(int count) {
    return 'Up to $count router(s)';
  }

  @override
  String get unlimitedHotspotUsers => 'Unlimited hotspot users';

  @override
  String upToHotspotUsers(int count) {
    return 'Up to $count hotspot users';
  }

  @override
  String get voucherSystemIncluded => 'Voucher system included';

  @override
  String get noVoucherSystem => 'No voucher system';

  @override
  String get reportsAnalytics => 'Reports & analytics';

  @override
  String get noReports => 'No reports';

  @override
  String get requestSubmitted => 'Request Submitted';

  @override
  String paymentFor(String plan) {
    return 'Payment for $plan';
  }

  @override
  String get bankInfo => 'Bank Info';

  @override
  String get uploadProof => 'Upload Proof';

  @override
  String get transferInstructions =>
      'Transfer the amount below to the bank account, then upload your payment confirmation.';

  @override
  String get bank => 'Bank';

  @override
  String get accountName => 'Account Name';

  @override
  String get accountNumber => 'Account Number';

  @override
  String get amount => 'Amount';

  @override
  String get iveSentMoney => 'I\'ve Sent the Money';

  @override
  String get failedLoadBankInfo => 'Failed to load bank info';

  @override
  String failedCreateRequest(String error) {
    return 'Failed to create request: $error';
  }

  @override
  String get uploadPaymentProof =>
      'Upload a screenshot or photo of your payment confirmation.';

  @override
  String get tapToSelectImage => 'Tap to select image';

  @override
  String get pngJpgUpTo5mb => 'PNG, JPG up to 5MB';

  @override
  String get changeImage => 'Change Image';

  @override
  String get skipForNow => 'Skip for Now';

  @override
  String get requestSavedUploadLater =>
      'Request saved. You can upload proof from Bills later.';

  @override
  String get submitProof => 'Submit Proof';

  @override
  String failedUploadProof(String error) {
    return 'Failed to upload proof: $error';
  }

  @override
  String get paymentProofSubmitted => 'Payment Proof Submitted';

  @override
  String get subscriptionRequestSubmitted =>
      'Your subscription request has been submitted.\nAn admin will review your payment and activate your plan.';

  @override
  String get done => 'Done';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get failedLoadPayments => 'Failed to load payments';

  @override
  String get noPaymentsYet => 'No payments yet';

  @override
  String get paymentHistoryAppear => 'Your payment history will appear here';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get pending => 'Pending';

  @override
  String get date => 'Date';

  @override
  String get method => 'Method';

  @override
  String get planDuration => 'Plan Duration';

  @override
  String daysDuration(int days) {
    return '$days days';
  }

  @override
  String get notes => 'Notes';

  @override
  String get reviewed => 'Reviewed';

  @override
  String get paymentProof => 'Payment Proof';

  @override
  String get failedLoadImage => 'Failed to load image';

  @override
  String get uploading => 'Uploading...';

  @override
  String get proofUploadedSuccess => 'Proof uploaded successfully';

  @override
  String failedUpload(String error) {
    return 'Failed to upload: $error';
  }

  @override
  String get noProofUploaded => 'No proof uploaded';

  @override
  String get searchByCodeOrPlan => 'Search by code or plan...';

  @override
  String get filterVouchers => 'Filter Vouchers';

  @override
  String get all => 'All';

  @override
  String get unused => 'Unused';

  @override
  String get total => 'Total';

  @override
  String selected(int count) {
    return '$count Selected';
  }

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get generate => 'Generate';

  @override
  String get loadingVouchers => 'Loading vouchers...';

  @override
  String get scrollForMore => 'Scroll for more';

  @override
  String get shareVoucher => 'Share Voucher';

  @override
  String get shareAsImage => 'Share as Image';

  @override
  String get beautifulStyledCard => 'Beautiful styled voucher card';

  @override
  String get shareAsText => 'Share as Text';

  @override
  String get plainTextFormat => 'Plain text format';

  @override
  String get shareQRCode => 'Share QR Code';

  @override
  String get scannableQRImage => 'Scannable QR image';

  @override
  String get printVoucherAction => 'Print Voucher';

  @override
  String get shareVoucherAction => 'Share Voucher';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get codeCopied => 'Code copied to clipboard';

  @override
  String get showQRCode => 'Show QR Code';

  @override
  String get deleteVoucher => 'Delete Voucher';

  @override
  String get deleteVoucherConfirm =>
      'Are you sure you want to delete this voucher? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get deleteVouchers => 'Delete Vouchers';

  @override
  String deleteVouchersConfirm(int count) {
    return 'Are you sure you want to delete $count vouchers? This action cannot be undone.';
  }

  @override
  String get deletingVouchers => 'Deleting vouchers...';

  @override
  String get scanToConnect => 'Scan to Connect';

  @override
  String get close => 'Close';

  @override
  String get print => 'Print';

  @override
  String get share => 'Share';

  @override
  String get generateVoucher => 'Generate Voucher';

  @override
  String get selectRouter => 'Select Router';

  @override
  String get chooseRouterForVouchers =>
      'Choose the router for generating vouchers';

  @override
  String get configure => 'Configure';

  @override
  String get confirm => 'Confirm';

  @override
  String get configurePlan => 'Configure Plan';

  @override
  String get setupVoucherDetails => 'Set up the voucher details';

  @override
  String get limitType => 'Limit Type';

  @override
  String get timeLimit => 'Time Limit';

  @override
  String get dataLimit => 'Data Limit';

  @override
  String get totalUse => 'Total Use';

  @override
  String get totalOnlineTime => 'Total Online Time';

  @override
  String get countsOnlyConnected => 'Counts only when connected';

  @override
  String get totalTime => 'Total Time';

  @override
  String get countsEvenOffline => 'Counts even when offline';

  @override
  String get validityDuration => 'Validity Duration';

  @override
  String get price => 'Price';

  @override
  String get quantity => 'Quantity';

  @override
  String get required => 'Required';

  @override
  String get advancedOptions => 'Advanced Options';

  @override
  String get codeFormat => 'Code Format';

  @override
  String get numbersOnly => 'Numbers Only (e.g., 12345678)';

  @override
  String get numbersAndLetters => 'Numbers & Letters (e.g., AB12CD34)';

  @override
  String get lettersOnly => 'Letters Only (e.g., ABCDEFGH)';

  @override
  String get continueBtn => 'Continue';

  @override
  String get confirmGenerate => 'Confirm & Generate';

  @override
  String get reviewVoucherSettings => 'Review your voucher settings';

  @override
  String get plan => 'Plan';

  @override
  String get duration => 'Duration';

  @override
  String get router => 'Router';

  @override
  String vouchersCount(int count) {
    return '$count voucher(s)';
  }

  @override
  String get priceEach => 'Price Each';

  @override
  String get noRoutersFoundAdd => 'No routers found';

  @override
  String get addRouterFirst => 'Add a router first to generate vouchers';

  @override
  String get unknownRouter => 'Unknown Router';

  @override
  String get noIP => 'No IP';

  @override
  String get loadingProfiles => 'Loading profiles...';

  @override
  String get noProfilesOnRouter => 'No profiles found on this router';

  @override
  String generateVouchersBtn(int count) {
    return 'Generate $count Voucher(s)';
  }

  @override
  String get printVouchers => 'Print Vouchers';

  @override
  String get printSettings => 'Print Settings';

  @override
  String get paperFormat => 'Paper Format';

  @override
  String get a4Paper => 'A4 Paper';

  @override
  String get thermal58mm => 'Thermal 58mm';

  @override
  String get thermal80mm => 'Thermal 80mm';

  @override
  String get cardDesign => 'Card Design';

  @override
  String get classic => 'Classic';

  @override
  String get modern => 'Modern';

  @override
  String get minimal => 'Minimal';

  @override
  String columns(int count) {
    return 'Columns: $count';
  }

  @override
  String get applyChanges => 'Apply Changes';

  @override
  String vouchersGenerated(int count) {
    return '$count Vouchers Generated!';
  }

  @override
  String get voucherGenerated => 'Voucher Generated!';

  @override
  String get vouchersReadyToUse => 'Your vouchers are ready to use';

  @override
  String get copy => 'Copy';

  @override
  String get username => 'USERNAME';

  @override
  String get passwordLabel => 'PASSWORD';

  @override
  String get myProfile => 'My Profile';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get emailAddressLabel => 'Email Address';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get networkSettings => 'Network Settings';

  @override
  String get networkName => 'Network Name';

  @override
  String get networkNameHelper => 'This name appears on printed vouchers';

  @override
  String get security => 'Security';

  @override
  String get leaveEmptyKeepPassword => 'Leave empty to keep current password';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get logOut => 'Log Out';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get confirmLogoutMessage =>
      'Are you sure you want to log out of your account?';

  @override
  String get logout => 'Logout';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get loading => 'Loading...';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get configureNotifications =>
      'Configure what notifications you receive from the app.';

  @override
  String get routerAlerts => 'Router Alerts';

  @override
  String get routerStatus => 'Router Status';

  @override
  String get routerStatusSubtitle =>
      'Get notified when your routers go online or offline';

  @override
  String get routerStatusEnabled => 'Router status notifications enabled';

  @override
  String get routerStatusDisabled => 'Router status notifications disabled';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get soon => 'Soon';

  @override
  String get lowBalanceAlert => 'Low Balance Alert';

  @override
  String get lowBalanceSubtitle => 'Get notified when voucher balance is low';

  @override
  String get dailySalesReport => 'Daily Sales Report';

  @override
  String get dailySalesSubtitle => 'Receive daily sales summary';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get checkInternetConnection =>
      'Please check your internet connection and try again.';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get serverErrorTitle => 'Server Error';

  @override
  String get serverErrorMessage =>
      'We\'re having trouble connecting to the server. Please try again later.';

  @override
  String get monitoring => 'Monitoring';

  @override
  String get reports => 'Reports';

  @override
  String get noRoutersYet => 'No routers yet';

  @override
  String get noRoutersMessage =>
      'Add your first MikroTik router to start managing hotspot vouchers and monitoring connections.';

  @override
  String get noVouchersYet => 'No Vouchers Yet';

  @override
  String get noVouchersMessage =>
      'Create your first voucher to start selling internet access. Make sure you have added a router first.';

  @override
  String get createVoucher => 'Create Voucher';

  @override
  String get noSalesYet => 'No Sales Yet';

  @override
  String get noSalesMessage =>
      'Your sales history will appear here once you start selling vouchers to customers.';

  @override
  String get noActiveSessions => 'No Active Sessions';

  @override
  String get noActiveSessionsMessage =>
      'No users are currently connected to your hotspot. Active sessions will appear here.';

  @override
  String get noResultsFound => 'No Results Found';

  @override
  String noResultsMessage(String query) {
    return 'We couldn\'t find any results for \"$query\". Try a different search term.';
  }

  @override
  String get somethingWentWrongTitle => 'Something Went Wrong';

  @override
  String get subscriptionRequiredTitle => 'Subscription Required';

  @override
  String get subscriptionRequiredBody =>
      'You need an active subscription to access this feature. Please subscribe to a plan to continue.';

  @override
  String get goToSubscriptions => 'Go to Subscriptions';

  @override
  String get manual => 'Manual';

  @override
  String get byScript => 'By Script';

  @override
  String get routerAddedSuccess => 'Router added successfully!';

  @override
  String get locationOptional => 'Location (Optional)';

  @override
  String vpnIpAssigned(String ip) {
    return 'VPN IP assigned: $ip';
  }

  @override
  String get runCommandsOnMikroTik =>
      'Run these commands on your MikroTik Terminal (RouterOS v7):';

  @override
  String get importantNotes => 'Important Notes:';

  @override
  String get importantNotesBody =>
      '• Requires RouterOS v7 or later (WireGuard support)\n• Run each command in order in the MikroTik terminal\n• The VPN tunnel connects your router to Wassal securely';

  @override
  String get copyAllCommands => 'Copy All Commands';

  @override
  String get allCommandsCopied => 'All commands copied!';

  @override
  String stepCopied(int number) {
    return 'Step $number copied!';
  }

  @override
  String get noSetupSteps => 'No setup steps available.';

  @override
  String get wireguardSetupDescription =>
      'This will generate a unique WireGuard VPN configuration and MikroTik commands for your router. A pending router will be created to reserve the VPN IP.';

  @override
  String get generateSetup => 'Generate Setup';

  @override
  String get needSubscriptionAddRouters =>
      'You need an active subscription to add routers. Please subscribe to a plan to continue.';

  @override
  String get needSubscriptionFeature =>
      'You need an active subscription to use this feature. Would you like to view available plans?';

  @override
  String get errorConnectionTimeout =>
      'Connection timed out.\n\nThe server may be busy or unreachable. Please try again in a moment.';

  @override
  String get errorConnectionFailed =>
      'Unable to connect to the server.\n\nPlease check your internet connection and try again.';

  @override
  String get errorDnsFailure =>
      'DNS resolution failed.\n\nYour network may be blocking this domain. Try switching to a different network.';

  @override
  String get errorConnectionRefused =>
      'Connection refused.\n\nThe server is not accepting connections. Please try again later.';

  @override
  String get errorTlsFailure =>
      'Secure connection failed.\n\nYour network may be intercepting traffic. Try a different network.';

  @override
  String get errorNetworkUnreachable =>
      'Network is unreachable.\n\nPlease check your internet connection.';

  @override
  String get errorAuthFailed =>
      'Authentication failed.\n\nYour session may have expired. Please log in again.';

  @override
  String get errorPermissionDenied =>
      'Permission denied.\n\nYou do not have access to this resource.';

  @override
  String get errorNotFound =>
      'Resource not found.\n\nThe requested data could not be located.';

  @override
  String errorServerGeneric(int statusCode) {
    return 'Server error ($statusCode).\n\nPlease try again later.';
  }

  @override
  String get errorRequestCancelled => 'Request cancelled.';

  @override
  String get errorNetwork =>
      'Network error.\n\nPlease check your internet connection and try again.';

  @override
  String get errorUnexpected => 'An unexpected error occurred.';

  @override
  String get ok => 'OK';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get sessions => 'Sessions';

  @override
  String get activeSessions => 'Active Sessions';

  @override
  String get allSessions => 'All Sessions';

  @override
  String get sessionDetails => 'Session Details';

  @override
  String get terminateSession => 'Terminate Session';

  @override
  String get sessionTerminated => 'Session terminated successfully';

  @override
  String get noSessionsFound => 'No sessions found';

  @override
  String get hotspotProfiles => 'Hotspot Profiles';

  @override
  String get createProfile => 'Create Profile';

  @override
  String get profileName => 'Profile Name';

  @override
  String get rateLimit => 'Rate Limit';

  @override
  String get sharedUsers => 'Shared Users';

  @override
  String get sessionTimeout => 'Session Timeout';

  @override
  String get idleTimeout => 'Idle Timeout';

  @override
  String get keepaliveTimeout => 'Keepalive Timeout';

  @override
  String get deleteRouter => 'Delete Router';

  @override
  String get deleteRouterConfirm =>
      'Are you sure you want to delete this router? This action cannot be undone.';

  @override
  String get routerDeleted => 'Router deleted successfully';

  @override
  String get editRouter => 'Edit Router';

  @override
  String get routerUpdated => 'Router updated successfully';

  @override
  String get failedDeleteRouter => 'Failed to delete router';

  @override
  String get failedUpdateRouter => 'Failed to update router';

  @override
  String get rebootRouter => 'Reboot Router';

  @override
  String get rebootRouterConfirm =>
      'Are you sure you want to reboot this router?';

  @override
  String get rebootSuccess => 'Router reboot initiated';

  @override
  String get splashConnecting => 'Connecting to server...';

  @override
  String get splashCheckingAuth => 'Checking authentication...';

  @override
  String get splashLoadingProfile => 'Loading profile...';

  @override
  String get splashReady => 'Ready!';

  @override
  String get splashFailed => 'Connection failed';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get contactUsSubtitle => 'Send a message to the admin team';

  @override
  String get subject => 'Subject';

  @override
  String get message => 'Message';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get messageSent => 'Message sent successfully!';

  @override
  String get myMessages => 'My Messages';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get replied => 'Replied';

  @override
  String get unread => 'Unread';

  @override
  String get read => 'Read';

  @override
  String get adminReply => 'Admin Reply';

  @override
  String get subjectRequired => 'Please enter a subject';

  @override
  String get messageRequired => 'Please enter a message';

  @override
  String get sendMessageFailed => 'Failed to send message. Please try again.';

  @override
  String get myRouters => 'My Routers';

  @override
  String get addFirstRouterHint =>
      'Add your first MikroTik router to get started.';

  @override
  String get errorLoadingRouters => 'Error loading routers';

  @override
  String get deleteRouterTitle => 'Delete Router';

  @override
  String deleteRouterMsg(String routerName) {
    return 'Are you sure you want to delete \'\'$routerName\'\'?';
  }

  @override
  String get addProfile => 'Add Profile';

  @override
  String get failedLoadProfiles => 'Failed to Load Profiles';

  @override
  String get noProfilesFound => 'No Profiles Found';

  @override
  String get noProfilesHint =>
      'Tap the button below to create your first profile';

  @override
  String get aboutTitle => 'About Wassal';

  @override
  String get aboutDescription => 'MikroTik hotspot management platform';

  @override
  String get version => 'Version';

  @override
  String get networkDiagnostics => 'Network Diagnostics';

  @override
  String get diagnoseNetwork => 'Diagnose Network';

  @override
  String get runningDiagnostics => 'Running diagnostics...';

  @override
  String get diagWifiConnectivity => 'WiFi / Cellular';

  @override
  String get diagDnsApi => 'DNS: api.wassal.tech';

  @override
  String get diagDnsGoogle => 'DNS: google.com';

  @override
  String get diagHttpHealth => 'HTTP: Server Health';

  @override
  String get diagIpVersion => 'IP Version';

  @override
  String get diagResponseTime => 'Response Time';

  @override
  String get diagPassed => 'Passed';

  @override
  String get diagFailed => 'Failed';

  @override
  String get diagSkipped => 'Skipped';

  @override
  String get diagRunAgain => 'Run Again';

  @override
  String diagResolvedTo(String ip) {
    return 'Resolved to $ip';
  }

  @override
  String diagResponseMs(int ms) {
    return '${ms}ms';
  }

  @override
  String get diagNoConnection => 'No network connection detected';

  @override
  String get diagDnsFailed => 'Could not resolve hostname';

  @override
  String get diagServerOk => 'Server is reachable';

  @override
  String get diagServerUnreachable => 'Server is unreachable';

  @override
  String get diagIpv4 => 'IPv4';

  @override
  String get diagIpv6 => 'IPv6';

  @override
  String get diagIpv4And6 => 'IPv4 + IPv6';

  @override
  String get diagSummaryAllGood =>
      'All checks passed. Your connection to the server is working.';

  @override
  String get diagSummaryDnsIssue =>
      'DNS resolution failed. Your network may be blocking this domain.';

  @override
  String get diagSummaryServerDown =>
      'DNS works but the server is unreachable. The server may be down.';

  @override
  String get diagSummaryNoInternet =>
      'No internet connection detected. Check your WiFi or mobile data.';
}
