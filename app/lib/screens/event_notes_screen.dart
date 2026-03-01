import 'package:flutter/material.dart';

class EventNotesScreen extends StatelessWidget {
  const EventNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0F172A)
        : Colors.white; // Using slate-900 or white
    final appBackgroundColor = isDark
        ? const Color(0xFF101922)
        : const Color(0xFFF6F7F8);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);
    final primaryColor = const Color(0xFF2B8CEE);

    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            color: backgroundColor,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        color: textMuted,
                      ),
                      Text(
                        'Staff Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                        color: textMuted,
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Input Section
                      Text(
                        'New Note',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: inputColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              maxLines: 5,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText:
                                    'Type incident details or event updates here...',
                                hintStyle: TextStyle(color: textMuted),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Material(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.add_a_photo,
                                      size: 20,
                                      color: textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: primaryColor.withAlpha(
                            76,
                          ), // ~0.3 opacity
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Save Note',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Previous Notes List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildNoteItem(
                        name: 'James Wilson',
                        time: '10:42 AM',
                        content:
                            'Gate B scanner is intermittently offline. Tech support has been notified.',
                        avatarUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCpl2vekt5qUQvWZGxja5-fg42yjXiAyGH2DxZmFT008Abq_ip7n5J4h41kXWC_VvSFwGyUsBpyU7ufbgbpbUYH6ArQU-2cPPavJKAwMHh0b5XeParuY_mYaMK0bSC8oCVn3SWHDA7V7W0e8nOPCdj_5YGrn3aTsepb7pnoULmiaWXqdVcQ69Lza3Te6gyvsAeqzI7AF1eHG4y02Dj9b9URfUAixxnHY0cAZ2Hb71ItTtGDTymznisLhTPFg4njaKpIQSX73mTNRbM',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        textMuted: textMuted,
                      ),
                      _buildNoteItem(
                        name: 'Sarah Chen',
                        time: '09:15 AM',
                        content:
                            'VIP section is at capacity. Redirecting new VIP guests to the overflow lounge near the east wing.',
                        alertTag: 'Capacity Alert',
                        avatarUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDpATyl8x05WV39c1k5PwLFObRURfRc0aOmyaAmAubPLA-AP_hOA9DzQLZfrmTZ1bUTT6M-zlPvHMXc5v-W96KtpWJ9TtLmKao_59ZyYg87IX4NYzCa7UocDE-9qr06k4dl1qeCAIPXcC4JzhvlL9hxOeCnBVdPJw7vTdXEL13gQacfgNS6D9eFUDjlKLNCGYeJgzZ12SGGhauMpR2gJMvbss4-f54wyqwfcW8UOdnVKVU7q-iuYqghyZQJ-0zWhyVGB9kSD2Eda5o',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        textMuted: textMuted,
                      ),
                      _buildNoteItem(
                        name: 'John Doe',
                        time: '08:50 AM',
                        content:
                            'Checked in the main sponsor group. They are seated in Row A.',
                        avatarInitials: 'JD',
                        primaryColor: primaryColor,
                        backgroundColor: backgroundColor,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        textMuted: textMuted,
                      ),

                      // Divider Yesterday
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: borderColor)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Text(
                                'Yesterday',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: textMuted,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: borderColor)),
                          ],
                        ),
                      ),

                      Opacity(
                        opacity: 0.75,
                        child: _buildNoteItem(
                          name: 'Mike Ross',
                          time: '4:30 PM',
                          content:
                              'Final security briefing completed. All teams are ready for tomorrow.',
                          avatarUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCKmUze-4VP6ZFsMnAgoSlh5ZIhbwd69LaXGTkY6cGpvKLmGSk1-0AsTn15zcgshMNuRzhUiofgI4A_LdzURJNMVcCAKY4SKwKM4crdQVown8goJ4ogPN1IfiLOWF6V5jtZ9opaz_varfcOcJni31tD95-evqVQqf2fBfQn0DVBjpP7uXRcnK_r1poMMmJAoSdS_FRR7LffzoDF5JpwH9ltdebGhR4HsghXaJUqPMlnINiFbR0IxW3nQW_4UBx6D1V8T_lDEwqonxY',
                          cardColor:
                              inputColor, // Slightly different color to represent older note
                          borderColor: borderColor,
                          textColor: textColor,
                          textMuted: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Nav (simulated for flow)
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBottomItem(
                        Icons.qr_code_scanner,
                        'Scan',
                        textMuted,
                      ),
                      _buildBottomItem(Icons.group, 'Attendees', textMuted),

                      // Active Notes Tab
                      SizedBox(
                        height: 50,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: 24,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primaryColor.withAlpha(25),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: backgroundColor,
                                    width: 4,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit_note,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            Text(
                              'Notes',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildBottomItem(Icons.bar_chart, 'Stats', textMuted),
                      _buildBottomItem(Icons.person, 'Profile', textMuted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteItem({
    required String name,
    required String time,
    required String content,
    String? alertTag,
    String? avatarUrl,
    String? avatarInitials,
    Color? primaryColor,
    Color? backgroundColor,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarInitials != null
                  ? primaryColor?.withAlpha(25)
                  : Colors.grey[200],
              border: Border.all(
                color: backgroundColor ?? Colors.white,
                width: 2,
              ),
              image: avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
              ],
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
          // Note bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: textMuted,
                      height: 1.4,
                    ),
                  ),
                  if (alertTag != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        alertTag,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
