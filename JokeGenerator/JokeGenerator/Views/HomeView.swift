//
// HomeView.swift
// JokeGenerator
//
// Created by Jaysen Gomez, Mariah Salgado, Kyle Lee
//

import SwiftUI

struct HomeView: View {
    
    @Binding var emailLoggedIn: String
    @State var user: User = User(username: "", email: "")
    @AppStorage(USER_EMAIL) var userEmail: String?

    @State private var selectedCategory: JokeCategory = .any
    @State private var jokeText: String = "Select a category and press refresh!"
    @State private var isLoading: Bool = false
    @State private var jokeHistory: [String] = [] // Store jokes for history

    @State private var currentJokeCate: String = ""
    @State private var showSetting: Bool = false
    @State private var showAlertDark: Bool = false
    @State private var showHistory: Bool = false // for history view
    @State private var showSideMenu: Bool = false // for side menu
    @State private var showFavorites: Bool = false // for favorites view state
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            ZStack(alignment: .leading) {
                backgroundColor(for: selectedCategory)
                    .ignoresSafeArea()
                
                // Main Content
                VStack(spacing: isLandscape ? 10 : 20) {
                    // header section... added hamburger menu
                    headerView
                    if isLandscape {
                        HStack(spacing: 20) {
                            jokeCardView
                                .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.7)
                            
                            VStack(spacing: 20) {
                                categoryPickerView
                                    .frame(width: geometry.size.width * 0.35)
                                
                                refreshButtonView
                                    .frame(width: geometry.size.width * 0.35)
                            }
                        }
                    } else {
                        Spacer()
                        jokeCardView
                            .frame(height: geometry.size.height * 0.4)
                        Spacer()
                        categoryPickerView
                        refreshButtonView
                    }
                }
                .padding()
                .animation(.easeInOut, value: selectedCategory)
                .onAppear {
                    fetchJoke()
                    Task {
                        try await fetchUserData()
                    }
                }
                .alert("Warning!", isPresented: $showAlertDark) {
                    Button("No, take me back", role: .destructive) {
                        selectedCategory = .any
                    }
                    Button("OK, let's go", role: .cancel) {}
                } message: {
                    Text("The dark jokes can be offensive to some people. Please proceed with caution.")
                }
                
                
                if showSideMenu {
                    // overlay behind side menu.. semi transparent
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showSideMenu = false
                            }
                        }
                    
                    //side menu transis
                    sideMenu
                        .transition(.move(edge: .leading))
                }
            }
            .sheet(isPresented: $showHistory) {
                HistoryView(history: jokeHistory)
            }
            .sheet(isPresented: $showSetting) {
                SettingView(showSetting: $showSetting, emailLoggedIn: $emailLoggedIn, user: $user)
            }
            .sheet(isPresented: $showFavorites) {
                FavoritesView(email: user.email)
            }
        }
    }
}

// MARK: - Subviews

extension HomeView {
    var headerView: some View {
        HStack {
            // system icon for hamburger
            Button(action: {
                withAnimation {
                    showSideMenu.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .resizable()
                    .frame(width: 24, height: 16)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }

            Spacer()

            // Title
            Text(user.username.isEmpty ? "Welcome!" : "Hi, \(user.username)!")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal)
    }
// Hamburger Menu View here - we can move this into seperate file but i mean its part of homeview so i wouldn't
    var sideMenu: some View {
        VStack(alignment: .leading, spacing: 40) {
            Text("Menu")
                .font(.largeTitle.bold())
                .padding(.top, 60)
                .padding(.leading, 20)
                .foregroundColor(.white)

            Button(action: {
                withAnimation {
                    showSideMenu = false
                    showHistory = true
                }
            }) {
                Label("View Joke History", systemImage: "clock")
                    .foregroundColor(.white)
                    .font(.title2.bold())
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
            }

            Button(action: {
                withAnimation {
                    showSideMenu = false
                    showFavorites = true
                }
            }) {
                Label("Favorites", systemImage: "heart.fill")
                    .foregroundColor(.white)
                    .font(.title2.bold())
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
            }

            Button(action: {
                withAnimation {
                    showSideMenu = false
                    showSetting = true
                }
            }) {
                Label("Settings", systemImage: "gear")
                    .foregroundColor(.white)
                    .font(.title2.bold())
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
            }

            Spacer()
        }
        .frame(width: 250)
        .background(Color.blue.opacity(0.9))
        .ignoresSafeArea()
    }
    
    var jokeCardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 5)
            
            VStack(spacing: 10) {
                Text(jokeText)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.black)
                
                Text("- \(currentJokeCate) joke")
                    .font(.footnote.italic())
                    .foregroundColor(.gray)
                
                // like button
                Button(action: {
                    saveFavoriteJoke()
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Like")
                            .fontWeight(.bold)
                    }
                    .padding(10)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .padding(.horizontal)
    }

    var categoryPickerView: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(JokeCategory.allCases, id: \.self) { category in
                Text(category.rawValue.capitalized)
                    .tag(category)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .frame(height: 60)
        .font(.title2)
        .background(Color.gray.opacity(0.4))
        .cornerRadius(12)
    }

    var refreshButtonView: some View {
        Button(action: fetchJoke) {
            HStack {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Next \"\(selectedCategory.rawValue.capitalized)\" Joke")
                        .font(.title2.bold())
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color.blue.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: .gray, radius: 5, x: 0, y: 3)
                }
            }
        }
        .disabled(isLoading)
        .padding(.horizontal)
    }
}

// MARK: - Functions

extension HomeView {
    private func backgroundColor(for category: JokeCategory) -> Color {
        switch category {
        case .any: return Color.blue.opacity(0.7)
        case .programming: return Color.green
        case .misc: return Color.orange
        case .dark: return Color.black
        case .pun: return Color.yellow
        case .spooky: return Color.purple
        case .christmas: return Color.red
        }
    }
    
    private func fetchUserData() async throws {
        do {
            let email = userEmail ?? ""
            user = try await AuthService.shared.loadUserData(email: email)
        } catch {
            print("DEBUG: Error loading user data")
        }
    }

    private func fetchJoke() {
        isLoading = true
        jokeText = "Loading..."
        
        JokeAPIClient.fetchJokes(category: selectedCategory, amount: 1) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let jokes):
                    if let joke = jokes.first {
                        if joke.type == "single" {
                            jokeText = joke.joke ?? "No joke available."
                        } else {
                            jokeText = "\(joke.setup ?? "")\n\n\(joke.delivery ?? "")"
                        }
                        jokeHistory.append(jokeText)
                        currentJokeCate = selectedCategory.rawValue.capitalized
                    } else {
                        jokeText = "No jokes found."
                    }
                case .failure(let error):
                    jokeText = "Failed to fetch joke: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func saveFavoriteJoke() {
        guard !jokeText.isEmpty, !user.email.isEmpty else { return }
        Task {
            do {
                try await AuthService.shared.saveFavoriteJoke(email: user.email, joke: jokeText)
            } catch {
                print("DEBUG: Failed to save favorite joke: \(error)")
            }
        }
    }
}

// JokeCategory Support for SwiftUI

extension JokeCategory: CaseIterable, Identifiable {
    public var id: String { rawValue }
    public static var allCases: [JokeCategory] {
        [.any, .programming, .misc, .dark, .pun, .spooky, .christmas]
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(emailLoggedIn: .constant(""))
    }
}

