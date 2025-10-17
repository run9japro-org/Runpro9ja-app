import 'package:flutter/material.dart';
import 'package:runpro_9ja/services/customer_services.dart';
import '../../auth/Auth_services/auth_service.dart';

class AgentSelectionScreen extends StatefulWidget {
  final String orderId;
  final List<dynamic> recommendedAgents;
  final double? quotationAmount;
  final String? serviceType;

  const AgentSelectionScreen({
    super.key,
    required this.orderId,
    required this.recommendedAgents,
    required this.quotationAmount,
    this.serviceType,
  });

  @override
  State<AgentSelectionScreen> createState() => _AgentSelectionScreenState();
}

class _AgentSelectionScreenState extends State<AgentSelectionScreen> {
  late final CustomerService customerService;
  String? _selectedAgentId;
  bool _isSubmitting = false;
  bool _isLoading = true;
  List<dynamic> _availableAgents = [];

  @override
  void initState() {
    super.initState();
    customerService = CustomerService(AuthService());
    _fetchAvailableAgents();
  }

  Future<void> _fetchAvailableAgents() async {
    try {
      // If we have pre-recommended agents, use them
      if (widget.recommendedAgents.isNotEmpty) {
        setState(() {
          _availableAgents = widget.recommendedAgents;
          _isLoading = false;
        });
        return;
      }

      // Otherwise, fetch available agents based on service type
      final agents = await customerService.getRecommendedAgents(
        serviceType: widget.serviceType,
      );

      setState(() {
        _availableAgents = agents;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load agents: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectAgent() async {
    if (_selectedAgentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an agent')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await customerService.selectAgentAfterQuotation(
        orderId: widget.orderId,
        agentId: _selectedAgentId!,
      );

      if (!mounted) return;

      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Success')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
                  SizedBox(height: 20),
                  Text(
                    'Agent Selected Successfully!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Your service is now confirmed.'),
                ],
              ),
            ),
          ),
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select agent: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Professional'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with quotation info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.green[50],
              child: Column(
                children: [
                  const Text(
                    'Final Quotation',
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  Text(
                    '₦${widget.quotationAmount?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Choose your preferred professional:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            // Agents List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : _availableAgents.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No agents available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      'Please try again later',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _availableAgents.length,
                itemBuilder: (context, index) {
                  final agent = _availableAgents[index];
                  final isSelected = _selectedAgentId == agent['_id'];
                  final user = agent['user'] ?? {};
                  final rating = agent['rating'] ?? 0.0;
                  final completedJobs = agent['completedJobs'] ?? 0;
                  final isVerified = agent['isVerified'] ?? false;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isSelected ? Colors.green[50] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.green : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => setState(() => _selectedAgentId = agent['_id']),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        backgroundImage: agent['profileImage'] != null
                            ? NetworkImage(agent['profileImage'])
                            : null,
                        child: agent['profileImage'] == null
                            ? Icon(Icons.person, color: Colors.green[800])
                            : null,
                      ),
                      title: Row(
                        children: [
                          Text(
                            user['fullName'] ?? 'Unknown Agent',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified, size: 16, color: Colors.blue),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(rating.toStringAsFixed(1)),
                              const SizedBox(width: 8),
                              Icon(Icons.work, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('$completedJobs jobs'),
                            ],
                          ),
                          if (agent['serviceType'] != null)
                            Text(
                              agent['serviceType'],
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          if (agent['summary'] != null)
                            Text(
                              agent['summary'],
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  );
                },
              ),
            ),

            // Select Button
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _selectedAgentId == null ? null : _selectAgent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _selectedAgentId == null
                        ? 'Select Professional'
                        : 'Confirm Selection',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}