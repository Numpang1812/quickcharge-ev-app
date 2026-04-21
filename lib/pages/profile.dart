import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = SupabaseService.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
        // Try to get name from metadata
        userName = (user.userMetadata?['full_name'] as String?) ?? 
                   (user.userMetadata?['name'] as String?) ?? 
                   'EV Explorer';
      });
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await SupabaseService.signOut();
      if (mounted) {
        // Restart the app by going back to the root widget
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const QuickChargeApp()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header card ──────────────────────────────────────────────
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              child: Column(
                children: [
                  // Avatar with lightning badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCEAFB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 52,
                          color: Color(0xFF49B63C),
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bolt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Name
                  Text(
                    userName ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userEmail ?? 'No email found',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Balance & Points stat cards
                  const Row(
                    children: [
                      Expanded(
                        child: _StatCard(label: 'BALANCE', value: '\$42.50'),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(label: 'POINTS', value: '1,240'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Account Settings ─────────────────────────────────────────
            const _SettingsSection(
              label: 'ACCOUNT SETTINGS',
              items: [
                _SettingsItemData(
                  icon: Icons.credit_card_outlined,
                  label: 'Payment Methods',
                ),
                _SettingsItemData(
                  icon: Icons.notifications_none_outlined,
                  label: 'Notifications',
                ),
                _SettingsItemData(
                  icon: Icons.shield_outlined,
                  label: 'Privacy & Security',
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Support ──────────────────────────────────────────────────
            const _SettingsSection(
              label: 'SUPPORT',
              items: [
                _SettingsItemData(
                  icon: Icons.help_outline,
                  label: 'Help Center',
                ),
                _SettingsItemData(
                  icon: Icons.chat_bubble_outline,
                  label: 'Contact Support',
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Danger zone ──────────────────────────────────────────────
            _SettingsSection(
              label: 'ACCOUNT',
              items: [
                _SettingsItemData(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  isDestructive: true,
                  onTap: _handleSignOut,
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat Card
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings Section
// ---------------------------------------------------------------------------

class _SettingsItemData {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsItemData({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.onTap,
  });
}

class _SettingsSection extends StatelessWidget {
  final String label;
  final List<_SettingsItemData> items;

  const _SettingsSection({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final isFirst = i == 0;
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    _SettingsRow(
                      item: item,
                      isFirst: isFirst,
                      isLast: isLast,
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        indent: 52,
                        color: Color(0xFFF1F5F9),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final _SettingsItemData item;
  final bool isFirst;
  final bool isLast;

  const _SettingsRow({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
    item.isDestructive ? const Color(0xFFEF4444) : const Color(0xFF49B63C);
    final textColor =
    item.isDestructive ? const Color(0xFFEF4444) : const Color(0xFF0F172A);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(item.icon, size: 22, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (!item.isDestructive)
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFFCBD5E1),
                ),
            ],
          ),
        ),
      ),
    );
  }
}