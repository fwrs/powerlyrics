//
//  GenreMapView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let baseInset: CGFloat = 95
    
    static let chartAnimationTimingFunction = CAMediaTimingFunction(controlPoints: 0.075, 0.82, 0.165, 1)
    
    static let chartAnimationDelayGrowth: Double = 20
    
    static let path = "path"
    
}

// MARK: - GenreMapView

class GenreMapView: UIView {
    
    // MARK: - Instance properties
    
    var oldValues = Constants.baseLikedSongCounts
    
    var values = Constants.baseLikedSongCounts
    
    var shapeLayer: CAShapeLayer!
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    // MARK: - Setup
    
    func setupView() {
        shapeLayer?.removeFromSuperlayer()
        let baseInset = Constants.baseInset
        let path = radarChart(inset: baseInset, rect: bounds, values: Constants.baseLikedSongCounts)
        shapeLayer = CAShapeLayer()

        shapeLayer.path = path.cgPath
        
        shapeLayer.strokeColor = UIColor.tintColor.cg
        shapeLayer.fillColor = UIColor.tintColor.withAlphaComponent(.pointThree).cg
        
        shapeLayer.lineWidth = .two
        shapeLayer.position = .zero

        self.layer.addSublayer(shapeLayer)
    }
    
    // MARK: - Helper methods
    
    func radarChart(inset: CGFloat, rect: CGRect, values: [CGFloat]) -> UIBezierPath {
        let xCenter = rect.origin.x + rect.size.height / .two
        let yCenter = rect.origin.y + rect.size.width / .two
        
        let width: CGFloat = rect.size.width - inset
        let radius: CGFloat = width / .two
        
        let vertices = CGFloat(RealmLikedSongGenre.total)
        
        let theta = .pi * (.two / vertices)
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: xCenter, y: yCenter - CGFloat(radius * values.first.safe)))
        
        for i in .one...Int(vertices) {
            let localRadius = values[i - .one]
            let x = (radius * localRadius) * sin((vertices - CGFloat(i) - .three) * theta)
            let y = (radius * localRadius) * cos((vertices - CGFloat(i) - .three) * theta)
            
            let x1: CGFloat = x+xCenter
            let y1: CGFloat = y+yCenter
            path.addLine(to: CGPoint(x: x1, y: y1))
        }
        
        path.close()
        
        return path
    }
    
    func animatePathChange(fast: Bool = false) {
        var prevDelay = Double.zero
        let group = DispatchGroup()
        for i in .zero..<RealmLikedSongGenre.total {
            group.enter()
            
            delay((prevDelay + pow(fast ? .pointThree : .pointThree * .three, Double(i + .one))) / Constants.chartAnimationDelayGrowth) { [self] in
                let baseInset: CGFloat = Constants.baseInset
                
                let newPath = radarChart(
                    inset: baseInset,
                    rect: bounds,
                    values: values.enumerated().map { $0 > i ? oldValues[$0] : CGFloat($1) }
                ).cgPath
                
                let animation = CABasicAnimation(keyPath: Constants.path)
                
                animation.duration = .half
                animation.fromValue = shapeLayer.presentation()?.path
                animation.toValue = newPath
                animation.timingFunction = Constants.chartAnimationTimingFunction
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                shapeLayer.path = shapeLayer.presentation()?.path
                shapeLayer.removeAllAnimations()
                shapeLayer.add(animation, forKey: Constants.path)
                
                delay(.half) {
                    group.leave()
                }
            }
            
            prevDelay += pow(fast ? .pointThree : .pointThree * .three, Double(i + .one))
        }
        
        group.notify(queue: .main) { [self] in
            oldValues = values
        }
        
    }
    
}
