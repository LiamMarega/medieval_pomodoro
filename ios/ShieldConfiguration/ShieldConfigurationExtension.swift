//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by Liam on 01/12/2025.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    // Helper method to create the Focus Knight shield
    private func focusKnightShield(name: String) -> ShieldConfiguration {
        // Acceder a los datos compartidos
        let userDefaults = UserDefaults(suiteName: "group.com.focusknight.app")
        
        let titleText = userDefaults?.string(forKey: "shield_title") ?? "Focus Knight"
        let subtitleTemplate = userDefaults?.string(forKey: "shield_subtitle") ?? "Has jurado proteger tu enfoque."
        let buttonLabelText = userDefaults?.string(forKey: "shield_button_label") ?? "Cerrar"
        
        // Replace placeholder {{appName}} with actual app name
        let subtitleText = subtitleTemplate.replacingOccurrences(of: "{{appName}}", with: name)
        
        return ShieldConfiguration(
            backgroundBlurStyle: .dark, // Fondo oscuro/borroso
            backgroundColor: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0), // Gris muy oscuro casi negro
            icon: UIImage(systemName: "shield.fill"), // Icono temporal, usa tu logo aquí
            title: ShieldConfiguration.Label(
                text: titleText,
                color: .systemYellow // Color dorado/ámbar medieval
            ),
            subtitle: ShieldConfiguration.Label(
                text: subtitleText,
                color: .white
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: buttonLabelText,
                color: .black
            ),
            primaryButtonBackgroundColor: .systemYellow, // Botón dorado
            secondaryButtonLabel: nil // Ocultar botón de "pedir más tiempo" para ser estricto
        )
    }
    
    // Configura el escudo cuando se bloquea una aplicación
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let appName = application.localizedDisplayName ?? "esta aplicación"
        return focusKnightShield(name: appName)
    }
    
    // Opcional: Configuración diferente si es una web o categoría
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return configuration(shielding: application)
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        let domainName = webDomain.domain ?? "esta web"
        return focusKnightShield(name: domainName)
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return configuration(shielding: webDomain)
    }
}
