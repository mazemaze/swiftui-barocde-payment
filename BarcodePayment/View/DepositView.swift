//
//  DepositView.swift
//  BarcodePayment
//
//  Created by 樋川裕次郎 on 2023/02/17.
//

import SwiftUI

struct DepositView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var amount = 0
    @State private var isValide = false
    var body: some View {
        VStack {
            if !isValide {
                Text("1円以上の金額を入力して下さい")
                    .foregroundColor(.red)
            }
            TextField("入金金額", value: $amount, formatter: NumberFormatter(), onCommit: {
                isValide = validateAmount(amount)
                
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()
            
            Button("入金する") {
                Task {
                    let result = try await BarcodeSystemFetcher().deposit(DepositRequest(walletId: appState.user!.walletId, amount: amount))
                    if result {
                        let user = try await BarcodeSystemFetcher().getUser(username: appState.user!.username)
                        appState.user = user
                    }
                    dismiss()
                }
                
            }
            .disabled(isValide)
            .buttonStyle(.borderedProminent)
        }
    }
    
    func validateAmount(_ amount: Int) -> Bool {
        if amount <= 0 {
            return false
        }
        return true
    }
}

struct DepositView_Previews: PreviewProvider {
    static var previews: some View {
        DepositView()
    }
}

