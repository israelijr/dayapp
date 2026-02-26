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
    Locale('es'),
    Locale('pt'),
    Locale('pt', 'BR'),
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
  /// **'Send code'**
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

  /// No description provided for @backupComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete Backup'**
  String get backupComplete;

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
  /// **'The complete backup includes: ...'**
  String get backupInfoDetails;

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
  String backupError(String message);

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
  String restoreError(String message);

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
  /// **'The backup was restored successfully! ...'**
  String get restoreSuccessContent;

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

  /// Subtitle do switch de arquivar
  ///
  /// In en, this message translates to:
  /// **'Hide from home screen'**
  String get archiveSubtitle;

  /// Label usado em switch que indica se a história está arquivada
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedStateLabel;

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

  /// Mensagem mostrada quando o título não foi fornecido
  ///
  /// In en, this message translates to:
  /// **'Title is required!'**
  String get titleRequired;

  /// Mensagem para erro genérico ao salvar história
  ///
  /// In en, this message translates to:
  /// **'Error saving story: {error}'**
  String errorSavingStory(Object error);

  /// Mensagem usada antes de exportar pdf quando título ou descrição faltam
  ///
  /// In en, this message translates to:
  /// **'Title and description are required to export.'**
  String get exportPdfFieldsRequired;

  /// Título do diálogo de exportação de história
  ///
  /// In en, this message translates to:
  /// **'Export Story'**
  String get exportHistory;

  /// Prompt do diálogo de exportação de história
  ///
  /// In en, this message translates to:
  /// **'Do you want to save before exporting or just preview?'**
  String get exportHistoryPrompt;

  /// Rótulo genérico para botão de preview
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Texto do botão para salvar e exportar
  ///
  /// In en, this message translates to:
  /// **'Save and export'**
  String get saveAndExport;

  /// Rótulo quando não há título
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// Mensagem de erro ao carregar arquivo externo
  ///
  /// In en, this message translates to:
  /// **'Error loading file: {error}'**
  String errorLoadingFile(Object error);

  /// Rótulo genérico de descartar
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Título do diálogo de descartar história
  ///
  /// In en, this message translates to:
  /// **'Discard story?'**
  String get discardStoryTitle;

  /// Prompt exibido quando há história não salva
  ///
  /// In en, this message translates to:
  /// **'You have a new unsaved story. Leave without saving?'**
  String get unsavedStoryPrompt;

  /// Tooltip para alterar data
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get changeDateTooltip;

  /// Label do campo título
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get storyTitleLabel;

  /// Hint do campo título
  ///
  /// In en, this message translates to:
  /// **'Enter the title'**
  String get storyTitleHint;

  /// Label para seção descrição
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// Hint para descrição
  ///
  /// In en, this message translates to:
  /// **'Write your story...'**
  String get descriptionHint;

  /// Rótulo para campo tags
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// Título da seção de fotos
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosSection;

  /// Título da seção de áudios
  ///
  /// In en, this message translates to:
  /// **'Audios'**
  String get audiosSection;

  /// Título da seção de vídeos
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videosSection;

  /// Tooltip para importar .txt
  ///
  /// In en, this message translates to:
  /// **'Import .txt'**
  String get importTxtTooltip;

  /// Tooltip para expandir editor
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expandTooltip;

  /// Tooltip para botão de foto
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoTooltip;

  /// Tooltip para botão de vídeo
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoTooltip;

  /// Tooltip para botão de áudio
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioTooltip;

  /// Tooltip para botão de emoji
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emojiTooltip;

  /// Título da tela de edição de descrição
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get editDescription;

  /// Título da tela de edição de história
  ///
  /// In en, this message translates to:
  /// **'Edit Story'**
  String get editStory;

  /// Título para diálogo de descartar alterações
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// Prompt de confirmação de descartar alterações não salvas
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leave without saving?'**
  String get discardChangesPrompt;
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
