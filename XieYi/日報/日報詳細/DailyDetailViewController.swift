//
//  DailyDetailViewController.swift
//  XieYi
//
//  Created by 写易 on 2021/01/14.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class DailyDetailViewController: ExSubViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var inputViwe: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var setCommentBtn: UIButton!
    @IBOutlet weak var personBtn: UIBarButtonItem!
    
    var name: String = ""
    var uid: String = ""
    var isApproved: Bool = false    //承認済み 確定
    var date: String = ""
    
    var commentListArray = Array<Dictionary<String, Any>>()
    var planWorkListArray = Array<Dictionary<String, Any>>()
    var reportListArray = Array<Dictionary<String, Any>>()
    var workStatusListArray = Array<Dictionary<String, Any>>()
    var planWorkTime = ""
    var workTime = ""
    
    @IBOutlet weak var inputViewCons: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customUI()
        
        // 获取popover页面的传值 重新请求并刷新数据
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: "DailyDetail"), object: nil)
        
        // 获取AddDaily页面的通知
        NotificationCenter.default.addObserver(self, selector: #selector(presentToAddDailyController), name: NSNotification.Name(rawValue: "AddDaily"), object: nil)
        // AddDaily画面から戻る通知
        NotificationCenter.default.addObserver(self, selector: #selector(presentBackFromAddDailyController), name: NSNotification.Name(rawValue: "BackFromAddDaily"), object: nil)
        
        // 监听键盘位移事件
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(node:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        uid = getUserIdFunc()
        print(uid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
        
        getReportDetailRequest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - 监听键盘事件并改变约束
    @objc func keyboardWillChangeFrame(node : Notification){
        print(node.userInfo ?? "")
        
        // 1.获取动画执行的时间
        let duration = node.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        // 2.获取键盘最终 Y值
        let endFrame = (node.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let y = endFrame.origin.y
        
        //3计算工具栏距离底部的间距
        let margin = UIScreen.main.bounds.height - y
        print("键盘高度",margin)
        
        //4.执行动画
        inputViewCons.constant = -margin
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - 销毁监听
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func customUI() {
        self.title = "日报"
        personBtn.tintColor = UIColor.clear
        personBtn.isEnabled = false
        
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        
        inputTextField.delegate = self
        
        table.register(UINib.init(nibName: "DailyDetailTableViewCell0", bundle: nil), forCellReuseIdentifier: "DailyDetailTableViewCell0")
        table.register(UINib.init(nibName: "DailyDetailTableViewCell1", bundle: nil), forCellReuseIdentifier: "DailyDetailTableViewCell1")
        table.register(UINib.init(nibName: "DailyDetailTableViewCell2", bundle: nil), forCellReuseIdentifier: "DailyDetailTableViewCell2")
        table.register(UINib.init(nibName: "DailyDetailTableViewCell3", bundle: nil), forCellReuseIdentifier: "DailyDetailTableViewCell3")
        table.register(UINib.init(nibName: "DailyDetailTableViewCell4", bundle: nil), forCellReuseIdentifier: "DailyDetailTableViewCell4")
        
        datePicker.minimumDate = Date.init(timeIntervalSinceNow: -60 * 60 * 24 * 60)
        datePicker.maximumDate = Date.init(timeIntervalSinceNow: 0)
        datePicker.addTarget(self, action: #selector(datePickerValueChange(_:)), for: .valueChanged)
        
        inputViwe.layer.borderWidth = 0.5
        inputViwe.layer.borderColor = UIColor.lightGray.cgColor
        
        self.navigationController?.navigationBar.tintColor = UIColor.systemIndigo
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="yyyyMMdd"
        datePicker.date = dateFormatter.date(from: date)!
        print("😈",date, uid)
    }
    
    func getReportDetailRequest() {
        if getTokenFunc().count != 0 {
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let userid: String
                let ymd: String
            }
            
            let para = Parameter(app: "EtOfficeGetReportInfo", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS", userid: uid, ymd: date)
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let data):
                    print(data)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        // TODO
                        let flag = jsonData["result"]["authflag"].object as! String
                        
                        if flag == "1" { // 是否有承认权限
                            self.personBtn.tintColor = UIColor.systemIndigo
                            self.personBtn.isEnabled = true
                        } else {
                            self.personBtn.tintColor = UIColor.clear
                            self.personBtn.isEnabled = false
                        }
                        
                        self.commentListArray = jsonData["result"]["commentlist"].object as! Array
                        self.planWorkListArray = jsonData["result"]["planworklist"].object as! Array
                        self.reportListArray = jsonData["result"]["reportlist"].object as! Array
                        self.workStatusListArray = jsonData["result"]["workstatuslist"].object as! Array
                        self.planWorkTime = jsonData["result"]["planworktime"].object as! String
                        self.workTime = jsonData["result"]["worktime"].object as! String
                        self.table.reloadData()
                    }
                case .failure(let error) :
                    print(error)
                }
            })
        }
    }
    
    // MARK: - 发送按钮点击事件
    @IBAction func setCommentBtnClick(_ sender: UIButton) {
        if inputTextField.text?.count ?? 0 > 0 {
            if inputTextField.text?.count ?? 0 <= 150 {
                let text = inputTextField.text
                setCommentRequest(comment: text!)
            } else {
                Util.showAlert(currentVC: self, msgKey: "MSG17")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if inputTextField.text?.count ?? 0 > 0 {
            if inputTextField.text?.count ?? 0 <= 150 {
                let text = inputTextField.text
                setCommentRequest(comment: text!)
            } else {
                Util.showAlert(currentVC: self, msgKey: "MSG17")
            }
        }
        return true
    }
    
    // MARK: - 评论网络请求
    func setCommentRequest(comment: String) {
        if getTokenFunc().count != 0 {
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let userid: String
                let ymd: String
                let comment: String
            }
            
            let para = Parameter(app: "EtOfficeSetComment", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS", userid: uid, ymd: date, comment: comment)
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let data):
                    debugPrint(response)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        self.commentListArray = jsonData["result"]["commentlist"].object as! Array
                        self.table.reloadData()
                        self.inputTextField.resignFirstResponder()
                        self.inputTextField.text = ""
                    }
                case .failure(let error) :
                    print(error)
                }
            })
        }
    }
    
    @objc func datePickerValueChange(_ picker: UIDatePicker) {
        debugPrint("datePickerValueChange........")
        date = DateUtils.stringFromDate(date: datePicker.date, format: "yyyyMMdd")
        getReportDetailRequest()
        
        //点击顶部日期, 打开日历选择画面，选择日期完了后，希望自动关闭日历窗口
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func refreshData(notification: NSNotification?) {
        let username = notification?.userInfo?["username"] as? String
        let uid = notification?.userInfo?["uid"] as? String
        let isApproved = notification?.userInfo?["isApproved"] as? Bool
        
        print(uid!, username!)
        self.title = username
        self.uid = uid!
        self.isApproved = isApproved ?? false
        getReportDetailRequest()
    }
    
    // 跳转至追加日报页面
    @objc func presentToAddDailyController() {
        let storyboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddDailyViewController") as! AddDailyViewController
        nextView.ymd = date
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    // 日報追加画面から戻る通知
    @objc func presentBackFromAddDailyController() {
        getReportDetailRequest()
    }
    
    @IBAction func personBtnClick(_ sender: UIBarButtonItem) {
        let storyboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "PersonPopoverViewController") as! PersonPopoverViewController
        nextView.rooter = "DailyDetail"
        self.navigationController?.present(nextView, animated: true, completion: {
            
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return planWorkListArray.count
        } else if section == 2 {
            return 1
        } else if section == 3 {
            return 1
        } else if section == 4 {
            //return 1
            
            //承認済み　確定
            if (isApproved == false) {
                return 1
            }
        } else if section == 5 {
            return commentListArray.count
        } else if section == 6 {
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tempCell = UITableViewCell.init()
        
        if indexPath.section == 0 {
            let cell: DailyDetailTableViewCell0 = table.dequeueReusableCell(withIdentifier: "DailyDetailTableViewCell0", for: indexPath) as! DailyDetailTableViewCell0
            
            cell.textLabel?.text = "予定: " + planWorkTime
            
            tempCell = cell
        } else if indexPath.section == 1 {
            let cell: DailyDetailTableViewCell1 = table.dequeueReusableCell(withIdentifier: "DailyDetailTableViewCell1", for: indexPath) as! DailyDetailTableViewCell1
            
            cell.titleLabel.text = planWorkListArray[indexPath.row]["project"] as? String
            
            cell.wbsLabel.text = planWorkListArray[indexPath.row]["wbs"] as? String
            
            cell.dateLabel.text = (planWorkListArray[indexPath.row]["date"] as? String)! + " " + (planWorkListArray[indexPath.row]["time"] as? String)!
            
            tempCell = cell
        } else if indexPath.section == 2 {
            let cell: DailyDetailTableViewCell2 = table.dequeueReusableCell(withIdentifier: "DailyDetailTableViewCell2", for: indexPath) as! DailyDetailTableViewCell2
            
            cell.textLabel?.text = "実績: " + workTime
            
            tempCell = cell
        } else if indexPath.section == 3 {
            let cell: DailyDetailTableViewCell3 = table.dequeueReusableCell(withIdentifier: "DailyDetailTableViewCell3", for: indexPath) as! DailyDetailTableViewCell3
            
            cell.workStatusListArray = workStatusListArray
            cell.collection.reloadData()
            
            tempCell = cell
        } else if indexPath.section == 4 {
            let cell: DailyDetailTableViewCell4 = table.dequeueReusableCell(withIdentifier: "DailyDetailTableViewCell4", for: indexPath) as! DailyDetailTableViewCell4
            
            cell.reportListArray = reportListArray
            
            cell.collection.reloadData()
            
            tempCell = cell
        } else if indexPath.section == 5 {
            let cell: UITableViewCell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "CELL")
            
            // 回复内容
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell.textLabel?.text = commentListArray[indexPath.row]["comment"] as? String
            
            // 回复人&时间
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat="yyyyMMddHHmmss"
            let time = commentListArray[indexPath.row]["time"] as? String
            let date = dateFormatter.date(from: time!)
            let finalDate = DateUtils.stringFromDate(date: date!, format: "yyyy.MM.dd HH:mm:ss")
            cell.detailTextLabel?.text = (commentListArray[indexPath.row]["username"] as? String)! + " " + finalDate
            
            cell.selectionStyle = .none
            
            tempCell = cell
        } else if indexPath.section == 6 {
            let cell: UITableViewCell = UITableViewCell.init(style: .default, reuseIdentifier: "CELL")
            
            cell.imageView?.image = .add
            cell.textLabel?.text = "返信を追加する"
            cell.selectionStyle = .none
            
            tempCell = cell
        }
        
        return tempCell
    }
}

extension DailyDetailViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            //            let storyboard = self.storyboard!
            //            let nextView = storyboard.instantiateViewController(withIdentifier: "DailyTaskViewController") as! DailyTaskViewController
            //            self.navigationController?.present(nextView, animated: true, completion: {
            //
            //            })
        } else if indexPath.section == 6 {
            
        }
    }
}
