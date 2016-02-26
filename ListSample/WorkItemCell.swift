//
//  WorkItemCell.swift
//  ShotAlertForSwift
//
//  Created by 平塚　俊輔 on 3/16/15.
//  Copyright (c) 2015 平塚　俊輔. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

public protocol WorkItemCellDelegate : class {
    
    func afterHandleFav()
    
}


class WorkItemCell: UITableViewCell{
    
    
    @IBOutlet weak var header_back_view: UIView!
    @IBOutlet weak var base_back_view: UIView!
    @IBOutlet weak var item_view: UIView!
    @IBOutlet weak var minimumday_label: UILabel!
    @IBOutlet weak var startday_label: UILabel!
    @IBOutlet weak var resistration_label: UILabel!
    @IBOutlet weak var catchcopyLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var mainjobLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    
    @IBOutlet weak var workstartdateLabel2: UILabel!
    
    @IBOutlet weak var fav_view: ImageWithView!
    @IBOutlet weak var img_seen_view: UIImageView!
    
    @IBOutlet weak var application_rate: UILabel!
    
    var row_height:CGFloat = 160
    var short_row_height:CGFloat = 146
    
    var fav_switch: UITapGestureRecognizer!
    
    var disposeBagCell:DisposeBag = DisposeBag()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //self.fav_view = ImageWithView.instance()
        
        self.fav_view.checkedImage = UIImage(named: "fav_on")
        self.fav_view.uncheckedImage = UIImage(named: "fav_off")
        
    }
    
    override func prepareForReuse() {
        self.disposeBagCell = DisposeBag()
        self.item_view.backgroundColor = UIColor.whiteColor()
    }
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //labelの長さではなく、cellの長さを指定。それをしないと、cell幅いっぱいの領域を確保しないみたい
        //これをしないと、２行のテキストが３行で高さを計算してしまう
        self.catchcopyLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds)
        
