//
//  RSAError.swift
//  RSASwift
//
//  Created by wuyuehyang on 2019/4/25.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

public enum RSAError: Error {
    case integerTooLarge
    case messageRepresentativeOutOfRange
    case ciphertextRepresentativeOutOfRange
    case maskTooLong
    case randomGenerationFailed(OSStatus)
    case messageTooLong
    case labelTooLong
    case decryptionError
}
