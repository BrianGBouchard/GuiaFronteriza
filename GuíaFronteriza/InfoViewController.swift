import Foundation
import UIKit

class InfoViewController: UIViewController {

    var rootController: ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func buttonPressed(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
        if rootController?.control!.selectedSegmentIndex == 0 {
            rootController?.aboutButton!.titleLabel!.textColor! = .white
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            rootController?.aboutButton!.titleLabel!.textColor! = .black
            UIApplication.shared.statusBarStyle = .default
        }
        rootController?.activityIndicator.stopAnimating()
    }
}
