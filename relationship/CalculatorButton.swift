import UIKit

class CalculatorButton: UIButton {
    
    enum ColorTheme {
        case day, night
        
        var normalColor: UIColor {
            switch self {
            case .day:
                return #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
            case .night:
                return UIColor(hex: 0x333333)
            }
        }
        
        var highlightedColor: UIColor {
            switch self {
            case .day:
                return #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
            case .night:
                return UIColor(hex: 0x737373)
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .day:
                return .black
            case .night:
                return .white
            }
        }
    }
    
    @IBInspectable
    public var isNight: Bool = false {
        didSet {
            colorTheme = isNight ? .night : .day
        }
    }
    
    public var colorTheme: ColorTheme = .day {
        didSet {
            setTitleColor(colorTheme.textColor, for: .normal)
            
            let disabledColor = UIColor(hex: 0xe6e6e6)
            setTitleColor(colorTheme == .day ? disabledColor : disabledColor.withAlphaComponent(0.5), for: .disabled)
            setBackgroundColor(colorTheme.normalColor, for: .normal)
            setBackgroundColor(UIColor.orange.withAlphaComponent(0.5), for: .selected)
            imageView?.tintColor = colorTheme.textColor
        }
    }
    
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
        
        colorTheme = .day


        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
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
        setBackgroundColor(colorTheme.highlightedColor, for: .normal)
    }
    
    @objc private func touchUp() {
        animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut, animations: {
            self.setBackgroundColor(self.colorTheme.normalColor, for: .normal)
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
