//
//  RadioCell.swift
//  Yelp
//
//  Created by Karan Khurana on 7/25/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol RadioCellDelegate {
    optional func radioCell (radioCell: RadioCell, didChangeValue value: Bool)
}

class RadioCell: UITableViewCell {

    @IBOutlet weak var radioLabel: UILabel!
    @IBOutlet weak var radioImage: UIImageView!
    
    weak var delegate: RadioCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        print("Selected in Radio Cell: \(selected)")
        // Configure the view for the selected state
//        radioImage.highlighted = selected
        delegate?.radioCell?(self, didChangeValue: selected)
    }
    
    

}
