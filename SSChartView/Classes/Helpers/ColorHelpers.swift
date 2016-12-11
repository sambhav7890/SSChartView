//
//  ColorHelpers.swift
//  Pods
//
//  Created by Sambhav Shah on 17/11/16.
//
//

import UIKit

enum DefaultColorType {
	case bar, line, barText, lineText, pieText

	func color() -> UIColor {
		switch self {
		case .bar:      return UIColor(hex: "#4DC2AB")
		case .line:     return UIColor(hex: "#FF0066")
		case .barText:  return UIColor(hex: "#333333")
		case .lineText: return UIColor(hex: "#333333")
		case .pieText:  return UIColor(hex: "#FFFFFF")
		}
	}

	static func pieColors(_ count: Int) -> [UIColor] {

		func randomArray(_ arr: [Int]) -> [Int] {
			if arr.count <= 0 {
				return []
			}
			let randomIndex = Int(arc4random_uniform(UInt32(arr.count)))
			var tail = [Int]()
			for i in 0 ..< arr.count {
				if i != randomIndex {
					tail.append(arr[i])
				}
			}
			return [arr[randomIndex]] + randomArray(tail)
		}

		return Array(0 ..< count).map({ $0 }).map({ UIColor(hue: CGFloat($0) / CGFloat(count), saturation: 0.9, brightness: 0.9, alpha: 1.0) })
	}
}


public extension UIColor {

	public static func colorGradientLocations(forColors colors: [Any]) -> [CGFloat] {
		let fractionCount = colors.count - 1
		if fractionCount > 0 {
			let fraction = 1.0 / CGFloat(fractionCount)

			var colorLocations: [CGFloat] = []
			var lastColor: CGFloat = 0.0

			while lastColor <= 1.0 {
				colorLocations.append(lastColor)
				lastColor += fraction
			}

			return colorLocations
		} else {
			return [0.0]
		}
	}

	public convenience init(gray: Int = 1, _ alphaPercent: Int = 100) {
		let white = CGFloat(gray) / 255.0
		let alphaVal = CGFloat(alphaPercent) / 100.0
		self.init(white: white, alpha: alphaVal)
	}

	public convenience init(rgba: (Int,Int,Int,Float) = (0,0,0,1.0)) {
		let red = CGFloat(rgba.0) / 255.0
		let green = CGFloat(rgba.1) / 255.0
		let blue = CGFloat(rgba.2) / 255.0
		let alpha = CGFloat(rgba.3)
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}

	public convenience init(RGBInt: UInt64, alpha: Float = 1.0) {
		self.init(
			red: (((CGFloat)((RGBInt & 0xFF0000) >> 16)) / 255.0),
			green: (((CGFloat)((RGBInt & 0xFF00) >> 8)) / 255.0),
			blue: (((CGFloat)(RGBInt & 0xFF)) / 255.0),
			alpha: CGFloat(alpha)
		)
	}

	public convenience init(hex: String) {

		let prefixHex = {(str) -> String in
			for prefix in ["0x", "0X", "#"] {
				if str.hasPrefix(prefix) {
					return str.substring(from: str.characters.index(str.startIndex, offsetBy: prefix.characters.count))
				}
			}
			return str
		}(hex)


		if prefixHex.characters.count != 6 && prefixHex.characters.count != 8 {
			self.init(white: 0.0, alpha: 1.0)
			return
		}

		let scanner = Scanner(string: prefixHex)
		var hexInt: UInt64 = 0
		if !scanner.scanHexInt64(&hexInt) {
			self.init(white: 0.0, alpha: 1.0)
			return
		}

		switch prefixHex.characters.count {
		case 6:
			self.init(RGBInt: hexInt)
		case 8:
			self.init(RGBInt: hexInt >> 8, alpha: (((Float)(hexInt & 0xFF)) / 255.0))
		case _:
			self.init(white: 0.0, alpha: 1.0)
		}
	}
}
