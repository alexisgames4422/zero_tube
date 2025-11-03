# Eli Player

Aplicación Flutter multiplataforma (Android, Windows y Linux) para descargar y reproducir contenido de YouTube localmente.

## Características
- Interfaz moderna con esquema pastel (menta y azul hielo).
- Dos pestañas principales: **Descargas** y **Biblioteca**.
- Descargas de audio (MP3) o video (MP4) usando `yt-dlp` en escritorios.
- Barra de progreso animada y notificaciones locales en pantalla.
- Biblioteca con miniaturas, duración, reproducción integrada y eliminación.
- Reproductor embebido con `just_audio` (audio) y `video_player` (video).
- Animaciones suaves con `flutter_animate` y tipografía `Google Fonts`.

## Requisitos previos
1. Flutter 3.19 o superior instalado y configurado.
2. `yt-dlp` disponible en el PATH del sistema (solo necesario en Windows/Linux/macOS).
3. Entornos de compilación configurados para Android (SDK) y escritorios (dependencias de Flutter desktop).

## Configuración
```bash
flutter pub get
```

### Desktop
```bash
flutter run -d windows   # o linux
```

### Android
```bash
flutter run -d android
```

> Nota: Las descargas con `yt-dlp` solo están habilitadas en escritorios. En Android verás un mensaje informativo.

## Estructura principal
```
lib/
 ├── app.dart
 ├── main.dart
 ├── models/
 ├── pages/
 ├── services/
 ├── theme/
 ├── utils/
 └── widgets/
```

## Descargas con `yt-dlp`
- Se guardan en `EliPlayer/media` dentro del directorio de soporte de la aplicación.
- Las miniaturas de video se generan en `.thumbnails`.

## Licencia
Proyecto no destinado a publicación en pub.dev (`publish_to: none`).
