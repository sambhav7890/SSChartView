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
    mat(UIColor),
    gradation(UIColor, UIColor)
}

extension UIColor {
    
    func matColor() -> GraphColorType {
        return .mat(self)
    }

	static func gradient(_ color1: UIColor, color2: UIColor) -> GraphColorType {
		return .gradation(color1, color2)
	}

	func components() -> [CGFloat] {
		let cgColor = self.cgColor
		let components = cgColor.components
		return components ?? [0, 0, 0, 0]
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
        self.barColor = (barColor ?? DefaultColorType.bar.color()).matColor()
        self.textColor = textColor ?? DefaultColorType.barText.color()
        self.textFont = textFont ?? UIFont.systemFont(ofSize: 10.0)
        self.barWidthScale = barWidthScale ?? 0.8
        self.zeroLineVisible = zeroLineVisible ?? true
        self.textVisible = textVisible ?? true
        self.contentInsets = contentInsets ?? UIEdgeInsets.zero
    }
}


internal class BarGraphView<T: Hashable, U: NumericType>: UIView {

    
    internal var graph: BarGraph<T, U>?
    
    fileprivate var config = BarGraphViewConfig()
    
    init(frame: CGRect, graph: BarGraph<T, U>?) {
        
        self.graph = graph
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.setNeedsDisplay()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBarGraphViewConfig(_ config: BarGraphViewConfig?) {
        
        self.config = config ?? BarGraphViewConfig()
        self.setNeedsDisplay()
    }
    
    fileprivate func graphFrame() -> CGRect {
        return CGRect(
            x: self.config.contentInsets.left,
            y: self.config.contentInsets.top,
            width: self.frame.size.width - self.config.contentInsets.horizontalMarginsTotal(),
            height: self.frame.size.height - self.config.contentInsets.verticalMarginsTotal()
        )
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let graph = self.graph else { return }
        
        let total = graph.units.map{ $0.value }.reduce(U(0)){ $0 + $1 }
        let rect = self.graphFrame()
        let min = graph.range.min
        let max = graph.range.max
        
        let sectionWidth = rect.size.width / CGFloat(graph.units.count)
        let width = sectionWidth * self.config.barWidthScale
        
        let zero = rect.size.height / CGFloat((max - min).floatValue()) * CGFloat(min.floatValue())

        graph.units.enumerated().forEach({ (index, u) in

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
			case let .mat(color):
				color.setFill()
				path.fill()
			case let .gradation(color1, color2):
				let colors = [color1.cgColor, color2.cgColor]
				let colorSpace = CGColorSpaceCreateDeviceRGB()
				let colorLocations:[CGFloat] = [0.0, 1.0]
				if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations) {
					let context = UIGraphicsGetCurrentContext()
					context?.saveGState()
					context?.addPath(path.cgPath)
					context?.clip()
					context?.drawLinearGradient(gradient, start: bezierRect.origin, end: bezierRect.ending, options: CGGradientDrawingOptions(rawValue: 0))
					context?.restoreGState()
				}
			}

            if let str = self.graph?.graphTextDisplay()(u, total) {
                
                let attrStr = NSAttributedString.graphAttributedString(str, color: self.config.textColor, font: self.config.textFont)
                
                let size = attrStr.size()
                
                attrStr.draw(
                    in: CGRect(
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
