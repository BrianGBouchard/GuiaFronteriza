import Foundation
import MapKit

class CrossingAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var xmlIdentifier: String?
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
    }
}
