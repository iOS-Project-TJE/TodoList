//
//  CalendarViewController.swift
//  TodoList
//
//  Created by Hyeji on 2021/08/19.
//

import UIKit
import SQLite3
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarTableView: UITableView!
    
    var db: OpaquePointer?
    let formatter = DateFormatter()
    var dates = [Date]()
    var calendarList: [Todolist] = []
    let now = Date()
    var tDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sqliteSetting()
        initDesignSetting()
        initFuncSetting()
        
        calendar.delegate = self
        calendar.dataSource = self
        
        calendarTableView.delegate = self
        calendarTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readValues()
    }
    
    func sqliteSetting() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("todoList.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS todo (id INTEGER PRIMARY KEY AUTOINCREMENT, tDate TEXT, tList TEXT, tState TEXT, tStar TEXT)",nil,nil,nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func initDesignSetting() {
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.today = nil

        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "YYYY년 MM월"
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.headerTitleColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        calendar.appearance.headerTitleFont = .boldSystemFont(ofSize: 20)
        calendar.appearance.selectionColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        calendar.appearance.eventSelectionColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        calendar.appearance.eventDefaultColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        
        calendarTableView.separatorStyle = .none
        // calendar.selectedDate
    }
    
    func initFuncSetting() {
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        tDate = formatter.string(from: now)
              
        let xmas = formatter.date(from: "2021-08-25")
        let sampledate = formatter.date(from: "2021-08-22")
        dates = [xmas!, sampledate!]
    }
    
    func readValues(){
        calendarList.removeAll()
        
        let queryString = "SELECT id, tDate, tList FROM todo where tDate = '\(tDate)'"
        print(queryString)
        
        var stmt: OpaquePointer?

        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return
        }
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            let id = sqlite3_column_int(stmt, 0)
            let tDate = String(cString: sqlite3_column_text(stmt, 1))
            let tList = String(cString: sqlite3_column_text(stmt, 2))
            
            calendarList.append(Todolist(id: Int(id), tDate: tDate, tList: tList))
        }
        self.calendarTableView.reloadData()
        
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

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "calendarCell") as! CalendarTableViewCell
        
        cell.btnUncheck.tintColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        cell.btnCheck.tintColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        
        cell.btnUncheck.isHidden = true
        cell.btnCheck.isHidden = false
        cell.lblTodo.text = "안녕하세요"
        // cell.lblTodo.attributedText = attributeString
        // attributeString.addAttribute(.baselineOffset, value: 0, range: (text as NSString).range(of:"Zedd"))
        
        let attributedText = NSMutableAttributedString(string: cell.lblTodo.text!)
        cell.lblTodo.attributedText = attributedText

        // 취소선 구현
//        let todo = NSMutableAttributedString(string: cell.lblTodo.text!)
//        todo.beauty.align(.center).strikethrough(1)
//        cell.lblTodo.attributedText = todo
        
        attributedText.addAttribute(.baselineOffset, value: 0, range: (cell.lblTodo.text! as NSString).range(of:cell.lblTodo.text!))
        attributedText.addAttribute(.strikethroughStyle, value: 1, range: (cell.lblTodo.text! as NSString).range(of:cell.lblTodo.text!))

        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
