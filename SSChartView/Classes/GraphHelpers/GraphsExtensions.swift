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

extension SequenceType where Generator.Element: GraphData {
    
    typealias GraphDataKey = Generator.Element.GraphDataKey
    typealias GraphDataValue = Generator.Element.GraphDataValue
    
    public func barGraph(
        range: GraphRange<GraphDataValue>? = nil,
        textDisplayHandler: Graph<GraphDataKey, GraphDataValue>.GraphTextDisplayHandler? = nil
    ) -> Graph<Generator.Element.GraphDataKey, Generator.Element.GraphDataValue> {
        
        return Graph<GraphDataKey, GraphDataValue>(type: .Bar, data: self.map{ $0 }, range: range, textDisplayHandler: textDisplayHandler)
    }
}


/**
 SequenceType<S: NumericType> -> 'Graph' object
 */

extension SequenceType where Generator.Element: NumericType {
    
    public func barGraph(
        range: GraphRange<Generator.Element>? = nil,
        textDisplayHandler: Graph<String, Generator.Element>.GraphTextDisplayHandler? = nil
    ) -> Graph<String, Generator.Element> {
        
        return Graph<String, Generator.Element>(type: .Bar, array: self.map{ $0 }, range: range, textDisplayHandler: textDisplayHandler)
    }

}


/**
 Dictionary -> 'Graph' object
 */

extension CollectionType where Self: DictionaryLiteralConvertible, Self.Key: Hashable, Self.Value: NumericType, Generator.Element == (Self.Key, Self.Value) {
    
    
    typealias aKey = Self.Key
    typealias aValue = Self.Value
    
    public func barGraph(
        range: GraphRange<aValue>? = nil,
        sort: (((Self.Key, Self.Value), (Self.Key, Self.Value)) -> Bool)? = nil,
        textDisplayHandler: Graph<aKey, aValue>.GraphTextDisplayHandler? = nil
    ) -> Graph<aKey, aValue> {
        
        return Graph<aKey, aValue>(type: .Bar, dictionary: dict(), range: range, textDisplayHandler: textDisplayHandler)
    }

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
        return (count > 0) ? (self[0],Array(self[1..<count])) : nil
    }
}

enum DefaultColorType {
    case Bar, BarText
    
    func color() -> UIColor {
        switch self {
        case .Bar:      return UIColor(hex: "#4DC2AB")
        case .BarText:  return UIColor(hex: "#333333")
        }
    }
}

public extension UIColor {

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
                    return str.substringFromIndex(str.startIndex.advancedBy(prefix.characters.count))
                }
            }
            return str
        }(hex)
        
        
        if prefixHex.characters.count != 6 && prefixHex.characters.count != 8 {
            self.init(white: 0.0, alpha: 1.0)
            return
        }
        
        let scanner = NSScanner(string: prefixHex)
        var hexInt: UInt64 = 0
        if !scanner.scanHexLongLong(&hexInt) {
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

public extension UIEdgeInsets {

    public func verticalMarginsTotal() -> CGFloat {
        return self.top + self.bottom
    }
    
    public func horizontalMarginsTotal() -> CGFloat {
        return self.left + self.right
    }
}

extension NSAttributedString {
    
    class func graphAttributedString(string: String, color: UIColor, font: UIFont) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .Center
        
        return NSAttributedString(string: string, attributes: [
            NSForegroundColorAttributeName:color,
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraph
        ])
    }
}



