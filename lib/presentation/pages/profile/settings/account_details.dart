import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/auth_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/auth_service.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/datepicker.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/dropdown_field.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/text_field.dart';
import 'package:workout_tracker_repo/routes/profile/profile.dart';
import 'package:workout_tracker_repo/validations/register/register_validation.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  final user = authService.value.getCurrentUser();
  final profilerepo = AuthRepositoryImpl(AuthService());

  final formkey1 = GlobalKey<FormState>();
  final formkey2 = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _activityLevelController = TextEditingController();
  final _bmiController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  List<String> selectedWorkoutTypes = [];
  ValueNotifier<DateTime?> _birthDate = ValueNotifier<DateTime?>(null);
  final ValueNotifier<String> selectedTab = ValueNotifier('personal');
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final List<DropdownOption> genderOptions = [
    const DropdownOption(value: 'Male', label: 'Male', icon: Icons.male),
    const DropdownOption(value: 'Female', label: 'Female', icon: Icons.female),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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

  Future<void> handleSavePersonal() async {
    try {
      isLoading.value = true;

      if (formkey1.currentState!.validate()) {
        Map<String, dynamic> data = {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'gender': _genderController.text,
          'address': _addressController.text,
          'birthdate': _birthDate.value,
        };

        await profilerepo.updateUserDetails(user!.uid, data);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personal information updated successfully!'),
              backgroundColor: Color(0xFF9ACBD0),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in all the required fields.'),
              backgroundColor: Color(0xFFED1010),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleSaveHealth() async {
    try {
      isLoading.value = true;

      if (formkey2.currentState!.validate()) {
        Map<String, dynamic> data = {
          'activity_level': _activityLevelController.text,
          'workout_type': selectedWorkoutTypes,
        };

        await profilerepo.updateUserDetails(user!.uid, data);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Health information updated successfully!'),
              backgroundColor: Color(0xFF9ACBD0),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in all the required fields.'),
              backgroundColor: Color(0xFFED1010),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Account Details'),
        leading: IconButton(
          onPressed: Navigator.canPop(context)
              ? () => Navigator.pop(context)
              : () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    ProfileRoutes.settings,
                    (route) => false,
                  );
                },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            StreamBuilder(
              stream: profilerepo.getUserDetails(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                if (snapshot.hasData) {
                  // print(snapshot.data.toString());
                }

                final user = snapshot.data!;
                _firstNameController.text = user.firstName;
                _lastNameController.text = user.lastName;
                _genderController.text = user.gender;
                _addressController.text = user.address;
                _birthDate = ValueNotifier<DateTime?>(user.birthDate);
                _bmiController.text = user.bmi.toString();
                _heightController.text = user.height.toString();
                _weightController.text = user.weight.toString();
                _activityLevelController.text = user.activityLevel;
                selectedWorkoutTypes = List.from(user.workoutType);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 20,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: selectedTab,
                          builder: (context, tab, _) {
                            return ButtonIcon(
                              icon: Icons.person,
                              onPressed: () {
                                selectedTab.value = 'personal';
                              },
                              isPressed: selectedTab.value == 'personal',
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: selectedTab,
                          builder: (context, tab, _) {
                            return ButtonIcon(
                              icon: Icons.medical_information,
                              onPressed: () {
                                selectedTab.value = 'health';
                              },
                              isPressed: selectedTab.value == 'health',
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: selectedTab,
                      builder: (context, tab, _) {
                        return tab == 'personal'
                            ? _buildPersonalForm()
                            : _buildHealthForm();
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Form _buildPersonalForm() {
    return Form(
      key: formkey1,
      child: Column(
        spacing: 20,
        children: [
          Text('Personal Information', style: TextStyle(fontSize: 18)),
          InputField(
            controller: _firstNameController,
            label: 'First Name',
            prefixIcon: Icons.person,
            validator: FormValidators.validateFirstName,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
            onChanged: (value) => _firstNameController.text = value,
          ),
          InputField(
            controller: _lastNameController,
            label: 'Last Name',
            prefixIcon: Icons.person_outline,
            validator: FormValidators.validateLastName,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
            onChanged: (value) => _lastNameController.text = value,
          ),

          InputField(
            controller: _addressController,
            label: 'Address',
            prefixIcon: Icons.location_on,
            validator: FormValidators.validateAddress,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
            onChanged: (value) => _addressController.text = value,
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
              _genderController.text = values.isNotEmpty ? values.first : '';
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
            onDateSelected: (date) => _birthDate.value = date,
            selectedDate: _birthDate.value,
            validator: (value) =>
                FormValidators.validateBirthDate(_birthDate.value),
            autoValidateMode: AutovalidateMode.onUserInteraction,
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, _) {
              return Button(
                label: 'Save',
                isLoading: loading,
                onPressed: () {
                  handleSavePersonal();
                },
                fullWidth: true,
              );
            },
          ),

          Divider(),
        ],
      ),
    );
  }

  double _calculateBMI() {
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);
    double? bmi;

    if (height != null && weight != null && height > 0 && weight > 0) {
      setState(() {
        bmi = weight / (height * height);
        _bmiController.text = bmi!.toStringAsFixed(1);
      });
    } else {
      setState(() {
        _bmiController.text = '';
      });
    }

    return bmi ?? 0.0;
  }

  Form _buildHealthForm() {
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
    return Form(
      key: formkey2,
      child: Column(
        spacing: 20,
        children: [
          Text('Health Information', style: TextStyle(fontSize: 18)),
          InputField(
            disabled: true,
            controller: _heightController,
            label: 'Height',
            prefixIcon: Icons.height,
            keyboardType: TextInputType.number,
            validator: FormValidators.validateHeight,
            onChanged: (value) {
              _heightController.text = value;
              _calculateBMI();
            },
          ),

          InputField(
            disabled: true,
            controller: _weightController,
            label: 'Weight',
            prefixIcon: Icons.scale,
            keyboardType: TextInputType.number,
            validator: FormValidators.validateWeight,
            onChanged: (value) {
              _weightController.text = value;
              _calculateBMI();
            },
          ),

          InputField(
            disabled: true,
            controller: _bmiController,
            label: 'BMI',
            prefixIcon: Icons.monitor_weight,
            validator: FormValidators.validateBMI,
          ),

          CustomDropdownField(
            label: 'Activity Level',
            options: activityLevelOptions,
            prefixIcon: Icons.monitor_heart,
            isMultiSelect: false,
            selectedValues: _activityLevelController.text.isNotEmpty
                ? [_activityLevelController.text]
                : null,
            validator: FormValidators.validateActivityLevel,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            enableLiveValidation: true,
            onChanged: (values) {
              _activityLevelController.text = values.isNotEmpty
                  ? values.first
                  : '';
            },
          ),

          CustomDropdownField(
            selectedValues: selectedWorkoutTypes,
            label: 'Select Workout Types',
            options: workoutTypeOptions,
            prefixIcon: Icons.fitness_center,
            isMultiSelect: true,
            validator: (values) =>
                FormValidators.validateWorkoutTypes(selectedWorkoutTypes),
            autoValidateMode: AutovalidateMode.onUserInteraction,
            // enableLiveValidation: true,
            onChanged: (values) {
              selectedWorkoutTypes = values;
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, _) {
              return Button(
                label: 'Save',
                isLoading: loading,
                onPressed: () {
                  handleSaveHealth();
                },
                fullWidth: true,
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}

class ButtonIcon extends StatelessWidget {
  const ButtonIcon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isPressed = false,
  });

  final bool? isPressed;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 50,
        color: isPressed ?? false
            ? Color(0xFF9ACBD0)
            : const Color.fromARGB(255, 129, 129, 129),
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(
          isPressed ?? false ? Color(0xFF006A71) : Colors.grey,
        ),
      ),
    );
  }
}
