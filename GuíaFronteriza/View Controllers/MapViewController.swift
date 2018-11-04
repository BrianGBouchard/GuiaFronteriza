import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var aboutButton: UIButton!
    @IBOutlet var crossingButton: UIButton!
    @IBOutlet var control: UISegmentedControl!

    var crossings: Array<CrossingAnnotation> = []
    var selectedPort: CrossingAnnotation?
    var selectedCrossingTitle: String?
    var selectedCrossingDelay: String?
    var selectedFastestCrossing: TravelTime?
    let centerCoordinates = CLLocationCoordinate2DMake(30.874890, -106.286547)
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    let locationManager = CLLocationManager()
    private let annotationIdentifier = MKAnnotationView.description()

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.white
        activityIndicator.hidesWhenStopped = true

        mapView.showsUserLocation = true

        //self.tabBarController!.tabBar.layer.borderWidth = 1
        self.tabBarController?.tabBar.layer.borderColor = UIColor.white.cgColor
        
        view.addSubview(activityIndicator)
        aboutButton.isSelected = false
        super.viewDidLoad()
        print(getDelayTime(forCrossing: "San Ysidro", crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>"))
        loadMap(rangeSpan: 2500000)
        crossingButton.layer.borderWidth = 1
        crossingButton.layer.cornerRadius = 7
        crossingButton.layer.borderColor = UIColor.white.cgColor

        control.selectedSegmentIndex = 0

        crossings = getCrossings()
        for item in crossings {
            mapView.addAnnotation(item)
        }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        for item in crossings {
            print(item.xmlIdentifier!)
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.setNeedsStatusBarAppearanceUpdate()
    }

    func loadMap(rangeSpan: CLLocationDistance) {
        let region = MKCoordinateRegion(center: centerCoordinates, latitudinalMeters: rangeSpan, longitudinalMeters: rangeSpan)
        mapView.region = region

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Data" {
            let navigationController = segue.destination as! UINavigationController
            let secondScene = navigationController.viewControllers[0] as! DataViewController
            secondScene.crossing = selectedPort?.xmlIdentifier
            secondScene.crossingTitle = selectedPort?.title
            secondScene.selectedCrossing = selectedPort
            selectedPort = nil
            secondScene.rootController = self
        }
        if segue.identifier == "Info" {
            let secondScene = segue.destination as! InfoViewController
            secondScene.rootController = self
        }
        if segue.identifier == "FastestCrossing" {
            let secondScene = segue.destination as! FastestCrossingViewController
            secondScene.rootController = self
            secondScene.crossingName = selectedCrossingTitle
            secondScene.delay = selectedCrossingDelay
            secondScene.selectedFastestCrossing = self.selectedFastestCrossing
        }
    }

    @IBAction func buttonPressed(sender: Any?) {
    }

    @IBAction func toggle(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = .satellite
            control.tintColor! = .white
            titleLabel.textColor = .white
            aboutButton.titleLabel!.textColor! = .white
            activityIndicator.color! = .white
            crossingButton.titleLabel?.textColor! = .white
            crossingButton.layer.borderColor = UIColor.white.cgColor

        } else if sender.selectedSegmentIndex == 1 {
            mapView.mapType = .standard
            control.tintColor! = .black
            titleLabel.textColor = .black
            aboutButton.titleLabel!.textColor! = .black
            activityIndicator.color! = .black
            crossingButton.titleLabel!.textColor! = .black
            crossingButton.layer.borderColor = UIColor.black.cgColor
        }

        self.setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if control!.selectedSegmentIndex == 0 {
            return .lightContent
        } else {
            return .default
        }
    }

    @IBAction func checkUserLocationStatus() {
        if CLLocationManager.locationServicesEnabled() == false || CLLocationManager.authorizationStatus() == .denied {
            let alert = UIAlertController(title: "Location Service Disabled", message: "Turn on location services to use this feature", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
                let settingsURL = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(settingsURL!, options: [:], completionHandler: nil)
            }
            alert.addAction(action)
            alert.addAction(settingsAction)

            self.present(alert, animated: true)

        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            let alert = UIAlertController(title: "Error", message: "Undetermined Location", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
        } else {
            if Locale.current.regionCode! != "MX" {
                let regionAlert = UIAlertController(title: "Feature unavailable in your region", message: "This feature is only available for users travelling from Mexico to the U.S. (If this problem persists, change your phone's Region settings to 'Mexico')", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default) { (alert) in
                    //FIX THIS
                    if self.titleLabel.textColor! == .black {
                        self.control.selectedSegmentIndex = 1
                    } else { self.control.selectedSegmentIndex = 0 }
                    if self.control.selectedSegmentIndex == 0 {
                        self.aboutButton.titleLabel?.textColor! = .white
                        self.crossingButton.titleLabel?.textColor! = .white
                        self.crossingButton.layer.borderColor = UIColor.white.cgColor
                    } else if self.control.selectedSegmentIndex == 1 {
                        self.aboutButton.titleLabel?.textColor = .black
                        self.crossingButton.titleLabel?.textColor! = .black
                        self.crossingButton.layer.borderColor = UIColor.black.cgColor
                    }
                }
                regionAlert.addAction(action)
                present(regionAlert, animated: true)
            } else {
                getFastestRoute()
            }
        }
    }

    func getFastestRoute() {
        activityIndicator.startAnimating()
        let maxNumberOfDistnces: Int = 5
        guard let userLocation = mapView.userLocation.location else { return }
        let group = DispatchGroup()
        group.enter()
        var travelTimes: Array<TravelTime> = []
        let distances = crossings.map { crossing in
            (crossing: crossing, distance: userLocation.distance(from: CLLocation(latitude: crossing.coordinate.latitude, longitude: crossing.coordinate.longitude)))
            }.sorted { $0.distance < $1.distance }
        let closestDistances = distances[..<maxNumberOfDistnces]
        var increment: Int = 0
        for item in closestDistances {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: item.crossing.coordinate))
            let directions = MKDirections(request: request)
            directions.calculate { (response, error) in
                if let response = response {
                    let delay = getDelayTime(forCrossing: item.crossing.xmlIdentifier!, crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>")
                    if delay != "N/A" && delay != "" {
                        let delayTimeSeconds = Double(Int(delay)!) * 60
                        travelTimes.append(TravelTime(crossingAnnotation: item.crossing, travelTime: (response.routes[0].expectedTravelTime as Double)+delayTimeSeconds))
                        increment += 1
                    } else {
                        increment += 1
                    }

                    }

                if increment >= maxNumberOfDistnces {
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            travelTimes.sort(by: { (x, y) in
                x.travelTime < y.travelTime
            })
            let fastestCrossing = travelTimes[0]
            print(fastestCrossing.travelTime)
            var crossingMessage: String = ""
            let crossingHours = Int(fastestCrossing.travelTime/3600)
            let crossingMinutes = (Int(fastestCrossing.travelTime) - (crossingHours * 3600)) / 60
            if crossingHours == 0 {
                crossingMessage = "\(crossingMinutes) minutes"
            } else {
                crossingMessage = "\(crossingHours) hours \(crossingMinutes) minutes"
            }
            self.selectedCrossingTitle = "\(fastestCrossing.crossingAnnotation.title!)"
            self.selectedCrossingDelay = "\(crossingMessage)"
            self.activityIndicator.stopAnimating()
            self.selectedFastestCrossing = fastestCrossing
            travelTimes = []
            self.mapView.region = MKCoordinateRegion(center: fastestCrossing.crossingAnnotation.coordinate,
                                                     latitudinalMeters: 25000,
                                                     longitudinalMeters: 25000)
            self.performSegue(withIdentifier: "FastestCrossing", sender: self)
        }
    }
}


// MARK : MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {

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
        }

        return annotationView
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
}

