import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormValidators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Email uniqueness validation (async)
  static Future<String?> validateEmailUniqueness(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return 'Email already exists';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    return null;
  }

  // First name validation
  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }

    if (value.length < 2) {
      return 'First name must be at least 2 characters long';
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'First name can only contain letters and spaces';
    }

    return null;
  }

  // Last name validation
  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }

    if (value.length < 2) {
      return 'Last name must be at least 2 characters long';
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Last name can only contain letters and spaces';
    }

    return null;
  }

  // Gender validation
  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your gender';
    }

    final validGenders = ['Male', 'Female', 'Other'];
    if (!validGenders.contains(value)) {
      return 'Please select a valid gender';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.length < 10) {
      return 'Please enter a complete address';
    }

    return null;
  }

  // Activity level validation
  static String? validateActivityLevel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your activity level';
    }

    final validLevels = ['Sedentary', 'Light', 'Moderate', 'Active', 'Fervid'];
    if (!validLevels.contains(value)) {
      return 'Please select a valid activity level';
    }

    return null;
  }

  static String? validateWorkoutTypes(List<String>? values) {
    if (values == null || values.isEmpty) {
      return 'Please select at least 1 workout type';
    }

    final validTypes = [
      "Cardio",
      "Flexibility",
      "Functional",
      "HIIT",
      "Mixed",
      "Rest",
      "Sports",
      "Strength",
    ];

    if (!values.any((element) => validTypes.contains(element))) {
      return 'Must contain at least 1 valid workout types';
    }
    return null;
  }

  // Height validation (in cm)
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }

    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid height';
    }

    if (height < 100) {
      return 'Height must be at least 100cm';
    }

    if (height > 250) {
      return 'Height must be at most 250cm';
    }

    return null;
  }

  // Weight validation (in kg)
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid weight';
    }

    if (weight < 30) {
      return 'Weight must be at least 30kg';
    }

    if (weight > 120) {
      return 'Weight must be at most 120kg';
    }

    return null;
  }

  // BMI validation (usually calculated, but if manually entered)
  static String? validateBMI(String? value) {
    if (value == null || value.isEmpty) {
      return null; // BMI might be calculated automatically
    }

    final bmi = double.tryParse(value);
    if (bmi == null) {
      return 'Please enter a valid BMI';
    }

    if (bmi < 10 || bmi > 50) {
      return 'BMI value seems invalid';
    }

    return null;
  }

  // Birth date validation (age must be at least 9 years old)
  static String? validateBirthDate(DateTime? birthDate) {
    if (birthDate == null) {
      return 'Birth date is required';
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year;
    final hasHadBirthdayThisYear =
        now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);

    final actualAge = hasHadBirthdayThisYear ? age : age - 1;

    if (actualAge < 9) {
      return 'Age must be at least 9 years old';
    }

    if (birthDate.isAfter(now)) {
      return 'Birth date cannot be in the future';
    }

    return null;
  }
}
