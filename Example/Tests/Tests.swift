import UIKit
import XCTest
import SSChartView

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

	func testExampleCreateCircularProgress() {
		// This is an example of a functional test case.
		let progress = UICircularProgressView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
		print(" Start ----- > " + "\(NSDate())")
		let originalAngle = 0.0
		progress.angle = originalAngle
		let progressPresent = expectation(description: "Circular Progress")

		progress.animateToAngle(120, duration: 2.0)

		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
			print(" Start + 3 ----- > " + "\(NSDate())")
			XCTAssert(progress.angle == 120, "Angle properly moved")
			progressPresent.fulfill()
			print(" Finish + 3 ----- > " + "\(NSDate())")
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			print(" Start + 0.1 ----- > " + "\(NSDate())")
			XCTAssert(progress.angle != originalAngle, "Angle not changing")
		}

		waitForExpectations(timeout: 5.0) { (error) in
			print(" Start + 5 ----- > " + "\(NSDate())")
			XCTAssertNil(error, "Not finished in 5 secs!")
		}
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
