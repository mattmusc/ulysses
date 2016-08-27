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
    var info: String
    var audio: String

    init(title: String, coordinate: CLLocationCoordinate2D, info: String, audio: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.audio = audio
    }
}
