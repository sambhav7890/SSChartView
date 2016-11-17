//
//  GraphDataObject.swift
//  Pods
//
//  Created by Sambhav Shah on 17/11/16.
//
//

import UIKit

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
