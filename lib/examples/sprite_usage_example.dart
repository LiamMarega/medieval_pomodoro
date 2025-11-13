import 'package:flutter/material.dart';
import '../widgets/sprite_widget.dart';
import '../widgets/medieval_timer_display.dart';
import '../constants/medieval_sprites.dart';

/// Ejemplo completo de cómo usar los sprites medievales en tu app
/// 
/// Para usar en tu app:
/// 1. Importa el widget que necesites
/// 2. Úsalo como cualquier otro widget de Flutter
class SpriteUsageExampleScreen extends StatelessWidget {
  const SpriteUsageExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medieval Sprites - Ejemplos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '🎨 Sprites Individuales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Ejemplo 1: Usar un sprite directamente
            const Text('Cartel de madera:'),
            const SizedBox(height: 8),
            SpriteWidget(
              imagePath: MedievalSprites.imagePath,
              srcX: MedievalSprites.mediumWoodenPanel.x,
              srcY: MedievalSprites.mediumWoodenPanel.y,
              srcWidth: MedievalSprites.mediumWoodenPanel.width,
              srcHeight: MedievalSprites.mediumWoodenPanel.height,
              width: 150,
              height: 150,
            ),
            
            const SizedBox(height: 30),
            
            // Ejemplo 2: Timer display
            const Text('Timer Display:'),
            const SizedBox(height: 8),
            const MedievalTimerDisplay(
              timeText: '25:00',
              size: 250,
            ),
            
            const SizedBox(height: 30),
            
            // Ejemplo 3: Botones medievales
            const Text('Botones:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                MedievalButton(
                  label: 'START',
                  onPressed: () => debugPrint('Start pressed'),
                  sprite: MedievalSprites.mediumWoodenPanel,
                ),
                MedievalButton(
                  label: 'PAUSE',
                  onPressed: () => debugPrint('Pause pressed'),
                  sprite: MedievalSprites.largeWoodenPanel,
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Ejemplo 4: Paneles de estadísticas
            const Text('Stats Panels:'),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MedievalStatsPanel(
                  title: 'SESSIONS',
                  value: '12',
                ),
                MedievalStatsPanel(
                  title: 'STREAK',
                  value: '5',
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Ejemplo 5: Barra de progreso
            const Text('Progress Bar:'),
            const SizedBox(height: 8),
            const MedievalProgressBar(progress: 0.7),
            
            const SizedBox(height: 30),
            
            // Ejemplo 6: Pergamino
            const Text('Pergamino:'),
            const SizedBox(height: 8),
            SpriteWidget(
              imagePath: MedievalSprites.imagePath,
              srcX: MedievalSprites.scrollLarge.x,
              srcY: MedievalSprites.scrollLarge.y,
              srcWidth: MedievalSprites.scrollLarge.width,
              srcHeight: MedievalSprites.scrollLarge.height,
              width: 250,
              height: 150,
            ),
            
            const SizedBox(height: 30),
            
            // Ejemplo 7: Escudos (badges)
            const Text('Escudos (Badges):'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpriteWidget(
                  imagePath: MedievalSprites.imagePath,
                  srcX: MedievalSprites.shieldBrown.x,
                  srcY: MedievalSprites.shieldBrown.y,
                  srcWidth: MedievalSprites.shieldBrown.width,
                  srcHeight: MedievalSprites.shieldBrown.height,
                  width: 60,
                  height: 80,
                ),
                const SizedBox(width: 16),
                SpriteWidget(
                  imagePath: MedievalSprites.imagePath,
                  srcX: MedievalSprites.shieldDark.x,
                  srcY: MedievalSprites.shieldDark.y,
                  srcWidth: MedievalSprites.shieldDark.width,
                  srcHeight: MedievalSprites.shieldDark.height,
                  width: 60,
                  height: 80,
                ),
                const SizedBox(width: 16),
                SpriteWidget(
                  imagePath: MedievalSprites.imagePath,
                  srcX: MedievalSprites.shieldLight.x,
                  srcY: MedievalSprites.shieldLight.y,
                  srcWidth: MedievalSprites.shieldLight.width,
                  srcHeight: MedievalSprites.shieldLight.height,
                  width: 60,
                  height: 80,
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Instrucciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📖 Cómo agregar más sprites:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Abre medieval.png en un editor de imágenes (GIMP, Photoshop, etc.)\n'
                    '2. Selecciona el sprite que quieres usar\n'
                    '3. Anota las coordenadas (x, y) y tamaño (width, height)\n'
                    '4. Agrégalo en medieval_sprites.dart\n'
                    '5. Úsalo con SpriteWidget',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

