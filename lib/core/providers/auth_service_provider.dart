// lib/core/providers/auth_service_provider.dart
import 'package:flutter/foundation.dart';
import 'package:workout_tracker_repo/data/services/auth_service.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());
