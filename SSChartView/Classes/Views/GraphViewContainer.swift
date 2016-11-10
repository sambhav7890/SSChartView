//
//  GraphViewContainer.swift
//  Pods
//
//  Created by Sambhav Shah on 03/09/16.
//  Copyright © 2016 S. All rights reserved.
//

import UIKit

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

open class GraphViewContainer: UIView {


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

	//Separators
	@IBOutlet weak var topGraphSeparator: UIView!
	@IBOutlet weak var bottomGraphSeparator: UIView!


	//Bottom Legend
	@IBOutlet var bottomView: UIView!
	@IBOutlet var legendScroller: UIScrollView!
	@IBOutlet var legendScrollContentView: UIView!

	@IBOutlet var gradientView: UIView!
	var gradientLayer = CAGradientLayer()

	public var graphState: GraphGradientState = .gray

	func updateConfigsForState() {

		//Background Gradient
		let colors = self.graphState.gradientColorsForGraph()

		gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
		gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

		gradientLayer.locations = UIColor.colorGradientLocations(forColors: colors).map { (gradLocation) in
			return NSNumber(value: Double(gradLocation))
		}

		gradientLayer.colors = colors

		//Graph Bars
		self.updateBarGraphConfig()

		//Legend Labels
		self.legendCells.forEach { (view) in
			self.graphState.configure(view: view, with: .legend)
		}

		//TitleLabels
		self.graphState.configure(view: self.titleLabel, with: .titleLabel)
		self.graphState.configure(view: self.averageTitleLabel, with: .titleLabel)

		//SubtitleLabels
		self.graphState.configure(view: self.subtitleLabel, with: .subtitleLabel)
		self.graphState.configure(view: self.averageSubtitleLabel, with: .subtitleLabel)

		//RangeLabels
		self.graphState.configure(view: self.maxLabel, with: .rangeLabel)
		self.graphState.configure(view: self.minLabel, with: .rangeLabel)

		//Separators
		self.graphState.configure(view: self.topGraphSeparator, with: .separator)
		self.graphState.configure(view: self.bottomGraphSeparator, with: .separator)

	}

	open override func layoutSubviews() {
		super.layoutSubviews()
		gradientLayer.frame = self.gradientView.bounds
	}

	open override func awakeFromNib() {
		super.awakeFromNib()
		resetCells()
		resetGraph()
		gradientLayer.frame = self.gradientView.bounds
		defer { self.graphState = .gray }
		guard let superlayer = gradientLayer.superlayer else {
			self.gradientView.layer.addSublayer(gradientLayer)
			return
		}
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
	internal var graphView: GraphView<Int,Double>?

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
			self.graphState.configure(view: legendView.legendLabel, with: .legend)

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

		graphView.translatesAutoresizingMaskIntoConstraints = false

		self.graphView = graphView
		graphView.addAsConstrainedSubview(forContainer: graphScrollContentView)
		updateConfigsForState()
	}

	func updateBarGraphConfig() {

		let _ = self.graphView?.barGraphConfiguration { () -> BarGraphViewConfig in
			var config = BarGraphViewConfig()

			let colors = self.graphState.gradientColorsForBar()

			if let firstColor = colors.first, colors.count == 1 {
				config.barColor = firstColor.matColor()
			} else {
				config.barColor = GraphColorType.gradation(colors.map{$0.cgColor})
			}

			config.roundedCorners = true
			config.textVisible = false

			config.barWidthScale = 0.2
			config.actualBarWidth = 4.0 // 8px bars

			return config
		}
		self.setNeedsLayout()
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
