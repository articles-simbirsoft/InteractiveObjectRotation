import UIKit
import SnapKit

final class InteractiveLayered2DView: UIView {

    // MARK: - CATransform3DView

    private lazy var matrix: CATransform3D = {
        var transform3D = CATransform3DIdentity
        transform3D.m34 = Constants.perspective
        caTransform3DView.layer.sublayerTransform = transform3D
        return transform3D
    }()
    
    private var caTransform3DView = UIView()
    
    private var layerLevel1 = CALayer()
    private var layerLevel2 = CALayer()
    private var layerLevel3 = CALayer()
    
    private var transformLayer = CATransformLayer()

    // MARK: - Gesture Recognizers
    
    private let panGestureRecognizer = UIPanGestureRecognizer()
    private var panGestureAnchorPoint: CGPoint?
    
    // MARK: - Init
    
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

private extension InteractiveLayered2DView {

    func configureUI() {
        self.backgroundColor = Constants.backgroundColor

        self.addSubview(caTransform3DView)
        caTransform3DView.backgroundColor = .clear

        makeConstraints()
        configureLayers()

        caTransform3DView.layer.addSublayer(transformLayer)
        caTransform3DView.transform3D = matrix
    }
  
    func configureLayers() {
        let imageViewArray = [
            (layerLevel1, Constants.nameImageLevel1),
            (layerLevel2, Constants.nameImageLevel2),
            (layerLevel3, Constants.nameImageLevel3),
        ]

        imageViewArray.forEach { (layer, imgName) in
            let image = UIImage(named: imgName)?.cgImage
            layer.contents = image
            layer.contentsGravity = CALayerContentsGravity.resize
            layer.allowsEdgeAntialiasing = true
            layer.drawsAsynchronously = true
            layer.isDoubleSided = true // значение отвечает за отрисовку обратной стороны слоя
            layer.backgroundColor = UIColor.clear.cgColor
            layer.frame = CGRect(
                x: 0,
                y: 0,
                width: Constants.viewSize,
                height: Constants.viewSize
            )
        }

        layerLevel1.zPosition = 0
        layerLevel2.zPosition = 20
        layerLevel3.zPosition = 35

        transformLayer.addSublayer(layerLevel1)
        transformLayer.addSublayer(layerLevel2)
        transformLayer.addSublayer(layerLevel3)
        transformLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: Constants.viewSize,
            height: Constants.viewSize
        )
    }
  
    func refreshLayers(duration: Double) {
        var transform3D = CATransform3DIdentity
        transform3D.m34 = Constants.perspective

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.35,
            initialSpringVelocity: 0.3,
            options: [.allowUserInteraction]
        ) {
            self.caTransform3DView.layer.sublayerTransform = transform3D
        }
    }

    func makeConstraints() {
        caTransform3DView.snp.makeConstraints { make in
            make.height.width.equalTo(Constants.viewSize)
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
        }
    }
  
    func setupGestureRecognizers() {
        panGestureRecognizer.addTarget(
            self,
            action: #selector(handlePanGesture(_:))
        )

        // To avoid bugs, we set the number of touches

        panGestureRecognizer.maximumNumberOfTouches = 1
        caTransform3DView.addGestureRecognizer(panGestureRecognizer)
    }
}

// MARK: - Pan Gesture Recognizer

private extension InteractiveLayered2DView {
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

            self.caTransform3DView.layer.sublayerTransform = CATransform3DConcat(
                rotation3dX,
                rotation3dY
            )
         
          
        case .cancelled, .ended, .failed, .possible:
            refreshLayers(duration: 1.5)
            panGestureAnchorPoint = nil
          
        @unknown default:
            break
        }
    }
}

// MARK: - Constants

private extension InteractiveLayered2DView {
    enum Constants {
        static let backgroundColor = UIColor.rgb(30, 73, 101)
        static let viewSize: CGFloat = 250
        static let perspective: CGFloat = -1 / 500
        static let nameImageLevel1: String = "level1"
        static let nameImageLevel2: String = "level2"
        static let nameImageLevel3: String = "level3"
    }
}
