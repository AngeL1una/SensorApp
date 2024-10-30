import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_tts/flutter_tts.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SensorScreen(),
    );
  }
}

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  // Variables para el giroscopio y acelerómetro
  double _gyroscopeX = 0.0, _gyroscopeY = 0.0, _gyroscopeZ = 0.0;
  double _accelerometerX = 0.0, _accelerometerY = 0.0, _accelerometerZ = 0.0;

  // Variable para la fecha y hora
  String _formattedDateTime = '';

  // Suscripciones a los sensores
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Lista para almacenar los registros de los sensores
  List<List<dynamic>> _sensorData = [];

  // Temporizador para la tasa de muestreo de 100 Hz (cada 10 ms)
  Timer? _samplingTimer;

  // Variables para etiquetas
  List<String> _etiquetas = [
    'etiqueta_1', 'etiqueta_2', 'etiqueta_3', 'etiqueta_4', 'etiqueta_5',
    'etiqueta_6', 'etiqueta_7', 'etiqueta_8', 'etiqueta_9', 'etiqueta_10',
    'etiqueta_fin'
  ];
  int _etiquetaIndex = 0;
  String _etiquetaActual = 'etiqueta_1';
  Timer? _etiquetaTimer;

  // Instancia de FlutterTTS
  FlutterTts _flutterTts = FlutterTts();

  // Ruta del archivo CSV guardado
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  
  void _startSensors() {
 
    _sensorData.clear();

    
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeX = event.x;
        _gyroscopeY = event.y;
        _gyroscopeZ = event.z;
      });
    });

    // Iniciar la suscripción al acelerómetro
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerX = event.x;
        _accelerometerY = event.y;
        _accelerometerZ = event.z;
      });
    });

    // Iniciar el temporizador para capturar a 100 Hz (cada 10 ms)
    _samplingTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      final currentTime = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
      _sensorData.add([
        currentTime,
        _etiquetaActual, // Registrar la etiqueta actual
        _gyroscopeX,
        _gyroscopeY,
        _gyroscopeZ,
        _accelerometerX,
        _accelerometerY,
        _accelerometerZ
      ]);
    });

    // Iniciar el temporizador para cambiar la etiqueta cada 3 minutos
    _etiquetaTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _cambiarEtiqueta();
    });
  }

  // Función para cambiar la etiqueta actual y anunciarla
  void _cambiarEtiqueta() async {
    if (_etiquetaIndex < _etiquetas.length - 1) {
      setState(() {
        _etiquetaIndex++;
        _etiquetaActual = _etiquetas[_etiquetaIndex];
      });

      // Anunciar la nueva etiqueta
      await _flutterTts.speak('Cambiando a $_etiquetaActual');
    } else {
      // Si la etiqueta es 'etiqueta_fin', detener la captura
      _stopSensors();
      await _flutterTts.speak('Etiqueta final alcanzada, fin del registro');
    }
  }

  // Función para detener la captura de datos de los sensores y etiquetas, y guardar en CSV
  Future<void> _stopSensors() async {
    // Detener las suscripciones y los temporizadores
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _samplingTimer?.cancel();
    _etiquetaTimer?.cancel();

    // Guardar los datos en un archivo CSV
    if (_sensorData.isNotEmpty) {
      await _saveToCsv();
    }
  }

  // Función para guardar los datos en un archivo CSV
  Future<void> _saveToCsv() async {
    try {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory?.path}/sensor_data_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(filePath);

      // Convertir la lista de datos a formato CSV
      final csvData = const ListToCsvConverter().convert([
        ['Tiempo', 'Etiqueta', 'GX', 'GY', 'GZ', 'AX', 'AY', 'AZ'],
        ..._sensorData
      ]);

      // Guardar el archivo CSV
      await file.writeAsString(csvData);
      setState(() {
        _filePath = filePath; // Guarda la ruta del archivo
      });
      _showMessage('Datos guardados en: $filePath');
    } catch (e) {
      _showMessage('Error al guardar el archivo: $e');
    }
  }

  // Función para abrir el archivo CSV
  void _openCsvFile() {
    if (_filePath != null) {
      OpenFilex.open(_filePath!);
    } else {
      _showMessage('No se ha guardado ningún archivo.');
    }
  }

  // Función para mostrar un mensaje en pantalla
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Función para actualizar la fecha y hora
  void _updateDateTime() {
    setState(() {
      _formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });

    // Actualizar cada segundo
    Future.delayed(const Duration(seconds: 1), _updateDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 50),

          // Nombre y título en la parte superior
          const Text(
            'Ángel Luna Lugo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'MoonDev',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),

          // Fecha y Hora
          Text(
            _formattedDateTime,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),

          // Mostrar la etiqueta actual
          Text(
            'Etiqueta actual: $_etiquetaActual',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 20),

          // Título del Giroscopio
          const Text(
            'Giroscopio:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Valores del Giroscopio
          Text(
            'GX: ${_gyroscopeX.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'GY: ${_gyroscopeY.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'GZ: ${_gyroscopeZ.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),

          // Título del Acelerómetro
          const Text(
            'Acelerómetro:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Valores del Acelerómetro
          Text(
            'AX: ${_accelerometerX.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'AY: ${_accelerometerY.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'AZ: ${_accelerometerZ.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18),
          ),
          const Spacer(),

          // Botones para Empezar, Detener y Abrir CSV
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _startSensors,
                child: const Text('Empezar'),
              ),
              ElevatedButton(
                onPressed: _stopSensors,
                child: const Text('Detener'),
              ),
              ElevatedButton(
                onPressed: _openCsvFile,
                child: const Text('Abrir CSV'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _samplingTimer?.cancel();
    _etiquetaTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
