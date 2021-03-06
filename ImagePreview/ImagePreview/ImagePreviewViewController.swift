//
//  Created by Maciej Gorecki on 07/03/2021.
//

import UIKit

class ImagePreviewViewController: ViewController {
    let background = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    let imageView = UIImageView()
    
    var completion: (() -> Void)?
    
    init(image: UIImage) {
        super.init()
        modalPresentationStyle = .overFullScreen
        imageView.image = image
    }
    
    override func loadView() {
        super.loadView()
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        completion?()
    }
}

private extension ImagePreviewViewController {
    func setup() {
        addSubviews()
        setupBackground()
        setupImageView()
        setupGestureRecognizers()
        transitioningDelegate = self
    }
    
    func addSubviews() {
        view.addSubview(background)
        view.addSubview(imageView)
    }
    
    func setupBackground() {
        background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.snapView(background, to: view)
    }
    
    func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let image = imageView.image
        let ratio = image!.size.width / image!.size.height
        let newHeight = UIScreen.main.bounds.width / ratio
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: newHeight)
        ])
    }
    
    func setupGestureRecognizers() {
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
    }
    
    @objc
    func close() {
        dismiss(animated: true)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard view.frame.height > 0 else { return }
        var translation = gesture.translation(in: nil)
        translation = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
        imageView.center = translation
        
        var result = (translation.y / view.frame.height) / 0.5
        result = result > 1 ? result - 1 : 1 - result
        background.alpha = 1 - result
        
        imageView.transform = .init(scaleX: 1 - (result / 2), y: 1 - (result / 2))
        
        gesture.setTranslation(.zero, in: nil)
        
        if gesture.state == .ended {
            dismiss(animated: true)
        }
    }
}

extension ImagePreviewViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ImagePreviewTransition(type: .presenting)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ImagePreviewTransition(type: .dismissing)
    }
}
