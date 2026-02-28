import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

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
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('es'),
  ];

  /// Label for appTitle
  ///
  /// In en, this message translates to:
  /// **'DayApp'**
  String get appTitle;

  /// Label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Label shown in language selection to use the device's default language
  ///
  /// In en, this message translates to:
  /// **'Device default'**
  String get deviceDefault;

  /// Label used to indicate the default option, e.g. in chips
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// Label for english
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Label for spanish
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// Label for tryAgain
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Message shown when the app fails to initialize
  ///
  /// In en, this message translates to:
  /// **'Error initializing app'**
  String get errorInitializingApp;

  /// Label for theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @themeAndScheme.
  ///
  /// In en, this message translates to:
  /// **'Theme and Scheme'**
  String get themeAndScheme;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @automaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic Backup'**
  String get automaticBackup;

  /// No description provided for @lastAutoBackup.
  ///
  /// In en, this message translates to:
  /// **'Last automatic backup'**
  String get lastAutoBackup;

  /// No description provided for @backupOnLogout.
  ///
  /// In en, this message translates to:
  /// **'Backup on logout'**
  String get backupOnLogout;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Label for pinUnlock
  ///
  /// In en, this message translates to:
  /// **'Unlock PIN'**
  String get pinUnlock;

  /// Label for changePin
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// Label for enableBiometrics
  ///
  /// In en, this message translates to:
  /// **'Biometric login'**
  String get enableBiometrics;

  /// Label for information
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// Label for email
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// Label for password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Label for configurePin
  ///
  /// In en, this message translates to:
  /// **'Configure PIN'**
  String get configurePin;

  /// Label for biometrics
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// Label for backgroundLock
  ///
  /// In en, this message translates to:
  /// **'Background lock'**
  String get backgroundLock;

  /// Prompt asking how long the app should be locked after being in background
  ///
  /// In en, this message translates to:
  /// **'How long should the app be locked after being in background?'**
  String get backgroundLockDialogPrompt;

  /// No description provided for @backgroundLockTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get backgroundLockTimeLabel;

  /// No description provided for @backgroundLockDialogResult.
  ///
  /// In en, this message translates to:
  /// **'Result:'**
  String get backgroundLockDialogResult;

  /// No description provided for @backgroundLockSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions:'**
  String get backgroundLockSuggestions;

  /// No description provided for @backgroundLockImmediateHint.
  ///
  /// In en, this message translates to:
  /// **'0 = immediate'**
  String get backgroundLockImmediateHint;

  /// Label for statistics
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @noStoriesYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No stories yet'**
  String get noStoriesYetTitle;

  /// No description provided for @noStoriesYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start recording your days to see statistics'**
  String get noStoriesYetSubtitle;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @activityByWeekday.
  ///
  /// In en, this message translates to:
  /// **'Activity by weekday'**
  String get activityByWeekday;

  /// No description provided for @streaksTitle.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaksTitle;

  /// No description provided for @longestStreakPrefix.
  ///
  /// In en, this message translates to:
  /// **'Longest streak:'**
  String get longestStreakPrefix;

  /// No description provided for @tableOfMoods.
  ///
  /// In en, this message translates to:
  /// **'Mood table'**
  String get tableOfMoods;

  /// No description provided for @moodCount.
  ///
  /// In en, this message translates to:
  /// **'Mood count'**
  String get moodCount;

  /// No description provided for @topTags.
  ///
  /// In en, this message translates to:
  /// **'Top tags'**
  String get topTags;

  /// No description provided for @storiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get storiesLabel;

  /// No description provided for @activeDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDaysLabel;

  /// No description provided for @avgPerDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg/day'**
  String get avgPerDayLabel;

  /// No description provided for @mediaLabel.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get mediaLabel;

  /// Label for manageGroups
  ///
  /// In en, this message translates to:
  /// **'Manage groups'**
  String get manageGroups;

  /// Label for trash
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// Label for help
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Label for about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Label for logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Label for createAccount
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Label for name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Label for confirmPassword
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Label for createAccountButton
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// Label for alreadyHaveAccount
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAccount;

  /// Label for needHelp
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// Label for currentPinLabel
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPinLabel;

  /// Label for newPinLabel
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPinLabel;

  /// Label for pinLabel
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// Label for confirmPin
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// Label for enterCurrentPin
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get enterCurrentPin;

  /// Label for enterPin
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// Message for pinLengthError
  ///
  /// In en, this message translates to:
  /// **'PIN must be between 4 and 8 digits'**
  String get pinLengthError;

  /// Message for pinsDoNotMatch
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinsDoNotMatch;

  /// Message for pinIncorrect
  ///
  /// In en, this message translates to:
  /// **'Current PIN incorrect'**
  String get pinIncorrect;

  /// Message for pinChangedSuccess
  ///
  /// In en, this message translates to:
  /// **'PIN changed successfully!'**
  String get pinChangedSuccess;

  /// Message for pinConfiguredSuccess
  ///
  /// In en, this message translates to:
  /// **'PIN configured successfully!'**
  String get pinConfiguredSuccess;

  /// Message for informYourEmail
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get informYourEmail;

  /// Message for invalidEmail
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get invalidEmail;

  /// Message for emailNotFound
  ///
  /// In en, this message translates to:
  /// **'Email not found. Check and try again.'**
  String get emailNotFound;

  /// Message for codeSent
  ///
  /// In en, this message translates to:
  /// **'Code sent to {email}! Check your inbox.'**
  String codeSent(Object email);

  /// Message for codeMustBe6
  ///
  /// In en, this message translates to:
  /// **'The code must be 6 digits.'**
  String get codeMustBe6;

  /// Message for codeVerified
  ///
  /// In en, this message translates to:
  /// **'Code verified! Set your new password.'**
  String get codeVerified;

  /// Message for codeInvalid
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code. Try again.'**
  String get codeInvalid;

  /// Message for enterNewPassword
  ///
  /// In en, this message translates to:
  /// **'Enter the new password.'**
  String get enterNewPassword;

  /// Message for passwordResetSuccess
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! Log in with the new password.'**
  String get passwordResetSuccess;

  /// Message for errorResetPassword
  ///
  /// In en, this message translates to:
  /// **'Error resetting password. Try again.'**
  String get errorResetPassword;

  /// Message for passwordsDoNotMatch
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// Message for resendCodeSuccess
  ///
  /// In en, this message translates to:
  /// **'New code sent! Check your inbox.'**
  String get resendCodeSuccess;

  /// Message for resendCodeError
  ///
  /// In en, this message translates to:
  /// **'Error resending code. Try again.'**
  String get resendCodeError;

  /// Message for passwordMinLength
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMinLength;

  /// Label for sendCode
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// Label for unlock
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Label for fullName
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// Label for birth date field
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get birthDate;

  /// No description provided for @almostReady.
  ///
  /// In en, this message translates to:
  /// **'almost ready...'**
  String get almostReady;

  /// No description provided for @optionalData.
  ///
  /// In en, this message translates to:
  /// **'The fields below are optional'**
  String get optionalData;

  /// No description provided for @birthDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Birth date (DD/MM/YYYY)'**
  String get birthDateFormat;

  /// No description provided for @invalidBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid birth date (use DD/MM/YYYY)'**
  String get invalidBirthDate;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get userNotFound;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Message for nameRequired
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Message for nameMinLength
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// Message for emailRequired
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Message for emailInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// Label for welcomeBack
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// Label for accessAccount
  ///
  /// In en, this message translates to:
  /// **'Access your account'**
  String get accessAccount;

  /// Label for enterPassword
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Label for signIn
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Label for forgotPassword
  ///
  /// In en, this message translates to:
  /// **'Forgot my password'**
  String get forgotPassword;

  /// Label for noAccountCreateHere
  ///
  /// In en, this message translates to:
  /// **'No account? Create one here.'**
  String get noAccountCreateHere;

  /// Label for privacyPolicy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Message for biometricsEnabledSuccess
  ///
  /// In en, this message translates to:
  /// **'Biometrics enabled successfully!'**
  String get biometricsEnabledSuccess;

  /// Message for biometricLoginError
  ///
  /// In en, this message translates to:
  /// **'Error logging in with biometrics.'**
  String get biometricLoginError;

  /// Message for invalidCredentials
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidCredentials;

  /// Message for profileUpdatedSuccess
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// Message for profileUpdateError
  ///
  /// In en, this message translates to:
  /// **'Error updating profile. Try again.'**
  String get profileUpdateError;

  /// Message for unlockAppReason
  ///
  /// In en, this message translates to:
  /// **'Unlock the app to continue'**
  String get unlockAppReason;

  /// Message for fillEmailAndPassword
  ///
  /// In en, this message translates to:
  /// **'Fill in email and password'**
  String get fillEmailAndPassword;

  /// Message for emailOrPasswordIncorrect
  ///
  /// In en, this message translates to:
  /// **'Email or password incorrect'**
  String get emailOrPasswordIncorrect;

  /// Message for noEmailRegistered
  ///
  /// In en, this message translates to:
  /// **'No email registered. Configure it in settings.'**
  String get noEmailRegistered;

  /// Message for checkEmailOrUseCode
  ///
  /// In en, this message translates to:
  /// **'Check your email at {email} or use the displayed code'**
  String checkEmailOrUseCode(Object email);

  /// Message for errorGeneratingCode
  ///
  /// In en, this message translates to:
  /// **'Error generating code. Try again.'**
  String get errorGeneratingCode;

  /// Message for errorSendingCode
  ///
  /// In en, this message translates to:
  /// **'Error sending code. Try again.'**
  String get errorSendingCode;

  /// Label for recoverPinTitle
  ///
  /// In en, this message translates to:
  /// **'Recover PIN'**
  String get recoverPinTitle;

  /// Label for enterRecoveryCodePrompt
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your email:'**
  String get enterRecoveryCodePrompt;

  /// Label for recoveryCodeLabel
  ///
  /// In en, this message translates to:
  /// **'Recovery code (6 digits)'**
  String get recoveryCodeLabel;

  /// Label for enterPasswordToContinue
  ///
  /// In en, this message translates to:
  /// **'Enter your password to continue'**
  String get enterPasswordToContinue;

  /// Label for enterPinToContinue
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue'**
  String get enterPinToContinue;

  /// Label for useBiometricsToContinue
  ///
  /// In en, this message translates to:
  /// **'Use your biometrics to continue'**
  String get useBiometricsToContinue;

  /// No description provided for @usePin.
  ///
  /// In en, this message translates to:
  /// **'Use PIN'**
  String get usePin;

  /// No description provided for @noStoriesHere.
  ///
  /// In en, this message translates to:
  /// **'No stories to display here.'**
  String get noStoriesHere;

  /// No description provided for @storiesGroupedOrArchived.
  ///
  /// In en, this message translates to:
  /// **'They are either grouped or archived.'**
  String get storiesGroupedOrArchived;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get useBiometrics;

  /// No description provided for @unlockWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Biometrics'**
  String get unlockWithBiometrics;

  /// No description provided for @useAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Use account password'**
  String get useAccountPassword;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot my PIN'**
  String get forgotPin;

  /// Label for unlockTitle
  ///
  /// In en, this message translates to:
  /// **'Unlock the App'**
  String get unlockTitle;

  /// Label for search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Search your stories'**
  String get searchStoriesTitle;

  /// No description provided for @searchStoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the filters above to find your memories.'**
  String get searchStoriesSubtitle;

  /// No description provided for @unsavedBackups.
  ///
  /// In en, this message translates to:
  /// **'You have {count} stories not backed up.'**
  String unsavedBackups(Object count);

  /// Label for backupRecommendation
  ///
  /// In en, this message translates to:
  /// **'We recommend backing up to avoid losing your data.'**
  String get backupRecommendation;

  /// Label for cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for performBackup
  ///
  /// In en, this message translates to:
  /// **'Backup now'**
  String get performBackup;

  /// Label for deleteStoryTitle
  ///
  /// In en, this message translates to:
  /// **'Delete story'**
  String get deleteStoryTitle;

  /// Message for deleteStoryConfirm
  ///
  /// In en, this message translates to:
  /// **'Do you want to move this story to the trash?'**
  String get deleteStoryConfirm;

  /// Label for deleteLabel
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// Message for movedToTrash
  ///
  /// In en, this message translates to:
  /// **'Story moved to trash'**
  String get movedToTrash;

  /// Error message when deleting story fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting story: {error}'**
  String errorDeletingStory(Object error);

  /// Message when there are no records on given day
  ///
  /// In en, this message translates to:
  /// **'No records for this day'**
  String get noRecordsThisDay;

  /// Label showing story is ungrouped
  ///
  /// In en, this message translates to:
  /// **'Story ungrouped'**
  String get storyUngrouped;

  /// Generic save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Title for deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// Snackbar message when a group is deleted
  ///
  /// In en, this message translates to:
  /// **'Group deleted successfully'**
  String get groupDeletedSuccess;

  /// Displayed when no groups are found
  ///
  /// In en, this message translates to:
  /// **'No groups found'**
  String get noGroupsFound;

  /// Error message when sharing fails
  ///
  /// In en, this message translates to:
  /// **'Could not share'**
  String get shareError;

  /// Error shown when photo deletion fails
  ///
  /// In en, this message translates to:
  /// **'Cannot delete this photo'**
  String get cannotDeletePhoto;

  /// Dialog title for photo deletion
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get deletePhotoTitle;

  /// Confirmation text for deleting a photo
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this photo?'**
  String get deletePhotoConfirm;

  /// Dialog title for group deletion
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get deleteGroupTitle;

  /// Label for share action
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Label for home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Label for groups tab
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'record'**
  String get record;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get records;

  /// No description provided for @filterText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get filterText;

  /// No description provided for @filterTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get filterTag;

  /// No description provided for @filterEmoticon.
  ///
  /// In en, this message translates to:
  /// **'Emoticon'**
  String get filterEmoticon;

  /// No description provided for @searchHintTag.
  ///
  /// In en, this message translates to:
  /// **'Type a tag...'**
  String get searchHintTag;

  /// No description provided for @searchHintText.
  ///
  /// In en, this message translates to:
  /// **'Search in title or description...'**
  String get searchHintText;

  /// No description provided for @clearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchTooltip;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @tapToSelectEmoji.
  ///
  /// In en, this message translates to:
  /// **'Tap to select an emoji:'**
  String get tapToSelectEmoji;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @recordVideoLabel.
  ///
  /// In en, this message translates to:
  /// **'Record a video'**
  String get recordVideoLabel;

  /// No description provided for @recordAudioLabel.
  ///
  /// In en, this message translates to:
  /// **'Record audio'**
  String get recordAudioLabel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// No description provided for @laterLabel.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterLabel;

  /// No description provided for @configureLabel.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configureLabel;

  /// Snackbar when image copied
  ///
  /// In en, this message translates to:
  /// **'Image copied to clipboard (base64)'**
  String get imageCopiedBase64;

  /// Label for creating new group
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// Label for editing a group
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get editGroup;

  /// Prompt to choose icon
  ///
  /// In en, this message translates to:
  /// **'Choose icon'**
  String get chooseIcon;

  /// Warning shown when deleting a group with stories
  ///
  /// In en, this message translates to:
  /// **'This group has {count} story(ies) linked. If deleted, those stories will return to the home screen (no group). Continue?'**
  String groupDeleteWarning(Object count);

  /// Label for unarchive
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// Label for group
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select Group'**
  String get selectGroup;

  /// No description provided for @existingGroups.
  ///
  /// In en, this message translates to:
  /// **'Existing Groups'**
  String get existingGroups;

  /// No description provided for @createNewGroup.
  ///
  /// In en, this message translates to:
  /// **'Create New Group'**
  String get createNewGroup;

  /// No description provided for @groupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupNameLabel;

  /// No description provided for @createAndSelect.
  ///
  /// In en, this message translates to:
  /// **'Create and Select'**
  String get createAndSelect;

  /// No description provided for @manageBackups.
  ///
  /// In en, this message translates to:
  /// **'Manage Backup'**
  String get manageBackups;

  /// No description provided for @createAndShareBackup.
  ///
  /// In en, this message translates to:
  /// **'Create and Share Backup'**
  String get createAndShareBackup;

  /// No description provided for @restoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from File'**
  String get restoreFromFile;

  /// No description provided for @backupNotAvailableWeb.
  ///
  /// In en, this message translates to:
  /// **'Backup not available on web'**
  String get backupNotAvailableWeb;

  /// No description provided for @backupNotAvailableDetail.
  ///
  /// In en, this message translates to:
  /// **'The backup feature requires file system access, available only on Android, iOS and desktop versions.'**
  String get backupNotAvailableDetail;

  /// No description provided for @backupInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About Backup'**
  String get backupInfoTitle;

  /// No description provided for @backupInfoDetails.
  ///
  /// In en, this message translates to:
  /// **'The complete backup includes:\n• Database (stories, texts, photos, audios)\n• Video files\n\nA ZIP file will be created and you can save it wherever you want:\n• OneDrive\n• Google Drive\n• Email\n• Any other location'**
  String get backupInfoDetails;

  /// No description provided for @backupComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete Backup'**
  String get backupComplete;

  /// No description provided for @backupZipSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ZIP file with all your data'**
  String get backupZipSubtitle;

  /// No description provided for @backupZipExplanation.
  ///
  /// In en, this message translates to:
  /// **'Generates a ZIP file that you can save to OneDrive, Google Drive, email or any other location.'**
  String get backupZipExplanation;

  /// No description provided for @restoreSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreSectionTitle;

  /// No description provided for @restoreSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a backup file (ZIP) previously created to restore all your data.'**
  String get restoreSectionDescription;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @backupStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting backup...'**
  String get backupStarting;

  /// No description provided for @backupCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup file created! Use the share menu to save it.'**
  String get backupCreatedSuccess;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Error creating backup: {message}'**
  String backupError(Object message);

  /// No description provided for @restoreStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting restore...'**
  String get restoreStarting;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore completed successfully!'**
  String get restoreSuccess;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Error restoring: {message}'**
  String restoreError(Object message);

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Confirm Restore'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'All current data will be replaced by the backup.\n\nThis action cannot be undone. Do you wish to continue?'**
  String get restoreConfirmContent;

  /// No description provided for @restoreSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'✅ Restore Completed'**
  String get restoreSuccessTitle;

  /// No description provided for @restoreSuccessContent.
  ///
  /// In en, this message translates to:
  /// **'The backup was restored successfully!\n\nAll your stories have been restored to the backup state.\n\nYou need to log in again to complete the process.'**
  String get restoreSuccessContent;

  /// No description provided for @helpAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About DayApp'**
  String get helpAboutTitle;

  /// No description provided for @helpAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'DayApp is a personal diary app that lets you record your stories, memories and thoughts in an organized and secure way.'**
  String get helpAboutDescription;

  /// No description provided for @helpNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Main Navigation'**
  String get helpNavigationTitle;

  /// No description provided for @helpHomeItemDesc.
  ///
  /// In en, this message translates to:
  /// **'View your stories as cards or list. Tap a story to view, long press for options.'**
  String get helpHomeItemDesc;

  /// No description provided for @helpGroupsNavDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize your stories into thematic groups. Create custom groups to categorize your memories.'**
  String get helpGroupsNavDesc;

  /// No description provided for @helpSearchItemDesc.
  ///
  /// In en, this message translates to:
  /// **'Quickly find stories by title, content or date.'**
  String get helpSearchItemDesc;

  /// No description provided for @helpCreatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Creating Stories'**
  String get helpCreatingTitle;

  /// No description provided for @helpNewStoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the floating (+) button to create a new story. Add title, rich text, images, videos and audios.'**
  String get helpNewStoryDesc;

  /// No description provided for @helpTextEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Text Editor'**
  String get helpTextEditorTitle;

  /// No description provided for @helpTextEditorDesc.
  ///
  /// In en, this message translates to:
  /// **'Use rich formatting: bold, italic, lists, links and more.'**
  String get helpTextEditorDesc;

  /// No description provided for @helpMediaDesc.
  ///
  /// In en, this message translates to:
  /// **'Add photos from the gallery or camera, record videos and audios directly in the app.'**
  String get helpMediaDesc;

  /// No description provided for @helpGroupsAssocDesc.
  ///
  /// In en, this message translates to:
  /// **'Associate each story with one or more groups for better organization.'**
  String get helpGroupsAssocDesc;

  /// No description provided for @helpCalendarDesc.
  ///
  /// In en, this message translates to:
  /// **'View your stories organized by date. Tap a date to see all stories for that day.'**
  String get helpCalendarDesc;

  /// No description provided for @helpCreateGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get helpCreateGroupTitle;

  /// No description provided for @helpCreateGroupDesc.
  ///
  /// In en, this message translates to:
  /// **'Go to \"Manage Groups\" in the side menu to create new groups with custom colors.'**
  String get helpCreateGroupDesc;

  /// No description provided for @helpEditGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get helpEditGroupTitle;

  /// No description provided for @helpEditGroupDesc.
  ///
  /// In en, this message translates to:
  /// **'Long press a group to edit its name, color or delete it.'**
  String get helpEditGroupDesc;

  /// No description provided for @helpBackupSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Security'**
  String get helpBackupSecurityTitle;

  /// No description provided for @helpAutomaticBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic Backup'**
  String get helpAutomaticBackupTitle;

  /// No description provided for @helpAutomaticBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure automatic backup on logout in Settings. A backup will be created and you can choose where to save it.'**
  String get helpAutomaticBackupDesc;

  /// No description provided for @helpManualBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Backup'**
  String get helpManualBackupTitle;

  /// No description provided for @helpManualBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Go to \"Manage Backup\" in Settings to create a full backup with all media.'**
  String get helpManualBackupDesc;

  /// No description provided for @helpRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get helpRestoreTitle;

  /// No description provided for @helpRestoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Use \"Restore from File\" to recover data from a previous backup.'**
  String get helpRestoreDesc;

  /// No description provided for @helpPinSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security PIN'**
  String get helpPinSecurityTitle;

  /// No description provided for @helpPinSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'Set a 4- to 8-digit PIN to protect app access.'**
  String get helpPinSecurityDesc;

  /// No description provided for @helpBiometricsDesc.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or facial recognition to unlock the app quickly, if available on your device.'**
  String get helpBiometricsDesc;

  /// No description provided for @helpPasswordUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Unlock'**
  String get helpPasswordUnlockTitle;

  /// No description provided for @helpPasswordUnlockDesc.
  ///
  /// In en, this message translates to:
  /// **'In addition to PIN and biometrics, you can unlock the app using your account password. Useful if you forget the PIN or biometrics fail.'**
  String get helpPasswordUnlockDesc;

  /// No description provided for @helpBackgroundLockDesc.
  ///
  /// In en, this message translates to:
  /// **'When the app is minimized or you switch to another app, it locks automatically after the configured time. You can set the time freely in settings (seconds, minutes or hours).'**
  String get helpBackgroundLockDesc;

  /// No description provided for @helpLockExceptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock Exceptions'**
  String get helpLockExceptionsTitle;

  /// No description provided for @helpLockExceptionsDesc.
  ///
  /// In en, this message translates to:
  /// **'The app does not lock when you use internal features that open other apps—such as picking photos from the gallery, recording videos, choosing backup location or sharing stories.'**
  String get helpLockExceptionsDesc;

  /// No description provided for @helpPinRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'PIN Recovery'**
  String get helpPinRecoveryTitle;

  /// No description provided for @helpPinRecoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Forgot your PIN? Use the \"Forgot my PIN\" option on the lock screen. A recovery code will be sent to the registered email.'**
  String get helpPinRecoveryDesc;

  /// No description provided for @helpThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Toggle between light, dark or automatic theme.'**
  String get helpThemeDesc;

  /// No description provided for @helpNotificationsSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Set reminders to write in the diary.'**
  String get helpNotificationsSettingsDesc;

  /// No description provided for @helpBackgroundLockSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Define how long the app can stay in the background before being locked. You may use values in seconds, minutes or hours, with full freedom.'**
  String get helpBackgroundLockSettingsDesc;

  /// No description provided for @helpBackupSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get helpBackupSettingTitle;

  /// No description provided for @helpBackupSettingDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage backup and restore settings.'**
  String get helpBackupSettingDesc;

  /// No description provided for @helpTrashDesc.
  ///
  /// In en, this message translates to:
  /// **'Deleted stories stay in the trash for 30 days. Access \"Trash\" in the side menu to recover or permanently delete.'**
  String get helpTrashDesc;

  /// No description provided for @helpStatisticsDesc.
  ///
  /// In en, this message translates to:
  /// **'View statistics about your diary usage: number of stories, words written, top groups, etc.'**
  String get helpStatisticsDesc;

  /// No description provided for @helpTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage Tips'**
  String get helpTipsTitle;

  /// No description provided for @helpOrganizationTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get helpOrganizationTipTitle;

  /// No description provided for @helpOrganizationTipDesc.
  ///
  /// In en, this message translates to:
  /// **'Use groups to categorize your stories by themes, feelings or life periods.'**
  String get helpOrganizationTipDesc;

  /// No description provided for @helpSearchTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get helpSearchTipTitle;

  /// No description provided for @helpSearchTipDesc.
  ///
  /// In en, this message translates to:
  /// **'Use the search function to quickly find old stories.'**
  String get helpSearchTipDesc;

  /// No description provided for @helpBackupTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Regular Backup'**
  String get helpBackupTipTitle;

  /// No description provided for @helpBackupTipDesc.
  ///
  /// In en, this message translates to:
  /// **'Back up regularly, especially before updates or device changes.'**
  String get helpBackupTipDesc;

  /// No description provided for @helpPrivacyTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get helpPrivacyTipTitle;

  /// No description provided for @helpPrivacyTipDesc.
  ///
  /// In en, this message translates to:
  /// **'Your stories are stored locally and encrypted. Set a PIN for additional protection.'**
  String get helpPrivacyTipDesc;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get helpSupportTitle;

  /// No description provided for @helpSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'For questions or issues, contact us via support email or check app updates.'**
  String get helpSupportDesc;

  /// Displayed when account creation fails
  ///
  /// In en, this message translates to:
  /// **'Error creating account. Please try again.'**
  String get errorCreateAccount;

  /// Displayed when sharing fails
  ///
  /// In en, this message translates to:
  /// **'Error sharing'**
  String get errorShare;

  /// No description provided for @errorPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Error playing audio: {message}'**
  String errorPlayAudio(Object message);

  /// No description provided for @errorSelectVideos.
  ///
  /// In en, this message translates to:
  /// **'Error selecting videos: {message}'**
  String errorSelectVideos(Object message);

  /// No description provided for @errorSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Error selecting file: {message}'**
  String errorSelectFile(Object message);

  /// No description provided for @errorRecordVideo.
  ///
  /// In en, this message translates to:
  /// **'Error recording video: {message}'**
  String errorRecordVideo(Object message);

  /// No description provided for @errorStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Error starting recording: {message}'**
  String errorStartRecording(Object message);

  /// No description provided for @errorPauseRecording.
  ///
  /// In en, this message translates to:
  /// **'Error pausing recording: {message}'**
  String errorPauseRecording(Object message);

  /// No description provided for @errorResumeRecording.
  ///
  /// In en, this message translates to:
  /// **'Error resuming recording: {message}'**
  String errorResumeRecording(Object message);

  /// No description provided for @errorStopRecording.
  ///
  /// In en, this message translates to:
  /// **'Error stopping recording: {message}'**
  String errorStopRecording(Object message);

  /// No description provided for @errorSelectAudios.
  ///
  /// In en, this message translates to:
  /// **'Error selecting audios: {message}'**
  String errorSelectAudios(Object message);

  /// Displayed when video fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading video'**
  String get errorLoadVideo;

  /// Displayed when image selection fails
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get errorSelectImage;

  /// No description provided for @imagePickerTitleMultiple.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get imagePickerTitleMultiple;

  /// No description provided for @imagePickerTitleSingle.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get imagePickerTitleSingle;

  /// No description provided for @imagePickerChooseOptionMultiple.
  ///
  /// In en, this message translates to:
  /// **'Choose an option (gallery allows multiple photos):'**
  String get imagePickerChooseOptionMultiple;

  /// No description provided for @imagePickerChooseOptionSingle.
  ///
  /// In en, this message translates to:
  /// **'Choose an option:'**
  String get imagePickerChooseOptionSingle;

  /// No description provided for @imagePickerGalleryMultiple.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery'**
  String get imagePickerGalleryMultiple;

  /// No description provided for @imagePickerGallerySingle.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get imagePickerGallerySingle;

  /// No description provided for @imagePickerTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get imagePickerTakePhoto;

  /// No description provided for @audioPickerTitleMultiple.
  ///
  /// In en, this message translates to:
  /// **'Add Audios'**
  String get audioPickerTitleMultiple;

  /// No description provided for @audioPickerTitleSingle.
  ///
  /// In en, this message translates to:
  /// **'Add Audio'**
  String get audioPickerTitleSingle;

  /// No description provided for @audioPickerChooseOptionMultiple.
  ///
  /// In en, this message translates to:
  /// **'Choose an option (files allow multiple audios):'**
  String get audioPickerChooseOptionMultiple;

  /// No description provided for @audioPickerChooseOptionSingle.
  ///
  /// In en, this message translates to:
  /// **'Choose an option:'**
  String get audioPickerChooseOptionSingle;

  /// No description provided for @audioPickerSelectFilesMultiple.
  ///
  /// In en, this message translates to:
  /// **'Select audio files'**
  String get audioPickerSelectFilesMultiple;

  /// No description provided for @audioPickerSelectFilesSingle.
  ///
  /// In en, this message translates to:
  /// **'Pick audio file'**
  String get audioPickerSelectFilesSingle;

  /// No description provided for @audioPickerRecord.
  ///
  /// In en, this message translates to:
  /// **'Record audio'**
  String get audioPickerRecord;

  /// No description provided for @videoPickerTitleMultiple.
  ///
  /// In en, this message translates to:
  /// **'Add Videos'**
  String get videoPickerTitleMultiple;

  /// No description provided for @videoPickerTitleSingle.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get videoPickerTitleSingle;

  /// No description provided for @videoPickerChooseOptionMultiple.
  ///
  /// In en, this message translates to:
  /// **'Choose an option (files allow multiple videos):'**
  String get videoPickerChooseOptionMultiple;

  /// No description provided for @videoPickerChooseOptionSingle.
  ///
  /// In en, this message translates to:
  /// **'Choose an option:'**
  String get videoPickerChooseOptionSingle;

  /// No description provided for @videoPickerSelectFilesMultiple.
  ///
  /// In en, this message translates to:
  /// **'Select video files'**
  String get videoPickerSelectFilesMultiple;

  /// No description provided for @videoPickerSelectFilesSingle.
  ///
  /// In en, this message translates to:
  /// **'Pick video file'**
  String get videoPickerSelectFilesSingle;

  /// No description provided for @videoPickerRecord.
  ///
  /// In en, this message translates to:
  /// **'Record video'**
  String get videoPickerRecord;

  /// No description provided for @successVideoAdded.
  ///
  /// In en, this message translates to:
  /// **'Video added successfully!'**
  String get successVideoAdded;

  /// No description provided for @successVideosAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} videos added successfully!'**
  String successVideosAdded(Object count);

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get startRecording;

  /// No description provided for @recordingPaused.
  ///
  /// In en, this message translates to:
  /// **'Recording paused'**
  String get recordingPaused;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// No description provided for @readyToRecord.
  ///
  /// In en, this message translates to:
  /// **'Ready to record'**
  String get readyToRecord;

  /// Title for the notification scheduling dialog
  ///
  /// In en, this message translates to:
  /// **'Schedule Notification'**
  String get notificationDialogTitle;

  /// Prompt asking when the user wants to be notified
  ///
  /// In en, this message translates to:
  /// **'When would you like to be notified about this entry?'**
  String get notificationDialogPrompt;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'E-mail already registered.'**
  String get emailAlreadyRegistered;

  /// No description provided for @successNotificationScheduled.
  ///
  /// In en, this message translates to:
  /// **'Notification scheduled successfully'**
  String get successNotificationScheduled;

  /// Title used for entry reminder notifications
  ///
  /// In en, this message translates to:
  /// **'Reminder: {title}'**
  String notificationReminderTitle(Object title);

  /// No description provided for @successImageAdded.
  ///
  /// In en, this message translates to:
  /// **'Image added successfully!'**
  String get successImageAdded;

  /// No description provided for @successImagesAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} images added successfully!'**
  String successImagesAdded(Object count);

  /// No description provided for @errorSearch.
  ///
  /// In en, this message translates to:
  /// **'Error during search: {message}'**
  String errorSearch(Object message);

  /// No description provided for @successStoryRestored.
  ///
  /// In en, this message translates to:
  /// **'Story restored successfully'**
  String get successStoryRestored;

  /// No description provided for @successStoryDeletedPermanently.
  ///
  /// In en, this message translates to:
  /// **'Story permanently deleted'**
  String get successStoryDeletedPermanently;

  /// No description provided for @trashAlreadyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is already empty'**
  String get trashAlreadyEmpty;

  /// No description provided for @successVideoRecorded.
  ///
  /// In en, this message translates to:
  /// **'Video recorded successfully!'**
  String get successVideoRecorded;

  /// No description provided for @permissionMicrophoneDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission not granted'**
  String get permissionMicrophoneDenied;

  /// No description provided for @errorSelectImages.
  ///
  /// In en, this message translates to:
  /// **'Error selecting images: {message}'**
  String errorSelectImages(Object message);

  /// No description provided for @successPhotoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Photo captured successfully!'**
  String get successPhotoCaptured;

  /// No description provided for @restoreStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore stories'**
  String get restoreStoriesTitle;

  /// No description provided for @restoreStoriesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to restore {count} selected story(ies)?'**
  String restoreStoriesConfirm(Object count);

  /// No description provided for @restoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreLabel;

  /// No description provided for @permanentlyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete'**
  String get permanentlyDeleteTitle;

  /// Confirmation when permanently deleting a story
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Do you really want to permanently delete this story?'**
  String get permanentlyDeleteConfirm;

  /// No description provided for @permanentlyDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete'**
  String get permanentlyDeleteLabel;

  /// Confirmation when deleting a group
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove the group \"{name}\" from your stories?'**
  String deleteGroupConfirm(Object name);

  /// No description provided for @recoverPinDescription.
  ///
  /// In en, this message translates to:
  /// **'We will send a recovery code to your registered email.'**
  String get recoverPinDescription;

  /// No description provided for @emptyTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get emptyTrashTitle;

  /// No description provided for @emptyTrashConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to permanently delete all {count} story(ies) in the trash? This action cannot be undone.'**
  String emptyTrashConfirm(Object count);

  /// No description provided for @emptyTrashLabel.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get emptyTrashLabel;

  /// No description provided for @errorTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Error taking photo: {message}'**
  String errorTakePhoto(Object message);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @entryNotifications.
  ///
  /// In en, this message translates to:
  /// **'Entry notifications'**
  String get entryNotifications;

  /// No description provided for @entryNotificationsInfo.
  ///
  /// In en, this message translates to:
  /// **'Entries with a date at least 2 hours ahead may have scheduled notifications.'**
  String get entryNotificationsInfo;

  /// No description provided for @defaultAdvanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Default advance'**
  String get defaultAdvanceTitle;

  /// No description provided for @notificationAdvanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification advance'**
  String get notificationAdvanceTitle;

  /// No description provided for @notificationAdvancePrompt.
  ///
  /// In en, this message translates to:
  /// **'How much notice would you like before being notified?'**
  String get notificationAdvancePrompt;

  /// No description provided for @notificationAdvanceDefault.
  ///
  /// In en, this message translates to:
  /// **'Default advance'**
  String get notificationAdvanceDefault;

  /// No description provided for @manageCompleteBackup.
  ///
  /// In en, this message translates to:
  /// **'Manage full backup'**
  String get manageCompleteBackup;

  /// No description provided for @backupWithVideosZip.
  ///
  /// In en, this message translates to:
  /// **'Backup with videos in ZIP file'**
  String get backupWithVideosZip;

  /// No description provided for @backupOnLogoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Backup will be created when you log out'**
  String get backupOnLogoutDescription;

  /// No description provided for @automaticBackupInfo.
  ///
  /// In en, this message translates to:
  /// **'When you log out, a backup will be created and you can choose where to save it (local folder, Google Drive, etc).'**
  String get automaticBackupInfo;

  /// No description provided for @biometricsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get biometricsNotAvailable;

  /// No description provided for @biometricsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometrics disabled'**
  String get biometricsDisabled;

  /// No description provided for @biometricConfiguredInfo.
  ///
  /// In en, this message translates to:
  /// **'Biometrics is configured. You can log in using your fingerprint or face recognition.'**
  String get biometricConfiguredInfo;

  /// No description provided for @biometricAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed'**
  String get biometricAuthFailed;

  /// No description provided for @confirmIdentityToEnableBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to enable biometrics'**
  String get confirmIdentityToEnableBiometrics;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @groupExists.
  ///
  /// In en, this message translates to:
  /// **'Group already exists'**
  String get groupExists;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the group'**
  String get enterGroupName;

  /// Label for archivedTitle
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedTitle;

  /// Label for toggleToIcons
  ///
  /// In en, this message translates to:
  /// **'Switch to icon view'**
  String get toggleToIcons;

  /// Label for toggleToCards
  ///
  /// In en, this message translates to:
  /// **'Switch to card view'**
  String get toggleToCards;

  /// Label for menu
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Label for editProfile
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// Label for editTip
  ///
  /// In en, this message translates to:
  /// **'Edit - double tap'**
  String get editTip;

  /// Label for exportPdf
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// Label for close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Label for newStory
  ///
  /// In en, this message translates to:
  /// **'New Story'**
  String get newStory;

  /// Label for noArchivedStories
  ///
  /// In en, this message translates to:
  /// **'No archived stories.'**
  String get noArchivedStories;

  /// Label for edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview - {title}'**
  String previewTitle(Object title);

  /// Label for archiveLabel
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveLabel;

  /// Message for storyArchived
  ///
  /// In en, this message translates to:
  /// **'Story archived'**
  String get storyArchived;

  /// Label for undo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Label for ungroup
  ///
  /// In en, this message translates to:
  /// **'Ungroup'**
  String get ungroup;

  /// No description provided for @noStoriesInGroup.
  ///
  /// In en, this message translates to:
  /// **'No stories in group {group}'**
  String noStoriesInGroup(Object group);

  /// No description provided for @exportPdfError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting PDF: {error}'**
  String exportPdfError(Object error);

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required!'**
  String get titleRequired;

  /// No description provided for @errorSavingStory.
  ///
  /// In en, this message translates to:
  /// **'Error saving story: {error}'**
  String errorSavingStory(Object error);

  /// No description provided for @exportPdfFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Title and description are required to export.'**
  String get exportPdfFieldsRequired;

  /// No description provided for @exportHistory.
  ///
  /// In en, this message translates to:
  /// **'Export Story'**
  String get exportHistory;

  /// No description provided for @exportHistoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save before exporting or just preview?'**
  String get exportHistoryPrompt;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @saveAndExport.
  ///
  /// In en, this message translates to:
  /// **'Save and export'**
  String get saveAndExport;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @errorLoadingFile.
  ///
  /// In en, this message translates to:
  /// **'Error loading file: {error}'**
  String errorLoadingFile(Object error);

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @discardStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard story?'**
  String get discardStoryTitle;

  /// No description provided for @unsavedStoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'You have a new unsaved story. Leave without saving?'**
  String get unsavedStoryPrompt;

  /// No description provided for @changeDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get changeDateTooltip;

  /// No description provided for @storyTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get storyTitleLabel;

  /// No description provided for @storyTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the title'**
  String get storyTitleHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Write your story...'**
  String get descriptionHint;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @photosSection.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosSection;

  /// No description provided for @audiosSection.
  ///
  /// In en, this message translates to:
  /// **'Audios'**
  String get audiosSection;

  /// No description provided for @videosSection.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videosSection;

  /// No description provided for @importTxtTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import .txt'**
  String get importTxtTooltip;

  /// No description provided for @expandTooltip.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expandTooltip;

  /// No description provided for @photoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoTooltip;

  /// No description provided for @videoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoTooltip;

  /// No description provided for @audioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioTooltip;

  /// No description provided for @emojiTooltip.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emojiTooltip;

  /// No description provided for @editDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get editDescription;

  /// No description provided for @editStory.
  ///
  /// In en, this message translates to:
  /// **'Edit Story'**
  String get editStory;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesPrompt.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leave without saving?'**
  String get discardChangesPrompt;

  /// No description provided for @archivedStateLabel.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedStateLabel;

  /// No description provided for @archiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide from home screen'**
  String get archiveSubtitle;
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
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
