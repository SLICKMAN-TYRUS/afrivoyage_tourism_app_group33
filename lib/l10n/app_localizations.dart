import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_rw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('fr'),
    Locale('rw')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'AfriVoyage'**
  String get appTitle;

  /// Subtitle shown on the login screen
  ///
  /// In en, this message translates to:
  /// **'Discover authentic Rwanda experiences'**
  String get appTagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a link to reset your password.'**
  String get resetPasswordHint;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @iAma.
  ///
  /// In en, this message translates to:
  /// **'I am a'**
  String get iAma;

  /// No description provided for @tourist.
  ///
  /// In en, this message translates to:
  /// **'Tourist'**
  String get tourist;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @touristSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore & book experiences'**
  String get touristSubtitle;

  /// No description provided for @providerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List & manage experiences'**
  String get providerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get agreeToTerms;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navImpact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get navImpact;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @discoverRwanda.
  ///
  /// In en, this message translates to:
  /// **'Discover Rwanda'**
  String get discoverRwanda;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @yourImpact.
  ///
  /// In en, this message translates to:
  /// **'Your Impact'**
  String get yourImpact;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Toggle between light and dark theme'**
  String get darkModeSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @offlineModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable offline access to bookings'**
  String get offlineModeSubtitle;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @perPerson.
  ///
  /// In en, this message translates to:
  /// **'per person'**
  String get perPerson;

  /// No description provided for @providerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Provider Dashboard'**
  String get providerDashboard;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @listings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listings;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @enterFirstAndLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first and last name'**
  String get enterFirstAndLastName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Jean-Baptiste Uwimana'**
  String get fullNameHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. +250 788 123 456'**
  String get phoneHint;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (9-15 digits)'**
  String get enterValidPhone;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @selectDateOfBirthHelper.
  ///
  /// In en, this message translates to:
  /// **'Select Date of Birth'**
  String get selectDateOfBirthHelper;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. jean@example.com'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHint;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @includeUppercase.
  ///
  /// In en, this message translates to:
  /// **'Include at least one uppercase letter'**
  String get includeUppercase;

  /// No description provided for @includeNumber.
  ///
  /// In en, this message translates to:
  /// **'Include at least one number'**
  String get includeNumber;

  /// No description provided for @reEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reEnterPassword;

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

  /// No description provided for @selectDobSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get selectDobSnackbar;

  /// No description provided for @agreeToTermsSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Service to continue'**
  String get agreeToTermsSnackbar;

  /// No description provided for @iAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get iAgreeTo;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @byContinuing.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service and Privacy Policy.'**
  String get byContinuing;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @passwordResetSentPrefix.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to'**
  String get passwordResetSentPrefix;

  /// No description provided for @strengthVeryWeak.
  ///
  /// In en, this message translates to:
  /// **'Very weak'**
  String get strengthVeryWeak;

  /// No description provided for @strengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get strengthWeak;

  /// No description provided for @strengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get strengthFair;

  /// No description provided for @strengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get strengthGood;

  /// No description provided for @strengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strengthStrong;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search experiences, locations…'**
  String get searchHint;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get categoryNature;

  /// No description provided for @categoryCulture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get categoryCulture;

  /// No description provided for @categoryFoodDrink.
  ///
  /// In en, this message translates to:
  /// **'Food & Drink'**
  String get categoryFoodDrink;

  /// No description provided for @categoryAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get categoryAdventure;

  /// No description provided for @noExperiencesFound.
  ///
  /// In en, this message translates to:
  /// **'No experiences found'**
  String get noExperiencesFound;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @bookingConfirmedNotif.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get bookingConfirmedNotif;

  /// No description provided for @newReview.
  ///
  /// In en, this message translates to:
  /// **'New review'**
  String get newReview;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @exploreRwanda.
  ///
  /// In en, this message translates to:
  /// **'Explore Rwanda'**
  String get exploreRwanda;

  /// No description provided for @landOfThousandHills.
  ///
  /// In en, this message translates to:
  /// **'The Land of a Thousand Hills'**
  String get landOfThousandHills;

  /// No description provided for @topRatedExperiences.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Experiences'**
  String get topRatedExperiences;

  /// No description provided for @destinations.
  ///
  /// In en, this message translates to:
  /// **'Destinations'**
  String get destinations;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @allBookings.
  ///
  /// In en, this message translates to:
  /// **'All Bookings'**
  String get allBookings;

  /// No description provided for @travelTips.
  ///
  /// In en, this message translates to:
  /// **'Travel Tips'**
  String get travelTips;

  /// No description provided for @bestTimeToVisit.
  ///
  /// In en, this message translates to:
  /// **'Best Time to Visit'**
  String get bestTimeToVisit;

  /// No description provided for @healthAndSafety.
  ///
  /// In en, this message translates to:
  /// **'Health & Safety'**
  String get healthAndSafety;

  /// No description provided for @currencyTip.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyTip;

  /// No description provided for @touristAccount.
  ///
  /// In en, this message translates to:
  /// **'Tourist Account'**
  String get touristAccount;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @darkModeToggle.
  ///
  /// In en, this message translates to:
  /// **'Toggle light / dark theme'**
  String get darkModeToggle;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @aboutAfriVoyage.
  ///
  /// In en, this message translates to:
  /// **'About AfriVoyage'**
  String get aboutAfriVoyage;

  /// No description provided for @bookExperience.
  ///
  /// In en, this message translates to:
  /// **'Book Experience'**
  String get bookExperience;

  /// No description provided for @noExperienceSelected.
  ///
  /// In en, this message translates to:
  /// **'No experience selected.'**
  String get noExperienceSelected;

  /// No description provided for @browseExperiencesFromHome.
  ///
  /// In en, this message translates to:
  /// **'Browse experiences from the Home tab.'**
  String get browseExperiencesFromHome;

  /// No description provided for @browseExperiences.
  ///
  /// In en, this message translates to:
  /// **'Browse Experiences'**
  String get browseExperiences;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @tapToChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a date'**
  String get tapToChooseDate;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @groupSize.
  ///
  /// In en, this message translates to:
  /// **'Group Size'**
  String get groupSize;

  /// No description provided for @numberOfPeople.
  ///
  /// In en, this message translates to:
  /// **'Number of people'**
  String get numberOfPeople;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @mtnMobileMoney.
  ///
  /// In en, this message translates to:
  /// **'MTN Mobile Money'**
  String get mtnMobileMoney;

  /// No description provided for @payWithMtn.
  ///
  /// In en, this message translates to:
  /// **'Pay securely with MTN MoMo'**
  String get payWithMtn;

  /// No description provided for @airtelMoney.
  ///
  /// In en, this message translates to:
  /// **'Airtel Money'**
  String get airtelMoney;

  /// No description provided for @payWithAirtel.
  ///
  /// In en, this message translates to:
  /// **'Pay securely with Airtel'**
  String get payWithAirtel;

  /// No description provided for @priceBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Price Breakdown'**
  String get priceBreakdown;

  /// No description provided for @experienceFee.
  ///
  /// In en, this message translates to:
  /// **'Experience fee'**
  String get experienceFee;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @platformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform fee (8 %)'**
  String get platformFee;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @confirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pay'**
  String get confirmAndPay;

  /// No description provided for @selectDateToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please select a date to continue'**
  String get selectDateToContinue;

  /// No description provided for @freeCancellation.
  ///
  /// In en, this message translates to:
  /// **'Free cancellation up to 24 hours before the experience'**
  String get freeCancellation;

  /// No description provided for @bookingConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bookingConfirmedTitle;

  /// No description provided for @smsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'You will receive an SMS confirmation shortly.'**
  String get smsConfirmation;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'person'**
  String get person;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'people'**
  String get people;

  /// No description provided for @seeTheDifference.
  ///
  /// In en, this message translates to:
  /// **'See the difference you\'re making in local communities'**
  String get seeTheDifference;

  /// No description provided for @familiesSupported.
  ///
  /// In en, this message translates to:
  /// **'Families supported'**
  String get familiesSupported;

  /// No description provided for @localEarnings.
  ///
  /// In en, this message translates to:
  /// **'Local earnings (RWF)'**
  String get localEarnings;

  /// No description provided for @verifiedBookings.
  ///
  /// In en, this message translates to:
  /// **'Verified bookings'**
  String get verifiedBookings;

  /// No description provided for @hoursExperienced.
  ///
  /// In en, this message translates to:
  /// **'Hours experienced'**
  String get hoursExperienced;

  /// No description provided for @communityImpactBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Community Impact Breakdown'**
  String get communityImpactBreakdown;

  /// No description provided for @conservationEfforts.
  ///
  /// In en, this message translates to:
  /// **'Conservation efforts'**
  String get conservationEfforts;

  /// No description provided for @localGuideSupport.
  ///
  /// In en, this message translates to:
  /// **'Local guide support'**
  String get localGuideSupport;

  /// No description provided for @womensCooperatives.
  ///
  /// In en, this message translates to:
  /// **'Women\'s cooperatives'**
  String get womensCooperatives;

  /// No description provided for @communityDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Community development'**
  String get communityDevelopment;

  /// No description provided for @verifiedGuideBadge.
  ///
  /// In en, this message translates to:
  /// **'Verified Guide — RDB Certified'**
  String get verifiedGuideBadge;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @recentBookings.
  ///
  /// In en, this message translates to:
  /// **'Recent Bookings'**
  String get recentBookings;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addExperience.
  ///
  /// In en, this message translates to:
  /// **'Add Experience'**
  String get addExperience;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @newBookingNotif.
  ///
  /// In en, this message translates to:
  /// **'New Booking'**
  String get newBookingNotif;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get paymentReceived;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @setAvailability.
  ///
  /// In en, this message translates to:
  /// **'Set Availability'**
  String get setAvailability;

  /// No description provided for @availabilityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Availability management is coming soon.\nYou\'ll be able to block dates and set capacity.'**
  String get availabilityComingSoon;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @providerSupport.
  ///
  /// In en, this message translates to:
  /// **'Provider Support'**
  String get providerSupport;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us:'**
  String get contactUs;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @noListingsYet.
  ///
  /// In en, this message translates to:
  /// **'No listings yet.'**
  String get noListingsYet;

  /// No description provided for @availableForBooking.
  ///
  /// In en, this message translates to:
  /// **'Available for booking'**
  String get availableForBooking;

  /// No description provided for @notAcceptingBookings.
  ///
  /// In en, this message translates to:
  /// **'Not accepting bookings'**
  String get notAcceptingBookings;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addNewExperience.
  ///
  /// In en, this message translates to:
  /// **'Add New Experience'**
  String get addNewExperience;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @priceRwf.
  ///
  /// In en, this message translates to:
  /// **'Price (RWF)'**
  String get priceRwf;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @experienceAdded.
  ///
  /// In en, this message translates to:
  /// **'Experience added!'**
  String get experienceAdded;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get editListing;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @reviewsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsLabel;

  /// No description provided for @estMonthlyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Est. Monthly Revenue'**
  String get estMonthlyRevenue;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing'**
  String get deleteListing;

  /// No description provided for @listingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Listing deleted.'**
  String get listingDeleted;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @monthlyBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Monthly Breakdown'**
  String get monthlyBreakdown;

  /// No description provided for @commissionStructure.
  ///
  /// In en, this message translates to:
  /// **'Commission Structure'**
  String get commissionStructure;

  /// No description provided for @yourEarnings.
  ///
  /// In en, this message translates to:
  /// **'Your earnings'**
  String get yourEarnings;

  /// No description provided for @bookingsCount.
  ///
  /// In en, this message translates to:
  /// **'bookings'**
  String get bookingsCount;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get pageNotFound;

  /// No description provided for @oopsLostInAfrica.
  ///
  /// In en, this message translates to:
  /// **'Oops! Lost in Africa?'**
  String get oopsLostInAfrica;

  /// No description provided for @pageNotFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'The page you\'re looking for doesn\'t exist.'**
  String get pageNotFoundDesc;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;
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
      <String>['en', 'fr', 'rw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'rw':
      return AppLocalizationsRw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
