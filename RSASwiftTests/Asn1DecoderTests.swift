//
//  Asn1DecoderTests.swift
//  RSASwiftTests
//
//  Created by wuyuehyang on 2019/5/8.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import XCTest
@testable import RSASwift

class Asn1DecoderTests: XCTestCase {
    
    let publicKeyData = Data(base64Encoded: "MIGJAoGBALYbsLNFPadTe64Pe076hemtUGi2jnLiIgcxW4QqLgjWLeSvLwjLm6kY/+9vOf870TOwLdtz77k/yH+CBL257gLrzmx2UfurkBy9l+9epKcd0B+7z+vXlxGD45S39Kb6XiPAyrw+wu0o6CjoEiecRHxpFdHNc5RUbFKct2Pj1uDvAgMBAAE=")!
    let privateKeyData = Data(base64Encoded: "MIICXAIBAAKBgQC2G7CzRT2nU3uuD3tO+oXprVBoto5y4iIHMVuEKi4I1i3kry8Iy5upGP/vbzn/O9EzsC3bc++5P8h/ggS9ue4C685sdlH7q5AcvZfvXqSnHdAfu8/r15cRg+OUt/Sm+l4jwMq8PsLtKOgo6BInnER8aRXRzXOUVGxSnLdj49bg7wIDAQABAoGAP1igfauvR549no2aGh4BKQj1uIcQRBwvNAtSR0YY31AJhMv/c3LIAelFVfd92C/plK5LNVQ95lWum9QRbCHaDamDwXo1JTPW7DFoqJADBavu7jGL89I0itH/ncUZNFoxQ1S34E4MqQUH9WZNkIm/ZiH11cPoMOXT+gKIsAH53+kCQQDnDpzh3JsiOidUn70toh/cSe0fRchc+ur1gzjmRdoUERS3VgkELntOzO6eccFEjROjUzfmg2nshXZw048Mpj9jAkEAycRZAe2p1PcizrA8yNxIuBcaNE4oTk4pPsPmZRfnZZp96A6OTpGgFmXmO0Ot3xEfm6N0GFlBAr9YV5Cox5UMBQJBAMEPzLZMhrOKs+JZttCybry6aI+A13IZlsmd46VFKHsr6otmMBJ2ZEHrqlZp5ntJBeeqWUMa+x7ORbDwlM6U+tECQB7hC/Y9l1ZelFcppcPf4sk5z+rdY1HIqItQk/w40lM8d7SCNclUhDmpUrkTPJL9HedF9sibMFXpTu3n18zjxLkCQCNq/hzBGLF6i2GX8kdXt3HwV6EQmOdsroAeeo82X9CNangZhy4TJXgfCuYwQbbKfJIXHczFYbWYKDMYApDOfRM=")!
    let publicKeyPem = """
-----BEGIN PUBLIC KEY-----
MIGJAoGBAPjbIToFRbYlsG79WloiEjKSc0EiyLAKvvjI5+KLSd8c3HtJe0/IOKt8
ZOkLXKLzvIoZA1nnIU75wIIfPlCZY43j/5HlLgPXmrAtPUDFStZjbNY+NZMBt+VI
nnByzTOP9zdIEaJpZ+8JJjkQZ/1aMjv95y6tMYFvwln5/YtRTek/AgMBAAE=
-----END PUBLIC KEY-----
"""
    let privateKeyPem = """
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQD42yE6BUW2JbBu/VpaIhIyknNBIsiwCr74yOfii0nfHNx7SXtP
yDirfGTpC1yi87yKGQNZ5yFO+cCCHz5QmWON4/+R5S4D15qwLT1AxUrWY2zWPjWT
AbflSJ5wcs0zj/c3SBGiaWfvCSY5EGf9WjI7/ecurTGBb8JZ+f2LUU3pPwIDAQAB
AoGAPG+bRif5oh7NFmdZBgK4QKfoba0w5+/0KR9BkXcaXaD4ushBtkJ94Me5Cg/E
U5617yPb+H11TWTCJ9fGnnRiBJz9uSzh6j9lFujxj/CZw1d8nPUFj5aQGSGwvWnV
K/0Ukj96WRmBToc05YdtLawprJbFD04fZrOGeJXUA18pAKECQQD81nrA5NbtZqln
rGAllLKmZc0S9p+881mZca1Z+1HDxfIJUnqNOeYAO6t+I1Bd3UhUveRLcqQ7OJqx
ZzdLVpsbAkEA+/fmyDutsrC9hcyyhfLwkduJTbDBBNIwrpDSXjLfxFWRWxwtyBFX
EXt+gtkV1azjsqghmtV/awNofLDx227IrQJBAKjse3Mo8VgHgSNdDZfOM1XtKgiD
cdICHFjilFlMCiLsu3ry+iIlDsAVHczWtzkfQNYtULv/yi4u8VuZhF33bQUCQEZU
ovlfFxPam3web/JNpnLAGaoy3R2wYeBIEkAy6RzPWZxZ2DmRBYGeu+hgGeUjtgbn
QUILt94x/FdZuJisap0CQEDXJIY4atCKKMwo+w92B/VVLIBeAFfR/SIgRDGvZR3J
GMUCF4ShGf6Q1LCW1XH5FXOTQKEVoGqf47uZT6iv8G4=
-----END RSA PRIVATE KEY-----
"""
    
