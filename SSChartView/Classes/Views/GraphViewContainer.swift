//
//  GraphViewContainer.swift
//  Pods
//
//  Created by Sambhav Shah on 03/09/16.
//  Copyright © 2016 S. All rights reserved.
//

import UIKit

open class GraphViewContainer: UIView {

	static var TopGradientColor = UIColor(rgba: (144,165,174,1.0))
	static var BottomGradientColor = UIColor(rgba: (176,190,197,1.0))

	//TopView
	@IBOutlet var topView: UIView!

	@IBOutlet open var titleLabel: UILabel!
	@IBOutlet open var subtitleLabel: UILabel!

	@IBOutlet open var averageSubtitleLabel: UILabel!
	@IBOutlet open var averageTitleLabel: UILabel!

	//GraphOverlay
	@IBOutlet var graphOverlay: UIView!
	@IBOutlet open var maxLabel: UILabel!
	@IBOutlet open var minLabel: UILabel!

	//GraphView
	@IBOutlet var graphHolder: UIView!
	@IBOutlet var graphScroller: UIScrollView!
	@IBOutlet var graphScrollContentView: UIView!

	@IBOutlet var graphContentWidthConstraint: NSLayoutConstraint!
	@IBOutlet var graphContentHeightConstraint: NSLayoutConstraint!

	//Bottom Legend
	@IBOutlet var bottomView: UIView!
	@IBOutlet var legendScroller: UIScrollView!
	@IBOutlet var legendScrollContentView: UIView!


	open override func awakeFromNib() {
		resetCells()
		resetGraph()
	}

	open static func create(_ inView: UIView? = nil) -> GraphViewContainer? {
		guard let bundle = Bundle.graphBundle() else { return nil }
		guard let nib = bundle.loadNibNamed("GraphViewContainer", owner: nil, options: nil) else { return nil }
		guard let container = nib.first as? GraphViewContainer else { return nil }

		if let view = inView {
			container.addConstraints(view)
		}
		return container
	}

	fileprivate func addConstraints(_ view: UIView) {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.addAsConstrainedSubview(forContainer: view)
	}

	open func setup(data values: [Double] = [], keys: [String] = []) {
		resetCells()
		generateCells(keys)
		resetGraph()
		let graphData = GraphDataObject.generate(fromValues: values)
		generateGraph(graphData)
	}


	open fileprivate (set) var legendCells: [ExpandableLegendView] = []
	internal var graphView: BarGraphView<Int,Double>?

	open func resetCells() {
		self.legendScrollContentView.subviews.forEach { $0.removeFromSuperview() }
		self.legendScroller.isScrollEnabled = false
		self.legendScroller.isUserInteractionEnabled = false
		self.legendCells = []
	}

	open func resetGraph() {
		graphScroller.isScrollEnabled = false
		graphScroller.isUserInteractionEnabled = false
		graphScrollContentView.subviews.forEach { $0.removeFromSuperview() }
	}
}

extension GraphViewContainer {

	func generateCells(_ data: [String]) {

		let total = self.bounds.size.width
		let each = total/CGFloat(data.count)

		let legendSize = CGSize(width: each, height: bottomView.bounds.size.height)

		var firstView: UIView?

		for (index, aData) in data.enumerated() {
			let currentOrigin = CGPoint(x: (each * CGFloat(index)), y: 0)
			let legendFrame = CGRect(origin: currentOrigin, size: legendSize)
			guard let legendView = ExpandableLegendView.create() else { continue }
			legendView.frame = legendFrame

			let key = aData
			legendView.legendLabel.text = key

			legendScrollContentView.addSubview(legendView)

			let bottomConstraint = NSLayoutConstraint(item: legendView, attribute: .top, relatedBy: .equal, toItem: legendScrollContentView, attribute: .top, multiplier: 1, constant: 0)
			legendScrollContentView.addConstraint(bottomConstraint)

			let topConstraint = NSLayoutConstraint(item: legendView, attribute: .bottom, relatedBy: .equal, toItem: legendScrollContentView, attribute: .bottom, multiplier: 1, constant: 0)
			legendScrollContentView.addConstraint(topConstraint)

			if let firstView = firstView {
				
				let leftSpaceConstraint = NSLayoutConstraint(item: legendView, attribute: .left, relatedBy: .equal, toItem: firstView, attribute: .right, multiplier: 1, constant: 0)
				legendScrollContentView.addConstraint(leftSpaceConstraint)

				let equalWidthConstraint = NSLayoutConstraint(item: legendView, attribute: .width, relatedBy: .equal, toItem: firstView, attribute: .width, multiplier: 1, constant: 0)
				legendScrollContentView.addConstraint(equalWidthConstraint)


			} else {
				let leftSpaceConstraint = NSLayoutConstraint(item: legendView, attribute: .left, relatedBy: .equal, toItem: legendScrollContentView, attribute: .left, multiplier: 1, constant: 0)
				legendScrollContentView.addConstraint(leftSpaceConstraint)
			}

			firstView = legendView
			legendCells.append(legendView)
		}

		if let firstView = firstView {
			let rightSpaceConstraint = NSLayoutConstraint(item: firstView, attribute: .right, relatedBy: .equal, toItem: legendScrollContentView, attribute: .right, multiplier: 1, constant: 0)
			legendScrollContentView.addConstraint(rightSpaceConstraint)
		}
	}

	func generateGraph(_ data: [GraphDataObject]) {

		let range = GraphRange(min: 0.0, max: 100.0)

		let graph = data.barGraph(range) { (unit, totalValue) -> String? in return "" }

		let graphView = graph.view(graphScrollContentView.bounds)

		let _ = graphView.barGraphConfiguration { () -> BarGraphViewConfig in
			var config = BarGraphViewConfig()

			let color1 = GraphViewContainer.TopGradientColor
			let color2 = GraphViewContainer.BottomGradientColor

			config.barColor = GraphColorType.gradation(color2 ,color1)

			config.textVisible = false
			config.barWidthScale = 1

			return config
		}

		graphView.translatesAutoresizingMaskIntoConstraints = false
		self.graphView = graphView as? BarGraphView<Int,Double>
		graphView.addAsConstrainedSubview(forContainer: graphScrollContentView)
	}
}

struct GraphDataObject: GraphData {
	var key: Int
	var value: Double

	init(data: (Int, Double)) {
		self.key = data.0
		self.value = data.1
	}

	static func generate(fromValues values: [Double]) -> [GraphDataObject] {
		var data = [GraphDataObject]()

		for (index, val) in values.enumerated() {
			let graphDataObj = GraphDataObject(data: (index, val))
			data.append(graphDataObj)
		}

		return data
	}
}

open class ExpandableLegendView: UIView {

	@IBOutlet open var legendLabel: UILabel!

	static func create() -> ExpandableLegendView? {
		guard let bundle = Bundle.graphBundle() else { return nil }
		guard let nib = bundle.loadNibNamed("ExpandableLegendView", owner: nil, options: nil) else { return nil }
		guard let container = nib.first as? ExpandableLegendView else { return nil }
		container.translatesAutoresizingMaskIntoConstraints = false
		return container
	}
}

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
