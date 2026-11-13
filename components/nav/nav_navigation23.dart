import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../explore/explore_page.dart';
import '../profile/profile_page.dart';
import '../studio/effects/studio_page.dart';
import 'FloatingNavBar.dart';

/// Shared floating-nav-bar tab-switch behavior for every page that
/// shows the bar (Home, Explore, Profile, ...). Home is the hub:
/// switching to a different built tab always pops back to the root
/// route first, then pushes the target page — so the stack never
/// grows deeper than one page no matter how much lateral tab-hopping
/// happens, and the system/edge-swipe back gesture always lands on
/// Home.
void handleNavTabSelected(
  BuildContext context, {
  required NavTab tapped,
  required NavTab current,
  required User currentUser,
  required ValueChanged<User> onProfileUpdated,
}) {
  if (tapped == current) return;

  final navigator = Navigator.of(context);

  if (tapped == NavTab.home) {
    navigator.popUntil((route) => route.isFirst);
    return;
  }

  if (current != NavTab.home) {
    navigator.popUntil((route) => route.isFirst);
  }

  if (tapped == NavTab.explore) {
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ExplorePage(
          currentUser: currentUser,
          onProfileUpdated: onProfileUpdated,
        ),
      ),
    );
    return;
  }

  if (tapped == NavTab.studio) {
    navigator.push(
      MaterialPageRoute(
        builder: (_) => StudioPage(
          currentUser: currentUser,
          onProfileUpdated: onProfileUpdated,
        ),
      ),
    );
    return;
  }

  if (tapped == NavTab.profile) {
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          currentUser: currentUser,
          onProfileUpdated: onProfileUpdated,
        ),
      ),
    );
    return;
  }

  // Every NavTab value is handled above now, so this is unreachable —
  // kept only as a safety net if a future tab gets added here without
  // updating this function to match.
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text("${tapped.label} isn't available yet."),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}