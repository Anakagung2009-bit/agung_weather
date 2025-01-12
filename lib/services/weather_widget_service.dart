import 'package:home_widget/home_widget.dart';

class WeatherWidgetService {
  static Future<void> updateWidget() async {
    await HomeWidget.saveWidgetData<String>('cityName', 'Jakarta');
    await HomeWidget.saveWidgetData<String>('temperature', '28°C');
    await HomeWidget.saveWidgetData<String>('description', 'Cerah Berawan');

    await HomeWidget.updateWidget(
      name: 'WeatherWidgetProvider',
      iOSName: 'WeatherWidget',
    );
  }
}