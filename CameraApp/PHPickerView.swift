//
//  PHPickerView.swift
//  MyCamera
//
//  Created by 大浦光晴 on 2022/02/19.
//

import SwiftUI
import PhotosUI //SwiftUIに対応していないため、UIViewControllerRepresentableが必要。

struct PHPickerView: UIViewControllerRepresentable {
    //sheetが表示されているかどうか管理
    @Binding var isShowSheet: Bool
    //フォトライブラリーから読み込む写真
        //Binding：呼び出し元にcaptureImageを渡すため
    @Binding var captureImage: UIImage?
    
    //Coordinatorでコントローラのdelegateを管理
        //PHPickerViewControllerDelegateを使用するためには、NSObjectが必要になる。
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        //PHPickerView型の変数を用意
            //Coordinatorクラスの中でPHPickerViewの構造体を編集して、利用するために、parentに格納
        var parent: PHPickerView
        //イニシャライザ（最初に実行される）
        init(parent: PHPickerView) {
            //self：自分自身（Coordinatorクラスのこと）
            //self.parentのparentは、Coordinatorクラスのプロパティのparent
            //parentは、init関数の引数で受け取ったもの（PHPickerView）
            self.parent = parent
        }
        //フォトライブラリーで写真を選択・キャンセルした時に実行される
        //delegateメソッド、必ず必要
            //第一引数：フォトライブラリー画面を格納
            //第二引数：選択した写真の情報を格納。複数の写真を選択される可能性もあるため、複数の情報に対応できる配列。PHPickerResult型。didFinishPickingはラベル
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            //写真は1つだけ選べる設定なので、最初の1件を指定
                //このアプリでは、複数が選択されても最初の1件しか格納しないようにする（処理が複雑になってしまうため）
            if let result = results.first {
                //UIImage型の写真のみ非同期で取得
                    //写真が取れたタイミングで、非同期にコードの処理を動かす（相手の終了を待たない。）
                result.itemProvider.loadObject(ofClass: UIImage.self) {
                    //image:取得できた写真入る。error：エラー情報
                    (image, error) in
                    //写真が取得できたら、UIImage型にキャストする
                    if let unwrapImage = image as? UIImage {
                        self.parent.captureImage = unwrapImage
                    } else {
                        print("使用できる写真がないです")
                    }
                }
                //フォトライブラリーから選択された写真がある場合、写真を取得した後でもsheetを閉じない
                parent.isShowSheet = true
                
            } else {
                //選択された写真がなければ、よばれる
                print("選択された写真がないです")
                
                //選択された写真がない場合は、sheetを閉じる
                parent.isShowSheet = false
                    
            }
        } // picker ここまで
    } // Coordinatorクラス　ここまで
    
    //Coordinatorを作成、SwiftUIによってい自動的に呼び出し
    func makeCoordinator() -> Coordinator {
        //self: 構造体PHPickerViewのことを指す
            //Coordinatorクラスの引数に自分自身を渡す。
        Coordinator(parent: self)
    }
    
    //Viewを作成する時に実行
        //フォトライブラリの起動に必要なPHPickerViewControllerのインスタンスを作成する
        //UIViewControllerRepresentableContext：PHPickerViewのデータ型
    func makeUIViewController(context: UIViewControllerRepresentableContext<PHPickerView>) -> PHPickerViewController {
        // PHPickerViewControllerのカスタマイズ
            //PHPickerConfiguration：PHPickerViewControllerの設定ができるインスタンス
        var configuration = PHPickerConfiguration()
        //静止画を選択：表示するものをimageのみにフィルタリングする
        configuration.filter = .images
        //フォトライブラリーで選択できる枚数を1枚にする
            //「0」にすると無制限に何枚でも可能
        configuration.selectionLimit = 1
        //PHPickerViewControllerのインスタンスを生成
        let picker = PHPickerViewController(configuration: configuration)
        //delegateを設定（メソッドがどこにあるのかを設定）。delegateを設定するとはどういうことか？？
            //Coordinatorクラスの「func picker」がdelegateメソッド→これがどこに書かれているのかを設定する。
            //contextの引数であるUIViewControllerRepresentableContextのcoordinatorを指定
        picker.delegate = context.coordinator
        //設定が終わったPHPickerViewControllerを返す
        return picker
    }
    //Viewが更新された時に実行
    //UIViewControllerRepresentableプロトコルを指定した時に必要になる。
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PHPickerView>) {
        //処理なし
    }
}
