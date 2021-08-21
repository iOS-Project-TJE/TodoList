//
//  CalendarTableViewCell.swift
//  TodoList
//
//  Created by Hyeji on 2021/08/20.
//

import UIKit

class CalendarTableViewCell: UITableViewCell { // 2021.08.20-21 조혜지 calendarviewcell

    @IBOutlet weak var btnUncheck: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblTodo: UILabel!
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
