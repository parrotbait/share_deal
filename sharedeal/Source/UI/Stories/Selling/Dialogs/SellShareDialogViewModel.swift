//
//  SellShareDialogViewModel.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SellShareDialogViewModel {
    
    struct Inputs {
        let numberOfShares = BehaviorSubject<String>(value: "")
    }
    
    struct Outputs {
        var numberOfShares: Observable<String> {
            return _numberOfShares.compactMap({ $0 }).map({ "\($0)" }).asObservable()
        }
        fileprivate let _numberOfShares = BehaviorSubject<Int?>(value: nil)
        
        var totalPrice: Observable<String> { return _totalPrice.asObservable() }
        fileprivate let _totalPrice = BehaviorRelay<String>(value: "")
        
        var name: Observable<String> { return _name.asObservable() }
        fileprivate let _name = BehaviorRelay<String>(value: "")
        
        var totalShares: Observable<String> { return _totalShares.asObservable() }
        fileprivate let _totalShares = BehaviorRelay<String>(value: "")
        
        var currentPrice: Observable<String> { return _currentPrice.asObservable() }
        fileprivate let _currentPrice = BehaviorRelay<String>(value: "")
        
        var saveButton: Observable<Bool> { return _saveButton.asObservable() }
        fileprivate let _saveButton = BehaviorRelay<Bool>(value: false)
        
        var error: Observable<String> { return _error.asObservable()}
        fileprivate let _error = BehaviorRelay<String>(value: "")
    }
    
    let inputs = Inputs()
    let outputs = Outputs()
    private let record: ShareCertificateRecord
    
    private let bag = DisposeBag()
    private let repo: ShareSellingRepository
    
    init(repo: ShareSellingRepository,
         record: ShareCertificateRecord) {
        self.record = record
        self.repo = repo
        
        repo.price
            .map({
                let priceText = $0.value.formattedPrice(currency: $0.currency)
                return R.string.localizable.common_current_price(priceText)
            })
            .bind(to: outputs._currentPrice).disposed(by: bag)
        
        record.numberOfSharesSelling.map({
            $0 > 0 ? $0 : nil
        }).bind(to: outputs._numberOfShares).disposed(by: bag)
        outputs._name.accept(R.string.localizable.selling_cell_title("\(record.cert.id)"))
        record.numberOfShares.map({R.string.localizable.common_total_shares($0) }).bind(to: outputs._totalShares).disposed(by: bag)
        
        inputs.numberOfShares
            .distinctUntilChanged()
            .skip(1) // Skip the first event caused by the textfield sending back the input value
            .subscribe(onNext: { [weak self] (text) in
            guard let self = self else { return }
            if let total = Int(text), total > 0 {
                let canSellTotal = self.canSell(record: self.record, numberOfShares: total)
                self.outputs._saveButton.accept(canSellTotal)
                if !canSellTotal {
                    if let numShares = try? self.record.numberOfShares.value() { self.outputs._error.accept(R.string.localizable.sell_share_dialog_insufficient_shares(numShares))
                    }
                }
            } else {
                self.outputs._saveButton.accept(false)
                if !text.isEmpty {
                    self.outputs._error.accept(R.string.localizable.sell_share_dialog_error_numerical_text())
                }
            }
        }).disposed(by: bag)
        
        Observable.combineLatest(repo.price, inputs.numberOfShares)
            .subscribe(onNext: { [weak self] (result) in
                guard let self = self else { return }
                if let total = Int(result.1) {
                    let totalPrice = Double(total) * result.0.value
                    self.outputs._totalPrice.accept(totalPrice.formattedPrice(currency: result.0.currency))
                }
        }).disposed(by: bag)
    }
    
    func canSell(record: ShareCertificateRecord, numberOfShares: Int) -> Bool {
        guard let total = try? record.numberOfShares.value() else { return false }
        return numberOfShares <= total && numberOfShares > 0
    }
    
    func save() {
        guard let total = try? Int(inputs.numberOfShares.value()) else { return }
        record.numberOfSharesSelling.onNext(total)
    }
}
