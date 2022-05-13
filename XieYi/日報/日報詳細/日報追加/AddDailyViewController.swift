//
//  AddDailyViewController.swift
//  XieYi
//
//  Created by 写易 on 2021/03/16.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import ActionSheetPicker_3_0

class AddDailyViewController: ExSubViewController {
    
    @IBOutlet weak var projectBtn: UIButton!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var worktimeBtn: UIButton!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var reportTextView: UITextView!
    
    var projectCD: String = ""
    var wsbCD: String = ""
    var worktime: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var place: String = ""
    var memo: String = ""
    var ymd: String = ""
    
    let hourArray: NSMutableArray = NSMutableArray.init()
    let minuteArray: NSMutableArray = NSMutableArray.init()
    var codeArray: Array<Dictionary<String, String>> = Array.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CustomUI()
    }
    
    func CustomUI() {
        // init hourArray data
        for i in 0...24 {
            hourArray.add(i < 10 ? "0" + String(i) : String(i))
        }
        // init minuteArray data
        for i in 0...11 {
            minuteArray.add(i * 5 < 10 ? "0" + String(i * 5) : String(i * 5))
        }
        
        getProjectRequest()
    }
    
    func getProjectRequest() {
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let ymd: String
            }
            
            let para = Parameter(app: "EtOfficeGetProject", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS", ymd: ymd)
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                debugPrint(response)
                
                let jsonData = JSON(response.data as Any)
                
                if (jsonData["status"].int == 0) {
                    self.dataArray = jsonData["result"]["projectlist"].object as! Array
                } else {
                    
                }
            })
        }
    }
    
    func setReportRequest() {
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let userid: String
                let ymd: String
                let projectcd: String
                let wbscd: String
                let totaltime: String
                let starttime: String
                let endtime: String
                let place: String
                let memo: String
            }
            
            let para = Parameter(app: "EtOfficeSetReport", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS", userid: "", ymd: ymd, projectcd: projectCD, wbscd: wsbCD, totaltime: worktime, starttime: startTime, endtime: endTime, place: place, memo: memo)
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                debugPrint(response)
                
                let jsonData = JSON(response.data as Any)
                
                if (jsonData["status"].int == 0) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BackFromAddDaily"), object: nil, userInfo: nil)
                    self.dismiss(animated: true) {
                        
                    }
                } else {
                    
                }
            })
        }
    }
    
    @IBAction func projectBtnClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "プロジェクト名を選択する", message: nil,
                                                preferredStyle: .actionSheet)
        if dataArray.count != 0 {
            for i in 0...dataArray.count - 1 {
                let projectcd = dataArray[i]["projectcd"] as? String
                let projectname = dataArray[i]["projectname"] as? String
                let wbslist = dataArray[i]["wbslist"] as? Array<Dictionary<String, String>>
                
                let action = UIAlertAction.init(title: projectcd! + " - " + projectname!, style: .default) { (action) in
                    self.projectCD = projectcd ?? ""
                    self.codeArray = wbslist! as Array
                    let codeTitle = (wbslist![0]["wbscd"])! + " - " + (wbslist![0]["wbsname"])!
                    self.projectBtn.setTitle(projectcd! + " - " + projectname!, for: .normal)
                    self.codeBtn.setTitle(codeTitle, for: .normal)
                    self.wsbCD = wbslist![0]["wbscd"]!
                    print(self.projectCD)
                }
                alertController.addAction(action)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func codeBtnClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "作業コードを選択する", message: nil,
                                                preferredStyle: .actionSheet)
        if codeArray.count == 0 {
            Util.showAlert(currentVC: self, msgKey:"MSG14")
        } else {
            for i in 0...codeArray.count - 1 {
                let wbscd = codeArray[i]["wbscd"]
                let wbsname = codeArray[i]["wbsname"]
                
                let action = UIAlertAction.init(title: wbscd! + " - " + wbsname!, style: .default) { (action) in

                    self.codeBtn.setTitle(wbscd! + " - " + wbsname!, for: .normal)
                    self.wsbCD = wbscd!
                    print(wbscd!)
                }
                alertController.addAction(action)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func worktimeBtnClick(_ sender: UIButton) {
        ActionSheetMultipleStringPicker.show(withTitle: "工数を選択する", rows: [
                    hourArray, minuteArray], initialSelection: [8, 0], doneBlock: {
                        picker, indexes, values in

//                        print("values = \(values)")
//                        print("indexes = \(indexes)")
                        
                        let result = values as? Array<String>
                        let h = result![0]
                        let m = result![1]
                        let title = h + ":" + m
                        
                        self.worktimeBtn.setTitle(title, for: .normal)
                        self.worktime = h + m
                        
                        return
                }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func startBtnClick(_ sender: UIButton) {
        ActionSheetMultipleStringPicker.show(withTitle: "開始時間を選択する", rows: [
                    hourArray, minuteArray], initialSelection: [8, 0], doneBlock: {
                        picker, indexes, values in

//                        print("values = \(values)")
//                        print("indexes = \(indexes)")
                        
                        let result = values as? Array<String>
                        let h = result![0]
                        let m = result![1]
                        let title = h + ":" + m
                        
                        self.startBtn.setTitle(title, for: .normal)
                        self.startTime = h + m
                        
                        return
                }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func endBtnClick(_ sender: UIButton) {
        ActionSheetMultipleStringPicker.show(withTitle: "終り時間を選択する", rows: [
                    hourArray, minuteArray], initialSelection: [8, 0], doneBlock: {
                        picker, indexes, values in

//                        print("values = \(values)")
//                        print("indexes = \(indexes)")
                        
                        let result = values as? Array<String>
                        let h = result![0]
                        let m = result![1]
                        let title = h + ":" + m
                        
                        self.endBtn.setTitle(title, for: .normal)
                        self.endTime = h + m
                        
                        return
                }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func commitBtnClick(_ sender: UIButton) {
        place = placeTextField.text ?? ""
        memo = reportTextView.text ?? ""
        
        print(projectCD)
        print(wsbCD)
        print(worktime)
        print(startTime)
        print(endTime)
        print(place)
        print(memo)
        
        if projectCD.count == 0 {
            Util.showAlert(currentVC: self, msgKey:"MSG14")
            return
        }
        
        if wsbCD.count == 0 {
            Util.showAlert(currentVC: self, msgKey:"MSG15")
            return
        }
        
        if worktime.count == 0 {
            Util.showAlert(currentVC: self, msgKey:"MSG16")
            return
        }
        
        setReportRequest()
    }
    
    @IBAction func cancelBtnClick(_ sender: UIButton){
        
        // キャンセル確認
        Util.showAlert(currentVC: self,
                       title: NSLocalizedString("CONFIRM", comment: ""),
                       msg: NSLocalizedString("MSG20", comment: ""),
                       okBtn: NSLocalizedString("OK", comment: ""),
                       okHandler: { (_) in
            self.dismiss(animated: true)
        },
                       cancelBtn: NSLocalizedString("CANCEL", comment: ""),
                       cancelHandler: nil)
        
    }
}
