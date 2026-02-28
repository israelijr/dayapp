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
  String get defaultLabel => 'Default';

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
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get security => 'Security';

  @override
  String get themeAndScheme => 'Theme and Scheme';

  @override
  String get backup => 'Backup';

  @override
  String get automaticBackup => 'Automatic Backup';

  @override
  String get lastAutoBackup => 'Last automatic backup';

  @override
  String get backupOnLogout => 'Backup on logout';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get confirm => 'Confirm';

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
  String get backgroundLockDialogPrompt =>
      'How long should the app be locked after being in background?';

  @override
  String get backgroundLockTimeLabel => 'Time';

  @override
  String get backgroundLockDialogResult => 'Result:';

  @override
  String get backgroundLockSuggestions => 'Suggestions:';

  @override
  String get backgroundLockImmediateHint => '0 = immediate';

  @override
  String get statistics => 'Statistics';

  @override
  String get noStoriesYetTitle => 'No stories yet';

  @override
  String get noStoriesYetSubtitle =>
      'Start recording your days to see statistics';

  @override
  String get trends => 'Trends';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get activityByWeekday => 'Activity by weekday';

  @override
  String get streaksTitle => 'Streaks';

  @override
  String get longestStreakPrefix => 'Longest streak:';

  @override
  String get tableOfMoods => 'Mood table';

  @override
  String get moodCount => 'Mood count';

  @override
  String get topTags => 'Top tags';

  @override
  String get storiesLabel => 'Stories';

  @override
  String get activeDaysLabel => 'Active days';

  @override
  String get avgPerDayLabel => 'Avg/day';

  @override
  String get mediaLabel => 'Media';

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
  String get passwordResetSuccess =>
      'Password reset successfully! Log in with the new password.';

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
  String get sendCode => 'Send Code';

  @override
  String get unlock => 'Unlock';

  @override
  String get fullName => 'Full name';

  @override
  String get birthDate => 'Birth date';

  @override
  String get almostReady => 'almost ready...';

  @override
  String get optionalData => 'The fields below are optional';

  @override
  String get birthDateFormat => 'Birth date (DD/MM/YYYY)';

  @override
  String get invalidBirthDate => 'Invalid birth date (use DD/MM/YYYY)';

  @override
  String get userNotFound => 'User not found.';

  @override
  String get create => 'Create';

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
  String get noEmailRegistered =>
      'No email registered. Configure it in settings.';

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
  String get usePin => 'Use PIN';

  @override
  String get noStoriesHere => 'No stories to display here.';

  @override
  String get storiesGroupedOrArchived => 'They are either grouped or archived.';

  @override
  String get useBiometrics => 'Use Biometrics';

  @override
  String get unlockWithBiometrics => 'Unlock with Biometrics';

  @override
  String get useAccountPassword => 'Use account password';

  @override
  String get forgotPin => 'Forgot my PIN';

  @override
  String get unlockTitle => 'Unlock the App';

  @override
  String get search => 'Search';

  @override
  String unsavedBackups(Object count) {
    return 'You have $count stories not backed up.';
  }

  @override
  String get backupRecommendation =>
      'We recommend backing up to avoid losing your data.';

  @override
  String get cancel => 'Cancel';

  @override
  String get performBackup => 'Backup now';

  @override
  String get deleteStoryTitle => 'Delete story';

  @override
  String get deleteStoryConfirm =>
      'Do you want to move this story to the trash?';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get movedToTrash => 'Story moved to trash';

  @override
  String errorDeletingStory(Object error) {
    return 'Error deleting story: $error';
  }

  @override
  String get noRecordsThisDay => 'No records for this day';

  @override
  String get storyUngrouped => 'Story ungrouped';

  @override
  String get save => 'Save';

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String get groupDeletedSuccess => 'Group deleted successfully';

  @override
  String get noGroupsFound => 'No groups found';

  @override
  String get shareError => 'Could not share';

  @override
  String get cannotDeletePhoto => 'Cannot delete this photo';

  @override
  String get deletePhotoTitle => 'Delete photo';

  @override
  String get deletePhotoConfirm => 'Do you really want to delete this photo?';

  @override
  String get deleteGroupTitle => 'Delete Group';

  @override
  String get share => 'Share';

  @override
  String get home => 'Home';

  @override
  String get groups => 'Groups';

  @override
  String get record => 'record';

  @override
  String get records => 'records';

  @override
  String get filterText => 'Text';

  @override
  String get filterTag => 'Tag';

  @override
  String get filterEmoticon => 'Emoticon';

  @override
  String get searchHintTag => 'Type a tag...';

  @override
  String get searchHintText => 'Search in title or description...';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String get clear => 'Clear';

  @override
  String get tapToSelectEmoji => 'Tap to select an emoji:';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get recordVideoLabel => 'Record a video';

  @override
  String get recordAudioLabel => 'Record audio';

  @override
  String get continueLabel => 'Continue';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get laterLabel => 'Later';

  @override
  String get configureLabel => 'Configure';

  @override
  String get imageCopiedBase64 => 'Image copied to clipboard (base64)';

  @override
  String get newGroup => 'New Group';

  @override
  String get editGroup => 'Edit Group';

  @override
  String get chooseIcon => 'Choose icon';

  @override
  String groupDeleteWarning(Object count) {
    return 'This group has $count story(ies) linked. If deleted, those stories will return to the home screen (no group). Continue?';
  }

  @override
  String get unarchive => 'Unarchive';

  @override
  String get group => 'Group';

  @override
  String get selectGroup => 'Select Group';

  @override
  String get existingGroups => 'Existing Groups';

  @override
  String get createNewGroup => 'Create New Group';

  @override
  String get groupNameLabel => 'Group Name';

  @override
  String get createAndSelect => 'Create and Select';

  @override
  String get manageBackups => 'Manage Backup';

  @override
  String get createAndShareBackup => 'Create and Share Backup';

  @override
  String get restoreFromFile => 'Restore from File';

  @override
  String get backupNotAvailableWeb => 'Backup not available on web';

  @override
  String get backupNotAvailableDetail =>
      'The backup feature requires file system access, available only on Android, iOS and desktop versions.';

  @override
  String get backupInfoTitle => 'About Backup';

  @override
  String get backupInfoDetails =>
      'The complete backup includes:\n• Database (stories, texts, photos, audios)\n• Video files\n\nA ZIP file will be created and you can save it wherever you want:\n• OneDrive\n• Google Drive\n• Email\n• Any other location';

  @override
  String get backupComplete => 'Complete Backup';

  @override
  String get backupZipSubtitle => 'ZIP file with all your data';

  @override
  String get backupZipExplanation =>
      'Generates a ZIP file that you can save to OneDrive, Google Drive, email or any other location.';

  @override
  String get restoreSectionTitle => 'Restore Backup';

  @override
  String get restoreSectionDescription =>
      'Select a backup file (ZIP) previously created to restore all your data.';

  @override
  String get processing => 'Processing...';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get backupStarting => 'Starting backup...';

  @override
  String get backupCreatedSuccess =>
      'Backup file created! Use the share menu to save it.';

  @override
  String backupError(Object message) {
    return 'Error creating backup: $message';
  }

  @override
  String get restoreStarting => 'Starting restore...';

  @override
  String get restoreSuccess => 'Restore completed successfully!';

  @override
  String restoreError(Object message) {
    return 'Error restoring: $message';
  }

  @override
  String get restoreConfirmTitle => '⚠️ Confirm Restore';

  @override
  String get restoreConfirmContent =>
      'All current data will be replaced by the backup.\n\nThis action cannot be undone. Do you wish to continue?';

  @override
  String get restoreSuccessTitle => '✅ Restore Completed';

  @override
  String get restoreSuccessContent =>
      'The backup was restored successfully!\n\nAll your stories have been restored to the backup state.\n\nYou need to log in again to complete the process.';

  @override
  String get helpAboutTitle => 'About DayApp';

  @override
  String get helpAboutDescription =>
      'DayApp is a personal diary app that lets you record your stories, memories and thoughts in an organized and secure way.';

  @override
  String get helpNavigationTitle => 'Main Navigation';

  @override
  String get helpHomeItemDesc =>
      'View your stories as cards or list. Tap a story to view, long press for options.';

  @override
  String get helpGroupsNavDesc =>
      'Organize your stories into thematic groups. Create custom groups to categorize your memories.';

  @override
  String get helpSearchItemDesc =>
      'Quickly find stories by title, content or date.';

  @override
  String get helpCreatingTitle => 'Creating Stories';

  @override
  String get helpNewStoryDesc =>
      'Tap the floating (+) button to create a new story. Add title, rich text, images, videos and audios.';

  @override
  String get helpTextEditorTitle => 'Text Editor';

  @override
  String get helpTextEditorDesc =>
      'Use rich formatting: bold, italic, lists, links and more.';

  @override
  String get helpMediaDesc =>
      'Add photos from the gallery or camera, record videos and audios directly in the app.';

  @override
  String get helpGroupsAssocDesc =>
      'Associate each story with one or more groups for better organization.';

  @override
  String get helpCalendarDesc =>
      'View your stories organized by date. Tap a date to see all stories for that day.';

  @override
  String get helpCreateGroupTitle => 'Create Group';

  @override
  String get helpCreateGroupDesc =>
      'Go to \"Manage Groups\" in the side menu to create new groups with custom colors.';

  @override
  String get helpEditGroupTitle => 'Edit Group';

  @override
  String get helpEditGroupDesc =>
      'Long press a group to edit its name, color or delete it.';

  @override
  String get helpBackupSecurityTitle => 'Backup & Security';

  @override
  String get helpAutomaticBackupTitle => 'Automatic Backup';

  @override
  String get helpAutomaticBackupDesc =>
      'Configure automatic backup on logout in Settings. A backup will be created and you can choose where to save it.';

  @override
  String get helpManualBackupTitle => 'Manual Backup';

  @override
  String get helpManualBackupDesc =>
      'Go to \"Manage Backup\" in Settings to create a full backup with all media.';

  @override
  String get helpRestoreTitle => 'Restore';

  @override
  String get helpRestoreDesc =>
      'Use \"Restore from File\" to recover data from a previous backup.';

  @override
  String get helpPinSecurityTitle => 'Security PIN';

  @override
  String get helpPinSecurityDesc =>
      'Set a 4- to 8-digit PIN to protect app access.';

  @override
  String get helpBiometricsDesc =>
      'Use fingerprint or facial recognition to unlock the app quickly, if available on your device.';

  @override
  String get helpPasswordUnlockTitle => 'Password Unlock';

  @override
  String get helpPasswordUnlockDesc =>
      'In addition to PIN and biometrics, you can unlock the app using your account password. Useful if you forget the PIN or biometrics fail.';

  @override
  String get helpBackgroundLockDesc =>
      'When the app is minimized or you switch to another app, it locks automatically after the configured time. You can set the time freely in settings (seconds, minutes or hours).';

  @override
  String get helpLockExceptionsTitle => 'Lock Exceptions';

  @override
  String get helpLockExceptionsDesc =>
      'The app does not lock when you use internal features that open other apps—such as picking photos from the gallery, recording videos, choosing backup location or sharing stories.';

  @override
  String get helpPinRecoveryTitle => 'PIN Recovery';

  @override
  String get helpPinRecoveryDesc =>
      'Forgot your PIN? Use the \"Forgot my PIN\" option on the lock screen. A recovery code will be sent to the registered email.';

  @override
  String get helpThemeDesc => 'Toggle between light, dark or automatic theme.';

  @override
  String get helpNotificationsSettingsDesc =>
      'Set reminders to write in the diary.';

  @override
  String get helpBackgroundLockSettingsDesc =>
      'Define how long the app can stay in the background before being locked. You may use values in seconds, minutes or hours, with full freedom.';

  @override
  String get helpBackupSettingTitle => 'Backup';

  @override
  String get helpBackupSettingDesc => 'Manage backup and restore settings.';

  @override
  String get helpTrashDesc =>
      'Deleted stories stay in the trash for 30 days. Access \"Trash\" in the side menu to recover or permanently delete.';

  @override
  String get helpStatisticsDesc =>
      'View statistics about your diary usage: number of stories, words written, top groups, etc.';

  @override
  String get helpTipsTitle => 'Usage Tips';

  @override
  String get helpOrganizationTipTitle => 'Organization';

  @override
  String get helpOrganizationTipDesc =>
      'Use groups to categorize your stories by themes, feelings or life periods.';

  @override
  String get helpSearchTipTitle => 'Search';

  @override
  String get helpSearchTipDesc =>
      'Use the search function to quickly find old stories.';

  @override
  String get helpBackupTipTitle => 'Regular Backup';

  @override
  String get helpBackupTipDesc =>
      'Back up regularly, especially before updates or device changes.';

  @override
  String get helpPrivacyTipTitle => 'Privacy';

  @override
  String get helpPrivacyTipDesc =>
      'Your stories are stored locally and encrypted. Set a PIN for additional protection.';

  @override
  String get helpSupportTitle => 'Support';

  @override
  String get helpSupportDesc =>
      'For questions or issues, contact us via support email or check app updates.';

  @override
  String get errorCreateAccount => 'Error creating account. Please try again.';

  @override
  String get errorShare => 'Error sharing';

  @override
  String errorPlayAudio(Object message) {
    return 'Error playing audio: $message';
  }

  @override
  String errorSelectVideos(Object message) {
    return 'Error selecting videos: $message';
  }

  @override
  String errorSelectFile(Object message) {
    return 'Error selecting file: $message';
  }

  @override
  String errorRecordVideo(Object message) {
    return 'Error recording video: $message';
  }

  @override
  String errorStartRecording(Object message) {
    return 'Error starting recording: $message';
  }

  @override
  String errorPauseRecording(Object message) {
    return 'Error pausing recording: $message';
  }

  @override
  String errorResumeRecording(Object message) {
    return 'Error resuming recording: $message';
  }

  @override
  String errorStopRecording(Object message) {
    return 'Error stopping recording: $message';
  }

  @override
  String errorSelectAudios(Object message) {
    return 'Error selecting audios: $message';
  }

  @override
  String get errorLoadVideo => 'Error loading video';

  @override
  String get errorSelectImage => 'Error selecting image';

  @override
  String get imagePickerTitleMultiple => 'Add Photos';

  @override
  String get imagePickerTitleSingle => 'Add Photo';

  @override
  String get imagePickerChooseOptionMultiple =>
      'Choose an option (gallery allows multiple photos):';

  @override
  String get imagePickerChooseOptionSingle => 'Choose an option:';

  @override
  String get imagePickerGalleryMultiple => 'Select from gallery';

  @override
  String get imagePickerGallerySingle => 'Pick from gallery';

  @override
  String get imagePickerTakePhoto => 'Take a photo';

  @override
  String get audioPickerTitleMultiple => 'Add Audios';

  @override
  String get audioPickerTitleSingle => 'Add Audio';

  @override
  String get audioPickerChooseOptionMultiple =>
      'Choose an option (files allow multiple audios):';

  @override
  String get audioPickerChooseOptionSingle => 'Choose an option:';

  @override
  String get audioPickerSelectFilesMultiple => 'Select audio files';

  @override
  String get audioPickerSelectFilesSingle => 'Pick audio file';

  @override
  String get audioPickerRecord => 'Record audio';

  @override
  String get videoPickerTitleMultiple => 'Add Videos';

  @override
  String get videoPickerTitleSingle => 'Add Video';

  @override
  String get videoPickerChooseOptionMultiple =>
      'Choose an option (files allow multiple videos):';

  @override
  String get videoPickerChooseOptionSingle => 'Choose an option:';

  @override
  String get videoPickerSelectFilesMultiple => 'Select video files';

  @override
  String get videoPickerSelectFilesSingle => 'Pick video file';

  @override
  String get videoPickerRecord => 'Record video';

  @override
  String get successVideoAdded => 'Video added successfully!';

  @override
  String successVideosAdded(Object count) {
    return '$count videos added successfully!';
  }

  @override
  String get startRecording => 'Start recording';

  @override
  String get recordingPaused => 'Recording paused';

  @override
  String get recording => 'Recording...';

  @override
  String get readyToRecord => 'Ready to record';

  @override
  String get notificationDialogTitle => 'Schedule Notification';

  @override
  String get notificationDialogPrompt =>
      'When would you like to be notified about this entry?';

  @override
  String get emailAlreadyRegistered => 'E-mail already registered.';

  @override
  String get successNotificationScheduled =>
      'Notification scheduled successfully';

  @override
  String notificationReminderTitle(Object title) {
    return 'Reminder: $title';
  }

  @override
  String get successImageAdded => 'Image added successfully!';

  @override
  String successImagesAdded(Object count) {
    return '$count images added successfully!';
  }

  @override
  String errorSearch(Object message) {
    return 'Error during search: $message';
  }

  @override
  String get successStoryRestored => 'Story restored successfully';

  @override
  String get successStoryDeletedPermanently => 'Story permanently deleted';

  @override
  String get trashAlreadyEmpty => 'Trash is already empty';

  @override
  String get successVideoRecorded => 'Video recorded successfully!';

  @override
  String get permissionMicrophoneDenied => 'Microphone permission not granted';

  @override
  String errorSelectImages(Object message) {
    return 'Error selecting images: $message';
  }

  @override
  String get successPhotoCaptured => 'Photo captured successfully!';

  @override
  String get restoreStoriesTitle => 'Restore stories';

  @override
  String restoreStoriesConfirm(Object count) {
    return 'Do you want to restore $count selected story(ies)?';
  }

  @override
  String get restoreLabel => 'Restore';

  @override
  String get permanentlyDeleteTitle => 'Permanently delete';

  @override
  String get permanentlyDeleteConfirm =>
      'This action cannot be undone. Do you really want to permanently delete this story?';

  @override
  String get permanentlyDeleteLabel => 'Permanently delete';

  @override
  String deleteGroupConfirm(Object name) {
    return 'Do you want to remove the group \"$name\" from your stories?';
  }

  @override
  String get recoverPinDescription =>
      'We will send a recovery code to your registered email.';

  @override
  String get emptyTrashTitle => 'Empty trash';

  @override
  String emptyTrashConfirm(Object count) {
    return 'Do you want to permanently delete all $count story(ies) in the trash? This action cannot be undone.';
  }

  @override
  String get emptyTrashLabel => 'Empty trash';

  @override
  String errorTakePhoto(Object message) {
    return 'Error taking photo: $message';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get entryNotifications => 'Entry notifications';

  @override
  String get entryNotificationsInfo =>
      'Entries with a date at least 2 hours ahead may have scheduled notifications.';

  @override
  String get defaultAdvanceTitle => 'Default advance';

  @override
  String get notificationAdvanceTitle => 'Notification advance';

  @override
  String get notificationAdvancePrompt =>
      'How much notice would you like before being notified?';

  @override
  String get notificationAdvanceDefault => 'Default advance';

  @override
  String get manageCompleteBackup => 'Manage full backup';

  @override
  String get backupWithVideosZip => 'Backup with videos in ZIP file';

  @override
  String get backupOnLogoutDescription =>
      'Backup will be created when you log out';

  @override
  String get automaticBackupInfo =>
      'When you log out, a backup will be created and you can choose where to save it (local folder, Google Drive, etc).';

  @override
  String get biometricsNotAvailable => 'Not available on this device';

  @override
  String get biometricsDisabled => 'Biometrics disabled';

  @override
  String get biometricConfiguredInfo =>
      'Biometrics is configured. You can log in using your fingerprint or face recognition.';

  @override
  String get biometricAuthFailed => 'Biometric authentication failed';

  @override
  String get confirmIdentityToEnableBiometrics =>
      'Confirm your identity to enable biometrics';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get groupExists => 'Group already exists';

  @override
  String get enterGroupName => 'Enter a name for the group';

  @override
  String get archivedTitle => 'Archived';

  @override
  String get toggleToIcons => 'Switch to icon view';

  @override
  String get toggleToCards => 'Switch to card view';

  @override
  String get menu => 'Menu';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get editTip => 'Edit - double tap';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get close => 'Close';

  @override
  String get newStory => 'New Story';

  @override
  String get noArchivedStories => 'No archived stories.';

  @override
  String get edit => 'Edit';

  @override
  String previewTitle(Object title) {
    return 'Preview - $title';
  }

  @override
  String get archiveLabel => 'Archive';

  @override
  String get storyArchived => 'Story archived';

  @override
  String get undo => 'Undo';

  @override
  String get ungroup => 'Ungroup';

  @override
  String noStoriesInGroup(Object group) {
    return 'No stories in group $group';
  }

  @override
  String exportPdfError(Object error) {
    return 'Error exporting PDF: $error';
  }

  @override
  String get titleRequired => 'Title is required!';

  @override
  String errorSavingStory(Object error) {
    return 'Error saving story: $error';
  }

  @override
  String get exportPdfFieldsRequired =>
      'Title and description are required to export.';

  @override
  String get exportHistory => 'Export Story';

  @override
  String get exportHistoryPrompt =>
      'Do you want to save before exporting or just preview?';

  @override
  String get preview => 'Preview';

  @override
  String get saveAndExport => 'Save and export';

  @override
  String get untitled => 'Untitled';

  @override
  String errorLoadingFile(Object error) {
    return 'Error loading file: $error';
  }

  @override
  String get discard => 'Discard';

  @override
  String get discardStoryTitle => 'Discard story?';

  @override
  String get unsavedStoryPrompt =>
      'You have a new unsaved story. Leave without saving?';

  @override
  String get changeDateTooltip => 'Change date';

  @override
  String get storyTitleLabel => 'Title';

  @override
  String get storyTitleHint => 'Enter the title';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'Write your story...';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get photosSection => 'Photos';

  @override
  String get audiosSection => 'Audios';

  @override
  String get videosSection => 'Videos';

  @override
  String get importTxtTooltip => 'Import .txt';

  @override
  String get expandTooltip => 'Expand';

  @override
  String get photoTooltip => 'Photo';

  @override
  String get videoTooltip => 'Video';

  @override
  String get audioTooltip => 'Audio';

  @override
  String get emojiTooltip => 'Emoji';

  @override
  String get editDescription => 'Edit Description';

  @override
  String get editStory => 'Edit Story';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesPrompt =>
      'You have unsaved changes. Leave without saving?';

  @override
  String get archivedStateLabel => 'Archived';

  @override
  String get archiveSubtitle => 'Hide from home screen';
}
