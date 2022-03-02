//
//  UIImageExtension.swift
//  MyCamera
//
//  Created by 大浦光晴 on 2022/02/22.
//

import Foundation
import UIKit

//UIImageは、データ形式
//元々定義されているUIImageを今回extensionで機能を拡張している
//シェア機能のところで使用する
extension UIImage {
    //戻り値としてUIImageを返す。
    func resize() -> UIImage? {
        //self.size.width：画像自体の幅を取得できる。率を出す。
        let rate = 1024.0 / self.size.width
        //率を用いて高さを調整する
        //CGRect：サイズを調整するメソッド
        let rect = CGRect(x: 0, y: 0, width: self.size.width * rate, height: self.size.height * rate)
        
        //これから作る画像の領域を確保する
        UIGraphicsBeginImageContext(rect.size)
        //draw：確保したメモリ領域に対して、drawで描画している
        self.draw(in: rect)
        //サイズ調整を終えたイメージを格納
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //BeginImageContext：作業領域を確保
        //EndImageContext：作業領域を破棄
        UIGraphicsEndImageContext()
        
        return image
        
    }
}
