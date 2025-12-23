//
//  FavoriteAPOD.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 23/12/25.
//

import SwiftData

@Model
class FavoriteAPOD {

    @Attribute(.unique)
    var date: String

    var title: String
    var imageURL: String

    init(date: String, title: String, imageURL: String) {
        self.date = date
        self.title = title
        self.imageURL = imageURL
    }
}
