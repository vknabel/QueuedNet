import XCTest
@testable import QueuedNet
import QueuedNetTests

var tests = [XCTestCaseEntry]()
tests += QueuedNetTests.allTests()
XCTMain(tests)
