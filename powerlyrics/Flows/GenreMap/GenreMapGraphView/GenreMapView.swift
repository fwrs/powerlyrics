//
//  GenreMapView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import UIKit

class GenreMapView: UIView {
    
    var values = [CGFloat]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addBehavior()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addBehavior()
    }
    
    func roseGraph(inset: CGFloat, rect: CGRect, values: [CGFloat]) -> UIBezierPath {
        let xCenter = rect.origin.x + rect.size.height / 2
        let yCenter = rect.origin.y + rect.size.width / 2
        
        let width: CGFloat = rect.size.width - inset
        let radius: CGFloat = width / 2.0
        
        let things: CGFloat = 8
        
        let theta = .pi * (2.0 / things)
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: xCenter, y: yCenter-CGFloat(radius * values[0])))
        
        for i in 1...Int(things) {
            let localRadius = values[i - 1]
            let x = (radius * localRadius) * sin((things - CGFloat(i) - 3) * theta)
            let y = (radius * localRadius) * cos((things - CGFloat(i) - 3) * theta)
            
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
        let baseInset: CGFloat = 95
        let path = roseGraph(inset: baseInset, rect: bounds, values: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0].map { _ in 0 })
        shapeLayer = CAShapeLayer()

        shapeLayer.path = path.cgPath
        
        let color: [CGFloat] = [ 234.0 / 255.0, 174.0 / 255.0, 127.0 / 255.0, 1.0 ]
        let aColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: color)!
        let fillColor: [CGFloat] = [ 234.0 / 255.0, 174.0 / 255.0, 127.0 / 255.0, 0.3 ]
        let aFillColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: fillColor)!
        
        shapeLayer.strokeColor = aColor
        shapeLayer.fillColor = aFillColor
        
        shapeLayer.lineWidth = 2.0
        shapeLayer.position = .zero

        self.layer.addSublayer(shapeLayer)
    }
    
    var oldValues: [CGFloat] = [0, 0, 0, 0, 0, 0, 0, 0]
    
    func animatePathChange(fast: Bool = false) {
        var prevDelay = 0.0
        let group = DispatchGroup()
        for i in 0..<8 {
            group.enter()
            delay((prevDelay + pow(fast ? 0.3 : 0.9, Double(i+1))) / 20) { [self] in
                let baseInset: CGFloat = 95
                let newPath = roseGraph(inset: baseInset, rect: bounds, values: values.enumerated().map { $0 > i ? oldValues[$0] : CGFloat($1) }).cgPath
                let animation = CABasicAnimation(keyPath: "path")
                animation.duration = 0.5
                animation.fromValue = shapeLayer.presentation()?.path
                animation.toValue = newPath
                animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.075, 0.82, 0.165, 1)
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                shapeLayer.path = shapeLayer.presentation()?.path
                shapeLayer.removeAllAnimations()
                shapeLayer.add(animation, forKey: "path")
                delay(0.5) {
                    group.leave()
                }
            }
            prevDelay += pow(fast ? 0.3 : 0.9, Double(i+1))
        }
        group.notify(queue: .main) { [self] in
            oldValues = values
        }
        
    }
    
}
