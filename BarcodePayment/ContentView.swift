//
//  ContentView.swift
//  BarcodePayment
//
//  Created by 樋川裕次郎 on 2023/02/17.
//

import SwiftUI

struct ContentView: View {
    @State private var path = [String]()
    @EnvironmentObject var appState: AppState
    var body: some View {
        if !appState.isLogin {
            NavigationStack(path: $path) {
                VStack {
                    Text("Barmy")
                        .font(.largeTitle)
                    NavigationLink("ログイン", destination: {
                        LoginView()
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .padding()

                    NavigationLink("新規登録", destination: {
                        RegistrationView()
                    })
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .padding()
            }
//            HomeView()
        } else {
            HomeView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject var appState = AppState()
    static var previews: some View {
        ContentView()
    }
}
