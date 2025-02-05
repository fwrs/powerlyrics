//
//  Image+Ext.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let colorComponentsCount = 4
    static let maxColorValue: CGFloat = 255
    static let red = 0
    static let green = 1
    static let blue = 2
    static let alpha = 3
    
}

// MARK: - UIImage

extension UIImage {
    
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        
        let extentVector = CIVector(
            x: inputImage.extent.origin.x,
            y: inputImage.extent.origin.y,
            z: inputImage.extent.size.width,
            w: inputImage.extent.size.height
        )
        
        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]
        ) else { return nil }
        
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: Constants.colorComponentsCount)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: Constants.colorComponentsCount,
            bounds: CGRect(
                x: 0,
                y: 0,
                width: 1,
                height: 1
            ),
            format: .RGBA8,
            colorSpace: nil
        )
        
        return UIColor(
            red: CGFloat(bitmap[Constants.red]) / Constants.maxColorValue,
            green: CGFloat(bitmap[Constants.green]) / Constants.maxColorValue,
            blue: CGFloat(bitmap[Constants.blue]) / Constants.maxColorValue,
            alpha: CGFloat(bitmap[Constants.alpha]) / Constants.maxColorValue
        )
    }
    
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cg)
        context!.fill(rect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
}

struct UIImageColors {
    var background: UIColor!
    var primary: UIColor!
    var secondary: UIColor!
    var detail: UIColor!
    
    init(background: UIColor, primary: UIColor, secondary: UIColor, detail: UIColor) {
        self.background = background
        self.primary = primary
        self.secondary = secondary
        self.detail = detail
    }
}

enum UIImageColorsQuality: CGFloat {
    case lowest = 50
    case low = 100
    case high = 250
    case highest = 0
}

fileprivate struct UIImageColorsCounter {
    let color: Double
    let count: Int
    init(color: Double, count: Int) {
        self.color = color
        self.count = count
    }
}

fileprivate extension Double {
    
    private var redValue: Double {
        fmod(floor(self / 1000000), 1000000)
    }
    
    private var greenValue: Double {
        fmod(floor(self / 1000), 1000)
    }
    
    private var blueValue: Double {
        fmod(self, 1000)
    }
    
    var isDarkColor: Bool {
        (redValue * 0.2126) + (greenValue * 0.7152) + (blueValue * 0.0722) < 127.5
    }
    
    var isBlackOrWhite: Bool {
        (redValue > 232 && greenValue > 232 && blueValue > 232) || (redValue < 23 && greenValue < 23 && blueValue < 23)
    }
    
    func isDistinct(_ other: Double) -> Bool {
        let rFix = redValue
        let gFix = greenValue
        let bFix = blueValue
        let orFix = other.redValue
        let ogFix = other.greenValue
        let obFix = other.blueValue
        
        return (fabs(rFix-orFix) > 63.75 || fabs(gFix-ogFix) > 63.75 || fabs(bFix-obFix) > 63.75)
            && !(fabs(rFix-gFix) < 7.65 && fabs(rFix-bFix) < 7.65 && fabs(orFix-ogFix) < 7.65 && fabs(orFix-obFix) < 7.65)
    }
    
    func with(minSaturation: Double) -> Double {
        let rFix = redValue / 255
        let gFix = greenValue / 255
        let bFix = blueValue / 255
        var hue, saturation, value: Double
        let mValue = fmax(rFix, fmax(gFix, bFix))
        var cValue = mValue - fmin(rFix, fmin(gFix, bFix))
        
        value = mValue
        saturation = value == 0 ? 0 : cValue / value
        
        if minSaturation <= saturation {
            return self
        }
        
        if cValue == 0 {
            hue = 0
        } else if rFix == mValue {
            hue = fmod((gFix - bFix) / cValue, 6)
        } else if gFix == mValue {
            hue = 2 + ((bFix - rFix) / cValue)
        } else {
            hue = 4 + ((rFix - gFix) / cValue)
        }
        
        if hue < 0 {
            hue += 6
        }
        
        cValue = value * minSaturation
        let xValue = cValue * (1 - fabs(fmod(hue, 2) - 1))
        var red, green, blue: Double
        
        switch hue {
        case 0...1:
            red = cValue
            green = xValue
            blue = 0
            
        case 1...2:
            red = xValue
            green = cValue
            blue = 0
            
        case 2...3:
            red = 0
            green = cValue
            blue = xValue
            
        case 3...4:
            red = 0
            green = xValue
            blue = cValue
            
        case 4...5:
            red = xValue
            green = 0
            blue = cValue
            
        case 5..<6:
            red = cValue
            green = 0
            blue = xValue
            
        default:
            red = 0
            green = 0
            blue = 0
        }
        
        let mNewValue = value - cValue
        
        return (floor((red + mNewValue)*255)*1000000)+(floor((green + mNewValue)*255)*1000)+floor((blue + mNewValue)*255)
    }
    
    func isContrasting(_ color: Double) -> Bool {
        let bgLum = (0.2126*redValue)+(0.7152*greenValue)+(0.0722*blueValue)+12.75
        let fgLum = (0.2126*color.redValue)+(0.7152*color.greenValue)+(0.0722*color.blueValue)+12.75
        if bgLum > fgLum {
            return 1.6 < bgLum/fgLum
        } else {
            return 1.6 < fgLum/bgLum
        }
    }
    
    var uicolor: UIColor {
        UIColor(red: CGFloat(redValue)/255, green: CGFloat(greenValue)/255, blue: CGFloat(blueValue)/255, alpha: 1)
    }
    
    var pretty: String {
        "\(Int(self.redValue)), \(Int(self.greenValue)), \(Int(self.blueValue))"
    }
}

