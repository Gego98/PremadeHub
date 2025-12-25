import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("PremadeHub")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    
                VStack(spacing: 16){
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                
                Button(action: {
                    // TODO: Firebase Auth Login
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                
                NavigationLink("Don't have an account? Register", destination: RegisterView())
                    .foregroundColor(.blue)
                    .padding(.top, 16)
                
                Spacer()
            }
            .padding(.top, 80)
        }
    }
}

#Preview {
    LoginView()
}
