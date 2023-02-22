//
//  HomeView.swift
//  BarcodePayment
//
//  Created by 樋川裕次郎 on 2023/02/17.
//

import SwiftUI

struct HomeView: View {
    @State var username : String = "名無し"
    @State var barcode : String = ""
    @State var balance : Int = 2000
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("アカウント名：\(appState.user?.username ?? "名無し")")
                    .padding()
                Text("残高：\(getComma((appState.user?.wallet.amount) ?? 0))円")
                Spacer()
                Image(uiImage:UIImage.makeQRCode(text: appState.user?.walletId ?? "nothing")!)
                Button("更新") {
                    Task {
                        let user = try await BarcodeSystemFetcher().getUser(username:appState.user?.username ?? "名無し")
                        if user != nil {
                            appState.user = user
                        }
                    }
                }
                Spacer()
                
                HStack {
                    NavigationLink("入金", destination: {
                        DepositView()
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .padding()
                    
                    NavigationLink("請求", destination: {
                        ClaimView()
                    })
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
        }
    }
    
    func getComma(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        let number = "¥\(formatter.string(from: NSNumber(value: num)) ?? "")"
        
        return number
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppState())
    }
}


func generateCode128Barcode(string: String) -> UIImage? {
    guard let data = string.data(using: .utf8) else {
        return nil
    }
    
    guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
        return nil
    }
    
    filter.setDefaults()
    filter.setValue(data, forKey: "inputMessage")
    
    guard let output = filter.outputImage else {
        return nil
    }
    
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(output, from: output.extent) else {
        return nil
    }
    
    let image = UIImage(cgImage: cgImage, scale: 2.0, orientation: UIImage.Orientation.up)
    
    return image
}

extension UIImage {
    static func makeQRCode(text: String) -> UIImage? {
        guard let data = text.data(using: .utf8) else { return nil }
        guard let QR = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data]) else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let ciImage = QR.outputImage?.transformed(by: transform) else { return nil }
        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
