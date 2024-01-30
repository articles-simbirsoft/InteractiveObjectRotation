import UIKit

final class Interactive2DViewController: UIViewController {

    private var customView = Interactive2DView()

    override func loadView() {
        self.view = customView
    }
  
}
