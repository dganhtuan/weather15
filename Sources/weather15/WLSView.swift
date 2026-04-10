import UIKit

// Khai báo giao thức của thư viện Dokdo (Objective-C) để Swift hiểu được
@objc protocol PDDokdoProtocol {
    func refreshWeatherData()
    var currentConditionsImage: UIImage? { get }
    var currentTemperature: String? { get }
}

final class WLSView: UIView {
    var image_view: UIImageView!
    var temp_label: UILabel!
    
    // Kết nối lén với thư viện Dokdo
    var dokdoClass: AnyClass? = NSClassFromString("PDDokdo")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        image_view = UIImageView(frame: CGRect.zero)
        image_view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image_view)
        
        temp_label = UILabel(frame: CGRect.zero)
        temp_label.translatesAutoresizingMaskIntoConstraints = false
        temp_label.textAlignment = .center
        temp_label.font = .systemFont(ofSize: 28, weight: .medium)
        addSubview(temp_label)
        
        configureConstraints()
        updateWeather()
    }
    
    func configureConstraints() {
        image_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        image_view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        image_view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
        image_view.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -20).isActive = true
        
        temp_label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        temp_label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        temp_label.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        temp_label.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    func updateWeather() {
        // Dùng KVC để gọi thư viện Dokdo an toàn mà không cần Header Objective-C
        guard let dokdoObj = NSClassFromString("PDDokdo") as? NSObject.Type else { return }
        guard let instance = dokdoObj.perform(NSSelectorFromString("sharedInstance"))?.takeUnretainedValue() as? NSObject else { return }
        
        instance.perform(NSSelectorFromString("refreshWeatherData"))
        
        if let image = instance.value(forKey: "currentConditionsImage") as? UIImage {
            image_view.image = image
        }
        if let temp = instance.value(forKey: "currentTemperature") as? String {
            temp_label.text = temp
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
