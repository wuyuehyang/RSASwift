//
//  Integer.swift
//  RSASwift
//
//  Created by wuyuehyang on 2019/4/14.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

internal struct Integer {
    
    private(set) var bytes: [UInt8]
    
    init() {
        bytes = []
    }
    
    init(bytes: [UInt8]) {
        self.bytes = bytes
        removeTrailingZero()
    }
    
    private mutating func removeTrailingZero() {
        while bytes.last == 0 {
            bytes.removeLast()
        }
    }
    
}

extension Integer: CustomStringConvertible {
    
    var description: String {
        let chunkSize = 4
        let hexGroups = stride(from: 0, to: bytes.count, by: chunkSize)
            .map { bytes[$0..<Swift.min($0 + chunkSize, bytes.count)] }
            .map { $0.reduce("", { $0 + String(format:"%02x", $1) }) }
            .joined(separator: " ")
        return "<" + hexGroups + ">"
    }
    
}

extension Integer: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return description
    }
    
}

extension Integer: CustomReflectable {
    
    var customMirror: Mirror {
        return Mirror(reflecting: description)
    }
    
}

extension Integer: AdditiveArithmetic {
    
    static func + (lhs: Integer, rhs: Integer) -> Integer {
        var result = lhs
        result += rhs
        return result
    }
    
    static func += (lhs: inout Integer, rhs: Integer) {
        let commonBytesCount = Swift.min(lhs.bytes.count, rhs.bytes.count)
        var carry: UInt8 = 0
        for i in 0..<commonBytesCount {
            var overflow = false
            if carry != 0 {
                (lhs.bytes[i], overflow) = lhs.bytes[i].addingReportingOverflow(carry)
                carry = overflow ? 1 : 0
            }
            (lhs.bytes[i], overflow) = lhs.bytes[i].addingReportingOverflow(rhs.bytes[i])
            carry += overflow ? 1 : 0
        }
        if lhs.bytes.count > rhs.bytes.count {
            for i in commonBytesCount..<lhs.bytes.count {
                guard carry != 0 else {
                    break
                }
                var overflow = false
                (lhs.bytes[i], overflow) = lhs.bytes[i].addingReportingOverflow(carry)
                carry = overflow ? 1 : 0
            }
        } else {
            for i in commonBytesCount..<rhs.bytes.count {
                if carry == 0 {
                    lhs.bytes.append(rhs.bytes[i])
                } else {
                    let (byte, overflow) = rhs.bytes[i].addingReportingOverflow(carry)
                    lhs.bytes.append(byte)
                    carry = overflow ? 1 : 0
                }
            }
        }
        if carry != 0 {
            lhs.bytes.append(1)
        }
    }
    
    static func - (lhs: Integer, rhs: Integer) -> Integer {
        var result = lhs
        result -= rhs
        return result
    }
    
    static func -= (lhs: inout Integer, rhs: Integer) {
        let lhsIsGreaterThanRhs = lhs.bytes.count > rhs.bytes.count
            || (lhs.bytes.count == rhs.bytes.count && (lhs.bytes.last ?? 0) >= (rhs.bytes.last ?? 0))
        precondition(lhsIsGreaterThanRhs)
        var borrow: UInt8 = 0
        var overflow = false
        for i in 0..<rhs.bytes.count {
            if borrow != 0 {
                (lhs.bytes[i], overflow) = lhs.bytes[i].subtractingReportingOverflow(borrow)
                borrow = overflow ? 1 : 0
            }
            (lhs.bytes[i], overflow) = lhs.bytes[i].subtractingReportingOverflow(rhs.bytes[i])
            borrow += overflow ? 1 : 0
        }
        for i in rhs.bytes.count...lhs.bytes.count {
            guard borrow != 0 else {
                break
            }
            (lhs.bytes[i], overflow) = lhs.bytes[i].subtractingReportingOverflow(borrow)
            borrow = overflow ? 1 : 0
        }
        lhs.removeTrailingZero()
    }
    
}

