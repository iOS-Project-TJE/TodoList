//
//  TodoViewController.swift
//  TodoList
//
//  Created by HyoEun Kwon on 2021/08/22.
//

import UIKit
import SQLite3

class TodoViewController: UIViewController, UITextFieldDelegate{

    // todo 입력 텍스트 필드
    @IBOutlet weak var tfAddTodo: UITextField!
    // 오늘의 날짜 부분
    @IBOutlet weak var lblTodayDate: UILabel!
    //table View 연결
    @IBOutlet weak var tvTodoList: UITableView!
    
    //sqlite 사용
    var db: OpaquePointer?
    //sqlite Bean List
    var addTodoList: [Todolist] = []
    //상태
    var state = "0"
    //중요도(별)
    var star = "0"
    //textfield에 적은 내용
    var todo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        //텍스트필드 힌트 색상 변화
//        tfAddTodo.attributedPlaceholder = NSAttributedString(string: "오늘의 할 일을 입력해주세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "CustomedNavy") as Any])
        
        //텍스트 필드 글자 수 제한
        tfAddTodo.delegate = self
        
        //*********
        
        //sqlite 생성하기
        sqliteSetting()
       
        //tableView
        tvTodoList.delegate = self
        tvTodoList.dataSource = self
        
    }//viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        //tableViewCell 줄 없애기
        tvTodoList.separatorStyle = .none
        //데이터 불러오기
        readValues()
        tvTodoList.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
   
    //todo 추가 버튼
    
    @IBAction func btnAdd(_ sender: UIButton) {
        
        //오늘의 일정
        todo = tfAddTodo.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 추가되고 textfield 없애기
        tfAddTodo.text?.removeAll()
        
        self.view.endEditing(true)
        
        // sqlite todo 정보 넣기
        insertTodoValues(todo)
        
        // 다시 불러오기
        readValues()
        
    }//btnAdd
    
    // 체크 아닐때 -> 체크로
    @IBAction func btnTodoUnCheck(_ sender: UIButton) {
        var stmt: OpaquePointer?

        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
        let tState = "1"
        let id = "\(String(describing: addTodoList[sender.tag].id!))"
        
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
        
        readValues()
        
    }//btnTodoUnCheck
    
    
    //체크 상태에서 빈 상태로
    @IBAction func btnTodoCheck(_ sender: UIButton) {
        var stmt: OpaquePointer?

        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
        let tState = "0"
        let id = "\(String(describing: addTodoList[sender.tag].id!))"
        
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
        
    }//btnTodoCheck
    
    
    // 중요도 체크 안했을때 -> 별 채우기
    @IBAction func btnStar(_ sender: UIButton) {
        var stmt: OpaquePointer?

        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
        let tStar = "1"
        let id = "\(String(describing: addTodoList[sender.tag].id!))"
        
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
    
    }//btnStar
    
    //중요도 체크 O -> 중요도 체크 해제
    @IBAction func btnStarFill(_ sender: UIButton) {
        var stmt: OpaquePointer?

        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
        let tStar = "0"
        let id = "\(String(describing: addTodoList[sender.tag].id!))"
        
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
        
    }//btnStarFill
    
    
    //----------------------------data
    
    //sqlite 생성
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
    
    // 데이터 불러오기
    func readValues() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: Date())
        
        //현재 날짜
        let date = currentDate
        
        // 1. 기존 화면 떠있는 애들을 지워주기  + 새롭게 구성하기
        addTodoList.removeAll()
        
        // Query
        let queryString = "SELECT id, tDate, tList, tState, tStar FROM todo where tDate = '\(date)'ORDER BY tStar DESC"
        
        // Statement
        var stmt: OpaquePointer?
        
        //
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select : \(errmsg)")
            return
        }
        
        // 한줄씩 가져오기
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            let id = sqlite3_column_int(stmt, 0)
            let tDate = String(cString: sqlite3_column_text(stmt, 1))
            let tList = String(cString: sqlite3_column_text(stmt, 2))
            let tState = String(cString: sqlite3_column_text(stmt, 3))
            let tStar = String(cString: sqlite3_column_text(stmt, 4))

            addTodoList.append(Todolist(id: Int(id), tDate: tDate, tList: tList, tState: tState, tStar: tStar))
        }
        self.tvTodoList.reloadData()
        
        lblTodayDate.text = currentDate
        
    }//select
    
    
    // SQLite : INSERT
    func insertTodoValues(_ todo: String){

        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: Date())
        //현재 날짜
        let date = currentDate
        
        let queryString = "INSERT INTO todo(tDate, tList, tState, tStar) VALUES (?,?,?,?)"

        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert : \(errmsg)")
            return
        }

        if sqlite3_bind_text(stmt, 1, date, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding content : \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, todo, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding date : \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 3, state, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding date : \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 4, star, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding date : \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting search : \(errmsg)")
            return
        }

    }//insert

    
    //글자수 제한 소스
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentString: NSString = textField.text! as NSString
            
            let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= 15
        }


}//-----


extension TodoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! TodoTableViewCell

        let content = addTodoList[indexPath.row]
        
        cell.lblTodo.text = content.tList
        
        cell.btnTodoUnCheck.tintColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        cell.btnTodoUnCheck.tintColor = UIColor(displayP3Red: 65/255, green: 99/225, blue: 135/255, alpha: 1)
        
        //체크 눌렀을때
        if content.tState == "1" {
            cell.btnTodoUnCheck.isHidden = true
            cell.btnTodoCheck.isHidden = false
            
            //취소선
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cell.lblTodo.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
            cell.lblTodo.attributedText = attributeString
            let somePartStringRange = (cell.lblTodo.text! as NSString).range(of: cell.lblTodo.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: somePartStringRange)
            
        }else {
            cell.btnTodoUnCheck.isHidden = false
            cell.btnTodoCheck.isHidden = true
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cell.lblTodo.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
            cell.lblTodo.attributedText = attributeString
            let somePartStringRange = (cell.lblTodo.text! as NSString).range(of: cell.lblTodo.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: somePartStringRange)
        }
        
        cell.btnTodoUnCheck.tag = indexPath.row
        cell.btnTodoCheck.tag = indexPath.row
        
        if content.tStar == "1" {
            cell.btnStar.isHidden = true
            cell.btnStarFill.isHidden = false
        }else {
            cell.btnStar.isHidden = false
            cell.btnStarFill.isHidden = true
        }
        
        cell.btnStar.tag = indexPath.row
        cell.btnStarFill.tag = indexPath.row
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addTodoList.count
    }
    
    
    // SQLite : DELETE - WHERE
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                var stmt: OpaquePointer?
                _ = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

                let id = "\(String(describing: addTodoList[indexPath.row].id!))"
                let queryString = "DELETE FROM todo WHERE id = '\(id)'"
                
                if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing delete : \(errmsg)")
                    return
                }

                if sqlite3_step(stmt) != SQLITE_DONE{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure deleting search : \(errmsg)")
                    return
                }
                
                print("Search info delete successfully")
                self.addTodoList.remove(at: indexPath.row)
                self.tvTodoList.deleteRows(at: [indexPath], with: .fade)
                
            }
        } // SQLite : DELETE - WHERE
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionsDelete = UIContextualAction(style: .normal, title: "Delete", handler: { action, view, completionHaldler in
            completionHaldler(true)
        })
        actionsDelete.backgroundColor = #colorLiteral(red: 0.3192519248, green: 0.4669253826, blue: 0.6003069282, alpha: 1)
        actionsDelete.title = "삭제"
        
        return UISwipeActionsConfiguration(actions: [actionsDelete])
    }


}//extension
