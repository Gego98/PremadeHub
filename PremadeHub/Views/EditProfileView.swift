import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    let userData: UserProfile
    let onSave: (UserProfile) -> Void
    
    @State private var summonerName: String
    @State private var summonerTag: String
    @State private var selectedRegion: String
    @State private var selectedRank: String
    @State private var selectedDivision: String
    @State private var selectedRole: String
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let regions = ["NA", "EUW", "EUNE", "KR", "BR", "LAN", "LAS", "OCE", "RU", "TR", "JP"]
    let ranksWithDivisions = ["Iron", "Bronze", "Silver", "Gold", "Platinum", "Emerald", "Diamond"]
    let ranksWithoutDivisions = ["Unranked", "Master", "Grandmaster", "Challenger"]
    let divisions = ["I", "II", "III", "IV"]
    let roles = ["Top", "Jungle", "Mid", "ADC", "Support", "Fill"]
    
    var allRanks: [String] {
        ranksWithoutDivisions + ranksWithDivisions
    }
    
    var showDivisionPicker: Bool {
        ranksWithDivisions.contains(selectedRank)
    }
    
    var fullRank: String {
        if showDivisionPicker {
            return "\(selectedRank) \(selectedDivision)"
        } else {
            return selectedRank
        }
    }
    
    init(userData: UserProfile, onSave: @escaping (UserProfile) -> Void) {
        self.userData = userData
        self.onSave = onSave
        
        _summonerName = State(initialValue: userData.summonerName)
        _summonerTag = State(initialValue: userData.summonerTag)
        _selectedRegion = State(initialValue: userData.region)
        _selectedRole = State(initialValue: userData.role)
        
        // Parse rank into tier and division
        let rankComponents = userData.rank.split(separator: " ")
        if rankComponents.count == 2 {
            _selectedRank = State(initialValue: String(rankComponents[0]))
            _selectedDivision = State(initialValue: String(rankComponents[1]))
        } else {
            _selectedRank = State(initialValue: userData.rank)
            _selectedDivision = State(initialValue: "IV")
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.01, green: 0.09, blue: 0.15)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color.cyan.opacity(0.3))
                                .frame(width: 100, height: 100)
                            
                            Text(String(summonerName.prefix(1)).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.cyan)
                        }
                        .padding(.top, 30)
                        
                        // Summoner Name + Tag (inline)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Riot ID")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 0) {
                                // Summoner Name
                                ZStack(alignment: .leading) {
                                    if summonerName.isEmpty {
                                        Text("Summoner Name")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(.leading, 16)
                                    }
                                    TextField("", text: $summonerName)
                                        .foregroundColor(.white)
                                        .padding()
                                        .autocorrectionDisabled()
                                }
                                .background(Color.white.opacity(0.1))
                                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(
                                    topLeading: 10,
                                    bottomLeading: 10,
                                    bottomTrailing: 0,
                                    topTrailing: 0
                                )))
                                
                                // # Separator
                                Text("#")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                    .frame(width: 30)
                                    .frame(maxHeight: .infinity)
//                                    .background(Color.white.opacity(0.05))
                                
                                // Summoner Tag
                                ZStack {
                                    if summonerTag.isEmpty {
                                        Text("TAG")
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                    TextField("", text: $summonerTag)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .onChange(of: summonerTag) { oldValue, newValue in
                                            // Limit to 5 characters
                                            if newValue.count > 5 {
                                                summonerTag = String(newValue.prefix(5))
                                            }
                                        }
                                }
                                .frame(width: 100)
                                .background(Color.white.opacity(0.1))
                                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(
                                    topLeading: 0,
                                    bottomLeading: 0,
                                    bottomTrailing: 10,
                                    topTrailing: 10
                                )))
                            }
                            .frame(height: 50)
                        }
                        .padding(.horizontal)
                        
                        // Region Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Region")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Menu {
                                ForEach(regions, id: \.self) { region in
                                    Button(action: {
                                        selectedRegion = region
                                    }) {
                                        HStack {
                                            Text(region)
                                            if selectedRegion == region {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedRegion)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Rank Picker with Divisions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rank")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 10) {
                                // Rank Tier
                                Menu {
                                    ForEach(allRanks, id: \.self) { rank in
                                        Button(action: {
                                            selectedRank = rank
                                            // Reset to highest division when changing rank
                                            if ranksWithDivisions.contains(rank) {
                                                selectedDivision = "IV"
                                            }
                                        }) {
                                            HStack {
                                                Text(rank)
                                                if selectedRank == rank {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedRank)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .frame(maxWidth: showDivisionPicker ? .infinity : .infinity)
                                
                                // Division Picker (only for Iron-Diamond)
                                if showDivisionPicker {
                                    Menu {
                                        ForEach(divisions, id: \.self) { division in
                                            Button(action: {
                                                selectedDivision = division
                                            }) {
                                                HStack {
                                                    Text(division)
                                                    if selectedDivision == division {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedDivision)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                    .frame(width: 80)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Role Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Main Role")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Menu {
                                ForEach(roles, id: \.self) { role in
                                    Button(action: {
                                        selectedRole = role
                                    }) {
                                        HStack {
                                            Text(role)
                                            if selectedRole == role {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedRole)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Save Button
                        Button(action: saveProfile) {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Save Changes")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.cyan)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Edit Profile")
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
    
    private func saveProfile() {
        guard !summonerName.isEmpty else {
            errorMessage = "Summoner name cannot be empty"
            showError = true
            return
        }
        
        guard !summonerTag.isEmpty else {
            errorMessage = "Summoner tag cannot be empty"
            showError = true
            return
        }
        
        // Validate tag format (3-5 alphanumeric characters)
        guard summonerTag.count >= 3 && summonerTag.count <= 5 else {
            errorMessage = "Summoner tag must be 3-5 characters"
            showError = true
            return
        }
        
        // Validate tag is alphanumeric
        let alphanumericSet = CharacterSet.alphanumerics
        guard summonerTag.unicodeScalars.allSatisfy({ alphanumericSet.contains($0) }) else {
            errorMessage = "Summoner tag can only contain letters and numbers"
            showError = true
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            showError = true
            return
        }
        
        isLoading = true
        
        let db = Firestore.firestore()
        let updateData: [String: Any] = [
            "summonerName": summonerName,
            "summonerTag": summonerTag,
            "region": selectedRegion,
            "rank": fullRank,
            "role": selectedRole
        ]
        
        db.collection("users").document(userId).updateData(updateData) { error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            // Update the user data and dismiss
            let updatedUser = UserProfile(
                id: userData.id,
                summonerName: summonerName,
                summonerTag: summonerTag,
                region: selectedRegion,
                rank: fullRank,
                role: selectedRole,
                lookingForDuo: userData.lookingForDuo,
                lookingForClash: userData.lookingForClash,
                email: userData.email
            )
            
            onSave(updatedUser)
            dismiss()
        }
    }
}

#Preview {
    EditProfileView(userData: UserProfile(
        id: "123",
        summonerName: "TestPlayer",
        summonerTag: "2508",
        region: "NA",
        rank: "Gold II",
        role: "Mid",
        lookingForDuo: false,
        lookingForClash: false,
        email: "test@example.com"
    )) { _ in }
}
