//
//  DataPrimitivesTests.swift
//  RSASwiftTests
//
//  Created by wuyuehyang on 2019/4/25.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import XCTest
@testable import RSASwift

class DataPrimitivesTests: XCTestCase {
    
    func testI2Osp() {
        XCTAssertThrowsError(try i2osp(x: Integer(256), xLen: 1))
        XCTAssertThrowsError(try i2osp(x: Integer(256), xLen: 2))
        
        func assertEqual(x: Int, xLen: Int, os: Data) {
            var result: Data?
            XCTAssertNoThrow(result = try i2osp(x: Integer(x), xLen: xLen))
            XCTAssertEqual(result, os)
        }
        
        assertEqual(x: 256, xLen: 3, os: Data([0, 1, 0]))
    }
    
    func testOs2Ip() {
        
        func assertEqual(os: [UInt8], i: Integer) {
            let result = os2ip(x: Data(os))
            XCTAssertEqual(result, i)
        }
        
        assertEqual(os: [1, 0], i: Integer(256))
        assertEqual(os: [0, 1, 0], i: Integer(256))
    }
    
}
