//
//  ShareSellListViewModel.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ShareSellingListViewModel {
    private let provider: ServiceProvider
    private let coordinator: ShareSellingListCoordinator
    private let repo: ShareSellingRepository
    private let bag = DisposeBag()
    
    struct Outputs {
        var shares: Observable<[ShareCellViewModel]> {
            return _shares.asObservable()
        }
        fileprivate let _shares = BehaviorRelay<[ShareCellViewModel]>(value: [])
        
        var error: Observable<Error> {
            return _error.asObservable()
        }
        fileprivate let _error = PublishRelay<Error>()
        
        var currentPrice: Observable<String> {
            return _currentPrice.asObservable()
        }
        fileprivate let _currentPrice = BehaviorRelay<String>(value: "")
        
        var name: Observable<String> {
            return _name.asObservable()
        }
        fileprivate let _name = BehaviorRelay<String>(value: "")
        
        var symbol: Observable<String> {
            return _symbol.asObservable()
        }
        fileprivate let _symbol = BehaviorRelay<String>(value: "")
        
        var loading: Observable<Bool> {
            return _loading.asObservable()
        }
        fileprivate let _loading = PublishRelay<Bool>()
    }
    let outputs = Outputs()
    
    init(provider: ServiceProvider,
         coordinator: ShareSellingListCoordinator,
         repo: ShareSellingRepository) {
        self.provider = provider
        self.coordinator = coordinator
        self.repo = repo
    }
    
    func load() {
        outputs._loading.accept(true)
        
        let certs = repo.getCertificates()
        // Transform to VMs and push
        certs.map { (certs) -> [ShareCellViewModel] in
            return certs.map({ ShareCellViewModel(data: $0) })
        }.subscribe(onNext: { [weak self] viewModels in
            self?.outputs._shares.accept(viewModels)
        }, onError: { [weak self] (error) in
            self?.outputs._error.accept(error)
        }).disposed(by: bag)
        
        let price = loadPrice()
        Observable.zip(certs, price).subscribe(onCompleted: { [weak self] in
            self?.outputs._loading.accept(false)
        }).disposed(by: bag)
    }
    
    private func loadPrice() -> Observable<SharesPrice> {
        let observable = repo.getSharesPrice()
        observable.subscribe(onNext: { [weak self] (price) in
            guard let self = self else { return }
            self.outputs._currentPrice.accept(price.value.formattedPrice(currency: price.currency))
            self.outputs._name.accept(price.name)
            self.outputs._symbol.accept(price.symbol)
        }, onError: { [weak self] (error) in
            self?.outputs._error.accept(error)
        }).disposed(by: bag)
        return observable
    }
}
