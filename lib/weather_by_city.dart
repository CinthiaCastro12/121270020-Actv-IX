import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherByCityScreen extends StatefulWidget {
  @override
  _WeatherByCityScreenState createState() => _WeatherByCityScreenState();
}

class _WeatherByCityScreenState extends State<WeatherByCityScreen> {
  final TextEditingController cityController = TextEditingController();
  String? weatherInfo;
  bool isLoading = false;

  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) {
      setState(() {
        weatherInfo = 'Por favor, ingrese una ciudad.';
      });
      return;
    }

    final apiKey = '4281723c20c373e5c2da76c16f5d9a86'; // API Key
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    setState(() {
      isLoading = true;
      weatherInfo = null; // Limpia la información anterior.
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
          weatherInfo = 'Error al obtener datos. Verifica el nombre de la ciudad.';
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
        title: Text('Consultar por Ciudad'),
        backgroundColor: Colors.blueAccent,
      ),
      resizeToAvoidBottomInset: true, // Permite que el contenido se ajuste cuando se abre el teclado
      body: Container(
        // El Container que envuelve todo para aplicar el gradiente al fondo completo
        width: double.infinity, // Hace que el contenedor ocupe todo el ancho
        height: double.infinity, // Hace que el contenedor ocupe todo el alto
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView( // Agregado para permitir desplazamiento
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Consulta del Clima',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.shade700,
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la ciudad',
                    labelStyle: TextStyle(color: Colors.blueAccent.shade700),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final city = cityController.text.trim();
                    fetchWeather(city);
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
                SizedBox(height: 20),
                isLoading
                    ? Center(child: CircularProgressIndicator()) // Indicador de carga
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
      ),
    );
  }
}
