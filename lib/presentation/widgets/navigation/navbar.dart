import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/navbar_screen_provider.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> navList = [
    {"title": "Routine", "icon": Icons.pending_actions_rounded},
    {"title": "Discover", "icon": Icons.explore_rounded},
    {"title": "Profile", "icon": Icons.person},
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentScreenIndex,
      builder: (context, value, child) {
        return SafeArea(
          child: Container(
            height: 75,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF006A71), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(navList.length, (index) {
                final isActive = currentScreenIndex.value == index;

                return SizedBox(
                  width:
                      MediaQuery.of(context).size.width / navList.length - 16,
                  // fixed width per tab minus some margin
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (!isActive) currentScreenIndex.value = index;
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isActive ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            navList[index]["icon"],
                            size: 28,
                            color: isActive
                                ? const Color(0xFF006A71)
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: isActive
                              ? const SizedBox.shrink()
                              : Text(
                                  navList[index]["title"],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class FloatingNavbar extends StatelessWidget {
  const FloatingNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(bottom: 0, left: 0, right: 0, child: Navbar());
  }
}
