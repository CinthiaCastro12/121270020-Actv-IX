import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherByCoordinatesScreen extends StatefulWidget {
  @override
  _WeatherByCoordinatesScreenState createState() =>
      _WeatherByCoordinatesScreenState();
}

class _WeatherByCoordinatesScreenState
    extends State<WeatherByCoordinatesScreen> {
  final TextEditingController latController = TextEditingController();
  final TextEditingController lonController = TextEditingController();
  String? weatherInfo;
  bool isLoading = false;

  Future<void> fetchWeather(double lat, double lon) async {
    final apiKey = '4281723c20c373e5c2da76c16f5d9a86'; // API Key
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    setState(() {
      isLoading = true;
      weatherInfo = null; // Limpia la información anterior
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherInfo = '''
          Clima: ${data['weather'][0]['main']}
          Descripción: ${data['weather'][0]['description']}
          Temperatura: ${data['main']['temp']} °C
          Sensación térmica: ${data['main']['feels_like']} °C
          Mínima: ${data['main']['temp_min']} °C
          Máxima: ${data['main']['temp_max']} °C
          Presión: ${data['main']['pressure']} hPa
          Humedad: ${data['main']['humidity']}%
          ''';
        });
      } else {
        setState(() {
          weatherInfo = 'Error al obtener datos. Verifica las coordenadas.';
        });
      }
    } catch (e) {
      setState(() {
        weatherInfo = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultar por Coordenadas'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        // Usamos height: double.infinity para asegurarnos de que el Container ocupe toda la pantalla
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView( // Mantiene la posibilidad de hacer scroll
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Consulta del Clima por Coordenadas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700,
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: latController,
                decoration: InputDecoration(
                  labelText: 'Latitud',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: Icon(Icons.location_on, color: Colors.blueAccent),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
              TextField(
                controller: lonController,
                decoration: InputDecoration(
                  labelText: 'Longitud',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: Icon(Icons.location_on, color: Colors.blueAccent),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final latText = latController.text.trim();
                  final lonText = lonController.text.trim();
                  if (latText.isEmpty || lonText.isEmpty) {
                    setState(() {
                      weatherInfo = 'Por favor, ingresa ambas coordenadas.';
                    });
                    return;
                  }
                  final lat = double.tryParse(latText);
                  final lon = double.tryParse(lonText);
                  if (lat != null && lon != null) {
                    fetchWeather(lat, lon);
                  } else {
                    setState(() {
                      weatherInfo = 'Por favor, ingresa coordenadas válidas.';
                    });
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  elevation: MaterialStateProperty.all(5),
                ),
                child: Text(
                  'Consultar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : weatherInfo != null
                      ? Card(
                          elevation: 4,
                          margin: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              weatherInfo!,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
