//
//  SearchViewController.swift
//  TodoList
//
//  Created by RayAri on 2021/08/19.
//

import UIKit
import SQLite3

class SearchViewController: UIViewController {
    
    @IBOutlet weak var lblFirst: UILabel!
    @IBOutlet weak var lblNoItem: UILabel!
    @IBOutlet weak var tvSearch: UITableView!
    @IBOutlet weak var tfSearch: UITextField!

    var db: OpaquePointer?
    var searchTodoList: [Todolist] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("todoList.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS todo (id INTEGER PRIMARY KEY AUTOINCREMENT, tDate TEXT, tList TEXT, tState TEXT, tStar TEXT)",nil,nil,nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        tfSearch.text=""
        tvSearch.delegate = self
        tvSearch.dataSource = self
        
        tvSearch.isHidden = true
        lblNoItem.isHidden = true
        lblFirst.isHidden = false
        
    }
    
    func readValues(){
        searchTodoList.removeAll()
        
        let queryString = "SELECT id, tDate, tList FROM todo where tList like '%\(tfSearch.text!)%'"
        
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
            
            searchTodoList.append(Todolist(id: Int(id), tDate: tDate, tList: tList))
        }
        reload()
        
    }
    
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
    
    
    @IBAction func btmSerch(_ sender: UIButton) {
        readValues()
        
    }
    
    
    @IBAction func btnDelete(_ sender: UIButton) {
        
        let item: Todolist
        item = searchTodoList[sender.tag]
        
        let id = item.id
        
        let queryString = "DELETE FROM todo where num=\(id)"
        
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
            
            searchTodoList.append(Todolist(id: Int(id), tDate: tDate, tList: tList))
        }
        reload()
    }

    
    @IBAction func btnAllDelete(_ sender: UIButton) {
        
        let queryString = "DELETE FROM todo where tList like '%\(tfSearch.text!)%'"
        
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
            
            searchTodoList.append(Todolist(id: Int(id), tDate: tDate, tList: tList))
        }
        reload()
    }

}


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
       
        cell.lblDate.text = item.tDate
        cell.lblList.text = item.tList
        cell.btnX.tag = indexPath.row
      
        return cell
    }
  
}

