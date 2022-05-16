//
//  Util.swift
//  XieYi
//
//  共通ユーティリティ
//  Created by Qi Yu on 2021/09/18.
//

import Foundation
import UIKit

class Util: NSObject {
    
    /// アラート表示
    /// - Parameters:
    ///   - currentVC: コントローラー
    ///   - title: タイトル
    ///   - msg: メッセージ
    ///   - cancelBtn: ボタン文字
    static func showAlert(currentVC: UIViewController?, title:String, msg:String, cancelBtn:String) {
        if currentVC == nil { return }
        
        let alertController = UIAlertController(title:title, message:msg , preferredStyle: .alert)
        let cancelAction = UIAlertAction(title:cancelBtn, style: .cancel, handler:nil)
        alertController.addAction(cancelAction)
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        if #available(iOS 13.0, *) {
            alertController.overrideUserInterfaceStyle = .light
        }
        
        // ダイアログ表示
        currentVC!.present(alertController, animated: true, completion: nil)
    }
    
    /// アラート表示
    /// - Parameters:
    ///   - currentVC: コントローラー
    ///   - msgKey: メッセージキー
    static func showAlert(currentVC: UIViewController?, msgKey: String) {
        showAlert(currentVC: currentVC,
                  title: NSLocalizedString("ERROR", comment: ""),
                  msg: NSLocalizedString(msgKey, comment: ""),
                  cancelBtn: NSLocalizedString("OK", comment: "")
        )
    }
    
    /// アラート表示
    /// - Parameters:
    ///   - currentVC: コントローラー
    ///   - msg: メッセージ
    static func showMessageAlert(currentVC: UIViewController?, msg: String) {
        showAlert(currentVC: currentVC,
                  title: NSLocalizedString("ERROR", comment: ""),
                  msg: msg,
                  cancelBtn: NSLocalizedString("OK", comment: "")
        )
    }
    
    /// アラート表示
    /// - Parameters:
    ///   - currentVC: コントローラー
    ///   - title: タイトル
    ///   - msgKey: メッセージキー
    static func showMessageAlert(currentVC: UIViewController?, title: String, msg: String) {
        showAlert(currentVC: currentVC,
                  title: title,
                  msg: msg,
                  cancelBtn: NSLocalizedString("OK", comment: "")
        )
    }
    
    /// アラート表示
    /// - Parameters:
    ///   - currentVC: コントローラー
    ///   - title: タイトル
    ///   - msg: メッセージ
    ///   - okBtn: 「はい」ボタン文字
    ///   - okHandler: 「はい」ボタン処理ハンドラ
    ///   - cancelBtn: 「いいえ」ボタン文字
    ///   - cancelHandler: 「いいえ」ボタン処理ハンドラ
    static func showAlert(currentVC: UIViewController?, title: String, msg: String, okBtn: String, okHandler: ((UIAlertAction) -> Void)? = nil, cancelBtn: String, cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        
        if currentVC == nil { return }
        
        let alertController = UIAlertController(title: title, message: msg , preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: okBtn, style: .default, handler: okHandler)
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title:cancelBtn, style: .cancel, handler: cancelHandler)
        alertController.addAction(cancelAction)
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        if #available(iOS 13.0, *) {
            alertController.overrideUserInterfaceStyle = .light
        }
        
        // ダイアログ表示
        currentVC!.present(alertController, animated: true, completion: nil)
    }
}
