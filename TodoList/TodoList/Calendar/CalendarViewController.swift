//
//  CalendarViewController.swift
//  TodoList
//
//  Created by Hyeji on 2021/08/19.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    
    let formatter = DateFormatter()
    var dates = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initDesignSetting()
        initFuncSetting()
        calendar.delegate = self
        calendar.dataSource = self
    }
    
    func initDesignSetting() {
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "YYYY년 MM월"
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.headerTitleColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        calendar.appearance.headerTitleFont = .boldSystemFont(ofSize: 20)
        calendar.appearance.selectionColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        calendar.appearance.todayColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        
        calendar.appearance.eventSelectionColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        calendar.appearance.eventDefaultColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
    }
    
    func initFuncSetting() {
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
              
        let xmas = formatter.date(from: "2021-08-25")
        let sampledate = formatter.date(from: "2021-08-22")
        dates = [xmas!, sampledate!]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CalendarViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(formatter.string(from: date) + " 선택됨")
    }
    // 날짜 선택 해제 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(formatter.string(from: date) + " 해제됨")
    }
    
    // 날짜 밑에 점 찍기
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if self.dates.contains(date){
            return 1
        }
        return 0
    }
    
}
