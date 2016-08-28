//
//  Note.swift
//  Ulysses
//
//  Created by Matteo Muscella on 27/08/16.
//  Copyright © 2016 The Ulysses Team. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class Note: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var city: String
    var address: String
    var audio: String
    var tagger: String

    init(title: String, coordinate: CLLocationCoordinate2D, city: String, address: String, audio: String, tagger: String) {
        self.title = title
        self.coordinate = coordinate
        self.city = city
        self.address = address
        self.audio = audio
        self.tagger = tagger
    }
}
