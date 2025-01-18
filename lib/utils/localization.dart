import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class Localization {
  static final Map<String, Map<String, String>> _localizations = {
    'en': {
      'settings': 'Settings',
      'app_settings': 'App Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'temperature_unit': 'Temperature Unit',
      'weather_notifications': 'Weather Notifications',
      'about': 'About',
      'login': 'Login',
      'logout': 'Logout',
      'celsius': 'Celsius',
      'fahrenheit': 'Fahrenheit',
      'logout_success': 'Logged out successfully',
      'logout_failed': 'Logout failed',
      'select_language': 'Select Language',
      'about': 'About',
      'weather_app_info': 'A comprehensive weather application',
      'developed_by': 'Developed by Agung with ❤️',

      // Spalsh
      'initializing': 'Initializing...',

      // Home Content
      'search_city_hint1': 'Agung Weather',
      'search_city_hint2': 'Search a city...',
      'search_city_hint3': 'Enter city name',
      'search_city_hint4': 'Find your weather',
      'city_not_found': 'City not found',
      'weather_search_failed': 'Failed to search weather',
      'app_name': 'Agung Weather',

      // Login
      'welcome_back': 'Welcome Back',
      'create_account': 'Create Account',
      'email': 'Email',
      'password': 'Password',
      'invalid_email': 'Please enter a valid email',
      'password_too_short': 'Password must be at least 6 characters',
      'login': 'Login',
      'register': 'Register',
      'already_have_account': 'Already have an account? Login',

    //   Search Screen

      'weather_search': 'Weather Search',
      'search_city_hint': 'Search city or country...',
      'quick_picks': 'Quick Picks',
      'explore_map': 'Explore Map',
      'start_searching': 'Start searching for a city',
      'unable_to_find_weather': 'Unable to find weather for {city}',
      'added_to_saved_locations': 'Added {city} to saved locations',
      'start_typing_to_search': 'Start Typing to Search',

    //   Details Weather
      'ai_weather_insights': 'AI Weather Insights',
      'chance_of_rain': 'Chance of Rain',
      'no_forecast_data': 'No forecast data available',
      'sunrise': 'Sunrise',
      'sunset': 'Sunset',
      'min_temp': 'Min Temp',
      'max_temp': 'Max Temp',
      'wind_speed': 'Wind Speed',
      'wind_direction': 'Wind Direction',

      'ai_weather_prompt_template': 'Provide a detailed and engaging weather summary based on these details:',
      'ai_weather_prompt_instructions': 'Give a conversational explanation about the current weather conditions, what to expect, and any potential impacts. Use a friendly and informative tone.',
      'unable_to_generate_summary': 'Unable to generate weather summary.',
      'error_generating_insights': 'Error generating weather insights',

    //   WOrld map
      'world_weather_map': 'World Weather Map',
      'failed_to_fetch_weather': 'Failed to fetch weather data',
      'added_to_saved_locations': 'Added {city} to saved locations',
      'add_location': 'Add Location',
      'temperature': 'Temperature',
      'feels_like': 'Feel like',
      'wind': 'Wind',
      'see_details': 'See Details',

    //   Kondisi Cuaca world map
      // Kondisi Cuaca
      'clear_sky_day': 'Clear Sky (Day)',
      'clear_sky_night': 'Clear Sky (Night)',
      'few_clouds_day': 'Few Clouds (Day)',
      'few_clouds_night': 'Few Clouds (Night)',
      'scattered_clouds': 'Scattered Clouds',
      'broken_clouds': 'Cloudy',
      'shower_rain': 'Light Rain',
      'rain_day': 'Rain (Day)',
      'rain_night': 'Rain (Night)',
      'thunderstorm': 'Thunderstorm',
      'snow': 'Snow',
      'mist': 'Misty',
      'unknown_weather': 'Unknown Weather',

    //   Added Location
      'please_login_add_locations': 'Please login to add your locations',
      'no_locations_added': 'No locations added yet',
      'login': 'Login',

    //   sidebar
      'app_tagline': 'Your personal weather companion',
      'dashboard': 'Dashboard',
      'locations': 'Locations',
      'settings': 'Settings',
      'user': 'User',
      'not_logged_in': 'Not logged in',

      // Pesan Lokasi
      'fetching_location': 'Fetching location...',
      'unknown_error': 'Unknown error',
      'retry': 'Retry',
      'location_services_disabled': 'Location Services Disabled',
      'location_permission_required': 'Location permission is required',
      'turn_on_location': 'Turn On Location',
      // Deskripsi cuaca
      'clear_sky_day': 'Clear sky',
      'clear_sky_night': 'Clear sky',
      'few_clouds_day': 'Few clouds',
      'few_clouds_night': 'Few clouds',
      'scattered_clouds': 'Scattered clouds',
      'broken_clouds': 'Broken clouds',
      'shower_rain': 'Shower rain',
      'rain_day': 'Rain',
      'rain_night': 'Rain',
      'thunderstorm': 'Thunderstorm',
      'snow': 'Snow',
      'mist': 'Mist',
      'unknown_weather': 'Unknown weather',

    //   navbar
      'dashboard': 'Dashboard',
      'locations': 'Locations',
      'settings': 'Settings',

      'select_temperature_unity': 'Select Temperature Unit',

      'global_disaster_alert': 'Global Disaster Alert',
      "potential_disaster_detected": "Potential Disaster Detected in Your Area",
      "no_immediate_disaster_threat": "No Immediate Disaster Threat",
      "failed_fetch_disaster_data": "Failed to fetch disaster data",
      "error_fetching_disaster_data": "Error fetching disaster data",
      "nearby_disasters": "Nearby Disasters:",
      'local_disaster_status': 'Local Disaster Status',
      "search_disasters_hint": "Search disasters by location or type",
      "disaster_alerts": "Disaster Alerts",

      "emergency_resources": "Emergency Resources",
      "emergency_services": "Emergency Services",
      "local_disaster_management": "Local Disaster Management",
      "call_emergency": "Call %s (%s)",
      "contacting_authorities": "Contacting local authorities in %s",
      "could_not_launch_call": "Could not launch emergency call",

      "location": "Location",
      "date": "Date",
      "coordinates": "Coordinates",

      "login_with_google": "Login with Google",
      "or": "or",

    },



    'id': {
      'settings': 'Pengaturan',
      'app_settings': 'Pengaturan Aplikasi',
      'dark_mode': 'Mode Gelap',
      'language': 'Bahasa',
      'temperature_unit': 'Unit Suhu',
      'weather_notifications': 'Notifikasi Cuaca',
      'about': 'Tentang',
      'login': 'Masuk',
      'logout': 'Keluar',
      'celsius': 'Celsius',
      'fahrenheit': 'Fahrenheit',
      'logout_success': 'Berhasil keluar',
      'logout_failed': 'Gagal keluar',
      'select_language': 'Pilih Bahasa',
      'about': 'Tentang',
      'weather_app_info': 'Aplikasi cuaca yang komprehensif',
      'developed_by': 'Dikembangkan oleh Agung dengan ❤️',
      'initializing': 'Memuat...',
      'app_name': 'Agung Weather',
      'search_city_hint1': 'Cuaca Agung',
      'search_city_hint2': 'Cari kota...',
      'search_city_hint3': 'Masukkan nama kota',
      'search_city_hint4': 'Temukan cuacamu',
      'city_not_found': 'Kota tidak ditemukan',
      'weather_search_failed': 'Gagal mencari cuaca',

      'welcome_back': 'Selamat Datang Kembali',
      'create_account': 'Buat Akun',
      'email': 'Email',
      'password': 'Kata Sandi',
      'invalid_email': 'Masukkan email yang valid',
      'password_too_short': 'Kata sandi harus minimal 6 karakter',
      'login': 'Masuk',
      'register': 'Daftar',
      'already_have_account': 'Sudah punya akun? Masuk',

      'weather_search': 'Pencarian Cuaca',
      'search_city_hint': 'Cari kota atau negara...',
      'quick_picks': 'Pilihan Cepat',
      'explore_map': 'Jelajahi Peta',
      'start_searching': 'Mulai mencari kota',
      'unable_to_find_weather': 'Tidak dapat menemukan cuaca untuk {city}',
      'added_to_saved_locations': 'Menambahkan {city} ke lokasi tersimpan',

    //   Details
      'ai_weather_insights': 'Wawasan Cuaca AI',
      'chance_of_rain': 'Peluang Hujan',
      'no_forecast_data': 'Tidak ada data prakiraan',
      'sunrise': 'Matahari Terbit',
      'sunset': 'Matahari Terbenam',
      'min_temp': 'Suhu Min',
      'max_temp': 'Suhu Maks',
      'wind_speed': 'Kecepatan Angin',
      'wind_direction': 'Arah Angin',

      'ai_weather_prompt_template': 'Berikan ringkasan cuaca yang detail dan menarik berdasarkan detail berikut:',
      'ai_weather_prompt_instructions': 'Berikan penjelasan percakapan tentang kondisi cuaca saat ini, apa yang diharapkan, dan potensi dampaknya. Gunakan nada yang ramah dan informatif.',
      'unable_to_generate_summary': 'Tidak dapat membuat ringkasan cuaca.',
      'error_generating_insights': 'Kesalahan menghasilkan wawasan cuaca',

    //   World map
      'world_weather_map': 'Peta Cuaca Dunia',
      'failed_to_fetch_weather': 'Gagal mengambil data cuaca',
      'added_to_saved_locations': 'Menambahkan {city} ke lokasi tersimpan',
      'add_location': 'Tambah Lokasi',
      'temperature': 'Suhu',
      'feels_like': 'Terasa seperti',
      'wind': 'Angin',
      'see_details': 'Lihat Detail',

      'clear_sky_day': 'Cerah (Siang)',
      'clear_sky_night': 'Cerah (Malam)',
      'few_clouds_day': 'Sedikit Berawan (Siang)',
      'few_clouds_night': 'Sedikit Berawan (Malam)',
      'scattered_clouds': 'Awan Terpencar',
      'broken_clouds': 'Mendung',
      'shower_rain': 'Hujan Ringan',
      'rain_day': 'Hujan (Siang)',
      'rain_night': 'Hujan (Malam)',
      'thunderstorm': 'Badai Petir',
      'snow': 'Salju',
      'mist': 'Berkabut',
      'unknown_weather': 'Cuaca Tidak Dikenal',

    //   Added location
      'please_login_add_locations': 'Silakan login untuk menambahkan lokasi',
      'no_locations_added': 'Belum ada lokasi ditambahkan',
      'login': 'Login',

    //   Sidebar
      'app_tagline': 'Pendamping Cuaca Pribadi Anda',
      'dashboard': 'Dasbor',
      'locations': 'Lokasi',
      'settings': 'Pengaturan',
      'user': 'Pengguna',
      'not_logged_in': 'Belum login',

      // Pesan Lokasi
      'fetching_location': 'Mengambil lokasi...',
      'unknown_error': 'Kesalahan tidak diketahui',
      'retry': 'Coba lagi',
      'location_services_disabled': 'Layanan Lokasi Dinonaktifkan',
      'location_permission_required': 'Izin lokasi diperlukan',
      'turn_on_location': 'Aktifkan Lokasi',
    //   Deskripsi
      'clear_sky_day': 'Langit cerah',
      'clear_sky_night': 'Langit cerah',
      'few_clouds_day': 'Sedikit awan',
      'few_clouds_night': 'Sedikit awan',
      'scattered_clouds': 'Awan tersebar',
      'broken_clouds': 'Awan mendung',
      'shower_rain': 'Hujan ringan',
      'rain_day': 'Hujan',
      'rain_night': 'Hujan',
      'thunderstorm': 'Badai',
      'snow': 'Salju',
      'mist': 'Kabut',
      'unknown_weather': 'Cuaca tidak diketahui',

    //   Navbar
      'dashboard': 'Dasbor',
      'locations': 'Lokasi',
      'settings': 'Pengaturan',

      'start_typing_to_search': 'Mulai mengetik untuk mencari',

      'select_temperature_unity': 'Pilih Unit Temperatur',

      'global_disaster_alert': 'Peringatan Bencana Global',
      "potential_disaster_detected": "Bencana Potensial Terdeteksi di Daerah Anda",
      "no_immediate_disaster_threat": "Tidak Ada Ancaman Bencana Langsung",
      "failed_fetch_disaster_data": "Gagal mengambil data bencana",
      "error_fetching_disaster_data": "Kesalahan saat mengambil data bencana",
      "nearby_disasters": "Bencana Terdekat:",
      'local_disaster_status': 'Status Bencana Lokal',
      "search_disasters_hint": "Cari bencana berdasarkan lokasi atau tipe",
      "disaster_alerts": "Peringatan Bencana",

      "emergency_resources": "Sumber Daya Darurat",
      "emergency_services": "Layanan Darurat",
      "local_disaster_management": "Manajemen Bencana Lokal",
      "call_emergency": "Hubungi %s (%s)",
      "contacting_authorities": "Menghubungi otoritas lokal di %s",
      "could_not_launch_call": "Tidak dapat membuat panggilan darurat",
      "location": "Lokasi",
      "date": "Tanggal",
      "coordinates": "Koordinat",

      "login_with_google": "Masuk dengan Google",
      "or": "atau",

    }
  };

  static String translate(BuildContext context, String key) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return _localizations[themeProvider.locale.languageCode]?[key] ?? key;
  }
}

// Extension untuk mempermudah penggunaan
extension TranslationExtension on BuildContext {
  String translate(String key) {
    return Localization.translate(this, key);
  }
}