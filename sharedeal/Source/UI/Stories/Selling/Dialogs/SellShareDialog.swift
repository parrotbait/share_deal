//
//  QuestionWasSentDialog.swift
//  Whoppah
//
//  Created by Boris Sagan on 3/28/19.
//  Copyright © 2019 Whoppah. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import RxSwift

class SellShareDialog: BaseDialog {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sharesLabel: UILabel!
    @IBOutlet weak var numSharesTextfield: SkyFloatingLabelTextField!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    private let bag = DisposeBag()
    var viewModel: SellShareDialogViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.outputs.currentPrice.bind(to: currentPriceLabel.rx.text).disposed(by: bag)
        viewModel.outputs.totalPrice.bind(to: totalPriceLabel.rx.text).disposed(by: bag)
        viewModel.outputs.numberOfShares.bind(to: numSharesTextfield.rx.text).disposed(by: bag)
        titleLabel.text = R.string.localizable.sell_share_dialog_title()
        viewModel.outputs.name.bind(to: nameLabel.rx.text).disposed(by: bag)
        viewModel.outputs.totalShares.bind(to: sharesLabel.rx.text).disposed(by: bag)
        totalTitleLabel.text = R.string.localizable.sell_share_dialog_total_price()
        // Clear down the error when the user types
        numSharesTextfield.rx.text.distinctUntilChanged().subscribe(onNext: { [weak self] _ in
            self?.numSharesTextfield.errorMessage = nil
        }).disposed(by: bag)
        viewModel.outputs.saveButton.bind(to: saveButton.rx.isEnabled).disposed(by: bag)
        viewModel.outputs.saveButton.map({ $0 ? 1.0 : 0.3 }).bind(to: saveButton.rx.alpha).disposed(by: bag)
        numSharesTextfield.rx.text.orEmpty.bind(to: viewModel.inputs.numberOfShares).disposed(by: bag)
        viewModel.outputs.error.subscribe(onNext: { [weak self] (error) in
            self?.numSharesTextfield.errorMessage = error
        }).disposed(by: bag)
        
        cancelButton.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: bag)
        
        saveButton.rx.tap.bind { [weak self] in
            self?.viewModel.save()
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: bag)
        viewModel.outputs.saveButton.bind(to: saveButton.rx.isEnabled).disposed(by: bag)
    }
}
