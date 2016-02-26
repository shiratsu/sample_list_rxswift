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
    var workitems = NSArray()
    
    var footer:UIView!
    var footerIndicator: UIActivityIndicatorView!
    let listMax:Int = 1000
    var prevMaxOffset:CGFloat = 0
    static let startLoadingOffset: CGFloat = 20
    var start:Int = 0
    var limit:Int = 20
    
    var dicParam:NSMutableDictionary = NSMutableDictionary()
    var dicBaseParam:NSMutableDictionary = NSMutableDictionary()
    
    var refreshctl:UIRefreshControl!
    
    var dicHeight:NSMutableDictionary! = NSMutableDictionary()
    
    
    /**
     xibを読み込む
     */
    override func loadView() {
        if let view = UINib(nibName: "ViewController", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshctl = UIRefreshControl()
        listView.addSubview(refreshctl)
        
        var nib  = UINib(nibName: "WorkItemCell", bundle:nil)
        listView.registerNib(nib, forCellReuseIdentifier:"WorkItemCell")
        nib  = UINib(nibName: "NoCountCell", bundle:nil)
        listView.registerNib(nib, forCellReuseIdentifier:"NoCountCell")
        
        //TableViewのフッタ
        self.footer = UIView()
        
        // インジケータを作成する.
        self.footerIndicator = UIActivityIndicatorView()
        self.footerIndicator.color = UIColor.blackColor()
        self.footerIndicator.frame.origin.x = self.view.frame.size.width / 2
        self.footer.addSubview(footerIndicator)
        
        //初回起動時は初期化
        sampleApi.intNowCount.value = 0
        sampleApi.strNowCount.value = "0"
        
        
        setSubscribe()
        
        setBaseParameter()
        setParameter()
        AppDelegate.sharedAppDelegate().showCloseCommonProgress()
        sampleApi.getWorkListData(dicParam, bool_loadnext: false)
            .catchError{ [weak self] error -> Observable<NSArray> in
                print(error)
                return Observable.just(NSArray())
            }
            .subscribeNext { [weak self] array in
                AppDelegate.sharedAppDelegate().showCloseCommonProgress(true)
                self!.stateWithWorkitems.value = WorkListResponse.InitWorkData(array as! [NSDictionary])
            }
            .addDisposableTo(disposeBag)
        
        
    }
    
    /**
     基礎となるパラメータをセット
     */
    func setBaseParameter(){
        self.dicBaseParam = NSMutableDictionary()
        
    }
    
    
    
    //検索用のパラメータをセット
    func setParameter(){
        dicParam = NSMutableDictionary()
        
        let immutable_base_param = NSDictionary(dictionary: self.dicBaseParam)
        //パラメータ辞書を作成
        dicParam = immutable_base_param.mutableCopy() as! NSMutableDictionary
        
        //startとリミットをセット
        dicParam.setObject(String(start+1), forKey: "start")
        dicParam.setObject(String(limit), forKey: "results")
    }
    
    func isNearTheBottomEdge(contentOffset: CGPoint,workview:UITableView) -> Bool {
        
        let maxOffset = workview.contentSize.height - workview.frame.size.height
        
        //前と変わってなければ、まだロードは終わってない
        if maxOffset - prevMaxOffset < 100{
            return false
        }
        
        if sampleApi.intTotalCount.value > 0
            && self.workitems.count > 0
            &&
            (self.workitems.count%20 == 0 && self.workitems.count < Int(sampleApi.intTotalCount.value)
                && self.workitems.count < self.listMax)
            && (maxOffset - contentOffset.y) <= ViewController.startLoadingOffset
        {
            prevMaxOffset = maxOffset
            return true
        }else{
            return false
        }
        
        
    }
    
    func getListData(){
        AppDelegate.sharedAppDelegate().showCloseCommonProgress()
        sampleApi.getWorkListData(NSDictionary(),bool_loadnext: false)
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
                    self!.listView.reloadData()
                    break
                case WorkListResponse.InitWorkData(let results):
                    self!.workitems = results
                    self!.listView.reloadData()
                    break
                case WorkListResponse.RefreshWorkData(let results):
                    self!.workitems = results
                    self!.listView.reloadData()
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
                        self!.listView.beginUpdates()
                        self!.listView.insertRowsAtIndexPaths(reload_ary as! [NSIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                        self!.listView.endUpdates()
                    }
                    break
                }
                self!.setFooterView(self!.listView)
            }
            .addDisposableTo(disposeBag)
        
        //フッタまで行った時
        self.listView.rx_contentOffset
            .distinctUntilChanged()
            .flatMap { [weak self] (offset) -> Observable<NSArray> in
                if self!.isNearTheBottomEdge(offset,workview:self!.listView) {
                    self!.start = self!.workitems.count
                    
                    self!.setParameter()
                    self!.footerIndicator.startAnimating()
                    return self!.sampleApi.getWorkListData(self!.dicParam, bool_loadnext: true)
                } else {
                    return Observable.empty()
                }
            }
            .subscribeNext { [weak self] results in
                self!.footerIndicator.stopAnimating()
                self!.stateWithWorkitems.value = WorkListResponse.AddWorkData(results as! [NSDictionary])
                //                self.now_loading = false
                //                print("scroll...")
            }
            .addDisposableTo(disposeBag)
        
        //リフレッシュ系
        self.refreshctl!.rx_controlEvent(.ValueChanged)
            .flatMap { [weak self] () -> Observable<NSArray> in
                self?.start = 0
                self?.prevMaxOffset = 0
                self?.setParameter()
                return (self?.sampleApi.getWorkListData(self!.dicParam, bool_loadnext: false)
                    .catchError{
                        error -> Observable<NSArray> in
                        print(error)
                        return Observable.just(NSArray())
                })!
            }
            .subscribeNext { [weak self] result in
                self!.refreshctl!.endRefreshing()
                self!.stateWithWorkitems.value = WorkListResponse.RefreshWorkData(result as! [NSDictionary])
            }
            .addDisposableTo(disposeBag)
    }
    
    /**
     レイアウトが全部確定したら呼び出される
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //存在する場合
        if self.footerIndicator != nil{
            self.footerIndicator.frame.origin.x = (self.view.frame.size.width / 2) - (self.footerIndicator.frame.width/2)
        }
        
        
    }
    
    
    func stopIndicator(){
        if self.footerIndicator != nil{
            if self.footerIndicator.isAnimating(){
                self.footerIndicator.stopAnimating()
            }
        }
    }
    
    /**
     フッタのインジケータの表示処理
     
     :param: workview <#workview description#>
     */
    func setFooterView(workview:UITableView){
        if self.workitems.count%20 == 0 && self.workitems.count < sampleApi.intTotalCount.value && self.workitems.count < self.listMax{
            workview.tableFooterView = footer
        }
    }
    
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 70
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        return footer_view
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sampleApi.intTotalCount.value == 0{
            return 1
        }
        
        return self.workitems.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if sampleApi.intTotalCount.value == 0{
            return self.view.frame.size.height
        } else {
            var cell_height:CGFloat = 0
            if let workdic: AnyObject = self.workitems.safeObjectAtIndex(indexPath.row){
                let text_height = WorkItemCell.heightForCatchCopy(tableView, workdic: workdic as? NSDictionary)
                cell_height = 192+text_height
            } else {
                cell_height = 219
            }
            dicHeight.setValue(cell_height, forKey: String(indexPath.row))
            
            return cell_height
        }
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
        if sampleApi.intTotalCount.value > 0{
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
        
        guard let workdic: AnyObject = self.workitems.safeObjectAtIndex(atIndexPath.row) else {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
}

extension NSArray{
    func safeObjectAtIndex(index: Int) ->AnyObject?{
        if index >= self.count{
            return nil
        }
        return self.objectAtIndex(index)
    }
}

