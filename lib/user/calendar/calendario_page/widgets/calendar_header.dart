import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Primary-colored banner shown at the top of the calendar page's initial
/// ("Start") state asking the user how they feel today.
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.message,
    this.asset = 'assets/images/ChicoRecurso.png',
    this.showImage = true,
    this.textAlign,
  });

  final String message;
  final String asset;
  final bool showImage;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final labelSmall = theme.labelSmall;
    return Container(
      width: double.infinity,
      height: 150.0,
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Stack(
                alignment: const AlignmentDirectional(1.0, 0.0),
                children: [
                  if (showImage)
                    Align(
                      alignment: const AlignmentDirectional(-0.8, -0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          asset,
                          fit: BoxFit.contain,
                          width: 200.0,
                          height: 200.0,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                  Align(
                    alignment: const AlignmentDirectional(0.76, -0.03),
                    child: Text(
                      message,
                      textAlign: textAlign,
                      style: labelSmall.override(
                        font: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontStyle: labelSmall.fontStyle,
                        ),
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle: labelSmall.fontStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
