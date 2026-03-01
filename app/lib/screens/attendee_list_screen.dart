import 'package:flutter/material.dart';

class AttendeeListScreen extends StatelessWidget {
  const AttendeeListScreen({super.key});

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
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Guest List',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: textMuted),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, email, or ticket #',
                hintStyle: TextStyle(color: textMuted),
                prefixIcon: Icon(Icons.search, color: textMuted),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Tab Bar
            Container(
              color: cardColor,
              child: TabBar(
                labelColor: primaryColor,
                unselectedLabelColor: textMuted,
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Checked In (450)'),
                  Tab(text: 'Pending (750)'),
                ],
              ),
            ),

            // Filters
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('All Ticket Types', true, primaryColor),
                    _buildFilterChip(
                      'VIP Only',
                      false,
                      primaryColor,
                      textMuted,
                      cardColor,
                      borderColor,
                      textColor,
                    ),
                    _buildFilterChip(
                      'General Admission',
                      false,
                      primaryColor,
                      textMuted,
                      cardColor,
                      borderColor,
                      textColor,
                    ),
                    _buildFilterChip(
                      'Early Bird',
                      false,
                      primaryColor,
                      textMuted,
                      cardColor,
                      borderColor,
                      textColor,
                    ),
                  ],
                ),
              ),
            ),

            // Tab Views / List
            Expanded(
              child: TabBarView(
                children: [
                  // Checked In Tab
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: 4,
                    separatorBuilder: (context, index) =>
                        Divider(color: borderColor, height: 1),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildAttendeeItem(
                          name: 'Sarah Jenkins',
                          email: 'sarah.j@example.com',
                          ticketType: 'VIP Access',
                          ticketNo: '#49201',
                          status: 'Checked In',
                          statusColor: Colors.green,
                          timeIcon: Icons.access_time,
                          timeText: '10:42 AM',
                          avatarUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDys9g22umKyRHJY8OLyZ3myDHPC0Gz12QLQ5qHADRViH9fVV3MMw-xnxz2nsHxg0NZQWq53ezQLWEPWd-NG3dau1dLHGCMsAKO0qYJtjKPqe5jiAxupjFirnH8GpL04s9wdilUsAenhEFVX8xPrfMDCtXBCjbn_vn4DcN_X5hzZ_cXmFfRpWR-sSSsUL43y9aoEsBp-te5bypHEw8Foiuer0WH2E3-PvJkVbq5ixhqWGZTaT38B_b07MGDuylb9PKHjrvXff70tFQ',
                          textColor: textColor,
                          textMuted: textMuted,
                          cardColor: cardColor,
                        );
                      } else if (index == 1) {
                        return _buildAttendeeItem(
                          name: 'Michael Chen',
                          email: 'm.chen@example.com',
                          ticketType: 'General Admission',
                          ticketNo: '#49202',
                          status: 'Checked In',
                          statusColor: Colors.green,
                          timeIcon: Icons.access_time,
                          timeText: '10:15 AM',
                          avatarInitials: 'MC',
                          textColor: textColor,
                          textMuted: textMuted,
                          cardColor: cardColor,
                          primaryColor: primaryColor,
                        );
                      } else if (index == 2) {
                        return _buildAttendeeItem(
                          name: 'Emma Thompson',
                          email: 'emma.t@example.com',
                          ticketType: 'VIP Access',
                          ticketNo: '#49203',
                          status: 'Checked In',
                          statusColor: Colors.green,
                          timeIcon: Icons.access_time,
                          timeText: '09:30 AM',
                          avatarUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDpATyl8x05WV39c1k5PwLFObRURfRc0aOmyaAmAubPLA-AP_hOA9DzQLZfrmTZ1bUTT6M-zlPvHMXc5v-W96KtpWJ9TtLmKao_59ZyYg87IX4NYzCa7UocDE-9qr06k4dl1qeCAIPXcC4JzhvlL9hxOeCnBVdPJw7vTdXEL13gQacfgNS6D9eFUDjlKLNCGYeJgzZ12SGGhauMpR2gJMvbss4-f54wyqwfcW8UOdnVKVU7q-iuYqghyZQJ-0zWhyVGB9kSD2Eda5o',
                          textColor: textColor,
                          textMuted: textMuted,
                          cardColor: cardColor,
                        );
                      } else {
                        return _buildAttendeeItem(
                          name: 'David Wilson',
                          email: 'd.wilson@example.com',
                          ticketType: 'General Admission',
                          ticketNo: '#49204',
                          status: 'Checked In',
                          statusColor: Colors.green,
                          timeIcon: Icons.access_time,
                          timeText: '09:05 AM',
                          avatarUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCKmUze-4VP6ZFsMnAgoSlh5ZIhbwd69LaXGTkY6cGpvKLmGSk1-0AsTn15zcgshMNuRzhUiofgI4A_LdzURJNMVcCAKY4SKwKM4crdQVown8goJ4ogPN1IfiLOWF6V5jtZ9opaz_varfcOcJni31tD95-evqVQqf2fBfQn0DVBjpP7uXRcnK_r1poMMmJAoSdS_FRR7LffzoDF5JpwH9ltdebGhR4HsghXaJUqPMlnINiFbR0IxW3nQW_4UBx6D1V8T_lDEwqonxY',
                          textColor: textColor,
                          textMuted: textMuted,
                          cardColor: cardColor,
                        );
                      }
                    },
                  ),

                  // Pending Tab
                  ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildAttendeeItem(
                        name: 'Robert Davis',
                        email: 'r.davis@example.com',
                        ticketType: 'General Admission',
                        ticketNo: '#50101',
                        status: 'Pending',
                        statusColor: Colors.amber,
                        avatarInitials: 'RD',
                        textColor: textColor,
                        textMuted: textMuted,
                        cardColor: cardColor,
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
                _buildNavItem(
                  Icons.dashboard,
                  'Dashboard',
                  false,
                  primaryColor,
                  textMuted,
                ),
                _buildNavItem(
                  Icons.qr_code_scanner,
                  'Scan',
                  false,
                  primaryColor,
                  textMuted,
                ),
                _buildNavItem(
                  Icons.group,
                  'Attendees',
                  true,
                  primaryColor,
                  textMuted,
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

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    Color primaryColor, [
    Color? textMuted,
    Color? cardColor,
    Color? borderColor,
    Color? textColor,
  ]) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : (borderColor ?? Colors.transparent),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : (textColor ?? Colors.black),
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAttendeeItem({
    required String name,
    required String email,
    required String ticketType,
    required String ticketNo,
    required String status,
    required Color statusColor,
    IconData? timeIcon,
    String? timeText,
    String? avatarUrl,
    String? avatarInitials,
    Color? primaryColor,
    required Color textColor,
    required Color textMuted,
    required Color cardColor,
  }) {
    return Container(
      color: cardColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarInitials != null
                  ? primaryColor?.withAlpha(25)
                  : Colors.grey[200],
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
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: textMuted, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      ticketType.contains('VIP')
                          ? Icons.star
                          : Icons.confirmation_number,
                      size: 14,
                      color: textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticketType,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      ticketNo,
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                    if (timeText != null) ...[
                      const Spacer(),
                      Icon(timeIcon, size: 14, color: textMuted),
                      const SizedBox(width: 4),
                      Text(
                        timeText,
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ],
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
    Color textMuted,
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
          child: Icon(icon, color: isActive ? primaryColor : textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? primaryColor : textMuted,
          ),
        ),
      ],
    );
  }
}
