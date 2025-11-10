//
//  CustomButton.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false

    enum ButtonStyle {
        case primary
        case secondary
        case outline
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(textColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.UI.buttonHeight)
            .background(backgroundColor)
            .cornerRadius(Constants.UI.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .stroke(borderColor, lineWidth: style == .outline ? 1.5 : 0)
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .buttonPrimary
        case .secondary:
            return .secondaryTeal
        case .outline:
            return .clear
        }
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .textPrimary
        case .outline:
            return .buttonPrimary
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline:
            return .buttonPrimary
        default:
            return .clear
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CustomButton(title: "HESAP OLUŞTUR", action: {})
            .padding()

        CustomButton(title: "GİRİŞ", action: {}, style: .primary)
            .padding()

        CustomButton(title: "Veriyi Kaydet", action: {}, style: .secondary)
            .padding()

        CustomButton(title: "Outline Button", action: {}, style: .outline)
            .padding()

        CustomButton(title: "Loading...", action: {}, isLoading: true)
            .padding()

        CustomButton(title: "Disabled", action: {}, isDisabled: true)
            .padding()
    }
    .background(Color.backgroundNeutral)
}
