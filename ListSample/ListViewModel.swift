//
//  ListViewModel.swift
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

class ListViewModel:NSObject, UITableViewDataSource {
    
    let api:SampleAPI = SampleAPI()
    
    var items: Variable<NSArray> = Variable(NSArray())
    let disposeBag = DisposeBag()
    
    func reloadData(param:NSDictionary){
        api.getWorkListData(param,bool_loadnext: false)
            .catchError{ [weak self] error -> Observable<NSArray> in
                print("取得できませんでした")
                return Observable.just(NSArray())
            }
            .subscribeNext { [weak self] array in
                AppDelegate.sharedAppDelegate().showCloseCommonProgress(true)
                self?.items.value = array
            }
            .addDisposableTo(disposeBag)
    }
    
    func addWorkData(param:NSDictionary){
        api.getWorkListData(param,bool_loadnext: true)
            .catchError{ [weak self] error -> Observable<NSArray> in
                print("取得できませんでした")
                return Observable.just(NSArray())
            }
            .subscribeNext { [weak self] array in
                self?.items.value = (self?.items.value.arrayByAddingObjectsFromArray(array as [AnyObject]))!
            }
            .addDisposableTo(disposeBag)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if api.intTotalCount.value == 0{
            return 1
        }
        return items.value.count
    }
    
    /*
    Cellに値を設定する.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Cellの.を取得する.
        if api.intTotalCount.value > 0{
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
        
        guard let workdic: AnyObject = items.value.safeObjectAtIndex(atIndexPath.row) else {
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
