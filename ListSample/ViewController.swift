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


class ViewController: UIViewController,WorkListDataSourceDelegate {

    @IBOutlet weak var listView: UITableView!
    let disposeBag = DisposeBag()
    
    var footer:UIView!
    var footerIndicator: UIActivityIndicatorView!
    let listMax:Int = 1000
    static let startLoadingOffset: CGFloat = 20
    var start:Int = 0
    var limit:Int = 20
    
    var dicParam:NSMutableDictionary = NSMutableDictionary()
    var dicBaseParam:NSMutableDictionary = NSMutableDictionary()
    
    var refreshctl:UIRefreshControl!
    
    var dicHeight:NSMutableDictionary! = NSMutableDictionary()
    
    let viewModel:ListViewModel = ListViewModel()
    
    let dataSource = WorkListDataSource()
    
    var isLoading = false
    var isRefresh = false
    
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
        listView.dataSource = nil
        
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
        
        
        
        setSubscribe()
        
        setBaseParameter()
        setParameter()
        
        AppDelegate.sharedAppDelegate().showCloseCommonProgress()
        viewModel.reloadData(dicParam)
        
    }
    
    /**
     基礎となるパラメータをセット
     */
    func setBaseParameter(){
        self.dicBaseParam = NSMutableDictionary()
        
    }
    
    func afterReload() {
        stopIndicator()
        setFooterView(listView)
        isLoading = false
        
        if isRefresh == true{
            refreshctl?.endRefreshing()
            isRefresh = false
        }
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
        
        let diffOffset = workview.contentSize.height - (contentOffset.y+workview.frame.height)

        if viewModel.api.intTotalCount.value > 0
            && viewModel.items.value.count > 0
            &&
            (viewModel.items.value.count%20 == 0 && viewModel.items.value.count < Int(viewModel.api.intTotalCount.value)
                && viewModel.items.value.count < self.listMax)
            && diffOffset <= ViewController.startLoadingOffset
            && !isLoading
        {
            isLoading = true
            return true
        }else{
            return false
        }
        
        
    }
    

    func setSubscribe(){
        
        dataSource.delegate = self
        
        viewModel.items.asObservable().bindTo(listView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        //フッタまで行った時
        self.listView.rx_contentOffset
            .filter{ [weak self] in self!.isNearTheBottomEdge($0,workview:self!.listView) }
            .subscribeNext { [weak self] offset in
                
                self!.start = self!.viewModel.items.value.count
                
                self?.setParameter()
                self?.footerIndicator.startAnimating()
                self?.viewModel.addWorkData(self!.dicParam)
                
            }
            .addDisposableTo(disposeBag)
        
        //リフレッシュ系
        self.refreshctl!.rx_controlEvent(.ValueChanged)
            .subscribeNext { [weak self] () in
                self?.start = 0
                self?.setParameter()
                self?.isRefresh = true
                self?.viewModel.reloadData((self?.dicParam)!)
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
        if viewModel.items.value.count%20 == 0 && viewModel.items.value.count < viewModel.api.intTotalCount.value && viewModel.items.value.count < self.listMax{
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if viewModel.api.intTotalCount.value == 0{
            return self.view.frame.size.height
        } else {
            var cell_height:CGFloat = 0
            if let workdic: AnyObject = viewModel.items.value.safeObjectAtIndex(indexPath.row){
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

