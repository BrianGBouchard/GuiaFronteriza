//
//  ViewController.swift
//  GuíaFronteriza
//
//  Created by Brian Bouchard on 9/6/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    var crossings: Array<CrossingAnnotation> = []

    let centerCoordinates = CLLocationCoordinate2DMake(30.874890, -106.286547)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(getDelayTime(forCrossing: "San Ysidro", crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>"))
        loadMap(rangeSpan: 2500000)

        let sanYsidro = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(32.542564, -117.029342), title: "San Ysidro")
        sanYsidro.xmlIdentifier = "San Ysidro"
        crossings.append(sanYsidro)
        mapView.addAnnotation(sanYsidro)

        let tecate = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(32.576332, -116.627447), title: "Tecate")
        tecate.xmlIdentifier = "Tecate"
        crossings.append(tecate)
        mapView.addAnnotation(tecate)

        let andrade = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(32.718132, -114.728626), title: "Andrade")
        andrade.xmlIdentifier = "Andrade"
        crossings.append(andrade)
        mapView.addAnnotation(andrade)

        let brownsvilleBM = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(25.891932, -97.504709), title: "Brownsville: \n B&M Bridge")
        brownsvilleBM.xmlIdentifier = "535501"
        crossings.append(brownsvilleBM)
        mapView.addAnnotation(brownsvilleBM)

        let brownsvilleGateway = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(25.898732, -97.497447), title: "Brownsville: \n Gateway Bridge")
        brownsvilleGateway.xmlIdentifier = "Gateway"
        crossings.append(brownsvilleGateway)
        mapView.addAnnotation(brownsvilleGateway)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadMap(rangeSpan: CLLocationDistance) {
        let region = MKCoordinateRegionMakeWithDistance(centerCoordinates, rangeSpan, rangeSpan)
        mapView.region = region

    }


}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let port = view.annotation?.coordinate {
            for item in crossings {
                if item.coordinate.latitude == port.latitude && item.coordinate.longitude == port.longitude {
                    showData(crossing: item.xmlIdentifier!, controller: self, crossingTitle: item.title!)
                }
            }
        }
    }
}

