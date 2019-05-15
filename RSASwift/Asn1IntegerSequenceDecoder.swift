//
//  Asn1IntegerSequenceDecoder.swift
//  RSASwift
//
//  Created by wuyuehyang on 2019/5/7.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

internal class Asn1IntegerSequenceDecoder {
    
    private enum Tag {
        static let constructedSequence = 0x30
        static let integer = 0x02
    }
    
    private let data: Data
    
    private var index: Data.Index
    private var isMalformed = false
    private var didReachEnd = false
    
    init?(data: Data) {
        // Min size: 30 04 02 00 02 00 00
        // Which is a sequence of 2 zero integers
        guard data.count >= 7 else {
            return nil
        }
        
        guard data[data.startIndex] == Tag.constructedSequence else {
            return nil
        }
        
        if data[data.index(after: data.startIndex)] == 0x80 {
            // Indefinite length sequence
            let lastByte = data[data.index(data.endIndex, offsetBy: -1)]
            let secondLastByte = data[data.index(data.endIndex, offsetBy: -2)]
            let lastTwoBytesIsEndOfContent = lastByte == 0x00 && secondLastByte == 0x00
            guard lastTwoBytesIsEndOfContent else {
                return nil
            }
            index = data.index(data.startIndex, offsetBy: 2)
        } else {
            // Definite length sequence
            if data[data.index(after: data.startIndex)] >> 7 == 0 {
                // Short form length octets
                index = data.index(data.startIndex, offsetBy: 2)
            } else {
                // Long form length octets
                let numberOfLengthOctets = Int(data[data.index(after: data.startIndex)] & 0b01111111)
                index = data.index(data.startIndex, offsetBy: 2 + numberOfLengthOctets)
            }
        }
        
        self.data = data
    }
    
    func next() -> Integer? {
        guard !isMalformed && !didReachEnd else {
            return nil
        }
        
        // Min object: 02 01 00
        guard index <= data.index(data.endIndex, offsetBy: -3) else {
            isMalformed = true
            return nil
        }
        
        guard data[index] == Tag.integer else {
            isMalformed = true
            return nil
        }
        index = data.index(after: index)
        
        let length: Int
        if data[index] >> 7 == 0 {
            length = Int(data[index])
            index = data.index(after: index)
        } else {
            let numberOfOctets = Int(data[index] & 0b01111111)
            
            // Despite the BER encoding holds up to 127 octets representing a length
            // That's way too large for an RSA key
            // Since length here is an Int so any numberOfOctets larger than Int.bitWidth is considered malformed
            guard numberOfOctets < Int.bitWidth else {
                isMalformed = true
                return nil
            }
            
            let endIndex = data.index(index, offsetBy: numberOfOctets)
            var exp = 1
            length = stride(from: data.index(before: endIndex), to: data.index(after: index), by: -1)
                .reduce(Int(data[endIndex]), { (prev, idx) -> Int in
                    let next = prev + (256 ^ exp) * Int(data[idx])
                    exp += 1
                    return next
                })
            index = data.index(after: endIndex)
        }
        
        let nextObjectIndex = data.index(index, offsetBy: length)
        let bytes = [UInt8](data[index..<nextObjectIndex])
        index = nextObjectIndex
        
        return Integer(bytes: bytes.reversed())
    }
    
}
