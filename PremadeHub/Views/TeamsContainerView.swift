import SwiftUI

struct TeamsContainerView: View {
    @Binding var selectedMainTab: Int
    @State private var selectedTeamsTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Sub-tabs for Teams section
            Picker("Teams Section", selection: $selectedTeamsTab) {
                Text("My Teams").tag(0)
                Text("Browse").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color(red: 0.01, green: 0.09, blue: 0.15))
            
            // Content based on selected tab
            TabView(selection: $selectedTeamsTab) {
                MyTeamsView(selectedTab: $selectedMainTab)
                    .tag(0)
                
                BrowseTeamsView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

#Preview {
    TeamsContainerView(selectedMainTab: .constant(2))
}
