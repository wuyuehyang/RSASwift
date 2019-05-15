//
//  IntegerTests.swift
//  RSASwiftTests
//
//  Created by wuyuehyang on 2019/4/14.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import XCTest
@testable import RSASwift

class IntegerTests: XCTestCase {
    
    func testInitWithBinaryInteger() {
        
        func assertEqual<T>(value: T, bytes: [UInt8]) where T: BinaryInteger {
            let int = Integer(value)
            XCTAssertEqual(int.bytes, bytes)
        }
        
        assertEqual(value: 0, bytes: [])
        assertEqual(value: 1, bytes: [1])
        assertEqual(value: 255, bytes: [255])
        assertEqual(value: 256, bytes: [0, 1])
    }
    
    func testAdditiveArithmetic() {
        XCTAssertEqual(Integer(1) + Integer(1), Integer(2))
        XCTAssertEqual(Integer(255) + Integer(1), Integer(256))
        XCTAssertEqual(Integer(1) - Integer(1), Integer(0))
        XCTAssertEqual(Integer(256) - Integer(1), Integer(255))
        XCTAssertEqual(Integer(bytes: [0, 0, 0, 1]) - Integer(1), Integer(bytes: [255, 255, 255]))
    }
    
    func testEquatable() {
        XCTAssertTrue(Integer(0) == 0)
        XCTAssertTrue(Integer(1) != 0)
    }
    
    func testComparable() {
        XCTAssertTrue(Integer(1) < Integer(2))
        XCTAssertTrue(Integer(1) <= Integer(2))
        XCTAssertTrue(Integer(1) <= Integer(1))
        XCTAssertFalse(Integer(2) < Integer(1))
        XCTAssertFalse(Integer(2) <= Integer(1))
        
        XCTAssertTrue(Integer(1) < Integer(256))
        XCTAssertTrue(Integer(1) <= Integer(256))
        XCTAssertTrue(Integer(256) <= Integer(256))
        XCTAssertFalse(Integer(256) < Integer(1))
        XCTAssertFalse(Integer(256) <= Integer(1))
        
        XCTAssertTrue(Integer(256) < Integer(257))
        XCTAssertTrue(Integer(256) <= Integer(257))
        XCTAssertTrue(Integer(256) <= Integer(256))
        XCTAssertFalse(Integer(257) < Integer(256))
        XCTAssertFalse(Integer(257) <= Integer(256))
        
        XCTAssertTrue(Integer(2) > Integer(1))
        XCTAssertTrue(Integer(2) >= Integer(1))
        XCTAssertTrue(Integer(2) >= Integer(2))
        XCTAssertFalse(Integer(1) > Integer(2))
        XCTAssertFalse(Integer(1) >= Integer(2))
        
        XCTAssertTrue(Integer(256) > Integer(1))
        XCTAssertTrue(Integer(256) >= Integer(1))
        XCTAssertTrue(Integer(256) >= Integer(256))
        XCTAssertFalse(Integer(1) > Integer(256))
        XCTAssertFalse(Integer(1) >= Integer(256))
        
        XCTAssertTrue(Integer(257) > Integer(256))
        XCTAssertTrue(Integer(257) >= Integer(256))
        XCTAssertTrue(Integer(256) >= Integer(256))
        XCTAssertFalse(Integer(256) > Integer(257))
        XCTAssertFalse(Integer(256) >= Integer(257))
    }
    
    func testBitShift() {
        XCTAssertEqual(Integer(255) << 0, 255)
        
        XCTAssertEqual(Integer(255) << 1, 65_280)
        XCTAssertEqual(Integer(255) << 2, 16_711_680)
        
        XCTAssertEqual(Integer(65_280) << -1, 255)
        XCTAssertEqual(Integer(16_711_680) << -2, 255)
        
        XCTAssertEqual(Integer(65_280) >> 1, 255)
        XCTAssertEqual(Integer(16_711_680) >> 2, 255)
        
        XCTAssertEqual(Integer(255) >> -1, 65_280)
        XCTAssertEqual(Integer(255) >> -2, 16_711_680)
    }
    
