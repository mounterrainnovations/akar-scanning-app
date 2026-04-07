import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
    final primaryColor = const Color(0xFF2B8CEE);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: textColor),
          onPressed: () {},
        ),
        title: Text(
          'Trippechalo',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBUBt73g8wYLoliAhTn08g4iVSP-Fb5YEWJab7TA8LHB0mfBn-Vxn-t0MBsIvPF-fqqo57lXsCmY2XQVgCcc4xKK1Noc6AFbNoYQ09J61DzEwfIpvwgc_PlWIkX5hp-WZC5FfMO-1UzjqMHpw49Lyumd8V9wn57z5wiCm39IW3DkvDYKS-YGonUgUtc9pqTmvPGtDURG89gvnFcmelU-dIQWQsKvsOYEAnU6_pWr4uxfQSxAxkzLOHD-Ge_dTWIPkTwM9thZrDf9qg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LIVE NOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Summer Music Fest 2024',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Location / Date text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Central Park, NY',
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text('•', style: TextStyle(color: textMuted, fontSize: 14)),
                  const SizedBox(width: 8),
                  Icon(Icons.calendar_today, size: 16, color: textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Aug 24, 2024',
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance Status',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '500 ',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/ 1200',
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(isDark ? 50 : 30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 14,
                                color: isDark
                                    ? Colors.greenAccent
                                    : Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+12% vs last hr',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.greenAccent
                                      : Colors.green[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.42,
                        minHeight: 12,
                        backgroundColor: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Checked In',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '42% Capacity',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: borderColor),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VIP Guests',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '45/100',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'General Admission',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '455/1100',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.qr_code_scanner, size: 32),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start Scanning',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryActionButton(
                          icon: Icons.groups,
                          label: 'Attendee List',
                          isDark: isDark,
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSecondaryActionButton(
                          icon: Icons.note_add,
                          label: 'Add Note',
                          isDark: isDark,
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Recent Activity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Recent Check-ins',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Live',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildRecentItem(
                    name: 'Sarah Jenkins',
                    desc: 'VIP Access • Gate A',
                    time: '2m ago',
                    avatarUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDys9g22umKyRHJY8OLyZ3myDHPC0Gz12QLQ5qHADRViH9fVV3MMw-xnxz2nsHxg0NZQWq53ezQLWEPWd-NG3dau1dLHGCMsAKO0qYJtjKPqe5jiAxupjFirnH8GpL04s9wdilUsAenhEFVX8xPrfMDCtXBCjbn_vn4DcN_X5hzZ_cXmFfRpWR-sSSsUL43y9aoEsBp-te5bypHEw8Foiuer0WH2E3-PvJkVbq5ixhqWGZTaT38B_b07MGDuylb9PKHjrvXff70tFQ',
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 12),
                  _buildRecentItem(
                    name: 'John Doe',
                    desc: 'General Admission • Gate B',
                    time: '5m ago',
                    avatarInitials: 'JD',
                    primaryColor: primaryColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 12),
                  Opacity(
                    opacity: 0.7,
                    child: _buildRecentItem(
                      name: 'Michael Smith',
                      desc: 'General Admission • Gate A',
                      time: '12m ago',
                      avatarUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAz88wGCdoi4uwwzQGl2FiPZ9nBJV7eGyy-gx5rM4eF5mdEXRkBmmSFHS9bTWRR9xzu8ap6ORUt3hT08XWo7JWGcwsc-t84cRzQ2bmsWILrK3v0QiX5L6pFZP3jQBjgmIDyAN4IH3acK0wL7EH9MDT04F0qe6qB6Pm-2gZRb83gGzcIvTDj5ovSsYwmpAqyZuCutKmFTF72VXoGz_y4B0ldpEybuKogmWx85vY7p4HHgmokNhv51iby0wZZPi0CNUn-D3IdpZqorpc',
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      textMuted: textMuted,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        child: const Icon(Icons.support_agent),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard, 'Dashboard', true, primaryColor),
                _buildNavItem(
                  Icons.calendar_today,
                  'Events',
                  false,
                  primaryColor,
                ),
                _buildNavItem(Icons.person, 'Profile', false, primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color primaryColor,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: primaryColor),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRecentItem({
    required String name,
    required String desc,
    required String time,
    String? avatarUrl,
    String? avatarInitials,
    Color? primaryColor,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: avatarInitials != null
                  ? primaryColor?.withAlpha(25)
                  : Colors.grey[200],
              shape: BoxShape.circle,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(desc, style: TextStyle(color: textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    Color primaryColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? primaryColor.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: isActive ? primaryColor : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? primaryColor : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
