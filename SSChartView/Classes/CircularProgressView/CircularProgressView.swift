//
//  CircularProgressView.swift
//  Test
//
//  Created by Sambhav Shah on 01/09/16.
//  Copyright © 2016 S. All rights reserved.
//

/*

progress.startAngle = -90
progress.progressThickness = 0.2
progress.trackThickness = 0.2
progress.trackColor = UIColor.clearColor()
progress.clockwise = true
progress.gradientRotateSpeed = 0
progress.roundedCorners = true
progress.glowMode = .NoGlow
progress.glowAmount = 0.0
progress.setColors(UIColor.cyanColor())

let final = Double(self.slider.value)
progress.animateToAngle(final, duration: 1)

*/

import UIKit

private let AngleAnimationKey: String = "angle"

public enum UICircularProgressGlowMode {
	case forward, reverse, constant, noGlow
}

@IBDesignable
open class UICircularProgressView: UIView {

	//================
	// MARK: - Public Variables

	//Current Angle
	@IBInspectable open var angle: Double = 0 {
		didSet {
			if self.isAnimating() {
				self.pauseAnimation()
			}
			progressLayer.angle = angle
		}
	}

	//Starts from top at -90,
	// setting this to 0 will start it at right edge
	@IBInspectable open var startAngle: Double = -90 {
		didSet {
			startAngle = Utility.mod(startAngle, range: 360, minMax: (0, 360))
			progressLayer.startAngle = startAngle
			progressLayer.setNeedsDisplay()
		}
	}

	//Fill is clockwise/anticlockwise
	@IBInspectable open var clockwise: Bool = true {
		didSet {
			progressLayer.clockwise = clockwise
			progressLayer.setNeedsDisplay()
		}
	}

	@IBInspectable open var roundedCorners: Bool = true {
		didSet {
			progressLayer.roundedCorners = roundedCorners
		}
	}

	//Color Blending
	@IBInspectable open var lerpColorMode: Bool = false {
		didSet {
			progressLayer.lerpColorMode = lerpColorMode
		}
	}

	//Movement On Gradients
	@IBInspectable open var gradientRotateSpeed: CGFloat = 0 {
		didSet {
			progressLayer.gradientRotateSpeed = gradientRotateSpeed
		}
	}

	//Glow around Circular Track
	@IBInspectable open var glowAmount: CGFloat = 0.0 {//Between 0 and 1
		didSet {
			glowAmount = Utility.clamp(glowAmount, minMax: (0, 1))
			progressLayer.glowAmount = glowAmount
		}
	}

	//Glow direction
	@IBInspectable open var glowMode: UICircularProgressGlowMode = .noGlow {
		didSet {
			progressLayer.glowMode = glowMode
		}
	}

	// inner ring Thickness
	@IBInspectable open var progressThickness: CGFloat = 0.4 {//Between 0 and 1
		didSet {
			progressThickness = Utility.clamp(progressThickness, minMax: (0, 1))
			progressLayer.progressThickness = progressThickness/2
		}
	}

	// Outer ring Thickness
	@IBInspectable open var trackThickness: CGFloat = 0.5 {//Between 0 and 1
		didSet {
			trackThickness = Utility.clamp(trackThickness, minMax: (0, 1))
			progressLayer.trackThickness = trackThickness/2
		}
	}

	//Outer Ring Background
	@IBInspectable open var trackColor: UIColor = .black {
		didSet {
			progressLayer.trackColor = trackColor
			progressLayer.setNeedsDisplay()
		}
	}

	//Percent Text Color
	@IBInspectable open var textColor: UIColor? {
		didSet {
			progressLayer.textColor = textColor
			progressLayer.setNeedsDisplay()
		}
	}
	//Percent Text Color
	@IBInspectable open var font: UIFont? {
		didSet {
			progressLayer.font = font
			progressLayer.setNeedsDisplay()
		}
	}

	//Central Circle Fill
	@IBInspectable open var progressInsideFillColor: UIColor? = nil {
		didSet {
			if let color = progressInsideFillColor {
				progressLayer.progressInsideFillColor = color
			} else {
				progressLayer.progressInsideFillColor = .clear
			}
		}
	}

	//Inner Ring Gradient Color Array
	@IBInspectable open var progressColors: [UIColor]! {
		get {
			return progressLayer.colorsArray
		}

		set(newValue) {
			setColors(newValue)
		}
	}

	//These are used only from the Interface-Builder. Changing these from code will have no effect.
	//Also IB colors are limited to 3, whereas programatically we can have an arbitrary number of them.
	@objc @IBInspectable fileprivate var PresetGradientColor1: UIColor?
	@objc @IBInspectable fileprivate var PresetGradientColor2: UIColor?
	@objc @IBInspectable fileprivate var PresetGradientColor3: UIColor?

