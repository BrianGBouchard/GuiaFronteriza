//
//  annotationPins.swift
//  GuíaFronteriza
//
//  Created by Brian Bouchard on 9/7/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import Foundation
import MapKit

enum ports {
    case sanYsidro = MKPointAnnotation()
    sanYsidro.coordinate = CLLocationCoordinate2DMake(32.542564, -117.029342)
    sanYsidro.title! = "San Ysidro"
    sanYsidro.subtitle! = "Hours: 24 hrs/day"

let tecate = MKPointAnnotation()
tecate.coordinate = CLLocationCoordinate2DMake(32.576332, -116.627447)
tecate.title! = "Tecate"
tecate.subtitle! = "Hours: 5 AM - 11 PM"
