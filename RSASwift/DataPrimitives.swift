//
//  DataPrimitives.swift
//  RSASwift
//
//  Created by wuyuehyang on 2019/4/24.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

internal func i2osp(x: Integer, xLen: Int) throws -> Data {
    guard x.bytes.count <= xLen else {
        throw RSAError.integerTooLarge
    }
    let zeros = [UInt8](repeating: 0, count: xLen - x.bytes.count)
    let bytes = zeros + x.bytes.reversed()
    return Data(bytes)
}

internal func os2ip(x: Data) -> Integer {
    let bytes = [UInt8](x.reversed())
    return Integer(bytes: bytes)
}
