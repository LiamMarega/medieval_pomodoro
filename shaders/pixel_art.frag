#version 460 core
#include <flutter/runtime_effect.glsl>

// IMPORTANTE: Para ImageFilter.shader(), el primer uniforme DEBE ser vec2 con el tamaño
// y el sampler2D debe estar después de los otros uniforms
uniform vec2 u_size;          // tamaño del renderizado (PRIMER uniforme requerido)
uniform sampler2D u_texture;  // sampler (configurado automáticamente por Flutter)
uniform float u_pixelSize;    // tamaño de píxel grosor (número de bloques)
uniform float u_colorCount;   // número de colores de la paleta (16-32)

out vec4 fragColor;

// Paleta de colores estilo 16 bits (16 colores típicos de consolas retro)
const vec3 palette[16] = vec3[16](
  vec3(0.0, 0.0, 0.0),           // 0: Negro
  vec3(0.2, 0.2, 0.4),           // 1: Azul oscuro
  vec3(0.4, 0.2, 0.2),           // 2: Rojo oscuro
  vec3(0.2, 0.4, 0.2),           // 3: Verde oscuro
  vec3(0.4, 0.3, 0.2),           // 4: Marrón
  vec3(0.3, 0.3, 0.3),           // 5: Gris oscuro
  vec3(0.4, 0.4, 0.4),           // 6: Gris medio
  vec3(0.5, 0.5, 0.6),           // 7: Gris claro
  vec3(0.6, 0.6, 0.6),           // 8: Gris muy claro
  vec3(0.4, 0.6, 0.8),           // 9: Azul claro
  vec3(0.8, 0.4, 0.4),           // 10: Rojo claro
  vec3(0.4, 0.8, 0.4),           // 11: Verde claro
  vec3(0.8, 0.8, 0.4),           // 12: Amarillo
  vec3(0.4, 0.6, 1.0),           // 13: Azul brillante
  vec3(1.0, 0.6, 0.6),           // 14: Rosa/Rojo brillante
  vec3(1.0, 1.0, 1.0)            // 15: Blanco
);

// Encuentra el color más cercano en la paleta
vec3 nearestColor(vec3 color) {
  float bestDist = 1000.0;
  vec3 chosen = palette[0];
  
  for (int i = 0; i < 16; i++) {
    float dist = distance(color, palette[i]);
    if (dist < bestDist) {
      bestDist = dist;
      chosen = palette[i];
    }
  }
  
  return chosen;
}

// Cuantización simple alternativa (más rápido pero menos auténtico)
vec3 quantize(vec3 color, float paletteSize) {
  float steps = paletteSize;
  color = floor(color * steps) / steps;
  return color;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / u_size;

  #ifdef IMPELLER_TARGET_OPENGLES
    uv.y = 1.0 - uv.y;
  #endif

  // Calcula bloques "pixelados" - reduce la resolución aparente
  vec2 pixelUV = floor(uv * u_pixelSize) / u_pixelSize;

  // Muestra la textura sin filtrado suave para bordes definidos
  vec4 color = texture(u_texture, pixelUV);

  // Aplica cuantización de color
  vec3 quantized;
  if (u_colorCount <= 16.0) {
    // Usa paleta fija de 16 colores para efecto más auténtico
    quantized = nearestColor(color.rgb);
  } else {
    // Usa cuantización uniforme para paletas más grandes
    quantized = quantize(color.rgb, u_colorCount);
  }

  // Mantiene la transparencia original
  fragColor = vec4(quantized, color.a);
}

