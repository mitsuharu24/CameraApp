//
//  ActivityView.swift
//  MyCamera
//
//  Created by 大浦光晴 on 2022/02/17.
//

//UIActivityViewControllerを使用するためにUIKitをimportする必要ある。
    //従来のUIKitもSwiftUIにもimportされている
import SwiftUI

//UIActivityViewControllerを使用するために、UIViewControllerRepresentableを使用
    //UIViewControllerRepresentableを使用する時、makeUIViewControllerとupdateUIViewControllerの2つのメソッド必要
struct ActivityView: UIViewControllerRepresentable {
    //UIActivityViewController（シェア機能）でシェアする写真
        //シェアは、テキストや動画もできるため、なんでもよいAnyの任意のデータ型を指定。
        //[]配列
    let shareItems: [Any]
    
    //表示するViewを作成する時に実行
    func makeUIViewController(context: Context) -> UIActivityViewController {
        
        //インスタンスを生成
            //UIActivityViewControllerでシェアする機能を生成
        let controller = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        
        return controller
    }
    
    //表示されているViewが更新された時に実行
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {
        //処理なし
    }
}


