// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DayApp';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get deviceDefault => 'Device default';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get tryAgain => 'Try again';

  @override
  String get errorInitializingApp => 'Error initializing app';

  @override
  String get theme => 'Theme';

  @override
  String get pinUnlock => 'Unlock PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get enableBiometrics => 'Biometric login';

  @override
  String get information => 'Information';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Password';

  @override
  String get configurePin => 'Configure PIN';

  @override
  String get biometrics => 'Biometrics';

  @override
  String get backgroundLock => 'Background lock';

  @override
  String get statistics => 'Statistics';

  @override
  String get manageGroups => 'Manage groups';

  @override
  String get trash => 'Trash';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get createAccount => 'Create account';

  @override
  String get name => 'Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get needHelp => 'Need help?';

  @override
  String get currentPinLabel => 'Current PIN';

  @override
  String get newPinLabel => 'New PIN';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get enterCurrentPin => 'Enter current PIN';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get pinLengthError => 'PIN must be between 4 and 8 digits';

  @override
  String get pinsDoNotMatch => 'PINs do not match';

  @override
  String get pinIncorrect => 'Current PIN incorrect';

  @override
  String get pinChangedSuccess => 'PIN changed successfully!';

  @override
  String get pinConfiguredSuccess => 'PIN configured successfully!';

  @override
  String get informYourEmail => 'Enter your email.';

  @override
  String get invalidEmail => 'Enter a valid email.';

  @override
  String get emailNotFound => 'Email not found. Check and try again.';

  @override
  String codeSent(Object email) {
    return 'Code sent to $email! Check your inbox.';
  }

  @override
  String get codeMustBe6 => 'The code must be 6 digits.';

  @override
  String get codeVerified => 'Code verified! Set your new password.';

  @override
  String get codeInvalid => 'Invalid or expired code. Try again.';

  @override
  String get enterNewPassword => 'Enter the new password.';

  @override
  String get passwordResetSuccess => 'Password reset successfully! Log in with the new password.';

  @override
  String get errorResetPassword => 'Error resetting password. Try again.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get resendCodeSuccess => 'New code sent! Check your inbox.';

  @override
  String get resendCodeError => 'Error resending code. Try again.';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters.';

  @override
  String get sendCode => 'Send code';

  @override
  String get unlock => 'Unlock';

  @override
  String get fullName => 'Full name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get accessAccount => 'Access your account';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get signIn => 'Sign in';

  @override
  String get forgotPassword => 'Forgot my password';

  @override
  String get noAccountCreateHere => 'No account? Create one here.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get biometricsEnabledSuccess => 'Biometrics enabled successfully!';

  @override
  String get biometricLoginError => 'Error logging in with biometrics.';

  @override
  String get invalidCredentials => 'Invalid email or password.';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get profileUpdateError => 'Error updating profile. Try again.';

  @override
  String get unlockAppReason => 'Unlock the app to continue';

  @override
  String get fillEmailAndPassword => 'Fill in email and password';

  @override
  String get emailOrPasswordIncorrect => 'Email or password incorrect';

  @override
  String get noEmailRegistered => 'No email registered. Configure it in settings.';

  @override
  String checkEmailOrUseCode(Object email) {
    return 'Check your email at $email or use the displayed code';
  }

  @override
  String get errorGeneratingCode => 'Error generating code. Try again.';

  @override
  String get errorSendingCode => 'Error sending code. Try again.';

  @override
  String get recoverPinTitle => 'Recover PIN';

  @override
  String get enterRecoveryCodePrompt => 'Enter the code sent to your email:';

  @override
  String get recoveryCodeLabel => 'Recovery code (6 digits)';

  @override
  String get enterPasswordToContinue => 'Enter your password to continue';

  @override
  String get enterPinToContinue => 'Enter your PIN to continue';

  @override
  String get useBiometricsToContinue => 'Use your biometrics to continue';

  @override
  String get unlockTitle => 'Unlock the App';

  @override
  String get search => 'Search';

  @override
  String unsavedBackups(Object count) {
    return 'You have $count stories not backed up.';
  }

  @override
  String get backupRecommendation => 'We recommend backing up to avoid losing your data.';

  @override
  String get cancel => 'Cancel';

  @override
  String get performBackup => 'Backup now';

  @override
  String get deleteStoryTitle => 'Delete story';

  @override
  String get deleteStoryConfirm => 'Do you want to move this story to the trash?';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get movedToTrash => 'Story moved to trash';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get group => 'Group';

  @override
  String exportPdfError(Object error) {
    return 'Error exporting PDF: $error';
  }
}
