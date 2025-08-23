//
//  FocusKnightWidgetLiveActivity.swift
//  FocusKnightWidgetExtension
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Requisito del plugin: el nombre DEBE ser exactamente este
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState

  public struct ContentState: Codable, Hashable {
    // Podés dejarlo vacío; el plugin usa UserDefaults para los datos
    // pero si querés, también podés mapear flags (p.ej. paused)
    var paused: Bool = false
  }

  // Identificador para prefijar claves en UserDefaults
  var id = UUID()
}

// Prefijo de claves (requisito del README del paquete)
extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    return "\(id)_\(key)"
  }
}

// MARK: - App Group (MISMO que en Flutter .init())
private let appGroupID = "group.com.focusknight.app" // <-- usa este App Group
private let sharedDefault = UserDefaults(suiteName: appGroupID)!

// MARK: - Helpers UI

/// Carga imagen que Flutter escribió en el App Group
func imageFromFlutter(path: String?) -> Image? {
  guard let path = path, let ui = UIImage(contentsOfFile: path) else { return nil }
  return Image(uiImage: ui)
}

/// Construye un Text con cuenta regresiva hasta endDate
@ViewBuilder
func countdown(to endDate: Date) -> some View {
  // iOS 16+: Text con intervalo y cuenta regresiva
  Text(timerInterval: Date.now...endDate, countsDown: true)
    .monospacedDigit()
    .font(.system(size: 16, weight: .semibold, design: .monospaced))
    .minimumScaleFactor(0.6)
}

// MARK: - Widget

struct FocusKnightLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      // Leer datos que manda Flutter (via UserDefaults + prefijo)
      let title = sharedDefault.string(forKey: context.attributes.prefixedKey("title")) ?? "FOCUS"
      let logoPath = sharedDefault.string(forKey: context.attributes.prefixedKey("logo"))
      let endAtMs = sharedDefault.double(forKey: context.attributes.prefixedKey("endAtMs"))
      let paused = sharedDefault.bool(forKey: context.attributes.prefixedKey("paused"))

      // Si no tenemos endAt, usamos ahora+1 para no crashear
      let endDate = endAtMs > 0 ? Date(timeIntervalSince1970: endAtMs / 1000.0) : Date().addingTimeInterval(1)

      // UI Lock Screen / Banner
      HStack(spacing: 10) {
        if let img = imageFromFlutter(path: logoPath) {
          img
            .resizable()
            .frame(width: 28, height: 28)
            .cornerRadius(6)
        }

        VStack(alignment: .leading, spacing: 4) {
          Text(title.uppercased())
            .font(.system(size: 10, weight: .bold, design: .default))
            .lineLimit(1)

          if paused {
            Text("PAUSADO")
              .font(.system(size: 10, weight: .bold, design: .default))
          } else {
            countdown(to: endDate)
          }
        }

        Spacer()
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .activityBackgroundTint(Color.black.opacity(0.9))
      .activitySystemActionForegroundColor(.white)

    } dynamicIsland: { context in
      let title = sharedDefault.string(forKey: context.attributes.prefixedKey("title")) ?? "FOCUS"
      let logoPath = sharedDefault.string(forKey: context.attributes.prefixedKey("logo"))
      let endAtMs = sharedDefault.double(forKey: context.attributes.prefixedKey("endAtMs"))
      let paused = sharedDefault.bool(forKey: context.attributes.prefixedKey("paused"))
      let endDate = endAtMs > 0 ? Date(timeIntervalSince1970: endAtMs / 1000.0) : Date().addingTimeInterval(1)

      return DynamicIsland {
        // Expanded
        DynamicIslandExpandedRegion(.leading) {
          if let img = imageFromFlutter(path: logoPath) {
            img.resizable().frame(width: 26, height: 26).cornerRadius(6)
          } else {
            Text("FK").font(.system(size: 10, weight: .bold))
          }
        }

        DynamicIslandExpandedRegion(.center) {
          if paused {
            Text("PAUSADO").font(.system(size: 12, weight: .bold))
          } else {
            countdown(to: endDate)
          }
        }

        DynamicIslandExpandedRegion(.trailing) {
          Text(title.uppercased())
            .font(.system(size: 9, weight: .semibold))
            .multilineTextAlignment(.trailing)
            .lineLimit(2)
        }

        DynamicIslandExpandedRegion(.bottom) {
          // Podés agregar progreso, tarea actual, etc.
        }
      } compactLeading: {
        if let img = imageFromFlutter(path: logoPath) {
          img.resizable().frame(width: 20, height: 20).cornerRadius(4)
        } else {
          Text("FK").font(.system(size: 9, weight: .bold))
        }
      } compactTrailing: {
        if paused {
          Text("||").font(.system(size: 9, weight: .bold))
        } else {
          // Para compact, mostramos un icono de tiempo
          if endAtMs > 0 {
            Text("⏳").font(.system(size: 12))
          } else {
            Text("--").font(.system(size: 10))
          }
        }
      } minimal: {
        if paused {
          Text("||").font(.system(size: 9, weight: .bold))
        } else {
          Text("⏳")
        }
      }
      .keylineTint(.white)
    }
  }
}

// MARK: - Preview

#Preview("Live", as: .content, using: LiveActivitiesAppAttributes()) {
  FocusKnightLiveActivity()
} contentStates: {
  LiveActivitiesAppAttributes.ContentState(paused: false)
}
