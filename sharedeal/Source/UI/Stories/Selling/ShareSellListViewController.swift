//
//  ViewController.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import UIKit
import RxSwift

class ShareSellListViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    var viewModel: ShareSellingListViewModel!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupBindings()
        viewModel.load()
    }
    
    private func setupTableView() {
        tableView.register(R.nib.shareSellListCell)
    }
    
    private func setupBindings() {
        viewModel.outputs.shares
            .bind(to: tableView.rx.items(cellIdentifier: R.nib.shareSellListCell.name, cellType: ShareSellListCell.self)) { [weak self] (_, viewModel, cell) in
            guard let self = self else { return }
            cell.configure(with: viewModel, bag: self.bag)
        }.disposed(by: bag)
        
        viewModel.outputs.error
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (error) in
            self?.showError(error)
        }).disposed(by: bag)
    }
}