extension Integer: ExpressibleByIntegerLiteral {
    
    init(integerLiteral value: Int) {
        self.init(value)
    }
    
}

extension Integer: Equatable {
    
    static func == (lhs: Integer, rhs: Integer) -> Bool {
        guard lhs.bytes.count == rhs.bytes.count else {
            return false
        }
        guard !lhs.bytes.isEmpty else {
            return true
        }
        for i in 0..<lhs.bytes.count {
            if lhs.bytes[i] != rhs.bytes[i] {
                return false
            }
        }
        return true
    }
    
    static func != (lhs: Integer, rhs: Integer) -> Bool {
        return !(lhs == rhs)
    }
    
}

extension Integer: Comparable {
    
    static func < (lhs: Integer, rhs: Integer) -> Bool {
        if lhs.bytes.count == rhs.bytes.count {
            let bits = stride(from: lhs.bytes.count - 1, through: 0, by: -1)
            for i in bits where lhs.bytes[i] != rhs.bytes[i] {
                return lhs.bytes[i] < rhs.bytes[i]
            }
            return false
        } else {
            return lhs.bytes.count < rhs.bytes.count
        }
    }
    
}

extension Integer: Numeric {
    
    var magnitude: Integer {
        return self
    }
    
    init?<T>(exactly source: T) where T : BinaryInteger {
        guard source >= 0 else {
            return nil
        }
        self.init(source)
    }
    
    static func * (lhs: Integer, rhs: Integer) -> Integer {
        if lhs.bytes.isEmpty || rhs.bytes.isEmpty {
            return Integer(bytes: [])
        } else {
            let (less, greater) = lhs.bytes.count < rhs.bytes.count
                ? (lhs.bytes, rhs.bytes)
                : (rhs.bytes, lhs.bytes)
            if less.count == 1 {
                var bytes: [UInt8] = []
                let multiplicand = less[0]
                var carry: UInt8 = 0
                for i in 0..<greater.count {
                    let (high, low) = greater[i].multipliedFullWidth(by: multiplicand)
                    let (partialValue, overflow) = low.addingReportingOverflow(carry)
                    carry = high + (overflow ? 1 : 0)
                    bytes.append(partialValue)
                }
                if carry != 0 {
                    bytes.append(carry)
                }
                return Integer(bytes: bytes)
            } else {
                // Karatsuba fast multiplication
                let m = less.count
                let m2 = m / 2
                
                let low1 = Integer(bytes: Array(less[0..<m2]))
                let high1 = Integer(bytes: Array(less[m2..<less.count]))
                let low2 = Integer(bytes: Array(greater[0..<m2]))
                let high2 = Integer(bytes: Array(greater[m2..<greater.count]))
                
                let z0 = low1 * low2
                let z1 = (low1 + high1) * (low2 + high2)
                let z2 = high1 * high2
                
                return (z2 << (2 * m2)) + ((z1 - z2 - z0) << m2) + z0
            }
        }
    }
    
    static func *= (lhs: inout Integer, rhs: Integer) {
        let result = lhs * rhs
        lhs.bytes = result.bytes
    }
    
}

extension Integer: UnsignedInteger {
    
    static var isSigned: Bool {
        return false
    }
    
