import Foundation
import UIKit

class InfoViewController: UIViewController {

    var rootController: MapViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    @IBAction func buttonPressed(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
        if rootController?.control!.selectedSegmentIndex == 0 {
            rootController?.aboutButton!.titleLabel!.textColor! = .white
            rootController?.crossingButton.titleLabel?.textColor! = .white
        } else {
            rootController?.aboutButton!.titleLabel!.textColor! = .black
            rootController?.crossingButton.titleLabel?.textColor! = .black
        }

        self.setNeedsStatusBarAppearanceUpdate()
        rootController?.activityIndicator.stopAnimating()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if rootController?.control!.selectedSegmentIndex == 0 {
            return .lightContent
        } else {
            return .default
        }
    }
}
