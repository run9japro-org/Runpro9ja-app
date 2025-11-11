// screens/customer_agent_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../services/socket_service.dart';

class CustomerAgentChatScreen extends StatefulWidget {
  final String agentId;
  final String agentName;
  final String? agentImage; // Make nullable
  final String orderId;
  final String authToken;
  final String currentUserId;

  const CustomerAgentChatScreen({
    super.key,
    required this.agentId,
    required this.agentName,
    required this.agentImage, // Now accepts null
    required this.orderId,
    required this.authToken,
    required this.currentUserId,
  });

  @override
  State<CustomerAgentChatScreen> createState() => _CustomerAgentChatScreenState();
}

class _CustomerAgentChatScreenState extends State<CustomerAgentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final SocketService _socketService = SocketService();
  late final ChatService _chatService;

  bool _isLoading = false;
  bool _isSending = false;
  bool _isConnected = false;
  bool _hasNewMessages = false;
  String? _agentPhone;
  bool _isProfileLoading = false;
  Map<String, dynamic>? _agentProfileData;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(widget.authToken);
    _debugAgentInfo();
    _initializeChat();
    _fetchAgentProfile(); // Fetch agent profile data including phone and image
  }

  void _debugAgentInfo() {
    print('👤 AGENT INFO DEBUG:');
    print('   - ID: ${widget.agentId}');
    print('   - Name: ${widget.agentName}');
    print('   - Raw Image: ${widget.agentImage}');
    print('   - Image is null: ${widget.agentImage == null}');
    print('   - Image is empty: ${widget.agentImage?.isEmpty ?? true}');
    print('   - Processed Image URL: $_agentImageUrl');
  }


  // REPLACE the _agentImageUrl getter with this:
  String get _agentImageUrl {
    // 1. First priority: Use profile image from agent profile API response
    if (_agentProfileData != null) {
      // Try profileImage from agent profile first
      if (_agentProfileData!['profileImage'] != null) {
        final apiImageUrl = _agentProfileData!['profileImage']?.toString();
        if (apiImageUrl != null && apiImageUrl.isNotEmpty && apiImageUrl != 'null') {
          // Handle the path format: "/uploads/1762816871614.jpg"
          if (apiImageUrl.startsWith('/uploads/')) {
            final fullUrl = 'https://runpro9ja-pxqoa.ondigitalocean.app$apiImageUrl';
            print('🖼️ Using agent profileImage: $fullUrl');
            return fullUrl;
          }
          // Handle full URL
          else if (apiImageUrl.startsWith('http')) {
            print('🖼️ Using agent profileImage (full URL): $apiImageUrl');
            return apiImageUrl;
          }
          // Handle filename only
          else {
            final fullUrl = 'https://runpro9ja-pxqoa.ondigitalocean.app/uploads/$apiImageUrl';
            print('🖼️ Using agent profileImage (filename): $fullUrl');
            return fullUrl;
          }
        }
      }

      // Fallback to user profile image if available
      if (_agentProfileData!['user'] != null && _agentProfileData!['user']['profileImage'] != null) {
        final userImageUrl = _agentProfileData!['user']['profileImage']?.toString();
        if (userImageUrl != null && userImageUrl.isNotEmpty && userImageUrl != 'null') {
          if (userImageUrl.startsWith('/uploads/')) {
            final fullUrl = 'https://runpro9ja-pxqoa.ondigitalocean.app$userImageUrl';
            print('🖼️ Using user profileImage: $fullUrl');
            return fullUrl;
          } else if (userImageUrl.startsWith('http')) {
            print('🖼️ Using user profileImage (full URL): $userImageUrl');
            return userImageUrl;
          }
        }
      }
    }

    // 2. Handle the widget.agentImage (fallback from constructor)
    if (widget.agentImage != null && widget.agentImage!.isNotEmpty) {
      final String image = widget.agentImage!;

      // If it's already a full URL, use it directly
      if (image.startsWith('http')) {
        print('🖼️ Using full URL from widget: $image');
        return image;
      }

      // If it starts with /uploads/, construct full URL
      if (image.startsWith('/uploads/')) {
        final fullUrl = 'https://runpro9ja-pxqoa.ondigitalocean.app$image';
        print('🖼️ Using database format URL: $fullUrl');
        return fullUrl;
      }

      // If it's just a filename, construct URL
      final fullUrl = 'https://runpro9ja-pxqoa.ondigitalocean.app/uploads/$image';
      print('🖼️ Using constructed URL: $fullUrl');
      return fullUrl;
    }

    // 3. Fallback: Use generated avatar
    final agentName = widget.agentName.isNotEmpty ? widget.agentName : 'Agent';
    final fallbackUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(agentName)}&background=26857C&color=ffffff&size=150';
    print('🖼️ Using fallback avatar: $fallbackUrl');
    return fallbackUrl;
  }


  // REPLACE your _fetchAgentProfile method with this:
  Future<void> _fetchAgentProfile() async {
    setState(() => _isProfileLoading = true);

    try {
      print('🔍 Fetching agent profile for: ${widget.agentId}');

      final response = await _chatService.getAgentProfile(widget.agentId);

      print('📋 Raw agent profile response: $response');

      String? foundPhone;

      // Now the user object should be populated with phone number
      if (response['user'] != null && response['user']['phone'] != null) {
        foundPhone = response['user']['phone']?.toString();
        print('📞 Found agent phone in user.phone: $foundPhone');
      }
      else {
        print('❌ Phone number not found in populated user data');
        if (response['user'] != null) {
          print('👤 User object: ${response['user']}');
          print('🔑 User object keys: ${response['user'].keys}');
        }
      }

      // Store the full profile data for image handling
      _agentProfileData = response;

      setState(() {
        _agentPhone = foundPhone;
      });

      print("📞 Final agent phone: $_agentPhone");

    } catch (e) {
      print("❌ Failed to fetch agent profile: $e");
    } finally {
      setState(() => _isProfileLoading = false);
    }
  }

  void _initializeChat() async {
    setState(() => _isLoading = true);

    try {
      print('🔄 Initializing chat with agent: ${widget.agentId}');

      // Load conversation history with this agent
      final messages = await _chatService.getConversation(widget.agentId);
      print('📨 Loaded ${messages.length} messages');

      setState(() {
        _messages.addAll(messages);
      });

      // Connect to socket for real-time messaging
      _socketService.connect(widget.authToken, widget.currentUserId);
      _socketService.onNewMessage = _handleNewMessage;
      _socketService.onConnected = _onSocketConnected;
      _socketService.onDisconnected = _onSocketDisconnected;
      _socketService.onMessageRead = _handleMessageRead;
      _socketService.onMessagesRead = _handleMessagesRead;

      // Mark unread messages as read
      await _markUnreadMessagesAsRead();

      _scrollToBottom();
    } catch (e) {
      print('❌ Error initializing chat: $e');
      _showError('Failed to load messages: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSocketConnected() {
    setState(() => _isConnected = true);
    print('✅ Connected to chat with ${widget.agentName}');
  }

  void _onSocketDisconnected() {
    setState(() => _isConnected = false);
    print('❌ Disconnected from chat');
  }

  void _handleNewMessage(ChatMessage message) {
    print('📩 New message received: ${message.message}');

    // Only add if message is from current conversation
    if (message.senderId == widget.agentId || message.receiverId == widget.agentId) {
      setState(() {
        _messages.add(message);
        _hasNewMessages = true;
      });
      _scrollToBottom();

      // Auto-mark as read when receiving new messages
      _markMessageAsRead(message.id);
    }
  }

  void _handleMessageRead(String messageId) {
    print('✅ Single message marked as read: $messageId');
    _updateMessageReadStatus(messageId, true);
  }

  void _handleMessagesRead(List<String> messageIds) {
    print('✅ Multiple messages marked as read: $messageIds');
    for (final messageId in messageIds) {
      _updateMessageReadStatus(messageId, true);
    }
  }

  void _updateMessageReadStatus(String messageId, bool read) {
    setState(() {
      final index = _messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(read: read);
      }
    });
  }

  Future<void> _markUnreadMessagesAsRead() async {
    try {
      final unreadMessages = _messages.where((msg) =>
      !msg.read && msg.senderId == widget.agentId
      ).toList();

      print('📖 Marking ${unreadMessages.length} unread messages as read');

      if (unreadMessages.isNotEmpty) {
        final messageIds = unreadMessages.map((msg) => msg.id).toList();

        await _chatService.markMessagesAsRead(messageIds);

        for (final message in unreadMessages) {
          _updateMessageReadStatus(message.id, true);
        }

        _socketService.markMessagesAsRead(
            messageIds,
            widget.agentId,
            widget.currentUserId
        );
      }
    } catch (e) {
      print('❌ Error marking messages as read: $e');
    }
  }

  Future<void> _markMessageAsRead(String messageId) async {
    try {
      _updateMessageReadStatus(messageId, true);
      _socketService.markAsRead(messageId, widget.agentId, widget.currentUserId);
      await _chatService.markAsRead(messageId);
    } catch (e) {
      print('❌ Error marking message as read: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ✅ UPDATED: Show agent profile dialog with phone number
  void _showAgentProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(_agentImageUrl),
              radius: 20,
              onBackgroundImageError: (exception, stackTrace) {
                print('❌ Error loading agent profile image: $exception');
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.agentName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileItem(Icons.person_outline, 'Agent ID', widget.agentId),
            const SizedBox(height: 12),

            // ✅ ADDED: Phone number with call functionality
            if (_agentPhone != null && _agentPhone!.isNotEmpty) ...[
              _buildPhoneItem(),
              const SizedBox(height: 12),
            ] else if (_isProfileLoading) ...[
              _buildProfileItem(Icons.phone, 'Phone', 'Loading...'),
              const SizedBox(height: 12),
            ] else ...[
              _buildProfileItem(Icons.phone, 'Phone', 'Not available'),
              const SizedBox(height: 12),
            ],

            _buildProfileItem(Icons.assignment, 'Order ID', widget.orderId),
            const SizedBox(height: 12),
            _buildProfileItem(Icons.chat, 'Messages in chat', '${_messages.length} messages'),
            const SizedBox(height: 8),
            _buildProfileItem(Icons.image, 'Profile Image',
                widget.agentImage == null ? 'Not set' : 'Custom image'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),

          // ✅ ADDED: Call button if phone number is available
          if (_agentPhone != null && _agentPhone!.isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Call'),
              onPressed: _makePhoneCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  // ✅ NEW: Phone item with call functionality
  Widget _buildPhoneItem() {
    return Row(
      children: [
        Icon(Icons.phone, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: _makePhoneCall,
                child: Text(
                  _agentPhone!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ NEW: Make phone call function
  Future<void> _makePhoneCall() async {
    if (_agentPhone == null || _agentPhone!.isEmpty) {
      _showError('Phone number not available');
      return;
    }

    final phoneUrl = 'tel:${_agentPhone!.replaceAll(RegExp(r'[^\d+]'), '')}';

    try {
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        _showError('Could not launch phone app');
      }
    } catch (e) {
      _showError('Failed to make phone call: $e');
    }
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ FIXED: Avatar widget with proper null handling
  Widget _buildAgentAvatar() {
    return CircleAvatar(
      backgroundImage: NetworkImage(_agentImageUrl),
      radius: 18,
      onBackgroundImageError: (exception, stackTrace) {
        print('❌ Error loading agent avatar: $exception');
      }
    );
  }


  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _isSending) {
      print('⏸️ Cannot send: empty message or already sending');
      return;
    }

    print('📤 Sending message: $text');
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      // Create temporary message for immediate UI feedback
      final tempMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        senderId: widget.currentUserId,
        receiverId: widget.agentId,
        message: text,
        orderId: widget.orderId,
        createdAt: DateTime.now(),
        read: false,
      );

      setState(() {
        _messages.add(tempMessage);
      });
      _scrollToBottom();

      // Send actual message via API
      final message = await _chatService.sendMessage(
        receiverId: widget.agentId,
        message: text,
        orderId: widget.orderId,
      );

      print('✅ Message sent successfully: ${message.id}');

      // Replace temporary message with real one
      setState(() {
        _messages.removeWhere((m) => m.id == tempMessage.id);
        _messages.add(message);
      });

      // Also send via socket for real-time delivery
      _socketService.sendMessage(message);

    } catch (e) {
      print('❌ Failed to send message: $e');
      _showError('Failed to send message: $e');

      // Restore message to input field if failed
      _messageController.text = text;

      // Remove temporary message
      setState(() {
        _messages.removeWhere((m) => m.id.startsWith('temp_'));
      });
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showAgentProfile,
          child: Row(
            children: [
              // Agent image - clickable
              GestureDetector(
                onTap: _showAgentProfile,
                child: _buildAgentAvatar(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Agent name - clickable
                    GestureDetector(
                      onTap: _showAgentProfile,
                      child: Text(
                        widget.agentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isConnected ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isConnected ? 'Online' : 'Connecting...',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isConnected ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_hasNewMessages)
            IconButton(
              icon: const Icon(Icons.mark_chat_read),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          // Phone button if phone number is available
          if (_agentPhone != null && _agentPhone!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: _makePhoneCall,
              tooltip: 'Call Agent',
            ),
          // Info button as alternative way to open profile
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAgentProfile,
            tooltip: 'Agent Info',
          ),
        ],
      ),
      body: Column(
        children: [
          // Order info banner
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green[50],
            child: Row(
              children: [
                Icon(Icons.assignment, color: Colors.green[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order: ${widget.orderId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Show phone number in banner if available
                if (_agentPhone != null && _agentPhone!.isNotEmpty) ...[
                  Icon(Icons.phone, color: Colors.green[700], size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _agentPhone!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading messages...'),
                ],
              ),
            )
                : _buildMessageList(),
          ),
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  void _markAllAsRead() async {
    try {
      await _markUnreadMessagesAsRead();
      setState(() {
        _hasNewMessages = false;
      });
      _showSuccess('All messages marked as read');
    } catch (e) {
      _showError('Failed to mark messages as read');
    }
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No messages yet', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text('Start a conversation about your order',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.senderId == widget.currentUserId;
        final isTemp = msg.id.startsWith('temp_');

        return _buildMessageBubble(msg, isMe, isTemp);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe, bool isTemp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            GestureDetector(
              onTap: _showAgentProfile,
              child: _buildAgentAvatar(),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? (isTemp ? Colors.green[300] : Colors.green[500])
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: isTemp
                    ? Border.all(color: Colors.green[200]!)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(msg.createdAt),
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                      if (isMe && !isTemp) ...[
                        const SizedBox(width: 4),
                        Icon(
                          msg.read ? Icons.done_all : Icons.done,
                          size: 12,
                          color: msg.read ? Colors.blue[100] : Colors.white70,
                        ),
                      ],
                      if (isTemp) ...[
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green[100],
              radius: 16,
              child: Icon(Icons.person, color: Colors.green[600], size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message about your order...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                suffixIcon: _messageController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _messageController.clear();
                    setState(() {});
                  },
                )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _messageController.text.trim().isEmpty || _isSending
                  ? Colors.grey
                  : Colors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _messageController.text.trim().isEmpty || _isSending
                  ? null
                  : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(d.year, d.month, d.day);

    if (messageDay == today) {
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } else {
      return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
  }
}