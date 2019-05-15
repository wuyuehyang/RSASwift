//
//  MGF1.swift
//  RSASwift
//
//  Created by wuyuehyang on 2019/4/30.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

internal func mgf1(mgfSeed: Data, maskLen: Integer, hasher: Hasher) throws -> Data {
    let hLen = hasher.digestLength
    let maxMaskLen = Integer(bytes: [0, 0, 0, 0, 1]) * Integer(hLen) // 2^32*hLen
    guard maskLen <= maxMaskLen else {
        throw RSAError.maskTooLong
    }
    var t = Data()
    for i in 0...maskLen / Integer(hLen) - 1 {
        let c = try i2osp(x: i, xLen: 4)
        let hash = hasher.digest(of: mgfSeed + c)
        t.append(hash)
        if t.count > maskLen {
            break
        }
    }
    return t.prefix(Int(maskLen))
}
