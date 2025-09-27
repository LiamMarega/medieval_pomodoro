import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/pixel_frame.dart';

/// Widget de formulario para el onboarding
class OnboardingFormWidget extends StatefulWidget {
  final Function(String)? onNameSubmitted;

  const OnboardingFormWidget({
    super.key,
    this.onNameSubmitted,
  });

  @override
  State<OnboardingFormWidget> createState() => _OnboardingFormWidgetState();
}

class _OnboardingFormWidgetState extends State<OnboardingFormWidget> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PixelFrame(
      cornerSize: 16,
      edgeThickness: 4,
      padding: 30,
      borderStyle: MedievalBorderStyle.stone,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1B0A).withValues(alpha: 0.9),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3A2B1A).withValues(alpha: 0.9),
              const Color(0xFF1A0B0A).withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Cómo te llamas, valiente caballero?',
              style: GoogleFonts.pressStart2p(
                fontSize: 15.sp,
                color: const Color(0xFFDAA520),
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            _buildTextField(),
            SizedBox(height: 2.h),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: TextField(
        controller: _nameController,
        style: GoogleFonts.vt323(
          fontSize: 18.sp,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Escribe tu nombre...',
          hintStyle: GoogleFonts.vt323(
            fontSize: 16.sp,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: () {
        if (_nameController.text.isNotEmpty && widget.onNameSubmitted != null) {
          widget.onNameSubmitted!(_nameController.text);
        }
      },
      child: Container(
        width: 40.w,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3728),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF5A4738),
              const Color(0xFF3A2718),
            ],
          ),
        ),
        child: Center(
          child: Text(
            'CONFIRMAR',
            style: GoogleFonts.pressStart2p(
              fontSize: 10.sp,
              color: const Color(0xFFDAA520),
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