    func testMultiply() {
        XCTAssertEqual(Integer(0) * Integer(1), Integer(0))
        XCTAssertEqual(Integer(0) * Integer(256), Integer(0))
        XCTAssertEqual(Integer(1) * Integer(0), Integer(0))
        XCTAssertEqual(Integer(256) * Integer(0), Integer(0))
        XCTAssertEqual(Integer(255) * Integer(255), Integer(65025))
        XCTAssertEqual(Integer(255) * Integer(256), Integer(65280))
        XCTAssertEqual(Integer(795192) * Integer(20058), Integer(15949961136))
        XCTAssertEqual(Integer(1237845) * Integer(64523), Integer(79869472935))
        
        let aBytes: [UInt8] = [0x81, 0xa1, 0x85, 0xb6, 0x9e, 0xa3, 0x6c, 0x6e,
                               0xb0, 0xcc, 0x3c, 0xc5, 0x71, 0x0c, 0x6f, 0x11,
                               0xcd, 0xb5, 0x98, 0xc0, 0xe6, 0x06, 0x95, 0x51,
                               0x75, 0x94, 0xeb, 0xbe, 0x08, 0x1f, 0x8c, 0xdf]
        let a = Integer(bytes: aBytes)
        let bBytes: [UInt8] = [0x21, 0x64, 0x6c, 0x72, 0x6f, 0x77, 0x20, 0x6f,
                               0x6c, 0x6c, 0x65, 0x48, 0x01]
        let b = Integer(bytes: bBytes)
        let result: [UInt8] = [0xa1, 0x35, 0xbc, 0x4e, 0xfc, 0x96, 0x4b, 0xc1,
                               0x62, 0x4d, 0xf2, 0x1e, 0x79, 0x36, 0xc8, 0xba,
                               0x84, 0x30, 0xbf, 0x3a, 0x1c, 0xba, 0xa1, 0x6a,
                               0x0e, 0xa9, 0xb9, 0x37, 0x65, 0x7e, 0xac, 0xea,
                               0x46, 0xd5, 0xcd, 0xf0, 0xa7, 0x0c, 0x50, 0x40,
                               0xb9, 0x18, 0xc4, 0x1e, 0x01]
        XCTAssertEqual((a * b).bytes, result)
    }
    
    func testDivision() {
        
        func assert(dividend: Int, divisor: Int, quotient: Int, remainder: Int) {
            let result = Integer(dividend).quotientAndRemainder(dividingBy: Integer(divisor))
            XCTAssertEqual(result.quotient, Integer(quotient))
            XCTAssertEqual(result.remainder, Integer(remainder))
            
            XCTAssertEqual(Integer(dividend) / Integer(divisor), Integer(quotient))
            
            var q = Integer(dividend)
            q /= Integer(divisor)
            XCTAssertEqual(q, Integer(quotient))
            
            XCTAssertEqual(Integer(dividend) % Integer(divisor), Integer(remainder))
            
            var r = Integer(dividend)
            r %= Integer(divisor)
            XCTAssertEqual(r, Integer(remainder))
        }
        
        assert(dividend: 5, divisor: 5, quotient: 1, remainder: 0)
        assert(dividend: 12, divisor: 4, quotient: 3, remainder: 0)
        assert(dividend: 256, divisor: 1, quotient: 256, remainder: 0)
        assert(dividend: 65_792, divisor: 100, quotient: 657, remainder: 92)
        assert(dividend: 84_148_994, divisor: 256, quotient: 328_707, remainder: 2)
    }
    
    func testModularExponentiation() {
        
        func assert(base: Int, exponent: Int, modulus: Int, result: Int) {
            let me = modularExponentiation(base: Integer(base),
                                           exponent: Integer(exponent),
                                           modulus: Integer(modulus))
            XCTAssertEqual(me, Integer(result))
        }
        
        assert(base: 0, exponent: 0, modulus: 1, result: 0)
        assert(base: 1, exponent: 0, modulus: 1, result: 0)
        assert(base: 2, exponent: 5, modulus: 13, result: 6)
        assert(base: 451722, exponent: 423165, modulus: 418, result: 296)
    }
    
}
