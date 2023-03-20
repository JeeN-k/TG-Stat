//
//  Message.swift
//  TG Stat
//
//  Created by user on 17.03.2023.
//

import Foundation

struct GroupModel: Codable {
    let id: Int
    let name: String
    let type: String
    let messages: [MessageModel]
}

struct MessageModel: Codable {
    let id: Int
    let type: String
    let date: String
    let dateUnixtime: String
    let from: String?
    let fromId: String?
    let title: String?
    let textEntities: [TextEntities]
}

struct TextEntities: Codable {
    let text: String
    let type: String
}
