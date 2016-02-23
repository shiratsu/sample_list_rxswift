//
//  SampleAPI.swift
//  ListSample
//
//  Created by 平塚 俊輔 on 2016/02/19.
//  Copyright © 2016年 平塚 俊輔. All rights reserved.
//

import Foundation

#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

enum SampleApiError: ErrorType {
    case NoResponse
    case Bad(NSData?)
}

enum WorkListResponse {
    case NoWorkData([NSDictionary])
    case InitWorkData([NSDictionary])
    case RefreshWorkData([NSDictionary])
    case AddWorkData([NSDictionary])
}

class SampleAPI : NSObject {
    static let sharedAPI = SampleAPI()
    // 求人取得総件数
    var intTotalCount: Variable<Int>
    let strTotalCount:Variable<String>
    let intNowCount:Variable<Int>
    let strNowCount:Variable<String>
    
    override init() {
        intTotalCount = Variable(0 as Int)
        intNowCount = Variable(0 as Int)
        strTotalCount = Variable("0")
        strNowCount = Variable("0")
    }
    
    
    
    /**
     求人リストデータ取得
     - parameter dicParam: 検索パラメータ
     */
    func getWorkListData(dicParam: NSDictionary) -> Observable<NSArray> {
        // URL作成
        let strParam = dicParam.urlEncodedString()
        let strUrl = "https://shotworks.jp/sw/app/worklist?" + strParam
        
        // 求人リストデータを取得
        let url = NSURL(string: strUrl)!
        let request = NSURLRequest(URL: url)
        return NSURLSession.sharedSession().rx_response(request)
            .observeOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
            .map { data, response in
                guard let httpResponse: NSHTTPURLResponse = response else {
                    throw SampleApiError.NoResponse
                }
                
                if httpResponse.statusCode != 200 {
                    throw SampleApiError.Bad(data)
                }
                
                return try self._parseWorkListData(data)
            }
            .observeOn(Dependencies.sharedDependencies.mainScheduler)
    }
    
    /**
     通常用のワークリスト
     
     :param: json <#json description#>
     
     :returns: <#return value description#>
     */
    private func _parseWorkListData(json: NSData) throws -> NSArray {
        guard let dict = try NSJSONSerialization.JSONObjectWithData(json, options:NSJSONReadingOptions.AllowFragments) as? NSDictionary else{
            print("Can't find results")
            return NSArray()
            
        }
        
        let resultset_key:String = "ResultSet"
        
        let responseData:NSDictionary = (dict.objectForKey(resultset_key))! as! NSDictionary
        let totalStr = responseData["totalResultsAvailable"] as? String
        
        if let total_int = Int(totalStr!){
            self.intTotalCount.value = total_int
            self.strTotalCount.value = String(self.intTotalCount.value)
        }
        
        guard let entries = dict.objectForKey("Result") as? NSArray else {
            print("Can't find results")
            return NSArray()
        }
        
        //現在の件数を足す
        self.intNowCount.value += entries.count
        self.strNowCount.value = String(self.intNowCount.value)
        
        return entries
    }
}


extension NSDictionary{
    func urlEncodedString() -> String {
        
        let parts:NSMutableArray = NSMutableArray()
        for key in self.allKeys {
            
            let sKey = key as! String
            let value:String = self.objectForKey(key) as! String
            let eValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            let part:String! = (sKey+"="+eValue) as String!
            parts.addObject(part)
        }
        return parts.componentsJoinedByString("&")
    }
}