//
//  NumericHelpers.swift
//  Pods
//
//  Created by Sambhav Shah on 17/11/16.
//
//

import UIKit

public protocol NumericType: Equatable, Comparable {
	static func + (lhs: Self, rhs: Self) -> Self
	static func - (lhs: Self, rhs: Self) -> Self
	static func * (lhs: Self, rhs: Self) -> Self
	static func / (lhs: Self, rhs: Self) -> Self
	static func % (lhs: Self, rhs: Self) -> Self
	init()
	init(_ v: Int)
}

extension NumericType {

	func floatValue() -> Float {
		if let n = self as? Int {
			return Float(n)
		}
		if let n = self as? Float {
			return Float(n)
		}
		if let n = self as? Double {
			return Float(n)
		}
		return 0.0
	}

	static func zero<T: NumericType>() -> T {
		return T(0)
	}
}

extension Double : NumericType { }
extension Float  : NumericType { }
extension Int    : NumericType { }
extension Int8   : NumericType { }
extension Int16  : NumericType { }
extension Int32  : NumericType { }
extension Int64  : NumericType { }
extension UInt   : NumericType { }
extension UInt8  : NumericType { }
extension UInt16 : NumericType { }
extension UInt32 : NumericType { }
extension UInt64 : NumericType { }
