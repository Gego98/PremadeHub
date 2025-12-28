import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
            } else if let user = viewModel.userData {
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile Header
                        VStack(spacing: 15) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(Color.cyan.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                
                                Text(String(user.summonerName.prefix(1)).uppercased())
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.cyan)
                            }
                            
                            // Display name with tag
                            Text("\(user.summonerName)#\(user.summonerTag)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(user.region)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 30)
                        
                        // Stats Card
                        VStack(spacing: 15) {
                            HStack(spacing: 30) {
                                VStack(spacing: 5) {
                                    Image(systemName: "trophy.fill")
                                        .font(.title2)
                                        .foregroundColor(.cyan)
                                    Text(user.rank)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Rank")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Divider()
                                    .frame(height: 50)
                                    .background(Color.gray.opacity(0.3))
                                
                                VStack(spacing: 5) {
                                    Image(systemName: "gamecontroller.fill")
                                        .font(.title2)
                                        .foregroundColor(.cyan)
                                    Text(user.role)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Main Role")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        
                        // Status Toggles
                        VStack(spacing: 15) {
                            StatusToggleView(
                                title: "Looking for Duo",
                                icon: "person.2.fill",
                                isOn: Binding(
                                    get: { user.lookingForDuo },
                                    set: { viewModel.updateLookingForDuo($0) }
                                )
                            )
                            
                            StatusToggleView(
                                title: "Looking for Clash Team",
                                icon: "person.3.fill",
                                isOn: Binding(
                                    get: { user.lookingForClash },
                                    set: { viewModel.updateLookingForClash($0) }
                                )
                            )
                        }
                        .padding(.horizontal)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                showEditProfile = true
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Profile")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.cyan)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                showLogoutAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.square")
                                    Text("Logout")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Failed to load profile")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    Button("Retry") {
                        viewModel.loadUserProfile()
                    }
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            if let user = viewModel.userData {
                EditProfileView(userData: user) { updatedUser in
                    viewModel.userData = updatedUser
                }
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .onAppear {
            viewModel.loadUserProfile()
        }
    }
    
    private func logout() {
        do {
            try viewModel.logout()
            // ContentView will automatically detect logout and show LoginView
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    struct StatusToggleView: View {
        let title: String
        let icon: String
        @Binding var isOn: Bool
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.cyan)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(.cyan)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
        }
    }
}
#Preview {
    ProfileView()
}
