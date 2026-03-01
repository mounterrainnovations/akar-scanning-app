import 'package:flutter/material.dart';

class ContactHubScreen extends StatelessWidget {
  const ContactHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF101922)
        : const Color(0xFFF6F7F8);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);
    final primaryColor = const Color(0xFF2B8CEE);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                color: isDark
                    ? backgroundColor.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                          color: cardColor,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, size: 20),
                          color: textMuted,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Event Contacts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    color: textMuted,
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Scrollable Lists
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withAlpha(76),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.sos,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Emergency',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withAlpha(76),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.support_agent,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Support',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Organizers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Organizers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'View All',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    name: 'Sarah Jenkins',
                    role: 'Lead Event Coordinator',
                    statusColor: Colors.green,
                    avatarUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCf7rWK-XTycdsfjMZ5TKHU5OF6FEKnsAgWzx473LO9UYhRx6ypio1juOTqk3LhJEzUU9Icqr-i3ZZOLOtG8BuUdtKSbopkgKVqiUAJ3sw0rQmzNw9iO-pcsmW2fsPlrkMnjm3fnt01nd1-IAQeiwLTg0epNHnV3TnLXbbQ05X-Ak3xptcWsGa0sofGWVc8lPe7MlA5n4eM1hFysqVg7wz5a9J0v7ozz3Qeo3HKVxfdhqlPQHABUUjuZITMx1eBCWEfGkx35ckcksg',
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    textMuted: textMuted,
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    name: 'Mike Ross',
                    role: 'Venue Manager',
                    statusColor: Colors.amber,
                    avatarUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAWYBvnCkx6CDvGU5cYItFf89pYovOjNCZ3YhBrfUaVFIW7mfxFzLYtFOsMu5CdYj9j-HG0_rj1T-Hv-ak-NwgGIKPYx8BZdjR224KL7_pMDVz9MYz5EPnmrtdKw-HRUEOE5bQnn599Bb1n8v_q8Uc6imXsK15XNrDln6VgnIrF0gQA9Rxeo7sMhJ-V4HRl7--fbQdpRzt2AwrfgoeWKb6LBqmolcoG_ZN713Kfm8I878jO2Xeazyr5veS9EdA01Ocl7EQJ88gCqWk',
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    textMuted: textMuted,
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 32),

                  // Venue Staff
                  Text(
                    'Venue Staff',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    name: 'Jessica Pearson',
                    role: 'Security Chief',
                    avatarUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuA4x6xEk8f_wxaZzRBDatuXccGjhxtJ1PPX6TAYRoI9JC10j4yZpjjuRvKBKzzQUolwi2b_Uu-GQtG9W_3utW5CIUsyKFrqQTP6AhZ5x9pbLD2miY9e1IC9_yJ2Id-0TVxg6cwj0o6y19XVzjHWysGCifab9VJZo9r3mhjoR1VG3roucdg3Z9SPaNh5aN451ZqVhF5xPahipfILAb740F6lx5b2_K87BT4xN8buar6Xb1_pObLiXV9zN1aBFO2ycf-E8-Zi9UiQdUU',
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    textMuted: textMuted,
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    name: 'David Lee',
                    role: 'Audio Engineer',
                    avatarInitials: 'DL',
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    textMuted: textMuted,
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  Icons.qr_code_scanner,
                  'Scan',
                  false,
                  primaryColor,
                  textMuted,
                ),
                _buildNavItem(
                  Icons.groups,
                  'Attendees',
                  false,
                  primaryColor,
                  textMuted,
                ),

                // Active Contacts element with Top Bar indicator
                SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(Icons.call, color: primaryColor, size: 24),
                      Text(
                        'Contacts',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildNavItem(
                  Icons.account_circle,
                  'Profile',
                  false,
                  primaryColor,
                  textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String name,
    required String role,
    Color? statusColor,
    String? avatarUrl,
    String? avatarInitials,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatarInitials != null
                      ? primaryColor.withAlpha(50)
                      : Colors.grey[200],
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : Colors.white,
                    width: 2,
                  ),
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: avatarInitials != null
                    ? Text(
                        avatarInitials,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (statusColor != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  role,
                  style: TextStyle(color: textMuted, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              _buildActionButton(Icons.chat_bubble, primaryColor, isDark),
              const SizedBox(width: 8),
              _buildActionButton(Icons.call, primaryColor, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color primaryColor, bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: primaryColor, size: 20),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    Color primaryColor,
    Color textMuted,
  ) {
    return SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? primaryColor : textMuted, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? primaryColor : textMuted,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
