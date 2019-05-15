//
//  String+Utils.swift
//  RSASwiftExample-macOS
//
//  Created by wuyuehyang on 2019/5/15.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

extension String {
    
    func chunks(count: Int) -> [String] {
        var index = startIndex
        var chunks = [Substring]()
        while index < endIndex {
            let chunkEndIndex = self.index(index, offsetBy: count, limitedBy: endIndex) ?? endIndex
            let chunk = self[index..<chunkEndIndex]
            chunks.append(chunk)
            index = chunkEndIndex
        }
        return chunks.map(String.init)
    }
    
}
