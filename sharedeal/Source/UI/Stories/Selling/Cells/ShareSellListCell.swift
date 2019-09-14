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
    @IBOutlet weak var numSharesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with vm: ShareCellViewModel, bag: DisposeBag) {
        vm.name.bind(to: nameLabel.rx.text).disposed(by: bag)
        vm.numberShares.bind(to: numSharesLabel.rx.text).disposed(by: bag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
