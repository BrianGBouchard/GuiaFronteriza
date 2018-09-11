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
    var tableRootController: TableListViewController?
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    override func viewDidLoad() {

        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.white
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        titleLabel.text! = crossingTitle!
        getData(crossing: crossing!, crossingTitle: crossingTitle!)
    }

    func getData(crossing: String, crossingTitle: String) {
        var data: [String: String] = [:]
        DispatchQueue.global(qos: .background).async {
            let updateTime = getUpdateTime(forCrossing: crossing, crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>")
            data["updateTime"] = updateTime
            let portStatus = getPortStatus(forCrossing: crossing)
            data["portStatus"] = portStatus
            let delayTime = getDelayTime(forCrossing: crossing, crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>")
            data["delayTime"] = delayTime
            self.showData(data: data)
        }
    }

    func showData(data: [String: String]) {

        DispatchQueue.main.async {
            if data["delayTime"] == "N/A" || data["delaytime"] == "" {
                self.delayTimeText.text! = "Delay Time: N/A"
            } else {
                self.delayTimeText.text! = "Delay: \(String(describing: data["delayTime"]!)) minutes"
            }
            self.updateTimeText.text! = "Last Updated: \(String(describing: data["updateTime"]!))"
            self.portStatusText.text! = "Port Status: \(String(describing: data["portStatus"]!))"
            self.activityIndicator.stopAnimating()
        }
    }

    @IBAction func buttonPressed(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
        if rootController != nil {
            rootController?.activityIndicator.stopAnimating()
        }
        if tableRootController != nil {
            tableRootController?.activityIndicator.stopAnimating()
        }
    }
}
