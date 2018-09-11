import Foundation
import UIKit

class DataViewController: UIViewController {

    @IBOutlet var updateTimeText: UITextView!
    @IBOutlet var portStatusText: UITextView!
    @IBOutlet var delayTimeText: UITextView!
    @IBOutlet var titleLabel: UILabel!

    var crossing: String?
    var crossingTitle: String?

    var rootController: ViewController?

    override func viewDidLoad() {
        titleLabel.text! = crossingTitle!
        showData(crossing: crossing!, crossingTitle: crossingTitle!)
    }

    func showData(crossing: String, crossingTitle: String) {
        let updateTime = getUpdateTime(forCrossing: crossing, crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>")
        updateTimeText.text! = "Last Updated: \(updateTime)"
        let portStatus = getPortStatus(forCrossing: crossing)
        portStatusText.text! = "Port Status: \(portStatus)"
        let delayTime = getDelayTime(forCrossing: crossing, crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>")
        if delayTime == "N/A" || delayTime == "" {
            delayTimeText.text! = "Delay Time: N/A"
        } else {
            delayTimeText.text! = "Delay: \(delayTime) minutes"
        }
    }

    @IBAction func buttonPressed(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
        rootController?.activityIndicator.stopAnimating()
    }
}
