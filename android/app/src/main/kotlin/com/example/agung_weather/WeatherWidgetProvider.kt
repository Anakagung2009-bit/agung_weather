package com.example.agung_weather

import android.Manifest
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.os.Looper
import android.util.Log
import android.widget.RemoteViews
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.*
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.io.BufferedReader
import java.io.InputStreamReader

class WeatherWidgetProvider : AppWidgetProvider() {
    companion object {
        private const val API_KEY = "48f97dbc04acb75d0677c86f678fca93"
        private const val TAG = "WeatherWidgetProvider"
        private const val PREFS_NAME = "WeatherWidgetPrefs"
        private const val UPDATE_INTERVAL = 30 * 60 * 1000L // 30 menit
        const val ACTION_UPDATE_WIDGET = "com.agungdev.weather.UPDATE_WIDGET"
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d(TAG, "Widget provider enabled")
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d(TAG, "Widget provider disabled")
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        // Handle update intent
        when (intent.action) {
            ACTION_UPDATE_WIDGET,
            AppWidgetManager.ACTION_APPWIDGET_UPDATE,
            Intent.ACTION_BOOT_COMPLETED -> {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val componentName = ComponentName(context, WeatherWidgetProvider::class.java)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)

                // Trigger update
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Iterasi melalui semua widget
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        // Buat RemoteViews
        val views = RemoteViews(context.packageName, context.resources.getIdentifier("weather_widget", "layout", context.packageName))

        // Ambil data tersimpan dari SharedPreferences
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val savedCity = prefs.getString("city_$appWidgetId", "Mencari Lokasi...")
        val savedTemp = prefs.getString("temp_$appWidgetId", "-")
        val savedDesc = prefs.getString("desc_$appWidgetId", "Memuat...")
        val savedTimestamp = prefs.getLong("timestamp_$appWidgetId", 0)

        // Set data tersimpan
        updateWidgetViews(context, views, savedCity, savedTemp, savedDesc)

        // Update widget sementara
        appWidgetManager.updateAppWidget(appWidgetId, views)

        // Cek apakah data perlu diperbarui
        val currentTime = System.currentTimeMillis()
        val shouldUpdateWeather = currentTime - savedTimestamp > UPDATE_INTERVAL

        if (shouldUpdateWeather) {
            fetchWeatherAndUpdateWidget(context, appWidgetManager, appWidgetId, views)
        }
    }

    private fun fetchWeatherAndUpdateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        views: RemoteViews
    ) {
        getCurrentLocation(context) { location ->
            if (location != null) {
                try {
                    val weatherData = fetchWeatherData(
                        location.latitude.toString(),
                        location.longitude.toString()
                    )

                    // Ekstrak data cuaca
                    val cityName = weatherData.getString("name")
                    val temperature = weatherData.getJSONObject("main").getDouble("temp").toInt().toString()
                    val description = weatherData.getJSONArray("weather")
                        .getJSONObject(0)
                        .getString("description")
                    val currentTime = System.currentTimeMillis()

                    // Update SharedPreferences
                    updateWidgetPreferences(context, appWidgetId, cityName, temperature, description, currentTime)

                    // Update UI di main thread
                    android.os.Handler(context.mainLooper).post {
                        updateWidgetViews(context, views, cityName, temperature, description)
                        appWidgetManager.updateAppWidget(appWidgetId, views)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error fetching weather", e)
                }
            } else {
                Log.e(TAG, "Failed to get location")
            }
        }
    }

    private fun updateWidgetViews(
        context: Context,
        views: RemoteViews,
        city: String?,
        temp: String?,
        desc: String?
    ) {
        views.setTextViewText(
            context.resources.getIdentifier("city_name", "id", context.packageName),
            city ?: "Lokasi Tidak Tersedia"
        )
        views.setTextViewText(
            context.resources.getIdentifier("temperature", "id", context.packageName),
            "${temp ?: "-"}°C"
        )
        views.setTextViewText(
            context.resources.getIdentifier("weather_description", "id", context.packageName),
            desc ?: "Memuat..."
        )
    }

    private fun updateWidgetPreferences(
        context: Context,
        appWidgetId: Int,
        cityName: String,
        temperature: String,
        description: String,
        timestamp: Long
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().apply {
            putString("city_$appWidgetId", cityName)
            putString("temp_$appWidgetId", temperature)
            putString("desc_$appWidgetId", description)
            putLong("timestamp_$appWidgetId", timestamp)
        }.apply()
    }

    private fun getCurrentLocation(context: Context, callback: (Location?) -> Unit) {
        // Cek izin lokasi
        if (!checkLocationPermission(context)) {
            Log.e(TAG, "Location permissions not granted")
            callback(null)
            return
        }

        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)

        // Cek lokasi terakhir tersimpan di SharedPreferences
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val lastValidLat = prefs.getFloat("last_valid_latitude", 0f)
        val lastValidLon = prefs.getFloat("last_valid_longitude", 0f)
        val lastValidTimestamp = prefs.getLong("last_valid_location_timestamp", 0)

        // Jika lokasi terakhir kurang dari 24 jam yang lalu, gunakan
        val currentTime = System.currentTimeMillis()
        val isLastLocationValid = currentTime - lastValidTimestamp < 24 * 60 * 60 * 1000
                && lastValidLat != 0f
                && lastValidLon != 0f

        // Timeout handler
        val handler = android.os.Handler(Looper.getMainLooper())
        val timeoutRunnable = Runnable {
            Log.e(TAG, "Location retrieval timed out")

            // Gunakan lokasi terakhir yang valid jika ada
            if (isLastLocationValid) {
                val fallbackLocation = Location("fallback").apply {
                    latitude = lastValidLat.toDouble()
                    longitude = lastValidLon.toDouble()
                }
                callback(fallbackLocation)
            } else {
                callback(null)
            }
        }

        // Set timeout 20 detik
        handler.postDelayed(timeoutRunnable, 20000)

        try {
            fusedLocationClient.lastLocation.addOnSuccessListener { location: Location? ->
                // Batalkan timeout jika lokasi ditemukan
                handler.removeCallbacks(timeoutRunnable)

                if (location != null && isLocationAccurate(location)) {
                    // Simpan lokasi valid
                    prefs.edit().apply {
                        putFloat("last_valid_latitude", location.latitude.toFloat())
                        putFloat("last_valid_longitude", location.longitude.toFloat())
                        putLong("last_valid_location_timestamp", currentTime)
                    }.apply()

                    Log.d(TAG, "Location found: ${location.latitude}, ${location.longitude}")
                    callback(location)
                    return@addOnSuccessListener
                }

                // Jika lokasi tidak akurat, minta update
                requestLocationUpdate(context, fusedLocationClient, callback) { accurateLocation ->
                    if (accurateLocation != null) {
                        // Batalkan timeout
                        handler.removeCallbacks(timeoutRunnable)

                        // Simpan lokasi valid
                        prefs.edit().apply {
                            putFloat("last_valid_latitude", accurateLocation.latitude.toFloat())
                            putFloat("last_valid_longitude", accurateLocation.longitude.toFloat())
                            putLong("last_valid_location_timestamp", currentTime)
                        }.apply()

                        callback(accurateLocation)
                    }
                }
            }.addOnFailureListener { e ->
                // Batalkan timeout
                handler.removeCallbacks(timeoutRunnable)

                // Gunakan lokasi terakhir yang valid jika ada
                if (isLastLocationValid) {
                    val fallbackLocation = Location("fallback").apply {
                        latitude = lastValidLat.toDouble()
                        longitude = lastValidLon.toDouble()
                    }
                    callback(fallbackLocation)
                } else {
                    Log.e(TAG, "Failed to get location", e)
                    callback(null)
                }
            }
        } catch (e: SecurityException) {
            // Batalkan timeout
            handler.removeCallbacks(timeoutRunnable)

            Log.e(TAG, "Security exception when accessing location", e)
            callback(null)
        }
    }

