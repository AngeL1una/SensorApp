# SensoresALL 📱 MoonDev

**SensoresALL** es una aplicación móvil desarrollada con Flutter para registrar datos del giroscopio y acelerómetro en tiempo real, generando un archivo CSV con la información recopilada. La app cambia automáticamente entre diferentes etiquetas cada 3 minutos, incluye una etiqueta final para indicar el término del registro, y utiliza texto a voz para anunciar cada cambio de etiqueta.

## Características principales

- 📈 **Captura de datos a 100 Hz** para giroscopio y acelerómetro.
- 🏷️ **Cambio automático de etiquetas** cada 3 minutos, con 10 etiquetas más una etiqueta final ('etiqueta_fin').
- 🗣️ **Texto a voz** que anuncia la etiqueta actual cada vez que cambia.
- 📝 **Generación de archivo CSV** con los datos recopilados, incluyendo la etiqueta activa.
- 📂 **Acceso directo al archivo CSV** desde la app.

## Tecnologías utilizadas

- **Flutter**: Framework de desarrollo para la interfaz de usuario y la lógica de la app.
- **sensors_plus**: Paquete para acceder a los datos del giroscopio y acelerómetro.
- **flutter_tts**: Paquete para implementar la funcionalidad de texto a voz.
- **path_provider**: Paquete para manejar la ubicación de almacenamiento del archivo CSV.
- **csv**: Paquete para convertir datos a formato CSV.
- **open_filex**: Paquete para abrir el archivo CSV generado desde la app.

## Instalación y uso

1. **Clona este repositorio** en tu máquina local:
   ```bash
   git clone https://github.com/AngeL1una/SensorApp.git
