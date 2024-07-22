//
//  PicDetails.swift
//  taskWisdomLeaf
//
//  Created by ilamparithi mayan on 23/06/24.
//

import Foundation

struct picdetails: Codable {
    var id: String?
    var author: String?
    var width: Int?
    var height: Int?
    var url: String?
    var download_url: String?
    var picImageData: Data?
}
