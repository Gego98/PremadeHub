import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SearchView: View {
    @State private var searchType = 0 // 0 = Duo, 1 = Clash
    @State private var selectedRole = "All"
    @State private var selectedRankFilter = "All"
    @State private var players: [Player] = []
    @State private var isLoading = false
    
    let roles = ["All", "Top", "Jungle", "Mid", "ADC", "Support", "Fill"]
    // For filtering, we'll use major ranks
    let rankFilters = ["All", "Unranked", "Iron", "Bronze", "Silver", "Gold", "Platinum", "Emerald", "Diamond", "Master+"]
    
    var body: some View {
        NavigationStack {
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
                        Picker("Search Type", selection: $searchType) {
                            Text("Duo").tag(0)
                            Text("Clash").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .onChange(of: searchType) { _, _ in
                            loadPlayers()
                        }
                        
                        // Filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Role Filter
                                Menu {
                                    ForEach(roles, id: \.self) { role in
                                        Button(role) {
                                            selectedRole = role
                                            loadPlayers()
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "gamecontroller.fill")
                                        Text(selectedRole)
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
                                            selectedRankFilter = rank
                                            loadPlayers()
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "trophy.fill")
                                        Text(selectedRankFilter)
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
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                        Spacer()
                    } else if players.isEmpty {
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
                                ForEach(players) { player in
                                    PlayerCardView(player: player)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .onAppear {
                loadPlayers()
            }
        }
    }
    
    private func loadPlayers() {
        isLoading = true
        players = []
        
        let db = Firestore.firestore()
        var query: Query = db.collection("users")
        
        // Filter by search type
        if searchType == 0 {
            query = query.whereField("lookingForDuo", isEqualTo: true)
        } else {
            query = query.whereField("lookingForClash", isEqualTo: true)
        }
        
        query.getDocuments { snapshot, error in
            isLoading = false
            
            if let error = error {
                print("Error fetching players: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var fetchedPlayers: [Player] = []
            
            for document in documents {
                let data = document.data()
                
                // Skip current user
                if document.documentID == Auth.auth().currentUser?.uid {
                    continue
                }
                
                let rank = data["rank"] as? String ?? "Unranked"
                let player = Player(
                    id: document.documentID,
                    summonerName: data["summonerName"] as? String ?? "",
                    summonerTag: data["summonerTag"] as? String ?? "",
                    region: data["region"] as? String ?? "",
                    rank: rank,
                    role: data["role"] as? String ?? "Fill"
                )
                
                // Apply role filter
                if selectedRole != "All" && player.role != selectedRole {
                    continue
                }
                
                // Apply rank filter
                if selectedRankFilter != "All" {
                    if !matchesRankFilter(rank: rank, filter: selectedRankFilter) {
                        continue
                    }
                }
                
                fetchedPlayers.append(player)
            }
            
            players = fetchedPlayers
        }
    }
    
    private func matchesRankFilter(rank: String, filter: String) -> Bool {
        if filter == "Master+" {
            return rank.contains("Master") || rank.contains("Grandmaster") || rank.contains("Challenger")
        } else {
            // For other ranks, check if the rank string starts with the filter
            return rank.hasPrefix(filter)
        }
    }
}

struct PlayerCardView: View {
    let player: Player
    
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
            Button(action: {
                // Handle connect action
            }) {
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
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// Player Model
struct Player: Identifiable {
    let id: String
    let summonerName: String
    let summonerTag: String
    let region: String
    let rank: String
    let role: String
}

#Preview {
    SearchView()
}
