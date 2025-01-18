import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'disaster_detail_screen.dart';
import '../utils/localization.dart';

// Import local disaster card
import '../widgets/local_disaster_card.dart';

class DisasterScreen extends StatefulWidget {
  @override
  _DisasterScreenState createState() => _DisasterScreenState();
}

class _DisasterScreenState extends State<DisasterScreen> {
  List<Map<String, dynamic>> _globalDisasters = [];
  List<Map<String, dynamic>> _filteredDisasters = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Daftar kategori bencana
  final List<String> _disasterCategories = [
    'All Categories',
    'Wildfires',
    'Severe Storms',
    'Earthquakes',
    'Volcanoes',
    'Floods'
  ];

  String _selectedCategory = 'All Categories';

  // Tambahkan TextEditingController untuk search
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGlobalDisasterData();
  }

  @override
  void dispose() {
    // Pastikan untuk dispose controller
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchGlobalDisasterData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final url = Uri.parse('https://eonet.gsfc.nasa.gov/api/v3/events');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData == null || responseData['events'] == null) {
          throw Exception('No data found');
        }

        final disasters = (responseData['events'] as List).map((disaster) {
          return {
            'id': disaster['id'],
            'title': disaster['title'] ?? 'Unknown Disaster',
            'description': _getDisasterDescription(disaster),
            'date': disaster['geometry'][0]['date'] ?? DateTime.now().toIso8601String(),
            'location': _getDisasterLocation(disaster),
            'type': disaster['categories'][0]['title'] ?? 'Unspecified',
            'severity': _determineDisasterSeverity(disaster)
          };
        }).toList();

        setState(() {
          _globalDisasters = disasters;
          _filteredDisasters = disasters;
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load disasters. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching disasters: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  // Method untuk melakukan pencarian
  void _searchDisasters(String query) {
    setState(() {
      if (query.isEmpty) {
        // Jika query kosong, kembalikan ke filter kategori sebelumnya
        _filterDisastersByCategory(_selectedCategory);
      } else {
        _filteredDisasters = _globalDisasters.where((disaster) {
          // Cari berdasarkan lokasi atau judul bencana
          return disaster['location'].toString().toLowerCase().contains(query.toLowerCase()) ||
              disaster['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
              disaster['type'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Fungsi untuk mendapatkan deskripsi bencana
  String _getDisasterDescription(dynamic disaster) {
    return 'A ${disaster['categories'][0]['title'] ?? 'disaster'} event detected.';
  }

  // Fungsi untuk mendapatkan lokasi bencana
  String _getDisasterLocation(dynamic disaster) {
    try {
      // Ambil koordinat pertama sebagai representasi lokasi
      var geometry = disaster['geometry'][0];
      return '${geometry['coordinates'][1]}, ${geometry['coordinates'][0]}';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  // Fungsi untuk menentukan tingkat keparahan bencana
  String _determineDisasterSeverity(dynamic disaster) {
    String category = disaster['categories'][0]['title']?.toLowerCase() ?? '';

    if (['wildfires', 'severe storms', 'hurricanes'].contains(category)) {
      return 'Extreme';
    } else if (['earthquakes', 'floods', 'volcanoes'].contains(category)) {
      return 'Severe';
    } else {
      return 'Medium';
    }
  }

  // Fungsi filter berdasarkan kategori
  void _filterDisastersByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All Categories') {
        _filteredDisasters = _globalDisasters;
      } else {
        _filteredDisasters = _globalDisasters.where((disaster) {
          return disaster['type'].toString().contains(category);
        }).toList();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('disaster_alerts')),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchGlobalDisasterData,
          )
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _fetchGlobalDisasterData,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: context.translate('search_disasters_hint'),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterDisastersByCategory(_selectedCategory);
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: _searchDisasters,
              ),
            ),


            // Dropdown Filter Kategori
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.filter_list),
                ),
                items: _disasterCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  _filterDisastersByCategory(value!);
                  // Reset search jika kategori berubah
                  _searchController.clear();
                },
              ),
            ),

            // Local Disaster Card(),
            LocalDisasterCard(),


            // Global Disasters Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(context.translate('global_disaster_alert'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Loading or Error State
            if (_isLoading)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 100,
                      ),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      ElevatedButton(
                        onPressed: _fetchGlobalDisasterData,
                        child: Text('Retry'),
                      )
                    ],
                  ),
                ),
              )
            else if (_filteredDisasters.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 100,
                          color: Colors.green,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No Active Disaster Alerts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredDisasters.length,
                    itemBuilder: (context, index) {
                      final disaster = _filteredDisasters[index];

                      // Parse tanggal
                      DateTime? parsedDate;
                      try {
                        parsedDate = DateTime.parse(disaster['date']);
                      } catch (e) {
                        parsedDate = null;
                      }

                      return Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.warning_rounded,
                            color: _getSeverityColor(disaster['severity']),
                          ),
                          title: Text(
                            disaster['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${disaster['type']} - ${disaster['location']}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                parsedDate != null
                                    ? DateFormat.yMMMd().format(parsedDate)
                                    : 'Unknown Date',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                disaster['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisasterDetailScreen(disaster: disaster),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}