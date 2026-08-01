import 'package:flutter/material.dart';
import 'dart:async'; // Required for Future.delayed
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Required for Riverpod state management

// Define an enum to manage the different states of the payment process
enum PaymentStatus {
  initial,
  processing,
  confirmed,
  failed,
}

/// Data model for managing the payment process state.
/// This class extends ChangeNotifier to notify listeners of state changes.
class PaymentData extends ChangeNotifier {
  PaymentStatus _currentStatus = PaymentStatus.initial;

  PaymentStatus get currentStatus => _currentStatus;

  /// Simulates a payment request.
  /// Sets the status to processing, then simulates a delay and a random outcome.
  Future<void> initiatePayment() async {
    // If the status is already processing, no need to set again or notify, just proceed.
    // This prevents redundant notifications if called multiple times while already processing.
    if (_currentStatus != PaymentStatus.processing) {
      _currentStatus = PaymentStatus.processing;
      notifyListeners();
    }

    // Simulate a network delay for payment processing
    await Future.delayed(const Duration(seconds: 3));

    // Simulate payment outcome (e.g., 80% success rate)
    final bool paymentSuccessful = DateTime.now().second % 5 != 0; // Simple random success/fail

    if (paymentSuccessful) {
      _currentStatus = PaymentStatus.confirmed;
    } else {
      _currentStatus = PaymentStatus.failed;
    }
    notifyListeners();
  }

  /// Sets the payment status to processing explicitly.
  void setProcessing() {
    _currentStatus = PaymentStatus.processing;
    notifyListeners();
  }

  /// Resets the payment status to initial.
  void resetPayment() {
    _currentStatus = PaymentStatus.initial;
    notifyListeners();
  }
}

// Define a Riverpod ChangeNotifierProvider for PaymentData
final paymentProvider = ChangeNotifierProvider<PaymentData>((ref) {
  return PaymentData();
});

void main() {
  runApp(
    // Wrap the entire app with ProviderScope to make Riverpod available
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  void _openPaymentModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // Allows the modal to take full height if needed
      builder: (BuildContext context) {
        return const PaymentFlowContent();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Application'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the Payment Application!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                final PaymentData paymentData = ref.read(paymentProvider);
                paymentData.resetPayment(); // Ensure we start fresh
                paymentData.setProcessing(); // Set status to processing immediately before opening modal
                _openPaymentModal(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Initiate Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A modal content widget that displays the payment flow.
/// It uses ConsumerStatefulWidget to react to PaymentData changes and trigger actions.
class PaymentFlowContent extends ConsumerStatefulWidget {
  const PaymentFlowContent({super.key});

  @override
  ConsumerState<PaymentFlowContent> createState() => _PaymentFlowContentState();
}

class _PaymentFlowContentState extends ConsumerState<PaymentFlowContent> {
  @override
  Widget build(BuildContext context) {
    // Listen for state changes, specifically when it becomes 'processing'
    // This will trigger whenever the currentStatus changes, initiating the payment API call.
    ref.listen<PaymentStatus>(
      paymentProvider.select((PaymentData data) => data.currentStatus),
          (PaymentStatus? previousStatus, PaymentStatus newStatus) {
        if (newStatus == PaymentStatus.processing) {
          // Use ref.read to access the PaymentData instance without watching it here
          final PaymentData paymentData = ref.read(paymentProvider);
          paymentData.initiatePayment();
        }
      },
    );

    // Watch the paymentProvider to rebuild when PaymentData changes
    final PaymentData paymentData = ref.watch(paymentProvider);
    final PaymentStatus currentStatus = paymentData.currentStatus;

    Widget contentWidget;
    switch (currentStatus) {
      case PaymentStatus.initial:
        contentWidget = PaymentInitialContent(paymentData: paymentData);
        break;
      case PaymentStatus.processing:
        contentWidget = const PaymentProcessingContent();
        break;
      case PaymentStatus.confirmed:
        contentWidget = PaymentConfirmedContent(paymentData: paymentData);
        break;
      case PaymentStatus.failed:
        contentWidget = PaymentFailedContent(paymentData: paymentData);
        break;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: contentWidget,
          ),
        ),
      ),
    );
  }
}

/// Widget to display content for PaymentStatus.initial.
class PaymentInitialContent extends StatelessWidget {
  final PaymentData paymentData;
  const PaymentInitialContent({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blueGrey),
        const SizedBox(height: 20),
        const Text(
          'Ready for your next payment?',
          style: TextStyle(fontSize: 20, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            // Set status to processing, which will trigger initiatePayment via ref.listen in parent
            paymentData.setProcessing();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text('Start New Payment'),
        ),
      ],
    );
  }
}

/// Widget to display content for PaymentStatus.processing.
class PaymentProcessingContent extends StatelessWidget {
  const PaymentProcessingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        CircularProgressIndicator(strokeWidth: 5),
        SizedBox(height: 30),
        Text(
          'Waiting for payment confirmation...',
          style: TextStyle(fontSize: 22, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Widget to display content for PaymentStatus.confirmed.
class PaymentConfirmedContent extends StatelessWidget {
  final PaymentData paymentData;
  const PaymentConfirmedContent({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.check_circle_outline,
          size: 150,
          color: Colors.green,
        ),
        const SizedBox(height: 20),
        const Text(
          'Payment Confirmed!',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            paymentData.resetPayment(); // Reset to initial state
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
          child: const Text('Make another payment'),
        ),
      ],
    );
  }
}

/// Widget to display content for PaymentStatus.failed.
class PaymentFailedContent extends StatelessWidget {
  final PaymentData paymentData;
  const PaymentFailedContent({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(Icons.error_outline, size: 80, color: Colors.red),
        const SizedBox(height: 20),
        const Text(
          'Payment Failed!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Please try again or contact support.',
          style: TextStyle(fontSize: 18, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            paymentData.resetPayment(); // Reset to initial state
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
          child: const Text('Try Again'),
        ),
      ],
    );
  }
}