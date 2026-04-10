import Orion
import UIKit

struct Prefs {
    static var enabled = true
    static var yOffset: CGFloat = 0.0

    static func load() {
        CFPreferencesAppSynchronize("com.tuan.weather15" as CFString)
        let path = "/var/jb/var/mobile/Library/Preferences/com.tuan.weather15.plist"
        guard let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else { return }
        enabled = dict["enabled"] as? Bool ?? true
        yOffset = dict["yOffset"] as? CGFloat ?? 0.0
    }
}

class DateViewHook: ClassHook<UIView> {
    static let targetName = "SBFLockScreenDateView"
    func setFrame(_ frame: CGRect) {
        var newFrame = frame
        if Prefs.enabled { newFrame.origin.y += Prefs.yOffset }
        orig.setFrame(newFrame)
    }
}

class DateViewControllerHook: ClassHook<UIViewController> {
    static let targetName = "SBFLockScreenDateViewController"
    
    // AN TOÀN: Dùng dấu "?" để không khởi tạo sớm gây Crash
    @Property(.nonatomic, .retain) var weatherView: WLSView? = nill
    
    func viewDidLoad() {
        orig.viewDidLoad()
        guard Prefs.enabled else { return }
        
        // Chỉ khởi tạo khi Apple đã load xong màn hình
        let wView = WLSView(frame: .zero)
        self.weatherView = wView
        target.view.addSubview(wView)
    }
    
    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        guard Prefs.enabled, let wView = self.weatherView else { 
            self.weatherView?.isHidden = true
            return 
        }
        
        wView.isHidden = false
        
        // Tính toán tọa độ và kích thước an toàn
        wView.frame = CGRect(x: (target.view.frame.width / 2) - 40, 
                             y: target.view.frame.maxY + 10, 
                             width: 80, height: 80)
        
        // AN TOÀN TỐI ĐA: Bỏ KVC móc màu dễ crash, đổi sang chữ Trắng đổ bóng đen siêu đẹp và bất tử
        wView.temp_label.textColor = .white
        wView.temp_label.layer.shadowColor = UIColor.black.cgColor
        wView.temp_label.layer.shadowOffset = CGSize(width: 1, height: 1)
        wView.temp_label.layer.shadowOpacity = 0.8
        wView.temp_label.layer.shadowRadius = 2
    }
    
    func _startUpdateTimer() {
        // Dùng Optional chaining để chống lỗi Nil
        guard let origImpl = orig.responds(to: #selector(_startUpdateTimer)) else { return }
        orig._startUpdateTimer()
        
        if Prefs.enabled {
            self.weatherView?.updateWeather()
        }
    }
}

struct Weather15: Tweak {
    init() {
        Prefs.load()
        let name = CFNotificationName("com.tuan.weather15/ReloadPrefs" as CFString)
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, { _, _, _, _, _ in Prefs.load() }, name.rawValue, nil, .deliverImmediately)
    }
}
