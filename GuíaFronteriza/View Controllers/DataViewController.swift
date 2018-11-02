import Foundation
import UIKit
import MapKit
import Firebase
import FirebaseDatabase

class DataViewController: UIViewController {

    @IBOutlet var updateTimeText: UITextView!
    @IBOutlet var portStatusText: UITextView!
    @IBOutlet var delayTimeText: UITextView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var directionsButton: UIButton!
    @IBOutlet var notificationButton: UIButton!

    var selectedCrossing: CrossingAnnotation?
    var crossing: String?
    var crossingTitle: String?
    var rootController: ViewController?
    var tableRootController: TableListViewController?
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    var dbRef: DatabaseReference!

    override func viewDidLoad() {
        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.white
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        directionsButton.layer.cornerRadius = 7
        notificationButton.layer.cornerRadius = 7

        let button = UIBarButtonItem(barButtonSystemItem: .done , target: self, action: #selector(self.barButtonPressed(sender:)))
        button.title = "Back"
        button.setTitleTextAttributes([NSAttributedStringKey.font:UIFont(name: "Menlo", size: 15.0)], for: .normal)
        navigationItem.leftBarButtonItem = button

        UIApplication.shared.statusBarStyle = .lightContent
        titleLabel.text! = crossingTitle!
        self.navigationItem.title = "Border Crossing"
        getData(crossing: crossing!, crossingTitle: crossingTitle!)

        dbRef = Database.database().reference().child("UserSettings")
    }

    override func viewDidLayoutSubviews() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        view.backgroundColor = UIColor.white
        self.view.addSubview(view)
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
            if data["delayTime"] == "N/A" || data["delayTime"] == "" {
                self.delayTimeText.text! = "Delay Time: N/A"
            } else {
                self.delayTimeText.text! = "Delay: \(String(describing: data["delayTime"]!)) minutes"
            }
            self.updateTimeText.text! = "Last Updated: \(String(describing: data["updateTime"]!))"
            self.portStatusText.text! = "Port Status: \(String(describing: data["portStatus"]!))"
            self.activityIndicator.stopAnimating()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Notifications" {
            let button = UIBarButtonItem()
            button.title = "Back"
            navigationItem.backBarButtonItem = button
            let nextScene = segue.destination as! NotificationViewController
            nextScene.selectedCrossing = self.selectedCrossing
        }
    }

    @objc func barButtonPressed(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
        if rootController != nil {
            rootController?.activityIndicator.stopAnimating()
        }
        if tableRootController != nil {
            tableRootController?.activityIndicator.stopAnimating()
        }
        if rootController?.control.selectedSegmentIndex == 1 {
            UIApplication.shared.statusBarStyle = .default
        }
    }

    @IBAction func notificationsButton(sender: Any?) {
        performSegue(withIdentifier: "Notifications", sender: Any?.self)
    }

    @IBAction func directionsButtonPressed(sender: Any?) {
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        MKMapItem(placemark: MKPlacemark(coordinate: selectedCrossing!.coordinate)).openInMaps(launchOptions: options)
    }
}
