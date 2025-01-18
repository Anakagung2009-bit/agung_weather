import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import '../utils/localization.dart';


class DisasterDetailScreen extends StatefulWidget {
  final Map<String, dynamic> disaster;

  const DisasterDetailScreen({Key? key, required this.disaster}) : super(key: key);

  @override
  _DisasterDetailScreenState createState() => _DisasterDetailScreenState();
}

class _DisasterDetailScreenState extends State<DisasterDetailScreen> {
  Map<String, dynamic>? _detailedDisaster;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDisasterDetails();
  }

  Future<void> _fetchDisasterDetails() async {
    try {
      final url = Uri.parse(
          'https://eonet.gsfc.nasa.gov/api/v3/events/${widget.disaster['id']}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _detailedDisaster = responseData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to load disaster details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error fetching disaster details');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
    );
  }

  // Fungsi helper untuk mengambil value dengan default
  String _getSafeValue(String key,
      {String defaultValue = 'No Information Available'}) {
    return (_detailedDisaster?[key] ?? widget.disaster[key] ?? defaultValue)
        .toString();
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
        return Colors.red;
      case 'severe':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  // Fungsi untuk mendapatkan gambar berdasarkan tipe bencana
  // Fungsi untuk mendapatkan gambar berdasarkan tipe bencana
  String _getDisasterImage(String type) {
    type = type.toLowerCase();

    // Daftar pasangan tipe bencana dengan URL gambar yang spesifik
    final Map<String, String> disasterImages = {
      'flood': 'https://plus.unsplash.com/premium_photo-1661962476059-13543ea45d4d?w=1080&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Zmxvb2R8ZW58MHx8MHx8fDA%3D',
      'earthquake': 'https://plus.unsplash.com/premium_photo-1695914233513-6f9ca230abdb?w=1080&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8ZWFydGhxdWFrZXxlbnwwfHwwfHx8MA%3D%3D',
      'wildfire': 'https://plus.unsplash.com/premium_photo-1688431299374-0db7511bb2ec?w=1080&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8d2lsZGZpcmV8ZW58MHx8MHx8fDA%3D',
      'cyclone': 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?w=1080&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Y3ljbG9uZXxlbnwwfHwwfHx8MA%3D%3D',
      'landslide': 'https://images.unsplash.com/photo-1731001209566-b6cce9b19a56?w=1080&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bGFuZHNsaWRlfGVufDB8fDB8fHww',
      'volcano': 'https://images.unsplash.com/photo-1497002961800-ea7dbfe18696?w=1080&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8dm9sY2Fub3xlbnwwfHwwfHx8MA%3D%3D',
      'storm': 'https://images.unsplash.com/photo-1561485132-59468cd0b553?w=1080&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8c3Rvcm18ZW58MHx8MHx8fDA%3D',
      'hurricane': 'https://plus.unsplash.com/premium_photo-1726260211838-2860249d55d3?w=1080&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8aHVycmljYW5lfGVufDB8fDB8fHww',
    };

    // Cari gambar yang cocok dengan berbagai variasi nama
    for (var key in disasterImages.keys) {
      if (type.contains(key)) {
        return disasterImages[key]!;
      }
    }

    // Jika tidak cocok, gunakan gambar default khusus bencana
    return 'https://images.unsplash.com/photo-1541873676-2218a1a4aa42?w=1080&auto=format&fit=crop&q=60';
  }

  // Fungsi untuk mendapatkan koordinat
  String _getCoordinates() {
    try {
      final geometry = _detailedDisaster?['geometry'][0]['coordinates'] ??
          widget.disaster['location'].split(',');
      return '${context.translate(
          'coordinates')}: ${geometry[1]}, ${geometry[0]}';
    } catch (e) {
      return context.translate('coordinates_not_available');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(context.translate('loading'))),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final colorScheme = Theme
        .of(context)
        .colorScheme;

    // Parse tanggal
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.tryParse(_getSafeValue('date'));
    } catch (e) {
      parsedDate = null;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar dengan gambar latar
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _getSafeValue('title'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black54,
                      offset: Offset(2.0, 2.0),
                    )
                  ],
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: _getDisasterImage(_getSafeValue('type')),
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                errorWidget: (context, url, error) =>
                    Icon(
                      Icons.error,
                      color: Colors.white,
                    ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  Share.share(
                    'Check out this disaster alert: ${_getSafeValue(
                        'title')} in ${_getSafeValue(
                        'location')} - ${_getSafeValue('description')}',
                  );
                },
              ),
            ],
          ),

          // Konten Detail
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Severity dan Tipe Bencana
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Severity Chip
                    Chip(
                      label: Text(
                        _getSafeValue('severity').toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: _getSeverityColor(
                          _getSafeValue('severity')),
                    ),
                    // Tipe Bencana Chip
                    Chip(
                      label: Text(
                        _getSafeValue('type').toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Colors.blueGrey,
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Informasi Lokasi
                _buildDetailCard(
                  icon: Icons.location_on,
                  iconColor: Colors.red,
                  title: 'Location',
                  content: _getSafeValue('location'),
                ),
                SizedBox(height: 16),

                // Tanggal Bencana
                _buildDetailCard(
                  icon: Icons.calendar_today,
                  iconColor: Colors.blue,
                  title: 'Date',
                  content: parsedDate != null
                      ? DateFormat.yMMMd().format(parsedDate)
                      : 'Unknown Date',
                ),
                SizedBox(height: 16),

                // Koordinat
                _buildDetailCard(
                  icon: Icons.map,
                  iconColor: Colors.green,
                  title: 'Coordinates',
                  content: _getCoordinates(),
                ),
                SizedBox(height: 16),

                // Deskripsi Bencana
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _getSafeValue('description'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),

                // Tombol Darurat
                ElevatedButton.icon(
                  onPressed: () => _showEmergencyBottomSheet(context),
                  icon: Icon(Icons.emergency),
                  label: Text('Emergency Resources'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membangun detail card
  Widget _buildDetailCard(
      {required IconData icon, required Color iconColor, required String title, required String content}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate(title.toLowerCase()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    content,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method untuk mendapatkan nomor darurat berdasarkan negara
  // Method untuk mendapatkan nomor darurat berdasarkan negara
  String _getEmergencyNumberForCountry(String country) {
    final Map<String, String> emergencyNumbers = {
      'United States': '911', // Ini sudah benar
      'Indonesia': '112',
      'United Kingdom': '999',
      'Australia': '000',
      'Canada': '911',
      'India': '112',
      'Singapore': '995',
      'Malaysia': '999',
      'Japan': '119',
      'China': '119',
      'South Korea': '119',
      'France': '112',
      'Germany': '112',
      'Philippines': '117',
      'Thailand': '191',
      'Vietnam': '113',
      'Mexico': '911',
      'Brazil': '190',
      'Russia': '112',
      'Italy': '112',
      'Spain': '112',
      'Netherlands': '112',
      'default': '112'
    };

    return emergencyNumbers[country] ?? emergencyNumbers['default']!;
  }

  // Bottom sheet untuk sumber daya darurat
  // Bottom sheet untuk sumber daya darurat
  void _showEmergencyBottomSheet(BuildContext context) {
    // Dapatkan lokasi dari data bencana
    String location = _getSafeValue('location');

    // Pisahkan negara dari lokasi
    String country = location
        .split(',')
        .last
        .trim();

    // Dapatkan nomor darurat untuk negara tersebut
    String emergencyNumber = _getEmergencyNumberForCountry(country);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.translate('emergency_resources'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.phone, color: Colors.red),
                title: Text(context.translate('emergency_services')),
                subtitle: Text(
                    '${context.translate(
                        'call_emergency')} $emergencyNumber ($country)'
                ),
                onTap: () async {
                  final Uri phoneUri = Uri.parse('tel:$emergencyNumber');
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            context.translate('could_not_launch_call')),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.location_city, color: Colors.blue),
                title: Text(context.translate('local_disaster_management')),
                subtitle: Text(
                    '${context.translate('contacting_authorities')} $country'
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${context.translate(
                              'contacting_authorities')} $country'
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}