    let nBytes: [UInt8] = [0xB6, 0x1B, 0xB0, 0xB3, 0x45, 0x3D, 0xA7, 0x53,
                           0x7B, 0xAE, 0x0F, 0x7B, 0x4E, 0xFA, 0x85, 0xE9,
                           0xAD, 0x50, 0x68, 0xB6, 0x8E, 0x72, 0xE2, 0x22,
                           0x07, 0x31, 0x5B, 0x84, 0x2A, 0x2E, 0x08, 0xD6,
                           0x2D, 0xE4, 0xAF, 0x2F, 0x08, 0xCB, 0x9B, 0xA9,
                           0x18, 0xFF, 0xEF, 0x6F, 0x39, 0xFF, 0x3B, 0xD1,
                           0x33, 0xB0, 0x2D, 0xDB, 0x73, 0xEF, 0xB9, 0x3F,
                           0xC8, 0x7F, 0x82, 0x04, 0xBD, 0xB9, 0xEE, 0x02,
                           0xEB, 0xCE, 0x6C, 0x76, 0x51, 0xFB, 0xAB, 0x90,
                           0x1C, 0xBD, 0x97, 0xEF, 0x5E, 0xA4, 0xA7, 0x1D,
                           0xD0, 0x1F, 0xBB, 0xCF, 0xEB, 0xD7, 0x97, 0x11,
                           0x83, 0xE3, 0x94, 0xB7, 0xF4, 0xA6, 0xFA, 0x5E,
                           0x23, 0xC0, 0xCA, 0xBC, 0x3E, 0xC2, 0xED, 0x28,
                           0xE8, 0x28, 0xE8, 0x12, 0x27, 0x9C, 0x44, 0x7C,
                           0x69, 0x15, 0xD1, 0xCD, 0x73, 0x94, 0x54, 0x6C,
                           0x52, 0x9C, 0xB7, 0x63, 0xE3, 0xD6, 0xE0, 0xEF]
    let dBytes: [UInt8] = [0x3F, 0x58, 0xA0, 0x7D, 0xAB, 0xAF, 0x47, 0x9E,
                           0x3D, 0x9E, 0x8D, 0x9A, 0x1A, 0x1E, 0x01, 0x29,
                           0x08, 0xF5, 0xB8, 0x87, 0x10, 0x44, 0x1C, 0x2F,
                           0x34, 0x0B, 0x52, 0x47, 0x46, 0x18, 0xDF, 0x50,
                           0x09, 0x84, 0xCB, 0xFF, 0x73, 0x72, 0xC8, 0x01,
                           0xE9, 0x45, 0x55, 0xF7, 0x7D, 0xD8, 0x2F, 0xE9,
                           0x94, 0xAE, 0x4B, 0x35, 0x54, 0x3D, 0xE6, 0x55,
                           0xAE, 0x9B, 0xD4, 0x11, 0x6C, 0x21, 0xDA, 0x0D,
                           0xA9, 0x83, 0xC1, 0x7A, 0x35, 0x25, 0x33, 0xD6,
                           0xEC, 0x31, 0x68, 0xA8, 0x90, 0x03, 0x05, 0xAB,
                           0xEE, 0xEE, 0x31, 0x8B, 0xF3, 0xD2, 0x34, 0x8A,
                           0xD1, 0xFF, 0x9D, 0xC5, 0x19, 0x34, 0x5A, 0x31,
                           0x43, 0x54, 0xB7, 0xE0, 0x4E, 0x0C, 0xA9, 0x05,
                           0x07, 0xF5, 0x66, 0x4D, 0x90, 0x89, 0xBF, 0x66,
                           0x21, 0xF5, 0xD5, 0xC3, 0xE8, 0x30, 0xE5, 0xD3,
                           0xFA, 0x02, 0x88, 0xB0, 0x01, 0xF9, 0xDF, 0xE9]
    
    func testInit() {
        
        func assertNil(data: Data) {
            XCTAssertNil(Asn1IntegerSequenceDecoder(data: data))
        }
        
        func assertNotNil(data: Data) {
            XCTAssertNotNil(Asn1IntegerSequenceDecoder(data: data))
        }
        
        assertNil(data: Data())
        assertNil(data: Data(count: 6))
        assertNil(data: Data([0x30, 0x80, 0x11, 0x11, 0x11, 0x11, 0x11]))
        
        assertNotNil(data: publicKeyData)
        assertNotNil(data: privateKeyData)
        
    }
    
    func testPublicKeyDecoding() {
        let decoder = Asn1IntegerSequenceDecoder(data: publicKeyData)
        XCTAssertNotNil(decoder)
        
        let n = decoder!.next()
        XCTAssertNotNil(n)
        XCTAssertEqual(n!.bytes.reversed(), nBytes)
        
        let e = decoder!.next()
        XCTAssertNotNil(e)
        XCTAssertEqual(e!.bytes.reversed(), [1, 0, 1])
        
        XCTAssertNil(decoder!.next())
    }
    
    func testPrivateKeyDecoding() {
        let decoder = Asn1IntegerSequenceDecoder(data: privateKeyData)
        XCTAssertNotNil(decoder)
        
        let version = decoder!.next()
        XCTAssertNotNil(version)
        
        let n = decoder!.next()
        XCTAssertNotNil(n)
        XCTAssertEqual(n!.bytes.reversed(), nBytes)
        
        let e = decoder!.next()
        XCTAssertNotNil(e)
        XCTAssertEqual(e!.bytes.reversed(), [1, 0, 1])
        
        let d = decoder!.next()
        XCTAssertNotNil(d)
        XCTAssertEqual(d!.bytes.reversed(), dBytes)
        
        XCTAssertNotNil(decoder!.next())
    }
    
    func testPemDecoding() {
        let privateKey = PrivateKey(pem: privateKeyPem)
        XCTAssertNotNil(privateKey)
        let publicKey = PublicKey(pem: publicKeyPem)
        XCTAssertNotNil(publicKey)
    }
    
}
