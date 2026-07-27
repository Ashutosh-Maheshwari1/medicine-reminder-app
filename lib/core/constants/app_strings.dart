/// Centralized string constants for MediTrack AI
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'MediTrack AI';
  static const String tagline = 'Never miss a dose.';

  // Auth
  static const String login = 'Login';
  static const String signup = 'Create Account';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String rememberMe = 'Remember Me';
  static const String orContinueWith = 'Or continue with';
  static const String signInWithGoogle = 'Continue with Google';
  static const String noAccount = "Don't have an account?";
  static const String hasAccount = 'Already have an account?';
  static const String fullName = 'Full Name';
  static const String confirmPassword = 'Confirm Password';
  static const String logout = 'Logout';

  // Navigation
  static const String home = 'Home';
  static const String medicines = 'Medicines';
  static const String history = 'History';
  static const String profile = 'Profile';

  // Home
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';
  static const String goodNight = 'Good Night';
  static const String todaysMedicines = "Today's Medicines";
  static const String upcomingReminder = 'Upcoming Reminder';
  static const String todaysTimeline = "Today's Timeline";
  static const String quickStats = 'Quick Stats';
  static const String weeklyAdherence = 'Weekly Adherence';
  static const String completed = 'Completed';
  static const String taken = 'Taken';
  static const String missed = 'Missed';
  static const String upcoming = 'Upcoming';
  static const String skipped = 'Skipped';

  // Medicines
  static const String addMedicine = 'Add Medicine';
  static const String editMedicine = 'Edit Medicine';
  static const String medicineName = 'Medicine Name';
  static const String dosage = 'Dosage';
  static const String medicineType = 'Medicine Type';
  static const String frequency = 'Frequency';
  static const String reminderTimes = 'Reminder Times';
  static const String mealPreference = 'Meal Preference';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String enableReminder = 'Enable Reminder';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String pause = 'Pause';
  static const String resume = 'Resume';
  static const String search = 'Search medicines...';
  static const String noMedicines = 'No medicines found';
  static const String noMedicinesDesc = 'Start by adding your first medicine to track.';

  // Medicine Types
  static const String tablet = 'Tablet';
  static const String capsule = 'Capsule';
  static const String injection = 'Injection';
  static const String drops = 'Drops';
  static const String syrup = 'Syrup';
  static const String other = 'Other';

  // Frequency
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String custom = 'Custom';

  // Meal Preference
  static const String beforeMeal = 'Before Meal';
  static const String afterMeal = 'After Meal';
  static const String anytime = 'Anytime';

  // Notifications
  static const String notifTitle = '💊 Time to Take Medicine';
  static const String takenAction = 'Taken';
  static const String snoozeAction = 'Snooze 10 mins';
  static const String dismissAction = 'Dismiss';

  // History
  static const String history_ = 'History';
  static const String noHistory = 'No history yet';
  static const String noHistoryDesc = 'Your medicine intake history will appear here.';

  // Profile
  static const String settings = 'Settings';
  static const String notificationSettings = 'Notification Settings';
  static const String darkMode = 'Dark Mode';
  static const String language = 'Language';
  static const String privacyPolicy = 'Privacy Policy';
  static const String exportHistory = 'Export History PDF';
  static const String editProfile = 'Edit Profile';

  // Errors
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorWeakPassword = 'Password must be at least 6 characters.';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorEmptyField = 'This field cannot be empty.';

  // Success
  static const String medicineAdded = 'Medicine added successfully! 🎉';
  static const String medicineTaken = 'Great job! Medicine marked as taken 💪';
  static const String profileUpdated = 'Profile updated successfully!';
}
