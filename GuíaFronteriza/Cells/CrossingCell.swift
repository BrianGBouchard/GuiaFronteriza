import UIKit

class CrossingCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var portStatusLabel: UILabel!
    @IBOutlet weak var delayTimeLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""
        self.updateTimeLabel.text = "Loading..."
        self.portStatusLabel.text = ""
        self.delayTimeLabel.text = ""
    }

    func getData(crossing: String, crossingTitle: String) {
        var crossingData: [String:String] = [:]
        DispatchQueue.global(qos: .background).async { [weak self] in
            let updateTime = getUpdateTime(forCrossing: crossing, crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>")
            crossingData["updateTime"] = updateTime
            let portStatus = getPortStatus(forCrossing: crossing)
            crossingData["portStatus"] = portStatus
            let delayTime = getDelayTime(forCrossing: crossing, crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>")
            crossingData["delayTime"] = delayTime
            self?.updateView(data: crossingData)
        }
    }

    func updateView(data: [String: String]) {
        DispatchQueue.main.async { [weak self] in
            let group = DispatchGroup()
            group.enter()
            self?.updateTimeLabel.text! = "Last updated: \(String(describing: data["updateTime"]!))"
            self?.updateTimeLabel.isHidden = true
            self?.portStatusLabel.text! = "Port status: \(String(describing: data["portStatus"]!))"
            self?.portStatusLabel.isHidden = true

            if data["delayTime"] == "N/A" || data["delayTime"] == "" {
                self?.delayTimeLabel.text! = "Delay: N/A"
                self?.delayTimeLabel.isHidden = true
            } else {
                self?.delayTimeLabel.text! = "Delay: \(String(describing: data["delayTime"]!)) minutes"
                self?.delayTimeLabel.isHidden = true
            }
            group.leave()
            group.notify(queue: .main) {
                self?.updateTimeLabel.fadeTransition(0.4)
                self?.updateTimeLabel.isHidden = false
                self?.portStatusLabel.fadeTransition(0.4)
                self?.portStatusLabel.isHidden = false
                self?.delayTimeLabel.fadeTransition(0.4)
                self?.delayTimeLabel.isHidden = false
            }
        }
    }
}
extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionFade)
    }

    func fadeOutTransition(_ duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionFade)
    }
}
