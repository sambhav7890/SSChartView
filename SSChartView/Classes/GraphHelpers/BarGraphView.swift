//
//  BarGraphView.swift
//  Graphs
//
//  Created by Sambhav Shah on 2016/09/02.
//  Copyright © 2016 S. All rights reserved.
//

import UIKit

public enum GraphColorType {
    case
    Mat(UIColor),
    Gradation(UIColor, UIColor)
}

extension UIColor {
    
    func matColor() -> GraphColorType {
        return .Mat(self)
    }

	static func gradient(color1: UIColor, color2: UIColor) -> GraphColorType {
		return .Gradation(color1, color2)
	}

	func components() -> UnsafePointer<CGFloat> {
		let cgColor = self.CGColor
		let components = CGColorGetComponents(cgColor)
		return components
	}
}

extension CGRect {
	var ending: CGPoint {
		var point = self.origin
//		point.x += self.size.width
		point.y += self.size.height
		return point
	}
}

public struct BarGraphViewConfig {
    
    public var barColor: GraphColorType
    public var textColor: UIColor
    public var textFont: UIFont
    public var textVisible: Bool
    public var zeroLineVisible: Bool
    public var barWidthScale: CGFloat
    public var contentInsets: UIEdgeInsets
    
    public init(
        barColor: UIColor? = nil,
        textColor: UIColor? = nil,
        textFont: UIFont? = nil,
        barWidthScale: CGFloat? = nil,
        zeroLineVisible: Bool? = nil,
        textVisible: Bool? = nil,
        contentInsets: UIEdgeInsets? = nil
    ) {
        self.barColor = (barColor ?? DefaultColorType.Bar.color()).matColor()
        self.textColor = textColor ?? DefaultColorType.BarText.color()
        self.textFont = textFont ?? UIFont.systemFontOfSize(10.0)
        self.barWidthScale = barWidthScale ?? 0.8
        self.zeroLineVisible = zeroLineVisible ?? true
        self.textVisible = textVisible ?? true
        self.contentInsets = contentInsets ?? UIEdgeInsetsZero
    }
}


internal class BarGraphView<T: Hashable, U: NumericType>: UIView {

    
    internal var graph: BarGraph<T, U>?
    
    private var config = BarGraphViewConfig()
    
    init(frame: CGRect, graph: BarGraph<T, U>?) {
        
        self.graph = graph
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.setNeedsDisplay()
    }
    
    func setBarGraphViewConfig(config: BarGraphViewConfig?) {
        
        self.config = config ?? BarGraphViewConfig()
        self.setNeedsDisplay()
    }
    
    private func graphFrame() -> CGRect {
        return CGRect(
            x: self.config.contentInsets.left,
            y: self.config.contentInsets.top,
            width: self.frame.size.width - self.config.contentInsets.horizontalMarginsTotal(),
            height: self.frame.size.height - self.config.contentInsets.verticalMarginsTotal()
        )
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let graph = self.graph else { return }
        
        let total = graph.units.map{ $0.value }.reduce(U(0)){ $0 + $1 }
        let rect = self.graphFrame()
        let min = graph.range.min
        let max = graph.range.max
        
        let sectionWidth = rect.size.width / CGFloat(graph.units.count)
        let width = sectionWidth * self.config.barWidthScale
        
        let zero = rect.size.height / CGFloat((max - min).floatValue()) * CGFloat(min.floatValue())

        graph.units.enumerate().forEach({ (index, u) in

			let height = { () -> CGFloat in
				switch u.value {
				case let n where n > U(0):
					return rect.size.height * CGFloat(
						u.value.floatValue() / (max - min).floatValue()
					)
				case let n where n < U(0):
					return rect.size.height * CGFloat(
						-(u.value).floatValue() / (max - min).floatValue()
					)
				case _:
					return 0.0
				}
			}()

			let bezierX = sectionWidth * CGFloat(index) + (sectionWidth - width) / 2.0 + rect.origin.x
			let bezierY = (u.value >= U(0) ? rect.size.height - height : rect.size.height) + zero + rect.origin.y

			let bezierRect = CGRect(x: bezierX, y: bezierY, width: width, height: height)

			let path = UIBezierPath(rect: bezierRect)

			switch self.config.barColor {
			case let .Mat(color):
				color.setFill()
				path.fill()
			case let .Gradation(color1, color2):
				let colors = [color1.CGColor, color2.CGColor]
				let colorSpace = CGColorSpaceCreateDeviceRGB()
				let colorLocations:[CGFloat] = [0.0, 1.0]
				if let gradient = CGGradientCreateWithColors(colorSpace, colors, colorLocations) {
					let context = UIGraphicsGetCurrentContext()
					CGContextSaveGState(context)
					CGContextAddPath(context, path.CGPath)
					CGContextClip(context)
					CGContextDrawLinearGradient(context, gradient, bezierRect.origin, bezierRect.ending, CGGradientDrawingOptions(rawValue: 0))
					CGContextRestoreGState(context)
				}
			}

            if let str = self.graph?.graphTextDisplay()(unit: u, totalValue: total) {
                
                let attrStr = NSAttributedString.graphAttributedString(str, color: self.config.textColor, font: self.config.textFont)
                
                let size = attrStr.size()
                
                attrStr.drawInRect(
                    CGRect(
                        origin: CGPoint(
                            x: sectionWidth * CGFloat(index) + rect.origin.x,
                            y: u.value >= U(0)
                                ? rect.size.height - height + zero - size.height - 3.0 + rect.origin.y
                                : rect.size.height + zero + height + 3.0 + rect.origin.y
                        ),
                        size: CGSize(
                            width: sectionWidth,
                            height: size.height
                        )
                    )
                )
            }
        })
    }
}