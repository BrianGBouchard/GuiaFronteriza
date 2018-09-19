import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var aboutButton: UIButton!
    @IBOutlet var showTableButton: UIButton!
    @IBOutlet var control: UISegmentedControl!

    var crossings: Array<CrossingAnnotation> = []
    var selectedPort: CrossingAnnotation?
    let centerCoordinates = CLLocationCoordinate2DMake(30.874890, -106.286547)
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let locationManager = CLLocationManager()
    private let annotationIdentifier = MKAnnotationView.description()

    let mockCoordinates = CLLocationCoordinate2DMake(26.115171, -97.493336)

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.white
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        UIApplication.shared.statusBarStyle = .lightContent
        aboutButton.isSelected = false
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(getDelayTime(forCrossing: "San Ysidro", crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>"))
        loadMap(rangeSpan: 2500000)

        control.selectedSegmentIndex = 0

        crossings = getCrossings()
        for item in crossings {
            mapView.addAnnotation(item)
        }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.mapView.removeFromSuperview()
        mapView.delegate = nil
        mapView = nil
    }

    func loadMap(rangeSpan: CLLocationDistance) {
        let region = MKCoordinateRegionMakeWithDistance(centerCoordinates, rangeSpan, rangeSpan)
        mapView.region = region

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Data" {
            let secondScene = segue.destination as! DataViewController
            secondScene.crossing = selectedPort!.xmlIdentifier!
            secondScene.crossingTitle = selectedPort!.title!
            selectedPort = nil
            secondScene.rootController = self
        }
        if segue.identifier == "Info" {
            let secondScene = segue.destination as! InfoViewController
            secondScene.rootController = self
        }
        if segue.identifier == "Table" {
            let secondScene = segue.destination as! TableListViewController
            secondScene.crossings = self.crossings
            secondScene.rootViewController = self
        }
    }

    @IBAction func buttonPressed(sender: Any?) {
    }

    @IBAction func tableButtonPressed(sender: Any?) {
    }

    @IBAction func toggle(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = .satellite
            control.tintColor! = .white
            titleLabel.textColor = .white
            aboutButton.titleLabel!.textColor! = .white
            UIApplication.shared.statusBarStyle = .lightContent
            activityIndicator.color! = .white
            showTableButton.titleLabel!.textColor! = .white
        } else if sender.selectedSegmentIndex == 1 {
            mapView.mapType = .standard
            control.tintColor! = .black
            titleLabel.textColor = .black
            aboutButton.titleLabel!.textColor! = .black
            UIApplication.shared.statusBarStyle = .default
            activityIndicator.color! = .black
            showTableButton.titleLabel!.textColor! = .black
        }
    }

    //This function takes forever and a lot of the time it just doesn't work at all. Especially once it's already been pressed once, it returns, and then I try to press it again.
    //Also did I do the privacy settings alert right? Did I miss anything important w/r/t CLLocationManager.authorizationStatus() or did I cover all the bases?
    //I commented out the regional restriction for testing purposes

    @IBAction func checkUserLocationStatus() {
        if CLLocationManager.locationServicesEnabled() == false || CLLocationManager.authorizationStatus() == .denied {
            let alert = UIAlertController(title: "Location Service Disabled", message: "Turn on location services to use this feature", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
                let settingsURL = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.open(settingsURL!, options: [:], completionHandler: nil)
            }
            alert.addAction(action)
            alert.addAction(settingsAction)
            self.present(alert, animated: true)
            self.locationManager.requestAlwaysAuthorization()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            let alert = UIAlertController(title: "Error", message: "Undetermined Location", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
        } else {
            /*if Locale.current.regionCode! != "MX" {
                let regionAlert = UIAlertController(title: "Feature Unavailable", message: "This feature is only available for users travelling from Mexico to the U.S.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                regionAlert.addAction(action)
                present(regionAlert, animated: true)
            } else {*/
                getFastestRoute()
            }
        //}
    }

    func getFastestRoute() {
        activityIndicator.startAnimating()
        let group = DispatchGroup()
        group.enter()
        var travelTimes: Array<TravelTime> = []
        var increment: Int = 0
        for item in crossings {
            let request = MKDirectionsRequest()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: item.coordinate))
            let directions = MKDirections(request: request)
            directions.calculate { (response, error) in
                if let response = response {
                    let delay = getDelayTime(forCrossing: item.xmlIdentifier!, crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>")
                    if delay != "N/A" && delay != "" {
                        let delayTimeSeconds = Double(Int(delay)!) * 60
                        travelTimes.append(TravelTime(crossingAnnotation: item, travelTime: (response.routes[0].expectedTravelTime as Double)+delayTimeSeconds))
                        increment += 1
                    } else {
                        increment += 1
                    }
                    if increment == 39 {
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: .main) {
            travelTimes.sort(by: { (x, y) in
                x.travelTime < y.travelTime
            })
            let fastestCrossing = travelTimes[0]
            print(fastestCrossing.travelTime)
            let crossingHours = Int(fastestCrossing.travelTime/3600)
            let crossingMinutes = (Int(fastestCrossing.travelTime) - (crossingHours * 3600)) / 60
            let crossingMessage: String?
            if crossingHours == 0 {
                crossingMessage = "\(crossingMinutes) minutes"
            } else {
                crossingMessage = "\(crossingHours) hours \(crossingMinutes) minutes"
            }
            self.mapView.region = MKCoordinateRegionMakeWithDistance(fastestCrossing.crossingAnnotation.coordinate, 30000, 30000)
            let alert = UIAlertController(title: nil, message: "Your most efficient option crossing option is \n\n\(fastestCrossing.crossingAnnotation.title!)\n\nTotal travel estimate (including travel and border delays) is \n\n\(crossingMessage!)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            let directionsAction = UIAlertAction(title: "Directions", style: .default) { (alert) in
                let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                MKMapItem(placemark: MKPlacemark(coordinate: fastestCrossing.crossingAnnotation.coordinate)).openInMaps(launchOptions: options)
            }
            alert.addAction(okAction)
            alert.addAction(directionsAction)
            self.activityIndicator.stopAnimating()
            travelTimes = []
            self.present(alert, animated: true)
        }
    }
}

extension ViewController {

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let port = view.annotation?.coordinate {
            for item in crossings {
                if item.coordinate.latitude == port.latitude && item.coordinate.longitude == port.longitude {
                    //showData(crossing: item.xmlIdentifier!, controller: self, crossingTitle: item.title!)
                    selectedPort = item
                    performSegue(withIdentifier: "Data", sender: Any?.self)
                }
            }
        }
        mapView.deselectAnnotation(view.annotation!, animated: true)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            // I used pin here MKPinAnnotationView
            // You can use MKAnnotationView and then set your own custom image if you want for each pin!
        }

        return annotationView
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
    }
}

