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

class ListViewModel:NSObject {
    
    let api:SampleAPI = SampleAPI()
    
    var items: Variable<NSArray> = Variable(NSArray())
    let disposeBag = DisposeBag()
    
    func reloadData(param:NSDictionary){
        api.getWorkListData(param,bool_loadnext: false)
            .catchError{ error -> Observable<NSArray> in
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
            .catchError{ error -> Observable<NSArray> in
                print("取得できませんでした")
                return Observable.just(NSArray())
            }
            .subscribeNext { [weak self] array in
                self?.items.value = (self?.items.value.arrayByAddingObjectsFromArray(array as [AnyObject]))!
            }
            .addDisposableTo(disposeBag)
    }
    
    
}