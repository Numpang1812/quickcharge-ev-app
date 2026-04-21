import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../main.dart';

// ── Entry point ─────────────────────────────────────────────────────────────

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
                    userName ?? 'Guest',
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
                        userEmail ?? 'Guest Email',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Account Settings ─────────────────────────────────────────
            const _SettingsSection(
              label: 'ACCOUNT SETTINGS',
              items: [
                _SettingsItemData(
                  icon: Icons.notifications_none_outlined,
                  label: 'Notifications',
                  destination: const NotificationsScreen(),
                ),
                _SettingsItemData(
                  icon: Icons.shield_outlined,
                  label: 'Privacy & Security',
                  destination: const PrivacySecurityScreen(),
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
                  destination: const HelpCenterScreen(),
                ),
                _SettingsItemData(
                  icon: Icons.chat_bubble_outline,
                  label: 'Contact Support',
                  destination: const ContactSupportScreen(),
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
                  onTap: (context) => _confirmSignOut(context),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleSignOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
  final Widget? destination;
  final void Function(BuildContext)? onTap;

  const _SettingsItemData({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.destination,
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
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    _SettingsRow(item: item, isFirst: i == 0, isLast: isLast),
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
    final iconColor = item.isDestructive
        ? const Color(0xFFEF4444)
        : const Color(0xFF49B63C);
    final textColor = item.isDestructive
        ? const Color(0xFFEF4444)
        : const Color(0xFF0F172A);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (item.onTap != null) {
            item.onTap!(context);
          } else if (item.destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.destination!),
            );
          }
        },
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

// ===========================================================================
// ===========================================================================
// DESTINATION SCREENS
// ===========================================================================

// ── Shared scaffold ─────────────────────────────────────────────────────────

class _DetailScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const _DetailScaffold({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: body,
    );
  }
}

// ── Helper widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}

class _CardRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showDivider;
  final VoidCallback? onTap;

  const _CardRow({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 52, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Notifications
// ---------------------------------------------------------------------------

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _smsEnabled = true;
  bool _promoEnabled = false;
  bool _activityEnabled = true;

  Widget _toggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    bool showDivider = true,
  }) {
    return _CardRow(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          value
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined,
          size: 20,
          color: value ? const Color(0xFF49B63C) : const Color(0xFF94A3B8),
        ),
      ),
      title: title,
      subtitle: subtitle,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF49B63C),
      ),
      showDivider: showDivider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Notifications',
      body: ListView(
        children: [
          const _SectionLabel('CHANNELS'),
          _SectionCard(
            children: [
              _toggle(
                'Push Notifications',
                'Alerts on this device',
                _pushEnabled,
                (v) => setState(() => _pushEnabled = v),
              ),
              _toggle(
                'Email Notifications',
                'Updates to your inbox',
                _emailEnabled,
                (v) => setState(() => _emailEnabled = v),
              ),
              _toggle(
                'SMS Notifications',
                'Text message alerts',
                _smsEnabled,
                (v) => setState(() => _smsEnabled = v),
                showDivider: false,
              ),
            ],
          ),
          const _SectionLabel('PREFERENCES'),
          _SectionCard(
            children: [
              _toggle(
                'Promotions & Offers',
                'Deals and rewards',
                _promoEnabled,
                (v) => setState(() => _promoEnabled = v),
              ),
              _toggle(
                'Account Activity',
                'Logins, balance changes',
                _activityEnabled,
                (v) => setState(() => _activityEnabled = v),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Privacy & Security (with working Change Password)
// ---------------------------------------------------------------------------

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometrics = true;
  bool _twoFactor = false;

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () {
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match!')),
                );
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF49B63C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Download My Data'),
        content: const Text(
          'Your data export is being prepared. You will receive an email with the download link shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFF49B63C))),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted.'),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Privacy & Security',
      body: ListView(
        children: [
          const _SectionLabel('SECURITY'),
          _SectionCard(
            children: [
              _CardRow(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 20,
                    color: Color(0xFF49B63C),
                  ),
                ),
                title: 'Biometric Login',
                subtitle: 'Face ID / Touch ID',
                trailing: Switch.adaptive(
                  value: _biometrics,
                  onChanged: (v) => setState(() => _biometrics = v),
                  activeColor: const Color(0xFF49B63C),
                ),
              ),
              _CardRow(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: Color(0xFFF97316),
                  ),
                ),
                title: 'Two-Factor Auth',
                subtitle: _twoFactor
                    ? 'Enabled via authenticator app'
                    : 'Not enabled',
                trailing: Switch.adaptive(
                  value: _twoFactor,
                  onChanged: (v) => setState(() => _twoFactor = v),
                  activeColor: const Color(0xFF49B63C),
                ),
              ),
              _CardRow(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.key_outlined,
                    size: 20,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                title: 'Change Password',
                onTap: _showChangePasswordDialog,
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFFCBD5E1),
                ),
                showDivider: false,
              ),
            ],
          ),
          const _SectionLabel('DATA'),
          _SectionCard(
            children: [
              _CardRow(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.download_outlined,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ),
                title: 'Download My Data',
                onTap: _showDownloadDataDialog,
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFFCBD5E1),
                ),
              ),
              _CardRow(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFFEF4444),
                  ),
                ),
                title: 'Delete Account',
                onTap: _showDeleteAccountDialog,
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFFCBD5E1),
                ),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Help Center (with search functionality)
