//
//  PersonManager.swift
//  SaupFMDB
//
//  Created by 卲 鵬 on 15/9/1.
//  Copyright (c) 2015年 pshao. All rights reserved.
//

import UIKit

class PersonManager: NSObject {
 
    let dbPath:String
    let dbBase:FMDatabase

    
    // MARK: >> 单例化
    class func shareInstance()->PersonManager{
        struct psSingle{
            static var onceToken:dispatch_once_t = 0;
            static var instance:PersonManager? = nil
        }
        //保证单例只创建一次
        dispatch_once(&psSingle.onceToken,{
            psSingle.instance = PersonManager()
        })
        return psSingle.instance!
    }
    
    
    // MARK: >> 创建数据库，打开数据库
    override init() {
        
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let path = documentsFolder.stringByAppendingPathComponent("test.sqlite")
        self.dbPath = path
        //创建数据库
        dbBase =  FMDatabase(path: self.dbPath as String)
        
        print("path: ---- \(self.dbPath)")
        
        //打开数据库
        if dbBase.open(){
            
            var createSql:String = "CREATE TABLE IF NOT EXISTS T_Person (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, pid integer,name TEXT,height REAL)"
            
            if dbBase.executeUpdate(createSql, withArgumentsInArray: nil){
                
                print("数据库创建成功！")
            
            }else{
                
                print("数据库创建失败！failed:\(dbBase.lastErrorMessage())")
            
            }
        }else{
                print("Unable to open database")
        
        }
    }
    
    
    // MARK: >> 增
    func addPerson(p:Person) {
        
        dbBase.open();
        
        var arr:[AnyObject] = [p.pid!,p.name!,p.height!];
        
        if !self.dbBase.executeUpdate("insert into T_Person (pid ,name, height) values (?, ?, ?)", withArgumentsInArray: arr) {
                println("添加1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
                println("添加1条数据成功！: \(p.pid)")

        }
        
        dbBase.close();
    }
    
    
    // MARK: >> 删
    func deletePerson(p:Person) {
        
        dbBase.open();
        
        if !self.dbBase.executeUpdate("delete from T_Person where pid = (?)", withArgumentsInArray: [p.pid!]) {
            println("删除1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            println("删除1条数据成功！: \(p.pid)")
            
        }
        dbBase.close();

        
    }
    
    // MARK: >> 改
    func updatePerson(p:Person) {
        dbBase.open();

        var arr:[AnyObject] = [p.name!,p.height!,p.pid!];
  
        
        if !self.dbBase .executeUpdate("update T_Person set name = (?), height = (?) where pid = (?)", withArgumentsInArray:arr) {
            println("修改1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            println("修改1条数据成功！: \(p.pid)")
            
        }
        dbBase.close();

    }
    
    // MARK: >> 查
    func selectPersons() -> Array<Person> {
        dbBase.open();
        var persons=[Person]()
        
            if let rs = dbBase.executeQuery("select pid, name, height from T_Person", withArgumentsInArray: nil) {
                while rs.next() {
                    
                    let pid:NSNumber = NSNumber(int:rs.intForColumn("pid"))
                    let name:String = rs.stringForColumn("name") as String
                    let height:Double = rs.doubleForColumn("height") as Double
                    
                    let p:Person = Person(pid: pid, name: name, height: height)
                    persons.append(p)
                }
            } else {
                
            println("查询失败 failed: \(dbBase.lastErrorMessage())")
                
            }
        dbBase.close();

        return persons
        
    }


    // MARK: >> 保证线程安全
    
    // TODO: 示例-增
    
    //FMDatabaseQueue这么设计的目的是让我们避免发生并发访问数据库的问题，因为对数据库的访问可能是随机的（在任何时候）、不同线程间（不同的网络回调等）的请求。内置一个Serial队列后，FMDatabaseQueue就变成线程安全了，所有的数据库访问都是同步执行，而且这比使用@synchronized或NSLock要高效得多。
    
    func safeaddPerson(p:Person){
        
        // 创建，最好放在一个单例的类中
        let queue:FMDatabaseQueue = FMDatabaseQueue(path: self.dbPath)
        
        queue.inDatabase { (db:FMDatabase!) -> Void in
            
            //You can do something in here...
            db.open();
            
            var arr:[AnyObject] = [p.pid!,p.name!,p.height!];
            
            if !self.dbBase.executeUpdate("insert into T_Person (pid ,name, height) values (?, ?, ?)", withArgumentsInArray: arr) {
                println("添加1条数据失败！: \(db.lastErrorMessage())")
            }else{
                println("添加1条数据成功！: \(p.pid)")
                
            }
            
            
            if let rs = db.executeQuery("select pid, name, height from T_Person", withArgumentsInArray: nil) {
                while rs.next() {
                    let pid:Int32 = rs.intForColumn("pid") as Int32
                    let name:String = rs.stringForColumn("name") as String
                    let height:Double = rs.doubleForColumn("height") as Double
                    print("pid:\(pid),name:\(name)");
                }
            } else {
                println("查询失败 failed: \(db.lastErrorMessage())")
            }
            db.close();

        }

    }

}
