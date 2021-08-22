//
//  SearchTableViewCell.swift
//  TodoList
//
//  Created by RayAri on 2021/08/19.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblList: UILabel!
    @IBOutlet weak var btnUncheck: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var btnNoStar: UIButton!
    @IBOutlet weak var btnStar: UIButton!
 
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.backgroundColor = UIColor.white
        } else {
            contentView.backgroundColor = UIColor.white
        }
    }

}
