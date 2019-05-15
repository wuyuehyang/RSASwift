//
//  EncryptionSchemes.swift
//  RSASwift
//
//  Created by wuyuehyang on 2019/4/25.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

public func rsaesOaepEncrypt(key: PublicKey, m: Data, l: Data = Data(), hasher: Hasher) throws -> Data {
    // TODO: check label length
    let k = key.n.bytes.count
    let hLen = hasher.digestLength
    let hLenBy2 = 2 * hLen
    guard m.count <= k - hLenBy2 - 2 else {
        throw RSAError.messageTooLong
    }
    let lHash: Data
    if l.isEmpty {
        lHash = Data() // FIXME
    } else {
        lHash = hasher.digest(of: l)
    }
    let ps = Data(count: k - m.count - hLenBy2 - 2)
    let db = lHash + ps + [1] + m
    let seed = try Data(securedRandomBytesOfCount: hLen)
    let dbMask = try mgf1(mgfSeed: seed, maskLen: Integer(k - hLen - 1), hasher: hasher)
    let maskedDb = db ^ dbMask
    let seedMask = try mgf1(mgfSeed: maskedDb, maskLen: Integer(hLen), hasher: hasher)
    let maskedSeed = seed ^ seedMask
    let em: Data = [0] + maskedSeed + maskedDb
    let m = os2ip(x: em)
    let c = try rsaep(k: key, m: m)
    return try i2osp(x: c, xLen: k)
}

public func rsaesOaepDecrypt(key: PrivateKey, c: Data, l: Data = Data(), hasher: Hasher) throws -> Data {
    // TODO: check label length
    let k = key.n.bytes.count
    let hLen = hasher.digestLength
    guard c.count == k else {
        throw RSAError.decryptionError
    }
    guard k >= 2*hLen + 2 else {
        throw RSAError.decryptionError
    }
    let c = os2ip(x: c)
    let m = try rsadp(k: key, c: c)
    let em = try i2osp(x: m, xLen: k)
    let lHash = hasher.digest(of: l)
    let y = em[em.startIndex]
    guard y == 0 else {
        throw RSAError.decryptionError
    }
    let maskedSeed = em[em.index(after: em.startIndex)...em.index(em.startIndex, offsetBy: hLen)]
    let maskedDb = em[em.index(em.startIndex, offsetBy: hLen + 1)...]
    let seedMask = try mgf1(mgfSeed: maskedDb, maskLen: Integer(hLen), hasher: hasher)
    let seed = maskedSeed ^ seedMask
    let dbMask = try mgf1(mgfSeed: seed, maskLen: Integer(k - hLen - 1), hasher: hasher)
    let db = maskedDb ^ dbMask
    let psStartIndex = db.index(db.startIndex, offsetBy: hLen)
    guard lHash == db[db.startIndex..<psStartIndex] else {
        throw RSAError.decryptionError
    }
    var i = psStartIndex
    while db[i] == 0x00 {
        i = db.index(after: i)
    }
    guard db[i] == 0x01 else {
        throw RSAError.decryptionError
    }
    return Data(db[db.index(after: i)...])
}
