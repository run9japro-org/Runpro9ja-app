import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import '../services/socket_service.dart';
import 'package:permission_handler/permission_handler.dart';
class MapViewPage extends StatefulWidget {
  final Map<String, dynamic> order;
  final Map<String, dynamic>? liveLocation;
  final List<Map<String, dynamic>>? locationHistory;

  const MapViewPage({
    super.key,
    required this.order,
    this.liveLocation,
    this.locationHistory,
  });

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final socketService = SocketService();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  LatLng? _serviceLocation;
  LatLng? _agentLocation;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  // Default Lagos coordinates
  static const LatLng _defaultLocation = LatLng(6.5244, 3.3792);

  @override
  void initState() {
    super.initState();

    _requestLocationPermission();
    // Initialize map setup
    _initializeMap();

    // ✅ Start listening for agent live updates via socket
    socketService.onAgentLocationUpdate = (agentId, lat, lng) {
      print('🔄 Update map marker for agent $agentId to ($lat, $lng)');
      updateAgentMarkerOnMap(lat, lng);
    };

    // ✅ Refresh map periodically if live tracking is enabled
    if (widget.liveLocation != null) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (mounted) _setupMarkersAndPolylines();
      });
    }
  }
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      print('✅ Location permission granted');
    } else {
      print('❌ Location permission denied');
    }
  }

  void _initializeMap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMarkersAndPolylines();
    });
  }
  void updateAgentMarkerOnMap(double lat, double lng) {
    final newPosition = LatLng(lat, lng);

    setState(() {
      _agentLocation = newPosition;
      _markers.removeWhere((m) => m.markerId.value == 'agent_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('agent_location'),
          position: newPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Agent', snippet: 'Live position'),
        ),
      );
    });

    // Optionally move camera to follow agent
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(newPosition));
    }
  }

  Future<void> _setupMarkersAndPolylines() async {
    final markers = <Marker>{};
    final polylines = <Polyline>{};
    final List<LatLng> allPoints = [];

    try {
      print('🗺️ Setting up map...');

      // 1. Get service location (customer location)
      final serviceLocation = await _getServiceLocation();
      if (serviceLocation != null) {
        _serviceLocation = serviceLocation;
        allPoints.add(serviceLocation);

        markers.add(
          Marker(
            markerId: const MarkerId('service_location'),
            position: serviceLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: 'Service Location',
              snippet: _getLocationText(),
            ),
          ),
        );
        print('✅ Service location added: $serviceLocation');
      }

      // 2. Add live agent location if available
      if (widget.liveLocation != null) {
        final agentLocation = await _parseCoordinates(widget.liveLocation!);
        if (agentLocation != null && _isValidLocation(agentLocation)) {
          _agentLocation = agentLocation;
          allPoints.add(agentLocation);

          markers.add(
            Marker(
              markerId: const MarkerId('agent_location'),
              position: agentLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: const InfoWindow(
                title: 'Agent Location',
                snippet: 'Current position',
              ),
            ),
          );
          print('✅ Agent location added: $agentLocation');
        }
      }

      // 3. Add location history trail if available
      if (widget.locationHistory != null && widget.locationHistory!.isNotEmpty) {
        final historyPoints = await _processLocationHistory(markers);
        if (historyPoints.isNotEmpty) {
          allPoints.addAll(historyPoints);

          // Draw route line
          if (historyPoints.length > 1) {
            polylines.add(
              Polyline(
                polylineId: const PolylineId('location_trail'),
                points: historyPoints,
                color: Colors.blue.withOpacity(0.6),
                width: 4,
                patterns: [PatternItem.dash(20), PatternItem.gap(10)],
              ),
            );
          }
        }
      }

      // 4. Draw route between service location and agent if both exist
      if (_serviceLocation != null && _agentLocation != null) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: [_serviceLocation!, _agentLocation!],
            color: Colors.green,
            width: 3,
          ),
        );
      }

      // 5. Update UI
      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.addAll(markers);
          _polylines.clear();
          _polylines.addAll(polylines);
          _isLoading = false;
          _errorMessage = null;
        });

        // 6. Adjust camera to show all markers
        if (allPoints.isNotEmpty && _mapController != null) {
          _fitMapToMarkers(allPoints);
        } else if (_serviceLocation != null && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_serviceLocation!, 14),
          );
        }
      }

      print('✅ Map setup complete with ${markers.length} markers');
    } catch (e, stackTrace) {
      print('❌ Error setting up map: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load map';
          _isLoading = false;
        });
      }
    }
  }

  Future<List<LatLng>> _processLocationHistory(Set<Marker> markers) async {
    final List<LatLng> historyPoints = [];

    try {
      print('📍 Processing ${widget.locationHistory!.length} history items');

      for (int i = 0; i < widget.locationHistory!.length; i++) {
        try {
          final item = widget.locationHistory![i];
          print('Processing history item $i: $item');

          // Check if this is a timeline event with coordinates
          LatLng? point;

          if (item['coordinates'] != null) {
            point = await _parseCoordinates(item);
          } else if (item['location'] != null) {
            point = await _parseCoordinates(item['location']);
          }

          if (point != null && _isValidLocation(point)) {
            historyPoints.add(point);

            markers.add(
              Marker(
                markerId: MarkerId('history_$i'),
                position: point,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                alpha: 0.7,
                infoWindow: InfoWindow(
                  title: 'Point ${i + 1}',
                  snippet: _formatTimestamp(item['timestamp']),
                ),
              ),
            );
          }
        } catch (e) {
          print('⚠️ Could not parse history item $i: $e');
        }
      }

      print('✅ Processed ${historyPoints.length} valid history points');
    } catch (e) {
      print('❌ Error processing location history: $e');
    }

    return historyPoints;
  }

  Future<LatLng?> _getServiceLocation() async {
    try {
      print('📍 Getting service location...');

      // Try different possible location fields
      final locationData = widget.order['location'] ??
          widget.order['deliveryLocation'] ??
          widget.order['serviceLocation'] ??
          widget.order['address'];

      if (locationData == null) {
        print('⚠️ No location in order, using default');
        return _defaultLocation;
      }

      print('📍 Location data: $locationData (${locationData.runtimeType})');

      // Parse coordinates
      final coordinates = await _parseCoordinates(locationData);

      if (coordinates != null && _isValidLocation(coordinates)) {
        return coordinates;
      }

      // Fallback to geocoding if it's a string address
      if (locationData is String && locationData.isNotEmpty) {
        final geocoded = await _geocodeAddress(locationData);
        if (geocoded != null) return geocoded;
      }

      return _defaultLocation;
    } catch (e) {
      print('❌ Error getting service location: $e');
      return _defaultLocation;
    }
  }

  Future<LatLng?> _parseCoordinates(dynamic data) async {
    if (data == null) return null;

    try {
      // Handle list first (to avoid string index errors)
      if (data is List && data.length >= 2) {
        final num1 = _toDouble(data[0]);
        final num2 = _toDouble(data[1]);
        if (num1 != null && num2 != null) {
          // Try both possible coordinate orders
          if (_isValidLatLng(num1, num2)) return LatLng(num1, num2);
          if (_isValidLatLng(num2, num1)) return LatLng(num2, num1);
        }
      }

      // Then handle map safely
      if (data is Map) {
        final coords = data['coordinates'] ?? data;
        if (coords is List && coords.length >= 2) {
          final num1 = _toDouble(coords[0]);
          final num2 = _toDouble(coords[1]);
          if (num1 != null && num2 != null) {
            if (_isValidLatLng(num1, num2)) return LatLng(num1, num2);
            if (_isValidLatLng(num2, num1)) return LatLng(num2, num1);
          }
        }
        final lat = _toDouble(data['lat'] ?? data['latitude']);
        final lng = _toDouble(data['lng'] ?? data['longitude']);
        if (lat != null && lng != null) return LatLng(lat, lng);
      }

      // Fallback for address string
      if (data is String && data.isNotEmpty) {
        return await _geocodeAddress(data);
      }
    } catch (e) {
      print('❌ Error parsing coordinates: $e');
    }

    return null;
  }


  bool _isValidLatLng(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  bool _isValidLocation(LatLng location) {
    // Check if it's not the default location and is valid
    return _isValidLatLng(location.latitude, location.longitude) &&
        !(location.latitude == 0 && location.longitude == 0);
  }

  Future<LatLng?> _geocodeAddress(String address) async {
    try {
      print('🔍 Geocoding: $address');
      final locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final loc = locations.first;
        final result = LatLng(loc.latitude, loc.longitude);
        print('✅ Geocoded to: $result');
        return result;
      }
    } catch (e) {
      print('❌ Geocoding failed: $e');
    }
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleaned);
    }
    return null;
  }

  void _fitMapToMarkers(List<LatLng> points) {
    if (points.isEmpty || _mapController == null) return;

    try {
      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;

      for (final point in points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      final southwest = LatLng(minLat, minLng);
      final northeast = LatLng(maxLat, maxLng);
      final bounds = LatLngBounds(southwest: southwest, northeast: northeast);

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } catch (e) {
      print('❌ Error fitting map to markers: $e');
    }
  }

  void _centerOnAgent() {
    if (_agentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_agentLocation!, 16),
      );
    } else if (_serviceLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_serviceLocation!, 14),
      );
    }
  }

  String _getLocationText() {
    final location = widget.order['location'];
    if (location is String) return location;
    if (location is Map) {
      return location['address']?.toString() ??
          location['formattedAddress']?.toString() ??
          'Service location';
    }
    return widget.order['deliveryAddress']?.toString() ?? 'Service location';
  }

  String _getOrderId() {
    final id = widget.order['_id']?.toString() ??
        widget.order['id']?.toString() ??
        'Unknown';
    return id.length > 8 ? '${id.substring(0, 8)}...' : id;
  }

  String _getServiceName() {
    final orderType = widget.order['orderType']?.toString();
    final serviceCategory = widget.order['serviceCategory'];
    final serviceType = widget.order['serviceType'];

    if (orderType == 'professional' && serviceCategory is Map) {
      return serviceCategory['name']?.toString() ??
          serviceType?.toString().replaceAll('_', ' ') ??
          'Professional Service';
    }

    return serviceType?.toString().replaceAll('_', ' ') ?? 'Service';
  }


  String? _getAgentName() {
    final agent = widget.order['agent'];
    if (agent is Map) {
      return agent['fullName']?.toString() ?? agent['name']?.toString();
    }
    return null;
  }


  StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
      case 'pending':
        return StatusInfo(Icons.pending, Colors.orange, 'Requested');
      case 'accepted':
      case 'agent_selected':
        return StatusInfo(Icons.assignment_turned_in, Colors.blue, 'Accepted');
      case 'in-progress':
      case 'in_progress':
        return StatusInfo(Icons.directions_bike, Colors.orange, 'In Progress');
      case 'completed':
      case 'delivered':
        return StatusInfo(Icons.check_circle, Colors.green, 'Completed');
      case 'cancelled':
        return StatusInfo(Icons.cancel, Colors.red, 'Cancelled');
      default:
        return StatusInfo(Icons.help, Colors.grey, 'Unknown');
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = DateTime.parse(timestamp.toString());
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getDistanceText() {
    if (_serviceLocation == null || _agentLocation == null) return 'Calculating...';

    // Simple distance calculation (not accurate for long distances)
    final lat1 = _serviceLocation!.latitude;
    final lon1 = _serviceLocation!.longitude;
    final lat2 = _agentLocation!.latitude;
    final lon2 = _agentLocation!.longitude;

    final dLat = (lat2 - lat1) * 111.0; // 1 degree ≈ 111 km
    final dLon = (lon2 - lon1) * 111.0;
    final distance = (dLat * dLat + dLon * dLon).abs().toStringAsFixed(1);

    return '~$distance km away';
  }


  @override
  Widget build(BuildContext context) {
    // Add debug prints
    print('🗺️ Building MapViewPage');
    print('📍 Markers count: ${_markers.length}');
    print('📍 Service location: $_serviceLocation');
    print('📍 Agent location: $_agentLocation');
    print('📍 Is loading: $_isLoading');
    print('📍 Error message: $_errorMessage');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${_getOrderId()}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isLoading && _mapController != null)
            IconButton(
              icon: const Icon(Icons.my_location, color: Colors.green),
              onPressed: _centerOnAgent,
              tooltip: 'Center on agent',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () {
              print('🔄 Manual refresh triggered');
              _setupMarkersAndPolylines();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map with error handling
          Container(
            color: Colors.grey.shade200,
            child: GoogleMap(
              onMapCreated: (controller) {
                print('✅ Map controller created');
                _mapController = controller;

                // Give the map a moment to initialize, then setup markers
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    print('🔄 Setting up markers after map creation');
                    _setupMarkersAndPolylines();
                  }
                });
              },
              initialCameraPosition: CameraPosition(
                target: _serviceLocation ?? _defaultLocation,
                zoom: 14,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onCameraMove: (position) {
                // Debug camera position
                print('📷 Camera at: ${position.target}');
              },
            ),
          ),

          // Loading overlay with better visibility
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.95),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Loading map...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Markers: ${_markers.length}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

          // Debug info overlay (remove in production)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Info:',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'Markers: ${_markers.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Loading: $_isLoading',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Service: ${_serviceLocation != null ? "✓" : "✗"}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Agent: ${_agentLocation != null ? "✓" : "✗"}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),

          // Error message with retry button
          if (_errorMessage != null && !_isLoading)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                          _isLoading = true;
                        });
                        _setupMarkersAndPolylines();
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Map legend - only show if we have markers
          if (!_isLoading && _markers.isNotEmpty)
            Positioned(
              top: 80,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem(
                      color: Colors.blue,
                      icon: Icons.location_on,
                      text: 'Service',
                    ),
                    if (widget.liveLocation != null) ...[
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        color: Colors.red,
                        icon: Icons.person_pin_circle,
                        text: 'Agent',
                      ),
                    ],
                    if (widget.locationHistory != null &&
                        widget.locationHistory!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        color: Colors.orange,
                        icon: Icons.timeline,
                        text: 'History',
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Order info panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getServiceName(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getLocationText(),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  if (_getAgentName() != null) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.green.shade100,
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getAgentName()!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (_agentLocation != null)
                                Text(
                                  _getDistanceText(),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (widget.liveLocation != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Live',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final status = widget.order['status']?.toString() ?? 'pending';
    final statusInfo = _getStatusInfo(status);
    print('🧩 order data: ${widget.order}');
    print('🧩 liveLocation: ${widget.liveLocation}');
    print('🧩 locationHistory: ${widget.locationHistory}');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: 12, color: statusInfo.color),
          const SizedBox(width: 4),
          Text(
            statusInfo.text,
            style: TextStyle(
              color: statusInfo.color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}

class StatusInfo {
  final IconData icon;
  final Color color;
  final String text;

  StatusInfo(this.icon, this.color, this.text);
}