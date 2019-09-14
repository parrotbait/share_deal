//
//  UIV.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

extension UIView {
    
    func addTopShadow(height: CGFloat, radius: CGFloat, color: UIColor = .black) {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: -height)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = 0.3
    }
}
