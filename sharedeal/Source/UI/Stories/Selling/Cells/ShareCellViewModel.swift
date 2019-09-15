//
//  ShareCellViewModel.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ShareCellViewModel {
    
    struct Inputs {
        let price = PublishSubject<SharesPrice>()
    }
    
    struct Outputs {
        var click: Observable<ShareCertificateRecord> { return _click.asObservable() }
        fileprivate let _click = PublishRelay<ShareCertificateRecord>()
        
        var onCancel: Observable<ShareCertificateRecord> { return _onCancel.asObservable() }
        fileprivate let _onCancel = PublishRelay<ShareCertificateRecord>()
        
        var sellingSharesText: Observable<String> { return _sellingSharesText.asObservable() }
        fileprivate let _sellingSharesText = BehaviorRelay<String>(value: "")
        
        var currentHoldingsText: Observable<String> { return _currentHoldingsText.asObservable() }
        fileprivate let _currentHoldingsText = BehaviorRelay<String>(value: "")
        
        var isSelling: Observable<Bool> { return _isSelling.asObservable() }
        fileprivate let _isSelling = BehaviorRelay<Bool>(value: false)
    }
    
    let outputs = Outputs()
    let inputs = Inputs()
    
    let data: ShareCertificateRecord
    init(data: ShareCertificateRecord, bag: DisposeBag) {
        self.data = data
        
        // Combine price and number of shares being sold to output text in the dialog
        Observable.combineLatest(inputs.price, data.numberOfSharesSelling)
        .map({ (result) -> String in
            let totalToSell = result.1
            let totalBalance = Double(totalToSell) * result.0.value
            let totalSellValue = totalBalance.formattedPrice(currency: result.0.currency)
            return "\(totalToSell) (\(totalSellValue))"
        }).bind(to: outputs._sellingSharesText).disposed(by: bag)
        
        // Combine price and number of shares owned, being sold to output text in the dialog
        Observable.combineLatest(inputs.price, data.numberOfShares, data.numberOfSharesSelling)
        .map({ (result) in
            let remainingCount = result.1 - result.2
            let remainingBalance = Double(remainingCount) * result.0.value
            return "\(remainingCount) (\(remainingBalance.formattedPrice(currency: result.0.currency)))"
        })
        .bind(to: outputs._currentHoldingsText).disposed(by: bag)
        
        data.numberOfSharesSelling.map({ $0 > 0 }).bind(to: outputs._isSelling).disposed(by: bag)
    }
    
    var name: Observable<String> {
        return Observable.just(R.string.localizable.selling_cell_title("\(data.cert.id)"))
    }
    
    func onClick() {
        outputs._click.accept(data)
    }
    
    func cancelSale() {
        outputs._onCancel.accept(data)
    }
}
