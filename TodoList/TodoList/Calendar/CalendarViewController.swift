//
//  CalendarViewController.swift
//  TodoList
//
//  Created by Hyeji on 2021/08/19.
//

import UIKit
import SQLite3
import FSCalendar

class CalendarViewController: UIViewController { // 2021.08.19-21 조혜지 calendarviewcontroller

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarTableView: UITableView!
    
    var db: OpaquePointer?
    let formatter = DateFormatter()
    var dotList = [Date]()
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
        dotSetting()
        readValues()
    }
    
    // sqlite table이 없다면 생성시키기
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
    
    // calendar design
    func initDesignSetting() {
        calendar.locale = Locale(identifier: "ko_KR")

        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "YYYY년 MM월"
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.headerTitleColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        calendar.appearance.headerTitleFont = .boldSystemFont(ofSize: 20)
        calendar.appearance.todayColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        calendar.appearance.selectionColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        calendar.appearance.eventSelectionColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        calendar.appearance.eventDefaultColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        
        calendarTableView.separatorStyle = .none
    }
    
    // calendar format setting
    func initFuncSetting() {
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        tDate = formatter.string(from: now)
    }
    
    // todo 작성한 날짜의 todo data select
    func dotSetting() {
        dotList.removeAll()
        
        let queryString = "SELECT tDate FROM todo GROUP BY tDate"
        print(queryString)
        
        var stmt: OpaquePointer?

        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return
        }
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            let tDate = formatter.date(from: String(cString: sqlite3_column_text(stmt, 0)))
            
            dotList.append(tDate!)
        }
        self.calendarTableView.reloadData()
    }
    
    // 선택된 날짜의 todo data select
    func readValues(){
        calendarList.removeAll()
        
        let queryString = "SELECT id, tDate, tList, tState, tStar FROM todo where tDate = '\(tDate)' ORDER BY tStar DESC"
        
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
            let tState = String(cString: sqlite3_column_text(stmt, 3))
            let tStar = String(cString: sqlite3_column_text(stmt, 4))
            
            calendarList.append(Todolist(id: Int(id), tDate: tDate, tList: tList, tState: tState, tStar: tStar))
        }
        self.calendarTableView.reloadData()
        
    }

    // 오늘 날짜에서 todo 완료 해제한 경우
    @IBAction func btnUnCheck(_ sender: UIButton) {
        if tDate == formatter.string(from: now) {
            var stmt: OpaquePointer?

            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let tState = "1"
            let id = "\(String(describing: calendarList[sender.tag].id!))"
            
            let queryString = "UPDATE todo SET tState=? where tDate = ? and id = ?"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing update: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 1, tState, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tState: \(errmsg)")
                return
            }

            if sqlite3_bind_text(stmt, 2, tDate, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tDate: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 3, id, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tDate: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure updating student: \(errmsg)")
                return
            }
            
            self.readValues()
        }
    }
    
    // 오늘 날짜에서 todo 완료한 경우
    @IBAction func btnCheck(_ sender: UIButton) {
        if tDate == formatter.string(from: now) {
            var stmt: OpaquePointer?

            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let tState = "0"
            let id = "\(String(describing: calendarList[sender.tag].id!))"
            
            let queryString = "UPDATE todo SET tState=? where tDate = ? and id = ?"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing update: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 1, tState, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tState: \(errmsg)")
                return
            }

            if sqlite3_bind_text(stmt, 2, tDate, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tDate: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 3, id, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tDate: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure updating student: \(errmsg)")
                return
            }
            
            self.readValues()
        }
    }
    
    // 오늘 날짜에서 todo 중요도 해제한 경우
    @IBAction func btnNoStar(_ sender: UIButton) {
        if tDate == formatter.string(from: now) {
            var stmt: OpaquePointer?

            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let tStar = "1"
            let id = "\(String(describing: calendarList[sender.tag].id!))"
            
            let queryString = "UPDATE todo SET tStar=? where tDate = ? and id = ?"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing update: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 1, tStar, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tState: \(errmsg)")
                return
            }

            if sqlite3_bind_text(stmt, 2, tDate, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tDate: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 3, id, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tDate: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure updating student: \(errmsg)")
                return
            }
            
            self.readValues()
        }
    }
    
    // 오늘 날짜에서 todo 중요도 선택한 경우
    @IBAction func btnStar(_ sender: UIButton) {
        if tDate == formatter.string(from: now) {
                        
            var stmt: OpaquePointer?

            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let tStar = "0"
            let id = "\(String(describing: calendarList[sender.tag].id!))"
            
            let queryString = "UPDATE todo SET tStar=? where tDate = ? and id = ?"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing update: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 1, tStar, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tState: \(errmsg)")
                return
            }

            if sqlite3_bind_text(stmt, 2, tDate, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tDate: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 3, id, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding tDate: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure updating student: \(errmsg)")
                return
            }
            
            self.readValues()
        }
    }

}

extension CalendarViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 특정 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.today = nil
        tDate = formatter.string(from: date)
        readValues()
    }
    
    // 특정 날짜에 점 찍기
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if self.dotList.contains(date){
            return 1
        }
        return 0
    }
    
}

// tableview cell data 넣기
extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "calendarCell") as! CalendarTableViewCell
        let selectToDoContent = calendarList[indexPath.row]
        
        cell.lblTodo.text = selectToDoContent.tList
        
        cell.btnUncheck.tintColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        cell.btnCheck.tintColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        
        if selectToDoContent.tState == "1" {
            cell.btnUncheck.isHidden = true
            cell.btnCheck.isHidden = false
        }else {
            cell.btnUncheck.isHidden = false
            cell.btnCheck.isHidden = true
        }
        
        cell.btnUncheck.tag = indexPath.row
        cell.btnCheck.tag = indexPath.row
        
        
        if tDate == formatter.string(from: now) {
            if selectToDoContent.tStar == "1" {
                cell.btnNoStar.isHidden = true
                cell.btnStar.isHidden = false
            }else {
                cell.btnNoStar.isHidden = false
                cell.btnStar.isHidden = true
            }
        }else {
            if selectToDoContent.tStar == "1" {
                cell.btnNoStar.isHidden = true
                cell.btnStar.isHidden = false
            }else {
                cell.btnNoStar.isHidden = true
                cell.btnStar.isHidden = true
            }
        }
        
        cell.btnNoStar.tag = indexPath.row
        cell.btnStar.tag = indexPath.row

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarList.count
    }

}

// tableviewcell 높이
extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
