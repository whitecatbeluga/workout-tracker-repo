import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_tracker_repo/data/models/user_model.dart';
import 'package:workout_tracker_repo/data/repositories_impl/auth_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/auth_service.dart';


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
        weight: _weightController.text.trim(),
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
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_passwordController, 'Password', isPassword: true),
              _buildTextField(_userNameController, 'Username'),
              _buildTextField(_firstNameController, 'First Name'),
              _buildTextField(_lastNameController, 'Last Name'),
              _buildTextField(_genderController, 'Gender'),
              _buildTextField(_addressController, 'Address'),
              _buildTextField(_activityLevelController, 'Activity Level'),
              _buildTextField(_bmiController, 'BMI', isNumber: true),
              _buildTextField(_heightController, 'Height (cm)', isNumber: true),
              _buildTextField(_weightController, 'Weight (kg)', isNumber: false),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      birthDate == null
                          ? 'Select Birthdate'
                          : 'Birthdate: ${birthDate!.toLocal()}'.split(' ')[0],
                    ),
                  ),
                  TextButton(
                    onPressed: _pickBirthDate,
                    child: const Text('Pick Date'),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['cardio', 'strength', 'flexibility', 'balance'].map((type) {
                  final selected = selectedWorkoutTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: selected,
                    onSelected: (bool selectedValue) {
                      setState(() {
                        selected
                            ? selectedWorkoutTypes.remove(type)
                            : selectedWorkoutTypes.add(type);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('REGISTER'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_passwordVisible,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: isPassword ? const Icon(Icons.lock) : const Icon(Icons.person),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          )
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Enter $label';
          return null;
        },
      ),
    );
  }
}