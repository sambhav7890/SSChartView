//
//  GraphsExtensions.swift
//  Graphs
//
//  Created by Sambhav Shah on 2016/09/02.
//  Copyright © 2016 S. All rights reserved.
//

import UIKit

/**
 GraphData protocols array can make 'Graph' object.
 */

public protocol GraphData {

    associatedtype GraphDataKey: Hashable
    associatedtype GraphDataValue: NumericType

    var key: GraphDataKey { get }
    var value: GraphDataValue { get }
}

/**
 SequenceType<S: GraphData> -> 'Graph' object
 */

extension Sequence where Iterator.Element: GraphData {

	typealias GraphDataKey = Iterator.Element.GraphDataKey
	typealias GraphDataValue = Iterator.Element.GraphDataValue

	public func barGraph(
		_ range: GraphRange<GraphDataValue>? = nil,
		textDisplayHandler: Graph<GraphDataKey, GraphDataValue>.GraphTextDisplayHandler? = nil
		) -> Graph<Iterator.Element.GraphDataKey, Iterator.Element.GraphDataValue> {

		return Graph<GraphDataKey, GraphDataValue>(type: .bar, data: self.map { $0 }, range: range, textDisplayHandler: textDisplayHandler)
	}

//	public func lineGraph(
//		_ range: GraphRange<GraphDataValue>? = nil,
//		textDisplayHandler: Graph<GraphDataKey, GraphDataValue>.GraphTextDisplayHandler? = nil
//		) -> Graph<Iterator.Element.GraphDataKey, Iterator.Element.GraphDataValue> {
//
//		return Graph<GraphDataKey, GraphDataValue>(type: .line, data: self.map { $0 }, range: range, textDisplayHandler: textDisplayHandler)
//	}

//	public func pieGraph(
//		_ textDisplayHandler: Graph<GraphDataKey, GraphDataValue>.GraphTextDisplayHandler? = nil
//		) -> Graph<Iterator.Element.GraphDataKey, Iterator.Element.GraphDataValue> {
//
//		return Graph<GraphDataKey, GraphDataValue>(type: .pie, data: self.map { $0 }, range: nil, textDisplayHandler: textDisplayHandler)
//	}
}

/**
 SequenceType<S: NumericType> -> 'Graph' object
 */

extension Sequence where Iterator.Element: NumericType {

	public func barGraph(
		_ range: GraphRange<Iterator.Element>? = nil,
		textDisplayHandler: Graph<String, Iterator.Element>.GraphTextDisplayHandler? = nil
		) -> Graph<String, Iterator.Element> {

		return Graph<String, Iterator.Element>(type: .bar, array: self.map { $0 }, range: range, textDisplayHandler: textDisplayHandler)
	}

//	public func lineGraph(
//		_ range: GraphRange<Iterator.Element>? = nil,
//		textDisplayHandler: Graph<String, Iterator.Element>.GraphTextDisplayHandler? = nil
//		) -> Graph<String, Iterator.Element> {
//
//		return Graph<String, Iterator.Element>(type: .line, array: self.map { $0 }, range: range, textDisplayHandler: textDisplayHandler)
//	}

//	public func pieGraph(
//		_ textDisplayHandler: Graph<String, Iterator.Element>.GraphTextDisplayHandler? = nil
//		) -> Graph<String, Iterator.Element> {
//
//		return Graph<String, Iterator.Element>(type: .pie, array: self.map { $0 }, range: nil, textDisplayHandler: textDisplayHandler)
//	}

}

/**
 Dictionary -> 'Graph' object
 */

extension Collection where Self: ExpressibleByDictionaryLiteral, Self.Key: Hashable, Self.Value: NumericType, Iterator.Element == (Self.Key, Self.Value) {

	typealias aKey = Self.Key
	typealias aValue = Self.Value

	public func barGraph(
		_ range: GraphRange<aValue>? = nil,
		sort: (((Self.Key, Self.Value), (Self.Key, Self.Value)) -> Bool)? = nil,
		textDisplayHandler: Graph<aKey, aValue>.GraphTextDisplayHandler? = nil
		) -> Graph<aKey, aValue> {

		return Graph<aKey, aValue>(type: .bar, dictionary: dict(), range: range, textDisplayHandler: textDisplayHandler)
	}

//	public func lineGraph(
//		_ range: GraphRange<aValue>? = nil,
//		sort: (((Self.Key, Self.Value), (Self.Key, Self.Value)) -> Bool)? = nil,
//		textDisplayHandler: Graph<aKey, aValue>.GraphTextDisplayHandler? = nil
//		) -> Graph<aKey, aValue> {
//
//		return Graph<aKey, aValue>(type: .line, dictionary: dict(), range: range, textDisplayHandler: textDisplayHandler)
//	}

//	public func pieGraph(
//		_ range: GraphRange<aValue>? = nil,
//		sort: (((Self.Key, Self.Value), (Self.Key, Self.Value)) -> Bool)? = nil,
//		textDisplayHandler: Graph<aKey, aValue>.GraphTextDisplayHandler? = nil
//		) -> Graph<aKey, aValue> {
//
//		return Graph<aKey, aValue>(type: .pie, dictionary: dict(), range: nil, textDisplayHandler: textDisplayHandler)
//	}

	func dict() -> [aKey: aValue] {
		var d = [aKey: aValue]()
		for kv in self {
			d[kv.0] = kv.1
		}
		return d
	}

	func touples() -> [(aKey, aValue)] {
		var d = [(aKey, aValue)]()
		for kv in self {
			d.append((kv.0, kv.1))
		}
		return d
	}

}

extension Array {
    var match : (head: Element, tail: [Element])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}

public extension UIEdgeInsets {

	public init(all: CGFloat) {
		self.left = all
		self.right = self.left
		self.top = self.left
		self.bottom = self.left
	}

	public init(horizontal: CGFloat, vertical: CGFloat) {
		self.left = horizontal
		self.right = self.left
		self.top = vertical
		self.bottom = self.top
	}

	public func verticalMarginsTotal() -> CGFloat {
		return self.top + self.bottom
	}

	public func horizontalMarginsTotal() -> CGFloat {
		return self.left + self.right
	}
}

extension NSAttributedString {

	class func graphAttributedString(_ string: String, color: UIColor, font: UIFont) -> NSAttributedString {
		let paragraph = NSMutableParagraphStyle()
		paragraph.alignment = .center

		return NSAttributedString(string: string, attributes: [
			NSForegroundColorAttributeName: color,
			NSFontAttributeName: font,
			NSParagraphStyleAttributeName: paragraph
			])
	}
}
