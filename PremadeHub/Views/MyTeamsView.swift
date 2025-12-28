import SwiftUI

struct MyTeamsView: View {
    @StateObject private var viewModel = MyTeamsViewModel()
    @Binding var selectedTab: Int
    @State private var showCreateTeam = false
    
    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Create Button
                HStack {
                    Text("My Teams")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showCreateTeam = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.cyan)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 10)
                
                if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
            } else if viewModel.teams.isEmpty {
                // Empty State
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.cyan)
                    
                    Text("No Teams Yet")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your duo partners and clash teams will appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        selectedTab = 0 // Switch to Search tab
                    }) {
                        Text("Find Players")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.cyan)
                            .cornerRadius(25)
                    }
                    .padding(.top, 10)
                }
            } else {
                // Teams List (Compact)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.teams) { team in
                            NavigationLink(destination: TeamDetailsView(team: team)) {
                                TeamCompactCard(team: team)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        }
        .onAppear {
            viewModel.loadTeams()
        }
        .sheet(isPresented: $showCreateTeam) {
            CreateTeamView(viewModel: viewModel)
        }
    }
}

#Preview {
    MyTeamsView(selectedTab: .constant(2))
}
