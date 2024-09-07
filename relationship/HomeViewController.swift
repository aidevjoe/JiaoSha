import UIKit
import JavaScriptCore

class BaseNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .orange
        
        navigationItem.rightBarButtonItem = .init(image: .init(systemName: "ellipsis"), style: .done, target: self, action: #selector(ourAppAction))
        
        UIView.activate(constraints: [fatherBtn.heightAnchor.constraint(equalTo: fatherBtn.widthAnchor)])
        
        [resultLabel, enterLabel].forEach { $0.adjustsFontSizeToFitWidth = true }
    }
    
    @objc private func ourAppAction() {
        let ourAppVC = OurAppViewController()
        let nav = UINavigationController(rootViewController: ourAppVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    @IBAction func tapKeyAction(_ btn: CalculatorButton) {
        guard let text = btn.currentTitle, text.count > 0,
        let relation = convertToRelation(text: text) else { return }
        Vibrations.light.vibrate()
        relatives.append(relation)
    }
    
    private func renewBtnState() {
        wifeBtn.isEnabled = true
        husbandBtn.isEnabled = true
    }
    
    @IBAction func tapFunctionKeyAction(_ btn: CalculatorButton) {
        Vibrations.light.vibrate()
        switch btn {
        case clearEntryBtn:
            if relatives.count > 0 {
                renewBtnState()
                relatives.removeLast()
            }
        case allClearBtn:
            renewBtnState()
            relatives.removeAll()
        case convertBtn:
            convertBtn.isSelected.toggle()
            convertBtn.imageView?.tintColor = convertBtn.isSelected ? .white : .label
            refreshRelative()
        case equalBtn:
            refreshRelative()
        default:
            break
        }
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
//        let sex: Sex = labelSwitch.curState == .L ? .man : .woman
        let script = "relationship({text: '\(text)', sex: \(-1), type: 'default', reverse: \(reverse ? "true" : "false")})"
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
}

enum Sex: Int {
    case woman = 0
    case man
}
