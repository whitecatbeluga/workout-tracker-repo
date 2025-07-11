import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/auth_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/auth_service.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/password_field.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/text_field.dart';
import 'package:workout_tracker_repo/routes/profile/profile.dart';
import 'package:workout_tracker_repo/validations/register/register_validation.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final user = authService.value.getCurrentUser();
  final authrepo = AuthRepositoryImpl(AuthService());
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<UserAccount>? _accountSubscription;
  final _isUploading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isLoadingDetails = ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingPassword = ValueNotifier(false);
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void dispose() {
    _accountSubscription?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _accountSubscription = getUserAccount(user!.uid).listen((account) {
      if (mounted) {
        setState(() {
          _usernameController.text = account.username ?? '';
          _emailController.text = account.email ?? '';
        });
      }
    });
  }

  void _showAvatarDialog(UserAccount? profile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar Display
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF9ACBD0),
                          radius: 80,
                          backgroundImage: _getAvatarImage(profile),
                          child: _getAvatarChild(profile),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Take Photo Button
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await _takePhoto();
                                    setDialogState(() {});
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  iconSize: 30,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.blue.withAlpha(
                                      (0.1 * 255).round(),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Camera',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            // Choose from Gallery Button
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await _chooseFromGallery();
                                    setDialogState(() {});
                                  },
                                  icon: const Icon(Icons.photo_library),
                                  iconSize: 30,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.green.withAlpha(
                                      (0.1 * 255).round(),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Gallery',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            if (_hasImage(profile))
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _removePhoto();
                                      setDialogState(() {});
                                    },
                                    icon: const Icon(Icons.delete),
                                    iconSize: 30,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red.withAlpha(
                                        (0.1 * 255).round(),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Remove',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (_selectedImage != null) ...[
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await _saveNewAvatar(_selectedImage!.path);
                                  },
                                  icon: const Icon(Icons.save, size: 18),
                                  label: const Text('Save Avatar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF006A71),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  // Close Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper methods for avatar display
  ImageProvider? _getAvatarImage(UserAccount? profile) {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    if (profile != null &&
        profile.accountPicture != null &&
        profile.accountPicture!.isNotEmpty) {
      return NetworkImage(profile.accountPicture!);
    }
    return null;
  }

  Widget? _getAvatarChild(UserAccount? profile) {
    if (_selectedImage != null) {
      return null;
    }
    if (profile == null ||
        profile.accountPicture == null ||
        profile.accountPicture!.isEmpty) {
      return Text(
        profile?.username!.isNotEmpty == true
            ? profile!.username![0].toUpperCase()
            : '?',
        style: const TextStyle(fontSize: 40, color: Color(0xFF006A71)),
      );
    }
    return null;
  }

  bool _hasImage(UserAccount? profile) {
    return _selectedImage != null ||
        (profile != null &&
            profile.accountPicture != null &&
            profile.accountPicture!.isNotEmpty);
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _chooseFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePhoto() async {
    _isUploading.value = true;
    setState(() {
      _selectedImage = null;
    });
    await authrepo.removeUserAvatar(user!.uid).then((_) {
      if (mounted) {
        _isUploading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo removed!'),
            backgroundColor: Color(0xFF505050),
          ),
        );
      }
    });
  }

  Future<void> _saveNewAvatar(String? imagePath) async {
    _isUploading.value = true;
    try {
      if (imagePath != null) {
        // Update user profile
        await authrepo.updateUserAvatar(user!.uid, _selectedImage!);

        // Refresh user profile data

        // Clear selected image
        setState(() {
          _selectedImage = null;
        });

        if (mounted) {
          _isUploading.value = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Avatar updated successfully!'),
              backgroundColor: Color(0xFF48A6A7),
            ),
          );
        }
      } else {
        // Remove avatar case
        // await removeUserAvatar();
        // await refreshUserProfile();

        if (mounted) {
          _isUploading.value = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avatar removed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _isUploading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating avatar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Stream<UserAccount> getUserAccount(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map(
          (doc) => UserAccount(
            // password: doc.data()?['password'],
            email: doc.data()?['email'],
            accountPicture: doc.data()?['account_picture'],
            username: doc.data()?['user_name'],
          ),
        );
  }

  Future<void> updateUserEmailAndUsername({
    String? newEmail,
    String? newUsername,
    VoidCallback? onFinished,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null || user.email == null) {
      onFinished?.call();
      return;
    }

    try {
      if (newUsername != null && newUsername.isNotEmpty) {
        await firestore.collection('users').doc(user.uid).update({
          'user_name': newUsername,
          if (newEmail != null) 'email': newEmail,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username updated successfully!'),
              backgroundColor: Color(0xFF48A6A7),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth Error: ${e.code} - ${e.message}");
    } catch (e) {
      print("General error: $e");
    } finally {
      onFinished?.call();
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully!'),
              backgroundColor: Color(0xFF48A6A7),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth Error: ${e.code} - ${e.message}");
      if (e.code == 'invalid-credential') {
        print("Incorrect password used for reauthentication.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Incorrect password',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              backgroundColor: Color(0xFFED1010),
            ),
          );
        }
      } else if (e.code == 'requires-recent-login') {
        print("Reauthentication required again.");
      }
    } catch (e) {
      print("General error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Settings'),
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
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: _isUploading,
        builder: (context, value, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 29,
                      children: [
                        Center(
                          child: StreamBuilder(
                            stream: getUserAccount(user!.uid),
                            builder: (context, res) {
                              if (res.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              }

                              if (res.hasError) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 60,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Error: ${res.error}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              UserAccount account = res.data!;

                              return GestureDetector(
                                onTap: () => _showAvatarDialog(account),
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color(0xFF9ACBD0),
                                      radius: 45,
                                      backgroundImage:
                                          (account.accountPicture != null &&
                                              account
                                                  .accountPicture!
                                                  .isNotEmpty)
                                          ? NetworkImage(
                                              account.accountPicture!,
                                            )
                                          : null,
                                      child:
                                          (account.accountPicture == null ||
                                              account.accountPicture!.isEmpty)
                                          ? Text(
                                              account.accountPicture == "" ||
                                                      account.accountPicture ==
                                                          null
                                                  ? account.username![0]
                                                        .toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontSize: 40,
                                                color: Color(0xFF006A71),
                                              ),
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: _selectedImage != null
                                              ? Colors.orange
                                              : Color(0xFF006A71),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          _selectedImage != null
                                              ? Icons.pending
                                              : Icons.edit,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const Text(
                          'Update Username',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        Column(
                          spacing: 20,
                          children: [
                            InputField(
                              controller: _usernameController,
                              label: 'Username',
                              prefixIcon: Icons.person,
                              validator: FormValidators.validateUsername,
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                              enableLiveValidation: true,
                            ),
                            InputField(
                              disabled: true,
                              controller: _emailController,
                              label: 'Email Address',
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: FormValidators.validateEmail,
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                              enableLiveValidation: true,
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: _isLoadingDetails,
                              builder: (context, isLoading, child) {
                                return isLoading
                                    ? CircularProgressIndicator()
                                    : Button(
                                        label: 'Save Details',
                                        onPressed: () async {
                                          if (_usernameController
                                                  .text
                                                  .isNotEmpty &&
                                              _emailController
                                                  .text
                                                  .isNotEmpty) {
                                            _isLoadingDetails.value = true;
                                            try {
                                              await updateUserEmailAndUsername(
                                                newEmail: _emailController.text,
                                                newUsername:
                                                    _usernameController.text,
                                              );
                                            } finally {
                                              _isLoadingDetails.value = false;
                                            }
                                          }
                                        },
                                        fullWidth: true,
                                        height: 45,
                                      );
                              },
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Update Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                            Form(
                              key: _formKey,
                              child: Column(
                                spacing: 20,
                                children: [
                                  PasswordField(
                                    controller: _oldPasswordController,
                                    label: 'Current Password',
                                    validator: FormValidators.validatePassword,
                                    autoValidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  PasswordField(
                                    controller: _passwordController,
                                    label: 'New Password',
                                    validator: FormValidators.validatePassword,
                                    autoValidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  PasswordField(
                                    controller: _confirmPasswordController,
                                    label: 'Confirm New Password',
                                    validator: (value) =>
                                        FormValidators.validateConfirmPassword(
                                          value,
                                          _passwordController.text,
                                        ),
                                    autoValidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  ValueListenableBuilder<bool>(
                                    valueListenable: _isLoadingPassword,
                                    builder: (context, isLoading, child) {
                                      return isLoading
                                          ? CircularProgressIndicator()
                                          : Button(
                                              label: 'Save Password',
                                              onPressed: () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  _isLoadingPassword.value =
                                                      true;

                                                  try {
                                                    await updatePassword(
                                                      currentPassword:
                                                          _oldPasswordController
                                                              .text,
                                                      newPassword:
                                                          _passwordController
                                                              .text,
                                                    );
                                                  } finally {
                                                    _isLoadingPassword.value =
                                                        false;
                                                  }
                                                }
                                              },
                                              fullWidth: true,
                                              height: 45,
                                            );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isUploading.value)
                Container(
                  color: Colors.black.withAlpha(40),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class UserAccount {
  // final String? password;
  final String? username;
  final String? email;
  final String? accountPicture;
  String? firstName;
  String? lastName;

  UserAccount({
    this.email,
    this.accountPicture,
    this.username,
    this.firstName,
    this.lastName,
  });
}
