//
//  sharedealTests.swift
//  sharedealTests
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import XCTest
import RxBlocking
import RxSwift

@testable import sharedeal

class ShareListViewModelTests: XCTestCase {

    private let certs = [ShareCertificate(id: 1, numShares: 1000, issueDate: Date()),
                         ShareCertificate(id: 2, numShares: 1000, issueDate: Date()),
                         ShareCertificate(id: 3, numShares: 1000, issueDate: Date())]
    
    let dummyPrice = SharesPrice(name: "Company ABC", symbol: "MY Symbol", value: 100)
    private func getViewModel(shareService: MockShareService, coordinator: MockShareListCoordinator = MockShareListCoordinator()) -> ShareSellingListViewModel {
        let provider = MockProvider(http: MockHttpService(environment: Environment(name: "", host: "")), share: shareService)
        let repo = MockShareSellingRepository(service: shareService)
        let viewModel = ShareSellingListViewModel(provider: provider, coordinator: coordinator, repo: repo)
        return viewModel
    }
    
    func testDefaults() {
        let viewModel = getViewModel(shareService: MockShareService())
        XCTAssertFalse(try viewModel.outputs.clearEnabled.toBlocking().first()!)
        XCTAssertFalse(try viewModel.outputs.sellEnabled.toBlocking().first()!)
        XCTAssertEqual(try viewModel.outputs.shares.toBlocking().first()?.count, 0)
    }

