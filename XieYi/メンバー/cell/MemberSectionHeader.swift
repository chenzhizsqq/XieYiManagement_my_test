//
//  PersonInfoFooter.swift
//  K1_Student
//
//  Created by DavidBlack on 2021/03/22.
//

import Foundation
import UIKit

class MemberSectionHeader: UITableViewHeaderFooterView {
    
    static let identifier = "MemberSectionHeader"
    static func nib() -> UINib {
        return UINib(nibName: "MemberSectionHeader", bundle: nil)
    }

    @IBOutlet weak var sectionName: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
