import 'package:flutter/material.dart';

import '../../models/user.dart';
import 'effects_page.dart';

/// Studio now opens directly into the camera. The camera owns the
/// primary creation flow; Editor is reached from its top-left action.
class StudioPage extends StatelessWidget {
  const StudioPage({super.key, required this.currentUser, required this.onProfileUpdated});

  final User currentUser;
  final ValueChanged<User> onProfileUpdated;

  @override
  Widget build(BuildContext context) => const EffectsPage();
}
