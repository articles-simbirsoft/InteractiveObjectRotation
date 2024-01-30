import UIKit
import SnapKit

final class Interactive2DView: UIView {

    private var transform3DView = UIView()

    private lazy var matrix: CATransform3D = {
        var transform3D = CATransform3DIdentity
        transform3D.m34 = Constants.perspective
        transform3DView.layer.sublayerTransform = transform3D
        return transform3D
    }()
    
    private var imageView = UIImageView()

    // MARK: Gesture Recognizers
    
    private let panGestureRecognizer = UIPanGestureRecognizer()
    private var panGestureAnchorPoint: CGPoint?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
        setupGestureRecognizers()
    }
}

// MARK: - Private func

private extension Interactive2DView {

    func configureUI() {
        self.backgroundColor = Constants.backgroundColor

        self.addSubview(transform3DView)
        transform3DView.addSubview(imageView)

        configureZPozitionView()
        configureImageView()
        makeConstraints()
    }

    func configureZPozitionView() {
        transform3DView.translatesAutoresizingMaskIntoConstraints = false
        transform3DView.backgroundColor = .clear
        //    CATransform3DView.layer.borderWidth = 4
        //    CATransform3DView.layer.borderColor = UIColor.white.cgColor
        transform3DView.clipsToBounds = true
    }

    func configureImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: Constants.nameImage)
        imageView.contentMode = .scaleAspectFit
    }

    func refreshView(duration: Double) {
        var transform3D = CATransform3DIdentity
        transform3D.m34 = Constants.perspective

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.35,
            initialSpringVelocity: 0.3,
            options: [.allowUserInteraction]
        ) {
            self.transform3DView.transform3D = transform3D
        }
    }

    func makeConstraints() {
        transform3DView.snp.makeConstraints { make in
            make.height.width.equalTo(Constants.viewSize)
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
        }

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupGestureRecognizers() {
        panGestureRecognizer.addTarget(
            self,
            action: #selector(handlePanGesture(_:))
        )

        // To avoid bugs, we set the number of touches

        panGestureRecognizer.maximumNumberOfTouches = 1

        transform3DView.addGestureRecognizer(panGestureRecognizer)
    }
}

    // MARK: - Pan Gesture Recognizer

private extension Interactive2DView {
    @objc
    func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard panGestureRecognizer === gestureRecognizer else { return }

        switch gestureRecognizer.state {
        case .began:
            panGestureAnchorPoint = gestureRecognizer.location(in: self)

        case .changed:
            guard let panGestureAnchorPoint = panGestureAnchorPoint else { return }
            let gesturePoint = gestureRecognizer.location(in: self)

            // Calculate parameters for the angle in X

            let ratioMovementXToHalfWidthScreen = (gesturePoint.x - panGestureAnchorPoint.x) / (Constants.viewSize / 2)
            let angleX: Float = ( .pi / 4 ) * Float(ratioMovementXToHalfWidthScreen)
            let rotation3dX = CATransform3DRotate(
                matrix,
                CGFloat(angleX),
                0, 1, 0
            )

            // Calculate parameters for the angle in Y

            let ratioMovementYToHalfWidthScreen = (gesturePoint.y - panGestureAnchorPoint.y) / (Constants.viewSize / 2)
            let angleY: Float = ( -.pi / 4 ) * Float(ratioMovementYToHalfWidthScreen)
            let rotation3dY = CATransform3DRotate(
                matrix,
                CGFloat(angleY),
                1, 0, 0
            )

            // Transformation Concatenation operation

            transform3DView.transform3D = CATransform3DConcat(rotation3dX, rotation3dY)

        case .cancelled, .ended, .failed, .possible:
            refreshView(duration: 1.5)
            panGestureAnchorPoint = nil

        @unknown default:
            break
        }
    }
}

// MARK: - Constants

private extension Interactive2DView {
    enum Constants {
        static let backgroundColor = UIColor.rgb(30, 73, 101)
        static let viewSize: CGFloat = 250
        static let perspective: CGFloat = -1 / 500
        static let nameImage: String = "ssLogoSymbolBlue2"
    }
}


