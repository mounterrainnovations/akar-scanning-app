import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'scan_screen.dart';
import 'profile_screen.dart';
import 'checkin_stats_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _registrations = [];
  List<Map<String, dynamic>> _events = [];
  Set<String> _checkedInIds = {};
  bool _loading = true;
  String _searchQuery = '';
  String? _selectedFilterEventId; // null = all events

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _client
            .from('event_registrations')
            .select('id, form_response, created_at, event_id, events(name, city)')
            .eq('payment_status', 'paid')
            .order('created_at', ascending: false),
        _client
            .from('events')
            .select('id, name, city')
            .order('created_at', ascending: false),
        _client
            .from('ticket_scans')
            .select('registration_id')
            .eq('scan_result', 'success'),
      ]);

      if (mounted) {
        setState(() {
          _registrations = List<Map<String, dynamic>>.from(results[0] as List);
          _events = List<Map<String, dynamic>>.from(results[1] as List);
          _checkedInIds = (results[2] as List)
              .map((s) => s['registration_id'] as String)
              .toSet();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _getName(Map<String, dynamic> reg) {
    final form = reg['form_response'] as Map?;
    final name = (form?['name'] ?? '').toString().trim();
    return name.isNotEmpty ? name : 'Unknown';
  }

  String _getPhone(Map<String, dynamic> reg) {
    final form = reg['form_response'] as Map?;
    return (form?['phone'] ?? form?['whatsapp_number'] ?? form?['mobile_number'] ?? '').toString().trim();
  }

  String _getEmail(Map<String, dynamic> reg) {
    final form = reg['form_response'] as Map?;
    return (form?['email'] ?? '').toString().trim();
  }

  String _getEventName(Map<String, dynamic> reg) {
    final event = reg['events'] as Map?;
    return (event?['name'] ?? '').toString().trim();
  }

  String _getEventCity(Map<String, dynamic> reg) {
    final event = reg['events'] as Map?;
    return (event?['city'] ?? '').toString().trim();
  }

  String _getTicketRef(Map<String, dynamic> reg) {
    final id = reg['id']?.toString() ?? '';
    return id.isNotEmpty ? 'TKT-${id.substring(0, 8).toUpperCase()}' : 'N/A';
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _registrations;
    if (_selectedFilterEventId != null) {
      list = list.where((r) => r['event_id'] == _selectedFilterEventId).toList();
    }
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((r) {
      return _getName(r).toLowerCase().contains(q) ||
          _getEventName(r).toLowerCase().contains(q) ||
          _getPhone(r).contains(q);
    }).toList();
  }

  void _showEventPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primary = const Color(0xFF2B8CEE);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 8, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Select Event',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text('View gate entry stats for a specific event',
                style: TextStyle(fontSize: 13, color: textMuted)),
            const SizedBox(height: 16),
            if (_events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                    child: Text('No events found.',
                        style: TextStyle(color: textMuted))),
              )
            else
              ...(_events.map((event) {
                final name = (event['name'] ?? '').toString();
                final city = (event['city'] ?? '').toString();
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckinStatsScreen(
                          eventId: event['id'] as String,
                          eventName: name,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.event_note,
                              color: primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              if (city.isNotEmpty)
                                Text(city,
                                    style: TextStyle(
                                        color: textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: textMuted, size: 20),
                      ],
                    ),
                  ),
                );
              })),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> reg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF2B8CEE);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final name = _getName(reg);
    final email = _getEmail(reg);
    final phone = _getPhone(reg);
    final ticketRef = _getTicketRef(reg);
    final eventName = _getEventName(reg);
    final eventCity = _getEventCity(reg);
    final date = _formatDate(reg['created_at']);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final form = reg['form_response'] as Map? ?? {};
    final kidName = (form['kid_name'] ?? form['kids_name'] ?? form['child_s_full_name'] ?? '').toString().trim();
    final kidAge = (form['kids_age'] ?? '').toString().trim();
    final participantType = (form['participant_type'] ?? form['participation_for'] ?? '').toString().trim();
    final parentName = (form['parent_s_name'] ?? form['mothers_name'] ?? '').toString().trim();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            CircleAvatar(
              backgroundColor: primaryColor.withAlpha(30),
              radius: 30,
              child: Text(initial, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 24)),
            ),
            const SizedBox(height: 12),
            Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(ticketRef, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(height: 20),
            _detailRow(Icons.event, 'Event', eventName, textColor, textMuted),
            if (eventCity.isNotEmpty) _detailRow(Icons.location_on, 'City', eventCity, textColor, textMuted),
            if (email.isNotEmpty) _detailRow(Icons.email_outlined, 'Email', email, textColor, textMuted),
            if (phone.isNotEmpty) _detailRow(Icons.phone, 'Phone', phone, textColor, textMuted),
            if (kidName.isNotEmpty) _detailRow(Icons.child_care, 'Child Name', kidName, textColor, textMuted),
            if (kidAge.isNotEmpty) _detailRow(Icons.cake, 'Child Age', kidAge, textColor, textMuted),
            if (participantType.isNotEmpty) _detailRow(Icons.category, 'Participation', participantType, textColor, textMuted),
            if (parentName.isNotEmpty) _detailRow(Icons.person, 'Parent', parentName, textColor, textMuted),
            if (date.isNotEmpty) _detailRow(Icons.calendar_today, 'Registered On', date, textColor, textMuted),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color textColor, Color textMuted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2B8CEE)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: textMuted, fontWeight: FontWeight.w500)),
                Text(value, style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryColor = const Color(0xFF2B8CEE);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    final filtered = _filtered;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('AWG Dashboard',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: textMuted), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          // ── Top bar: confirmed count ──────────────────────────────────
          if (!_loading)
            Container(
              color: cardColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: Colors.green),
                        const SizedBox(width: 6),
                        Text('${_registrations.length} Confirmed',
                            style: const TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Gate Entry Status card ────────────────────────────────────
          if (!_loading)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.how_to_reg_outlined, color: primaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gate Entry Status',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        const SizedBox(height: 2),
                        Text('Track check-in progress per event',
                            style: TextStyle(fontSize: 11, color: textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showEventPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Select Event',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios,
                              color: Colors.white, size: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Search ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by name, event, or phone...',
                hintStyle: TextStyle(color: textMuted, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
                filled: true,
                fillColor: cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor)),
              ),
            ),
          ),

          // ── Event filter chips ────────────────────────────────────────
          if (!_loading && _events.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _events.length + 1, // +1 for "All Events"
                itemBuilder: (_, i) {
                  final isAll = i == 0;
                  final eventId = isAll ? null : _events[i - 1]['id'] as String;
                  final label = isAll
                      ? 'All Events'
                      : (_events[i - 1]['name'] as String? ?? '');
                  final isSelected = _selectedFilterEventId == eventId;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilterEventId = eventId),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : (isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : borderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // ── Attendees header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('Attendees',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(width: 8),
                Text('(${filtered.length})',
                    style: TextStyle(color: textMuted, fontSize: 14)),
              ],
            ),
          ),

          // ── Attendees list ────────────────────────────────────────────
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty && _selectedFilterEventId == null
                              ? 'No confirmed attendees found.'
                              : 'No results.',
                          style: TextStyle(color: textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final reg = filtered[i];
                          final name = _getName(reg);
                          final initial =
                              name.isNotEmpty ? name[0].toUpperCase() : '?';
                          final eventName = _getEventName(reg);
                          final phone = _getPhone(reg);
                          final isCheckedIn = _checkedInIds.contains(reg['id'] as String? ?? '');
                          final statusColor = isCheckedIn ? Colors.green : primaryColor;

                          return GestureDetector(
                            onTap: () => _showDetails(context, reg),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: isCheckedIn
                                        ? Colors.green.withAlpha(80)
                                        : (isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0))),
                              ),
                              child: Row(
                                children: [
                                  // Plain avatar — no dot
                                  CircleAvatar(
                                    backgroundColor: primaryColor.withAlpha(25),
                                    radius: 22,
                                    child: Text(initial,
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                                fontSize: 15),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Icon(Icons.event,
                                                size: 11,
                                                color: primaryColor
                                                    .withAlpha(180)),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(eventName,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: primaryColor
                                                          .withAlpha(180)),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          ],
                                        ),
                                        if (phone.isNotEmpty)
                                          Text(phone,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: textMuted)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Explicit check-in status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: statusColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: statusColor.withAlpha(60),
                                          width: 1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isCheckedIn
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: statusColor,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isCheckedIn
                                              ? 'Checked In'
                                              : 'Not In Yet',
                                          style: TextStyle(
                                              color: statusColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: cardColor,
            border: Border(top: BorderSide(color: borderColor))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.dashboard, 'Dashboard', true,
                    primaryColor, null),
                _buildNavItem(context, Icons.qr_code_scanner, 'Scan', false,
                    primaryColor, const ScanScreen()),
                _buildNavItem(context, Icons.person, 'Profile', false,
                    primaryColor, const ProfileScreen()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      bool isActive, Color primaryColor, Widget? target) {
    return GestureDetector(
      onTap: () {
        if (!isActive && target != null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => target));
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? primaryColor.withAlpha(30) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon,
                color: isActive ? primaryColor : Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? primaryColor : Colors.grey.shade500)),
        ],
      ),
    );
  }
}
