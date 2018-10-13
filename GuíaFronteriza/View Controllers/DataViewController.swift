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

        /*var upperIndicatorBorder = UIView(frame: CGRect(x: 0, y: 36.5, width: pickerView.frame.width, height: 0.5))
        var lowerIndicatorborder = UIView(frame: CGRect(x: 0, y: 63, width: pickerView.frame.width, height: 0.5))
        var lowerIndicatorBorder2 = UIView(frame: CGRect(x: 0, y: 62.5, width: pickerView.frame.width, height: 0.5))
        var hoursTop1: UIView = UIView(frame: CGRect(x: 0, y: 0, width: hoursLabel.frame.width, height: 0.5))
        var hoursTop2: UIView = UIView(frame: CGRect(x: 0, y: 0.5, width: hoursLabel.frame.width, height: 0.5))
        var hoursBottom1: UIView = UIView(frame: CGRect(x: 0, y: (hoursLabel.frame.height - 1), width: hoursLabel.frame.width, height: 0.5))
        upperIndicatorBorder.layer.isOpaque = true
        lowerIndicatorborder.layer.isOpaque = true
        lowerIndicatorborder.backgroundColor = UIColor.lightGray
        lowerIndicatorBorder2.isOpaque = true
        hoursTop1.backgroundColor = UIColor.lightGray
        hoursTop1.isOpaque = true
        hoursTop2.backgroundColor = UIColor.lightGray
        hoursTop2.alpha = 0.65
        hoursBottom1.backgroundColor = UIColor.lightGray
        hoursBottom1.alpha = 0.65
        hoursLabel.textColor = UIColor.white
        upperIndicatorBorder.backgroundColor = UIColor.lightGray
        lowerIndicatorborder.backgroundColor = UIColor.lightGray
        pickerView.addSubview(upperIndicatorBorder)
        pickerView.addSubview(lowerIndicatorborder)
        pickerView.addSubview(lowerIndicatorBorder2)
        //hoursLabel.addSubview(hoursTop1)
        hoursLabel.addSubview(hoursTop2)
        hoursLabel.addSubview(hoursBottom1)*/

        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.white
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        directionsButton.layer.cornerRadius = 7
        notificationButton.layer.cornerRadius = 7


        UIApplication.shared.statusBarStyle = .lightContent
        titleLabel.text! = crossingTitle!
        getData(crossing: crossing!, crossingTitle: crossingTitle!)

        dbRef = Database.database().reference().child("UserSettings")
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

    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {


    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Notifications" {
            let nextScene = segue.destination as! NotificationViewController
            nextScene.selectedCrossing = self.selectedCrossing
        }
    }

    @IBAction func notificationsButton(sender: Any?) {
        performSegue(withIdentifier: "Notifications", sender: Any?.self)
    }

    @IBAction func buttonPressed(sender: Any?) {
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

    @IBAction func directionsButtonPressed(sender: Any?) {
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        MKMapItem(placemark: MKPlacemark(coordinate: selectedCrossing!.coordinate)).openInMaps(launchOptions: options)
    }
}
