//: Playground - noun: a place where people can play

import UIKit
import SSChartView

let str = "Hello Graphs!!"

let viewFrame = CGRect(x: 0.0, y: 0.0, width: 180.0, height: 180.0)

///* ========= Bar graph ========= */
//
//let barGraph = Graph<String, Int>(type: GraphType.bar, array: [10, 20, 4, 8, 25, 18, 21, 24, 8, 15], min: 0, max: 30)
//let barGraphView = GraphView(frame: viewFrame, graph: barGraph)
//
///// Array -> Graph
//
//let barGraphView1 = (1 ... 10).barGraph().view(viewFrame)
//
///// Set graphs range
//let range = GraphRange(min: 0, max: 12)
//let barGraphView2 = (1 ... 10).barGraph(range).view(viewFrame)
//
///// Set graphs text
//let barGraph3 = (1 ... 10).barGraph(range){(u, _) -> String? in "\(u.value)pt"}
//let barGraphView3 = barGraph3.view(viewFrame)
//
///// Set views apperances
//let v4 = barGraph3.view(viewFrame).barGraphConfiguration {
//	BarGraphViewConfig(barColor: UIColor.red)
//}
//let barGraphView4 = v4
//
//let v5 = barGraph3.view(viewFrame).barGraphConfiguration {
//	BarGraphViewConfig(
//		barColor: UIColor.yellow,
//		textColor: UIColor.darkGray,
//		textFont: UIFont.boldSystemFont(ofSize: 12.0),
//		barWidthScale: 0.5,
//		zeroLineVisible: true,
//		textVisible: true
//	)
//}
//let barGraphView5 = v5
//
///// Minus values
//let range2 = GraphRange(min: -60.0, max: 60.0)
//let v6 = [-5.0, -4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0].map { $0 * 10.0 }.barGraph(range2).view(viewFrame)
//let barGraphView6 = v6
//
///// GraphData Protocol -> Graph
//
//struct Data<T: Hashable, U: NumericType>: GraphData {
//	typealias GraphDataKey = T
//	typealias GraphDataValue = U
//
//	private let _key: T
//	private let _value: U
//
//	init(key: T, value: U) {
//		self._key = key
//		self._value = value
//	}
//
//	var key: T { get{ return self._key } }
//	var value: U { get{ return self._value } }
//}
//
//let data = [
//	Data(key: "John", value: 28.9),
//	Data(key: "Ken", value: 32.9),
//	Data(key: "Taro", value: 15.3),
//	Data(key: "Micheal", value: 22.9),
//	Data(key: "Jun", value: -12.9),
//	Data(key: "Hanako", value: 32.2),
//	Data(key: "Kent", value: 3.8)
//]
//
//let barGraph8 = data.barGraph(GraphRange(min: -20.0, max: 38.0)) { (unit, totalValue) -> String? in
//	return unit.key
//}
//
//let barGraphView8 = barGraph8.view(viewFrame)

let progress = 30

///* ========= Pie graph ========= */

let pieData = [progress, 100 - progress]

let pieGraph = pieData.pieGraph { (_, _) -> String? in
	return nil
}

let pieGraphConfig = PieGraphViewConfig(pieColors: [UIColor.blue, UIColor.clear], textColor: nil, textFont: nil, isDounut: true, contentInsets: nil)

let pieGraphView = pieGraph.view(viewFrame).pieGraphConfiguration { () -> PieGraphViewConfig in
	return pieGraphConfig
}

let finalGraphView = pieGraphView

let circularProgress = UICircularProgressView(frame: viewFrame, colors: UIColor.blue)
circularProgress.layoutSubviews()
circularProgress.roundedCorners = false

circularProgress.angle = Double(progress) * 3.6
