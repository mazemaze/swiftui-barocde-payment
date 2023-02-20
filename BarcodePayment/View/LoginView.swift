//
//  LoginView.swift
//  BarcodePayment
//
//  Created by 樋川裕次郎 on 2023/02/17.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var username = ""
    var body: some View {
        NavigationStack {
            VStack{
                TextField("ユーザ名を入力", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                Button("ログイン", action: {
                    Task {
                        let user = try await BarcodeSystemFetcher().login(username:username)
                        if user != nil {
                            appState.user = user
                            appState.isLogin = true
                        }
                    }
                })
                .disabled(username.isEmpty)
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
