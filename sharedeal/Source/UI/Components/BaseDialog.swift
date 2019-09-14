//
//  BaseDialog.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import UIKit

class BaseDialog: UIViewController {
    
    // MARK: Properties
    typealias CompletionHandler = () -> Void
    var onComplete: CompletionHandler?
    
    // MARK: - IBOutlets
    
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGestures()
    }
    
    // MARK: - Private
    private func setUpGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapHandler(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    @objc func backgroundTapHandler(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: onComplete)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: onComplete)
    }
}

extension BaseDialog: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Make sure that touches on the dialog view don't hide the view
        if let touchView = touch.view, touchView != view, touchView.isDescendant(of: self.view) {
            return false
        }
        return true
    }
}
