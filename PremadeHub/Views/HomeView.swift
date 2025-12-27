import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            //Search Tab
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(0)
            
            // My Teams Tab (placeholder for now)
            MyTeamsView()
                .tabItem {
                    Label("My Teams", systemImage: "person.3.fill")
                }
                .tag(1)
            
            // Messages Tav (placeholder for now)
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.cyan)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomeView()
}
