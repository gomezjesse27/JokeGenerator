//
//  LoginView.swift
//  JokeGenerator
//
//  Created by Long Nguyen on 12/6/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var mailLoggedIn: String
    
    @FocusState var showKeyboard: Bool
    @State private var showAlert: Bool = false
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Text("Login view")
                .font(.system(size: 20))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.all, 32)
            
            Image("jokerTheme")
                .resizable()
                .frame(width: UIScreen.main.bounds.size.width, height: 240)
                .scaledToFit()
                .ignoresSafeArea()
                .padding()
            
            
            //textField
            VStack {
                TextField("Enter your Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .modifier(TxtFieldModifier())
                    .disableAutocorrection(true)
                    .keyboardType(.alphabet)
                
                SecureField("Enter your Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .modifier(TxtFieldModifier())
                    .keyboardType(.alphabet)
            }
            .focused($showKeyboard)
            .submitLabel(.continue)
            .disableAutocorrection(true)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Dismiss") {
                        showKeyboard = false
                    }
                }
            }
            
            Divider()
                .foregroundStyle(.white)
                .padding()
                        
            //Login Btn
            Button {
                Task {
                    try await login()
                }
            } label: {
                Text("Login")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Spacer()

        }
        .navigationTitle("")
        .background(.black)
        .alert("Error log in!", isPresented: $showAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("There is something wrong with your login credentials, please try again.")
        }
    }
    
//MARK: - Function
    
    @MainActor
    private func login() async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            UserDefaults.standard.set(email, forKey: USER_EMAIL)
            mailLoggedIn = email
        } catch {
            print("DEBUG: err logging in \(error.localizedDescription)")
            showAlert.toggle()
        }
    }
    
}

#Preview {
    LoginView(mailLoggedIn: .constant(""))
}

//MARK: - textField

struct TxtFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)
    }
}
