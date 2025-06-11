import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_tracker_repo/data/models/user_model.dart';
import 'package:workout_tracker_repo/data/repositories_impl/auth_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/auth_service.dart';
import 'package:workout_tracker_repo/presentation/widgets/badge/badge.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/datepicker.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/dropdown_field.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/password_field.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/text_field.dart';
import 'package:workout_tracker_repo/presentation/widgets/stepper/stepper.dart';
import 'package:workout_tracker_repo/validations/register/register_validation.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authRepo = AuthRepositoryImpl(AuthService());
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _activityLevelController = TextEditingController();
  final _bmiController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  List<String> selectedWorkoutTypes = [];
  DateTime? birthDate;
  bool _isLoading = false;
  bool _passwordVisible = false;

  // Calculate BMI
  double _calculateBMI() {
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);
    double? bmi;

    if (height != null && weight != null && height > 0 && weight > 0) {
      setState(() {
        bmi = (weight * 10000) / (height * height);
        _bmiController.text = bmi!.toStringAsFixed(1);
      });
    } else {
      setState(() {
        _bmiController.text = '';
      });
    }

    return bmi ?? 0.0;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || birthDate == null) return;

    setState(() => _isLoading = true);

    try {
      final user = UserModel(
        uid: '',
        email: _emailController.text.trim(),
        userName: _userNameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _genderController.text.trim(),
        address: _addressController.text.trim(),
        activityLevel: _activityLevelController.text.trim(),
        birthDate: birthDate!,
        bmi: double.parse(_bmiController.text.trim()),
        height: double.parse(_heightController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        workoutType: selectedWorkoutTypes,
      );

      await authRepo.signUp(user, _passwordController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        birthDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _activityLevelController.dispose();
    _bmiController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: CustomStepper(
          steps: [
            StepperStep(
              title: 'Account Information',
              content: _buildAccountStep(),
            ),
            StepperStep(
              title: 'Personal Information',
              content: _buildPersonalStep(),
            ),
            StepperStep(
              title: 'Health Information',
              content: _buildHealthStep(),
            ),
            StepperStep(
              title: 'Review Information',
              content: _buildReviewStep(),
            ),
          ],
          onCompleted: () async {
            // try {
            //   // Validate email uniqueness
            //   String? emailError = await FormValidators.validateEmailUniqueness(
            //     _emailController.text,
            //   );
            //
            //   if (emailError != null) {
            //     // Show error message
            //     if (mounted) {
            //       // Check if widget is still mounted
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text(emailError),
            //           backgroundColor: Colors.red,
            //         ),
            //       );
            //     }
            //     return;
            //   }
            //
            //   // Proceed with registration
            //   // _register();
            //
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(content: Text('Registered Successfully!')),
            //   );
            // } catch (e) {
            //   // Handle any unexpected errors
            //   if (mounted) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(
            //         content: Text('An error occurred. Please try again.'),
            //         backgroundColor: Colors.red,
            //       ),
            //     );
            //   }
            // }

            // Validate email uniqueness
            String? emailError = await FormValidators.validateEmailUniqueness(
              _emailController.text,
            );

            if (emailError != null) {
              // Email is not unique, show error
              setState(() {
                // Hide loading indicator if you added one
              });

              // Show error message (you can customize this based on your UI)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(emailError),
                  backgroundColor: Colors.red,
                ),
              );

              // Optionally, you can navigate back to the email step
              // setState(() {
              //   _currentStep = 0; // or whatever step contains the email field
              // });

              return; // Don't proceed with registration
            }

            // Email is unique, proceed with registration
            // await _register();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registered Successfully!')),
            );
          },
        ),
      ),
    );
  }

  // ElevatedButton(
  //   onPressed: _isLoading ? null : _register,
  //   child: _isLoading
  //       ? const CircularProgressIndicator(color: Colors.white)
  //       : const Text('REGISTER'),
  // ),

  Widget _buildAccountStep() {
    return Center(
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Let\'s get you set up!'),

          InputField(
            controller: _userNameController,
            label: 'Username',
            prefixIcon: Icons.person,
            validator: FormValidators.validateUsername,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
            onChanged: (value) =>
                setState(() => _userNameController.text = value),
          ),

          InputField(
            controller: _emailController,
            label: 'Email Address',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: FormValidators.validateEmail,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
            onChanged: (value) => setState(() => _emailController.text = value),
          ),

          PasswordField(
            controller: _passwordController,
            label: 'Password',
            validator: FormValidators.validatePassword,
            autoValidateMode: AutovalidateMode.onUserInteraction,
          ),

          PasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            validator: (value) => FormValidators.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
            autoValidateMode: AutovalidateMode.onUserInteraction,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalStep() {
    final List<DropdownOption> genderOptions = [
      const DropdownOption(value: 'Male', label: 'Male', icon: Icons.male),
      const DropdownOption(
        value: 'Female',
        label: 'Female',
        icon: Icons.female,
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Tell us more about yourself!"),

          InputField(
            controller: _firstNameController,
            label: 'First Name',
            prefixIcon: Icons.person,
            validator: FormValidators.validateFirstName,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
            onChanged: (value) =>
                setState(() => _firstNameController.text = value),
          ),

          InputField(
            controller: _lastNameController,
            label: 'Last Name',
            prefixIcon: Icons.person_outline,
            validator: FormValidators.validateLastName,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
            onChanged: (value) =>
                setState(() => _lastNameController.text = value),
          ),

          InputField(
            controller: _addressController,
            label: 'Address',
            prefixIcon: Icons.location_on,
            validator: FormValidators.validateAddress,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
            onChanged: (value) =>
                setState(() => _addressController.text = value),
          ),

          CustomDropdownField(
            label: 'Select Gender',
            options: genderOptions,
            prefixIcon: Icons.transgender,
            isMultiSelect: false,
            selectedValues: _genderController.text.isNotEmpty
                ? [_genderController.text]
                : null,
            onChanged: (values) {
              setState(() {
                _genderController.text = values.isNotEmpty ? values.first : '';
              });
            },
            validator: FormValidators.validateGender,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
          ),

          CustomDatePicker(
            label: 'Birthdate',
            config: DatePickerConfig(
              mode: CustomDatePickerMode.date,
              lastDate: DateTime.now(),
              primaryColor: Colors.blue,
              use24HourFormat: false,
            ),
            prefixIcon: Icons.calendar_month_outlined,
            onDateSelected: (date) => setState(() => birthDate = date),
            selectedDate: birthDate,
            validator: (value) => FormValidators.validateBirthDate(birthDate),
            autoValidateMode: AutovalidateMode.onUserInteraction,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStep() {
    final List<DropdownOption> activityLevelOptions = [
      const DropdownOption(
        label: "Fervid",
        value: "Fervid",
        description: "Always moving, training intensely every day",
      ),
      const DropdownOption(
        label: "Active",
        value: "Active",
        description: "Work out regularly and stay on your feet often",
      ),
      const DropdownOption(
        label: "Moderate",
        value: "Moderate",
        description: "Exercise a few times a week and stay fairly active",
      ),
      const DropdownOption(
        label: "Light",
        value: "Light",
        description: "Occasional exercise with a mostly relaxed lifestyle",
      ),
      const DropdownOption(
        label: "Sedentary",
        value: "Sedentary",
        description: "Little to no regular physical activity",
      ),
    ];

    final List<DropdownOption> workoutTypeOptions = [
      const DropdownOption(
        label: "Cardio",
        value: "Cardio",
        description: "Boost your heart rate with endurance-focused training",
      ),
      const DropdownOption(
        label: "Flexibility",
        value: "Flexibility",
        description: "Improve mobility with stretching and balance exercises",
      ),
      const DropdownOption(
        label: "Functional",
        value: "Functional",
        description: "Train movements that mimic everyday activities",
      ),
      const DropdownOption(
        label: "HIIT",
        value: "HIIT",
        description:
            "High-intensity bursts with short rest periods for fat-burning",
      ),
      const DropdownOption(
        label: "Mixed",
        value: "Mixed",
        description: "A balanced blend of strength, cardio, and mobility work",
      ),
      const DropdownOption(
        label: "Rest",
        value: "Rest",
        description: "Time to recover and let your body rebuild stronger",
      ),
      const DropdownOption(
        label: "Sports",
        value: "Sports",
        description: "Activity focused on specific sports or athletic skills",
      ),
      const DropdownOption(
        label: "Strength",
        value: "Strength",
        description: "Build muscle and power through resistance training",
      ),
    ];

    return Center(
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('What is your physical details?'),

          InputField(
            controller: _heightController,
            label: 'Height',
            prefixIcon: Icons.height,
            keyboardType: TextInputType.number,
            validator: FormValidators.validateHeight,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
            onChanged: (value) {
              setState(() => _heightController.text = value);
              _calculateBMI();
            },
          ),

          InputField(
            controller: _weightController,
            label: 'Weight',
            prefixIcon: Icons.scale,
            keyboardType: TextInputType.number,
            validator: FormValidators.validateWeight,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
            onChanged: (value) {
              setState(() => _weightController.text = value);
              _calculateBMI();
            },
          ),

          CustomDropdownField(
            label: 'Activity Level',
            options: activityLevelOptions,
            prefixIcon: Icons.monitor_heart,
            isMultiSelect: false,

            selectedValues: _activityLevelController.text.isNotEmpty
                ? [_activityLevelController.text]
                : null,
            onChanged: (values) {
              setState(() {
                _activityLevelController.text = values.isNotEmpty
                    ? values.first
                    : '';
              });
            },
          ),

          CustomDropdownField(
            selectedValues: selectedWorkoutTypes,
            label: 'Select Workout Types',
            options: workoutTypeOptions,
            prefixIcon: Icons.fitness_center,
            isMultiSelect: true,
            onChanged: (values) {
              setState(() {
                selectedWorkoutTypes = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    String formatDate(DateTime? date) {
      if (date == null) return '';

      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${months[date.month]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            'Almost done, ${_userNameController.text}! Review your Information below',
          ),

          _buildReviewItem(
            Icons.switch_account_rounded,
            'Username',
            _userNameController.text,
          ),

          _buildReviewItem(Icons.email, 'Email Address', _emailController.text),

          _buildReviewItem(
            Icons.account_circle_rounded,
            'Full Name',
            '${_firstNameController.text} ${_lastNameController.text}',
          ),
          _buildReviewItem(
            Icons.location_on,
            'Address',
            _addressController.text,
          ),
          _buildReviewItem(Icons.transgender, 'Gender', _genderController.text),
          _buildReviewItem(
            Icons.calendar_today,
            'Birthdate',
            formatDate(birthDate),
          ),

          _buildReviewItem(
            Icons.height,
            'Height',
            '${_heightController.text} cm',
          ),
          _buildReviewItem(
            Icons.scale,
            'Weight',
            '${_weightController.text} kg',
          ),

          _buildReviewItem(
            Icons.health_and_safety,
            'BMI',
            _bmiController.text,
            showBadge: true,
          ),

          _buildReviewItem(
            Icons.monitor_heart,
            'Activity Level',
            _activityLevelController.text,
          ),
          _buildReviewItem(
            Icons.fitness_center,
            'Workout Type',
            selectedWorkoutTypes.join(', '),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String label) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBMICalculate() {
    // Determine BMI category
    String category;
    Color categoryColor;

    double bmi = _calculateBMI();

    if (bmi < 18.5) {
      category = "Underweight";
      categoryColor = Colors.blue.shade800;
    } else if (bmi < 25) {
      category = "Normal weight";
      categoryColor = Colors.green.shade800;
    } else if (bmi < 30) {
      category = "Overweight";
      categoryColor = Colors.orange.shade800;
    } else {
      category = "Obese";
      categoryColor = Colors.red.shade800;
    }

    return BadgeWidget(label: category, color: categoryColor);
  }

  Widget _buildReviewItem(
    IconData icon,
    String label,
    String value, {
    bool showBadge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Color(0xFF6B7280), size: 20),
              Text('$label:', style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
          Row(
            spacing: 3,
            children: [
              Text(
                value.isEmpty ? 'Not provided' : value,
                style: TextStyle(
                  color: value.isEmpty ? Colors.grey : Color(0xFF323232),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showBadge) _buildBMICalculate(),
            ],
          ),
        ],
      ),
    );
  }
}
