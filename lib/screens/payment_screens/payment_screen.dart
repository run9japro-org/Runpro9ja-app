// lib/screens/payment/payment_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import '../../auth/Auth_services/auth_service.dart';
import '../../services/payment_service.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String agentId;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.agentId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController controller;
  late final PaymentService _paymentService;
  bool _isLoading = true;
  bool _paymentInitialized = false;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(AuthService());
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      print('💰 Initializing payment for order: ${widget.orderId}');

      final paymentData = await _paymentService.initializePayment(
        orderId: widget.orderId,
        amount: widget.amount,
        agentId: widget.agentId,
      );

      if (paymentData['success'] == true) {
        final authorizationUrl = paymentData['authorizationUrl'];
        final reference = paymentData['reference'];

        print('✅ Payment initialized. Authorization URL: $authorizationUrl');
        print('✅ Payment reference: $reference');

        setState(() {
          _paymentInitialized = true;
        });

        controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                print('Loading: $progress%');
              },
              onPageStarted: (String url) {
                setState(() => _isLoading = true);
              },
              onPageFinished: (String url) {
                setState(() => _isLoading = false);
                print('Page finished loading: $url');
                _handlePaymentCallback(url);
              },
              onWebResourceError: (WebResourceError error) {
                print('WebView error: ${error.description}');
                if (!_paymentCompleted) {
                  _showError('Payment page loading failed: ${error.description}');
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                print('Navigation to: ${request.url}');
                _handlePaymentCallback(request.url);
                return NavigationDecision.navigate;
              },
              onUrlChange: (UrlChange change) {
                print('URL changed to: ${change.url}');
                _handlePaymentCallback(change.url ?? '');
              },
            ),
          )
          ..loadRequest(Uri.parse(authorizationUrl));
      } else {
        throw Exception('Failed to initialize payment');
      }
    } catch (e) {
      print('❌ Payment initialization error: $e');
      _showError('Payment initialization failed: $e');
    }
  }

  void _handlePaymentCallback(String url) {
    if (_paymentCompleted) return; // Prevent multiple calls

    print('🔄 Handling payment callback: $url');

    // Check for Paystack success URLs
    if (url.contains('callback') &&
        (url.contains('success') || url.contains('reference=') || url.contains('trxref='))) {

      print('✅ Payment completion callback detected');

      final uri = Uri.parse(url);
      final reference = uri.queryParameters['trxref'] ?? uri.queryParameters['reference'];

      if (reference != null) {
        print('🔍 Extracted reference: $reference');
        _verifyPaymentWithReference(reference);
      } else {
        // If no reference, check with backend
        _checkPaymentStatusWithBackend();
      }
    }

    // Check for failure URLs
    if (url.contains('failed') || url.contains('error=true')) {
      print('❌ Payment failure detected');
      _showError('Payment was cancelled or failed. Please try again.');
    }
  }

  Future<void> _verifyPaymentWithReference(String reference) async {
    try {
      print('🔍 Verifying payment with reference: $reference');

      setState(() {
        _isLoading = true;
      });

      final verificationResult = await _paymentService.verifyPayment(reference);

      setState(() {
        _isLoading = false;
      });

      if (verificationResult['success'] == true) {
        print('✅ Payment verified successfully!');
        _paymentCompleted = true;
        _showSuccess();
      } else {
        print('❌ Payment verification failed: ${verificationResult['message']}');
        _showError('Payment failed: ${verificationResult['message']}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Payment verification error: $e');
      // Fallback to backend check
      _checkPaymentStatusWithBackend();
    }
  }

  Future<void> _checkPaymentStatusWithBackend() async {
    try {
      print('🔍 Checking payment status with backend for order: ${widget.orderId}');

      setState(() {
        _isLoading = true;
      });

      // Try to get order details to check payment status
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('https://runpro9ja-backend.onrender.com/api/orders/${widget.orderId}'),
        headers: headers,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final orderData = json.decode(response.body);
        final order = orderData['order'];
        final paymentStatus = order['paymentStatus'];
        final status = order['status'];

        print('📊 Order status: $status, Payment status: $paymentStatus');

        if (paymentStatus == 'paid' || paymentStatus == 'completed' || status == 'confirmed') {
          _paymentCompleted = true;
          _showSuccess();
        } else {
          _showError('Payment is still pending. Please check your email for confirmation.');
        }
      } else {
        _showError('Unable to verify payment status. Please check your email for confirmation.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Backend status check error: $e');
      _showError('Payment status verification failed. Please check your email for confirmation.');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _showSuccess() {
    _paymentCompleted = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          orderId: widget.orderId,
          amount: widget.amount,
          agentId: widget.agentId,
        ),
      ),
    );
  }

  void _showError(String message) {
    if (_paymentCompleted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Status'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close payment screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelPayment() async {
    try {
      print('🚫 Cancelling payment for order: ${widget.orderId}');

      setState(() {
        _isLoading = true;
      });

      // Call backend to cancel payment
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('https://runpro9ja-pxqoa.ondigitalocean.app/api/payments/${widget.orderId}/cancel'),
        headers: headers,
        body: json.encode({
          'cancelledBy': 'user',
          'reason': 'User cancelled payment process',
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        print('✅ Payment cancelled successfully');
        _showCancellationSuccess();
      } else {
        print('❌ Payment cancellation failed: ${response.statusCode}');
        _showCancellationError('Failed to cancel payment. Please contact support.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Payment cancellation error: $e');
      _showCancellationError('Cancellation failed: $e');
    }
  }

  void _showCancellationSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Payment Cancelled'),
          ],
        ),
        content: const Text('Your payment has been successfully cancelled. No amount was deducted from your account.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close payment screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCancellationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.orange),
            SizedBox(width: 8),
            Text('Cancellation Status'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close payment screen
            },
            child: const Text('Exit Anyway', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

// Update the _showExitConfirmation method

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button during payment
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitConfirmation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Secure Payment'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showExitConfirmation,
          ),
        ),
        body: !_paymentInitialized
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing payment...'),
            ],
          ),
        )
            : Stack(
          children: [
            WebViewWidget(controller: controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    if (_paymentCompleted) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Payment'),
          ),
          TextButton(
            onPressed: () {
              _cancelPayment();
            },
            child: const Text('Cancel Payment', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}