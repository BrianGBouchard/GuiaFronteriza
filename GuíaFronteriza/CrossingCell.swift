//
//  CrossingCell.swift
//  GuíaFronteriza
//
//  Created by Brian Bouchard on 9/11/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import UIKit

class CrossingCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var portStatusLabel: UILabel!
    @IBOutlet weak var delayTimeLabel: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func getData(crossing: String, crossingTitle: String) {
        var crossingData: [String:String] = [:]
        DispatchQueue.global(qos: .background).async {
            let updateTime = getUpdateTime(forCrossing: crossing, crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>")
            crossingData["updateTime"] = updateTime
            let portStatus = getPortStatus(forCrossing: crossing)
            crossingData["portStatus"] = portStatus
            let delayTime = getDelayTime(forCrossing: crossing, crossingType: "<passenger_vehicle_lanes>", laneType: "<standard_lanes>")
            crossingData["delayTime"] = delayTime
            self.updateView(data: crossingData)
        }
    }

    func updateView(data: [String: String]) {
        DispatchQueue.main.async {
            self.updateTimeLabel.text! = "Last updated: \(String(describing: data["updateTime"]!))"
            self.portStatusLabel.text! = "Port status: \(String(describing: data["portStatus"]!))"
            if data["delayTime"] == "N/A" {
                self.delayTimeLabel.text! = "Delay: N/A"
            } else {
            self.delayTimeLabel.text! = "Delay: \(String(describing: data["delayTime"]!)) minutes"
            }
        }
    }
}
