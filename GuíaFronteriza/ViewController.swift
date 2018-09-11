import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var aboutButton: UIButton!
    @IBOutlet var showTableButton: UIButton!
    @IBOutlet var control: UISegmentedControl!

    var crossings: Array<CrossingAnnotation> = []
    var selectedPort: CrossingAnnotation?
    let centerCoordinates = CLLocationCoordinate2DMake(30.874890, -106.286547)
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private let annotationIdentifier = MKAnnotationView.description()

    override func viewDidLoad() {

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

        let andrade = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(32.718132, -114.728626), title: "Andrade")
        andrade.xmlIdentifier = "Andrade"
        crossings.append(andrade)

        let brownsvilleBM = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(25.891932, -97.504709), title: "Brownsville: \nB&M Bridge")
        brownsvilleBM.xmlIdentifier = "535501"
        crossings.append(brownsvilleBM)

        let brownsvilleGateway = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(25.898732, -97.497447), title: "Brownsville: \nGateway Bridge")
        brownsvilleGateway.xmlIdentifier = "Gateway"
        crossings.append(brownsvilleGateway)

        let brownsvilleLosIndios = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(26.029156, -97.738830), title: "Brownsville: \nLos Indios")
        brownsvilleLosIndios.xmlIdentifier = "535503"
        crossings.append(brownsvilleLosIndios)

        let brownsvilleVeterans = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(25.883627, -97.476396), title: "Brownsville: \nVeterans International Bridge")
        brownsvilleVeterans.xmlIdentifier = "535502"
        crossings.append(brownsvilleVeterans)

        let calexicoEast = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(32.673329, -115.388003), title: "Calexico: East")
        calexicoEast.xmlIdentifier = "250301"
        crossings.append(calexicoEast)

        let calexicoWest = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(32.665037, -115.496501), title: "Calexico: West")
        calexicoWest.xmlIdentifier = "250302"
        crossings.append(calexicoWest)

        let columbus = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.783712, -107.627886), title: "Columbus")
        columbus.xmlIdentifier = "240601"
        crossings.append(columbus)

        let delRio = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(29.326843, -100.927676), title: "Del Rio")
        delRio.xmlIdentifier = "230201"
        crossings.append(delRio)

        let douglas = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.334092, -109.560479), title: "Douglas \n(Raul Hector Castro)")
        douglas.xmlIdentifier = "260101"
        crossings.append(douglas)

        let eaglePass1 = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(28.705502, -100.511719), title: "Eagle Pass (Bridge I)")
        eaglePass1.xmlIdentifier = "230301"
        crossings.append(eaglePass1)

        let eaglePass2 = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(28.697709, -100.510603), title: "Eagle Pass (Bridge II)")
        eaglePass2.xmlIdentifier = "230302"
        crossings.append(eaglePass2)

        let elPasoBOTA = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.764646, -106.451573), title: "El Paso: \nBridge of the Americas")
        elPasoBOTA.xmlIdentifier = "240201"
        crossings.append(elPasoBOTA)

        let elPasoPDN = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.747688, -106.487023), title: "El Paso: \nPaso Del Norte")
        elPasoPDN.xmlIdentifier = "240202"
        crossings.append(elPasoPDN)

        let elPasoStanton = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.748207, -106.482737), title: "El Paso: \nStanton DCL")
        elPasoStanton.xmlIdentifier = "240204"
        crossings.append(elPasoStanton)

        let elPasoYsleta = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.671043, -106.337875), title: "El Paso: \nYsleta")
        elPasoYsleta.xmlIdentifier = "240203"
        crossings.append(elPasoYsleta)

        let fabens = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.432821, -106.147965), title: "Fabens: Tornillo")
        fabens.xmlIdentifier = "240401"
        crossings.append(fabens)

        let fortHancock = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.273255, -105.854507), title: "Fort Hancock")
        fortHancock.xmlIdentifier = "124501"
        crossings.append(fortHancock)

        let hpAnzalduas = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(26.116480, -98.318232), title: "Hidalgo/Pharr: \nAnzalduas Bridge")
        hpAnzalduas.xmlIdentifier = "230503"
        crossings.append(hpAnzalduas)

        let hpHidalgo = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(26.095110, -98.271524), title: "Hidalgo/Pharr: \nHidalgo")
        hpHidalgo.xmlIdentifier = "230501"
        crossings.append(hpHidalgo)

        let hpPharr = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(26.066707, -98.205257), title: "Hidalgo/Pharr: \nPharr")
        hpPharr.xmlIdentifier = "230502"
        crossings.append(hpPharr)

        let laredoI = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(27.499503, -99.507350), title: "Laredo: Bridge I")
        laredoI.xmlIdentifier = "230401"
        crossings.append(laredoI)

        let laredoII = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(27.500116, -99.502711), title: "Laredo: Bridge II")
        laredoII.xmlIdentifier = "230402"
        crossings.append(laredoII)

        let laredoCS = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(27.699804, -99.745565), title: "Laredo: \nColombia Solidarity")
        laredoCS.xmlIdentifier = "230403"
        crossings.append(laredoCS)

        let laredoWTB = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(27.597210, -99.536923), title: "Laredo: \nWorld Trade Bridge")
        laredoWTB.xmlIdentifier = "230404"
        crossings.append(laredoWTB)

        let lukeville = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.880066, -112.817488), title: "Lukeville")
        lukeville.xmlIdentifier = "260201"
        crossings.append(lukeville)

        let naco = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.334063, -109.948531), title: "Naco")
        naco.xmlIdentifier = "260301"
        crossings.append(naco)

        let nogales = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.332760, -110.965188), title: "Nogales: Mariposa")
        nogales.xmlIdentifier = "260402"
        crossings.append(nogales)

        let nogalesMorleyGate = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.332797, -110.942292), title: "Nogales: \nMorley Gate")
        nogalesMorleyGate.xmlIdentifier = "260403"
        crossings.append(nogalesMorleyGate)

        let otayMesa = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(32.550216, -116.938629), title: "Otay Mesa")
        otayMesa.xmlIdentifier = "250601"
        crossings.append(otayMesa)

        let presidio = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(29.561846, -104.394687), title: "Presidio")
        presidio.xmlIdentifier = "240301"
        crossings.append(presidio)

        let progresoDIB = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(26.065733, -98.075755), title: "Progreso: \nDonna International Bridge")
        progresoDIB.xmlIdentifier = "230902"
        crossings.append(progresoDIB)

        let progreso = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(26.062097, -97.950000), title: "Progreso")
        progreso.xmlIdentifier = "230901"
        crossings.append(progreso)

        let rioGrandeCity = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(26.365874, -98.802351), title: "Rio Grande City")
        rioGrandeCity.xmlIdentifier = "230701"
        crossings.append(rioGrandeCity)

        let roma = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(26.403853, -99.019141), title: "Roma")
        roma.xmlIdentifier = "231001"
        crossings.append(roma)

        let sanLuis = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(32.485213, -114.782291), title: "San Luis")
        sanLuis.xmlIdentifier = "260801"
        crossings.append(sanLuis)

        let santaTeresa = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(31.784007, -106.679516), title: "Santa Teresa")
        santaTeresa.xmlIdentifier = "240801"
        crossings.append(santaTeresa)

        let sanYsidro = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(32.542564, -117.029342), title: "San Ysidro")
        sanYsidro.xmlIdentifier = "San Ysidro"
        crossings.append(sanYsidro)

        let tecate = CrossingAnnotation(coordinate: CLLocationCoordinate2DMake(32.576332, -116.627447), title: "Tecate")
        tecate.xmlIdentifier = "Tecate"
        crossings.append(tecate)

        for item in crossings {
            mapView.addAnnotation(item)
        }

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
}


