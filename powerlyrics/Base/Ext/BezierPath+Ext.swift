//
//  BezierPath+Ext.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

extension UIBezierPath {

    static func superellipse(in rect: CGRect, cornerRadius: CGFloat) -> UIBezierPath {

        let minSide = min(rect.width, rect.height)
        let radius = min(cornerRadius, minSide/2)

        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)

        let p0 = CGPoint(x: rect.minX + radius, y: rect.minY)
        let p1 = CGPoint(x: rect.maxX - radius, y: rect.minY)

        let p2 = CGPoint(x: rect.maxX, y: rect.minY + radius)
        let p3 = CGPoint(x: rect.maxX, y: rect.maxY - radius)

        let p4 = CGPoint(x: rect.maxX - radius, y: rect.maxY)
        let p5 = CGPoint(x: rect.minX + radius, y: rect.maxY)

        let p6 = CGPoint(x: rect.minX, y: rect.maxY - radius)
        let p7 = CGPoint(x: rect.minX, y: rect.minY + radius)

        let path = UIBezierPath()
        path.move(to: p0)
        path.addLine(to: p1)
        path.addCurve(to: p2, controlPoint1: topRight, controlPoint2: topRight)
        path.addLine(to: p3)
        path.addCurve(to: p4, controlPoint1: bottomRight, controlPoint2: bottomRight)
        path.addLine(to: p5)
        path.addCurve(to: p6, controlPoint1: bottomLeft, controlPoint2: bottomLeft)
        path.addLine(to: p7)
        path.addCurve(to: p0, controlPoint1: topLeft, controlPoint2: topLeft)

        return path
    }
}
