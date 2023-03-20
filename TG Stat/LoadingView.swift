//
//  LoadingView.swift
//  MOBAPP_B2C
//
//  Created by Denis Smirnov on 20/09/2019.
//  Copyright © 2019 fil-it. All rights reserved.
//

import UIKit

public final class LoadingView: UIView {
    
    private let canvasView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var timer: Timer?
    private var isLoading = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public func setLoadingState(_ isLoading: Bool) {
        guard self.isLoading != isLoading else {
            if isLoading, activityIndicator.isHidden {
                animateLoadingState(isLoading)
            }
            return
        }
        self.isLoading = isLoading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            self?.animateLoadingState(isLoading)
        })
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        canvasView.center = CGPoint(x: bounds.midX,
                                    y: bounds.midY)
        activityIndicator.center = CGPoint(x: canvasView.bounds.midX,
                                           y: canvasView.bounds.midY)
    }
}

// MARK: - Private methods
extension LoadingView {
    private func initialize() {
        addSubview(canvasView)
        canvasView.alpha = 0.0
        canvasView.addSubview(activityIndicator)
        canvasView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: 49,
                                  height: 49)
        canvasView.backgroundColor = .gray
        canvasView.layer.cornerRadius = 8.0
        canvasView.clipsToBounds = true
        
        isUserInteractionEnabled = false
    }
    
    private func animateLoadingState(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        self.isUserInteractionEnabled = isLoading
        UIView.animate(withDuration: 0.1) {
            self.canvasView.alpha = isLoading ? 1.0 : 0.0
        }
    }
}
