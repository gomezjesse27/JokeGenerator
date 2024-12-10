//
//  FavoritesView.swift
//  JokeGenerator
//
//  Created by Jaysen Gomez on 12/10/24.
//

import SwiftUI

struct FavoritesView: View {
    let email: String
    @State private var favorites: [String] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading favorites...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if favorites.isEmpty {
                    Text("No favorites yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(favorites, id: \.self) { joke in
                        Text(joke)
                            .padding()
                    }
                }
            }
            .navigationTitle("Your Favorites")
            .onAppear {
                loadFavorites()
            }
        }
    }
    
    private func loadFavorites() {
        Task {
            do {
                isLoading = true
                favorites = try await AuthService.shared.loadFavoriteJokes(email: email)
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
