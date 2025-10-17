// lib/screens/saved_locations_screen.dart
import 'package:flutter/material.dart';

class SavedLocation {
  final String id;
  final String title;
  final String address;
  final String type; // home, work, other
  late final bool isDefault;
  final double? latitude;
  final double? longitude;

  SavedLocation({
    required this.id,
    required this.title,
    required this.address,
    required this.type,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  IconData get icon {
    switch (type) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }

  Color get color {
    switch (type) {
      case 'home':
        return Colors.blue;
      case 'work':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }
}

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  List<SavedLocation> _savedLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _savedLocations = [
        SavedLocation(
          id: '1',
          title: 'Home',
          address: '123 Main Street, Lagos Island, Lagos',
          type: 'home',
          isDefault: true,
          latitude: 6.5244,
          longitude: 3.3792,
        ),
        SavedLocation(
          id: '2',
          title: 'Work',
          address: '456 Business District, Victoria Island, Lagos',
          type: 'work',
          isDefault: false,
          latitude: 6.4281,
          longitude: 3.4210,
        ),
        SavedLocation(
          id: '3',
          title: 'Mom\'s Place',
          address: '789 Family Avenue, Ikeja, Lagos',
          type: 'other',
          isDefault: false,
          latitude: 6.6018,
          longitude: 3.3515,
        ),
      ];
      _isLoading = false;
    });
  }

  void _addNewLocation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddLocationSheet(
        onLocationAdded: (newLocation) {
          setState(() {
            _savedLocations.add(newLocation);
          });
        },
      ),
    );
  }

  void _editLocation(SavedLocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddLocationSheet(
        location: location,
        onLocationAdded: (updatedLocation) {
          setState(() {
            final index = _savedLocations.indexWhere((loc) => loc.id == location.id);
            if (index != -1) {
              _savedLocations[index] = updatedLocation;
            }
          });
        },
      ),
    );
  }

  void _deleteLocation(String locationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: const Text('Are you sure you want to delete this saved location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _savedLocations.removeWhere((loc) => loc.id == locationId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(String locationId) {
    setState(() {
      for (var location in _savedLocations) {
        location.isDefault = location.id == locationId;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Default location updated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewLocation,
            tooltip: 'Add New Location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedLocations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _savedLocations.length,
        itemBuilder: (context, index) {
          final location = _savedLocations[index];
          return _buildLocationCard(location);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Saved Locations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your frequently used locations for faster checkout',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewLocation,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(SavedLocation location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: location.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(location.icon, color: location.color),
        ),
        title: Row(
          children: [
            Text(
              location.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (location.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              location.address,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editLocation(location);
                break;
              case 'set_default':
                _setAsDefault(location.id);
                break;
              case 'delete':
                _deleteLocation(location.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            if (!location.isDefault)
              const PopupMenuItem(
                value: 'set_default',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 20),
                    SizedBox(width: 8),
                    Text('Set as Default'),
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
          // Optionally show location details or set as current
        },
      ),
    );
  }
}

class AddLocationSheet extends StatefulWidget {
  final SavedLocation? location;
  final Function(SavedLocation) onLocationAdded;

  const AddLocationSheet({
    super.key,
    this.location,
    required this.onLocationAdded,
  });

  @override
  State<AddLocationSheet> createState() => _AddLocationSheetState();
}

class _AddLocationSheetState extends State<AddLocationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedType = 'home';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.location != null) {
      _titleController.text = widget.location!.title;
      _addressController.text = widget.location!.address;
      _selectedType = widget.location!.type;
      _isDefault = widget.location!.isDefault;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveLocation() {
    if (_formKey.currentState!.validate()) {
      final newLocation = SavedLocation(
        id: widget.location?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        address: _addressController.text.trim(),
        type: _selectedType,
        isDefault: _isDefault,
      );

      widget.onLocationAdded(newLocation);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.location != null ? 'Location updated!' : 'Location saved!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.location != null ? 'Edit Location' : 'Add New Location',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Location Name',
                hintText: 'e.g., Home, Work, Mom\'s Place',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Full Address',
                hintText: 'Enter complete address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Location Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeChip('home', 'Home', Icons.home),
                const SizedBox(width: 8),
                _buildTypeChip('work', 'Work', Icons.work),
                const SizedBox(width: 8),
                _buildTypeChip('other', 'Other', Icons.location_on),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.location == null)
              CheckboxListTile(
                title: const Text('Set as default location'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(widget.location != null ? 'Update Location' : 'Save Location'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? _getColor(type).withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? _getColor(type) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? _getColor(type) : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? _getColor(type) : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(String type) {
    switch (type) {
      case 'home':
        return Colors.blue;
      case 'work':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }
}