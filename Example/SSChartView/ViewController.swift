//
//  ViewController.swift
//  SSChartView
//
//  Created by Sambhav Shah on 09/06/2016.
//  Copyright (c) 2016 Sambhav Shah. All rights reserved.
//

import UIKit
import SSChartView

class ViewController: UIViewController {

	@IBOutlet weak var graphContainer: UIView!

	var graphParent :GraphGenParent?



	override func viewDidLoad() {
        super.viewDidLoad()
		self.view.layoutIfNeeded()
        // Do any additional setup after loading the view, typically from a nib.

		self.initialize()
    }

	func initialize() {
		graphParent = GraphGenParent(parent: self.graphContainer)
	}

	@IBAction func checkTapped(_ sender: AnyObject) {
		graphParent?.config()
	}
}



class GraphGenParent {

	init(parent view: UIView) {
		let circle = UICircularProgressView(frame: view.bounds)
		circle.addAsConstrainedSubview(forContainer: view)
		self.circle = circle

		self.configure()
	}

	var circle: UICircularProgressView

	func config() {
		let randomAngle = arc4random_uniform(360)
		let randomDoubleAngle = Double(randomAngle)
		self.circle.animateToAngle(randomDoubleAngle, duration: 0.3, relativeDuration: false)
	}

	func configure() {
		self.circle.clockwise = true
		self.circle.roundedCorners = false
		let circleColor = UIColor(rgba: (30, 170, 241, 1.0))
		circle.progressColors = [circleColor]

		circle.trackColor = UIColor.clear
		circle.textColor = UIColor.black
	}


}

