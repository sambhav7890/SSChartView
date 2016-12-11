//
//  DebugViewController.swift
//  SSChartView
//
//  Created by Sambhav Shah on 11/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SSChartView

class DebugViewController: UIViewController {


	@IBOutlet weak var graphContainer: UIView!

	override func viewDidLoad() {
		super.viewDidLoad()
		config()
	}

	func config() {

		let percentFilled: Int = 75
		let color = UIColor.blue

		let data = [percentFilled, (100-percentFilled)]

		let pieGraph = data.pieGraph({ (graphUnit, value) -> String? in return nil })

		let config = PieGraphViewConfig(pieColors: [color, UIColor.clear], isDounut: true)

		let view = pieGraph.view(graphContainer.bounds).pieGraphConfiguration({ () -> PieGraphViewConfig in
			return config
		})

		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		graphContainer.addSubview(view)
	}



}
