//
//  BundleHelper.swift
//  Pods
//
//  Created by Sambhav Shah on 17/11/16.
//
//

import UIKit

internal extension Bundle {
	static func graphBundle() -> Bundle? {
		let podBundle = Bundle(for: ExpandableLegendView.self)
		guard let bundleURL = podBundle.url(forResource: "SSChartView", withExtension: "bundle") else { return nil }
		guard let bundle = Bundle(url: bundleURL) else { return nil }
		return bundle
	}
}


public extension UIView {
	public func addAsConstrainedSubview(forContainer view: UIView) {
		let child = self
		let container = view
		container.addSubview(child)

		// align graph from the left and right
		container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": child]));

		// align graph from the top and bottom
		container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": child]));
	}
	
}
