import UIKit

final class Interactive2DLayeredViewController: UIViewController {
  
    private var customView = InteractiveLayered2DView()

    override func loadView() {
        self.view = customView
    }
  
}
