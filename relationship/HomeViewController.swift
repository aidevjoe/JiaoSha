import UIKit
import JavaScriptCore
import LabelSwitch

class BaseNavigationController: UINavigationController {
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var fatherBtn: CalculatorButton!
    @IBOutlet weak var motherBtn: CalculatorButton!
    @IBOutlet weak var husbandBtn: CalculatorButton!
    @IBOutlet weak var wifeBtn: CalculatorButton!
    @IBOutlet weak var sonBtn: CalculatorButton!
    @IBOutlet weak var daughterBtn: CalculatorButton!
    @IBOutlet weak var brotherBtn: CalculatorButton!
    @IBOutlet weak var youngerBrotherBtn: CalculatorButton!
    @IBOutlet weak var sisterBtn: CalculatorButton!
    @IBOutlet weak var youngerSisterBtn: CalculatorButton!
    @IBOutlet weak var clearEntryBtn: CalculatorButton!
    @IBOutlet weak var allClearBtn: CalculatorButton!
    @IBOutlet weak var convertBtn: CalculatorButton!
    @IBOutlet weak var equalBtn: CalculatorButton!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var enterLabel: UILabel!
    
    private var jsContext: JSContext? {
        guard let jsContext = JSContext(),
            let hgPath = Bundle.main.path(forResource: "relationship.min", ofType: "js"),
            let js = try? String(contentsOfFile: hgPath)
            else { return nil }
        
        let _ = jsContext.evaluateScript(js)
        return jsContext
    }

    private var relatives: [String] = [] {
        didSet {
            
            let text = relatives.joined(separator: "的")
            if text.isEmpty {
                enterLabel.text = ""
                resultLabel.text = "自己"
                return
            }
            
            enterLabel.text = text//.isEmpty ? "我" : text
            
            
            if ["妈妈", "老婆", "女儿", "姐姐", "妹妹"].contains(relatives.last ?? "")  {
                wifeBtn.isEnabled = false
                husbandBtn.isEnabled = true
            } else {
                wifeBtn.isEnabled = true
                husbandBtn.isEnabled = false
            }

            if relatives.count > 15 {
                resultLabel.text = "关系有点远，年长就叫老祖宗吧~"
                return
            }
            
            relationship(text: text)
        }
    }
    
    private var isNight = false {
        didSet {
            updateTheme()
        }
    }
    
    private lazy var labelSwitch: LabelSwitch = {
        let ls = LabelSwitchConfig(text: "女",
                                   textColor: .white,
                                   font: .boldSystemFont(ofSize: 15),
                                   gradientColors: [UIColor.orange.cgColor, UIColor.yellow.cgColor], startPoint: CGPoint(x: 0.0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
        
        let rs = LabelSwitchConfig(text: "男",
                                   textColor: .white,
                                   font: .boldSystemFont(ofSize: 15),
                                   gradientColors: [UIColor.yellow.cgColor, UIColor.orange.cgColor], startPoint: CGPoint(x: 0.0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
        
        
        // Set the default state of the switch,
        let labelSwitch = LabelSwitch(center: .zero, leftConfig: ls, rightConfig: rs)
        labelSwitch.delegate = self
        labelSwitch.fullSizeTapEnabled = true
        return labelSwitch
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .orange

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: labelSwitch)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "night"), style: .plain, target: self, action: #selector(switchTheme))
        
        UIView.activate(constraints: [fatherBtn.heightAnchor.constraint(equalTo: fatherBtn.widthAnchor)])
        
        [resultLabel, enterLabel].forEach { $0.adjustsFontSizeToFitWidth = true }
        
        if labelSwitch.curState == .L {
            wifeBtn.isEnabled = true
            husbandBtn.isEnabled = false
        } else {
            wifeBtn.isEnabled = false
            husbandBtn.isEnabled = true
        }
        
        isNight = UserDefaults.standard.bool(forKey: "isNight")
    }
    
    @IBAction func tapKeyAction(_ btn: CalculatorButton) {
        guard let text = btn.currentTitle, text.count > 0,
        let relation = convertToRelation(text: text) else { return }
        relatives.append(relation)
    }
    
    @IBAction func tapFunctionKeyAction(_ btn: CalculatorButton) {
        switch btn {
        case clearEntryBtn:
            if relatives.count > 0 {
                relatives.removeLast()
            }
        case allClearBtn:
            relatives.removeAll()
        case convertBtn:
            convertBtn.isSelected = !convertBtn.isSelected
            refreshRelative()
        case equalBtn:
            refreshRelative()
        default:
            break
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isNight ? .lightContent : .default
    }
}

extension HomeViewController {
    
    private func refreshRelative() {
        let res = relatives
        relatives = res
    }
    
    /// text: 输入的文本
    /// sex: 自己的性别：0女性,1男性
    /// reverse: 称呼方式：true对方称呼我,false我称呼对方
    private func relationship(text: String) {
        let reverse = convertBtn.isSelected
        let sex: Sex = labelSwitch.curState == .L ? .man : .woman
        let script = "relationship({text: '\(text)', sex: \(sex.rawValue), type: 'default', reverse: \(reverse ? "true" : "false")})"
        let res = jsContext?.evaluateScript(script).toString()
        resultLabel.text = res
        
        if res?.isEmpty == true {
            resultLabel.text = "貌似他/她跟你不是很熟哦!"
        }
    }
    
    private func convertToRelation(text: String) -> String? {
        switch text {
        case "父":
            return "爸爸"
        case "母":
            return "妈妈"
        case "夫":
            return "老公"
        case "妻":
            return "老婆"
        case "子":
            return "儿子"
        case "女":
            return "女儿"
        case "兄":
            return "哥哥"
        case "弟":
            return "弟弟"
        case "姐":
            return "姐姐"
        case "妹":
            return "妹妹"
        default:
            return nil
        }
    }

    @objc private func switchTheme() {
        isNight = !isNight
    }
    
    private func updateTheme() {
        UserDefaults.standard.set(isNight, forKey: "isNight")
        UserDefaults.standard.synchronize()
        
        UIView.animate(withDuration: 0.1) {
            self.view.backgroundColor = self.isNight ? #colorLiteral(red: 0.02745098039, green: 0.06666666667, blue: 0.08235294118, alpha: 1) : .white
            
            [self.fatherBtn, self.motherBtn, self.husbandBtn, self.wifeBtn, self.sonBtn, self.daughterBtn,
             self.brotherBtn, self.youngerBrotherBtn, self.sisterBtn, self.youngerSisterBtn,
             self.clearEntryBtn, self.allClearBtn, self.convertBtn, self.equalBtn
                ].forEach { $0?.colorTheme = self.isNight ? .night : .day }
            
            self.resultLabel.textColor = self.isNight ? .white : .black
        }
        setNeedsStatusBarAppearanceUpdate()
    }
}

extension HomeViewController: LabelSwitchDelegate {
    func switchChangToState(_ state: LabelSwitchState) {
        labelSwitch.curState = state
        refreshRelative()
    }
}

enum Sex: Int {
    case woman = 0
    case man
}
