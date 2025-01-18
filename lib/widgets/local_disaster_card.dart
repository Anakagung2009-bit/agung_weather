import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/localization.dart';

class LocalDisasterCard extends StatefulWidget {
  @override
  _LocalDisasterCardState createState() => _LocalDisasterCardState();
}

class _LocalDisasterCardState extends State<LocalDisasterCard> {
  Position? _currentPosition;
  String _disasterStatus = 'Checking...';
  Color _statusColor = Colors.grey;
  IconData _statusIcon = Icons.help_outline;
  List<dynamic> _nearbyDisasters = [];

  @override
  void initState() {
    super.initState();
    _checkLocalDisasterStatus();
  }

  void _updateStatus(String status, Color color, IconData icon) {
    setState(() {
      _disasterStatus = status;
      _statusColor = color;
      _statusIcon = icon;
    });
  }

  Future<void> _checkLocalDisasterStatus() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateStatus(
          'Location services disabled',
          Colors.grey,
          Icons.location_off,
        );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _updateStatus(
            'Location permission denied',
            Colors.orange,
            Icons.warning_rounded,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _updateStatus(
          'Location permission permanently denied',
          Colors.red,
          Icons.block,
        );
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _fetchNearbyDisasters();
    } catch (e) {
      _updateStatus(
        'Error checking disaster status',
        Colors.grey,
        Icons.error_outline,
      );
    }
  }

  Future<void> _fetchNearbyDisasters() async {
    if (_currentPosition == null) return;

    try {
      final url = Uri.parse(
          'https://eonet.gsfc.nasa.gov/api/v3/events?status=open&bbox='
              '${_currentPosition!.longitude - 5},'
              '${_currentPosition!.latitude - 5},'
              '${_currentPosition!.longitude + 5},'
              '${_currentPosition!.latitude + 5}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final events = responseData['events'] as List;

        _nearbyDisasters = events.where((event) {
          // Filter events within a certain distance
          final geometry = event['geometry'][0];
          final distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            geometry['coordinates'][1],
            geometry['coordinates'][0],
          );

          return distance <= 500000; // 500 km radius
        }).toList();

        if (_nearbyDisasters.isNotEmpty) {
          _updateStatus(
            context.translate('potential_disaster_detected'),
            Colors.red,
            Icons.warning_rounded,
          );
        } else {
          _updateStatus(
            context.translate('no_immediate_disaster_threat'),
            Colors.green,
            Icons.check_circle_outline,
          );
        }
      } else {
        _updateStatus(
          context.translate('failed_fetch_disaster_data'),
          Colors.orange,
          Icons.error_outline,
        );
      }
    } catch (e) {
      _updateStatus(
        context.translate('error_fetching_disaster_data'),
        Colors.grey,
        Icons.error_outline,
      );
    }
  }

  String _getDisasterDetails() {
    if (_nearbyDisasters.isEmpty) {
      return 'No nearby disasters detected';
    }

    return _nearbyDisasters.map((disaster) {
      return '${disaster['title']} (${disaster['categories'][0]['title']})';
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.all(16),
      color: colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _statusIcon,
                  color: _statusColor,
                  size: 50,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.translate('local_disaster_status'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _disasterStatus,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: colorScheme.primary),
                  onPressed: _checkLocalDisasterStatus,
                )
              ],
            ),
            if (_nearbyDisasters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${context.translate('nearby_disasters')}: ${_getDisasterDetails()}',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 19,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}