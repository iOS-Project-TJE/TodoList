//
//  CalendarTableViewCell.swift
//  TodoList
//
//  Created by Hyeji on 2021/08/20.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var btnUncheck: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblTodo: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.backgroundColor = UIColor.white
        } else {
            contentView.backgroundColor = UIColor.white
        }
    }

}
