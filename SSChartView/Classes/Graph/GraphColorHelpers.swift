//
//  GraphColorHelpers.swift
//  Pods
//
//  Created by Sambhav Shah on 17/11/16.
//
//

import UIKit

public enum GraphColorType {
	case
	mat(UIColor),
	gradation([CGColor])
}

extension UIColor {

	func matColor() -> GraphColorType {
		return .mat(self)
	}

	static func gradient(_ colors: UIColor ...) -> GraphColorType {
		if colors.count == 1 {
			return .mat(colors.first!)
		}
		let cgColors = colors.map{ $0.cgColor }
		return .gradation(cgColors)
	}

	func components() -> [CGFloat] {
		let cgColor = self.cgColor
		let components = cgColor.components
		return components ?? [0, 0, 0, 0]
	}
}


//Gradient
public enum GraphGradientState {
	case gray
	case green
}

extension GraphGradientState {
	func gradientColorsForBar() -> [UIColor] {
		switch self {
		case .gray:
			//Top->Bottom
			return [UIColor(rgba: (144,165,174,1.0)), UIColor(rgba: (176,190,197,1.0))]
		case .green:
			return [UIColor.white.withAlphaComponent(0.4)]
		}
	}

	func gradientColorsForGraph() -> [CGColor] {
		switch self {
		case .gray:
			return [UIColor(rgba: (236,239,241,1.0)), UIColor(rgba: (236,239,241,1.0))].map{$0.cgColor}
		case .green:
			return [UIColor(rgba: (120,206,125,1.0)),UIColor(rgba: (67,160,71,1.0))].map{$0.cgColor}
		}
	}
}

//Colors
extension GraphGradientState {

	private var graphTitleColorAlpha: (UIColor, CGFloat) {
		switch self {
		case .gray: return (UIColor(gray: 79), 1)
		case .green: return (UIColor.white, 1.0)
		}
	}

	private var graphSubTitleColorAlpha: (UIColor, CGFloat) {
		switch self {
		case .gray: return (UIColor.black, 0.3)
		case .green: return (UIColor.white, 0.5)
		}
	}

	private var graphLegendColorAlpha: (UIColor, CGFloat) {
		switch self {
		case .gray: return (UIColor(gray: 79), 0.3)
		case .green: return (UIColor.white, 1.0)
		}
	}

	private var graphSeparatorColorAlpha: (UIColor, CGFloat) {
		switch self {
		case .gray: return (UIColor.black, 0.1)
		case .green: return (UIColor.white, 0.1)
		}
	}

	private var graphRangeColorAlpha: (UIColor, CGFloat) {
		switch self {
		case .gray: return (UIColor(gray: 79), 0.4)
		case .green: return (UIColor.white, 0.4)
		}
	}


	enum GraphGradientStateConfigView {
		case titleLabel, subtitleLabel, legend, separator, rangeLabel
	}

	func configure(view: UIView, with type: GraphGradientStateConfigView) {

		let colorAlpha: (UIColor, CGFloat)

		switch type {
		case .titleLabel:
			colorAlpha = graphTitleColorAlpha
		case .subtitleLabel:
			colorAlpha = graphSubTitleColorAlpha
		case .legend:
			colorAlpha = graphLegendColorAlpha
		case .separator:
			colorAlpha = graphSeparatorColorAlpha
		case .rangeLabel:
			colorAlpha = graphRangeColorAlpha
		}

		if let labelView = view as? UILabel {
			labelView.textColor = colorAlpha.0
			labelView.alpha = colorAlpha.1
		} else if let legendView = view as? ExpandableLegendView {
			legendView.legendLabel.textColor = colorAlpha.0
			legendView.legendLabel.alpha = colorAlpha.1
		} else {
			view.backgroundColor = colorAlpha.0
			view.alpha = colorAlpha.1
		}
	}
}
