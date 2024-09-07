import UIKit

class CalculatorButton: UIButton {
    
    /// The value to display on the button.
    @IBInspectable
    public var text: String? {
        didSet {
            setTitle(text, for: .normal)
        }
    }
    
    /// The value to display on the button.
    @IBInspectable
    public var image: UIImage? {
        didSet {
            setImage(image, for: .normal)
        }
    }
    
    
    private var animator = UIViewPropertyAnimator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        layer.masksToBounds = true
        titleLabel?.font = UIFont.systemFont(ofSize: 25)

        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
        
        setBackgroundColor(.secondarySystemBackground, for: .normal)
        setBackgroundColor(.orange, for: .selected)
        setTitleColor(.opaqueSeparator, for: .disabled)
        imageView?.tintColor = .label
        setTitleColor(.label, for: .normal)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 75, height: 75)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 10//bounds.width / 2
    }
    
    @objc private func touchDown() {
        animator.stopAnimation(true)
        setBackgroundColor(.secondarySystemFill, for: .normal)
    }
    
    @objc private func touchUp() {
        animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut, animations: {
            self.setBackgroundColor(.secondarySystemBackground, for: .normal)
        })
        animator.startAnimation()
    }
}


extension UIButton {
    
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        if let usingColor = color {
            let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
            usingColor.setFill()
            UIRectFill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let cgImage = image?.cgImage else {
                return
            }
            
            let backgroundImage = UIImage(cgImage: cgImage)
            self.setBackgroundImage(backgroundImage, for: state)
        }
    }
}
