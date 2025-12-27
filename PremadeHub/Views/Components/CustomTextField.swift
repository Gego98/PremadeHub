import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autoCapitalization: TextInputAutocapitalization = .sentences
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.leading, 16)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .padding()
                    .autocorrectionDisabled()
            } else {
                TextField("", text: $text)
                    .foregroundColor(.white)
                    .padding()
                    .textInputAutocapitalization(autoCapitalization)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
            }
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}
