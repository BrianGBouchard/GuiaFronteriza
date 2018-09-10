import Foundation
import UIKit

func webRequest() -> String {
    let urlString = "https://apps.cbp.gov/bwt/bwt.xml"
    let url: URL = URL(string: urlString)!
    do {
        let HTMLString = try String(contentsOf: url, encoding: .ascii)

        return HTMLString

    } catch { print(error.localizedDescription)

        return ""
    }
}

func getPortData(forCrossing crossing: String) -> String {
    let baseData = webRequest()
    let baseDataArray = baseData.components(separatedBy: "<port>")
    for item in baseDataArray {
        if item.contains(crossing) {
            return(item)
        }
    }
    return "VOID"
}

func getPortStatus(forCrossing crossing: String) -> String {
    let portData = getPortData(forCrossing: crossing)
    let portDataArray = portData.components(separatedBy: "<port_status>")
    if portDataArray.count > 1 {
        let portStatus = portDataArray[1].components(separatedBy: "<")[0]

        return portStatus
    } else {
        return "N/A"
    }
}

func getLaneData(forCrossing crossing: String, crossingType: String) -> String {
    let portData = getPortData(forCrossing: crossing)
    let portDataArray = portData.components(separatedBy: crossingType)
    if portDataArray.count > 1 {
        let passengerLaneData = portDataArray[1]
        let laneData = (passengerLaneData.components(separatedBy: crossingType))[0]

        return laneData
    } else {
        return "N/A"
    }
}

func getUpdateTime(forCrossing crossing: String, crossingType: String, laneType: String) -> String {
    let laneData = getLaneData(forCrossing: crossing, crossingType: crossingType)
    if laneData == "N/A" {
        return "N/A"
    } else {
        if laneData.count > 1 {
            let laneTypeData = laneData.components(separatedBy: laneType)[1]
            let updateDataArray = laneTypeData.components(separatedBy: "<update_time>")
            if updateDataArray.count > 1 {
                let updateTimeText = updateDataArray[1].components(separatedBy: "<")[0]
                let updateTimeArray = updateTimeText.components(separatedBy: "At ")
                if updateTimeArray.count > 1 {
                    let updateTime = updateTimeArray[1]

                    return updateTime

                } else {
                    return "N/A"
                }
            } else {
                return "N/A"
            }
        } else {
            return "N/A"
        }
    }
}

func getDelayTime(forCrossing crossing: String, crossingType: String, laneType: String) -> String {
    let laneData = getLaneData(forCrossing: crossing, crossingType: crossingType)
    if laneData == "N/A" {
        return "N/A"
    } else {
        let laneTypeData = (laneData.components(separatedBy: crossingType))[0]
        let delayTimeData = laneTypeData.components(separatedBy: "<delay_minutes>")[1]
        let delayTime = delayTimeData.components(separatedBy: "<")[0]

        return delayTime
    }
}
