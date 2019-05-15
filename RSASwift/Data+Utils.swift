//
//  Random.swift
//  RSASwift
//
//  Created by wuyuehyang on 2019/4/30.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

internal extension Data {
    
    init(securedRandomBytesOfCount count: Int) throws {
        let bytes = malloc(count)!
        let status = SecRandomCopyBytes(kSecRandomDefault, count, bytes)
        guard status == errSecSuccess else {
            throw RSAError.randomGenerationFailed(status)
        }
        self.init(bytesNoCopy: bytes, count: count, deallocator: .free)
    }
    
    static func ^(_ lhs: Data, _ rhs: Data) -> Data {
        var result = lhs
        for offset in 0..<rhs.count {
            let resultIndex = result.index(result.startIndex, offsetBy: offset)
            let rhsIndex = rhs.index(rhs.startIndex, offsetBy: offset)
            result[resultIndex] ^= rhs[rhsIndex % rhs.count]
        }
        return result
    }
    
}
