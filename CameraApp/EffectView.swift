//
//  EffectView.swift
//  MyCamera
//
//  Created by 大浦光晴 on 2022/02/22.
//

import SwiftUI

//フィルタ名を列挙した配列（Array）
//0.モノクロ
//1.Chrome
//2.Fade
//3.Instant
//4.Noir
//5.Process
//6.Tonal
//7.Transfer
//8.SepiaTone
let filterArray = ["CIPhotoEffectMono",
                   "CIPhotoEffectChrome",
                   "CIPhotoEffectFade",
                   "CIPhotoEffectInstant",
                   "CIPhotoEffectNoir",
                   "CIPhotoEffectProcess",
                   "CIPhotoEffectTonal",
                   "CIPhotoEffectTransfer",
                   "CIPhotoEffectSepiaTone"
]
//選択中のエフェクト（filterArrayの添字）
var filterSelectNumber = 0

struct EffectView: View {
    //エフェクト編集画面（sheet）の表示有無を管理する状態変数
        //呼び出し元の選択画面（ContentViewで実装）と双方向に状態変数をやりとりするため、@Bindingをつける
    @Binding var isShowSheet: Bool
    //撮影した写真を格納、エフェクト編集画面では値が変更されないので、let定数で定義、編集した画像は他の変数で格納する。
    let captureImage: UIImage
    //表示する写真（エフェクト編集後の写真）
    @State var showImage: UIImage?
    //シェア画面（UIActivityViewController）表示有無を管理する状態変数
    @State var isShowActivity = false
    
    var body: some View {
        //縦方向にレイアウト
        VStack {
            Spacer()
            //showImageは写真がない時はnilがセットされているので、写真がセットされている時のみ画面に写真を表示
            if let unwrapShowImage = showImage {
                Image(uiImage: unwrapShowImage)
                    //リサイズする
                    .resizable()
                //アスペクト比（縦横比）を維持して画面内に収まるようにする
                    .aspectRatio(contentMode: .fit)
            }
            Spacer()
            //エフェクトボタン
            Button(action: {
                //ボタンをタップした時のアクション
                //フィルタ名を指定
                let filterName = filterArray[filterSelectNumber]
                
                //filterArray[0] : "CIPhotoEffectMono"
                
                //次回に適用するフィルタを決めておく。
                filterSelectNumber += 1
                //最後のフィルタまで適用した場合、最初の0に戻す
                    //filterArray.count →9
                if filterSelectNumber == filterArray.count {
                    //次回のフィルタは最初に戻る
                    filterSelectNumber = 0
                }
                //❶元々の画像の回転角度を取得
                //rotate：回転角度を保存、画像の加工処理をすると、画像の縦方向横方向の情報が失われてしまうため、保存する必要がある。
                let rotate = captureImage.imageOrientation
                //❷UIImage形式の画像をCIImage形式に変換
                    //CIImage型は、CoreImageで使用するデータ型、この際画像の方向が失われてしまう。
                let inputImage = CIImage(image: captureImage)
                //❸フィルタの種別を引数で指定された種類を指定してCIFilterのインスタンスを取得
                    //このeffectFilterに加工情報を入れる
                //guard let：オプショナル変数を安全に取り出す方法、CIFilterがnill出ないように取り出す。
                guard let effectFilter = CIFilter(name: filterName) else {
                    return
                }
                //❹フィルタ加工のパラメータを初期化
                effectFilter.setDefaults()
                //❺インスタンスにフィルタ加工する元画像を設定
                effectFilter.setValue(inputImage, forKey: kCIInputImageKey)
                //❻フィルタ加工を行う情報を生成する
                guard let outputImage = effectFilter.outputImage else {
                    return
                }
                //CIContextのインスタンスを取得
                    //フィルタ加工するための作業領域を確保する
                let ciContext = CIContext(options: nil)
                //フィルタ加工後の画像をCIContext上に描画し、結果をcgImageとしてCGImage形式の画像を取得
                    //createCGImage：画像の加工処理
                //createCGImage
                    //第一引数：CIImage型の画像をセットする
                    //第二引数：描画する（レンダリング、アプリのメモリ上での画像変換）画像の領域をセットする
                guard let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else {
                    return
                }
                //❽フィルタ加工後の画像をCGImage形式からUIImage型にキャストする、元々の回転角度もrotateで渡す。
                showImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: rotate)
            }) {
                Text("エフェクト")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
            }
            .padding()
            //シェアボタン
            Button(action: {
                //ボタンをタップした時のアクション
                //シェア画面の表示有無を管理する状態変数
                    //UIActivityViewController（シェア画面）をモーダル表示する
                isShowActivity = true
            }) {
                Text("シェア")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
            } //「シェアボタン」ここまで
            //データバインド（連動）
                //「$」：参照の意味、同じデータの保存場所を利用できる。双方向でデータの読み書きができる。
            .sheet(isPresented: $isShowActivity) {
                //シェア画面表示
                //[]:配列
                    //showImageはUIImage型なので、そのままresizeメソッド使用可能
                    //resizeメソッドは、UIImageExtensionファイルで拡張済み
                    //シェアする際、画像をresizeして、引き渡す。
                ActivityView(shareItems: [showImage!.resize()!])
            }
            .padding()
            //閉じるボタン
            Button(action: {
                //ボタンをタップした時のアクション
                //エフェクト編集画面を閉じる
                isShowSheet = false
            }) {
                Text("閉じる")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
            } //閉じるボタン　ここまで
            
            .padding()
        } //VStackここまで
        //写真が表示される時に実行
            //.onAppear画面が表示される時に実行されるhttps://capibara1969.com/3529/
        .onAppear {
            //撮影した写真を表示する写真に設定
                //showImage：状態変数のため、値が変わると再描画される
            showImage = captureImage
        }
    }
}

struct EffectView_Previews: PreviewProvider {
    static var previews: some View {
        //EffevtViewの構造体で設定しているプロパティが設定されていないためエラーが出ている。
            //showImage：nilを許容しているため、初期値を設定する必要はない。
            //captureImage：初期値を設定剃るために、ダミーの写真を設定するpreview_use.jpg
                //→Preview Assets.xcassetsに画像を入れる。
        //プロパティの設定
            //isShowSheet→Binding型のtrueをセットする。なぜfalseではなく、trueを設定するのか？？
            //caputureImageUIImage型にキャスト、オプショナル型の変数なので、強制ラップする
        EffectView(isShowSheet: Binding.constant(true), captureImage: UIImage(named: "preview_use")!)
    }
}
