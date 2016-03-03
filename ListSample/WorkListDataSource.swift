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

class WorkListDataSource: NSObject, RxTableViewDataSourceType, UITableViewDataSource {
    
    
    var items: NSArray?
    var dicHeight:NSMutableDictionary! = NSMutableDictionary()
    
    func tableView(tableView: UITableView, observedEvent: RxSwift.Event<NSArray>) {
        switch observedEvent {
        case .Next(let value):
            self.items = value
            
            tableView.reloadData()
            
        case .Error(let error):
            print("Error: \(error)")
            
        case .Completed:
            print("Completed")
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 70
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 70))
        return footer_view
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items!.count == 0{
            return 1
        }
        
        return items!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var cell_height:CGFloat = 0
        if let workdic: AnyObject = items!.safeObjectAtIndex(indexPath.row){
            let text_height = WorkItemCell.heightForCatchCopy(tableView, workdic: workdic as? NSDictionary)
            cell_height = 192+text_height
        } else {
            cell_height = 219
        }
        dicHeight.setValue(cell_height, forKey: String(indexPath.row))
        
        return cell_height
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let cell_height = dicHeight.objectForKey(String(indexPath.row)) as? CGFloat else{
            return 219
        }
        return cell_height
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