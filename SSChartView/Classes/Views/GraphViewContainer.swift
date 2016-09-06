//
//  GraphViewContainer.swift
//  Pods
//
//  Created by Sambhav Shah on 03/09/16.
//  Copyright © 2016 S. All rights reserved.
//

import UIKit

public class GraphViewContainer: UIView {

	static var TopGradientColor = UIColor(rgba: (144,165,174,1.0))
	static var BottomGradientColor = UIColor(rgba: (176,190,197,1.0))

	//TopView
	@IBOutlet var topView: UIView!

	@IBOutlet public var titleLabel: UILabel!
	@IBOutlet public var subtitleLabel: UILabel!

	@IBOutlet public var averageSubtitleLabel: UILabel!
	@IBOutlet public var averageTitleLabel: UILabel!

	//GraphOverlay
	@IBOutlet var graphOverlay: UIView!
	@IBOutlet public var maxLabel: UILabel!
	@IBOutlet public var minLabel: UILabel!

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


	public override func awakeFromNib() {
		resetCells()
		resetGraph()
	}

	public static func create(inView: UIView? = nil) -> GraphViewContainer? {
		guard let bundle = NSBundle.graphBundle() else { return nil }
		guard let nib = bundle.loadNibNamed("GraphViewContainer", owner: nil, options: nil) else { return nil }
		guard let container = nib.first as? GraphViewContainer else { return nil }

		if let view = inView {
			container.addConstraints(view)
		}
		return container
	}

	private func addConstraints(view: UIView) {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.addAsConstrainedSubview(forContainer: view)
	}

	public func setupWithData(data: [(String, Double)]) {
		let dataSet = data.flatMap { GraphDataObject(data: $0) }
		resetCells()
		generateCells(dataSet)
		resetGraph()
		generateGraph(dataSet)
	}


	public private (set) var legendCells: [ExpandableLegendView] = []
	internal var graphView: BarGraphView<String,Double>?

	public func resetCells() {
		self.legendScrollContentView.subviews.forEach { $0.removeFromSuperview() }
		self.legendScroller.scrollEnabled = false
		self.legendScroller.userInteractionEnabled = false
		self.legendCells = []
	}

	public func resetGraph() {
		graphScroller.scrollEnabled = false
		graphScroller.userInteractionEnabled = false
		graphScrollContentView.subviews.forEach { $0.removeFromSuperview() }
	}
}

extension GraphViewContainer {

	func generateCells(data: [GraphDataObject]) {

		let total = self.bounds.size.width
		let each = total/CGFloat(data.count)

		let legendSize = CGSize(width: each, height: bottomView.bounds.size.height)

		var firstView: UIView?

		for (index, aData) in data.enumerate() {
			let currentOrigin = CGPoint(x: (each * CGFloat(index)), y: 0)
			let legendFrame = CGRect(origin: currentOrigin, size: legendSize)
			guard let legendView = ExpandableLegendView.create() else { continue }
			legendView.frame = legendFrame

			let key = aData.key
			legendView.legendLabel.text = key

			legendScrollContentView.addSubview(legendView)

			let bottomConstraint = NSLayoutConstraint(item: legendView, attribute: .Top, relatedBy: .Equal, toItem: legendScrollContentView, attribute: .Top, multiplier: 1, constant: 0)
			legendScrollContentView.addConstraint(bottomConstraint)

			let topConstraint = NSLayoutConstraint(item: legendView, attribute: .Bottom, relatedBy: .Equal, toItem: legendScrollContentView, attribute: .Bottom, multiplier: 1, constant: 0)
			legendScrollContentView.addConstraint(topConstraint)

			if let firstView = firstView {
				
				let leftSpaceConstraint = NSLayoutConstraint(item: legendView, attribute: .Left, relatedBy: .Equal, toItem: firstView, attribute: .Right, multiplier: 1, constant: 0)
				legendScrollContentView.addConstraint(leftSpaceConstraint)

				let equalWidthConstraint = NSLayoutConstraint(item: legendView, attribute: .Width, relatedBy: .Equal, toItem: firstView, attribute: .Width, multiplier: 1, constant: 0)
				legendScrollContentView.addConstraint(equalWidthConstraint)


			} else {
				let leftSpaceConstraint = NSLayoutConstraint(item: legendView, attribute: .Left, relatedBy: .Equal, toItem: legendScrollContentView, attribute: .Left, multiplier: 1, constant: 0)
				legendScrollContentView.addConstraint(leftSpaceConstraint)
			}

			firstView = legendView
			legendCells.append(legendView)
		}

		if let firstView = firstView {
			let rightSpaceConstraint = NSLayoutConstraint(item: firstView, attribute: .Right, relatedBy: .Equal, toItem: legendScrollContentView, attribute: .Right, multiplier: 1, constant: 0)
			legendScrollContentView.addConstraint(rightSpaceConstraint)
		}
	}

	func generateGraph(data: [GraphDataObject]) {

		let range = GraphRange(min: 0.0, max: 100.0)

		let graph = data.barGraph(range) { (unit, totalValue) -> String? in return "" }

		let graphView = graph.view(graphScrollContentView.bounds)

		graphView.barGraphConfiguration { () -> BarGraphViewConfig in
			var config = BarGraphViewConfig()

			let color1 = GraphViewContainer.TopGradientColor
			let color2 = GraphViewContainer.BottomGradientColor

			config.barColor = GraphColorType.Gradation(color2 ,color1)

			config.textVisible = false
			config.barWidthScale = 1

			return config
		}

		graphView.translatesAutoresizingMaskIntoConstraints = false
		self.graphView = graphView as? BarGraphView<String,Double>
		graphView.addAsConstrainedSubview(forContainer: graphScrollContentView)
	}
}

struct GraphDataObject: GraphData {
	var key: String
	var value: Double

	init(data: (String, Double)) {
		self.key = data.0
		self.value = data.1
	}
}

public class ExpandableLegendView: UIView {

	@IBOutlet public var legendLabel: UILabel!

	static func create() -> ExpandableLegendView? {
		guard let bundle = NSBundle.graphBundle() else { return nil }
		guard let nib = bundle.loadNibNamed("ExpandableLegendView", owner: nil, options: nil) else { return nil }
		guard let container = nib.first as? ExpandableLegendView else { return nil }
		container.translatesAutoresizingMaskIntoConstraints = false
		return container
	}
}

internal extension NSBundle {
	static func graphBundle() -> NSBundle? {
		let podBundle = NSBundle(forClass: ExpandableLegendView.self)
		guard let bundleURL = podBundle.URLForResource("PractoBarChart", withExtension: "bundle") else { return nil }
		guard let bundle = NSBundle(URL: bundleURL) else { return nil }
		return bundle
	}
}


public extension UIView {
	public func addAsConstrainedSubview(forContainer view: UIView) {
		let child = self
		let container = view
		container.addSubview(child)

		// align graph from the left and right
		container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": child]));

		// align graph from the top and bottom
		container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": child]));
	}

}