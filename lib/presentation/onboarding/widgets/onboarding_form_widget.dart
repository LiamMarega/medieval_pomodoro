import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../generated/locale_keys.g.dart';
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
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {
      _isButtonEnabled = _nameController.text.trim().length >= 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PixelFrame(
      cornerSize: 16,
      edgeThickness: 4,
      padding: 20,
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          spacing: 10,
          children: [
            Text(
              LocaleKeys.onboarding_what_is_your_name_knight.tr(),
              style: GoogleFonts.pressStart2p(
                fontSize: 15.sp,
                color: const Color(0xFFDAA520),
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            _buildTextField(),
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
          hintText: LocaleKeys.onboarding_write_your_name.tr(),
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
      onTap: _isButtonEnabled
          ? () {
              if (widget.onNameSubmitted != null) {
                widget.onNameSubmitted!(_nameController.text.trim());
              }
            }
          : null,
      child: Container(
        width: 40.w,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: _isButtonEnabled
              ? const Color(0xFF4A3728)
              : const Color(0xFF2A1B0A),
          gradient: _isButtonEnabled
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF5A4738),
                    const Color(0xFF3A2718),
                  ],
                )
              : null,
        ),
        child: Center(
          child: Text(
            LocaleKeys.onboarding_confirm.tr(),
            style: GoogleFonts.pressStart2p(
              fontSize: 10.sp,
              color: _isButtonEnabled
                  ? const Color(0xFFDAA520)
                  : const Color(0xFF666666),
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
