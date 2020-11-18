//
//  GenreMapView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

fileprivate extension Constants {
    
    static let baseInset: CGFloat = 95
    
    static let chartAnimationTimingFunction = CAMediaTimingFunction(controlPoints: 0.075, 0.82, 0.165, 1)
    
    static let chartAnimationDelayGrowth: Double = 20
    
}

class GenreMapView: UIView {
    
    var values: [CGFloat] = Constants.baseLikedSongCounts
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addBehavior()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addBehavior()
    }
    
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
    
    var shapeLayer: CAShapeLayer!

    func addBehavior() {
        shapeLayer?.removeFromSuperlayer()
        let baseInset = Constants.baseInset
        let path = radarChart(inset: baseInset, rect: bounds, values: Constants.baseLikedSongCounts)
        shapeLayer = CAShapeLayer()

        shapeLayer.path = path.cgPath
        
        shapeLayer.strokeColor = UIColor.tintColor.cg
        shapeLayer.fillColor = UIColor.tintColor.withAlphaComponent(.oThree).cg
        
        shapeLayer.lineWidth = .two
        shapeLayer.position = .zero

        self.layer.addSublayer(shapeLayer)
    }
    
    var oldValues = Constants.baseLikedSongCounts
    
    func animatePathChange(fast: Bool = false) {
        var prevDelay = Double.zero
        let group = DispatchGroup()
        for i in 0..<8 {
            group.enter()
            delay((prevDelay + pow(fast ? .oThree : .oThree * .three, Double(i + .one))) / Constants.chartAnimationDelayGrowth) { [self] in
                let baseInset: CGFloat = Constants.baseInset
                let newPath = radarChart(inset: baseInset, rect: bounds, values: values.enumerated().map { $0 > i ? oldValues[$0] : CGFloat($1) }).cgPath
                let animation = CABasicAnimation(keyPath: "path")
                animation.duration = .half
                animation.fromValue = shapeLayer.presentation()?.path
                animation.toValue = newPath
                animation.timingFunction = Constants.chartAnimationTimingFunction
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                shapeLayer.path = shapeLayer.presentation()?.path
                shapeLayer.removeAllAnimations()
                shapeLayer.add(animation, forKey: "path")
                delay(.half) {
                    group.leave()
                }
            }
            prevDelay += pow(fast ? .oThree : .oThree * .three, Double(i+1))
        }
        group.notify(queue: .main) { [self] in
            oldValues = values
        }
        
    }
    
}
