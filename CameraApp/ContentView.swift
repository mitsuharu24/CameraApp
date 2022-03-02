//
//  ContentView.swift
//  MyCamera
//
//  Created by 大浦光晴 on 2022/02/15.
//

import SwiftUI

struct ContentView: View {
    //撮影する写真を保持する状態変数
    @State var captureImage: UIImage? = nil
    //撮影画面を表示するsheet（ModalView）（true:表示する、false:表示しない）
    @State var isShowSheet = false
//    //シェア画面を表示するシート（ModalView）（表示するか表示しないかの判定）
//    @State var isShowActivity = false
    //フォトライブラリーかカメラかを保持する状態変数
    @State var isPhotolibrary = false
    //actionSheetモディファイアでの表示有無を管理する状態変数
    @State var isShowAction = false
    
    
    var body: some View {
        //縦方向にレイアウト
        VStack {
            //スペースを追加
            Spacer()
//            //撮影した写真があるとき、if let文の中身が実行される。
//            if let unwrapCaptureImage = captureImage {
//                //撮影写真を表示
//                Image(uiImage: unwrapCaptureImage)
//                    //利用な可能な画面に合わせ、リサイズ
//                    .resizable()
//                    //アスペクト比（縦横比）を維持して画面内に
//                    .aspectRatio(contentMode: .fit)
//
//            }
            //「カメラを起動する」ボタン
            Button(action: {
                //ボタンをタップしたときのアクション
//                //カメラが使用できるかどうかをチェック
//                if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                    print("カメラは利用できます")
//                    //カメラが利用可能なら、isShowSheetをtrue→撮影画面を表示する
//                    isShowSheet = true
//
//                } else {
//                    print("カメラは利用できません")
//                }
                //撮影写真を初期化する
                captureImage = nil
                //ActionSheetを表示する
                isShowAction = true
//
            }) {
                //テキスト表示
                //モディファイア（modifier）の適用順番について
                    //上から順番に実行されるため、記載順番によってUIが変わる。
                Text("カメラを起動する")
                    //横幅一杯に表示
                    .frame(maxWidth: .infinity)
                    //高さ50ポイント指定
                    .frame(height: 50)
                    //文字列をセンタリング指定
                    .multilineTextAlignment(.center)
                    //背景色を青色
                    .background(Color.blue)
                    //文字色を白
                    .foregroundColor(Color.white)
                
            } //カメラを起動するボタン　ここまで
            //上下左右に余白を追加
            //isPresentedで指定した状態変数がtrueの時、クロージャの中身が実行される
            //$：参照の意味を持つ、isShowSheetの値を共有する
            //ImagePickerView：「ImagePickerView.swift」ファイルのstructImagePickerViewのことを指す。
            //「.sheet」モディファイアをButtonに定義しているが、実際はどこでもいい
                //.sheetはButtonに連動するのではなく、isPresentedに連動する
                //https://capibara1969.com/2521/
                //sheetは、ModalView
                //https://qiita.com/1amageek/items/e90e1cfb0ad497e8b27a
            //ボタンの上下左右に余白をつける
                //https://capibara1969.com/1954/
            .padding()
            
            .sheet(isPresented: $isShowSheet) {
                //写真があるかどうかをチェックする
                //captureImage：撮影した写真がnilでないなら
                if let unwrapCaptureImage = captureImage {
                    //撮影した写真がある→EffectViewを表示する
                    //編集した画像を選択画面ではもらう必要がないので、unwrapCaptureImageには「$」をつけない。エフェクト編集画面に画像を渡す一方方向のため。
                        //受け手のEffectViewのcaptureImageプロパティは状態変数でなく、定数で定義しているという理由からもunwrapCaptureImageに「$」をつけるとエラーになる。
                    EffectView(isShowSheet: $isShowSheet, captureImage: unwrapCaptureImage)

                } else {
                    //フォトライブラリーが選択された時（isPhotolibrary: true）
                        //isPhotolibrary:フォトライブラリーかカメラかを保持する状態変数
                    if isPhotolibrary {
                        PHPickerView(isShowSheet: $isShowSheet, captureImage: $captureImage)
                    } else {
                        //（isPhotolibrary: falseの時）カメラ撮影画面を表示する
                        ImagePickerView(isShowSheet: $isShowSheet, captureImage: $captureImage)
                    }
                }
            }
            //状態変数：$isShowActionに変化があったら実行
                //「カメラを起動する」ボタンを押した時にisShowActionをtrueにしている。
            .actionSheet(isPresented: $isShowAction) {
                //ActionSheet→構造体、表示するタイトル、メッセージ、ボタンメニューを定義
                ActionSheet(title: Text("確認"),
                            message: Text("選択してください"),
                            //選択肢で表示するメニュー
                            buttons: [
                                .default(Text("カメラ"), action :{
                                    //カメラを選択した時によばれる
                                    //フォトライブラリーかカメラかを保持する状態変数
                                    isPhotolibrary = false
                                    //カメラが利用可能かどうかチェックする
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        print("カメラは利用できません")
                                        //撮影画面を表示する
                                        isShowSheet = true
                                    } else {
                                        print("カメラは利用できません")
                                    }
                                }),
                                .default(Text("フォトライブラリー"), action: {
                                    //フォトライブラリーかカメラかを保持する状態変数
                                    isPhotolibrary = true
                                    //フォトライブラリー画面を表示するためにtrueにする。
                                        //.sheet(isPresented: $isShowSheet)
                                        //PHPickerViewでフォトライブラリー画面を表示する
                                    isShowSheet = true
                                }),
                                .cancel()
                            ])
            } // .actionSheet　ここまで
            
//            //「SNSに投稿する」ボタン
//            Button(action: {
//                //撮影した写真があるときだけ、UIActivityViewController（シェア機能）を表示
//                    //captureImageはオプショナル変数のため、アンラップする
//                    //if let文で、変数を使わないため、変数名を指定せず、「_」で省略可能
//                if let _ = captureImage {
//                    isShowActivity = true
//                }
//
//            }) {
//                Text("SNSに投稿する")
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 50)
//                    .multilineTextAlignment(.center)
//                    .background(Color.blue)
//                    .foregroundColor(Color.white)
//            } // 「SNSに投稿する」ボタン　ここまで
//            .padding()
//            //sheetを表示
//            //isPresentedで指定した状態変数がtrueの時実行
//            .sheet(isPresented: $isShowActivity) {
//                //UIActivityViewController（シェア機能）を表示、シェアする写真を渡す
//                    //ActivityViewは（「ActivityView.swift」にて）プロパティでshareItemsを設定しているので、引数を渡す処理必要。
//                    //[]配列型で渡す。
//                    //「!」：nilかどうか判定せずに、強制アンラップを実施
//                ActivityView(shareItems: [captureImage!])
//            }
            
        } // VStack ここまで
    } // body　ここまで
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
