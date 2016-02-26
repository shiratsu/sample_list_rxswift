//
//  ImageWithView.swift
//  shotworks_for_ph2_by_swift
//
//  Created by 平塚 俊輔 on 2015/07/14.
//  Copyright (c) 2015年 平塚 俊輔. All rights reserved.
//

import UIKit

class ImageWithView: UIView {

    var in_imgview: UIImageView!
    //images
    var checkedImage:UIImage!
    var uncheckedImage:UIImage!
    
    //bool property
    var isChecked:Bool = false{
        didSet{
            if self.checkedImage != nil && self.uncheckedImage != nil && self.in_imgview != nil{
                if isChecked == true{
                    self.in_imgview.image = self.checkedImage
                }else{
                    self.in_imgview.image = self.uncheckedImage
                }
            }
            
        }
    }
    
    override func awakeFromNib() {
        self.isChecked = false
        self.in_imgview = UIImageView(frame: CGRect(x: 16, y: 16, width: 24, height: 23))
        self.addSubview(self.in_imgview)
        self.multipleTouchEnabled = false
        self.exclusiveTouch = true
    }
    
//    class func instance() -> ImageWithView {
//        return UINib(nibName: "ImageWithView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! ImageWithView
//    }

}
