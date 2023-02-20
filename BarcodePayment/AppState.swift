//
//  AppState.swift
//  BarcodePayment
//
//  Created by 樋川裕次郎 on 2023/02/20.
//

import Foundation

class AppState: ObservableObject {
    @Published var isNavigateToLoginView = false
    
    @Published var isLogin = false
    
    @Published var user: User? = nil
}
