import 'package:flutter/material.dart';
import 'package:runpro_9ja/services/customer_services.dart';
import 'package:runpro_9ja/screens/professional_services/agent_selection_screen.dart';
import '../../auth/Auth_services/auth_service.dart';

class QuotationAcceptanceScreen extends StatefulWidget {
  final String orderId;
  final double? quotationAmount;
  final String? quotationDetails;
  final List<dynamic> recommendedAgents;
  final String serviceType; // Add this

  const QuotationAcceptanceScreen({
    super.key,
    required this.orderId,
    required this.quotationAmount,
    required this.quotationDetails,
    required this.recommendedAgents,
    required this.serviceType, // Add this
  });

  @override
  State<QuotationAcceptanceScreen> createState() => _QuotationAcceptanceScreenState();
}
class _QuotationAcceptanceScreenState extends State<QuotationAcceptanceScreen> {
  late final CustomerService customerService;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    customerService = CustomerService(AuthService());
  }

  Future<void> _acceptQuotation() async {
    setState(() => _isAccepting = true);

    try {
      await customerService.acceptQuotation(widget.orderId);

      if (!mounted) return;

      // Navigate to agent selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AgentSelectionScreen(
            orderId: widget.orderId,
            recommendedAgents: widget.recommendedAgents,
            quotationAmount: widget.quotationAmount,
          ),
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept quotation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  void _rejectQuotation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Quotation?'),
        content: const Text('Are you sure you want to reject this quotation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to waiting screen
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Quotation'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quotation Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Quotation Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₦${widget.quotationAmount?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quotation Details
              if (widget.quotationDetails != null) ...[
                const Text(
                  'Quotation Details:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(widget.quotationDetails!),
                ),
                const SizedBox(height: 16),
              ],

              // Recommended Agents Info
              if (widget.recommendedAgents.isNotEmpty) ...[
                const Text(
                  'Recommended Professionals:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.recommendedAgents.length} professional(s) recommended for this service',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],

              const Spacer(),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAccepting ? null : _acceptQuotation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isAccepting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Accept Quotation & Choose Agent',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _rejectQuotation,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Reject Quotation',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
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