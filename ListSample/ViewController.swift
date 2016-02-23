//
//  ViewController.swift
//  ListSample
//
//  Created by 平塚 俊輔 on 2016/02/19.
//  Copyright © 2016年 平塚 俊輔. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif


class ViewController: UIViewController {

    @IBOutlet weak var listView: UITableView!
    let sampleApi:SampleAPI = SampleAPI()
    let disposeBag = DisposeBag()
    var stateWithWorkitems = Variable(WorkListResponse.NoWorkData([]))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    
    func getListData(){
        AppDelegate.sharedAppDelegate().showCloseCommonProgress()
        sampleApi.getWorkListData(NSDictionary())
            .catchError{ [weak self] error -> Observable<NSArray> in
                print("取得できませんでした")
                return Observable.just(NSArray())
            }
            .subscribeNext { [weak self] array in
                AppDelegate.sharedAppDelegate().showCloseCommonProgress()
                self!.stateWithWorkitems.value = WorkListResponse.InitWorkData(array as! [NSDictionary])
            }
            .addDisposableTo(disposeBag)
        
    }
    
    
    func setSubscribe(){
        self.stateWithWorkitems.asObservable().observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] state in
                self!.stopIndicator()
                //ステータスによってワークリストの処理を分ける
                switch state {
                case WorkListResponse.NoWorkData(let results):
                    self!.workitems = results
                    self!.workview.reloadData()
                    break
                case WorkListResponse.InitWorkData(let results):
                    self!.workitems = results
                    self!.workview.reloadData()
                    break
                case WorkListResponse.RefreshWorkData(let results):
                    self!.workitems = results
                    self!.workview.reloadData()
                    break
                case WorkListResponse.AddWorkData(let results):
                    let current_pos = self!.workitems.count
                    self!.workitems = self!.workitems.arrayByAddingObjectsFromArray(results as [AnyObject])
                    
                    let end_pos = self!.workitems.count
                    let indexPaths = NSMutableArray()
                    
                    for i in current_pos..<end_pos {
                        indexPaths.addObject(NSIndexPath(forRow: i, inSection: 0))
                    }
                    
                    let reload_ary = indexPaths.copy() as! NSArray
                    if reload_ary.count > 0{
                        self!.workview.beginUpdates()
                        self!.workview.insertRowsAtIndexPaths(reload_ary as! [NSIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                        self!.workview.endUpdates()
                    }
                    break
                }
                self!.setFooterView(self!.workview)
            }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

