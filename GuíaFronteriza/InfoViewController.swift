import Foundation
import UIKit

class InfoViewController: UIViewController {

    var rootController: ViewController?
    
    @IBAction func buttonPressed(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
        if rootController?.control!.selectedSegmentIndex == 0 {
            rootController?.aboutButton!.titleLabel!.textColor! = .white
        } else {
            rootController?.aboutButton!.titleLabel!.textColor! = .black
        }
    }
}