// ---------------------------------------------------------------------------

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<Map<String, String>> _allArticles = [
    {
      'title': 'How do I add funds to my balance?',
      'content':
          'Go to Balance section and tap "Add Funds". Choose an amount and confirm with your saved payment method.',
    },
    {
      'title': 'How do I redeem my points?',
      'content':
          'Points are automatically applied at checkout. You can also redeem them for cash balance in the Rewards section.',
    },
    {
      'title': 'Can I transfer my balance to a bank?',
      'content':
          'Yes — go to Balance, tap "Withdraw", and link your bank account. Transfers take 1–3 business days.',
    },
    {
      'title': 'Why was my payment declined?',
      'content':
          'This can happen if your card details are outdated or the bank flagged the transaction. Try updating your card or contact your bank.',
    },
    {
      'title': 'How do I dispute a charge?',
      'content':
          'Tap on the transaction in your history and select "Dispute This Charge". Our team reviews within 3–5 business days.',
    },
    {
      'title': 'How do I update my profile information?',
      'content':
          'Go to Profile Screen and tap on your avatar. You can edit your name, email, and other personal information there.',
    },
    {
      'title': 'What payment methods are accepted?',
      'content':
          'We accept Credit/Debit cards, Bank transfers, and various mobile wallets like ABA, Wing, and ACLEDA.',
    },
    {
      'title': 'How do I contact customer support?',
      'content':
          'You can contact us through the Contact Support option in the Support section of your profile.',
    },
  ];

  List<Map<String, String>> get _filteredArticles {
    if (_searchQuery.isEmpty) return _allArticles;
    return _allArticles
        .where(
          (article) =>
              article['title']!.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              article['content']!.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Help Center',
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF49B63C)),
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: _filteredArticles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No articles found',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = _filteredArticles[index];
                      final isLast = index == _filteredArticles.length - 1;
                      return _FaqTile(
                        question: article['title']!,
                        answer: article['content']!,
                        showDivider: !isLast,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  final bool showDivider;

  const _FaqTile({
    required this.question,
    required this.answer,
    this.showDivider = true,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Icon(
                    _open ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: const Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ),
          if (widget.showDivider && !_open)
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Contact Support
// ---------------------------------------------------------------------------

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedTopic = 'Payment Issue';
  bool _submitted = false;

  static const _topics = [
    'Payment Issue',
    'Account Access',
    'Rewards / Points',
    'Technical Problem',
    'Other',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_subjectController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Contact Support',
      body: _submitted ? _successView(context) : _formView(context),
    );
  }

  Widget _successView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 36,
                color: Color(0xFF49B63C),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Message Sent!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our support team will get back to you within 24 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF49B63C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Profile',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        const Text(
          'Topic',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTopic,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              items: _topics
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedTopic = v!),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Subject',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _subjectController,
          decoration: InputDecoration(
            hintText: 'Brief description of your issue',
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Message',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _messageController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Describe your issue in detail…',
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF49B63C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Send Message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