    func testShareLoading() {
        let shareService = MockShareService()
        let certs = [ShareCertificate(id: 1, numShares: 1000, issueDate: Date()),
                     ShareCertificate(id: 2, numShares: 1000, issueDate: Date()),
                     ShareCertificate(id: 3, numShares: 1000, issueDate: Date())]
        shareService.certificates = certs
        let viewModel = getViewModel(shareService: shareService)
        
        let expectation = XCTestExpectation(description: "Waiting for ads")
        let bag = DisposeBag()
        viewModel.outputs.shares
            .skip(1)
            .subscribe(onNext: { (models) in
            XCTAssertEqual(models.count, certs.count)
            for (index, model) in models.enumerated() {
                XCTAssertEqual(model.data.cert.id, certs[index].id)
            }
            expectation.fulfill()
        }, onError: { (error) in
            XCTFail("Unexpected failure \(error)")
        }).disposed(by: bag)
        viewModel.load()
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testPriceLoading() {
        let shareService = MockShareService()
        shareService.certificates = certs
        shareService.price = dummyPrice
        let viewModel = getViewModel(shareService: shareService)
        
        let expectation = XCTestExpectation(description: "Waiting for ads")
        let bag = DisposeBag()
        viewModel.outputs.currentPrice.skip(1).subscribe(onNext: { (text) in
            XCTAssertTrue(text.contains(self.dummyPrice.value.formattedPrice(currency: self.dummyPrice.currency)))
            expectation.fulfill()
        }, onError: { (error) in
            XCTFail("Unexpected failure \(error)")
        }).disposed(by: bag)
        viewModel.load()
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testLoadingCompleted() {
        let shareService = MockShareService()
        shareService.certificates = certs
        shareService.price = dummyPrice
        let viewModel = getViewModel(shareService: shareService)
        
        let expectation = XCTestExpectation(description: "Waiting for ads")
        let bag = DisposeBag()
        viewModel.outputs.loading.skip(1).subscribe(onNext: { (loading) in
            XCTAssertFalse(loading)
            expectation.fulfill()
        }).disposed(by: bag)
        viewModel.load()
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testShareClickNavigation() {
        let shareService = MockShareService()
        shareService.certificates = certs
        let coordinator = MockShareListCoordinator()
        let viewModel = getViewModel(shareService: shareService, coordinator: coordinator)
        let expectationNav = XCTestExpectation(description: "Waiting for navigation")
        
        let bag = DisposeBag()
        viewModel.outputs.shares
            .skip(1)
            .subscribe(onNext: { (models) in
            models.first?.onClick()
            XCTAssertTrue(coordinator.showedDialog)
            XCTAssertEqual(coordinator.record?.cert.id, models.first?.data.cert.id)
            expectationNav.fulfill()
        }, onError: { (error) in
            XCTFail("Unexpected failure \(error)")
        }).disposed(by: bag)
        
        viewModel.load()
        wait(for: [expectationNav], timeout: 0.5)
    }
    
    func testShareSelection() {
        let shareService = MockShareService()
        shareService.certificates = certs
        let coordinator = MockShareListCoordinator()
        let viewModel = getViewModel(shareService: shareService, coordinator: coordinator)
        let expectationSell = XCTestExpectation(description: "Waiting for sell button")
        let expectationClear = XCTestExpectation(description: "Waiting for clear button")
        
        let bag = DisposeBag()
        viewModel.outputs.shares
            .skip(1)
            .subscribe(onNext: { (models) in
                viewModel.outputs.sellEnabled.skip(1).subscribe(onNext: { (enabled) in
                    XCTAssertTrue(enabled)
                    expectationSell.fulfill()
                }).disposed(by: bag)
                viewModel.outputs.clearEnabled.skip(1).subscribe(onNext: { (enabled) in
                    XCTAssertTrue(enabled)
                    expectationClear.fulfill()
                }).disposed(by: bag)
                models.first?.onClick()
                coordinator.record?.numberOfSharesSelling.onNext(100)
            }, onError: { (error) in
                XCTFail("Unexpected failure \(error)")
            }).disposed(by: bag)
        
        viewModel.load()
        wait(for: [expectationClear, expectationSell], timeout: 0.5)
    }
    
    func testShareSelectionCancel() {
        let shareService = MockShareService()
        shareService.certificates = certs
        let coordinator = MockShareListCoordinator()
        let viewModel = getViewModel(shareService: shareService, coordinator: coordinator)
        let expectationSell = XCTestExpectation(description: "Waiting for sell button")
        let expectationClear = XCTestExpectation(description: "Waiting for clear button")
        
        let bag = DisposeBag()
        viewModel.outputs.shares
            .skip(1)
            .subscribe(onNext: { (models) in
                models.first?.onClick()
                coordinator.record?.numberOfSharesSelling.onNext(100)
                models.first?.cancelSale()
                
                viewModel.outputs.sellEnabled.skip(1).subscribe(onNext: { (enabled) in
                    XCTAssertFalse(enabled)
                    expectationSell.fulfill()
                }).disposed(by: bag)
                viewModel.outputs.clearEnabled.skip(1).subscribe(onNext: { (enabled) in
                    XCTAssertFalse(enabled)
                    expectationClear.fulfill()
                }).disposed(by: bag)
                
            }, onError: { (error) in
                XCTFail("Unexpected failure \(error)")
            }).disposed(by: bag)
        
        viewModel.load()
        wait(for: [expectationClear, expectationSell], timeout: 0.5)
    }
    
    func testShareListClear() {
        let shareService = MockShareService()
        shareService.certificates = certs
        let coordinator = MockShareListCoordinator()
        let viewModel = getViewModel(shareService: shareService, coordinator: coordinator)
        let expectationSell = XCTestExpectation(description: "Waiting for sell button")
        let expectationClear = XCTestExpectation(description: "Waiting for clear button")
        
        let bag = DisposeBag()
        viewModel.outputs.shares
            .skip(1)
            .subscribe(onNext: { (models) in
                models.first?.onClick()
                // sell/clear is now enabled
                coordinator.record?.numberOfSharesSelling.onNext(100)
                // clear disables the buttons again
                viewModel.clear()
                viewModel.outputs.sellEnabled.skip(1).subscribe(onNext: { (enabled) in
                    XCTAssertFalse(enabled)
                    expectationSell.fulfill()
                }).disposed(by: bag)
                viewModel.outputs.clearEnabled.skip(1).subscribe(onNext: { (enabled) in
                    XCTAssertFalse(enabled)
                    expectationClear.fulfill()
                }).disposed(by: bag)
                
            }, onError: { (error) in
                XCTFail("Unexpected failure \(error)")
            }).disposed(by: bag)
        
        viewModel.load()
        wait(for: [expectationClear, expectationSell], timeout: 0.5)
    }
    
    func testShareListPostSellAmountChanged() {
        let shareService = MockShareService()
        shareService.certificates = certs
        let coordinator = MockShareListCoordinator()
        let viewModel = getViewModel(shareService: shareService, coordinator: coordinator)
        let expectation = XCTestExpectation(description: "Waiting for share sell amount to change")
        
        let bag = DisposeBag()
        viewModel.outputs.shares
            .skip(1)
            .subscribe(onNext: { (models) in
                models.first?.onClick()
                // sell/clear is now enabled
                let firstModelId = coordinator.record?.cert.id
                guard let initialShareCount = try? coordinator.record?.numberOfShares.value() else {
                    assertionFailure("Expected to be able to get share count")
                    return
                }
                let sharesSold = 100
                coordinator.record?.numberOfSharesSelling.onNext(sharesSold)
                models.last?.onClick()
                coordinator.record?.numberOfSharesSelling.onNext(100)
                // sell disables the buttons again
                viewModel.sell()
                XCTAssertEqual(shareService.sellingCerts.count, 2)
                XCTAssertEqual(shareService.sellingCerts.first?.id, models.first?.data.cert.id)
                XCTAssertEqual(shareService.sellingCerts.last?.id, models.last?.data.cert.id)
                
                viewModel.outputs.shares.subscribe(onNext: { (models) in
                    for model in models where model.data.cert.id == firstModelId {
                        guard let newCount = try? model.data.numberOfShares.value() else {
                            assertionFailure("Expected to be able to get new share count")
                            return
                        }
                        XCTAssertEqual(newCount, initialShareCount - 100)
                    }
                    expectation.fulfill()
                }).disposed(by: bag)
            }, onError: { (error) in
                XCTFail("Unexpected failure \(error)")
            }).disposed(by: bag)
        
        viewModel.load()
        wait(for: [expectation], timeout: 0.5)
    }
    
}