//        self.layoutIfNeeded()
        
        
        
    }
    
    
    private var _workdic: NSDictionary?
    var workdic: NSDictionary? {
        get {
            return _workdic
        }
        set(workdic) {
            
            _workdic = workdic
            if let workdic = workdic {
                
                setData(workdic)
            }
        }
    }
    
    
    
    func setData(shot_workdic:NSDictionary){
        let workplace = shot_workdic["WorkPlace"] as? String
        let companyname = shot_workdic["CompanyName"] as? String
        let jobname = shot_workdic["JobName"] as? String
        let payment = shot_workdic["Payment"] as? String
        let workstartdate = shot_workdic["WorkStartDate"] as? String
        let workdatetime = shot_workdic["WorkDateTime"] as? String
        let minimumday = shot_workdic["MinimumWorkDay"] as? String
        let applyenddate = shot_workdic["ApplyEndDate"] as? String
        let catchcopy = shot_workdic["CatchCopy"] as? String
        let rate_text = shot_workdic["ApplicationRate"] as? String
        let rtypeflg = shot_workdic["RtypeFlg"] as? String
        

        if notnullCheck(catchcopy){
            
            //全角スペースを半角に変換。これをしないと、要らない行間を勝手に確保する
            let no_multi_catchcopy = catchcopy!.stringByReplacingOccurrencesOfString("　", withString: " ")
            
            //行間
            let attributedText = NSMutableAttributedString(string: no_multi_catchcopy)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
            
            self.catchcopyLabel.attributedText = attributedText
            
            
        }
        self.catchcopyLabel.sizeToFit()
        
        if let payment_constant = payment{
            self.paymentLabel.text = payment_constant
        }
        
        if notnullCheck(minimumday){
            self.minimumday_label.text = minimumday!
        }
        if notnullCheck(workstartdate){
            self.startday_label.text = workstartdate!
        }
        if let applyenddate_constant = applyenddate{
            self.limitLabel.text = applyenddate_constant
        }
        
        if let jobname_constant = jobname{
            self.mainjobLabel.text = jobname_constant
        }
        
        
        if let workdatetime_constant = workdatetime{
            self.workstartdateLabel2.text = workdatetime_constant
        }
        
        
        if let companyname_constant = companyname{
            self.companyLabel.text = companyname_constant
        }
        
        if self.application_rate != nil{
            if let rate_text_constant = rate_text{
                self.application_rate.text = "応募倍率"+rate_text_constant+"倍"
            }else{
                self.application_rate.text = ""
            }
        }
        
        //登録型かどうか
        if notnullCheck(rtypeflg){
            let bool_isAnken = isAnken(rtypeflg!)
            
            if bool_isAnken{
                self.resistration_label.hidden = true
            }else{
                self.resistration_label.hidden = false
            }
            
        }
        
        self.resistration_label.layer.borderWidth = 1
        self.resistration_label.layer.borderColor = UIColor(netHex: 0xFF833E).CGColor
        
        self.stationLabel.text = workplace
        self.catchcopyLabel.layoutIfNeeded()
        self.item_view.layoutIfNeeded()
        self.layoutIfNeeded()
        

        //確定したあとじゃないとサイズが正確に決まらない
        setRegistrationLabelX()
        
    }
    

    
    
    /**
     案件型かどうか判定
     
     :param: str_workid rtypeflg
     
     :returns: <#return value description#>
     */
    func isAnken(rtypeflg:String) -> Bool{
        
        if rtypeflg != "1"{
            return true
        }else{
            return false
        }
    }
    
    //
    /**
    登録型アイコンの位置決め
    constraintでやる場合、最低勤務日数、開始日、登録型アイコン全てconstraintセットし直さないと無理くさいので
    手間なので断念
    */
    func setRegistrationLabelX(){
        let normal = decideShortOrNormal(workdic!)
        
        let startday_frame = self.startday_label.frame
        let minimumday_frame = self.minimumday_label.frame
        
        let float_const_left = minimumday_frame.size.width+startday_frame.width+CGFloat(12)
        
        //normalは案件型、normalがfalseは登録型
        if normal{
            
            self.resistration_label.frame.origin.x = float_const_left            
            self.minimumday_label.hidden = false
            self.startday_label.hidden = false
            
        }else{
            
            self.resistration_label.frame.origin.x = 0
            self.minimumday_label.hidden = true
            self.startday_label.hidden = true
            
        }
    }
    
    //短いやつか長いやつを決める。長い奴の際はfalseを返す
    func decideShortOrNormal(workdic:NSDictionary) -> Bool{
        let workstartdate = workdic["WorkStartDate"] as? String
        let minimumday = workdic["MinimumWorkDay"] as? String
        if notnullCheck(workstartdate) || notnullCheck(minimumday){
            return true
        }else{
            return false
        }
        
    }
    
    class func heightForCatchCopy(tableView: UITableView, workdic: NSDictionary?) -> CGFloat {
        struct Sizing {
            static var cell: WorkItemCell?
        }
        if Sizing.cell == nil {
            Sizing.cell = tableView.dequeueReusableCellWithIdentifier("WorkItemCell") as? WorkItemCell
        }
        if let cell = Sizing.cell {
            cell.frame.size.width = CGRectGetWidth(tableView.bounds)
            cell.workdic = workdic
            
            let size = cell.catchcopyLabel.intrinsicContentSize()
            return size.height
        }
        return 0
    }
    
    class func heightForCatchCopyAnother(tableView: UITableView, workdic: NSDictionary?) -> CGFloat {
        struct Sizing {
            static var cell: WorkItemCell?
        }
        if Sizing.cell == nil {
            Sizing.cell = tableView.dequeueReusableCellWithIdentifier("ShortWorkItemCell") as? WorkItemCell
        }
        if let cell = Sizing.cell {
            cell.frame.size.width = CGRectGetWidth(tableView.bounds)
            cell.workdic = workdic
            
            let size = cell.catchcopyLabel.intrinsicContentSize()
            return size.height
        }
        return 0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true{
            self.item_view.changeColorByTap(0xcccccc)
        }
    }
    
}