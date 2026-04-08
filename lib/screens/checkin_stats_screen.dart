import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckinStatsScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const CheckinStatsScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<CheckinStatsScreen> createState() => _CheckinStatsScreenState();
}

class _CheckinStatsScreenState extends State<CheckinStatsScreen> {
  final _client = Supabase.instance.client;

  bool _loading = true;
  int _totalPaid = 0;
  int _totalSuccess = 0;
  int _totalAlreadyScanned = 0;
  int _totalInvalid = 0;
  int _totalPaymentIssue = 0;

  // All paid attendees for this event
  List<Map<String, dynamic>> _attendees = [];
  // IDs of registrations that have a successful scan
  Set<String> _checkedInIds = {};

  List<Map<String, dynamic>> _recentScans = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        // All paid registrations for this event (with names)
        _client
            .from('event_registrations')
            .select('id, form_response')
            .eq('event_id', widget.eventId)
            .eq('payment_status', 'paid')
            .filter('deleted_at', 'is', null),

        // All scan attempts for this event
        _client
            .from('ticket_scans')
            .select('scan_result, registration_id')
            .eq('event_id', widget.eventId),

        // Recent 30 scans for this event
        _client
            .from('ticket_scans')
            .select('id, scan_result, scanned_at, scanner_email, registration_id, event_registrations(name)')
            .eq('event_id', widget.eventId)
            .order('scanned_at', ascending: false)
            .limit(30),
      ]);

      final paid = results[0] as List;
      final scans = results[1] as List;
      final recent = results[2] as List;

      final checkedInIds = scans
          .where((s) => s['scan_result'] == 'success')
          .map((s) => s['registration_id'] as String)
          .toSet();

      if (mounted) {
        setState(() {
          _totalPaid = paid.length;
          _totalSuccess = scans.where((s) => s['scan_result'] == 'success').length;
          _totalAlreadyScanned = scans.where((s) => s['scan_result'] == 'already_scanned').length;
          _totalInvalid = scans.where((s) => s['scan_result'] == 'invalid_ticket').length;
          _totalPaymentIssue = scans.where((s) => s['scan_result'] == 'payment_not_completed').length;
          _checkedInIds = checkedInIds;
          // Checked-in attendees first, then pending
          _attendees = [
            ...paid.where((r) => checkedInIds.contains(r['id'] as String)),
            ...paid.where((r) => !checkedInIds.contains(r['id'] as String)),
          ].map((r) => Map<String, dynamic>.from(r as Map)).toList();
          _recentScans = List<Map<String, dynamic>>.from(recent);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _getPersonName(Map<String, dynamic> reg) {
    final form = reg['form_response'] as Map?;
    final name = (form?['name'] ?? '').toString().trim();
    return name.isNotEmpty ? name : 'Unknown';
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]}, $h:$m';
    } catch (_) {
      return iso;
    }
  }

  String _getScanAttendeeName(Map<String, dynamic> scan) {
    final reg = scan['event_registrations'] as Map?;
    final raw = (reg?['name'] ?? '').toString().trim();
    return raw.isNotEmpty ? raw : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primary = const Color(0xFF2B8CEE);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final double checkinPct = _totalPaid > 0 ? _totalSuccess / _totalPaid : 0.0;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gate Entry Status',
                style: TextStyle(
                    color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.eventName,
                style: TextStyle(color: textMuted, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textMuted),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Progress card ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Checked In',
                                style: TextStyle(
                                    color: textMuted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            Text(
                              '${(checkinPct * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                  color: primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$_totalSuccess',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    height: 1)),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6, left: 6),
                              child: Text('/ $_totalPaid',
                                  style: TextStyle(
                                      color: textMuted,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: checkinPct.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation(primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_totalPaid total paid registrations for this event',
                          style: TextStyle(color: textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Stat chips ────────────────────────────────────────
                  Row(
                    children: [
                      _statChip(icon: Icons.check_circle_outline, label: 'Successful', count: _totalSuccess, color: Colors.green, cardColor: cardColor, borderColor: borderColor),
                      const SizedBox(width: 10),
                      _statChip(icon: Icons.warning_amber_rounded, label: 'Duplicate', count: _totalAlreadyScanned, color: Colors.orange, cardColor: cardColor, borderColor: borderColor),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _statChip(icon: Icons.credit_card_off_outlined, label: 'Unpaid', count: _totalPaymentIssue, color: Colors.redAccent, cardColor: cardColor, borderColor: borderColor),
                      const SizedBox(width: 10),
                      _statChip(icon: Icons.block, label: 'Invalid', count: _totalInvalid, color: Colors.grey, cardColor: cardColor, borderColor: borderColor),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Attendees section ─────────────────────────────────
                  Row(
                    children: [
                      Text('Attendees',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text('(${_attendees.length})',
                          style: TextStyle(color: textMuted, fontSize: 14)),
                      const Spacer(),
                      // Legend
                      _legendDot(Colors.green, 'In', textMuted),
                      const SizedBox(width: 10),
                      _legendDot(primary, 'Pending', textMuted),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_attendees.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Center(
                          child: Text('No attendees for this event.',
                              style: TextStyle(color: textMuted))),
                    )
                  else
                    ...(_attendees.map((reg) {
                      final regId = reg['id'] as String;
                      final isCheckedIn = _checkedInIds.contains(regId);
                      final name = _getPersonName(reg);
                      final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                      final statusColor = isCheckedIn ? Colors.green : primary;
                      final statusLabel = isCheckedIn ? 'Checked In' : 'Pending';
                      final statusIcon = isCheckedIn ? Icons.check_circle : Icons.schedule;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCheckedIn
                                ? Colors.green.withAlpha(80)
                                : borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: primary.withAlpha(25),
                              radius: 20,
                              child: Text(initial,
                                  style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(name,
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: statusColor.withAlpha(60), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon,
                                      color: statusColor, size: 12),
                                  const SizedBox(width: 4),
                                  Text(statusLabel,
                                      style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    })),

                  const SizedBox(height: 8),

                  // ── Recent Activity ───────────────────────────────────
                  Text('Recent Scan Activity',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  if (_recentScans.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                          child: Text('No scans yet for this event.',
                              style: TextStyle(color: textMuted))),
                    )
                  else
                    ...(_recentScans.map((scan) {
                      final result = scan['scan_result'] as String? ?? '';
                      final name = _getScanAttendeeName(scan);
                      final time = _formatTime(scan['scanned_at'] as String?);
                      final scannerEmail =
                          (scan['scanner_email'] as String? ?? '').trim();

                      final Color resultColor;
                      final IconData resultIcon;
                      final String resultLabel;

                      switch (result) {
                        case 'success':
                          resultColor = Colors.green;
                          resultIcon = Icons.check_circle;
                          resultLabel = 'Success';
                          break;
                        case 'already_scanned':
                          resultColor = Colors.orange;
                          resultIcon = Icons.warning_amber_rounded;
                          resultLabel = 'Duplicate';
                          break;
                        case 'payment_not_completed':
                          resultColor = Colors.redAccent;
                          resultIcon = Icons.credit_card_off_outlined;
                          resultLabel = 'Unpaid';
                          break;
                        default:
                          resultColor = Colors.grey;
                          resultIcon = Icons.block;
                          resultLabel = 'Invalid';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
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
                                color: resultColor.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(resultIcon,
                                  color: resultColor, size: 18),
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
                                  const SizedBox(height: 2),
                                  Text(
                                    scannerEmail.isNotEmpty
                                        ? '$time · $scannerEmail'
                                        : time,
                                    style: TextStyle(
                                        color: textMuted, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: resultColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(resultLabel,
                                  style: TextStyle(
                                      color: resultColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    })),
                ],
              ),
            ),
    );
  }

  Widget _legendDot(Color color, String label, Color textMuted) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count',
                    style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1)),
                Text(label,
                    style: TextStyle(
                        color: color.withAlpha(180),
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
