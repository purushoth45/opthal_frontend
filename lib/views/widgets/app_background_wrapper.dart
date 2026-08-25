import 'package:flutter/material.dart';

class AppBackgroundWrapper extends StatelessWidget {
  final Widget child;
  final String? backgroundImagePath;
  final double backgroundImageOpacity;

  const AppBackgroundWrapper({
    super.key,
    required this.child,
    this.backgroundImagePath,
    this.backgroundImageOpacity = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ultra-rich, vivid gradient palette allowing 70% background color visibility
    const lightGradient = LinearGradient(
      colors: [
        Color(0xFF0F2942), // Deep Navy
        Color(0xFF1A73E8), // Vibrant Royal Blue
        Color(0xFF0EA5E9), // Vivid Sky Blue
        Color(0xFF38BDF8), // Cyan Highlight
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    const darkGradient = LinearGradient(
      colors: [
        Color(0xFF0A192F), // Midnight Deep Navy
        Color(0xFF0F172A), // Dark Slate
        Color(0xFF1E1B4B), // Vivid Indigo Slate
        Color(0xFF0369A1), // Deep Vibrant Blue
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Stack(
      children: [
        // Base Rich Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: isDark ? darkGradient : lightGradient,
          ),
        ),

        // Optional Background Image (e.g. Saveetha Campus with reduced opacity)
        if (backgroundImagePath != null)
          Positioned.fill(
            child: Opacity(
              opacity: backgroundImageOpacity,
              child: Image.asset(
                backgroundImagePath!,
                fit: BoxFit.cover,
              ),
            ),
          ),

        // Glowing Ambient Light Orb (Top Right)
        Positioned(
          top: -60,
          right: -50,
          width: 380,
          height: 380,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF38BDF8).withValues(alpha: 0.35),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFF60A5FA).withValues(alpha: 0.40),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),

        // Glowing Ambient Light Orb (Center Left)
        Positioned(
          top: 260,
          left: -80,
          width: 400,
          height: 400,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF818CF8).withValues(alpha: 0.25),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFF818CF8).withValues(alpha: 0.30),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),

        // Child Screen Content
        child,
      ],
    );
  }
}
