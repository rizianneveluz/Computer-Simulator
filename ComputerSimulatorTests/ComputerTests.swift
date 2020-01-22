//
//  ComputerTests.swift
//  ComputerSimulatorTests
//
//  Created by Rizianne Veluz on 31/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import XCTest
@testable import ComputerSimulator

class ComputerTests: XCTestCase {
    var computer: Computer!
    let stackSize = 10
    
    override func setUp() {
        computer = Computer.new(size: stackSize)
    }

    override func tearDown() {
        computer = nil
    }
    
    func testInitialAddress() {
        XCTAssertEqual(computer.programCounter, 0, "Expected program counter to be initially at 0.")
    }

    func testSetAddress() {
        if case .Success(_) = computer.set_address(5) {
            XCTAssertEqual(computer.programCounter, 5)
        }
        else {
            XCTFail("Expected program counter to be equal to passed address.")
        }
    }
    
    func testSetNegativeAddress() {
        if case let .Failure(message) = computer.set_address(-2) {
            XCTAssertEqual(message, Errors.PcOutOfBounds, "Computer should return Failure PcOutOfBounds when program counter is set to an invalid address.")
        }
        else {
            XCTFail("Computer should return Failure PcOutOfBounds when program counter is set to an invalid address.")
        }
    }
    
    func testSetInvalidAddress() {
        if case let .Failure(message) = computer.set_address(stackSize) {
            XCTAssertEqual(message, Errors.PcOutOfBounds, "Expected Computer to return Failure PcOutOfBounds when program counter is set to an invalid address.")
        }
        else {
            XCTFail("Expected Computer to return Failure PcOutOfBounds when program counter is set to an invalid address.")
        }
    }
    
    func testMult() {
        let factor1 = 6, factor2 = 2
        let _ = computer.insert(instruction: "PUSH", argument: factor1)
        let _ = computer.insert(instruction: "PUSH", argument: factor2)
        let _ = computer.insert(instruction: "MULT", argument: nil)
        let _ = computer.insert(instruction: "STOP", argument: nil)
        let _ = computer.set_address(0)

        if case let .Success(product) = computer.execute() {
            XCTAssertEqual(product, factor1*factor2, "Expected product is \(factor1) * \(factor2) instead of \(product!).")
        }
        else {
            XCTFail("Expected MULT to be successfully executed using two latest values in the stack.")
        }
    }

    func testMultNotEnoughArguments() {
        let factor = 6
        let _ = computer.insert(instruction: "PUSH", argument: factor)
        let _ = computer.insert(instruction: "MULT", argument: nil)
        let _ = computer.insert(instruction: "STOP", argument: nil)
        let _ = computer.set_address(0)

        if case let .Failure(message) = computer.execute() {
            XCTAssertEqual(message, Errors.InvalidArgumentMult, "Expected MULT to return Failure InvalidArgumentMult when there are less than 2 items to be popped from the stack.")
        }
        else {
            XCTFail("Expected MULT to return Failure InvalidArgumentMult when there are less than 2 items to be popped from the stack.")
        }
    }

    func testMultInvalidArgument() {
        let factor = 6
        let _ = computer.set_address(stackSize-1)
        let _ = computer.insert(instruction: "CALL", argument: 2)
        let _ = computer.set_address(0)
        let _ = computer.insert(instruction: "PUSH", argument: factor)
        let _ = computer.insert(instruction: "MULT", argument: nil)
        let _ = computer.insert(instruction: "STOP", argument: nil)
        let _ = computer.set_address(0)

        if case let .Failure(message) = computer.execute() {
            XCTAssertEqual(message, Errors.InvalidArgumentMult,"Expected MULT to return Failure InvalidArgumentMult when any of the latest two items in the stack are not integers.")
        }
        else {
            XCTFail("Expected MULT to return Failure InvalidArgumentMult when any of the latest two items in the stack are not integers.")
        }
    }
    
