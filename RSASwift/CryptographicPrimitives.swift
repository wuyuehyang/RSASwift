//
//  CryptographicPrimitives.swift
//  RSASwift
//
//  Created by wuyuehyang on 2019/4/25.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

internal func rsaep(k: PublicKey, m: Integer) throws -> Integer {
    guard m > 0 && m < k.n - 1 else {
        throw RSAError.messageRepresentativeOutOfRange
    }
    return modularExponentiation(base: m, exponent: k.e, modulus: k.n)
}

internal func rsadp(k: PrivateKey, c: Integer) throws -> Integer {
    guard c > 0 && c < k.n - 1 else {
        throw RSAError.ciphertextRepresentativeOutOfRange
    }
    return modularExponentiation(base: c, exponent: k.d, modulus: k.n)
}
