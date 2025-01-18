import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'disaster_detail_screen.dart';

class CountryDisasterScreen extends StatefulWidget {
  @override
  _CountryDisasterScreenState createState() => _CountryDisasterScreenState();
}

class _CountryDisasterScreenState extends State<CountryDisasterScreen> {
  List<String> _countries = [
    'Indonesia', 'Malaysia', 'Singapore', 'Philippines',
    'Thailand', 'Vietnam', 'Cambodia', 'Myanmar',
    'Brunei', 'Timor-Leste'
  ];

  String _selectedCountry = 'Indonesia';
  List<dynamic> _disasters = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDisastersByCountry();
  }

  Future<void> _fetchDisastersByCountry() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final url = Uri.parse(
          'https://api.reliefweb.int/v1/reports?filter[query][value]=$_selectedCountry'
      );

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          _disasters = responseData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load disasters');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disasters in $_selectedCountry'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: _countries.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value!;
                });
                _fetchDisastersByCountry();
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 100),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: _fetchDisastersByCountry,
              child: Text('Retry'),
            )
          ],
        ),
      )
          : _disasters.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 16),
            Text(
              'No Disaster Reports for $_selectedCountry',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _disasters.length,
        itemBuilder: (context, index) {
          final disaster = _disasters[index]['fields'];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                disaster['title'] ?? 'Untitled Disaster',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disaster['disaster']?['type']?['name'] ?? 'Unknown Type',
                  ),
                  Text(
                    disaster['date']?['created'] ?? 'Unknown Date',
                  ),
                ],
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisasterDetailScreen(
                      disaster: {
                        'title': disaster['title'] ?? 'Untitled Disaster',
                        'type': disaster['disaster']?['type']?['name'] ?? 'Unknown',
                        'severity': disaster['disaster']?['severity']?['name'] ?? 'Low',
                        'location': disaster['country']?.map((c) => c['name']).join(', ') ?? 'Unknown Location',
                        'date': disaster['date']?['created'] ?? '',
                        'description': disaster['description'] ?? 'No description available',
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}