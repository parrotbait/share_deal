//
//  ShareSellListCell.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ShareSellListCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var currentSharesLabel: UILabel!
    @IBOutlet weak var sellingSharesTitleLabel: UILabel!
    @IBOutlet weak var sellingSharesLabel: UILabel!
    @IBOutlet weak var cancelSellButton: UIButton!
    private var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with vm: ShareCellViewModel) {
        bag = DisposeBag()
        vm.name.bind(to: nameLabel.rx.text).disposed(by: bag)
        vm.outputs.currentHoldingsText.bind(to: currentSharesLabel.rx.text).disposed(by: bag)
        vm.outputs.sellingSharesText.bind(to: sellingSharesLabel.rx.text).disposed(by: bag)
        vm.outputs.isSelling.map({ !$0 }).bind(to: sellingSharesTitleLabel.rx.isHidden).disposed(by: bag)
        vm.outputs.isSelling.map({ !$0 }).bind(to: sellingSharesLabel.rx.isHidden).disposed(by: bag)
        vm.outputs.isSelling.map({ !$0 }).bind(to: cancelSellButton.rx.isHidden).disposed(by: bag)
        cancelSellButton.rx.tap.bind {
            vm.cancelSale()
        }.disposed(by: bag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
