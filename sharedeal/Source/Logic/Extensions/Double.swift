//
//  Double.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

extension Double {
    func formattedPrice(currency: Currency?, showFraction: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let currency = currency {
            formatter.currencySymbol = currency.rawValue
        }
        formatter.maximumFractionDigits = showFraction ? 2 : 0
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
