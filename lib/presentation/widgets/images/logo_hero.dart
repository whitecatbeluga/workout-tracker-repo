import 'package:flutter/material.dart';

class HeroLogo extends StatelessWidget {
  const HeroLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(tag: "logo", child: Image.asset("assets/images/logo.png"));
  }
}
