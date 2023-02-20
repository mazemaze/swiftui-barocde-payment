//
//  ClaimView.swift
//  BarcodePayment
//
//  Created by 樋川裕次郎 on 2023/02/17.
//

import SwiftUI
import AVFoundation

struct ClaimView: View {
    @Environment(\.dismiss) private var dismiss
    @State var amount = 0
    @ObservedObject private var qrReader = QRReader()
    @EnvironmentObject var appState: AppState
    var body: some View {
        if qrReader.isdetectQR {
            VStack {
                Text("請求先: \(qrReader.qrData)")
                TextField("請求金額", value: $amount, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding()
                Button("請求") {
                    Task {
                        let result = try await BarcodeSystemFetcher().sendBalance(TransactionRequest(senderId: appState.user!.walletId, recieverId: qrReader.qrData, amount: amount))
                        
                        if result {
                            let user = try await BarcodeSystemFetcher().getUser(username: appState.user!.username)
                            appState.user = user
                            dismiss()
                        }
                    }
                }
            }
        } else {
            QRReaderView(caLayer: qrReader.videoPreviewLayer)
                .edgesIgnoringSafeArea(.all)
        }
        //QRコードを読み込んだらAlertで読み取り結果を出す。読み取ったらAVCaptureSessionを停止しているのでOKボタンを押して再度読み取り開始
    }
}

struct ClaimView_Previews: PreviewProvider {
    static var previews: some View {
        ClaimView()
    }
}


class BarcodeViewModel: ObservableObject {
    @Published var code: String = "read barcode..."
    @Published var isShowing: Bool = false
    @Published var isFound : Bool = false
    
    func onFound(_ code: String){
        self.code = code
        self.isShowing = false
        self.isFound = true
    }
}

struct QRReaderView: UIViewControllerRepresentable {
    var caLayer:CALayer
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<QRReaderView>) -> UIViewController {
        let viewController = UIViewController()
        
        viewController.view.layer.addSublayer(caLayer)
        caLayer.frame = viewController.view.layer.frame
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<QRReaderView>) {
        caLayer.frame = uiViewController.view.layer.frame
    }
}

class QRReader: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    
    @Published var qrData:String = ""
    
    @Published var isdetectQR = false
    
    //カメラ用のAVsessionインスタンス作成
    private let AVsession = AVCaptureSession()
    //カメラ画像を表示するレイヤー
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    // カメラの設定
    // 今回は背面カメラなのでposition: .back
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
    
    override init() {
        super.init()
        cameraInit()
    }
    
    func cameraInit(){
        //カメラデバイスの取得
        let devices = discoverySession.devices
        
        //背面のカメラ情報を取得
        if let backCamera = devices.first {
            do {
                //カメラ入力をinputとして取得
                let input = try AVCaptureDeviceInput(device: backCamera)
                
                //Metadata情報（今回はQRコード）を取得する準備
                //AVssessionにinputを追加:既に追加されている場合を考慮してemptyチェックをする
                if AVsession.inputs.isEmpty {
                    AVsession.addInput(input)
                    //MetadataOutput型の出力用の箱を用意
                    let captureMetadataOutput = AVCaptureMetadataOutput()
                    //captureMetadataOutputに先ほど入力したinputのmetadataoutputを入れる
                    AVsession.addOutput(captureMetadataOutput)
                    //MetadataObjectsのdelegateに自己(self)をセット
                    captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    //Metadataの出力タイプをqrにセット
                    captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                    
                    //カメラ画像表示viewの準備とカメラの開始
                    //カメラ画像を表示するAVCaptureVideoPreviewLayer型のオブジェクトをsessionをAVsessionで初期化でプレビューレイヤを初期化
                    videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: AVsession)
                    //カメラ画像を表示するvideoPreviewLayerの大きさをview（superview）の大きさに設定
                    //videoPreviewLayer?.frame = previewLayer.bounds
                    //カメラ画像を表示するvideoPreviewLayerをビューに追加
                    //previewLayer.addSublayer(videoPreviewLayer!)
                }
                //セッションの開始(今回はカメラの開始)
                DispatchQueue.global(qos: .background).async {
                    self.AVsession.startRunning()
                }
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
    }
    
    
    func startSession() {
        if AVsession.isRunning { return }
        AVsession.startRunning()
    }
    
    func stopSession() {
        if !AVsession.isRunning { return }
        AVsession.stopRunning()
    }
    
    
}
//MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRReader:AVCaptureMetadataOutputObjectsDelegate{
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        //カメラ画像にオブジェクトがあるか確認
        if metadataObjects.count == 0 {
            return
        }
        //オブジェクトの中身を確認
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // metadataのtype： metadata.type
            // QRの中身： metadata.stringValue
            guard let data = metadata.stringValue else { return }
            isdetectQR = true
            qrData = data
            print("読み取りvalue：",data)
            //一旦て停止
            stopSession()
            //AVsession.stopRunning()
        }
    }
}
