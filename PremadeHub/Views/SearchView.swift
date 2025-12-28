import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    let roles = ["All", "Top", "Jungle", "Mid", "ADC", "Support", "Fill"]
    let rankFilters = ["All", "Unranked", "Iron", "Bronze", "Silver", "Gold", "Platinum", "Emerald", "Diamond", "Master+"]
    
    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    Text("Find Players")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Search Type Picker
                    Picker("Search Type", selection: $viewModel.searchType) {
                        Text("Duo").tag(0)
                        Text("Clash").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .onChange(of: viewModel.searchType) { _, newValue in
                        viewModel.updateSearchType(newValue)
                    }
                    
                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Role Filter
                            Menu {
                                ForEach(roles, id: \.self) { role in
                                    Button(role) {
                                        viewModel.updateRole(role)
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "gamecontroller.fill")
                                    Text(viewModel.selectedRole)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                            
                            // Rank Filter
                            Menu {
                                ForEach(rankFilters, id: \.self) { rank in
                                    Button(rank) {
                                        viewModel.updateRank(rank)
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                    Text(viewModel.selectedRank)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                .padding(.bottom, 10)
                .background(Color(red: 0.01, green: 0.09, blue: 0.15))
                
                // Player List
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                    Spacer()
                } else if viewModel.players.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No players found")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("Try adjusting your filters")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.players) { player in
                                PlayerCardView(
                                    player: player,
                                    teamType: viewModel.searchType == 0 ? .duo : .clash
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadPlayers()
        }
    }
}

struct PlayerCardView: View {
    let player: Player
    let teamType: TeamType
    @State private var isConnecting = false
    @State private var hasSentInvitation = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Text(String(player.summonerName.prefix(1)).uppercased())
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.cyan)
            }
            
            // Player Info
            VStack(alignment: .leading, spacing: 5) {
                Text("\(player.summonerName)#\(player.summonerTag)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 10) {
                    Label(player.region, systemImage: "globe")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label(player.rank, systemImage: "trophy.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Label(player.role, systemImage: "gamecontroller.fill")
                    .font(.caption)
                    .foregroundColor(.cyan)
            }
            
            Spacer()
            
            // Connect Button
            Button(action: sendInvitation) {
                if isConnecting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 80)
                } else if hasSentInvitation {
                    Text("Sent")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                } else {
                    Text("Connect")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.cyan)
                        .cornerRadius(20)
                }
            }
            .disabled(isConnecting || hasSentInvitation)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
    
    private func sendInvitation() {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else { return }
        
        isConnecting = true
        
        Task {
            do {
                // Check if invitation already exists
                let exists = try await TeamService.shared.checkExistingInvitation(
                    fromUserId: currentUserId,
                    toUserId: player.id
                )
                
                if exists {
                    hasSentInvitation = true
                    isConnecting = false
                    return
                }
                
                // Send invitation (Duo or Clash based on search type)
                _ = try await TeamService.shared.sendTeamInvitation(
                    fromUserId: currentUserId,
                    toUserId: player.id,
                    teamType: teamType
                )
                
                hasSentInvitation = true
            } catch {
                print("Failed to send invitation: \(error.localizedDescription)")
            }
            
            isConnecting = false
        }
    }
}

#Preview {
    SearchView()
}
