import Foundation
import UIKit
import MapKit

class TableListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var showMapButton: UIButton!

    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var rootViewController: ViewController?
    var crossings: Array<CrossingAnnotation> = []
    var selectedCrossing: CrossingAnnotation?

    override func viewDidLoad() {
        UIApplication.shared.statusBarStyle = .lightContent
        view.addSubview(activityIndicator)

        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.white
        activityIndicator.hidesWhenStopped = true
        
        tableView.layer.borderColor! = UIColor.white.cgColor
        tableView.layer.borderWidth = 1.0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        crossings = getCrossings()
        tableView.reloadData()
        UIApplication.shared.statusBarStyle = .lightContent
    }
}

extension TableListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crossings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let crossing = crossings[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CrossingCell
        cell.titleLabel.text = crossing.title!
        cell.getData(crossing: crossing.xmlIdentifier!, crossingTitle: crossing.title!)
        if crossing.title!.contains("\n") {
            let titleComponents = crossing.title?.components(separatedBy: "\n")
            cell.titleLabel.text = "\(titleComponents![0])\(titleComponents![1])"
        } else {
            cell.titleLabel.text = crossing.title!
        }
        return cell
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(114.0)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        MKMapItem(placemark: MKPlacemark(coordinate: crossings[indexPath.row].coordinate)).openInMaps(launchOptions: options)
    }
}
