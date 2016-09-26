//
//  QueuedNetTests.swift
//  QueuedNetTests
//
//  Created by Valentin Knabel on 02.03.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

import XCTest

protocol LinuxTestCase {
    associatedtype TestCase: XCTestCase
    static var allTests: [(String, (TestCase) -> () -> ())] { get }
}

#if os(Linux)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(QueuedNetTests.allTests)
        ]
    }
#endif


class QueuedNetTests: XCTestCase, LinuxTestCase {

    static var allTests = []
    
}