	//================
	// MARK: - Private Variables

	fileprivate var progressLayer: UICircularProgressViewLayer {
		return layer as! UICircularProgressViewLayer
	}

	fileprivate var radius: CGFloat! {
		didSet {
			progressLayer.radius = radius
		}
	}

	fileprivate var animationCompletionBlock: ((Bool) -> Void)?

	//================
	// MARK: - Public Initializers

	override public init(frame: CGRect) {
		super.init(frame: frame)
		isUserInteractionEnabled = false
		setInitialValues()
		refreshValues()
		checkAndSetIBColors()
	}

	convenience public init(frame: CGRect, colors: UIColor...) {
		self.init(frame: frame)
		setColors(colors)
	}

	required public init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
		translatesAutoresizingMaskIntoConstraints = false
		isUserInteractionEnabled = false
		setInitialValues()
		refreshValues()
	}

	//================
	// MARK: - Public Layout Methods

	open override func awakeFromNib() {
		checkAndSetIBColors()
	}

	override open class var layerClass: AnyClass {
		return UICircularProgressViewLayer.self
	}

	open override func layoutSubviews() {
		super.layoutSubviews()

		//We always apply a 20% padding, stopping glows from being clipped
		let radiusFactor: CGFloat = self.glowMode != .noGlow ? 0.8 : 1.0
		radius = (frame.size.width/2.0) * radiusFactor
	}

	open override func didMoveToWindow() {
		if let window = window {
			progressLayer.contentsScale = window.screen.scale
		}
	}

	open override func willMove(toSuperview newSuperview: UIView?) {
		if newSuperview == nil && isAnimating() {
			pauseAnimation()
		}
	}

	open override func prepareForInterfaceBuilder() {
		setInitialValues()
		refreshValues()
		checkAndSetIBColors()
		progressLayer.setNeedsDisplay()
	}

	//================
	// MARK: - Public Methods

	open func setColors(_ colors: UIColor...) {
		setColors(colors)
	}

	open func animateFromAngle(_ fromAngle: Double, toAngle: Double, duration: TimeInterval, relativeDuration: Bool = true, completion: ((Bool) -> Void)?) {
		if isAnimating() {
			pauseAnimation()
		}

		let animationDuration: TimeInterval
		if !relativeDuration { // Absolute animation time
			animationDuration = duration
		} else { // Scale Duration with angle delta
			let traveledAngle = Utility.mod(toAngle - fromAngle, range: 360, minMax: (0, 360))
			let scaledDuration = (TimeInterval(traveledAngle) * duration) / 360
			animationDuration = scaledDuration
		}

		let animation = CABasicAnimation(keyPath: AngleAnimationKey)
		animation.fromValue = fromAngle
		animation.toValue = toAngle
		animation.duration = animationDuration
		animation.delegate = self
		angle = toAngle
		animationCompletionBlock = completion

		progressLayer.add(animation, forKey: AngleAnimationKey)
	}

	open func animateToAngle(_ toAngle: Double, duration: TimeInterval, relativeDuration: Bool = true, completion: ((Bool) -> Void)? = nil) {
		if isAnimating() {
			pauseAnimation()
		}
		animateFromAngle(angle, toAngle: toAngle, duration: duration, relativeDuration: relativeDuration, completion: completion)
	}

	open func pauseAnimation() {
		guard let presentationLayer = progressLayer.presentation() else { return }
		let currentValue = presentationLayer.angle
		progressLayer.removeAllAnimations()
		animationCompletionBlock = nil
		angle = currentValue
	}

	open func stopAnimation() {
		animationCompletionBlock = nil
		progressLayer.removeAllAnimations()
		angle = 0
	}

	open func isAnimating() -> Bool {
		return progressLayer.animation(forKey: AngleAnimationKey) != nil
	}

	//================
	// MARK: - Private Setup Methods

	fileprivate func setInitialValues() {
		//We always apply a 20% padding, stopping glows from being clipped
		let radiusFactor: CGFloat = self.glowMode != .noGlow ? 0.8 : 1.0
		radius = (frame.size.width/2.0) * radiusFactor
		backgroundColor = .clear
		setColors(.white, .cyan)
	}

	fileprivate func refreshValues() {
		progressLayer.angle = angle
		progressLayer.startAngle = startAngle
		progressLayer.clockwise = clockwise
		progressLayer.roundedCorners = roundedCorners
		progressLayer.lerpColorMode = lerpColorMode
		progressLayer.gradientRotateSpeed = gradientRotateSpeed
		progressLayer.glowAmount = glowAmount
		progressLayer.glowMode = glowMode
		progressLayer.progressThickness = progressThickness/2
		progressLayer.trackColor = trackColor
		progressLayer.trackThickness = trackThickness/2
	}

	fileprivate func checkAndSetIBColors() {
		let nonNilColors = [PresetGradientColor1, PresetGradientColor2, PresetGradientColor3].flatMap { $0 }
		if !nonNilColors.isEmpty {
			setColors(nonNilColors)
		}
	}

	fileprivate func setColors(_ colors: [UIColor]) {
		progressLayer.colorsArray = colors
		progressLayer.setNeedsDisplay()
	}

	fileprivate class UICircularProgressViewLayer: CALayer {
		@NSManaged var angle: Double
		var radius: CGFloat! {
			didSet {
				invalidateGradientCache()
			}
		}

		var formatBlock: ((Double) -> String) = { angle in
			var formatString: String = "%.f%%"
			let fixedAngle = angle <= 0 ? 0 : angle >= 360 ? 100 : angle/3.6
			return String(format: formatString, fixedAngle)
		}

		var startAngle: Double!
		var clockwise: Bool! {
			didSet {
				if clockwise != oldValue {
					invalidateGradientCache()
				}
			}
		}
		var roundedCorners: Bool!
		var lerpColorMode: Bool!
		var gradientRotateSpeed: CGFloat! {
			didSet {
				invalidateGradientCache()
			}
		}
		var glowAmount: CGFloat!
		var glowMode: UICircularProgressGlowMode!
		var progressThickness: CGFloat!
		var trackThickness: CGFloat!
		var trackColor: UIColor!
		var progressInsideFillColor: UIColor = UIColor.clear
		var colorsArray: [UIColor]! {
			didSet {
				invalidateGradientCache()
			}
		}
		var font: UIFont?
		var textColor: UIColor?
		fileprivate var gradientCache: CGGradient?
		fileprivate var locationsCache: [CGFloat]?

		fileprivate struct GlowConstants {
			fileprivate static let sizeToGlowRatio: CGFloat = 0.00015
			static func glowAmountForAngle(_ angle: Double, glowAmount: CGFloat, glowMode: UICircularProgressGlowMode, size: CGFloat) -> CGFloat {
				switch glowMode {
				case .forward:
					return CGFloat(angle) * size * sizeToGlowRatio * glowAmount
				case .reverse:
					return CGFloat(360 - angle) * size * sizeToGlowRatio * glowAmount
				case .constant:
					return 360 * size * sizeToGlowRatio * glowAmount
				default:
					return 0
				}
			}
		}

		override class func needsDisplay(forKey key: String) -> Bool {
			return key == AngleAnimationKey ? true : super.needsDisplay(forKey: key)
		}

		override init(layer: Any) {
			super.init(layer: layer)
			let progressLayer = layer as! UICircularProgressViewLayer
			radius = progressLayer.radius
			angle = progressLayer.angle
			startAngle = progressLayer.startAngle
			clockwise = progressLayer.clockwise
			roundedCorners = progressLayer.roundedCorners
			lerpColorMode = progressLayer.lerpColorMode
			gradientRotateSpeed = progressLayer.gradientRotateSpeed
			glowAmount = progressLayer.glowAmount
			glowMode = progressLayer.glowMode
			progressThickness = progressLayer.progressThickness
			trackThickness = progressLayer.trackThickness
			trackColor = progressLayer.trackColor
			colorsArray = progressLayer.colorsArray
			progressInsideFillColor = progressLayer.progressInsideFillColor
			textColor = progressLayer.textColor
			font = progressLayer.font
		}

		override init() {
			super.init()
		}

		required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
		}

		override func draw(in ctx: CGContext) {
			UIGraphicsPushContext(ctx)

			let size = bounds.size

			let reducedAngle = Utility.mod(angle, range: 360, minMax: (0, 360))
			let fromAngle = Conversion.degreesToRadians(CGFloat(-startAngle))
			let toAngle = Conversion.degreesToRadians(CGFloat((clockwise == true ? -reducedAngle : reducedAngle) - startAngle))

			//Draw Text
			self.drawText(size, context: ctx)

			//Draw Stroke
			self.drawBackground(size, reducedAngle: reducedAngle, fromAngle: fromAngle, toAngle: toAngle, context: ctx)

			//Gradient - Fill
			self.drawFill(reducedAngle, context: ctx)

			ctx.restoreGState()
			UIGraphicsPopContext()
		}

		func drawFill(_ reducedAngle: Double, context ctx: CGContext) {
			if !lerpColorMode && colorsArray.count > 1 {
				drawGradient(ctx)
			} else {
				fillSingleColor(reducedAngle, context: ctx)
			}
		}

		func fillSingleColor(_ reducedAngle: Double, context ctx: CGContext) {
			var color: UIColor?
			if colorsArray.isEmpty {
				color = UIColor.white
			} else if colorsArray.count == 1 {
				color = colorsArray[0]
			} else {
				// lerpColorMode is true
				let t = CGFloat(reducedAngle) / 360
				let steps = colorsArray.count - 1
				let step = 1 / CGFloat(steps)
				for i in 1...steps {
					let fi = CGFloat(i)
					if (t <= fi * step || i == steps) {
						let colorT = Utility.inverseLerp(t, minMax: ((fi - 1) * step, fi * step))
						color = Utility.colorLerp(colorT, minMax: (colorsArray[i - 1], colorsArray[i]))
						break
					}
				}
			}

			if let color = color {
				fillRectWithContext(ctx, color: color)
			}
		}

		func drawGradient(_ ctx: CGContext) {
			let rgbColorsArray: [UIColor] = colorsArray.map { color in // Make sure every color in colors array is in RGB color space
				if color.cgColor.numberOfComponents == 2 {
					let whiteValue = color.cgColor.components?[0]
					return UIColor(red: whiteValue!, green: whiteValue!, blue: whiteValue!, alpha: 1.0)
				} else {
					return color
				}
			}

			let componentsArray = rgbColorsArray.flatMap { color -> [CGFloat] in
				guard let components = color.cgColor.components else { return [0, 0, 0, 0] }
				return [components[0], components[1], components[2], 1.0]
			}

			drawGradientWithContext(ctx, componentsArray: componentsArray)
		}

		func drawBackground(_ size: CGSize, reducedAngle: Double, fromAngle: CGFloat, toAngle: CGFloat, context ctx: CGContext) {
			let width = size.width
			let height = size.height

			let trackLineWidth = radius * trackThickness
			let progressLineWidth = radius * progressThickness
			let arcRadius = max(radius - trackLineWidth/2, radius - progressLineWidth/2)

			let center = CGPoint(x: width/2, y: height/2)
			ctx.addArc(center: center, radius: arcRadius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: false)

			trackColor.set()

			ctx.setStrokeColor(trackColor.cgColor)
			ctx.setFillColor(progressInsideFillColor.cgColor)

			ctx.setLineWidth(trackLineWidth)
			ctx.setLineCap(CGLineCap.butt)
			ctx.drawPath(using: .fillStroke)

			UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

			let imageCtx = UIGraphicsGetCurrentContext()

			imageCtx?.addArc(center: center, radius: arcRadius, startAngle: fromAngle, endAngle: toAngle, clockwise: clockwise)

			let glowValue = GlowConstants.glowAmountForAngle(reducedAngle, glowAmount: glowAmount, glowMode: glowMode, size: width)

			if glowValue > 0 {
				imageCtx?.setShadow(offset: CGSize.zero, blur: glowValue, color: UIColor.black.cgColor)
			}

			imageCtx?.setLineCap(roundedCorners == true ? .round : .butt)
			imageCtx?.setLineWidth(progressLineWidth)
			imageCtx?.drawPath(using: .stroke)

			let drawMask: CGImage = UIGraphicsGetCurrentContext()!.makeImage()!
			UIGraphicsEndImageContext()

			ctx.saveGState()
			ctx.clip(to: bounds, mask: drawMask)
		}

		func drawText(_ size: CGSize, context ctx: CGContext) {
			let textStyle = NSMutableParagraphStyle()
			textStyle.alignment = .left
			let valueFontSize: CGFloat = size.height / 5
			let font = self.font ?? UIFont.systemFont(ofSize: valueFontSize)

			let color = self.textColor ?? self.colorsArray.first ?? UIColor.black
			let valueFontAttributes = [NSFontAttributeName: font,
			                           NSForegroundColorAttributeName: color,
			                           NSParagraphStyleAttributeName: textStyle]

			let text = NSMutableAttributedString()

			let textToPresent = formatBlock(angle)
			let value = NSAttributedString(string: textToPresent, attributes: valueFontAttributes)
			text.append(value)
			// set the decimal font size

			let percentSize = text.size()
			let textCenter = CGPoint(x: size.width / 2 - percentSize.width / 2, y: size.height / 2 - percentSize.height / 2)
			text.draw(at: textCenter)
		}

		fileprivate func fillRectWithContext(_ ctx: CGContext!, color: UIColor) {
			ctx.setFillColor(color.cgColor)
			ctx.fill(bounds)
		}

		fileprivate func drawGradientWithContext(_ ctx: CGContext!, componentsArray: [CGFloat]) {
			let baseSpace = CGColorSpaceCreateDeviceRGB()
			let locations = locationsCache ?? gradientLocationsForColorCount(componentsArray.count/4, gradientWidth: bounds.size.width)
			let gradient: CGGradient

			if let cachedGradient = gradientCache {
				gradient = cachedGradient
			} else {
				guard let cachedGradient = CGGradient(colorSpace: baseSpace, colorComponents: componentsArray, locations: locations, count: componentsArray.count / 4) else {
					return
				}

				gradientCache = cachedGradient
				gradient = cachedGradient
			}

			let halfX = bounds.size.width / 2.0
			let floatPi = CGFloat(M_PI)
			let rotateSpeed = clockwise == true ? gradientRotateSpeed : gradientRotateSpeed * -1
			let angleInRadians = Conversion.degreesToRadians(rotateSpeed! * CGFloat(angle) - 90)
			let oppositeAngle = angleInRadians > floatPi ? angleInRadians - floatPi : angleInRadians + floatPi

			let startPoint = CGPoint(x: (cos(angleInRadians) * halfX) + halfX, y: (sin(angleInRadians) * halfX) + halfX)
			let endPoint = CGPoint(x: (cos(oppositeAngle) * halfX) + halfX, y: (sin(oppositeAngle) * halfX) + halfX)

			ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
		}

		fileprivate func gradientLocationsForColorCount(_ colorCount: Int, gradientWidth: CGFloat) -> [CGFloat] {
			if colorCount == 0 || gradientWidth == 0 {
				return []
			} else {
				let progressLineWidth = radius * progressThickness
				let firstPoint = gradientWidth/2 - (radius - progressLineWidth/2)
				let increment = (gradientWidth - (2*firstPoint))/CGFloat(colorCount - 1)

				let locationsArray = (0..<colorCount).map { firstPoint + (CGFloat($0) * increment) }
				let result = locationsArray.map { $0 / gradientWidth }
				locationsCache = result
				return result
			}
		}

		fileprivate func invalidateGradientCache() {
			gradientCache = nil
			locationsCache = nil
		}
	}
}

