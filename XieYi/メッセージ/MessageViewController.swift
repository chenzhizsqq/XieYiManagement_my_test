//
//  MessageViewController.swift
//  XieYi
//
//  Created by 写易 on 2020/12/14.
//

import UIKit
import Alamofire
import SwiftyJSON
import YYRefreshView

class MessageViewController: ExMainViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var allBtn: UIBarButtonItem!
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    
    // 「データがありません」を表示
    @IBOutlet weak var tipsLabel: UILabel!
    
    var selectFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tipsLabel.isHidden = true
        customUI()
    }
    
    func customUI() {
        table.delegate = self
        table.dataSource = self
        
        // 下拉刷新逻辑
        table.addYYRefresh(position: .top) { (refresh) in
            if !self.table.isEditing {
                self.getMessageRequest()
                refresh.endRefresh()
            } else {
                refresh.endRefresh()
            }
        }
        // 上拉刷新逻辑
        table.addYYRefresh(position: .bottom) { (refresh) in
            if !self.table.isEditing {
                self.getMoreMessageRequest()
                refresh.endRefresh()
            } else {
                refresh.endRefresh()
            }
        }
        
        // 初始化Btn
        allBtn.tintColor = UIColor.clear
        allBtn.isEnabled = false
        deleteBtn.tintColor = UIColor.clear
        deleteBtn.isEnabled = false
        editBtn.title = NSLocalizedString("EDIT", comment: "编辑")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getMessageRequest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        editBtn.title = NSLocalizedString("EDIT", comment: "编辑")
        self.table!.setEditing(false, animated:true)
        allBtn.tintColor = UIColor.clear
        allBtn.isEnabled = false
        deleteBtn.tintColor = UIColor.clear
        deleteBtn.isEnabled = false
        selectFlag = false
    }
    
    func messageAlert(title: String, message: String, index: NSIndexPath) {
        let alert = UIAlertController.init(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: NSLocalizedString("ARCHIVE", comment: "アーカイブ"), style: .default, handler: {
            action in
            print(index.row)
            self.deleteMessageRequest(index: index, readflg: "1")
        }))
        alert.addAction(.init(title: NSLocalizedString("DELETE", comment: "削除"), style: .default, handler: {
            action in
            print(index.row)
            self.deleteMessageRequest(index: index, readflg: "2")
        }))
        alert.addAction(.init(title: NSLocalizedString("CANCEL", comment: "キャンセル"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - 编辑按钮点击事件
    @IBAction func editBtnClick(_ sender: UIBarButtonItem) {
        if(self.table!.isEditing == false) {
            editBtn.title = NSLocalizedString("CANCEL", comment: "キャンセル")
            editBtn.image = nil
            self.table!.setEditing(true, animated:true)
            allBtn.tintColor = UIColor.systemIndigo
            allBtn.isEnabled = true
            deleteBtn.tintColor = UIColor.systemIndigo
            deleteBtn.isEnabled = true
            selectFlag = false
        }
        else {
            editBtn.title = NSLocalizedString("EDIT", comment: "编辑")
            editBtn.image = UIImage(named:"edit")!
            self.table!.setEditing(false, animated:true)
            allBtn.tintColor = UIColor.clear
            allBtn.isEnabled = false
            deleteBtn.tintColor = UIColor.clear
            deleteBtn.isEnabled = false
            selectFlag = false
        }
    }
    
    // MARK: - 全部按钮点击事件
    @IBAction func allBtnClick(_ sender: UIBarButtonItem) {
        if selectFlag == false {
            selectFlag = true
            if dataArray.count > 0 {
                for i in 0...dataArray.count - 1 {
                    let indexPath = NSIndexPath.init(row: i, section: 0)
                    table.selectRow(at: indexPath as IndexPath, animated: true, scrollPosition: .none)
                }
            }
        } else {
            selectFlag = false
            if dataArray.count > 0 {
                for i in 0...dataArray.count - 1 {
                    let indexPath = NSIndexPath.init(row: i, section: 0)
                    table.deselectRow(at: indexPath as IndexPath, animated: true)
                }
            }
        }
    }
    
    // MARK: - 删除按钮点击事件
    @IBAction func deleteBtnClick(_ sender: UIBarButtonItem) {
        let selectItems = NSMutableArray.init(capacity: 0)
        //        print(table.indexPathsForSelectedRows as Any)
        for indexPath in [table.indexPathsForSelectedRows] {
            print(indexPath as Any)
            if indexPath?.count ?? 0 > 0 {
                for i in 0...indexPath!.count - 1 {
                    selectItems.add(indexPath![i][1])
                }
                if selectItems.count > 0 {
                    // 削除確認
                    Util.showAlert(currentVC: self,
                                   title: NSLocalizedString("CONFIRM", comment: ""),
                                   msg: NSLocalizedString("MSG13", comment: ""),
                                   okBtn: NSLocalizedString("OK", comment: ""),
                                   okHandler: { (_) in
                        self.deleteMessagesRequest(indexArray: selectItems)
                        print("删除")
                    },
                                   cancelBtn: NSLocalizedString("CANCEL", comment: ""),
                                   cancelHandler: nil)
                    
                }
            } else {
                Util.showAlert(currentVC: self, msgKey: "MSG12")
            }
        }
    }
    
    // MARK: - 获取消息请求
    func getMessageRequest() {
        print("token = " + getTokenFunc())
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let count: String
            }
            
            let para = Parameter(app: "EtOfficeGetMessage", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS", count: "10")
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let data):
                    print(data)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        
                        self.dataArray = jsonData["result"]["messagelist"].object as! Array
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
    
    // MARK: - 获取更多消息请求
    func getMoreMessageRequest() {
        
        if dataArray.count == 0 {
            getMessageRequest()
            return
        }
        
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let count: String
                let lasttime: String
                let lastsubid: String
            }
            
            let para = Parameter(
                app: "EtOfficeGetMessage",
                token: getTokenFunc(),
                tenant: getTenantidFunc(),
                hpid: getHpidFunc(),
                device: "iOS",
                count: "10",
                lasttime: dataArray.last!["updatetime"] as! String,
                lastsubid: dataArray.last!["subid"] as! String
            )
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                print("getMoreMessageRequest")
                switch response.result {
                case .success(let data):
                    print(data)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        let tempArray = jsonData["result"]["messagelist"].object as! Array<[String : Any]>
                        self.dataArray = self.dataArray + tempArray
                        self.table.reloadData()
                    }
                case .failure(let error) :
                    print(error)
                }
                
            })
        }
    }
    
    // MARK: - 删除单条消息请求 readflg 1 归档 2 删除
    func deleteMessageRequest(index: NSIndexPath, readflg: String) {
        
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let updateid: Array<String>
                let readflg: String
            }
            
            let updateidArray: NSMutableArray = []
            let updatetime = dataArray[index.row]["updatetime"] as! String
            let subid = dataArray[index.row]["subid"] as! String
            let tempString = updatetime + subid
            updateidArray.add(tempString)
            
            let para = Parameter(
                app: "EtOfficeSetMessage",
                token: getTokenFunc(),
                tenant: getTenantidFunc(),
                hpid: getHpidFunc(),
                device: "iOS",
                updateid: updateidArray as! Array<String>,
                readflg: readflg
            )
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                print("deleteMessageRequest")
                debugPrint(response)
                
                let jsonData = JSON(response.data as Any)
                
                if (jsonData["status"].intValue == 0) {
                    
                    self.dataArray.removeAt(indexes: [index.row])
                    self.table.reloadData()
                } else {
                    Util.showAlert(currentVC: self, msgKey:"ERROR")
                }
            })
        }
    }
    
    // MARK: - 删除多条消息请求
    func deleteMessagesRequest(indexArray: NSMutableArray) {
        
        if dataArray.count == 0 {
            getMessageRequest()
            return
        }
        
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let updateid: Array<String>
                let readflg: String
            }
            
            let updateidArray: NSMutableArray = []
            for item in 0...indexArray.count - 1 {
                let updatetime = dataArray[indexArray[item] as! Int]["updatetime"] as! String
                let subid = dataArray[indexArray[item] as! Int]["subid"] as! String
                let tempString = updatetime + subid
                updateidArray.add(tempString)
            }
            
            let para = Parameter(
                app: "EtOfficeSetMessage",
                token: getTokenFunc(),
                tenant: getTenantidFunc(),
                hpid: getHpidFunc(),
                device: "iOS",
                updateid: updateidArray as! Array<String>,
                readflg: "2"
            )
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                print("deleteMessageRequest")
                debugPrint(response)
                
                let jsonData = JSON(response.data as Any)
                
                if (jsonData["status"].intValue == 0) {
                    
                    self.dataArray.removeAt(indexes: indexArray as! [Int])
                    self.table.reloadData()
                } else {
                    Util.showAlert(currentVC: self, msgKey:"ERROR")
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "messageCell")
        
        cell.selectedBackgroundView = UIView.init(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = UIColor.clear
        
        cell.textLabel?.text = dataArray[indexPath.row]["title"] as? String
        
        let tempStr = dataArray[indexPath.row]["content"] as? String
        var str = tempStr?.replacingOccurrences(of: "<br>", with: "")
        
        if (str?.contains("$") ?? false) as Bool {
            str = str?.replacingOccurrences(of: "$", with: "￥")
        } else {
            
        }
        
        cell.detailTextLabel?.text = str
        cell.detailTextLabel?.numberOfLines = 2
        cell.detailTextLabel?.textColor = UIColor.darkGray
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="yyyyMMddHHmmss"
        let time = dataArray[indexPath.row]["updatetime"]
        let date = dateFormatter.date(from: time as! String)
        let timeLabel = UILabel.init(frame: CGRect.init(x: screenWidth - 196, y: 10, width: 180, height: 14))
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.text = DateUtils.stringFromDate(date: date!, format: "yyyy.MM.dd HH:mm:ss")
        timeLabel.textAlignment = .right
        cell.addSubview(timeLabel)
        
        return cell
    }
}

extension MessageViewController {
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return NSLocalizedString("DELETE", comment: "删除")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteMessageRequest(index: indexPath as NSIndexPath, readflg: "2")
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        //处理选中
        if !table.isEditing {
            messageAlert(
                title: dataArray[indexPath.row]["title"] as? String ?? "",
                message: dataArray[indexPath.row]["content"] as? String ?? "",
                index: indexPath as NSIndexPath
            )
        } else {
            print("is editing")
        }
    }
    
    //多选取消选中执行的方法
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //处理取消选中
        print("deselect")
    }
}

extension Array {
    //Array方法扩展，支持根据索引数组删除
    mutating func removeAt(indexes: [Int]) {
        print(self.count)
        print(indexes.count)
        if self.count == indexes.count {
            self.removeAll()
        } else {
            for i in indexes.sorted(by: >) {
                self.remove(at: i)
            }
        }
    }
}
