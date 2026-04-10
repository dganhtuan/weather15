import Orion
import UIKit

// 1. KHO CHỨA CÀI ĐẶT
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

// 2. HOOK ĐỂ DỜI TRỤC Y CẢ CỤM ĐỒNG HỒ (Từ bài học SimpleLS15)
class DateViewHook: ClassHook<UIView> {
    static let targetName = "SBFLockScreenDateView"

    func setFrame(_ frame: CGRect) {
        var newFrame = frame
        if Prefs.enabled {
            newFrame.origin.y += Prefs.yOffset
        }
        orig.setFrame(newFrame)
    }
}

// 3. HOOK ĐỂ NHÉT THỜI TIẾT VÀO MÀN HÌNH (Từ mã nguồn WeatherLS)
class DateViewControllerHook: ClassHook<UIViewController> {
    static let targetName = "SBFLockScreenDateViewController"
    
    // Thêm một View thời tiết vào
    @Property(.nonatomic, .retain) var weatherView = WLSView()
    
    func viewDidLoad() {
        orig.viewDidLoad()
        guard Prefs.enabled else { return }
        
        weatherView = WLSView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        target.view.addSubview(weatherView)
    }
    
    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        guard Prefs.enabled else {
            weatherView.isHidden = true
            return
        }
        weatherView.isHidden = false
        
        // Đặt vị trí thời tiết nằm ngay bên dưới đồng hồ
        var frame = weatherView.frame
        frame.origin.x = (target.view.frame.width / 2) - 40 // Căn giữa màn hình
        frame.origin.y = target.view.frame.maxY + 10 // Cách đồng hồ 10 pixel
        weatherView.frame = frame
        
        // Lấy màu sắc của đồng hồ để gán cho chữ thời tiết
        if let timeLabel = target.value(forKey: "_timeLabel") as? UIView,
           let legibility = timeLabel.value(forKey: "_legibilitySettings") as? NSObject,
           let color = legibility.value(forKey: "primaryColor") as? UIColor {
            weatherView.temp_label.textColor = color
        } else {
            weatherView.temp_label.textColor = .white
        }
    }
    
    // Cập nhật lại thời tiết mỗi khi đồng hồ nhảy số
    // Note: Dùng AnyObject để tránh lỗi Swift
    func _startUpdateTimer() {
        orig._startUpdateTimer()
        if Prefs.enabled {
            weatherView.updateWeather()
        }
    }
}

// 4. KHỞI TẠO TWEAK
struct Weather15: Tweak {
    init() {
        Prefs.load()
        let name = CFNotificationName("com.tuan.weather15/ReloadPrefs" as CFString)
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, { _, _, _, _, _ in Prefs.load() }, name.rawValue, nil, .deliverImmediately)
    }
}