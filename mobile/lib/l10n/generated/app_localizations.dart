import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MikroTik Hotspot Manager'**
  String get appTitle;

  /// No description provided for @wassal.
  ///
  /// In en, this message translates to:
  /// **'Wassal'**
  String get wassal;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your MikroTik hotspots'**
  String get signInSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @forgotPasswordQ.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordQ;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @cannotConnectServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server. Please check your internet connection.'**
  String get cannotConnectServer;

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout. Please try again.'**
  String get connectionTimeout;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again.'**
  String get invalidCredentials;

  /// No description provided for @checkInputTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check your input and try again.'**
  String get checkInputTryAgain;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started with MikroTik management'**
  String get signUpSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get nameMinLength;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @pleaseEnterAPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterAPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @reenterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reenterPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please login instead.'**
  String get emailAlreadyRegistered;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a reset code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get sendResetCode;

  /// No description provided for @resetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Reset code sent! Check your email or server logs.'**
  String get resetCodeSent;

  /// No description provided for @failedSendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset code. Try again.'**
  String get failedSendResetCode;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {email} and your new password.'**
  String resetPasswordSubtitle(String email);

  /// No description provided for @resetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset Code'**
  String get resetCode;

  /// No description provided for @enterResetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get enterResetCode;

  /// No description provided for @pleaseEnterResetCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the reset code'**
  String get pleaseEnterResetCode;

  /// No description provided for @codeMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 digits'**
  String get codeMustBe6Digits;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordMin8Chars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMin8Chars;

  /// No description provided for @reenterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get reenterNewPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! Please log in.'**
  String get passwordResetSuccess;

  /// No description provided for @failedResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password. Try again.'**
  String get failedResetPassword;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @monitoringAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Monitoring & Analytics'**
  String get monitoringAnalytics;

  /// No description provided for @monitoringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time stats, bandwidth, and health'**
  String get monitoringSubtitle;

  /// No description provided for @salesReports.
  ///
  /// In en, this message translates to:
  /// **'Sales & Reports'**
  String get salesReports;

  /// No description provided for @salesReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Voucher sales, revenue, and exports'**
  String get salesReportsSubtitle;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @viewPlansManageSub.
  ///
  /// In en, this message translates to:
  /// **'View plans and manage subscription'**
  String get viewPlansManageSub;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @noActivePlanSelect.
  ///
  /// In en, this message translates to:
  /// **'No active plan — select one'**
  String get noActivePlanSelect;

  /// No description provided for @billsPayments.
  ///
  /// In en, this message translates to:
  /// **'Bills & Payments'**
  String get billsPayments;

  /// No description provided for @viewPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'View your payment history'**
  String get viewPaymentHistory;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @manageYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage your account'**
  String get manageYourAccount;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @configureAlerts.
  ///
  /// In en, this message translates to:
  /// **'Configure alerts'**
  String get configureAlerts;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version 1.0.0'**
  String get appVersion;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get languageSubtitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String hello(String name);

  /// No description provided for @hotspotOverview.
  ///
  /// In en, this message translates to:
  /// **'Here is your hotspot overview'**
  String get hotspotOverview;

  /// No description provided for @totalRouters.
  ///
  /// In en, this message translates to:
  /// **'Total Routers'**
  String get totalRouters;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @activeUsers.
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get activeUsers;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @activeUsersRealtime.
  ///
  /// In en, this message translates to:
  /// **'Active Users Real-time'**
  String get activeUsersRealtime;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addRouter.
  ///
  /// In en, this message translates to:
  /// **'Add Router'**
  String get addRouter;

  /// No description provided for @printVoucher.
  ///
  /// In en, this message translates to:
  /// **'Print Voucher'**
  String get printVoucher;

  /// No description provided for @loadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard...'**
  String get loadingDashboard;

  /// No description provided for @failedLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Dashboard'**
  String get failedLoadDashboard;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @subscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Subscription Required'**
  String get subscriptionRequired;

  /// No description provided for @subscriptionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'You need an active subscription to use this feature. Would you like to view available plans?'**
  String get subscriptionRequiredMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get viewPlans;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemaining(int days);

  /// No description provided for @noPlan.
  ///
  /// In en, this message translates to:
  /// **'No Plan'**
  String get noPlan;

  /// No description provided for @noSubscription.
  ///
  /// In en, this message translates to:
  /// **'No Subscription'**
  String get noSubscription;

  /// No description provided for @tapToSelectPlan.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a plan'**
  String get tapToSelectPlan;

  /// No description provided for @tapToManagePlan.
  ///
  /// In en, this message translates to:
  /// **'Tap to manage your plan'**
  String get tapToManagePlan;

  /// No description provided for @routers.
  ///
  /// In en, this message translates to:
  /// **'Routers'**
  String get routers;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @vouchers.
  ///
  /// In en, this message translates to:
  /// **'Vouchers'**
  String get vouchers;

  /// No description provided for @loadingRouters.
  ///
  /// In en, this message translates to:
  /// **'Loading routers...'**
  String get loadingRouters;

  /// No description provided for @loadingStats.
  ///
  /// In en, this message translates to:
  /// **'Loading stats...'**
  String get loadingStats;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectionFailed;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noRoutersFound.
  ///
  /// In en, this message translates to:
  /// **'No Routers Found'**
  String get noRoutersFound;

  /// No description provided for @addRouterToMonitor.
  ///
  /// In en, this message translates to:
  /// **'Add a router to start monitoring'**
  String get addRouterToMonitor;

  /// No description provided for @tapRefreshLoadStats.
  ///
  /// In en, this message translates to:
  /// **'Tap refresh to load stats'**
  String get tapRefreshLoadStats;

  /// No description provided for @routerOnline.
  ///
  /// In en, this message translates to:
  /// **'Router Online'**
  String get routerOnline;

  /// No description provided for @routerOffline.
  ///
  /// In en, this message translates to:
  /// **'Router Offline'**
  String get routerOffline;

  /// No description provided for @uptime.
  ///
  /// In en, this message translates to:
  /// **'Uptime: {value}'**
  String uptime(String value);

  /// No description provided for @bandwidth.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth'**
  String get bandwidth;

  /// No description provided for @cpuLoad.
  ///
  /// In en, this message translates to:
  /// **'CPU Load'**
  String get cpuLoad;

  /// No description provided for @memory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memory;

  /// No description provided for @routerDetails.
  ///
  /// In en, this message translates to:
  /// **'Router Details'**
  String get routerDetails;

  /// No description provided for @routerName.
  ///
  /// In en, this message translates to:
  /// **'Router Name'**
  String get routerName;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get ipAddress;

  /// No description provided for @apiPort.
  ///
  /// In en, this message translates to:
  /// **'API Port'**
  String get apiPort;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @dailySales.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales'**
  String get dailySales;

  /// No description provided for @monthlySales.
  ///
  /// In en, this message translates to:
  /// **'Monthly Sales'**
  String get monthlySales;

  /// No description provided for @dataPoints.
  ///
  /// In en, this message translates to:
  /// **'{count} data points'**
  String dataPoints(int count);

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @noSalesData.
  ///
  /// In en, this message translates to:
  /// **'No Sales Data'**
  String get noSalesData;

  /// No description provided for @salesWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Sales will appear here when you make your first sale'**
  String get salesWillAppear;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @recentSales.
  ///
  /// In en, this message translates to:
  /// **'Recent Sales'**
  String get recentSales;

  /// No description provided for @viewSalesHistory.
  ///
  /// In en, this message translates to:
  /// **'View Sales History'**
  String get viewSalesHistory;

  /// No description provided for @loadingSalesHistory.
  ///
  /// In en, this message translates to:
  /// **'Loading sales history...'**
  String get loadingSalesHistory;

  /// No description provided for @availablePlans.
  ///
  /// In en, this message translates to:
  /// **'Available Plans'**
  String get availablePlans;

  /// No description provided for @selectPlanFits.
  ///
  /// In en, this message translates to:
  /// **'Select a plan that fits your needs'**
  String get selectPlanFits;

  /// No description provided for @noActiveSubscription.
  ///
  /// In en, this message translates to:
  /// **'No Active Subscription'**
  String get noActiveSubscription;

  /// No description provided for @choosePlanBelow.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan below to get started'**
  String get choosePlanBelow;

  /// No description provided for @subscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Subscription expired'**
  String get subscriptionExpired;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @maxRouters.
  ///
  /// In en, this message translates to:
  /// **'Max Routers'**
  String get maxRouters;

  /// No description provided for @maxHotspotUsers.
  ///
  /// In en, this message translates to:
  /// **'Max Hotspot Users'**
  String get maxHotspotUsers;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @failedLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plans'**
  String get failedLoadPlans;

  /// No description provided for @checkConnectionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again'**
  String get checkConnectionTryAgain;

  /// No description provided for @noPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available'**
  String get noPlansAvailable;

  /// No description provided for @contactAdminPlans.
  ///
  /// In en, this message translates to:
  /// **'Contact your administrator to set up subscription plans'**
  String get contactAdminPlans;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get current;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @selectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get selectPlan;

  /// No description provided for @upToRouters.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} router(s)'**
  String upToRouters(int count);

  /// No description provided for @unlimitedHotspotUsers.
  ///
  /// In en, this message translates to:
  /// **'Unlimited hotspot users'**
  String get unlimitedHotspotUsers;

  /// No description provided for @upToHotspotUsers.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} hotspot users'**
  String upToHotspotUsers(int count);

  /// No description provided for @voucherSystemIncluded.
  ///
  /// In en, this message translates to:
  /// **'Voucher system included'**
  String get voucherSystemIncluded;

  /// No description provided for @noVoucherSystem.
  ///
  /// In en, this message translates to:
  /// **'No voucher system'**
  String get noVoucherSystem;

  /// No description provided for @reportsAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Reports & analytics'**
  String get reportsAnalytics;

  /// No description provided for @noReports.
  ///
  /// In en, this message translates to:
  /// **'No reports'**
  String get noReports;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted'**
  String get requestSubmitted;

  /// No description provided for @paymentFor.
  ///
  /// In en, this message translates to:
  /// **'Payment for {plan}'**
  String paymentFor(String plan);

  /// No description provided for @bankInfo.
  ///
  /// In en, this message translates to:
  /// **'Bank Info'**
  String get bankInfo;

  /// No description provided for @uploadProof.
  ///
  /// In en, this message translates to:
  /// **'Upload Proof'**
  String get uploadProof;

  /// No description provided for @transferInstructions.
  ///
  /// In en, this message translates to:
  /// **'Transfer the amount below to the bank account, then upload your payment confirmation.'**
  String get transferInstructions;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @iveSentMoney.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Sent the Money'**
  String get iveSentMoney;

  /// No description provided for @failedLoadBankInfo.
  ///
  /// In en, this message translates to:
  /// **'Failed to load bank info'**
  String get failedLoadBankInfo;

  /// No description provided for @failedCreateRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to create request: {error}'**
  String failedCreateRequest(String error);

  /// No description provided for @uploadPaymentProof.
  ///
  /// In en, this message translates to:
  /// **'Upload a screenshot or photo of your payment confirmation.'**
  String get uploadPaymentProof;

  /// No description provided for @tapToSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to select image'**
  String get tapToSelectImage;

  /// No description provided for @pngJpgUpTo5mb.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPG up to 5MB'**
  String get pngJpgUpTo5mb;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// No description provided for @requestSavedUploadLater.
  ///
  /// In en, this message translates to:
  /// **'Request saved. You can upload proof from Bills later.'**
  String get requestSavedUploadLater;

  /// No description provided for @submitProof.
  ///
  /// In en, this message translates to:
  /// **'Submit Proof'**
  String get submitProof;

  /// No description provided for @failedUploadProof.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload proof: {error}'**
  String failedUploadProof(String error);

  /// No description provided for @paymentProofSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Payment Proof Submitted'**
  String get paymentProofSubmitted;

  /// No description provided for @subscriptionRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your subscription request has been submitted.\nAn admin will review your payment and activate your plan.'**
  String get subscriptionRequestSubmitted;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @failedLoadPayments.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payments'**
  String get failedLoadPayments;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPaymentsYet;

  /// No description provided for @paymentHistoryAppear.
  ///
  /// In en, this message translates to:
  /// **'Your payment history will appear here'**
  String get paymentHistoryAppear;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @planDuration.
  ///
  /// In en, this message translates to:
  /// **'Plan Duration'**
  String get planDuration;

  /// No description provided for @daysDuration.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysDuration(int days);

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @paymentProof.
  ///
  /// In en, this message translates to:
  /// **'Payment Proof'**
  String get paymentProof;

  /// No description provided for @failedLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedLoadImage;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @proofUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Proof uploaded successfully'**
  String get proofUploadedSuccess;

  /// No description provided for @failedUpload.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload: {error}'**
  String failedUpload(String error);

  /// No description provided for @noProofUploaded.
  ///
  /// In en, this message translates to:
  /// **'No proof uploaded'**
  String get noProofUploaded;

  /// No description provided for @searchByCodeOrPlan.
  ///
  /// In en, this message translates to:
  /// **'Search by code or plan...'**
  String get searchByCodeOrPlan;

  /// No description provided for @filterVouchers.
  ///
  /// In en, this message translates to:
  /// **'Filter Vouchers'**
  String get filterVouchers;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @unused.
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get unused;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String selected(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @loadingVouchers.
  ///
  /// In en, this message translates to:
  /// **'Loading vouchers...'**
  String get loadingVouchers;

  /// No description provided for @scrollForMore.
  ///
  /// In en, this message translates to:
  /// **'Scroll for more'**
  String get scrollForMore;

  /// No description provided for @shareVoucher.
  ///
  /// In en, this message translates to:
  /// **'Share Voucher'**
  String get shareVoucher;

  /// No description provided for @shareAsImage.
  ///
  /// In en, this message translates to:
  /// **'Share as Image'**
  String get shareAsImage;

  /// No description provided for @beautifulStyledCard.
  ///
  /// In en, this message translates to:
  /// **'Beautiful styled voucher card'**
  String get beautifulStyledCard;

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Share as Text'**
  String get shareAsText;

  /// No description provided for @plainTextFormat.
  ///
  /// In en, this message translates to:
  /// **'Plain text format'**
  String get plainTextFormat;

  /// No description provided for @shareQRCode.
  ///
  /// In en, this message translates to:
  /// **'Share QR Code'**
  String get shareQRCode;

  /// No description provided for @scannableQRImage.
  ///
  /// In en, this message translates to:
  /// **'Scannable QR image'**
  String get scannableQRImage;

  /// No description provided for @printVoucherAction.
  ///
  /// In en, this message translates to:
  /// **'Print Voucher'**
  String get printVoucherAction;

  /// No description provided for @shareVoucherAction.
  ///
  /// In en, this message translates to:
  /// **'Share Voucher'**
  String get shareVoucherAction;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopied;

  /// No description provided for @showQRCode.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get showQRCode;

  /// No description provided for @deleteVoucher.
  ///
  /// In en, this message translates to:
  /// **'Delete Voucher'**
  String get deleteVoucher;

  /// No description provided for @deleteVoucherConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this voucher? This action cannot be undone.'**
  String get deleteVoucherConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteVouchers.
  ///
  /// In en, this message translates to:
  /// **'Delete Vouchers'**
  String get deleteVouchers;

  /// No description provided for @deleteVouchersConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} vouchers? This action cannot be undone.'**
  String deleteVouchersConfirm(int count);

  /// No description provided for @deletingVouchers.
  ///
  /// In en, this message translates to:
  /// **'Deleting vouchers...'**
  String get deletingVouchers;

  /// No description provided for @scanToConnect.
  ///
  /// In en, this message translates to:
  /// **'Scan to Connect'**
  String get scanToConnect;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @generateVoucher.
  ///
  /// In en, this message translates to:
  /// **'Generate Voucher'**
  String get generateVoucher;

  /// No description provided for @selectRouter.
  ///
  /// In en, this message translates to:
  /// **'Select Router'**
  String get selectRouter;

  /// No description provided for @chooseRouterForVouchers.
  ///
  /// In en, this message translates to:
  /// **'Choose the router for generating vouchers'**
  String get chooseRouterForVouchers;

  /// No description provided for @configure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configure;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @configurePlan.
  ///
  /// In en, this message translates to:
  /// **'Configure Plan'**
  String get configurePlan;

  /// No description provided for @setupVoucherDetails.
  ///
  /// In en, this message translates to:
  /// **'Set up the voucher details'**
  String get setupVoucherDetails;

  /// No description provided for @limitType.
  ///
  /// In en, this message translates to:
  /// **'Limit Type'**
  String get limitType;

  /// No description provided for @timeLimit.
  ///
  /// In en, this message translates to:
  /// **'Time Limit'**
  String get timeLimit;

  /// No description provided for @dataLimit.
  ///
  /// In en, this message translates to:
  /// **'Data Limit'**
  String get dataLimit;

  /// No description provided for @totalUse.
  ///
  /// In en, this message translates to:
  /// **'Total Use'**
  String get totalUse;

  /// No description provided for @totalOnlineTime.
  ///
  /// In en, this message translates to:
  /// **'Total Online Time'**
  String get totalOnlineTime;

  /// No description provided for @countsOnlyConnected.
  ///
  /// In en, this message translates to:
  /// **'Counts only when connected'**
  String get countsOnlyConnected;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @countsEvenOffline.
  ///
  /// In en, this message translates to:
  /// **'Counts even when offline'**
  String get countsEvenOffline;

  /// No description provided for @validityDuration.
  ///
  /// In en, this message translates to:
  /// **'Validity Duration'**
  String get validityDuration;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @advancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get advancedOptions;

  /// No description provided for @codeFormat.
  ///
  /// In en, this message translates to:
  /// **'Code Format'**
  String get codeFormat;

  /// No description provided for @numbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Numbers Only (e.g., 12345678)'**
  String get numbersOnly;

  /// No description provided for @numbersAndLetters.
  ///
  /// In en, this message translates to:
  /// **'Numbers & Letters (e.g., AB12CD34)'**
  String get numbersAndLetters;

  /// No description provided for @lettersOnly.
  ///
  /// In en, this message translates to:
  /// **'Letters Only (e.g., ABCDEFGH)'**
  String get lettersOnly;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @confirmGenerate.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Generate'**
  String get confirmGenerate;

  /// No description provided for @reviewVoucherSettings.
  ///
  /// In en, this message translates to:
  /// **'Review your voucher settings'**
  String get reviewVoucherSettings;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @router.
  ///
  /// In en, this message translates to:
  /// **'Router'**
  String get router;

  /// No description provided for @vouchersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} voucher(s)'**
  String vouchersCount(int count);

  /// No description provided for @priceEach.
  ///
  /// In en, this message translates to:
  /// **'Price Each'**
  String get priceEach;

  /// No description provided for @noRoutersFoundAdd.
  ///
  /// In en, this message translates to:
  /// **'No routers found'**
  String get noRoutersFoundAdd;

  /// No description provided for @addRouterFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a router first to generate vouchers'**
  String get addRouterFirst;

  /// No description provided for @unknownRouter.
  ///
  /// In en, this message translates to:
  /// **'Unknown Router'**
  String get unknownRouter;

  /// No description provided for @noIP.
  ///
  /// In en, this message translates to:
  /// **'No IP'**
  String get noIP;

  /// No description provided for @loadingProfiles.
  ///
  /// In en, this message translates to:
  /// **'Loading profiles...'**
  String get loadingProfiles;

  /// No description provided for @noProfilesOnRouter.
  ///
  /// In en, this message translates to:
  /// **'No profiles found on this router'**
  String get noProfilesOnRouter;

  /// No description provided for @generateVouchersBtn.
  ///
  /// In en, this message translates to:
  /// **'Generate {count} Voucher(s)'**
  String generateVouchersBtn(int count);

  /// No description provided for @printVouchers.
  ///
  /// In en, this message translates to:
  /// **'Print Vouchers'**
  String get printVouchers;

  /// No description provided for @printSettings.
  ///
  /// In en, this message translates to:
  /// **'Print Settings'**
  String get printSettings;

  /// No description provided for @paperFormat.
  ///
  /// In en, this message translates to:
  /// **'Paper Format'**
  String get paperFormat;

  /// No description provided for @a4Paper.
  ///
  /// In en, this message translates to:
  /// **'A4 Paper'**
  String get a4Paper;

  /// No description provided for @thermal58mm.
  ///
  /// In en, this message translates to:
  /// **'Thermal 58mm'**
  String get thermal58mm;

  /// No description provided for @thermal80mm.
  ///
  /// In en, this message translates to:
  /// **'Thermal 80mm'**
  String get thermal80mm;

  /// No description provided for @cardDesign.
  ///
  /// In en, this message translates to:
  /// **'Card Design'**
  String get cardDesign;

  /// No description provided for @classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classic;

  /// No description provided for @modern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get modern;

  /// No description provided for @minimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get minimal;

  /// No description provided for @columns.
  ///
  /// In en, this message translates to:
  /// **'Columns: {count}'**
  String columns(int count);

  /// No description provided for @applyChanges.
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get applyChanges;

  /// No description provided for @vouchersGenerated.
  ///
  /// In en, this message translates to:
  /// **'{count} Vouchers Generated!'**
  String vouchersGenerated(int count);

  /// No description provided for @voucherGenerated.
  ///
  /// In en, this message translates to:
  /// **'Voucher Generated!'**
  String get voucherGenerated;

  /// No description provided for @vouchersReadyToUse.
  ///
  /// In en, this message translates to:
  /// **'Your vouchers are ready to use'**
  String get vouchersReadyToUse;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'USERNAME'**
  String get username;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get passwordLabel;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddressLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @networkSettings.
  ///
  /// In en, this message translates to:
  /// **'Network Settings'**
  String get networkSettings;

  /// No description provided for @networkName.
  ///
  /// In en, this message translates to:
  /// **'Network Name'**
  String get networkName;

  /// No description provided for @networkNameHelper.
  ///
  /// In en, this message translates to:
  /// **'This name appears on printed vouchers'**
  String get networkNameHelper;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @leaveEmptyKeepPassword.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep current password'**
  String get leaveEmptyKeepPassword;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get confirmLogoutMessage;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @configureNotifications.
  ///
  /// In en, this message translates to:
  /// **'Configure what notifications you receive from the app.'**
  String get configureNotifications;

  /// No description provided for @routerAlerts.
  ///
  /// In en, this message translates to:
  /// **'Router Alerts'**
  String get routerAlerts;

  /// No description provided for @routerStatus.
  ///
  /// In en, this message translates to:
  /// **'Router Status'**
  String get routerStatus;

  /// No description provided for @routerStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when your routers go online or offline'**
  String get routerStatusSubtitle;

  /// No description provided for @routerStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Router status notifications enabled'**
  String get routerStatusEnabled;

  /// No description provided for @routerStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Router status notifications disabled'**
  String get routerStatusDisabled;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @lowBalanceAlert.
  ///
  /// In en, this message translates to:
  /// **'Low Balance Alert'**
  String get lowBalanceAlert;

  /// No description provided for @lowBalanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when voucher balance is low'**
  String get lowBalanceSubtitle;

  /// No description provided for @dailySalesReport.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales Report'**
  String get dailySalesReport;

  /// No description provided for @dailySalesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive daily sales summary'**
  String get dailySalesSubtitle;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// No description provided for @checkInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get checkInternetConnection;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// No description provided for @serverErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverErrorTitle;

  /// No description provided for @serverErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'re having trouble connecting to the server. Please try again later.'**
  String get serverErrorMessage;

  /// No description provided for @monitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get monitoring;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @noRoutersYet.
  ///
  /// In en, this message translates to:
  /// **'No routers yet'**
  String get noRoutersYet;

  /// No description provided for @noRoutersMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first MikroTik router to start managing hotspot vouchers and monitoring connections.'**
  String get noRoutersMessage;

  /// No description provided for @noVouchersYet.
  ///
  /// In en, this message translates to:
  /// **'No Vouchers Yet'**
  String get noVouchersYet;

  /// No description provided for @noVouchersMessage.
  ///
  /// In en, this message translates to:
  /// **'Create your first voucher to start selling internet access. Make sure you have added a router first.'**
  String get noVouchersMessage;

  /// No description provided for @createVoucher.
  ///
  /// In en, this message translates to:
  /// **'Create Voucher'**
  String get createVoucher;

  /// No description provided for @noSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No Sales Yet'**
  String get noSalesYet;

  /// No description provided for @noSalesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your sales history will appear here once you start selling vouchers to customers.'**
  String get noSalesMessage;

  /// No description provided for @noActiveSessions.
  ///
  /// In en, this message translates to:
  /// **'No Active Sessions'**
  String get noActiveSessions;

  /// No description provided for @noActiveSessionsMessage.
  ///
  /// In en, this message translates to:
  /// **'No users are currently connected to your hotspot. Active sessions will appear here.'**
  String get noActiveSessionsMessage;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get noResultsFound;

  /// No description provided for @noResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any results for \"{query}\". Try a different search term.'**
  String noResultsMessage(String query);

  /// No description provided for @somethingWentWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get somethingWentWrongTitle;

  /// No description provided for @subscriptionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Required'**
  String get subscriptionRequiredTitle;

  /// No description provided for @subscriptionRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'You need an active subscription to access this feature. Please subscribe to a plan to continue.'**
  String get subscriptionRequiredBody;

  /// No description provided for @goToSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Go to Subscriptions'**
  String get goToSubscriptions;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @byScript.
  ///
  /// In en, this message translates to:
  /// **'By Script'**
  String get byScript;

  /// No description provided for @routerAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Router added successfully!'**
  String get routerAddedSuccess;

  /// No description provided for @locationOptional.
  ///
  /// In en, this message translates to:
  /// **'Location (Optional)'**
  String get locationOptional;

  /// No description provided for @vpnIpAssigned.
  ///
  /// In en, this message translates to:
  /// **'VPN IP assigned: {ip}'**
  String vpnIpAssigned(String ip);

  /// No description provided for @runCommandsOnMikroTik.
  ///
  /// In en, this message translates to:
  /// **'Run these commands on your MikroTik Terminal (RouterOS v7):'**
  String get runCommandsOnMikroTik;

  /// No description provided for @importantNotes.
  ///
  /// In en, this message translates to:
  /// **'Important Notes:'**
  String get importantNotes;

  /// No description provided for @importantNotesBody.
  ///
  /// In en, this message translates to:
  /// **'• Requires RouterOS v7 or later (WireGuard support)\n• Run each command in order in the MikroTik terminal\n• The VPN tunnel connects your router to Wassal securely'**
  String get importantNotesBody;

  /// No description provided for @copyAllCommands.
  ///
  /// In en, this message translates to:
  /// **'Copy All Commands'**
  String get copyAllCommands;

  /// No description provided for @allCommandsCopied.
  ///
  /// In en, this message translates to:
  /// **'All commands copied!'**
  String get allCommandsCopied;

  /// No description provided for @stepCopied.
  ///
  /// In en, this message translates to:
  /// **'Step {number} copied!'**
  String stepCopied(int number);

  /// No description provided for @noSetupSteps.
  ///
  /// In en, this message translates to:
  /// **'No setup steps available.'**
  String get noSetupSteps;

  /// No description provided for @needSubscriptionAddRouters.
  ///
  /// In en, this message translates to:
  /// **'You need an active subscription to add routers. Please subscribe to a plan to continue.'**
  String get needSubscriptionAddRouters;

  /// No description provided for @needSubscriptionFeature.
  ///
  /// In en, this message translates to:
  /// **'You need an active subscription to use this feature. Would you like to view available plans?'**
  String get needSubscriptionFeature;

  /// No description provided for @errorConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out.\n\nThe server may be busy or unreachable. Please try again in a moment.'**
  String get errorConnectionTimeout;

  /// No description provided for @errorConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server.\n\nPlease check your internet connection and try again.'**
  String get errorConnectionFailed;

  /// No description provided for @errorDnsFailure.
  ///
  /// In en, this message translates to:
  /// **'DNS resolution failed.\n\nYour network may be blocking this domain. Try switching to a different network.'**
  String get errorDnsFailure;

  /// No description provided for @errorConnectionRefused.
  ///
  /// In en, this message translates to:
  /// **'Connection refused.\n\nThe server is not accepting connections. Please try again later.'**
  String get errorConnectionRefused;

  /// No description provided for @errorTlsFailure.
  ///
  /// In en, this message translates to:
  /// **'Secure connection failed.\n\nYour network may be intercepting traffic. Try a different network.'**
  String get errorTlsFailure;

  /// No description provided for @errorNetworkUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Network is unreachable.\n\nPlease check your internet connection.'**
  String get errorNetworkUnreachable;

  /// No description provided for @errorAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed.\n\nYour session may have expired. Please log in again.'**
  String get errorAuthFailed;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied.\n\nYou do not have access to this resource.'**
  String get errorPermissionDenied;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.\n\nThe requested data could not be located.'**
  String get errorNotFound;

  /// No description provided for @errorServerGeneric.
  ///
  /// In en, this message translates to:
  /// **'Server error ({statusCode}).\n\nPlease try again later.'**
  String errorServerGeneric(int statusCode);

  /// No description provided for @errorRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get errorRequestCancelled;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error.\n\nPlease check your internet connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorUnexpected;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get activeSessions;

  /// No description provided for @allSessions.
  ///
  /// In en, this message translates to:
  /// **'All Sessions'**
  String get allSessions;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get sessionDetails;

  /// No description provided for @terminateSession.
  ///
  /// In en, this message translates to:
  /// **'Terminate Session'**
  String get terminateSession;

  /// No description provided for @sessionTerminated.
  ///
  /// In en, this message translates to:
  /// **'Session terminated successfully'**
  String get sessionTerminated;

  /// No description provided for @noSessionsFound.
  ///
  /// In en, this message translates to:
  /// **'No sessions found'**
  String get noSessionsFound;

  /// No description provided for @hotspotProfiles.
  ///
  /// In en, this message translates to:
  /// **'Hotspot Profiles'**
  String get hotspotProfiles;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Profile Name'**
  String get profileName;

  /// No description provided for @rateLimit.
  ///
  /// In en, this message translates to:
  /// **'Rate Limit'**
  String get rateLimit;

  /// No description provided for @sharedUsers.
  ///
  /// In en, this message translates to:
  /// **'Shared Users'**
  String get sharedUsers;

  /// No description provided for @sessionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Session Timeout'**
  String get sessionTimeout;

  /// No description provided for @idleTimeout.
  ///
  /// In en, this message translates to:
  /// **'Idle Timeout'**
  String get idleTimeout;

  /// No description provided for @keepaliveTimeout.
  ///
  /// In en, this message translates to:
  /// **'Keepalive Timeout'**
  String get keepaliveTimeout;

  /// No description provided for @deleteRouter.
  ///
  /// In en, this message translates to:
  /// **'Delete Router'**
  String get deleteRouter;

  /// No description provided for @deleteRouterConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this router? This action cannot be undone.'**
  String get deleteRouterConfirm;

  /// No description provided for @routerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Router deleted successfully'**
  String get routerDeleted;

  /// No description provided for @editRouter.
  ///
  /// In en, this message translates to:
  /// **'Edit Router'**
  String get editRouter;

  /// No description provided for @routerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Router updated successfully'**
  String get routerUpdated;

  /// No description provided for @failedDeleteRouter.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete router'**
  String get failedDeleteRouter;

  /// No description provided for @failedUpdateRouter.
  ///
  /// In en, this message translates to:
  /// **'Failed to update router'**
  String get failedUpdateRouter;

  /// No description provided for @rebootRouter.
  ///
  /// In en, this message translates to:
  /// **'Reboot Router'**
  String get rebootRouter;

  /// No description provided for @rebootRouterConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reboot this router?'**
  String get rebootRouterConfirm;

  /// No description provided for @rebootSuccess.
  ///
  /// In en, this message translates to:
  /// **'Router reboot initiated'**
  String get rebootSuccess;

  /// No description provided for @splashConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to server...'**
  String get splashConnecting;

  /// No description provided for @splashCheckingAuth.
  ///
  /// In en, this message translates to:
  /// **'Checking authentication...'**
  String get splashCheckingAuth;

  /// No description provided for @splashLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get splashLoadingProfile;

  /// No description provided for @splashReady.
  ///
  /// In en, this message translates to:
  /// **'Ready!'**
  String get splashReady;

  /// No description provided for @splashFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get splashFailed;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a message to the admin team'**
  String get contactUsSubtitle;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully!'**
  String get messageSent;

  /// No description provided for @myMessages.
  ///
  /// In en, this message translates to:
  /// **'My Messages'**
  String get myMessages;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @replied.
  ///
  /// In en, this message translates to:
  /// **'Replied'**
  String get replied;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @adminReply.
  ///
  /// In en, this message translates to:
  /// **'Admin Reply'**
  String get adminReply;

  /// No description provided for @subjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get subjectRequired;

  /// No description provided for @messageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get messageRequired;

  /// No description provided for @sendMessageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message. Please try again.'**
  String get sendMessageFailed;

  /// No description provided for @myRouters.
  ///
  /// In en, this message translates to:
  /// **'My Routers'**
  String get myRouters;

  /// No description provided for @addFirstRouterHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first MikroTik router to get started.'**
  String get addFirstRouterHint;

  /// No description provided for @errorLoadingRouters.
  ///
  /// In en, this message translates to:
  /// **'Error loading routers'**
  String get errorLoadingRouters;

  /// No description provided for @deleteRouterTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Router'**
  String get deleteRouterTitle;

  /// No description provided for @deleteRouterMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'\'{routerName}\'\'?'**
  String deleteRouterMsg(String routerName);

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add Profile'**
  String get addProfile;

  /// No description provided for @failedLoadProfiles.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Profiles'**
  String get failedLoadProfiles;

  /// No description provided for @noProfilesFound.
  ///
  /// In en, this message translates to:
  /// **'No Profiles Found'**
  String get noProfilesFound;

  /// No description provided for @noProfilesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to create your first profile'**
  String get noProfilesHint;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Wassal'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'MikroTik hotspot management platform'**
  String get aboutDescription;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @networkDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Network Diagnostics'**
  String get networkDiagnostics;

  /// No description provided for @diagnoseNetwork.
  ///
  /// In en, this message translates to:
  /// **'Diagnose Network'**
  String get diagnoseNetwork;

  /// No description provided for @runningDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Running diagnostics...'**
  String get runningDiagnostics;

  /// No description provided for @diagWifiConnectivity.
  ///
  /// In en, this message translates to:
  /// **'WiFi / Cellular'**
  String get diagWifiConnectivity;

  /// No description provided for @diagDnsApi.
  ///
  /// In en, this message translates to:
  /// **'DNS: api.wassal.tech'**
  String get diagDnsApi;

  /// No description provided for @diagDnsGoogle.
  ///
  /// In en, this message translates to:
  /// **'DNS: google.com'**
  String get diagDnsGoogle;

  /// No description provided for @diagHttpHealth.
  ///
  /// In en, this message translates to:
  /// **'HTTP: Server Health'**
  String get diagHttpHealth;

  /// No description provided for @diagIpVersion.
  ///
  /// In en, this message translates to:
  /// **'IP Version'**
  String get diagIpVersion;

  /// No description provided for @diagResponseTime.
  ///
  /// In en, this message translates to:
  /// **'Response Time'**
  String get diagResponseTime;

  /// No description provided for @diagPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get diagPassed;

  /// No description provided for @diagFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get diagFailed;

  /// No description provided for @diagSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get diagSkipped;

  /// No description provided for @diagRunAgain.
  ///
  /// In en, this message translates to:
  /// **'Run Again'**
  String get diagRunAgain;

  /// No description provided for @diagResolvedTo.
  ///
  /// In en, this message translates to:
  /// **'Resolved to {ip}'**
  String diagResolvedTo(String ip);

  /// No description provided for @diagResponseMs.
  ///
  /// In en, this message translates to:
  /// **'{ms}ms'**
  String diagResponseMs(int ms);

  /// No description provided for @diagNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No network connection detected'**
  String get diagNoConnection;

  /// No description provided for @diagDnsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve hostname'**
  String get diagDnsFailed;

  /// No description provided for @diagServerOk.
  ///
  /// In en, this message translates to:
  /// **'Server is reachable'**
  String get diagServerOk;

  /// No description provided for @diagServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Server is unreachable'**
  String get diagServerUnreachable;

  /// No description provided for @diagIpv4.
  ///
  /// In en, this message translates to:
  /// **'IPv4'**
  String get diagIpv4;

  /// No description provided for @diagIpv6.
  ///
  /// In en, this message translates to:
  /// **'IPv6'**
  String get diagIpv6;

  /// No description provided for @diagIpv4And6.
  ///
  /// In en, this message translates to:
  /// **'IPv4 + IPv6'**
  String get diagIpv4And6;

  /// No description provided for @diagSummaryAllGood.
  ///
  /// In en, this message translates to:
  /// **'All checks passed. Your connection to the server is working.'**
  String get diagSummaryAllGood;

  /// No description provided for @diagSummaryDnsIssue.
  ///
  /// In en, this message translates to:
  /// **'DNS resolution failed. Your network may be blocking this domain.'**
  String get diagSummaryDnsIssue;

  /// No description provided for @diagSummaryServerDown.
  ///
  /// In en, this message translates to:
  /// **'DNS works but the server is unreachable. The server may be down.'**
  String get diagSummaryServerDown;

  /// No description provided for @diagSummaryNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection detected. Check your WiFi or mobile data.'**
  String get diagSummaryNoInternet;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
