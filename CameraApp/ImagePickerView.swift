//
//  ImagePickerView.swift
//  MyCamera
//
//  Created by 大浦光晴 on 2022/02/15.
//

import SwiftUI  //SWiftUIにUIKitも読み込まれているので「import UIKit」は必要なし

//UIKitのUIImagePickerControllerがSwiftUIに対応できていないため、UIViewControllerをSwiftUIのViewで使えるようにするために、UIViewControllerRepresentableプロトコルでラップする
//UIViewControllerRepresentableのプロトコルを指定すると、makeUIViewControllerとupdateUIViewControllerが必要になる
struct ImagePickerView: UIViewControllerRepresentable {
    
    //UIImagePickerController(写真撮影の画面)が表示されているかを管理する
    @Binding var isShowSheet: Bool
    //撮影した画像を管理
    @Binding var captureImage: UIImage? //UIImage型（UIImageクラス）
    
    //コーディネーターでコントローラのdelegateを管理
    //UIImagePickerControllerDelegate：カメラ操作で発生したユーザ操作をdelegateで検知する
    //→imagePickerControllerとimagePickerControllerDidCancelを利用するためにUIImagePickerControllerDelegateが必要
    //NSObjectとUINavigationControllerDelegateは、UIImagePickerControllerDelegateのプロトコルを使う上で最低限必要なプロトコル
    class Coordinator: NSObject,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
        
        //ImagePickerView型の変数を用意
        //Coordinatorの親（parent）：ImagePickerView、これを直接編集したいため、設定している。
        let parent: ImagePickerView //ImagePickreViewというデータ型
        //イニシャライザ、Coordinatorがインスタンス化される際、初期化されるため、その時に呼ばれる。
        //init：初期化のための手続きクロージャ内に記載
        //引数が親
        init(_ parent: ImagePickerView ) {
            //self.parentは、let parent: ImagePickerViewで指定したparentのことを指す。
            self.parent = parent
        }
        
        //撮影が終わった時に呼ばれる、必ず必要
        //UIImagePickerControllerクラスのdelegateメソッド
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            //撮影した画像をcaptureImageに保存
            //動画など他の情報もある中で、.originalImageと指定することで、撮影した写真のみ取得
            //取り出した写真はAny型になっているため、UIImage型へ型変換（キャスト）（as? UIImage）
            //if let文なので、変換に成功した時だけ、左辺（originalImage）に代入される
            if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                
                //ImagePickerViewのBinding変数captureImageにセット
                parent.captureImage = originalImage
            }
            //parent.isShowSheetはImagePickerViewのisShowSheetのこと
            //sheet（撮影画面）を閉じない→カメラによる撮影が終わっても閉じないようにする
            parent.isShowSheet = true
        }
        
        //撮影をキャンセルしたときのイベント
        //キャンセルボタンが押された時に呼ばれる、必ず必要
        //UIImagePickerControllerクラスのdelegateメソッド
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShowSheet = false
        }
        
    } // Coordinatorここまで
    
    //Coordinatorを作成、SwiftUIによって自動的に呼び出し
    func makeCoordinator() -> Coordinator {
        //イニシャライザ
        //Coordinatorクラスのインスタンスを作成
        //self：構造体structのimagePickerViewのことを指し、自分自身のことを渡している。
        Coordinator(self) //本当は、return Coordinator(self)と書く（処理が1行しかない時は省略できるため、省略している。）
        
        //このコードの後呼ばれるのがinitのイニシャライザ
    }
    //表示するViewを作成する時に自動で実行される
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        //UIImagePickerControllerのインスタンス作成
        let myImagePickerController = UIImagePickerController()
        //sourceTypeにcameraを設定→カメラの撮影画面になる
        myImagePickerController.sourceType = .camera
        //delegateを設定
        //coordinatorは、coordinatorクラスのことを指す、このクラスに設定されているカメラ撮影に関するdelegateを呼び出す（func imagePickerControllerとfunc imagePickerControllerDidCancel）
        //context：セットされる情報、引数で渡されてくる情報
        myImagePickerController.delegate = context.coordinator
        //UIImagePickerControllerを返す
        return myImagePickerController
    }
    //表示されているViewが更新された時に実行
    func updateUIViewController(_ uiView: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
        //　今回使用しないので、処理を記載していない
    }
    
} //ImagePickerViewはここまで


