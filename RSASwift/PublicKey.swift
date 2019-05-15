//
//  PublicKey.swift
//  RSASwift
//
//  Created by wuyuehyang on 2019/4/25.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

final public class PublicKey {
    
    internal let n: Integer
    internal let e: Integer
    
    internal init(n: Integer, e: Integer) {
        self.n = n
        self.e = e
    }
    
    public convenience init?(berEncodedAsn1Data data: Data) {
        guard let decoder = Asn1IntegerSequenceDecoder(data: data) else {
            return nil
        }
        guard let n = decoder.next(), let e = decoder.next() else {
            return nil
        }
        self.init(n: n, e: e)
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
