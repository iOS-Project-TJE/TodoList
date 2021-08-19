//
//  TodoList.swift
//  TodoList
//
//  Created by RayAri on 2021/08/19.
//

import Foundation

class Todolist{
    var id :Int
    var tDate : String?
    var tList : String?
    var tState : String?
    var tStar : String?
    
    init(id: Int, tDate:String?, tList:String?, tState:String?, tStar:String?) {
        self.id = id
        self.tDate = tDate
        self.tList = tList
        self.tState = tState
        self.tStar = tStar
    }
    
    init(id: Int, tDate:String?, tList:String?) {
        self.id = id
        self.tDate = tDate
        self.tList = tList
    }
    
}
