import Foundation



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
    let portStatus = portDataArray[1].components(separatedBy: "<")[0]

    return portStatus
}

func getLaneData(forCrossing crossing: String, crossingType: String) -> String {
    let portData = getPortData(forCrossing: crossing)
    let portDataArray = portData.components(separatedBy: crossingType)
    let passengerLaneData = portDataArray[1]
    let laneData = (passengerLaneData.components(separatedBy: crossingType))[0]

    return laneData

}

func getUpdateTime(forCrossing crossing: String, crossingType: String, laneType: String) -> String {
    let laneData = getLaneData(forCrossing: crossing, crossingType: crossingType)
    let laneTypeData = laneData.components(separatedBy: laneType)[1]
    let updateDataArray = laneTypeData.components(separatedBy: "<update_time>")
    let updateTimeText = updateDataArray[1].components(separatedBy: "<")[0]
    let updateTime = (updateTimeText.components(separatedBy: "At "))[1]

    return updateTime
}

func getDelayTime(forCrossing crossing: String, crossingType: String, laneType: String) -> String {
    let laneData = getLaneData(forCrossing: crossing, crossingType: crossingType)
    let laneTypeData = (laneData.components(separatedBy: crossingType))[0]
    let delayTimeData = laneTypeData.components(separatedBy: "<delay_minutes>")[1]
    let delayTime = delayTimeData.components(separatedBy: "<")[0]

    return delayTime
}
