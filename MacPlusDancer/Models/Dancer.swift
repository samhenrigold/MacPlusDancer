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

struct Dancer: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let general_dance_style: String?
    let related_game: String?
    let download_link: String?
    let description: String?
    let matte_video: Video?
    let regular_video: Video?
    
    enum CodingKeys: String, CodingKey {
        case name, general_dance_style, related_game, download_link, description, matte_video, regular_video
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.general_dance_style = try container.decodeIfPresent(String.self, forKey: .general_dance_style)
        self.related_game = try container.decodeIfPresent(String.self, forKey: .related_game)
        self.download_link = try container.decodeIfPresent(String.self, forKey: .download_link)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.matte_video = try container.decodeIfPresent(Video.self, forKey: .matte_video)
        self.regular_video = try container.decodeIfPresent(Video.self, forKey: .regular_video)
    }
    
    static func == (lhs: Dancer, rhs: Dancer) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.general_dance_style == rhs.general_dance_style &&
               lhs.related_game == rhs.related_game &&
               lhs.download_link == rhs.download_link &&
               lhs.description == rhs.description &&
               lhs.matte_video == rhs.matte_video &&
               lhs.regular_video == rhs.regular_video
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Video: Codable, Equatable, Hashable {
    let converted_file: String
}
