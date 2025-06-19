import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/measurement_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/measurement_service.dart';
import 'package:workout_tracker_repo/domain/entities/measurement.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';

class AddMeasurementPage extends StatefulWidget {
  const AddMeasurementPage({super.key});

  @override
  State<AddMeasurementPage> createState() => _AddMeasurementPageState();
}

class _AddMeasurementPageState extends State<AddMeasurementPage> {
  final user = authService.value.getCurrentUser();
  final measurementrepo = MeasurementRepositoryImpl(MeasurementService());
  final TextEditingController _weightcontroller = TextEditingController();
  final TextEditingController _heightcontroller = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _weightcontroller.dispose();
    _heightcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text('Log Measurement')],
        ),
        actions: [
          Button(
            label: 'Save',
            onPressed: () {
              _submit();
            },
            backgroundColor: Colors.white,
            textColor: Color(0xFF006A71),
            isLoading: isLoading,
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 24,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  'Measurements',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A6A6A),
                  ),
                ),
                InputWidget(
                  label: 'Weight',
                  placeholder: '56 kg',
                  textController: _weightcontroller,
                ),
                InputWidget(
                  label: 'Height',
                  placeholder: '88 cm',
                  textController: _heightcontroller,
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const Text(
                  'Progress Picture',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6A6A6A),
                  ),
                ),
                InputImage(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_heightcontroller.text.isEmpty || _weightcontroller.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter height and weight.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    bool success = false;

    try {
      await measurementrepo.addMeasurement(
        Measurement(
          userId: user!.uid,
          height: double.parse(_heightcontroller.text),
          weight: double.parse(_weightcontroller.text),
          date: DateTime.now(),
        ),
      );
      success = true;
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    // Only update UI if still mounted
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.of(context).pop();
    }
  }
}

class InputImage extends StatelessWidget {
  const InputImage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 182, 182, 182),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.photo_camera_outlined,
              size: 32,
              color: Color(0xFF006A71),
            ),
            SizedBox(height: 8),
            Text(
              'Add Picture',
              style: TextStyle(color: Color(0xFF006A71), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class InputWidget extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController textController;

  const InputWidget({
    super.key,
    required this.label,
    required this.placeholder,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color.fromARGB(255, 197, 197, 197)),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 16))),
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                border: InputBorder.none,
              ),
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }
}