    func testCall() {
        let address = 5
        let _ = computer.set_address(address)
        let _ = computer.insert(instruction: "STOP", argument: nil)
        let _ = computer.set_address(0)
        let _ = computer.insert(instruction: "CALL", argument: address)
        let _ = computer.set_address(0)
        let _ = computer.execute()
        
        XCTAssertEqual(computer.programCounter, address, "Expected program counter to be equal to passed addressed.")
    }
    
    func testCallInvalidAddress() {
        let address = 50
        let oldAddress = computer.programCounter
        
        if case let .Failure(message) = computer.set_address(address) {
            XCTAssertEqual(message, Errors.PcOutOfBounds)
            XCTAssertEqual(oldAddress, computer.programCounter, "Program counter should not increment when CALL fails to execute.")
        }
        else {
            XCTFail("Expected CALL to return Failure PcOutOfBounds when address is invalid.")
        }
    }
    
    func testCallNegativeAddress() {
        let address = -2
        let oldAddress = computer.programCounter
        
        if case let .Failure(message) = computer.set_address(address) {
            XCTAssertEqual(message, Errors.PcOutOfBounds)
            XCTAssertEqual(oldAddress, computer.programCounter, "Program counter should not increment when CALL fails to execute.")
        }
        else {
            XCTFail("Expected CALL to return Failure PcOutOfBounds when address is invalid.")
        }
    }
    
    func testReturn() {
        let address = 2
        let _ = computer.insert(instruction: "PUSH", argument: address)
        let _ = computer.insert(instruction: "CALL", argument: 6)
        let _ = computer.insert(instruction: "STOP", argument: nil)
        let _ = computer.set_address(6)
        let _ = computer.insert(instruction: "RET", argument: nil)
        let _ = computer.set_address(0)
        let _ = computer.execute()
        
        XCTAssertEqual(computer.programCounter, address, "Expected address to be equal to argument of RET instruction")
    }
    
    func testReturnInvalidArgument() {
        let _ = computer.insert(instruction: "RET", argument: nil)
        let _ = computer.insert(instruction: "STOP", argument: nil)
        let _ = computer.set_address(0)

        if case let .Failure(message) = computer.execute() {
            XCTAssertEqual(message, Errors.InvalidArgumentRetInt, "Expected RET to return Failure InvalidArgumentRetInt when address is nil or invalid.")
        }
        else {
            XCTFail("Expected RET to return Failure InvalidArgumentRetInt when address is nil or invalid.")
        }
    }
    
    func testReturnInvalidAddress() {
        let _ = computer.insert(instruction: "PUSH", argument: stackSize)
        let _ = computer.insert(instruction: "RET", argument: nil)
        let _ = computer.insert(instruction: "STOP", argument: nil)
        let _ = computer.set_address(0)
        
        if case let .Failure(message) = computer.execute() {
            XCTAssertEqual(message, Errors.InvalidArgumentRetAddress, "Expected RET to return Failure InvalidArgumentRetAddress when address is out of bounds.")
        }
        else {
            XCTFail("Expected RET to return Failure InvalidArgumentRetAddress when address is out of bounds.")
        }
    }
    
    func testPrint() {
        let _ = computer.insert(instruction: "PUSH", argument: 6)
        let _ = computer.insert(instruction: "PRINT", argument: nil)
        let _ = computer.insert(instruction: "STOP", argument: nil)
        let _ = computer.set_address(0)
        
        if case let .Success(value) = computer.execute() {
            XCTAssertEqual(value!, 6, "Expected return value to be equal the pushed argument.")
        }
        else {
            XCTFail("Expected return value to be equal the pushed argument.")
        }
    }
    
    func testPrintNilArgument() {
        let _ = computer.insert(instruction: "PRINT", argument: nil)
        let _ = computer.insert(instruction: "STOP", argument: nil)
        let _ = computer.set_address(0)
        
        if case let .Failure(message) = computer.execute() {
            XCTAssertEqual(message, Errors.InvalidArgumentPrint, "Expected PRINT to return Failure InvalidArgumentPrint when address is argument is nil.")
        }
        else {
            XCTFail("Expected PRINT to return Failure InvalidArgumentPrint when address is argument is nil.")
        }
    }
    
