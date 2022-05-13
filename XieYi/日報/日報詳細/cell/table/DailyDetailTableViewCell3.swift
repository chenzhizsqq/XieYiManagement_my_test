//
//  DailyDetailTableViewCell3.swift
//  XieYi
//
//  Created by 写易 on 2021/01/18.
//

import Foundation
import UIKit

class DailyDetailTableViewCell3: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collection: UICollectionView!
    
    var workStatusListArray = Array<Dictionary<String, Any>>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collection.delegate = self
        collection.dataSource = self
        
        collection.register(UINib.init(nibName: "DailyDetailCollectionViewCell0", bundle: nil), forCellWithReuseIdentifier: "DailyDetailCollectionViewCell0")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(workStatusListArray)
        return workStatusListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "DailyDetailCollectionViewCell0", for: indexPath) as! DailyDetailCollectionViewCell0
        
        cell.time.text = workStatusListArray[indexPath.row]["time"] as? String
        cell.status.text = workStatusListArray[indexPath.row]["status"] as? String
        
        return cell
    }
}

// MARK: - Collection Extension
extension DailyDetailTableViewCell3: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 72, height: 72)
        }
        return CGSize(width: 0, height: 0)
    }
}
