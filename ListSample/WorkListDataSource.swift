//
//  WorkListDataSource.swift
//  ListSample
//
//  Created by 平塚 俊輔 on 2016/03/03.
//  Copyright © 2016年 平塚 俊輔. All rights reserved.
//

import Foundation

#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

public protocol WorkListDataSourceDelegate : class {
    
    func afterReload()
    
}


class WorkListDataSource: NSObject, RxTableViewDataSourceType, UITableViewDataSource {
    
    
    var items: NSArray?
    var dicHeight:NSMutableDictionary! = NSMutableDictionary()
    weak var delegate:WorkListDataSourceDelegate?
    
    func tableView(tableView: UITableView, observedEvent: RxSwift.Event<NSArray>) {
        switch observedEvent {
        case .Next(let value):
            self.items = value
            self.delegate?.afterReload()
            tableView.reloadData()
            
        case .Error(let error):
            print("Error: \(error)")
            
        case .Completed:
            print("Completed")
        }
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items!.count == 0{
            return 1
        }
        
        return items!.count
    }
        
    /*
    Cellに値を設定する.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Cellの.を取得する.
        if items!.count > 0{
            let cell = workItemCell(tableView, cellForRowAtIndexPath: indexPath, str_xib: "WorkItemCell")
            return cell
        } else {
            let nocell: NoCountCell = tableView.dequeueReusableCellWithIdentifier("NoCountCell", forIndexPath: indexPath) as! NoCountCell
            nocell.conditionButton.addTarget(self, action: "goBack:", forControlEvents: .TouchUpInside)
            return nocell
        }
    }
    
    func workItemCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath,str_xib:String) ->WorkItemCell{
        let wcell: WorkItemCell = tableView.dequeueReusableCellWithIdentifier(str_xib) as! WorkItemCell
        wcell.separatorInset = UIEdgeInsetsZero
        wcell.selectionStyle = UITableViewCellSelectionStyle.None
        updateCell(wcell, atIndexPath: indexPath)
        
        return wcell
    }
    
    func updateCell(cell:UITableViewCell,atIndexPath:NSIndexPath){
        setItemFromServer(cell, atIndexPath: atIndexPath)
    }
    
    func setItemFromServer(cell:UITableViewCell,atIndexPath:NSIndexPath) -> (WorkItemCell?,String?){
        let wcell = cell as! WorkItemCell
        
        guard let workdic: AnyObject = items!.safeObjectAtIndex(atIndexPath.row) else {
            return (nil,nil)
        }
        
        showWorkItem(wcell, workdic: workdic as! NSDictionary)
        
        guard let workid = workdic.objectForKey("WorkId") as? String else {
            return (nil,nil)
        }
        
        
        
        return (wcell,workid)
    }
    
    func showWorkItem(wcell:WorkItemCell,workdic:NSDictionary){
        
        wcell.workdic = workdic
        
    }
    
    
    
    
    
}