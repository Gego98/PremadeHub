import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Home")
                .font(.largeTitle)
            
            NavigationLink("Search Players", destination: SearchView())
            NavigationLink("My Profile", destination: ProfileView())
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
