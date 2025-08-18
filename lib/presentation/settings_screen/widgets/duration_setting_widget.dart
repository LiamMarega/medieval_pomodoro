import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class DurationSettingWidget extends ConsumerWidget {
  final String title;
  final int currentValue;
  final int minValue;
  final int maxValue;
  final int increment;
  final Function(int) onChanged;

  const DurationSettingWidget({
    super.key,
    required this.title,
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    required this.increment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.pressStart2p(
              fontSize: 12.sp,
              color: const Color(0xFFDAA520),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildControlButton(
                'assets/sprites/close_button.png',
                '-',
                currentValue > minValue
                    ? () => onChanged(currentValue - increment)
                    : null,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3728),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFFDAA520),
                    width: 2,
                  ),
                ),
                child: Text(
                  '$currentValue min',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 14.sp,
                    color: const Color(0xFFDAA520),
                  ),
                ),
              ),
              _buildControlButton(
                'assets/sprites/button_play.png',
                '+',
                currentValue < maxValue
                    ? () => onChanged(currentValue + increment)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      String spritePath, String label, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          color: onPressed != null
              ? const Color(0xFF4A3728)
              : const Color(0xFF4A3728).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onPressed != null
                ? const Color(0xFFDAA520)
                : const Color(0xFFDAA520).withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(spritePath),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  colorFilter: onPressed != null
                      ? null
                      : ColorFilter.mode(
                          Colors.grey.withValues(alpha: 0.5),
                          BlendMode.modulate,
                        ),
                ),
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 6.sp,
                color: onPressed != null
                    ? const Color(0xFFDAA520)
                    : const Color(0xFFDAA520).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
