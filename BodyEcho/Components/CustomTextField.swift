//
//  CustomTextField.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(placeholder)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textPrimary)

            Group {
                if isSecure {
                    SecureField("", text: $text)
                        .focused($isFocused)
                } else {
                    TextField("", text: $text)
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                }
            }
            .font(.system(size: 16))
            .padding()
            .background(Color.white)
            .cornerRadius(Constants.UI.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .stroke(isFocused ? Color.buttonPrimary : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

struct CustomTextFieldWithIcon: View {
    let placeholder: String
    let icon: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.textSecondary)
                .frame(width: 24)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                }
            }
            .font(.system(size: 16))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Constants.UI.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                .stroke(isFocused ? Color.buttonPrimary : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 24) {
        CustomTextField(
            placeholder: "E-posta Adresi",
            text: .constant("ornek@email.com")
        )

        CustomTextField(
            placeholder: "Şifre",
            text: .constant("password123"),
            isSecure: true
        )

        CustomTextFieldWithIcon(
            placeholder: "ornek@email.com",
            icon: "envelope",
            text: .constant(""),
            keyboardType: .emailAddress
        )

        CustomTextFieldWithIcon(
            placeholder: "Şifrenizi girin",
            icon: "lock",
            text: .constant(""),
            isSecure: true
        )
    }
    .padding()
    .background(Color.backgroundNeutral)
}
