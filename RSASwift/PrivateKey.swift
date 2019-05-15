//
//  PrivateKey.swift
//  RSASwift
//
//  Created by wuyuehyang on 2019/4/25.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

final public class PrivateKey {
    
    internal let n: Integer
    internal let d: Integer
    
    internal init(n: Integer, d: Integer) {
        self.n = n
        self.d = d
    }
    
    // TODO: pass through the Integer construction for version and e
    public convenience init?(berEncodedAsn1Data data: Data) {
        guard let decoder = Asn1IntegerSequenceDecoder(data: data) else {
            return nil
        }
        _ = decoder.next() // version
        guard let n = decoder.next() else {
            return nil
        }
        _ = decoder.next() // e
        guard let d = decoder.next() else {
            return nil
        }
        self.init(n: n, d: d)
    }
    
    public convenience init?(pem: String) {
        let body = pem.split(separator: "\n")
            .dropFirst()
            .dropLast()
            .joined()
        guard let data = Data(base64Encoded: body) else {
            return nil
        }
        self.init(berEncodedAsn1Data: data)
    }
    
}
