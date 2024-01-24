//
//  YoutubeSearchResponse.swift
//  Envies
//
//  Created by lowbatt on 7/11/2565 BE.
//

import Foundation

//apiของยุทุป

struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}


struct VideoElement: Codable {
    let id: IdVideoElement
}


struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}
