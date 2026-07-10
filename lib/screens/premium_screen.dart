import 'package:flutter/material.dart';
// built in ui widgets
import 'package:flutter_riverpod/flutter_riverpod.dart';
// riverpod state management
import 'package:qr_flutter/qr_flutter.dart';
// draws QR codes
import 'package:tpmentorship/providers/auth_provider.dart';
import 'package:tpmentorship/providers/data_providers.dart';
// the app's providers
import 'package:tpmentorship/theme/app_theme.dart';
// app colours and styling
import 'package:tpmentorship/utils/snackbar_helper.dart';
// helper to show popup messages

class PremiumScreen extends ConsumerStatefulWidget {
// additional feature: the NETS QR payment scenario from the proposal
// upgrading to TPMentorship Premium by scanning a NETS QR code
//
// the QR is generated with the payment details inside it - in a real
// deployment this payload would come from the NETS API, here the
// payment confirmation is simulated so no real money is involved

  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _verifying = false;
  // true while the pretend payment check is running

  // pretends to verify the payment, then unlocks premium in Firestore
  Future<void> _confirmPayment() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _verifying = true);
    // show the spinner on the button

    // simulate the delay of a real payment gateway checking the payment
    await Future.delayed(const Duration(seconds: 2));

    try {
      await ref.read(userServiceProvider).upgradeToPremium(user.uid);
      // flip isPremium to true in the user's firestore profile

      if (!mounted) return;
      // success dialog (feedback: AlertDialog)
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppTheme.darkCardBg,
          title: Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber),
              SizedBox(width: 8),
              Text('Welcome to Premium!',
                  style: TextStyle(
                      color: AppTheme.textPrimary, fontSize: 18)),
            ],
          ),
          content: Text(
            'Payment received. You now get priority booking and '
            'instant messaging with mentors.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Nice!',
                  style: TextStyle(
                      color: AppTheme.tpRed,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
      // leave the premium screen - the profile updates by itself
      // because the user profile is a live stream
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Payment could not be confirmed. Try again.');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    // whats inside the QR: the pretend NETS payment payload
    final qrData = 'NETSQR|TPMENTORSHIP|SGD2.99|${user?.uid ?? 'guest'}';

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Go Premium')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ----- what you get -----
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCardBg,
                  border: Border.all(color: AppTheme.darkBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'TPMentorship Premium',
                          style: TextStyle(
                            color: AppTheme.tpRed,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.workspace_premium,
                            color: Colors.amber, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$2.99/month - first time purchase gets +3 months free',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    _benefit('Priority when booking sessions'),
                    _benefit('Instant messages without needing to book'),
                    _benefit('Support student mentors on the platform'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ----- the NETS QR code -----
              Text(
                'Scan with your banking app to pay via NETS',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // QR codes need a white background to scan reliably
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // the NETS brand strip above the code
                      const Text(
                        'NETS QR',
                        style: TextStyle(
                          color: Color(0xFF003087),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      QrImageView(
                        data: qrData,
                        // the payment payload drawn as a QR code
                        size: 190,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SGD 2.99',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ----- confirm button with loading spinner -----
              ElevatedButton(
                onPressed: _verifying ? null : _confirmPayment,
                // disabled while checking so it cant be tapped twice
                child: _verifying
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          ),
                          SizedBox(width: 10),
                          Text('Verifying payment...'),
                        ],
                      )
                    : const Text("I've paid - verify my payment"),
              ),
              const SizedBox(height: 8),
              Text(
                'Demo mode: no real payment is made',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // one green-ticked benefit line
  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
