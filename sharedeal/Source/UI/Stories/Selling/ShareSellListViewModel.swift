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

// TODO: this should be coming from a config - ideally remotely
let priceRefreshRateSeconds: Double = 5
let warningLevelPercentageThreshold: Int = 50

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
        
        var sellEnabled: Observable<Bool> {
            return _sellEnabled.asObservable()
        }
        fileprivate let _sellEnabled = BehaviorRelay<Bool>(value: false)
        
        var clearEnabled: Observable<Bool> {
            return _clearEnabled.asObservable()
        }
        fileprivate let _clearEnabled = BehaviorRelay<Bool>(value: false)
        
        var totalSaleValue: Observable<String> {
            return _totalSaleValue.asObservable()
        }
        fileprivate let _totalSaleValue = BehaviorRelay<String>(value: "")
        var totalSharesToSell: Observable<String> {
            return _totalSharesToSell.map({ "\($0)" }).asObservable()
        }
        fileprivate let _totalSharesToSell = BehaviorSubject<Int>(value: 0)
        
        var warningText: Observable<String?> {
            return _warningText.asObservable()
        }
        fileprivate let _warningText = BehaviorRelay<String?>(value: nil)
    }
    
    let outputs = Outputs()
    
    init(provider: ServiceProvider,
         coordinator: ShareSellingListCoordinator,
         repo: ShareSellingRepository) {
        self.provider = provider
        self.coordinator = coordinator
        self.repo = repo
        
        repo.price
            .subscribe(onNext: { [weak self] (price) in
            guard let self = self else { return }
            let priceText = price.value.formattedPrice(currency: price.currency)
            self.outputs._currentPrice.accept(R.string.localizable.common_current_price(priceText))
            self.outputs._name.accept(price.name)
            self.outputs._symbol.accept(price.symbol)
                
            DispatchQueue.main.asyncAfter(deadline: .now() + priceRefreshRateSeconds, execute: { [weak self] in
                self?.repo.getSharesPrice()
            })
        }, onError: { [weak self] (error) in
                self?.outputs._error.accept(error)
        }).disposed(by: bag)
        
        Observable.combineLatest(repo.price, outputs._totalSharesToSell)
            .map { (result) -> String in
                let totalValue = Double(result.1) * result.0.value
                return totalValue.formattedPrice(currency: result.0.currency)
        }.bind(to: outputs._totalSaleValue).disposed(by: bag)
    }
    
    func load() {
        outputs._loading.accept(true)
        
        let certs = repo.getCertificates()
        // Transform to VMs and push
        certs.map { [weak self] (certs) -> [ShareCellViewModel] in
            guard let self = self else { return [] }
            return certs.map({
                let shareRecord = ShareCertificateRecord(cert: $0)
                let viewModel = ShareCellViewModel(data: shareRecord, bag: self.bag)
                viewModel.outputs.click.subscribe(onNext: { (cert) in
                    self.onCertSelected(cert)
                }).disposed(by: self.bag)
                
                viewModel.outputs.onCancel.subscribe(onNext: { [weak self] (record) in
                    record.numberOfSharesSelling.onNext(0)
                    self?.refreshTotals()
                }).disposed(by: self.bag)
                
                shareRecord.numberOfSharesSelling.subscribe(onNext: { _ in
                    self.refreshTotals()
                }).disposed(by: self.bag)
                
                self.repo.price
                    .compactMap({ $0 })
                    .bind(to: viewModel.inputs.price).disposed(by: self.bag)
                
                return viewModel
            })
        }.subscribe(onNext: { [weak self] viewModels in
            self?.outputs._shares.accept(viewModels)
        }, onError: { [weak self] (error) in
            self?.outputs._error.accept(error)
        }).disposed(by: bag)

        Observable.zip(certs, repo.price).subscribe(onNext: { [weak self] _ in
            self?.outputs._loading.accept(false)
        }).disposed(by: bag)
        
        repo.getSharesPrice()
        
        // enable the sell buttons
        outputs._totalSharesToSell.map({ $0 > 0 }).bind(to: outputs._clearEnabled).disposed(by: bag)
        outputs._totalSharesToSell.map({ $0 > 0 }).bind(to: outputs._sellEnabled).disposed(by: bag)
    }
    
    // MARK: Actions
    func sell() {
        let viewModels = outputs._shares.value
        
        let shareList = viewModels.map { (viewModel) -> ShareCertificateSale? in
            guard let total = try? viewModel.data.numberOfSharesSelling.value() else {
                return nil
            }
            guard total > 0 else { return nil }
            return ShareCertificateSale(id: viewModel.data.cert.id, numberOfShares: total)
        }.compactMap({ $0 })
        
        provider.share.sellShares(items: shareList).subscribe(onNext: { _ in
            var modelsToRemove = [Int]()
            viewModels.forEach({ (viewModel) in
                viewModel.data.numberOfSharesSelling.onNext(0)
                if let match = shareList.first(where: { viewModel.data.cert.id == $0.id }) {
                    // Modify the observer
                    if let existingValue = try? viewModel.data.numberOfShares.value() {
                        let newTotal = existingValue - match.numberOfShares
                        viewModel.data.numberOfShares.onNext(newTotal)
                        if newTotal <= 0 {
                            modelsToRemove.append(viewModel.data.cert.id)
                        }
                    }
                }
            })
            
            // TODO: Ideally when completing this call the REST endpoint would either return the updated models
            // Or we re-fetch the list
            // Here we locally modify the existing model
            if !modelsToRemove.isEmpty {
                var newModels = self.outputs._shares.value
                newModels.removeAll(where: { (viewModel) -> Bool in
                    return modelsToRemove.contains(viewModel.data.cert.id)
                })
                self.outputs._shares.accept(newModels)
            }
            
        }, onError: { [weak self] (error) in
            self?.outputs._error.accept(error)
        }).disposed(by: bag)
    }
    
    func clear() {
        let viewModels = outputs._shares.value
        viewModels.forEach({ $0.data.numberOfSharesSelling.onNext(0) })
        refreshTotals()
    }
    
    // MARK: Private
    
    private func onCertSelected(_ record: ShareCertificateRecord) {
        coordinator.showSellDialog(repo: repo, record: record)
    }
    
    private func refreshTotals() {
        let viewModels = outputs._shares.value
        var totalShares = 0
        var totalSelling = 0
        viewModels.forEach { (vm) in
            let total = try? vm.data.numberOfShares.value()
            totalShares += total ?? 0
            let selling = try? vm.data.numberOfSharesSelling.value()
            totalSelling += selling ?? 0
        }
        outputs._totalSharesToSell.onNext(totalSelling)
        guard totalShares > 0 else {
            outputs._warningText.accept(nil)
            return
        }
        
        let percentage = Int(Double(totalSelling) / Double(totalShares) * 100)
        let isOverThreshold = percentage >= warningLevelPercentageThreshold
        if isOverThreshold {
            outputs._warningText.accept(R.string.localizable.selling_high_percent_warning(warningLevelPercentageThreshold))
        } else {
            outputs._warningText.accept(nil)
        }
    }
    
}
