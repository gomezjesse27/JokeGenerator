//
//  AuthService.swift
//  JokeGenerator
//
//  Created by Long Nguyen on 12/7/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore //casting as? User.self

class AuthService {
        
    static let shared = AuthService() //only 1 instance reused
    
    
//MARK: - Auth Function
//------------------------------------------------------
    @MainActor //execute on the main thread (where most UI works)
    func createUser(user: User, pw: String) async throws {
        try await Auth.auth().createUser(withEmail: user.email, password: pw)
        let docData: [String: Any] = [
            "username": user.username,
            "email": user.email,
        ]
        try? await Firestore.firestore().collection("users").document(user.email).setData(docData)
    }
    
    
    
//MARK: - API Function
//------------------------------------------------------
    
    
    @MainActor //main thread, as all auth service should be
    func loadUserData(email: String) async throws -> User {
        let docRefUser = Firestore.firestore().collection("users").document(email)
        
        return try await docRefUser.getDocument(as: User.self)
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        print("DEBUG: user just logged out")
        UserDefaults.standard.set("", forKey: USER_EMAIL)
    }
    
// MARK: - Favorites Functions
//------------------------------------------------------
    @MainActor
    func saveFavoriteJoke(email: String, joke: String) async throws {
        let favoritesRef = Firestore.firestore().collection("users").document(email).collection("favorites")
        let docData: [String: Any] = [
            "joke": joke,
            "timestamp": Timestamp(date: Date())
        ]
        try await favoritesRef.addDocument(data: docData)
    }
    
    @MainActor
    func loadFavoriteJokes(email: String) async throws -> [String] {
        let favoritesRef = Firestore.firestore().collection("users").document(email).collection("favorites")
        let snapshot = try await favoritesRef.order(by: "timestamp", descending: false).getDocuments()
        let jokes = snapshot.documents.compactMap { $0.data()["joke"] as? String }
        return jokes
    }
    
}
