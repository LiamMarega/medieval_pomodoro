# 🎵 Funcionalidades de Música Medieval Lofi

## Características Implementadas

### 🎼 Reproducción Automática
- La música lofi se reproduce automáticamente al iniciar el temporizador
- Archivo: `assets/songs/medieval_lofi.mp3`
- Reproducción en bucle continuo

### 🔊 Control de Volumen Gradual
- **Fade In**: El volumen aumenta gradualmente desde 0 hasta 0.7 (70%)
- **Fade Out**: El volumen disminuye gradualmente hasta 0 antes de pausar
- **Incremento**: 0.05 cada 500ms para una transición suave
- **Volumen máximo**: 70% para no ser demasiado fuerte

### 🎛️ Controles de Música
- **Botón MUSIC ON/OFF**: Activa/desactiva la funcionalidad de música
- **Indicador visual**: Muestra el estado de la música (ON/OFF/Reproduciendo)
- **Indicador de carga**: Muestra cuando la música está cargando

### ⏰ Integración con el Temporizador
- **Inicio automático**: La música comienza cuando se inicia el timer
- **Pausa automática**: La música se detiene cuando se pausa el timer
- **Reinicio**: La música se detiene al reiniciar el timer
- **Finalización**: La música se detiene al completar una sesión

### 🔄 Transición Automática
- Después de 25 minutos de trabajo, automáticamente cambia al tiempo de pausa
- La música se detiene al finalizar la sesión de trabajo
- El siguiente timer se inicia automáticamente después de 2 segundos

## Dependencias Utilizadas

```yaml
just_audio: ^0.9.36
```

## Configuración

1. Asegúrate de que el archivo `medieval_lofi.mp3` esté en `assets/songs/`
2. El archivo ya está incluido en `pubspec.yaml` bajo assets
3. Ejecuta `flutter pub get` para instalar las dependencias

## Uso

1. **Activar música**: Presiona el botón "MUSIC ON" en los controles
2. **Iniciar timer**: Presiona "PLAY" - la música comenzará automáticamente
3. **Pausar**: Presiona "STOP" - la música se detendrá gradualmente
4. **Reiniciar**: Presiona "RESTART" - la música se detendrá

## Estados Visuales

- **Música desactivada**: Icono gris con "OFF"
- **Música activada**: Icono dorado con "ON"
- **Reproduciendo**: Icono dorado con "ON" + punto verde
- **Cargando**: Indicador de progreso circular dorado