extension UIImage {
    func resizeForUIImageColors(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("UIImageColors.resizeForUIImageColors failed: UIGraphicsGetImageFromCurrentImageContext returned nil.")
        }
        
        return result
    }
    
    func getColors(quality: UIImageColorsQuality = .high, _ completion: @escaping (UIImageColors?) -> Void) {
        DispatchQueue.global().async {
            let result = self.getColors(quality: quality)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    static let sortedColorComparator: Comparator = { (main, other) -> ComparisonResult in
        let mainColors = main as! UIImageColorsCounter, otherColors = other as! UIImageColorsCounter
        if mainColors.count < otherColors.count {
            return .orderedDescending
        } else if mainColors.count == otherColors.count {
            return .orderedSame
        } else {
            return .orderedAscending
        }
    }
    
    func getColors(quality: UIImageColorsQuality = .high) -> UIImageColors? {
        var scaleDownSize: CGSize = self.size
        if quality != .highest {
            if self.size.width < self.size.height {
                let ratio = self.size.height/self.size.width
                scaleDownSize = CGSize(width: quality.rawValue/ratio, height: quality.rawValue)
            } else {
                let ratio = self.size.width/self.size.height
                scaleDownSize = CGSize(width: quality.rawValue, height: quality.rawValue/ratio)
            }
        }
        
        guard let resizedImage = self.resizeForUIImageColors(newSize: scaleDownSize) else { return nil }
        
        guard let cgImage = resizedImage.cgImage else { return nil }
        
        let width: Int = cgImage.width
        let height: Int = cgImage.height
        
        let threshold = Int(CGFloat(height) * 0.01)
        var proposed: [Double] = [-1, -1, -1, -1]
        
        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("UIImageColors.getColors failed: could not get cgImage data.")
        }
        
        let imageColors = NSCountedSet(capacity: width*height)
        for x in 0..<width {
            for y in 0..<height {
                let pixel: Int = ((width * y) + x) * 4
                if data[pixel + 3] >= 127 {
                    imageColors.add((Double(data[pixel+2])*1000000)+(Double(data[pixel+1])*1000)+(Double(data[pixel])))
                }
            }
        }
        
        var enumerator = imageColors.objectEnumerator()
        var sortedColors = NSMutableArray(capacity: imageColors.count)
        while let next = enumerator.nextObject() as? Double {
            let count = imageColors.count(for: next)
            if threshold < count {
                sortedColors.add(UIImageColorsCounter(color: next, count: count))
            }
        }
        sortedColors.sort(comparator: UIImage.sortedColorComparator)
        
        var proposedEdgeColor: UIImageColorsCounter
        let numberOfItems = sortedColors.count
        if numberOfItems > 0 {
            proposedEdgeColor = sortedColors.object(at: 0) as! UIImageColorsCounter
        } else {
            proposedEdgeColor = UIImageColorsCounter(color: 0, count: 1)
        }
        
        if proposedEdgeColor.color.isBlackOrWhite && 0 < sortedColors.count {
            for i in 1..<sortedColors.count {
                let nextProposedEdgeColor = sortedColors.object(at: i) as! UIImageColorsCounter
                if Double(nextProposedEdgeColor.count) / Double(proposedEdgeColor.count) > 0.3 {
                    if !nextProposedEdgeColor.color.isBlackOrWhite {
                        proposedEdgeColor = nextProposedEdgeColor
                        break
                    }
                } else {
                    break
                }
            }
        }
        proposed[0] = proposedEdgeColor.color
        
        enumerator = imageColors.objectEnumerator()
        sortedColors.removeAllObjects()
        sortedColors = NSMutableArray(capacity: imageColors.count)
        let findDarkTextColor = !proposed.first.safe.isDarkColor
        
        while var next = enumerator.nextObject() as? Double {
            next = next.with(minSaturation: 0.15)
            if next.isDarkColor == findDarkTextColor {
                let count = imageColors.count(for: next)
                sortedColors.add(UIImageColorsCounter(color: next, count: count))
            }
        }
        sortedColors.sort(comparator: UIImage.sortedColorComparator)
        
        for color in sortedColors {
            let color = (color as! UIImageColorsCounter).color
            
            if proposed[1] == -1 {
                if color.isContrasting(proposed[0]) {
                    proposed[1] = color
                }
            } else if proposed[2] == -1 {
                if !color.isContrasting(proposed[0]) || !proposed[1].isDistinct(color) {
                    continue
                }
                proposed[2] = color
            } else if proposed[3] == -1 {
                if !color.isContrasting(proposed[0]) || !proposed[2].isDistinct(color) || !proposed[1].isDistinct(color) {
                    continue
                }
                proposed[3] = color
                break
            }
        }
        
        let isDarkBackground = proposed[0].isDarkColor
        for i in 1...3 where proposed[i] == -1 {
            proposed[i] = isDarkBackground ? 255255255 : 0
        }
        
        return UIImageColors(
            background: proposed[0].uicolor,
            primary: proposed[1].uicolor,
            secondary: proposed[2].uicolor,
            detail: proposed[3].uicolor
        )
    }
}
