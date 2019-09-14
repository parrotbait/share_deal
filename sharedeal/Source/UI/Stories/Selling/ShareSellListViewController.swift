//
//  ViewController.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD

class ShareSellListViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalShares: UILabel!
    @IBOutlet weak var totalBalance: UILabel!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var bottomSection: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    
    // MARK: Properties
    var viewModel: ShareSellingListViewModel!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupBindings()
        setupBottomSection()
        viewModel.load()
    }
    
    private func setupBottomSection() {
        bottomSection.addTopShadow(height: 2, radius: 5, color: UIColor.init(white: 0.3, alpha: 0.7))
    }
    
    private func setupTableView() {
        tableView.register(R.nib.shareSellListCell)
        // Inset so we can scroll all the way to the bottom of the list
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
    }
    
    private func setupBindings() {
        
        viewModel.outputs.shares
        .bind(to: tableView.rx.items(cellIdentifier: R.nib.shareSellListCell.name, cellType: ShareSellListCell.self)) { [weak self] (_, viewModel, cell) in
            cell.configure(with: viewModel)
        }.disposed(by: bag)
        
        Observable
        .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ShareCellViewModel.self))
        .bind { [weak self] indexPath, model in
                guard let self = self else { return }
                self.tableView.deselectRow(at: indexPath, animated: true)
                model.onClick()
        }.disposed(by: bag)
        
        viewModel.outputs.error
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (error) in
            self?.showError(error)
        }).disposed(by: bag)
        
        viewModel.outputs.loading
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (loading) in
                guard let self = self else { return }
                if loading {
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.label.text = R.string.localizable.selling_loading_hud_text()
                    hud.backgroundColor = UIColor(white: 0.3, alpha: 0.8)
                    hud.isUserInteractionEnabled = false
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
        }).disposed(by: bag)
        
        viewModel.outputs.currentPrice.bind(to: priceLabel.rx.text).disposed(by: bag)
        viewModel.outputs.name.bind(to: nameLabel.rx.text).disposed(by: bag)
        viewModel.outputs.totalSharesToSell.bind(to: totalShares.rx.text).disposed(by: bag)
        viewModel.outputs.totalSaleValue.bind(to: totalBalance.rx.text).disposed(by: bag)
        viewModel.outputs.sellEnabled.bind(to: sellButton.rx.isEnabled).disposed(by: bag)
        viewModel.outputs.sellEnabled.map({ $0 ? 1.0 : 0.3 }).bind(to: sellButton.rx.alpha).disposed(by: bag)
        sellButton.rx.tap.bind { [weak self] in
            self?.viewModel.sell()
        }.disposed(by: bag)
        
        clearButton.rx.tap.bind { [weak self] in
            self?.viewModel.clear()
        }.disposed(by: bag)
        viewModel.outputs.clearEnabled.bind(to: clearButton.rx.isEnabled).disposed(by: bag)
        
        viewModel.outputs.warningText.map({ $0 == nil }).bind(to: warningLabel.rx.isHidden).disposed(by: bag)
        viewModel.outputs.warningText.bind(to: warningLabel.rx.text).disposed(by: bag)
    }
}
