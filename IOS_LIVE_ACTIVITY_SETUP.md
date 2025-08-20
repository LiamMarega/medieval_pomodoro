# iOS Live Activity Setup Guide

## 🔧 **Configuración Requerida en Xcode**

Para que Live Activities funcionen correctamente, necesitas configurar Xcode manualmente:

### **1. Abrir el Proyecto en Xcode**

```bash
cd ios
open Runner.xcworkspace
```

### **2. Configurar App Groups**

1. **Selecciona el target "Runner"** en Xcode
2. **Ve a "Signing & Capabilities"**
3. **Haz clic en "+ Capability"**
4. **Busca y agrega "App Groups"**
5. **Haz clic en "+" para agregar un grupo**
6. **Agrega: `group.com.medieval.pomodoro`**

### **3. Verificar Bundle Identifier**

1. **En "Signing & Capabilities"**
2. **Asegúrate de que el Bundle Identifier sea único**
3. **Ejemplo: `com.tuempresa.medievalpomodoro`**

### **4. Configurar Team de Desarrollo**

1. **En "Signing & Capabilities"**
2. **Selecciona tu "Team" de desarrollo**
3. **Asegúrate de que el perfil de provisionamiento incluya App Groups**

### **5. Verificar Info.plist**

El archivo ya está configurado con:
- `NSSupportsLiveActivities` = `true`
- `CFBundleURLTypes` con scheme `medievalpomodoro`

### **6. Verificar Runner.entitlements**

El archivo ya está configurado con:
- `com.apple.security.application-groups` = `group.com.medieval.pomodoro`

## 🧪 **Testing**

### **Requisitos del Dispositivo**
- **iOS 16.1 o superior**
- **Dispositivo físico** (no simulador para mejor testing)
- **Cuenta de desarrollador** (gratuita o paga)

### **Pasos de Testing**

1. **Conecta un dispositivo iOS 16.1+**
2. **Ejecuta la app desde Xcode**
3. **Inicia un timer**
4. **Pon la app en segundo plano**
5. **Verifica que aparece la Live Activity**

## 🔍 **Debugging**

### **Logs a Buscar**

```
🚀 Initializing Live Activity service...
✅ Live Activity service initialized successfully
🔍 Live Activity available: true
✅ Timer state synced with Live Activity
```

### **Errores Comunes**

1. **"ActivityInput error 0"**
   - Verificar App Groups en Xcode
   - Verificar Bundle Identifier
   - Verificar Team de desarrollo

2. **"Live Activities not available"**
   - Verificar versión de iOS (16.1+)
   - Verificar permisos del dispositivo

3. **"can't launch live activity"**
   - Verificar configuración en Xcode
   - Limpiar y rebuildear el proyecto

## 🛠️ **Solución de Problemas**

### **Si el Error Persiste**

1. **Limpia el proyecto:**
   ```bash
   flutter clean
   cd ios
   pod deintegrate
   pod install
   cd ..
   flutter pub get
   ```

2. **En Xcode:**
   - Product → Clean Build Folder
   - Product → Build

3. **Verifica el dispositivo:**
   - Ajustes → Privacidad y Seguridad → Live Activities
   - Asegúrate de que la app tenga permisos

### **Configuración Alternativa**

Si sigues teniendo problemas, puedes usar un App Group ID más simple:

```dart
appGroupId: 'group.medievalpomodoro',
```

Y actualizar el archivo `Runner.entitlements`:

```xml
<string>group.medievalpomodoro</string>
```

## 📱 **Notas Importantes**

- **Live Activities solo funcionan en dispositivos físicos** (no simulador)
- **Requiere iOS 16.1 o superior**
- **El usuario debe dar permisos** la primera vez
- **Puede tomar unos segundos** en aparecer la primera vez

## 🆘 **Soporte**

Si sigues teniendo problemas:

1. Verifica que tu cuenta de desarrollador tenga App Groups habilitado
2. Prueba en un dispositivo diferente
3. Verifica que el Bundle Identifier sea único
4. Asegúrate de que el Team de desarrollo esté correctamente configurado
