//
//  DailyViewController.swift
//  XieYi
//
//  Created by 写易 on 2020/10/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import YYRefreshView

class DailyViewController: ExMainViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var personBtn: UIBarButtonItem!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var commitBtn: UIBarButtonItem!
    @IBOutlet weak var allSelectBtn: UIBarButtonItem!
    
    // 「データがありません」を表示
    @IBOutlet weak var tipsLabel: UILabel!
    
    var selectFlag = false
    var name: String = ""
    var uid: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tipsLabel.isHidden = true
        uid = getUserIdFunc()
        print(uid)
        customUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if isLogin() {
            self.getReportListRequest(uid: uid)
        } else {
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "Login")
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        editBtn.title = NSLocalizedString("EDIT", comment: "编辑")
        self.table!.setEditing(false, animated:true)
        commitBtn.tintColor = UIColor.clear
        commitBtn.isEnabled = false
        allSelectBtn.tintColor = UIColor.clear
        allSelectBtn.isEnabled = false
        selectFlag = false
        self.title = "日报"
    }
    
    func customUI() {
        commitBtn.tintColor = UIColor.clear
        commitBtn.isEnabled = false
        allSelectBtn.tintColor = UIColor.clear
        allSelectBtn.isEnabled = false
        personBtn.tintColor = UIColor.clear
        personBtn.isEnabled = false
        editBtn.tintColor = UIColor.clear
        editBtn.isEnabled = false
        
        table.delegate = self
        table.dataSource = self
        table.register(UINib.init(nibName: "DailyTableViewCell", bundle: nil), forCellReuseIdentifier: "DailyTableViewCell")
        
        // 下拉刷新逻辑
        table.addYYRefresh(position: .top) { (refresh) in
            if !self.table.isEditing {
                self.getReportListRequest(uid: self.uid)
                refresh.endRefresh()
            } else {
                refresh.endRefresh()
            }
        }
        // 上拉刷新逻辑
        table.addYYRefresh(position: .bottom) { (refresh) in
            if !self.table.isEditing {
                refresh.endRefresh()
            } else {
                refresh.endRefresh()
            }
        }
        
        // 获取popover页面的传值 重新请求并刷新数据
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: "Daily"), object: nil)
    }
    
    @objc func refreshData(notification: NSNotification?) {
        let username = notification?.userInfo?["username"] as? String
        let uid = notification?.userInfo?["uid"] as? String
        
        print(uid!, username!)
        self.title = username
        self.uid = uid!
        getReportListRequest(uid: uid!)
    }
    
    //MARK: - 日报列表请求(带参数)
    func getReportListRequest(uid:String) {
        if getTokenFunc().count != 0 {
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let userid: String
            }
            
            let para = Parameter(app: "EtOfficeGetReportList", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS", userid: uid)
            
            debugPrint(uid)
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let data):
                    print(data)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        let flag = jsonData["result"]["authflag"].object as! String
                        
                        if flag == "1" { // 是否有承认权限
                            self.personBtn.tintColor = UIColor.systemIndigo
                            self.personBtn.isEnabled = true
                            self.editBtn.tintColor = UIColor.systemIndigo
                            self.editBtn.isEnabled = true
                        } else {
                            self.personBtn.tintColor = UIColor.clear
                            self.personBtn.isEnabled = false
                            self.editBtn.tintColor = UIColor.clear
                            self.editBtn.isEnabled = false
                        }
                        
                        self.dataArray = jsonData["result"]["group"].object as! Array
                        self.table.reloadData()
                        
                        //「データがありません」を表示
                        if (self.dataArray.isEmpty){
                            self.tipsLabel.isHidden = false
                        }else{
                            self.tipsLabel.isHidden = true
                        }
                    }
                case .failure(let error) :
                    print(error)
                }
            })
        }
    }
    
    //MARK: - 承认日报请求(复数)
    func dailyCommitRequest(indexArray: NSMutableArray) {
        if dataArray.count == 0 {
            return
        }
        
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let userid: String
                let updateymd: Array<String>
            }
            
            let para = Parameter(
                app: "EtOfficeSetApprovalJsk",
                token: getTokenFunc(),
                tenant: getTenantidFunc(),
                hpid: getHpidFunc(),
                device: "iOS",
                userid: self.uid,
                updateymd: indexArray as! Array<String>
            )
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let data):
                    print(data)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        self.getReportListRequest(uid: self.uid)
                    }
                case .failure(let error) :
                    print(error)
                }
            })
        }
    }
    
    // MARK: - Button Click
    // MARK: 全选按钮点击事件
    @IBAction func allSelectBtnClick(_ sender: UIBarButtonItem) {
        if selectFlag == false {
            selectFlag = true
            if dataArray.count > 0 {
                for i in 0...dataArray.count - 1 {
                    let tempArray = dataArray[i]["reportlist"] as! Array<Dictionary<String, Any>>
                    for j in 0...tempArray.count - 1 {
                        let indexPath = NSIndexPath.init(row: j, section: i)
                        table.selectRow(at: indexPath as IndexPath, animated: true, scrollPosition: .none)
                    }
                }
            }
        } else {
            selectFlag = false
            if dataArray.count > 0 {
                for i in 0...dataArray.count - 1 {
                    let tempArray = dataArray[i]["reportlist"] as! Array<Dictionary<String, Any>>
                    for j in 0...tempArray.count - 1 {
                        let indexPath = NSIndexPath.init(row: j, section: i)
                        table.deselectRow(at: indexPath as IndexPath, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: 承认按钮点击事件
    @IBAction func commitBtnClick(_ sender: UIBarButtonItem) {
        let selectItems = NSMutableArray.init(capacity: 0)
                print(table.indexPathsForSelectedRows as Any)
        for indexPath in [table.indexPathsForSelectedRows] {
            print(indexPath as Any)
            if indexPath?.count ?? 0 > 0 {
                for i in 0...indexPath!.count - 1 {
                    let m = indexPath![i][0]
                    let n = indexPath![i][1]
                    let array = dataArray[m]["reportlist"] as! Array<Dictionary<String, Any>>
                    selectItems.add(array[n]["yyyymmdd"]!)
                }
                print(selectItems)
                if selectItems.count > 0 {
                    // 承認確認
                    Util.showAlert(currentVC: self,
                                   title: NSLocalizedString("CONFIRM", comment: ""),
                                   msg: NSLocalizedString("MSG18", comment: ""),
                                   okBtn: NSLocalizedString("OK", comment: ""),
                                   okHandler: { (_) in
                        self.dailyCommitRequest(indexArray: selectItems)
                    },
                                   cancelBtn: NSLocalizedString("CANCEL", comment: ""),
                                   cancelHandler: nil)
                    
                }
            } else {
                Util.showAlert(currentVC: self, msgKey: "MSG19")
            }
        }
    }
    
    // MARK: 编辑按钮点击事件
    @IBAction func editBtnClick(_ sender: UIBarButtonItem) {
        if(self.table!.isEditing == false) {
            editBtn.title = NSLocalizedString("CANCEL", comment: "取消")
            editBtn.image = nil
            self.table!.setEditing(true, animated:true)
            commitBtn.tintColor = UIColor.systemIndigo
            commitBtn.isEnabled = true
            allSelectBtn.tintColor = UIColor.systemIndigo
            allSelectBtn.isEnabled = true
            selectFlag = false
        }
        else {
            editBtn.title = NSLocalizedString("EDIT", comment: "编辑")
            editBtn.image = UIImage(named:"edit")!
            self.table!.setEditing(false, animated:true)
            commitBtn.tintColor = UIColor.clear
            commitBtn.isEnabled = false
            allSelectBtn.tintColor = UIColor.clear
            allSelectBtn.isEnabled = false
            selectFlag = false
        }
    }
    
    // MARK: 人员按钮点击事件
    @IBAction func personBtnClick(_ sender: UIBarButtonItem) {
        let storyboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "PersonPopoverViewController") as! PersonPopoverViewController
        nextView.rooter = "Daily"
        self.navigationController?.present(nextView, animated: true, completion: {
            
        })
    }
    
    // MARK: - Delegate && DataSource
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var month = (dataArray[section]["month"] as! String)
        let start = month.index(month.startIndex, offsetBy: 4)
        month.insert(".", at: start)
        return month
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tempArray : Array = dataArray[section]["reportlist"] as! Array<Dictionary<String, Any>>
        return tempArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DailyTableViewCell = table.dequeueReusableCell(withIdentifier: "DailyTableViewCell", for: indexPath) as! DailyTableViewCell
        
        cell.selectedBackgroundView = UIView.init(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = UIColor.clear
        
        let array = dataArray[indexPath.section]["reportlist"] as! Array<Dictionary<String, Any>>
        
        // Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="yyyyMMdd"
        
        let time = array[indexPath.row]["yyyymmdd"] as? String
        let date = dateFormatter.date(from: time!)
        let finalDate = DateUtils.stringFromDate(date: date!, format: "yyyy.MM.dd")
        
        cell.timeLabel.text = finalDate
        
        // Title
        cell.titleLabel.text = (array[indexPath.row]["title"] as? String)!
        
        // Name
        let name = array[indexPath.row]["approval"] as? String
        cell.nameLabel.text = name
        
        // Status
        cell.statusLabel.text = name?.count ?? 0 > 0 ? " 承認済み " : " 未承認 "
        cell.statusLabel.backgroundColor = name?.count ?? 0 > 0 ? UIColor.systemIndigo : UIColor.systemPink
        
        // Content
        cell.contentLabel.text = array[indexPath.row]["content"] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        let array = dataArray[indexPath.section]["reportlist"] as! Array<Dictionary<String, Any>>
        let name = array[indexPath.row]["approval"] as? String
        return name?.count ?? 0 > 0 ? false : true
    }
}

extension DailyViewController {
    //多选取消选中执行的方法
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //处理取消选中
        print("deselect")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !table.isEditing {
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "DailyDetailViewController") as! DailyDetailViewController
            let array = dataArray[indexPath.section]["reportlist"] as! Array<Dictionary<String, Any>>
            let date = array[indexPath.row]["yyyymmdd"] as? String
            nextView.date = date!
            nextView.uid = uid
            
            //承認済み　確定
            let name = array[indexPath.row]["approval"] as? String
            nextView.isApproved = name?.count ?? 0 > 0 ? true : false
            
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
}
