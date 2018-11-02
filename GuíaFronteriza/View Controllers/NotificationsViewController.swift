import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import UIKit
import FirebaseMessaging

class NotificationViewController: UIViewController {

    @IBOutlet var timePicker: UIPickerView!
    @IBOutlet var notifyButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var successLabel: UILabel!

    var selectedCrossing: CrossingAnnotation?
    var hourValue: Int = 0
    var minuteValue: Int = 0
    var totalMinutes: Int = 0
    let hoursArray = [0,1,2,3]
    let minutesArray = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59]
    let activityMonitor = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var dbRef: DatabaseReference!

    override func viewDidLoad() {
        activityMonitor.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityMonitor.color = UIColor.white
        activityMonitor.hidesWhenStopped = true
        view.addSubview(activityMonitor)
        successLabel.isHidden = true
        successLabel.layer.cornerRadius = 10
        successLabel.clipsToBounds = true
        super.viewDidLoad()
        self.navigationItem.title = "Notification Settings"
        dbRef = Database.database().reference().child("UserSettings")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let upperIndicatorBorder = UIView(frame: CGRect(x: 0, y: 82.5, width: timePicker.frame.width, height: 0.5))
        let lowerIndicatorborder = UIView(frame: CGRect(x: 0, y: 109, width: timePicker.frame.width, height: 0.5))
        let lowerIndicatorBorder2 = UIView(frame: CGRect(x: 0, y: 88.5, width: timePicker.frame.width, height: 0.5))
        upperIndicatorBorder.layer.isOpaque = true
        lowerIndicatorborder.layer.isOpaque = true
        lowerIndicatorborder.backgroundColor = UIColor.lightGray
        lowerIndicatorBorder2.isOpaque = true
        upperIndicatorBorder.backgroundColor = UIColor.lightGray
        lowerIndicatorborder.backgroundColor = UIColor.lightGray
        timePicker.addSubview(upperIndicatorBorder)
        timePicker.addSubview(lowerIndicatorborder)
        timePicker.addSubview(lowerIndicatorBorder2)

        let greyRect = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: timePicker.frame.height))
        greyRect.backgroundColor = UIColor.darkGray
        greyRect.isOpaque = true
        greyRect.isUserInteractionEnabled = false
        timePicker.addSubview(greyRect)

        let hours = UILabel(frame: CGRect(x: 113, y: 84, width: 65, height: 25))
        hours.text = "Hours"
        hours.textColor = UIColor.white
        hours.font = UIFont(name: "Menlo", size: 15.0)!
        timePicker.addSubview(hours)

        let minutes = UILabel(frame: CGRect(x: 268, y: 84, width: 65, height: 25))
        minutes.text = "Min"
        minutes.textColor = UIColor.white
        minutes.font = UIFont(name: "Menlo", size: 15.0)!
        timePicker.addSubview(minutes)

        notifyButton.layer.cornerRadius = 7
        notifyButton.clipsToBounds = true
        cancelButton.layer.cornerRadius = 7
        cancelButton.clipsToBounds = true

        notifyButton.layer.cornerRadius = 7
        notifyButton.clipsToBounds = true
        cancelButton.layer.cornerRadius = 7
        cancelButton.clipsToBounds = true

        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white

        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        view.backgroundColor = UIColor.white
        self.view.addSubview(view)

    }

    @IBAction func notifyButtonPressed(sender: Any?) {
        activityMonitor.startAnimating()
        guard let userID = Auth.auth().currentUser?.uid, let tokenID = Messaging.messaging().fcmToken else {
            print("error, user not logged in")
            return
        }
        var shouldDisplayLabel = true

        let ref = dbRef.child("\(userID)")
        ref.child("Borders").observeSingleEvent(of: .childAdded) { (snapshot) in
            if shouldDisplayLabel == true {
                shouldDisplayLabel = false
                let group = DispatchGroup()
                group.enter()
                self.activityMonitor.stopAnimating()
                self.successLabel.fadeTransition(0.2)
                self.successLabel.isHidden = false
                group.leave()
                group.notify(queue: .main) {
                    let group2 = DispatchGroup()
                    group2.enter()
                    sleep(1)
                    group2.leave()
                    group2.notify(queue: .main) {
                        self.successLabel.fadeOutTransition(0.2)
                        self.successLabel.isHidden = true
                    }
                }
            }
        }

        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                if value["Token"] == nil {
                    ref.setValue(["Token":"\(tokenID)"])
                }
                if value["Borders"] == nil {
                    ref.child("Borders")
                }
            } else {
                ref.setValue(["Token": "\(tokenID)"])
                ref.child("Borders")
            }

            let selectedBorderRef = ref.child("Borders").child("\(String(describing: self.selectedCrossing!.xmlIdentifier!))")
            selectedBorderRef.setValue(["Time": self.totalMinutes])
            print(tokenID)
        }
    }

    @IBAction func cancelButtonPressed(sender: Any?) {
        activityMonitor.startAnimating()
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        dbRef.observe(.childChanged) { (snapshot) in
            let group = DispatchGroup()
            group.enter()
            self.activityMonitor.stopAnimating()
            self.successLabel.fadeTransition(0.2)
            self.successLabel.isHidden = false
            group.leave()
            group.notify(queue: .main) {
                let group2 = DispatchGroup()
                group2.enter()
                sleep(1)
                group2.leave()
                group2.notify(queue: .main) {
                    self.successLabel.fadeOutTransition(0.2)
                    self.successLabel.isHidden = true
                }
            }
        }
        dbRef.child("\(userID)").child("Borders").child("\(selectedCrossing!.xmlIdentifier!)").removeValue()
    }
}

extension NotificationViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hoursArray.count
        } else {
            return minutesArray.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if component == 0 {
            let title = NSAttributedString(string: String(hoursArray[row]), attributes: [NSAttributedStringKey.font:UIFont(name: "Menlo", size: 15.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
            return title
        } else {
            let title = NSAttributedString(string: String(minutesArray[row]), attributes: [NSAttributedStringKey.font:UIFont(name: "Menlo", size: 15.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
            return title
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            hourValue = (hoursArray[row] * 60)
        } else {
            minuteValue = (minutesArray[row])
        }
        totalMinutes = hourValue + minuteValue
    }
}
