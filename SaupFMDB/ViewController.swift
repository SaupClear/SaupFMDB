//
//  ViewController.swift
//  SaupFMDB
//
//  Created by 卲 鵬 on 15/9/1.
//  Copyright (c) 2015年 pshao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       //增：   PersonManager.shareInstance().addPerson(Person(pid: 2, name: "清澈", height: 1.75));
        
       //删：   PersonManager.shareInstance().deletePerson(Person(pid: 1, name: nil, height: nil));
       
       //改：   PersonManager.shareInstance().updatePerson(Person(pid: 2, name: "清幽", height: 1.80));
        
       //保证线程安全: 增+查
       //      PersonManager.shareInstance().safeaddPerson(Person(pid: 2, name: "清泠", height: 1.80));
        
       //查
        var arr:Array<Person> = PersonManager.shareInstance().selectPersons()
        
        for (index,element:Person) in enumerate(arr){
            print("Person:\(element.name!)");
            //print结果：Person:清澈 Person:清幽 Person:清泠
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

