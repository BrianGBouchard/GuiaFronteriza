import Foundation
import UIKit
import MapKit

class FastestCrossingViewController: UIViewController {

    var rootController: ViewController?
    var crossingName: String?
    var delay: String?
    var selectedFastestCrossing: TravelTime?

    @IBOutlet var crossingNameLabel: UILabel!
    @IBOutlet var delayLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        crossingNameLabel.text! = crossingName!
        delayLabel.text! = delay!
    }

    @IBAction func buttonPressed(sender: Any?) {
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        MKMapItem(placemark: MKPlacemark(coordinate: selectedFastestCrossing!.crossingAnnotation.coordinate)).openInMaps(launchOptions: options)
    }

    @IBAction func dismissButton(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
        if rootController?.control!.selectedSegmentIndex == 0 {
            rootController?.aboutButton!.titleLabel!.textColor! = .white
            rootController?.crossingButton.titleLabel?.textColor! = .white
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            rootController?.aboutButton!.titleLabel!.textColor! = .black
            rootController?.crossingButton.titleLabel?.textColor! = .black
            UIApplication.shared.statusBarStyle = .default
        }
    }
}
