//
//  Hasher.swift
//  RSASwift
//
//  Created by wuyuehyang on 2019/4/29.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation
import CommonCrypto

public struct Hasher {
    
    private typealias Impl = (UnsafeRawPointer?, CC_LONG, UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?
    
    public static let sha1 = Hasher(digestLength: CC_SHA1_DIGEST_LENGTH, impl: CC_SHA1)
    public static let sha224 = Hasher(digestLength: CC_SHA224_DIGEST_LENGTH, impl: CC_SHA224)
    public static let sha256 = Hasher(digestLength: CC_SHA256_DIGEST_LENGTH, impl: CC_SHA256)
    public static let sha384 = Hasher(digestLength: CC_SHA384_DIGEST_LENGTH, impl: CC_SHA384)
    public static let sha512 = Hasher(digestLength: CC_SHA512_DIGEST_LENGTH, impl: CC_SHA512)
    
    internal let digestLength: Int
    
    private let impl: Impl
    
    private init(digestLength: Int32, impl: @escaping Impl) {
        self.digestLength = Int(digestLength)
        self.impl = impl
    }
    
    internal func digest(of source: Data) -> Data {
        let digest = malloc(digestLength)!.bindMemory(to: UInt8.self, capacity: digestLength)
        source.withUnsafeBytes { (ptr) -> Void in
            _ = impl(ptr.baseAddress!, CC_LONG(source.count), digest)
        }
        return Data(bytesNoCopy: digest, count: digestLength, deallocator: .free)
    }
    
}
