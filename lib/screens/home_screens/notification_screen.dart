// screens/notification_screen.dart
import 'package:flutter/material.dart';

import '../../auth/Auth_services/auth_service.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService(AuthService());

  final List<NotificationModel> _notifications = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _selectedFilter = 'all';
  String? _selectedReadFilter;

  // Filter options
  final Map<String, String> _typeFilters = {
    'all': 'All',
    'order_update': 'Order Updates',
    'payment': 'Payments',
    'system': 'System',
    'promotion': 'Promotions',
    'agent_assigned': 'Agent Assignments',
    'delivery_status': 'Delivery Status',
    'chat': 'Chat',
    'review': 'Reviews',
  };

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
      }

      setState(() {
        _isLoading = true;
      });

      final response = await _notificationService.getNotifications(
        page: _currentPage,
        limit: 20,
        type: _selectedFilter == 'all' ? null : _selectedFilter,
        isRead: _selectedReadFilter == null
            ? null
            : _selectedReadFilter == 'read',
      );

      setState(() {
        if (refresh) {
          _notifications.clear();
        }

        _notifications.addAll(response.notifications);
        _hasMore = _currentPage < response.totalPages;
        _currentPage++;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load notifications');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _loadNotifications();
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    try {
      final success = await _notificationService.markAsRead(notification.id);
      if (success && mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(isRead: true);
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to mark as read');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();
      if (success && mounted) {
        setState(() {
          for (int i = 0; i < _notifications.length; i++) {
            if (!_notifications[i].isRead) {
              _notifications[i] = _notifications[i].copyWith(isRead: true);
            }
          }
        });
        _showSuccessSnackBar('All notifications marked as read');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to mark all as read');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      if (success && mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notificationId);
        });
        _showSuccessSnackBar('Notification deleted');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to delete notification');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Type Filter
                  const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _typeFilters.entries.map((entry) {
                      return FilterChip(
                        label: Text(entry.value),
                        selected: _selectedFilter == entry.key,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedFilter = selected ? entry.key : 'all';
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Read Status Filter
                  const Text('Read Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedReadFilter == null,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedReadFilter = null;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Unread'),
                        selected: _selectedReadFilter == 'unread',
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedReadFilter = selected ? 'unread' : null;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Read'),
                        selected: _selectedReadFilter == 'read',
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedReadFilter = selected ? 'read' : null;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _loadNotifications(refresh: true);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: _isLoading && _notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _notifications.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _notifications.length) {
              return _buildLoadMoreIndicator();
            }
            final notification = _notifications[index];
            return _buildNotificationItem(notification);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re all caught up!',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _loadNotifications(refresh: true),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : _hasMore
            ? const Text('Load more...')
            : const Text('No more notifications'),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text('Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteNotification(notification.id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: notification.isRead ? Colors.white : Colors.blue[50],
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(notification.icon, color: notification.color),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message),
              const SizedBox(height: 4),
              Text(
                notification.timeAgo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_read') {
                _markAsRead(notification);
              } else if (value == 'delete') {
                _deleteNotification(notification.id);
              }
            },
            itemBuilder: (context) => [
              if (!notification.isRead)
                const PopupMenuItem(
                  value: 'mark_read',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_read, size: 20),
                      SizedBox(width: 8),
                      Text('Mark as read'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification);
            }

            // Handle notification action
            if (notification.actionUrl != null) {
              _handleNotificationAction(notification);
            }
          },
        ),
      ),
    );
  }

  void _handleNotificationAction(NotificationModel notification) {
    // Implement navigation based on notification type and data
    switch (notification.type) {
      case NotificationType.orderUpdate:
      // Navigate to order details
        break;
      case NotificationType.payment:
      // Navigate to payment details
        break;
      case NotificationType.chat:
      // Navigate to chat
        break;
    // Handle other types...
      default:
        break;
    }
  }
}