//
//  RegistrationView.swift
//  BarcodePayment
//
//  Created by 樋川裕次郎 on 2023/02/17.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var appState: AppState
    @State private var username = ""
    var body: some View {
        VStack {
            TextField("ユーザー名を入力", text: $username)
                .padding()
                .textFieldStyle(.roundedBorder)
            Button("登録") {
                Task {
                    let user = try await BarcodeSystemFetcher().registerUser(username: username)
                    if user != nil {
                        appState.user = user
                        appState.isLogin = true
                    }
                }
                
            }
            .disabled(username.isEmpty)
            .buttonStyle(.borderedProminent)
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