    private fun requestLocationUpdate(
        context: Context,
        fusedLocationClient: FusedLocationProviderClient,
        callback: (Location?) -> Unit,
        accurateCallback: ((Location) -> Unit)? = null
    ) {
        val locationRequest = LocationRequest.create().apply {
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
            interval = 10000
            fastestInterval = 5000
            numUpdates = 3 // Minta beberapa update
        }

        val locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                val locations = locationResult.locations
                val accurateLocation = locations.firstOrNull { isLocationAccurate(it) }

                if (accurateLocation != null) {
                    Log.d(TAG, "Accurate location found: ${accurateLocation.latitude}, ${accurateLocation.longitude}")
                    accurateCallback?.invoke(accurateLocation)
                    callback(accurateLocation)
                    fusedLocationClient.removeLocationUpdates(this)
                } else if (locations.isNotEmpty()) {
                    // Jika tidak ada lokasi akurat, kirim lokasi terakhir
                    val lastLocation = locations.last()
                    callback(lastLocation)
                    fusedLocationClient.removeLocationUpdates(this)
                }
            }
        }

        try {
            fusedLocationClient.requestLocationUpdates(
                locationRequest,
                locationCallback,
                Looper.getMainLooper()
            )
        } catch (e: SecurityException) {
            Log.e(TAG, "Security exception when requesting location updates", e)
            callback(null)
        }
    }

    private fun isLocationAccurate(location: Location): Boolean {
        return location.accuracy < 100 && // Akurasi kurang dari 100 meter
                System.currentTimeMillis() - location.time < 5 * 60 * 1000 // Lokasi kurang dari 5 menit
    }

    private fun fetchWeatherData(lat: String, lon: String): JSONObject {
        val url = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$API_KEY&units=metric"

        val connection = URL(url).openConnection() as HttpURLConnection
        connection.requestMethod = "GET"
        connection.connect()

        val responseCode = connection.responseCode
        if (responseCode == HttpURLConnection.HTTP_OK) {
            val reader = BufferedReader(InputStreamReader(connection.inputStream))
            val response = StringBuilder()
            reader.forEachLine { response.append(it) }
            reader.close()
            return JSONObject(response.toString())
        } else {
            throw Exception("Failed to fetch weather data: $responseCode")
        }
    }

    private fun checkLocationPermission(context: Context): Boolean {
        return ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
                ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
    }
}