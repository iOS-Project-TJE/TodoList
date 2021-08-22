//
//  SearchViewController.swift
//  TodoList
//
//  Created by RayAri on 2021/08/19.
//

import UIKit
import SQLite3

class SearchViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var lblFirst: UILabel!
    @IBOutlet weak var lblNoItem: UILabel!
    @IBOutlet weak var tvSearch: UITableView!
    @IBOutlet weak var tfSearch: UITextField!

    var db: OpaquePointer?
    var searchTodoList: [Todolist] = []
    var search : String = ""
    var now = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        //SQLite생성
        SQliteSetting()
        //글자마다 변경
        change()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //페이지 초기설정
        pageSetting()

    }
    
    //SQLite생성
    func SQliteSetting(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("todoList.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS todo (id INTEGER PRIMARY KEY AUTOINCREMENT, tDate TEXT, tList TEXT, tState TEXT, tStar TEXT)",nil,nil,nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    //viewWillAppear 초기설정
    func pageSetting(){
        tfSearch.text=""
        tvSearch.delegate = self
        tvSearch.dataSource = self
        
        tvSearch.isHidden = true
        lblNoItem.isHidden = true
        lblFirst.isHidden = false
    
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        now = formatter.string(from: Date())
    }

    //입력시마다 변경
    @objc func textFieldDidChange(_ sender: Any?) {
        self.search = self.tfSearch.text!
       //SELECT
        readValues()
        
      }
    
    func change(){
        self.tfSearch.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    //SELECT - table list
    func readValues(){
        searchTodoList.removeAll()
        
        let queryString = "SELECT id, tDate, tList, tState, tStar FROM todo where tList like '%\(search)%' ORDER BY tDate asc, tStar desc"
        
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
            
            searchTodoList.append(Todolist(id: Int(id), tDate: tDate, tList: tList, tState: tState, tStar: tStar))
        }
        reload()
        
    }
    
    // 리로드
    func reload(){
        self.tvSearch.reloadData()
        
        if searchTodoList.count == 0 {
            tvSearch.isHidden = true
            lblNoItem.isHidden = false
            lblFirst.isHidden = true
        }else{
            tvSearch.isHidden = false
            lblNoItem.isHidden = true
            lblFirst.isHidden = true
        }
    }
    
    //오늘날짜 체크하기
    @IBAction func btnUncheck(_ sender: UIButton) {
        let searchDate = searchTodoList[sender.tag].tDate
        if now == searchDate {
            
            var stmt: OpaquePointer?
            
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let tState = "1"
            let id = "\(String(describing: searchTodoList[sender.tag].id!))"
            
            let queryString = "UPDATE todo SET tState=? where id = ?"
            
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
            
            if sqlite3_bind_text(stmt, 2, id, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding id: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure updating todo: \(errmsg)")
                return
            }
            
            self.readValues()

        }
        
    }
    
    //오늘날짜 체크해제
    @IBAction func btnCheck(_ sender: UIButton) {
        let searchDate = searchTodoList[sender.tag].tDate
        if now == searchDate {
            
            var stmt: OpaquePointer?
            
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let tState = "0"
            let id = "\(String(describing: searchTodoList[sender.tag].id!))"
            
            let queryString = "UPDATE todo SET tState=? where id = ?"
            
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
            
            if sqlite3_bind_text(stmt, 2, id, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding id: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure updating todo: \(errmsg)")
                return
            }
            
            self.readValues()

        }
        
        
    }
    
    // 오늘날짜 중요도체크
    @IBAction func btnNoStar(_ sender: UIButton) {
        let searchDate = searchTodoList[sender.tag].tDate
        if now == searchDate {
            
            var stmt: OpaquePointer?
            
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let tStar = "1"
            let id = "\(String(describing: searchTodoList[sender.tag].id!))"
            
            let queryString = "UPDATE todo SET tStar=? where id = ?"
            
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
            
            if sqlite3_bind_text(stmt, 2, id, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding id: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure updating todo: \(errmsg)")
                return
            }
            
            self.readValues()
        }
        
        
    }
    
    //오늘날짜 중요도체크해제
    @IBAction func btnStar(_ sender: UIButton) {
        let searchDate = searchTodoList[sender.tag].tDate
        if now == searchDate {
            
            var stmt: OpaquePointer?
            
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let tStar = "0"
            let id = "\(String(describing: searchTodoList[sender.tag].id!))"
            
            let queryString = "UPDATE todo SET tStar=? where id = ?"
            
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
            
            if sqlite3_bind_text(stmt, 2, id, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding id: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure updating todo: \(errmsg)")
                return
            }
            
            self.readValues()
        }

    }

}

//테이블 딜리게이트
extension SearchViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTodoList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTodoCell", for: indexPath) as! SearchTableViewCell
        
        let item: Todolist
        item = searchTodoList[indexPath.row]
        
        //값받기
        cell.lblDate.tag = indexPath.row
        cell.btnUncheck.tag = indexPath.row
        cell.btnCheck.tag = indexPath.row
        cell.btnNoStar.tag = indexPath.row
        cell.btnStar.tag = indexPath.row
        
        cell.lblDate.text = item.tDate
        cell.lblList.text = item.tList
        
        //체크상태에 따른 표시
        if item.tState == "1" {
            cell.btnCheck.isHidden = false
            cell.btnUncheck.isHidden = true
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cell.lblList.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
            cell.lblList.attributedText = attributeString
            let somePartStringRange = (cell.lblList.text! as NSString).range(of: cell.lblList.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: somePartStringRange)
            
            
        }else {
            cell.btnCheck.isHidden = true
            cell.btnUncheck.isHidden = false
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cell.lblList.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
            cell.lblList.attributedText = attributeString
            let somePartStringRange = (cell.lblList.text! as NSString).range(of: cell.lblList.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: somePartStringRange)
        }
        
        if item.tStar == "1" {
            cell.btnStar.isHidden = false
            cell.btnNoStar.isHidden = true
        }else{
            cell.btnStar.isHidden = true
            cell.btnNoStar.isHidden = false
        }
      
        return cell
    }
    
    // tableview cell 오늘 날짜만 삭제 가능하도록 설정
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item: Todolist
        item = searchTodoList[indexPath.row]
        
        let searchDate = item.tDate!
        
        if now == searchDate {
            return true
        }else {
            return false
        }
    }

    // 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            var stmt: OpaquePointer?

            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let item: Todolist
            item = searchTodoList[indexPath.row]
            
            let id = String(item.id!)
            
            let queryString = "DELETE FROM todo where id = ?"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing update: \(errmsg)")
                return
            }

            if sqlite3_bind_text(stmt, 1, id, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding id: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure updating todo: \(errmsg)")
                return
            }
            
            self.readValues()
        }
    }
    
    // slide 시 "삭제" 라는 문구 등장
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
  
}
