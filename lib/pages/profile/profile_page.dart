import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/preferences/pref_helper.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/custom/report_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'Barista';
  String role = 'Lead Barista';
  String outletName = 'Main Branch';
  bool darkMode = true;
  bool notifications = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      username = prefs.getString(PrefHelper.username) ?? 'Barista';
      role = prefs.getString(PrefHelper.role) ?? 'Lead Barista';
      outletName = prefs.getString(PrefHelper.outletName) ?? 'Main Branch';
      darkMode = prefs.getBool(PrefHelper.themeMode) ?? true;
    });
  }

  Future<void> _setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefHelper.themeMode, value);
    if (!mounted) return;
    setState(() => darkMode = value);
  }

  Future<void> _logout() async {
    await PrefHelper.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ReportColors.navyDark,
        bottomNavigationBar: const AppBottomNav(currentIndex: 4),
        body: ReportGradientBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
              children: [
                _ProfileHeaderCard(
                  username: username,
                  role: role,
                  outletName: outletName,
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(
                      child: _ProfileStatCard(
                        value: '142',
                        label: 'Shifts Done',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _ProfileStatCard(
                        value: '4.9★',
                        label: 'Avg Rating',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _ProfileStatCard(
                        value: '284h',
                        label: 'Hours',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _SettingsCard(
                  darkMode: darkMode,
                  notifications: notifications,
                  outletName: outletName,
                  onDarkModeChanged: _setDarkMode,
                  onNotificationChanged: (value) {
                    setState(() => notifications = value);
                  },
                ),
                const SizedBox(height: 24),
                _SignOutButton(onTap: _logout),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String username;
  final String role;
  final String outletName;

  const _ProfileHeaderCard({
    required this.username,
    required this.role,
    required this.outletName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ReportColors.brownLight,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFB77946),
                          Color(0xFF2E4169),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _initials(username),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: ReportColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ReportColors.navyMid,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$role · Shift A',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ReportColors.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatusChip(
                      text: outletName,
                      color: ReportColors.brownLight,
                      background: ReportColors.brown.withOpacity(0.25),
                    ),
                    _StatusChip(
                      text: 'On Duty',
                      color: ReportColors.green,
                      background: ReportColors.green.withOpacity(0.18),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.045),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: ReportColors.muted,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'B';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;

  const _StatusChip({
    required this.text,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStatCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ReportColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool darkMode;
  final bool notifications;
  final String outletName;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onNotificationChanged;

  const _SettingsCard({
    required this.darkMode,
    required this.notifications,
    required this.outletName,
    required this.onDarkModeChanged,
    required this.onNotificationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Column(
        children: [
          _SettingSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            value: darkMode,
            onChanged: onDarkModeChanged,
          ),
          _divider(),
          _SettingSwitchTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            value: notifications,
            onChanged: onNotificationChanged,
          ),
          _divider(),
          const _SettingArrowTile(
            icon: Icons.language_rounded,
            title: 'Language',
            value: 'English',
          ),
          _divider(),
          _SettingArrowTile(
            icon: Icons.local_cafe_outlined,
            title: 'Outlet Info',
            value: outletName,
          ),
          _divider(),
          const _SettingArrowTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
          ),
          _divider(),
          const _SettingArrowTile(
            icon: Icons.star_border_rounded,
            title: 'Help & Support',
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 0),
      color: Colors.white.withOpacity(0.055),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          _SettingIcon(icon: icon),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: ReportColors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: ReportColors.navyMid,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingArrowTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;

  const _SettingArrowTile({
    required this.icon,
    required this.title,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          _SettingIcon(icon: icon),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (value != null) ...[
            Flexible(
              child: Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: ReportColors.muted,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(
            Icons.chevron_right_rounded,
            color: ReportColors.muted,
            size: 26,
          ),
        ],
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  final IconData icon;

  const _SettingIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(
        icon,
        color: ReportColors.muted,
        size: 26,
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF2D3565).withOpacity(0.72),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFF4D4D).withOpacity(0.45),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: Color(0xFFFF4D4D),
              size: 25,
            ),
            SizedBox(width: 12),
            Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFFF4D4D),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
