//
//  RectangleFeaturesFunnelTests.swift
//  WeScanTests
//
//  Created by Boris Emorine on 2/24/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import XCTest
@testable import WeScan

final class RectangleFeaturesFunnelTests: XCTestCase {

    var funnel = RectangleFeaturesFunnel()

    override func setUp() {
        super.setUp()
        funnel = RectangleFeaturesFunnel()
    }

    /// Ensures that feeding the funnel with less than the minimum number of rectangles doesn't trigger the completion block.
    func testAddMinUnderThreshold() {
        let rectangleFeatures = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect1, withCount: funnel.minNumberOfRectangles - 1)

        let expectation = XCTestExpectation(description: "Funnel add callback")
        expectation.isInverted = true

        for index in 0 ..< rectangleFeatures.count {
            funnel.add(rectangleFeatures[index], currentlyDisplayedRectangle: nil) { (_, _) in
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    /// Ensures that feeding the funnel with the minimum number of rectangles triggers the completion block.
    func testAddMinThreshold() {
        let rectangleFeatures = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect1, withCount: funnel.minNumberOfRectangles)

        let expectation = XCTestExpectation(description: "Funnel add callback")

        for index in 0 ..< rectangleFeatures.count {
            funnel.add(rectangleFeatures[v], currentlyDisplayedRectangle: nil) { (_, _) in
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    /// Ensures that feeding the funnel with a lot of rectangles triggers the completion block the appropriate amount of time.
    func testAddMaxThreshold() {
        let rectangleFeatures = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect1, withCount: funnel.maxNumberOfRectangles * 2)

        let expectation = XCTestExpectation(description: "Funnel add callback")
        expectation.expectedFulfillmentCount = rectangleFeatures.count - funnel.minNumberOfRectangles

        for index in 0 ..< rectangleFeatures.count {
            funnel.add(rectangleFeatures[index], currentlyDisplayedRectangle: nil) { (_, _) in
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    /// Ensures that feeding the funnel with rectangles similar to the currently displayed one doesn't trigger the completion block.
    func testAddPreviouslyDisplayedRect() {
        let rectangleFeatures = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect1, withCount: funnel.maxNumberOfRectangles * 2)

        let expectation = XCTestExpectation(description: "Funnel add callback")
        expectation.isInverted = true

        let currentlyDisplayedRect = rectangleFeatures.first!

        for index in 0 ..< rectangleFeatures.count {
            funnel.add(rectangleFeatures[index], currentlyDisplayedRectangle: currentlyDisplayedRect) { (_, _) in
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    /// Ensures that feeding the funnel with 2 images alternatively (image 1, image 2, image 1, image 2, image 1 etc.), doesn't make the completion block get called every time a new one is added.
    func testAddAlternateImage() {
        let count = 100
        let type1RectangleFeatures = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect1, withCount: count)
        let type2RectangleFeatures = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect2, withCount: count)
        var currentlyDisplayedRect: Quadrilateral?

        let expectation = XCTestExpectation(description: "Funnel add callback")
        expectation.isInverted = true

        for index in 0 ..< count {
            let rectangleFeature = index % 2 == 0 ? type1RectangleFeatures[index] : type2RectangleFeatures[index]

            funnel.add(rectangleFeature, currentlyDisplayedRectangle: currentlyDisplayedRect, completion: { (result, rectFeature) in

                currentlyDisplayedRect = rectFeature
                if index >= funnel.maxNumberOfRectangles && result == .showOnly {
                    expectation.fulfill()
                }
            })
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testAddMultipleImages() {
        let count = max(funnel.minNumberOfMatches + 2, funnel.minNumberOfRectangles)

        let rectangleFeaturesType1 = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect1, withCount: count - 1)
        let rectangleFeatureType2 = ImageFeatureTestHelpers.getRectangleFeature(from: .rect2)

        for index in 0 ..< rectangleFeaturesType1.count {
            funnel.add(rectangleFeaturesType1[index], currentlyDisplayedRectangle: nil, completion: {_, _ in
            })
        }

        let expectationType1 = XCTestExpectation(description: "Funnel add callback")

        funnel.add(rectangleFeatureType2, currentlyDisplayedRectangle: nil) { (_, rectangle) in
            XCTAssert(rectangle.isWithin(1.0, ofRectangleFeature: rectangleFeaturesType1[0]))
            expectationType1.fulfill()
        }

        wait(for: [expectationType1], timeout: 3.0)
    }

}
