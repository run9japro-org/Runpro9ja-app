// agents_screen/minimum_scale_agent_selection.dart - UPDATED
import 'package:flutter/material.dart';
import 'package:runpro_9ja/models/agent_model.dart';
import 'package:runpro_9ja/services/customer_services.dart';
import '../../auth/Auth_services/auth_service.dart';

class MinimumScaleAgentSelection extends StatefulWidget {
  final String serviceType;
  final Map<String, dynamic> orderData;
  final double orderAmount;
  final Function(Agent, Map<String, dynamic>) onAgentSelected;

  const MinimumScaleAgentSelection({
    super.key,
    required this.serviceType,
    required this.orderData,
    required this.orderAmount,
    required this.onAgentSelected,
  });

  @override
  State<MinimumScaleAgentSelection> createState() => _MinimumScaleAgentSelectionState();
}

class _MinimumScaleAgentSelectionState extends State<MinimumScaleAgentSelection> {
  late final CustomerService customerService;
  List<Agent> _agents = [];
  bool _isLoading = true;
  Agent? _selectedAgent;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    customerService = CustomerService(AuthService());
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    try {
      final agentsData = await customerService.getRecommendedAgents(
        serviceType: widget.serviceType,
      );

      // Convert the data to Agent objects using fromJson
      final agents = agentsData.map((agentData) {
        return Agent.fromJson(agentData);
      }).toList();

      setState(() {
        _agents = agents;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load agents: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectAgent(Agent agent) {
    setState(() {
      _selectedAgent = agent;
    });
  }

  Future<void> _confirmSelection() async {
    if (_selectedAgent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an agent')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Use the new method for minimum scale agent selection
      await customerService.selectAgentForMinimumScale(
        orderId: widget.orderData['orderId'],
        agentId: _selectedAgent!.id,
      );

      // Check if widget is still mounted
      if (!mounted) return;

      // Call the callback with the selected agent
      widget.onAgentSelected(_selectedAgent!, widget.orderData);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select agent: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Professional'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Professional for ${widget.serviceType}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estimated Amount: ₦${widget.orderAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Minimum Scale Service - Direct Booking',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Agents List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _agents.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No professionals available',
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
              itemCount: _agents.length,
              itemBuilder: (context, index) {
                final agent = _agents[index];
                final isSelected = _selectedAgent?.id == agent.id;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: isSelected ? Colors.green[50] : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: agent.profileImage.isNotEmpty
                          ? NetworkImage(agent.profileImage)
                          : null,
                      child: agent.profileImage.isEmpty
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            agent.displayName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (agent.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 16, color: Colors.blue),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₦${agent.price.toStringAsFixed(0)} per service'),
                        Text('${agent.distance.toStringAsFixed(1)} km away'),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text('${agent.rating.toStringAsFixed(1)} (${agent.completedJobs} jobs)'),
                          ],
                        ),
                        if (agent.yearsOfExperience.isNotEmpty)
                          Text(
                            '${agent.yearsOfExperience} years experience',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        if (agent.summary.isNotEmpty)
                          Text(
                            agent.summary,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () => _selectAgent(agent),
                  ),
                );
              },
            ),
          ),

          // Confirm Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                ),
                onPressed: (_isSubmitting || _selectedAgent == null) ? null : _confirmSelection,
                child: _isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Confirm Selection',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}