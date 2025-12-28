import SwiftUI

struct CreateTeamView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MyTeamsViewModel
    
    @State private var teamName = ""
    @State private var selectedType: TeamType = .duo
    @State private var selectedPrivacy: TeamPrivacy = .inviteOnly
    @State private var isCreating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.01, green: 0.09, blue: 0.15)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.cyan)
                            
                            Text("Create Your Team")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Set up your team and start playing together")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            // Team Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Team Name")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Enter team name", text: $teamName)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .autocapitalization(.words)
                            }
                            
                            // Team Type
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Team Type")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 12) {
                                    TeamTypeButton(
                                        icon: "person.2.fill",
                                        title: "Duo",
                                        subtitle: "2 Players",
                                        isSelected: selectedType == .duo,
                                        action: { selectedType = .duo }
                                    )
                                    
                                    TeamTypeButton(
                                        icon: "person.3.fill",
                                        title: "Clash",
                                        subtitle: "5 Players",
                                        isSelected: selectedType == .clash,
                                        action: { selectedType = .clash }
                                    )
                                }
                            }
                            
                            // Privacy
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Privacy")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    PrivacyOption(
                                        icon: "lock.fill",
                                        title: "Invite Only",
                                        subtitle: "Only invited players can join",
                                        isSelected: selectedPrivacy == .inviteOnly,
                                        action: { selectedPrivacy = .inviteOnly }
                                    )
                                    
                                    PrivacyOption(
                                        icon: "globe",
                                        title: "Open",
                                        subtitle: "Anyone can request to join",
                                        isSelected: selectedPrivacy == .open,
                                        action: { selectedPrivacy = .open }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Create Button
                        Button(action: createTeam) {
                            if isCreating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Team")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(teamName.isEmpty || isCreating ? Color.gray : Color.cyan)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .disabled(teamName.isEmpty || isCreating)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Create Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
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
    
    private func createTeam() {
        isCreating = true
        
        Task {
            do {
                try await viewModel.createTeam(
                    type: selectedType,
                    name: teamName,
                    privacy: selectedPrivacy
                )
                
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isCreating = false
        }
    }
}

struct TeamTypeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .cyan : .gray)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct PrivacyOption: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .cyan : .gray)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.cyan)
                }
            }
            .padding()
            .background(isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    CreateTeamView(viewModel: MyTeamsViewModel())
}
