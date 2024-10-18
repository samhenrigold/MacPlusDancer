//
//  Dancer.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-18.
//

import Foundation

struct DancersData: Codable {
    let dancers: [Dancer]
}

struct Dancer: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let general_dance_style: String?
    let related_game: String?
    let download_link: String?
    let description: String?
    let group: String?
    let matte_video: Video?
    let regular_video: Video?
}

struct Video: Codable, Hashable {
    let converted_file: String
}
