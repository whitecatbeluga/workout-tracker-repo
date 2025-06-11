import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/dropdown_field.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/text_field.dart';
import 'package:workout_tracker_repo/presentation/widgets/stepper/stepper.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.white,
      ),
      body: CustomStepper(
        steps: [
          StepperStep(
            title: 'Account Information',
            content: _buildAccountStep(),
          ),
          StepperStep(
            title: 'Personal Information',
            content: _buildPersonalStep(),
            validator: () => _validatePersonalStep(),
          ),
          StepperStep(title: 'Health Information', content: _buildHealthStep()),
          StepperStep(title: 'Review Information', content: _buildReviewStep()),
        ],
        onStepChanged: (step) {
          print('Step changed to: $step');
        },
        onCompleted: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Stepper completed!')));
        },
      ),
    );
  }

  Widget _buildAccountStep() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader('Let\'s get you set up!')],
      ),
    );
  }

  Widget _buildPersonalStep() {
    final List<DropdownOption> genderOptions = [
      const DropdownOption(value: 'male', label: 'Male', icon: Icons.male),
      const DropdownOption(
        value: 'female',
        label: 'Female',
        icon: Icons.female,
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _firstNameController,
            label: 'First Name',
            icon: Icons.person,
          ),

          _buildTextField(
            controller: _lastNameController,
            label: 'Last Name',
            icon: Icons.person_outline,
          ),

          _buildTextField(
            controller: _addressController,
            label: 'Address',
            icon: Icons.location_on,
          ),

          _buildDropdownField(
            label: 'Select your favorite workout type',
            options: genderOptions,
            prefixIcon: Icons.fitness_center,
            isMultiSelect: false,
          ),

          _buildDatePicker(),
        ],
      ),
    );
  }

  Widget _buildHealthStep() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.health_and_safety, size: 80, color: Color(0xFF0D7377)),
          SizedBox(height: 16),
          Text(
            'Health Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'This step would contain health-related forms',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Your Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _buildReviewItem('First Name', _firstNameController.text),
          _buildReviewItem('Last Name', _lastNameController.text),
          _buildReviewItem('Address', _addressController.text),
          _buildReviewItem('Gender', _selectedGender ?? ''),
          _buildReviewItem(
            'Birthdate',
            _selectedDate?.toString().split(' ')[0] ?? '',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return InputField(controller: controller, label: label, prefixIcon: icon);
  }

  Widget _buildDropdownField({
    required String label,
    required List<DropdownOption> options,
    required IconData prefixIcon,
    required bool isMultiSelect,
    String? helperText,
  }) {
    return CustomDropdownField(
      label: label,
      options: options,
      prefixIcon: prefixIcon,
      isMultiSelect: isMultiSelect,
      helperText: helperText,
      onChanged: (values) => print(values),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Birthdate',
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0D7377)),
        ),
      ),
      controller: TextEditingController(
        text: _selectedDate != null
            ? _selectedDate.toString().split(' ')[0]
            : '',
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validatePersonalStep() {
    if (_firstNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your first name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    if (_lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your last name')),
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
