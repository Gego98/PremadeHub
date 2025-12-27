import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var navigateToRegister = false
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(red: 0.01, green: 0.09, blue: 0.15)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        Spacer()
                            .frame(height: 60)
                        
                        // Logo/Icon
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.cyan)
                        
                        Text("PremadeHub")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text ("Find Your Perfect Duo & Clash Team")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            CustomTextField(
                                placeholder: "Enter your email",
                                text: $email,
                                keyboardType: .emailAddress,
                                autoCapitalization: .never
                            )
                        }
                        .padding(.horizontal, 30)
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            CustomTextField(
                                placeholder: "Enter your password",
                                text: $password,
                                isSecure: true
                            )
                        }
                        .padding(.horizontal, 30)
                        
                        // Login Button
                        Button(action: login) {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Login")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.cyan)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading)
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        
                        // Register Link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                navigateToRegister = true
                            }) {
                                Text("Sign Up")
                                    .foregroundColor(.cyan)
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.subheadline)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                }
                .navigationDestination(isPresented: $navigateToRegister) {
                    RegisterView()
                }
                .navigationDestination(isPresented: $navigateToHome) {
                    HomeView()
                }
            }
            .alert("Login Error", isPresented: $showError) {
                Button("OK", role: .cancel){ }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            // Navigate to home
            navigateToHome = true
        }
    }
}

#Preview {
    LoginView()
}
