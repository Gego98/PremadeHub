import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                SplashView()
            } else if isAuthenticated {
                HomeView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            checkAuthenticationState()
        }
    }
    
    private func checkAuthenticationState() {
        // Check if user is already logged in
        if Auth.auth().currentUser != nil {
            isAuthenticated = true
        }
        
        // Simulate loading delay (remove in production or adjust if needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
        }
    }
}

// Simple splash screen
struct SplashView: View {
    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.cyan)
                
                Text("PremadeHub")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Find Your Perfect Team")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    ContentView()
}