extension UICircularProgressView {
	fileprivate struct Conversion {
		static func degreesToRadians (_ value: CGFloat) -> CGFloat {
			return value * CGFloat(M_PI) / 180.0
		}

		static func radiansToDegrees (_ value: CGFloat) -> CGFloat {
			return value * 180.0 / CGFloat(M_PI)
		}
	}

	fileprivate struct Utility {
		static func clamp<T: Comparable>(_ value: T, minMax: (T, T)) -> T {
			let (min, max) = minMax
			if value < min {
				return min
			} else if value > max {
				return max
			} else {
				return value
			}
		}

		static func inverseLerp(_ value: CGFloat, minMax: (CGFloat, CGFloat)) -> CGFloat {
			return (value - minMax.0) / (minMax.1 - minMax.0)
		}

		static func lerp(_ value: CGFloat, minMax: (CGFloat, CGFloat)) -> CGFloat {
			return (minMax.1 - minMax.0) * value + minMax.0
		}

		static func colorLerp(_ value: CGFloat, minMax: (UIColor, UIColor)) -> UIColor {
			let clampedValue = clamp(value, minMax: (0, 1))

			let zero: CGFloat = 0

			var (r0, g0, b0, a0) = (zero, zero, zero, zero)
			minMax.0.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)

			var (r1, g1, b1, a1) = (zero, zero, zero, zero)
			minMax.1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)

			return UIColor(red: lerp(clampedValue, minMax: (r0, r1)), green: lerp(clampedValue, minMax: (g0, g1)), blue: lerp(clampedValue, minMax: (b0, b1)), alpha: lerp(clampedValue, minMax: (a0, a1)))
		}

		static func mod(_ value: Double, range: Double, minMax: (Double, Double)) -> Double {
			let (min, max) = minMax
			assert(abs(range) <= abs(max - min), "range should be <= than the interval")
			if value >= min && value <= max {
				return value
			} else if value < min {
				return mod(value + range, range: range, minMax: minMax)
			} else {
				return mod(value - range, range: range, minMax: minMax)
			}
		}
	}
}

extension UICircularProgressView: CAAnimationDelegate {
//	optional public func animationDidStart(_ anim: CAAnimation)
	public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if let completionBlock = animationCompletionBlock {
			if flag {
				animationCompletionBlock = nil
			}

			completionBlock(flag)
		}
	}
}
