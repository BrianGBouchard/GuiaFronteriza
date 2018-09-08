import Foundation
import UIKit

class InfoViewController: UIViewController {

    var unwindDestination: UIViewController?

    @IBAction func buttonPressed(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }

}
