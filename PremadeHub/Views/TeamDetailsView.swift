import SwiftUI

struct TeamDetailsView: View {
    let team: Team
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = MyTeamsViewModel()
    @StateObject private var joinRequestsViewModel = JoinRequestsViewModel()
    @State private var showLeaveAlert = false
    @State private var showJoinRequests = false
    @State private var refreshTrigger = UUID() // Trigger refresh
    
    private var isCreator: Bool {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else { return false }
        return team.createdBy == currentUserId
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Team Header
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.cyan.opacity(0.3))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: team.type == .duo ? "person.2.fill" : "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.cyan)
                        }
                        
                        Text(team.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(team.type == .duo ? "Duo Team" : "Clash Team")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Team Size Badge
                        HStack(spacing: 8) {
                            Text("\(team.currentSize)/\(team.maxSize) Members")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            if team.isFull {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Full")
                                }
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Team Members Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Team Members")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(team.members) { member in
                                TeamMemberRow(member: member)
                            }
                            
                            // Empty Slots
                            if team.type == .clash && !team.isFull {
                                ForEach(0..<team.availableSlots, id: \.self) { index in
                                    EmptySlotRow()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Join Requests (only for team creator)
                    if isCreator && !joinRequestsViewModel.requests.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Button(action: {
                                showJoinRequests = true
                            }) {
                                HStack {
                                    Image(systemName: "envelope.badge")
                                        .foregroundColor(.cyan)
                                    
                                    Text("Join Requests")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    // Badge with count
                                    Text("\(joinRequestsViewModel.requests.count)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red)
                                        .cornerRadius(10)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.cyan.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Team Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team Information")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 10) {
                            InfoRow(icon: "calendar", label: "Created", value: formatDate(team.createdAt))
                            InfoRow(icon: "person.fill", label: "Type", value: team.type == .duo ? "Duo" : "Clash")
                            InfoRow(icon: "number", label: "Members", value: "\(team.currentSize)/\(team.maxSize)")
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    // Actions
                    VStack(spacing: 12) {
                        if !team.isFull && team.type == .clash {
                            Button(action: {
                                // Invite more players
                            }) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                    Text("Invite More Players")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.cyan)
                                .cornerRadius(12)
                            }
                        }
                        
                        Button(action: {
                            showLeaveAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Leave Team")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Team Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showJoinRequests) {
            JoinRequestsListView(teamId: team.id) {
                // Refresh callback
                joinRequestsViewModel.loadRequests(teamId: team.id)
                refreshTrigger = UUID()
            }
        }
        .id(refreshTrigger) // Force view refresh
        .onAppear {
            if isCreator {
                joinRequestsViewModel.loadRequests(teamId: team.id)
            }
        }
        .alert("Leave Team", isPresented: $showLeaveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                leaveTeam()
            }
        } message: {
            Text("Are you sure you want to leave this team?")
        }
    }
    
    private func leaveTeam() {
        Task {
            do {
                try await viewModel.leaveTeam(teamId: team.id)
                dismiss()
            } catch {
                print("Failed to leave team: \(error.localizedDescription)")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TeamMemberRow: View {
    let member: TeamMember
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Text(String(member.summonerName.prefix(1)).uppercased())
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.cyan)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(member.summonerName)#\(member.summonerTag)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if member.isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundColor(.cyan)
                    }
                }
                
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
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct EmptySlotRow: View {
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "plus")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            Text("Empty Slot")
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 24)
            
            Text(label)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
