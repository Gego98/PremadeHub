import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var invitationCount = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Search Tab
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(0)
                
                // Invitations Tab
                InvitationsView()
                    .tabItem {
                        Label("Invites", systemImage: "envelope")
                    }
                    .badge(invitationCount)
                    .tag(1)
                
                // Teams Tab (with My Teams and Browse sub-tabs)
                TeamsContainerView(selectedMainTab: $selectedTab)
                    .tabItem {
                        Label("Teams", systemImage: "person.3.fill")
                    }
                    .tag(2)
                
                // Messages Tab
                MessagesView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(3)
                
                // Profile Tab
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(4)
            }
            .accentColor(.cyan)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                loadInvitationCount()
            }
        }
    }
    
    private func loadInvitationCount() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                let invitations = try await TeamService.shared.getPendingInvitations(userId: userId)
                invitationCount = invitations.count
            } catch {
                print("Failed to load invitation count: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    HomeView()
}
