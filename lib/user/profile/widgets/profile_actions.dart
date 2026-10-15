import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_header.dart' show kDefaultProfileAvatar;

/// Bottom status/navigation bar at the foot of the profile screen. Shows a
/// back chevron, happy-day counter, and a small avatar linking back to the
/// profile page.
class ProfileBottomBar extends StatelessWidget {
  const ProfileBottomBar({super.key, required this.profileRouteName});

  final String profileRouteName;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      height: 41.0,
      decoration: BoxDecoration(color: theme.primary),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 5.0, 20.0, 5.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async => context.safePop(),
              child: FaIcon(
                FontAwesomeIcons.circleChevronLeft,
                color: theme.lightBlueForMobile,
                size: 30.0,
              ),
            ),
            _buildHappyDays(context, theme),
            _buildAvatarButton(context, profileRouteName),
          ],
        ),
      ),
    );
  }

  Widget _buildHappyDays(BuildContext context, FlutterFlowTheme theme) {
    final bodyMedium = theme.bodyMedium;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(Icons.favorite, color: theme.tertiary, size: 24.0),
        Text(
          '${functions.emocion(FFAppState().CalenderEmotion.map((e) => e.emocion).toList())} dias',
          style: bodyMedium.override(
            font: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontStyle: bodyMedium.fontStyle,
            ),
            letterSpacing: 0.0,
            fontWeight: FontWeight.bold,
            fontStyle: bodyMedium.fontStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarButton(BuildContext context, String routeName) {
    return AuthUserStreamWidget(
      builder: (context) => InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          context.pushNamed(
            routeName,
            extra: <String, dynamic>{
              '__transition_info__': const TransitionInfo(
                hasTransition: true,
                transitionType: PageTransitionType.fade,
                duration: Duration(milliseconds: 0),
              ),
            },
          );
        },
        child: Container(
          width: 41.0,
          height: 41.0,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: CachedNetworkImage(
            imageUrl: valueOrDefault<String>(
              currentUserPhoto,
              'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
            ),
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Image.network(
              kDefaultProfileAvatar,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
