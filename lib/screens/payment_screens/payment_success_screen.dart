// lib/screens/payment/payment_success_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String agentId;

  const PaymentSuccessScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.agentId,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  final DateTime now = DateTime.now();

  double get agentShare => widget.amount * 0.8;
  double get companyShare => widget.amount * 0.2;

  Future<void> _saveReceipt() async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _showSnackBar('Storage permission required to save receipt');
        return;
      }

      // Create receipt content
      final receiptContent = '''
RUNPRO9JA PAYMENT RECEIPT
========================

Order ID: #${widget.orderId}
Date: ${_formatDate(now)}
Time: ${_formatTime(now)}
Status: COMPLETED

PAYMENT DETAILS:
----------------
Total Amount: ₦${widget.amount.toStringAsFixed(2)}
Agent Share (80%): ₦${agentShare.toStringAsFixed(2)}
Platform Fee (20%): ₦${companyShare.toStringAsFixed(2)}

AGENT ID: ${widget.agentId}

Thank you for your payment!
For inquiries, contact support@runpro9ja.com

Refund Policy: Payments are refundable within 7 days for service-related issues.
      ''';

      // Get directory and create file
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory?.path}/RunPro9ja_Receipt_${widget.orderId}.txt';
      final file = File(filePath);

      await file.writeAsString(receiptContent);

      // Share the receipt
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'RunPro9ja Payment Receipt - Order #${widget.orderId}',
        subject: 'Payment Receipt from RunPro9ja',
      );

      _showSnackBar('Receipt saved and shared successfully!');

    } catch (e) {
      _showSnackBar('Failed to save receipt: $e');
    }
  }

  void _showRefundPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.policy, color: Colors.blue),
            SizedBox(width: 8),
            Text('Refund Policy'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPolicySection(
                  'Eligibility for Refunds',
                  '• Service not rendered within agreed timeframe\n• Technical issues preventing service delivery\n• Agent cancellation after payment\n• Duplicate payments'
              ),
              const SizedBox(height: 16),
              _buildPolicySection(
                  'Refund Timeframe',
                  '• Refund requests must be made within 7 days of payment\n• Processing time: 3-5 business days\n• Refunds will be issued to original payment method'
              ),
              const SizedBox(height: 16),
              _buildPolicySection(
                  'Non-Refundable Cases',
                  '• Services already completed\n• User cancellation after agent assignment\n• Issues not reported within 24 hours\n• Force majeure events'
              ),
              const SizedBox(height: 16),
              _buildPolicySection(
                  'How to Request Refund',
                  '1. Contact support@runpro9ja.com\n2. Provide order ID and reason\n3. Submit supporting evidence\n4. Allow 24-48 hours for response'
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Optionally navigate to support
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isSuccess ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Receipt has been generated. You can save it for your records.',
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 50,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 32),

              // Success Message
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Amount
              Text(
                '₦${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Order ID
              Text(
                'Order #${widget.orderId}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Payment Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Payment Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBreakdownRow('Total Amount', '₦${widget.amount.toStringAsFixed(2)}'),
                    _buildBreakdownRow('Agent (80%)', '₦${agentShare.toStringAsFixed(2)}'),
                    _buildBreakdownRow('Platform Fee (20%)', '₦${companyShare.toStringAsFixed(2)}'),
                    const Divider(height: 20),
                    _buildBreakdownRow('Date', '${_formatDate(now)}'),
                    _buildBreakdownRow('Time', '${_formatTime(now)}'),
                    _buildBreakdownRow('Status', 'Completed', isSuccess: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Additional Information
              _buildInfoCard(),
              const SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveReceipt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.receipt),

                      label: const Text(
                        'Save Receipt',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/main');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // Navigate to order details
                          },
                          child: const Text(
                            'View Order Details',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _showRefundPolicy,
                        child: const Text(
                          'Refund Policy',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}