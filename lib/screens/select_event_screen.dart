import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // We will route here upon selection

class SelectEventScreen extends StatelessWidget {
  const SelectEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF101922)
        : const Color(0xFFF6F7F8);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D141B);
    final textColorMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final primaryColor = const Color(0xFF2B8CEE);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header & Search
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              color: isDark
                  ? backgroundColor.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.9),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: cardColor,
                          shape: const CircleBorder(),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Select Designated Event',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for centering
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Field
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assigned Events',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Event Card 1
                  _buildEventCard(
                    context: context,
                    title: 'Summer Music Festival',
                    location: 'Central Park Arena',
                    dateText: 'Today, 8:00 PM',
                    soldText: '342 Sold',
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDQ_snCOWcUKiO5VMA0M9gr1Vx3Xs32UnMkYFmf9BhOtK-kjhYd9-gMlk27J-Jqhf4_QQ7H3qmrYQ_wFToKxaV4NLwJbscOWWRJ6_cLeeNb3zgcqPlPIdjsTCHrQofuKgL6BCgbM_vSJpZUKP8kpiY-a2jK6kBh25bZ7WYc5niPCUgHEA464_YxG27FFo0LJEnKKzEg2zFgcRmO0JXuqgWGIdeoRmRf1-RBP4SANHz5sJ8ykj1r8tP_lwmrejv8_RmiFc2vdwDwixw',
                    isPrimaryButton: true,
                    cardColor: cardColor,
                    textColor: textColor,
                    textColorMuted: textColorMuted,
                    primaryColor: primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),

                  // Event Card 2
                  _buildEventCard(
                    context: context,
                    title: 'Tech Innovators Summit 2024',
                    location: 'Moscone Center',
                    dateText: 'Aug 12, 10:00 AM',
                    soldText: '1,205 Sold',
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuA_9eFu7uTOwiupCFxvQZjtZQ-P1LBmsPTcq3bsFyRW8Dq0yc5OhXzg6ugj09qu5-VOitAP3q3hCVkpJ9iWQGbXjk_rBd5rveRpAT6uL7pZVpgm068WJC6htNoyGLA7_0oAdZcWeNQjcUyVXfPLocnoIPoCcbFFYkrly7kUYqT5-lBJFZmvbweAsb1s_QAUBuYM2gJIp3egFvyuX3l8mtKamwunTUdpBYDQ5edBfTApjxzF9zpg9MqczhSC0iaLku1UCYw9EaNie3U',
                    isPrimaryButton: false,
                    cardColor: cardColor,
                    textColor: textColor,
                    textColorMuted: textColorMuted,
                    primaryColor: primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),

                  // Event Card 3 (Past Event)
                  Opacity(
                    opacity: 0.8,
                    child: _buildEventCard(
                      context: context,
                      title: 'Modern Art Expo',
                      location: 'The Tate Modern',
                      dateText: 'Ended',
                      soldText: '',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDjGgOH-V5b_rmB4eAKywQdn03x-0aqhKQTI8Fr2FecFFI6rI-6NRYKm_5VvjSp5VTD2eH3ftXphxuOMEFh8G6tgI6b4kIeM9_c-bfgcjsh-nvDxP4WHPOqgIO7xnKG6Ox8B_xkYmVn9yPEZsNMX7ieSckT_CQ_iRbc5uC2jcokKXTxLnmN41-pgcFlmEnN0OfoZ0fIrZ62XDHmgem_BPWCaKIGgSdT2WrlCm1vo7Uu87wTZJ4uG1LU12M5mUYAsySRuLIkm6ACxus',
                      isPrimaryButton: false,
                      cardColor: cardColor,
                      textColor: textColor,
                      textColorMuted: textColorMuted,
                      primaryColor: primaryColor,
                      isPast: true,
                    ),
                  ),
                  const SizedBox(height: 80), // Fab spacing
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(
        context,
        primaryColor,
        cardColor,
        borderColor,
      ),
    );
  }

  Widget _buildEventCard({
    required BuildContext context,
    required String title,
    required String location,
    required String dateText,
    required String soldText,
    required String imageUrl,
    required bool isPrimaryButton,
    required Color cardColor,
    required Color textColor,
    required Color textColorMuted,
    required Color primaryColor,
    bool isPast = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Header
          SizedBox(
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColorFiltered(
                  colorFilter: isPast
                      ? const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        )
                      : const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        ),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
                Container(
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
                if (isPast)
                  Container(
                    color: Colors.black38,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Ended',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (soldText.isNotEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.confirmation_number,
                            size: 14,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            soldText,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Text(
                    dateText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: textColorMuted),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(fontSize: 14, color: textColorMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isPast ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPrimaryButton
                        ? primaryColor
                        : (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9)),
                    foregroundColor: isPrimaryButton ? Colors.white : textColor,
                    elevation: isPrimaryButton ? 2 : 0,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isPast ? 'View Details' : 'Select Event',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isPrimaryButton) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    Color primaryColor,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.calendar_month, 'Events', true, primaryColor),
              _buildNavItem(Icons.qr_code_scanner, 'Scan', false, primaryColor),
              _buildNavItem(Icons.person, 'Profile', false, primaryColor),
            ],
          ),
        ),
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
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
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
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? primaryColor : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
