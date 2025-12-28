import SwiftUI

struct BrowseTeamsView: View {
    @StateObject private var viewModel = BrowseTeamsViewModel()
    @State private var selectedTeam: Team?
    @State private var showJoinAlert = false
    @State private var isJoining = false
    
    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
            } else if viewModel.teams.isEmpty {
                // Empty State
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Open Teams")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Check back later or create your own team")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.teams) { team in
                            Button(action: {
                                selectedTeam = team
                            }) {
                                TeamCompactCard(team: team)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.loadTeams()
        }
        .sheet(item: $selectedTeam) { team in
            TeamBrowseDetailView(team: team, onJoinRequest: {
                joinTeam(team)
            })
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
    
    private func joinTeam(_ team: Team) {
        isJoining = true
        
        Task {
            do {
                try await viewModel.sendJoinRequest(teamId: team.id)
                selectedTeam = nil
                viewModel.loadTeams() // Refresh list
            } catch {
                viewModel.errorMessage = error.localizedDescription
                viewModel.showError = true
                selectedTeam = nil
            }
            
            isJoining = false
        }
    }
}

struct TeamBrowseDetailView: View {
    let team: Team
    let onJoinRequest: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var hasSentRequest = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
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
                            
                            HStack(spacing: 8) {
                                Text(team.type == .duo ? "Duo Team" : "Clash Team")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                if team.privacy == .open {
                                    HStack(spacing: 4) {
                                        Image(systemName: "globe")
                                        Text("Open")
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        // Team Members
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Current Members (\(team.currentSize)/\(team.maxSize))")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(team.members) { member in
                                    HStack(spacing: 15) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.cyan.opacity(0.3))
                                                .frame(width: 40, height: 40)
                                            
                                            Text(String(member.summonerName.prefix(1)).uppercased())
                                                .font(.headline)
                                                .foregroundColor(.cyan)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
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
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Join Button
                        if !team.isFull {
                            Button(action: {
                                onJoinRequest()
                                hasSentRequest = true
                            }) {
                                HStack {
                                    Image(systemName: hasSentRequest ? "checkmark.circle.fill" : "hand.raised.fill")
                                    Text(hasSentRequest ? "Request Sent" : "Request to Join")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(hasSentRequest ? Color.gray : Color.cyan)
                                .cornerRadius(12)
                            }
                            .disabled(hasSentRequest)
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationTitle("Team Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    BrowseTeamsView()
}
