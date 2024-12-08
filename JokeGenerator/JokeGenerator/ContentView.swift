//
//  ContentView.swift
//  JokeGenerator
//
//  Created by Long Nguyen on 12/8/24.
//

import SwiftUI

struct ContentView: View {
    
    let persistenceController = PersistenceController.shared
    @State var email: String = ""
    
    var body: some View {
        ZStack {
            if email.isEmpty {
                WelcomeView(email: $email)
            } else {
                HomeView(emailLoggedIn: $email)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
        .onAppear {
            if let userEmail = UserDefaults.standard.object(forKey: USER_EMAIL) {
                self.email = userEmail as! String
            }
        }
    }
}

#Preview {
    ContentView()
}
