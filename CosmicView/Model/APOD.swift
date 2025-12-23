//
//  APOD.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//


import Foundation

struct APOD: Codable, Identifiable {
    var id: String { date }

    let title: String
    let explanation: String
    let date: String
    let mediaType: String
    let url: String
    let hdurl: String?
    let copyright: String?

    enum CodingKeys: String, CodingKey {
        case title
        case explanation
        case date
        case url
        case hdurl
        case copyright
        case mediaType = "media_type"
    }
}
