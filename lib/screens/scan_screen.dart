import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_state.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

enum _ScanResultType { success, alreadyScanned, paymentNotCompleted, invalid }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  final _client = Supabase.instance.client;

  bool _isProcessing = false;
  bool _isLoading = false;
  String? _lastScanned;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.start();
    }
  }

  void _onQRDetected(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue == _lastScanned) return;

    setState(() {
      _isProcessing = true;
      _lastScanned = rawValue;
    });
    _controller.stop();
    _processTicket(rawValue);
  }

  Future<void> _processTicket(String rawValue) async {
    setState(() => _isLoading = true);

    // ── 1. Parse QR ──────────────────────────────────────────────────────
    Map<String, dynamic> qr;
    try {
      qr = jsonDecode(rawValue) as Map<String, dynamic>;
    } catch (_) {
      // Not JSON — try treating as a bare registration UUID
      qr = {'id': rawValue.trim()};
    }

    final registrationId = qr['id']?.toString().trim() ?? '';
    final qrAttendeeName = qr['name']?.toString().trim() ?? '';
    final qrEventName = qr['event']?.toString().trim() ?? '';

    if (registrationId.isEmpty) {
      setState(() => _isLoading = false);
      _showResultSheet(_ScanResultType.invalid, '', '', null);
      return;
    }

    // ── 2. Fetch registration ────────────────────────────────────────────
    try {
      final reg = await _client
          .from('event_registrations')
          .select('id, event_id, payment_status, deleted_at')
          .eq('id', registrationId)
          .maybeSingle();

      if (reg == null || reg['deleted_at'] != null) {
        await _insertScan(
          registrationId: registrationId,
          eventId: null,
          result: 'invalid_ticket',
        );
        setState(() => _isLoading = false);
        _showResultSheet(_ScanResultType.invalid, qrAttendeeName, qrEventName, null);
        return;
      }

      // ── 3. Check payment ───────────────────────────────────────────────
      if (reg['payment_status'] != 'paid') {
        await _insertScan(
          registrationId: registrationId,
          eventId: reg['event_id'] as String?,
          result: 'payment_not_completed',
        );
        setState(() => _isLoading = false);
        _showResultSheet(_ScanResultType.paymentNotCompleted, qrAttendeeName, qrEventName, null);
        return;
      }

      // ── 4. Check duplicate scan ────────────────────────────────────────
      final existing = await _client
          .from('ticket_scans')
          .select('scanned_at')
          .eq('registration_id', registrationId)
          .eq('scan_result', 'success')
          .order('scanned_at', ascending: true)
          .limit(1)
          .maybeSingle();

      if (existing != null) {
        await _insertScan(
          registrationId: registrationId,
          eventId: reg['event_id'] as String?,
          result: 'already_scanned',
        );
        setState(() => _isLoading = false);
        _showResultSheet(
          _ScanResultType.alreadyScanned,
          qrAttendeeName,
          qrEventName,
          existing['scanned_at'] as String?,
        );
        return;
      }

      // ── 5. Success ─────────────────────────────────────────────────────
      await _insertScan(
        registrationId: registrationId,
        eventId: reg['event_id'] as String?,
        result: 'success',
      );
      setState(() => _isLoading = false);
      _showResultSheet(_ScanResultType.success, qrAttendeeName, qrEventName, null);
    } catch (e) {
      setState(() => _isLoading = false);
      _showResultSheet(_ScanResultType.invalid, qrAttendeeName, 'Error: $e', null);
    }
  }

  Future<void> _insertScan({
    required String registrationId,
    String? eventId,
    required String result,
  }) async {
    try {
      final payload = <String, dynamic>{
        'registration_id': registrationId,
        'scan_result': result,
        'scanner_email': AppState.instance.loggedInEmail ?? '',
        'device_info': 'Flutter App',
      };
      if (eventId != null) payload['event_id'] = eventId;
      await _client.from('ticket_scans').insert(payload);
    } catch (_) {
      // Swallow — don't block the UI result
    }
  }

  void _resumeScanner() {
    setState(() {
      _isProcessing = false;
      _isLoading = false;
      _lastScanned = null;
    });
    _controller.start();
  }

  void _showResultSheet(
    _ScanResultType type,
    String attendeeName,
    String eventName,
    String? firstScannedAt,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final Color accent;
    final IconData icon;
    final String title;
    final String subtitle;

    switch (type) {
      case _ScanResultType.success:
        accent = Colors.green;
        icon = Icons.check_circle;
        title = 'Check-in Successful';
        subtitle = attendeeName.isNotEmpty ? attendeeName : 'Ticket verified';
        break;
      case _ScanResultType.alreadyScanned:
        accent = Colors.orange;
        icon = Icons.warning_amber_rounded;
        title = 'Already Checked In';
        subtitle = attendeeName.isNotEmpty ? attendeeName : 'This ticket was used before';
        break;
      case _ScanResultType.paymentNotCompleted:
        accent = Colors.redAccent;
        icon = Icons.credit_card_off_outlined;
        title = 'Payment Incomplete';
        subtitle = attendeeName.isNotEmpty ? attendeeName : 'Payment not confirmed';
        break;
      case _ScanResultType.invalid:
        accent = const Color(0xFF64748B);
        icon = Icons.block;
        title = 'Invalid Ticket';
        subtitle = 'This QR code is not recognised';
        break;
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Result icon with colored ring
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: accent.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 48),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
            const SizedBox(height: 6),

            // Attendee name / subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),

            // Event name
            if (eventName.isNotEmpty && type != _ScanResultType.invalid) ...[
              const SizedBox(height: 4),
              Text(
                eventName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // First scanned at (for duplicate)
            if (type == _ScanResultType.alreadyScanned && firstScannedAt != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      'First scanned: ${_formatTime(firstScannedAt)}',
                      style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Scan Again button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _resumeScanner();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'Scan Next Ticket',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      if (_isProcessing) _resumeScanner();
    });
  }

  String _formatTime(String iso) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primaryColor = const Color(0xFF2B8CEE);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan Ticket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on : Icons.flash_off,
              color: _torchOn ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              setState(() => _torchOn = !_torchOn);
              _controller.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onQRDetected,
          ),

          CustomPaint(
            painter: _ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),

          Positioned(
            top: 130,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Align QR code within the frame',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),

          // Loading overlay while querying DB
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Verifying ticket...',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

          // Manual Entry
          if (!_isLoading)
            Positioned(
              bottom: 90,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: _showManualEntry,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.keyboard, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Enter Ticket ID Manually',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
                _buildNavItem(context, Icons.dashboard, 'Dashboard', false,
                    primaryColor, const DashboardScreen()),
                _buildNavItem(context, Icons.qr_code_scanner, 'Scan', true,
                    primaryColor, null),
                _buildNavItem(context, Icons.person, 'Profile', false,
                    primaryColor, const ProfileScreen()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Manual entry input type detection ──────────────────────────────────

  bool _isUUID(String s) => RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(s);

  bool _isTKTRef(String s) =>
      s.toUpperCase().startsWith('TKT-') && s.length > 4;

  bool _isPhone(String s) => RegExp(r'^\+?\d{7,15}$').hasMatch(s);

  // Short code: hex suffix from ticket name e.g. "b28f441d-ba1" or just "ba1"
  bool _isShortCode(String s) =>
      RegExp(r'^[0-9a-fA-F]{3,12}(-[0-9a-fA-F]{3})?$').hasMatch(s);

  // ── Lookup from manual input ─────────────────────────────────────────────

  Future<void> _lookupByManualInput(String raw) async {
    final input = raw.trim();
    setState(() {
      _isProcessing = true;
      _isLoading = true;
      _lastScanned = input;
    });

    const cols =
        'id, form_response, event_id, payment_status, deleted_at, events(name, city)';

    try {
      List<Map<String, dynamic>> matches = [];

      if (_isUUID(input)) {
        final r = await _client
            .from('event_registrations')
            .select(cols)
            .eq('id', input)
            .eq('payment_status', 'paid')
            .maybeSingle();
        if (r != null) matches = [Map<String, dynamic>.from(r)];
      } else if (_isTKTRef(input)) {
        final prefix = input.substring(4).toLowerCase();
        final r = await _client
            .from('event_registrations')
            .select(cols)
            .ilike('id', '$prefix%')
            .eq('payment_status', 'paid')
            .limit(5);
        matches = List<Map<String, dynamic>>.from(r);
      } else if (_isPhone(input)) {
        // Try all three phone field names in parallel
        final futures = await Future.wait([
          _client.from('event_registrations').select(cols)
              .filter('form_response->>phone', 'ilike', '%$input%')
              .eq('payment_status', 'paid').limit(5),
          _client.from('event_registrations').select(cols)
              .filter('form_response->>whatsapp_number', 'ilike', '%$input%')
              .eq('payment_status', 'paid').limit(5),
          _client.from('event_registrations').select(cols)
              .filter('form_response->>mobile_number', 'ilike', '%$input%')
              .eq('payment_status', 'paid').limit(5),
        ]);
        final seen = <String>{};
        for (final list in futures) {
          for (final r in list as List) {
            final id = r['id'] as String;
            if (seen.add(id)) matches.add(Map<String, dynamic>.from(r));
          }
        }
      } else if (_isShortCode(input)) {
        final r = await _client
            .from('event_registrations')
            .select(cols)
            .ilike('name', '%-$input')
            .eq('payment_status', 'paid')
            .limit(5);
        matches = List<Map<String, dynamic>>.from(r);
      } else {
        // Fallback: name search
        final r = await _client
            .from('event_registrations')
            .select(cols)
            .filter('form_response->>name', 'ilike', '%$input%')
            .eq('payment_status', 'paid')
            .limit(8);
        matches = List<Map<String, dynamic>>.from(r);
      }

      setState(() => _isLoading = false);

      if (matches.isEmpty) {
        _showNotFoundSheet(input);
      } else if (matches.length == 1) {
        _showConfirmationSheet(matches.first);
      } else {
        _showPickerSheet(matches);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showNotFoundSheet(input);
    }
  }

  // ── Confirmation sheet ───────────────────────────────────────────────────

  void _showConfirmationSheet(Map<String, dynamic> reg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const primary = Color(0xFF2B8CEE);

    final form = reg['form_response'] as Map? ?? {};
    final name = (form['name'] ?? '').toString().trim();
    final phone = (form['phone'] ?? form['whatsapp_number'] ?? form['mobile_number'] ?? '').toString().trim();
    final email = (form['email'] ?? '').toString().trim();
    final event = reg['events'] as Map?;
    final eventName = (event?['name'] ?? '').toString().trim();
    final city = (event?['city'] ?? '').toString().trim();
    final regId = reg['id'] as String;
    final ticketRef = 'TKT-${regId.substring(0, 8).toUpperCase()}';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
            // Handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),

            // Question header
            Text('Is this the right person?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            const SizedBox(height: 4),
            Text('Please confirm the details below before checking in.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textMuted)),
            const SizedBox(height: 20),

            // Attendee card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primary.withAlpha(25),
                    radius: 28,
                    child: Text(initial,
                        style: const TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name.isNotEmpty ? name : 'Unknown',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        if (eventName.isNotEmpty)
                          _confirmRow(Icons.event, eventName, textMuted),
                        if (city.isNotEmpty)
                          _confirmRow(Icons.location_on, city, textMuted),
                        if (phone.isNotEmpty)
                          _confirmRow(Icons.phone, phone, textMuted),
                        if (email.isNotEmpty)
                          _confirmRow(Icons.email_outlined, email, textMuted),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(ticketRef,
                              style: const TextStyle(
                                  color: primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Yes button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _processTicket(regId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Yes, Check In This Person',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Not this person button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _resumeScanner();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Not This Person',
                    style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      if (_isProcessing && _isLoading == false) _resumeScanner();
    });
  }

  Widget _confirmRow(IconData icon, String text, Color textMuted) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 12, color: textMuted),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                style: TextStyle(color: textMuted, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // ── Picker sheet (multiple matches) ─────────────────────────────────────

  void _showPickerSheet(List<Map<String, dynamic>> matches) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const primary = Color(0xFF2B8CEE);
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Multiple Matches Found',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            const SizedBox(height: 4),
            Text('Select the correct person to continue.',
                style: TextStyle(fontSize: 13, color: textMuted)),
            const SizedBox(height: 16),
            ...matches.map((reg) {
              final form = reg['form_response'] as Map? ?? {};
              final name = (form['name'] ?? '').toString().trim();
              final phone = (form['phone'] ??
                      form['whatsapp_number'] ??
                      form['mobile_number'] ??
                      '')
                  .toString()
                  .trim();
              final event = reg['events'] as Map?;
              final eventName = (event?['name'] ?? '').toString().trim();
              final regId = reg['id'] as String;
              final ticketRef = 'TKT-${regId.substring(0, 8).toUpperCase()}';
              final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

              return GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _showConfirmationSheet(reg);
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
                      CircleAvatar(
                        backgroundColor: primary.withAlpha(25),
                        radius: 20,
                        child: Text(initial,
                            style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name.isNotEmpty ? name : 'Unknown',
                                style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            if (eventName.isNotEmpty)
                              Text(eventName,
                                  style:
                                      TextStyle(color: textMuted, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            if (phone.isNotEmpty)
                              Text(phone,
                                  style:
                                      TextStyle(color: textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(ticketRef,
                              style: TextStyle(
                                  color: textMuted,
                                  fontSize: 10,
                                  fontFamily: 'monospace')),
                          const SizedBox(height: 4),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFF2B8CEE), size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _resumeScanner();
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      if (_isProcessing && !_isLoading) _resumeScanner();
    });
  }

  // ── Not found sheet ──────────────────────────────────────────────────────

  void _showNotFoundSheet(String input) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: Colors.redAccent, size: 44),
            ),
            const SizedBox(height: 16),
            Text('No Ticket Found',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            const SizedBox(height: 8),
            Text(
              'No paid registration matched "$input".\n\nAccepted formats: ticket UUID, TKT-XXXXXXXX, short code (e.g. ba1), phone number, or name.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: textMuted, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _resumeScanner();
                  Future.delayed(
                      const Duration(milliseconds: 300), _showManualEntry);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B8CEE),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Try Again',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _resumeScanner();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() => _resumeScanner());
  }

  // ── Manual entry sheet ───────────────────────────────────────────────────

  void _showManualEntry() {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Manual Ticket Lookup',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Enter any of the following:',
                  style: TextStyle(fontSize: 13, color: textMuted)),
              const SizedBox(height: 8),
              // Accepted formats hint chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _hintChip('Ticket UUID', textMuted, isDark),
                  _hintChip('TKT-XXXXXXXX', textMuted, isDark),
                  _hintChip('Short code (ba1)', textMuted, isDark),
                  _hintChip('Phone number', textMuted, isDark),
                  _hintChip('Attendee name', textMuted, isDark),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. ba1 · TKT-113B97FB · 9876543210 · Hamzaan',
                  hintStyle: TextStyle(fontSize: 13, color: textMuted),
                  filled: true,
                  fillColor: isDark ? Colors.black26 : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final val = controller.text.trim();
                    if (val.isNotEmpty) {
                      Navigator.pop(ctx);
                      _lookupByManualInput(val);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B8CEE),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Find Ticket',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hintChip(String label, Color textMuted, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: textMuted,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    Color primaryColor,
    Widget? targetScreen,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isActive && targetScreen != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
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
              color: isActive ? primaryColor.withAlpha(50) : Colors.transparent,
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
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const boxSize = 260.0;
    final left = (size.width - boxSize) / 2;
    final top = (size.height - boxSize) / 2;
    final rect = Rect.fromLTWH(left, top, boxSize, boxSize);

    final overlayPaint = Paint()..color = Colors.black.withAlpha(140);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    const bracketLen = 28.0;
    const bracketThick = 4.0;
    final bracketPaint = Paint()
      ..color = const Color(0xFF2B8CEE)
      ..strokeWidth = bracketThick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(left, top + bracketLen), Offset(left, top), bracketPaint);
    canvas.drawLine(Offset(left, top), Offset(left + bracketLen, top), bracketPaint);
    canvas.drawLine(Offset(left + boxSize - bracketLen, top), Offset(left + boxSize, top), bracketPaint);
    canvas.drawLine(Offset(left + boxSize, top), Offset(left + boxSize, top + bracketLen), bracketPaint);
    canvas.drawLine(Offset(left, top + boxSize - bracketLen), Offset(left, top + boxSize), bracketPaint);
    canvas.drawLine(Offset(left, top + boxSize), Offset(left + bracketLen, top + boxSize), bracketPaint);
    canvas.drawLine(Offset(left + boxSize - bracketLen, top + boxSize), Offset(left + boxSize, top + boxSize), bracketPaint);
    canvas.drawLine(Offset(left + boxSize, top + boxSize - bracketLen), Offset(left + boxSize, top + boxSize), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
