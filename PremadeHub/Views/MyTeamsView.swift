import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MyTeamsView: View {
    @State private var myTeams: [Team] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
            } else if myTeams.isEmpty {
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
                        // Navigate to search tab
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
                // Teams List
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(myTeams) { team in
                            TeamCardView(team: team)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("My Teams")
        .onAppear {
            loadMyTeams()
        }
    }
    
    private func loadMyTeams() {
        // TODO: Implement team loading from Firestore
        // For now, simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
        }
    }
}

struct TeamCardView: View {
    let team: Team
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Team Header
            HStack {
                Image(systemName: team.type == .duo ? "person.2.fill" : "person.3.fill")
                    .foregroundColor(.cyan)
                
                Text(team.type == .duo ? "Duo Partner" : "Clash Team")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Team Size Badge
                HStack(spacing: 4) {
                    Text("\(team.currentSize)/\(team.maxSize)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(team.isFull ? .green : .cyan)
                    
                    if team.isFull {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(team.isFull ? Color.green.opacity(0.2) : Color.cyan.opacity(0.2))
                .cornerRadius(12)
            }
            
            // Team Members
            VStack(alignment: .leading, spacing: 8) {
                ForEach(team.members) { member in
                    HStack(spacing: 12) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color.cyan.opacity(0.3))
                                .frame(width: 40, height: 40)
                            
                            Text(String(member.summonerName.prefix(1)).uppercased())
                                .font(.headline)
                                .foregroundColor(.cyan)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(member.summonerName)#\(member.summonerTag)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                Label(member.rank, systemImage: "trophy.fill")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Label(member.role, systemImage: "gamecontroller.fill")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                // Empty Slots (for Clash teams)
                if team.type == .clash && !team.isFull {
                    ForEach(0..<team.availableSlots, id: \.self) { _ in
                        HStack(spacing: 12) {
                            // Empty Avatar
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "plus")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                            
                            Text("Empty Slot")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                        }
                    }
                }
            }
            
            // Available Slots Info
            if !team.isFull {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.cyan)
                        .font(.caption)
                    
                    Text(team.availableSlotsText)
                        .font(.caption)
                        .foregroundColor(.cyan)
                }
                .padding(.top, 4)
            }
            
            // Action Buttons
            HStack(spacing: 10) {
                if !team.isFull {
                    Button(action: {
                        // Invite action
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Invite")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.cyan)
                        .cornerRadius(8)
                    }
                }
                
                Button(action: {
                    // Message action
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("Message")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(team.isFull ? Color.cyan : Color.white.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    // View details action
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Details")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// Team Model
struct Team: Identifiable {
    let id: String
    let type: TeamType
    let members: [TeamMember]
    let createdAt: Date
    
    // Computed properties for team size management
    var maxSize: Int {
        switch type {
        case .duo:
            return 2
        case .clash:
            return 5
        }
    }
    
    var currentSize: Int {
        return members.count
    }
    
    var availableSlots: Int {
        return maxSize - currentSize
    }
    
    var isFull: Bool {
        return currentSize >= maxSize
    }
    
    var availableSlotsText: String {
        if isFull {
            return "Team is full"
        } else if availableSlots == 1 {
            return "1 slot available"
        } else {
            return "\(availableSlots) slots available"
        }
    }
}

enum TeamType {
    case duo    // Max 2 players (you + 1)
    case clash  // Max 5 players (you + 4)
}

struct TeamMember: Identifiable {
    let id: String
    let summonerName: String
    let summonerTag: String
    let rank: String
    let role: String
    let isCurrentUser: Bool
}

#Preview {
    MyTeamsView()
}
