//
//  KBItemCell.swift
//  KartBuys
//
//  Created by Krishna Panchal on 06/01/24.
//

import Foundation
import UIKit

class KBItemCell: UITableViewCell {

    @IBOutlet weak var KBThumbnail: UIImageView!

    @IBOutlet weak var KBTitle: UILabel!
    
    @IBOutlet weak var KBPrice: UILabel!
    
    @IBOutlet weak var KBDetails: UILabel!
    
    func configureKBCell(item: KBItem) {
        
        KBTitle.text = item.title
        KBPrice.text = "₹\(item.price)"
        KBDetails.text = item.details
        KBThumbnail.image = item.toImage?.image as? UIImage
    }
}
