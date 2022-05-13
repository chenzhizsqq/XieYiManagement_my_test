//
//  DailyDetailTableViewCell4.swift
//  XieYi
//
//  Created by 写易 on 2021/01/19.
//

import Foundation
import UIKit

class DailyDetailTableViewCell4: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collection: UICollectionView!
    
    var reportListArray = Array<Dictionary<String, Any>>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collection.delegate = self
        collection.dataSource = self
        
        collection.register(UINib.init(nibName: "DailyDetailCollectionViewCell1", bundle: nil), forCellWithReuseIdentifier: "DailyDetailCollectionViewCell1")
        collection.register(UINib.init(nibName: "DailyDetailCollectionViewCell2", bundle: nil), forCellWithReuseIdentifier: "DailyDetailCollectionViewCell2")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print("0")
            
        } else if indexPath.section == 1 {
            print("1")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddDaily"), object: nil, userInfo: nil)
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return reportListArray.count
        } else if section == 1 {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var tempCell = UICollectionViewCell.init()
        if indexPath.section == 0 {
            let cell = collection.dequeueReusableCell(withReuseIdentifier: "DailyDetailCollectionViewCell1", for: indexPath) as! DailyDetailCollectionViewCell1
            
            cell.titleLabel.text = "プロジェクト: " + (reportListArray[indexPath.row]["project"] as? String)!
            cell.codeLabel.text = "作業コード: " + (reportListArray[indexPath.row]["wbs"] as? String)!
            cell.timeLabel.text = "工数: " + (reportListArray[indexPath.row]["time"] as? String)!
            cell.reportLabel.text = "報告: " + (reportListArray[indexPath.row]["memo"] as? String)!
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            tempCell = cell
        } else if indexPath.section == 1 {
            let cell = collection.dequeueReusableCell(withReuseIdentifier: "DailyDetailCollectionViewCell2", for: indexPath) as! DailyDetailCollectionViewCell2
            
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            tempCell = cell
        }
        return tempCell
    }
}

// MARK: - Collection Extension
extension DailyDetailTableViewCell4: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 280, height: 105)
        } else if indexPath.section == 1 {
            return CGSize(width: 66, height: 105)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 4, left: 4, bottom: 4, right: 4)
    }
}
