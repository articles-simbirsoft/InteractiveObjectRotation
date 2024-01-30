import UIKit

final class Interactive3DViewController: UIViewController {
    
    private var customView = Interactive3DView()

    override func loadView() {
        self.view = customView
    }
}
