//
//  BarcodePaymentApp.swift
//  BarcodePayment
//
//  Created by 樋川裕次郎 on 2023/02/17.
//

import SwiftUI

@main
struct BarcodePaymentApp: App {
    @StateObject var appState = AppState()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