    func testPrintInvalidArgument() {
        let _ = computer.set_address(stackSize-1)
        let _ = computer.insert(instruction: "CALL", argument: 50)
        let _ = computer.set_address(0)
        let _ = computer.insert(instruction: "PRINT", argument: nil)
        let _ = computer.insert(instruction: "STOP", argument: nil)
        let _ = computer.set_address(0)
        
        if case let .Failure(message) = computer.execute() {
            XCTAssertEqual(message, Errors.InvalidArgumentPrint, "Expected PRINT to return Failure InvalidArgumentPrint when address is argument is invalid.")
        }
        else {
            XCTFail("Expected PRINT to return Failure InvalidArgumentPrint when address is argument is invalid.")
        }
    }
    
    func testPush() {
        let pushedNumber = 50
        let _ = computer.insert(instruction: "PUSH", argument: pushedNumber)
        let _ = computer.insert(instruction: "PRINT", argument: nil)
        let _ = computer.insert(instruction: "STOP", argument: nil)
        let _ = computer.set_address(0)
        
        if case let .Success(value) = computer.execute() {
            XCTAssertEqual(value!, pushedNumber, "Expected to retrieve the same value as the pushed number.")
        }
        else {
            XCTFail("Expected to retrieve the same value as the pushed number.")
        }
    }
    
    func testInsertMultExtraArgument() {
        let result = computer.insert(instruction: "MULT", argument: 5)
        
        if case .Success(_) = result {
            XCTAssertEqual(computer.programCounter, 1, "Expected to be able to successfully insert. Extra arguments should be ignored.")
        }
        else {
            XCTFail("Expected to be able to successfully insert. Extra arguments should be ignored.")
        }
    }
    
    func testInsertRetExtraArgument() {
        let result = computer.insert(instruction: "RET", argument: 5)
        
        if case .Success(_) = result {
            XCTAssertEqual(computer.programCounter, 1, "Expected to be able to successfully insert. Extra arguments should be ignored.")
        }
        else {
            XCTFail("Expected to be able to successfully insert. Extra arguments should be ignored.")
        }
    }
    
    func testInsertStopExtraArgument() {
        let result = computer.insert(instruction: "STOP", argument: 5)
        
        if case .Success(_) = result {
            XCTAssertEqual(computer.programCounter, 1, "Expected to be able to successfully insert. Extra arguments should be ignored.")
        }
        else {
            XCTFail("Expected to be able to successfully insert. Extra arguments should be ignored.")
        }
    }
    
    func testInsertPrintExtraArgument() {
        let result = computer.insert(instruction: "PRINT", argument: 5)
        
        if case .Success(_) = result {
            XCTAssertEqual(computer.programCounter, 1, "Expected to be able to successfully insert. Extra arguments should be ignored.")
        }
        else {
            XCTFail("Expected to be able to successfully insert. Extra arguments should be ignored.")
        }
    }
    
    func testInsertCallInvalidArgument() {
        let result = computer.insert(instruction: "CALL", argument: nil)
        
        if case let .Failure(message) = result {
            XCTAssertEqual(message, Errors.InvalidArgument, "Expected insert to return Failure InvalidArgument when a nil argument is passed.")
            
        }
        else {
            XCTFail("Expected insert to return Failure InvalidArgument when a nil argument is passed.")
        }
    }
    
    func testInsertPushInvalidArgument() {
        let result = computer.insert(instruction: "PUSH", argument: nil)
        
        if case let .Failure(message) = result {
            XCTAssertEqual(message, Errors.InvalidArgument, "Expected insert to return Failure InvalidArgument when a nil argument is passed.")
            
        }
        else {
            XCTFail("Expected insert to return Failure InvalidArgument when a nil argument is passed.")
        }
    }
    
    func testInsertInvalidInstruction() {
        let result = computer.insert(instruction: "TEST", argument: nil)

        if case let .Failure(message) = result {
            XCTAssertEqual(message, Errors.InvalidInstruction, "Expected to insert to return Failure InvalidInstruction when passed a value outside of the supported instructions.")
        }
        else {
            XCTFail("Expected to insert to return Failure InvalidInstruction when passed a value outside of the supported instructions.")
        }
    }
}
