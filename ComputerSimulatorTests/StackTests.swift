//
//  ComputerSimulatorTests.swift
//  ComputerSimulatorTests
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import XCTest
@testable import ComputerSimulator

class StackTests: XCTestCase {
    var stack: Stack!
    let size = 3

    override func setUp() {
        super.setUp()
        
        stack = Stack.init(size: 3)
    }
    
    override func tearDown() {
        super.tearDown()

        stack = nil
    }
    
    func testInitWithZeroSize() {
        let someStack = Stack.init(size: 0)
        
        XCTAssertEqual(someStack.size, 100, "Stack size cannot be zero.")
    }
    
    func testInitWithNegativeSize() {
        let someStack = Stack.init(size: -4)
        
        XCTAssertEqual(someStack.size, 100, "Stack size cannot be negative.")
    }
    
    func testInitWithValidSize() {
        let someStack = Stack.init(size: 50)

        XCTAssertEqual(someStack.size, 50, "Stack size is different from passed value.")
    }
    
    func testStackInitialValues() {
        for index in 0..<size {
            let item = stack.peek(at: index)
            XCTAssertNil(item, "Default value of stack items must be nil")
        }
    }
    
    func testPushWithArgument() {
        let stackItem: (String, Int?) = ("PUSH", 6)
        
        stack.push(stackItem)
        
        let pushedItem = stack.peek(at: size)
        XCTAssertEqual(pushedItem?.0, stackItem.0, "Last item in the stack is different from pushed item.")
        XCTAssertEqual(pushedItem?.1, stackItem.1, "Last item in the stack is different from pushed item.")
    }
    
    func testPushWithNilArgument() {
        let stackItem: (String, Int?) = ("RET", nil)

        stack.push(stackItem)
        
        let pushedItem = stack.peek(at: size)
        XCTAssertEqual(pushedItem?.0, stackItem.0, "Last item in the stack is different from pushed item.")
        XCTAssertNil(pushedItem?.1, "Last item in the stack is different from pushed item.")
    }
    
    func testPop() {
        let stackItem: (String, Int?) = ("CALL", 50)
        
        stack.push(stackItem)
        let poppedItem = stack.pop()

        XCTAssertNotNil(poppedItem!, "Last item in the stack is nil.")
        XCTAssertEqual(poppedItem!?.0, stackItem.0, "Last item in the stack is different from pushed item.")
        XCTAssertEqual(poppedItem!?.1, stackItem.1, "Last item in the stack is different from pushed item.")
    }
    
    func testInsertAtStartIndex() {
        let item: (String, Int?) = ("STOP", nil)
        let validIndex = 0
        
        let result = stack.insert(item, at: validIndex)
        if case .Success(_) = result {
            let insertedItem = stack.peek(at: validIndex)
            XCTAssertEqual(insertedItem?.0, item.0, "Item at index is different from inserted item.")
            XCTAssertEqual(insertedItem?.1, item.1, "Item at index is different from inserted item.")
        }
    }
    
    func testInsertAtEndIndex() {
        let item: (String, Int?) = ("STOP", nil)
        let validIndex = size-1

        let result = stack.insert(item, at: validIndex)
        if case .Success(_) = result {
            let insertedItem = stack.peek(at: validIndex)
            XCTAssertEqual(insertedItem?.0, item.0, "Item at index is different from inserted item.")
            XCTAssertEqual(insertedItem?.1, item.1, "Item at index is different from inserted item.")
        }
        else {
            XCTFail("Result.Success was expected.")
        }
    }
    
    func testInsertAtInvalidIndex() {
        let item: (String, Int?) = ("STOP", nil)
        let invalidIndex = size

        let result = stack.insert(item, at: invalidIndex)
        if case let .Failure(message) = result {
            XCTAssertEqual(message, Errors.PcOutOfBounds, "Stack should return Failure PcOutOfBounds error when an invalid index is given.")
        }
    }
    
    func testPeek() {
        let item: (String, Int?) = ("PUSH", 6)
        if case .Success(_) = stack.insert(item, at: 1) {
            let peekedItem = stack.peek(at: 1)
            
            XCTAssertEqual(item.0, peekedItem?.0, "Item at given index is different from inserted item.")
            XCTAssertEqual(item.1, peekedItem?.1, "Item at given index is different from inserted item.")
        }
        else {
            XCTFail("Expected to insert stack item successfully.")
        }
    }
    
    func testPeekDefaultItem() {
        let item = stack.peek(at: 0)
        
        XCTAssertNil(item, "Expected a nil item for default stack configuration")
    }

    func testPeekAtInvalidIndex() {
        let item = stack.peek(at: size)
        
        XCTAssertNil(item, "Expected a nil item for invalid index")
    }
}
