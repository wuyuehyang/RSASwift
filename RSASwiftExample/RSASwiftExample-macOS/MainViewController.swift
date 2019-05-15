//
//  ViewController.swift
//  RSASwiftExample-macOS
//
//  Created by wuyuehyang on 2019/5/13.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Cocoa
import Security
import RSASwift

class MainViewController: NSViewController {
    
    @IBOutlet var publicKeyTextView: NSTextView!
    @IBOutlet var privateKeyTextView: NSTextView!
    @IBOutlet weak var labelTextField: NSTextField!
    @IBOutlet var plainTextView: NSTextView!
    @IBOutlet var cipherTextView: NSTextView!
    
    let courierFont = NSFont(name: "Courier", size: 14)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        publicKeyTextView.font = courierFont
        privateKeyTextView.font = courierFont
        cipherTextView.font = courierFont
    }
    
    @IBAction func generateKeyPair(_ sender: Any) {
        let key: (public: Data, private: Data) = {
            let params = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                          kSecAttrKeySizeInBits: 1024] as [CFString : Any]
            let privateKey = SecKeyCreateRandomKey(params as CFDictionary, nil)!
            let privateData = SecKeyCopyExternalRepresentation(privateKey, nil)! as Data
            let publicKey = SecKeyCopyPublicKey(privateKey)!
            let publicData = SecKeyCopyExternalRepresentation(publicKey, nil)! as Data
            return (publicData, privateData)
        }()
        let privateKeyPem: String = {
            let ber = key.private.base64EncodedString()
            return "-----BEGIN RSA PRIVATE KEY-----\n"
                + ber.chunks(count: 64).joined(separator: "\n")
                + "\n-----END RSA PRIVATE KEY-----"
        }()
        let publicKeyPem: String = {
            let ber = key.public.base64EncodedString()
            return "-----BEGIN RSA PUBLIC KEY-----\n"
                + ber.chunks(count: 64).joined(separator: "\n")
                + "\n-----END RSA PUBLIC KEY-----"
        }()
        publicKeyTextView.string = publicKeyPem
        privateKeyTextView.string = privateKeyPem
    }
    
    @IBAction func decrypt(_ sender: Any) {
        guard let key = PrivateKey(pem: privateKeyTextView.string) else {
            return
        }
        guard let cipher = Data(base64Encoded: cipherTextView.string) else {
            return
        }
        guard let label = labelTextField.stringValue.data(using: .utf8) else {
            return
        }
        let plain = try! rsaesOaepDecrypt(key: key, c: cipher, l: label, hasher: .sha1)
        plainTextView.string = String(data: plain, encoding: .utf8) ?? ""
    }
    
    @IBAction func encrypt(_ sender: Any) {
        guard let key = PublicKey(pem: publicKeyTextView.string) else {
            return
        }
        guard let plain = plainTextView.string.data(using: .utf8) else {
            return
        }
        guard let label = labelTextField.stringValue.data(using: .utf8) else {
            return
        }
        let cipher = try! rsaesOaepEncrypt(key: key, m: plain, l: label, hasher: .sha1)
        cipherTextView.string = cipher.base64EncodedString()
    }
    
}