    init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        return nil
    }
    
    init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.init()
    }
    
    init<T>(_ source: T) where T : BinaryInteger {
        precondition(source >= 0)
        var bytes: [UInt8] = []
        let bitWidthRatio = source.bitWidth / UInt8.bitWidth
        for var sourceWord in source.words {
            for _ in 0..<bitWidthRatio {
                let byte = UInt8(truncatingIfNeeded: sourceWord)
                bytes.append(byte)
                sourceWord >>= UInt8.bitWidth
            }
        }
        self.bytes = bytes
        removeTrailingZero()
    }
    
    init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.init()
    }
    
    init<T>(clamping source: T) where T : BinaryInteger {
        self.init()
    }
    
    var words: [UInt] {
        return []
    }
    
    var bitWidth: Int {
        return 0
    }
    
    var trailingZeroBitCount: Int {
        return 0
    }
    
    static func / (lhs: Integer, rhs: Integer) -> Integer {
        let (quotient, _) = lhs.quotientAndRemainder(dividingBy: rhs)
        return quotient
    }
    
    static func /= (lhs: inout Integer, rhs: Integer) {
        let (quotient, _) = lhs.quotientAndRemainder(dividingBy: rhs)
        lhs = quotient
    }
    
    static func % (lhs: Integer, rhs: Integer) -> Integer {
        let (_, remainder) = lhs.quotientAndRemainder(dividingBy: rhs)
        return remainder
    }
    
    static func %= (lhs: inout Integer, rhs: Integer) {
        let (_, remainder) = lhs.quotientAndRemainder(dividingBy: rhs)
        lhs = remainder
    }
    
    prefix static func ~ (x: Integer) -> Integer {
        return Integer()
    }
    
    static func & (lhs: Integer, rhs: Integer) -> Integer {
        return Integer()
    }
    
    static func &= (lhs: inout Integer, rhs: Integer) {
        
    }
    
    static func | (lhs: Integer, rhs: Integer) -> Integer {
        return Integer()
    }
    
    static func |= (lhs: inout Integer, rhs: Integer) {
        
    }
    
    static func ^ (lhs: Integer, rhs: Integer) -> Integer {
        return Integer()
    }
    
    static func ^= (lhs: inout Integer, rhs: Integer) {
        
    }
    
    static func >> <RHS>(lhs: Integer, rhs: RHS) -> Integer where RHS : BinaryInteger {
        var result = lhs
        result >>= rhs
        return result
    }
    
    static func >>= <RHS>(lhs: inout Integer, rhs: RHS) where RHS : BinaryInteger {
        guard rhs != 0 else {
            return
        }
        guard rhs > 0 else {
            lhs <<= rhs.magnitude
            return
        }
        lhs.bytes.removeFirst(Int(rhs))
    }
    
    static func << <RHS>(lhs: Integer, rhs: RHS) -> Integer where RHS : BinaryInteger {
        var result = lhs
        result <<= rhs
        return result
    }
    
    static func <<= <RHS>(lhs: inout Integer, rhs: RHS) where RHS : BinaryInteger {
        guard rhs != 0 else {
            return
        }
        guard rhs > 0 else {
            lhs >>= rhs.magnitude
            return
        }
        let zeros = [UInt8](repeating: 0, count: Int(rhs))
        lhs.bytes.insert(contentsOf: zeros, at: 0)
    }
    
    func quotientAndRemainder(dividingBy rhs: Integer) -> (quotient: Integer, remainder: Integer) {
        precondition(!rhs.bytes.isEmpty)
        guard self >= rhs else {
            return (0, self)
        }
        guard self != rhs else {
            return (1, 0)
        }
        
        var quotient = Integer(0)
        var remainingSelf = self
        
        for i in stride(from: bytes.count - rhs.bytes.count, through: 0, by: -1) {
            let divisor = rhs << i
            
            var counter: UInt8 = 0
            while remainingSelf >= divisor {
                remainingSelf -= divisor
                counter += 1
            }
            
            var bytes = [UInt8](repeating: 0, count: i)
            bytes.append(counter)
            quotient += Integer(bytes: bytes)
        }
        
        quotient.removeTrailingZero()
        return (quotient, remainingSelf)
    }
    
    func isMultiple(of other: Integer) -> Bool {
        return true
    }
    
    func signum() -> Integer {
        return Integer()
    }
    
}

func modularExponentiation(base: Integer, exponent: Integer, modulus: Integer) -> Integer {
    precondition(modulus != 0)
    guard modulus != 1 else {
        return 0
    }
    var base = base
    var exponent = exponent
    var result = Integer(1)
    base %= modulus
    while exponent > 0 {
        if exponent % 2 == 1 {
            result = (result * base) % modulus
        }
        exponent /= 2
        base = (base * base) % modulus
    }
    return result
}
