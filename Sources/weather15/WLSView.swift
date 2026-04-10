import UIKit

@objc protocol PDDokdoProtocol {
    func refreshWeatherData()
    var currentConditionsImage: UIImage? { get }
    var currentTemperature: String? { get }
}

final class WLSView: UIView {
    var image_view: UIImageView!
    var temp_label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        image_view = UIImageView(frame: .zero)
        image_view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image_view)
        
        temp_label = UILabel(frame: .zero)
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
        // Dò mìn cực kỳ cẩn thận: Có thư viện Dokdo mới chạy, không có thì im lặng rút lui!
        guard let dokdoObj = NSClassFromString("PDDokdo") as? NSObject.Type,
              let instance = dokdoObj.perform(NSSelectorFromString("sharedInstance"))?.takeUnretainedValue() as? NSObject else { return }
        
        // Kiểm tra xem hàm có tồn tại không trước khi gọi để chống nổ
        if instance.responds(to: NSSelectorFromString("refreshWeatherData")) {
            instance.perform(NSSelectorFromString("refreshWeatherData"))
        }
        
        if instance.responds(to: NSSelectorFromString("currentConditionsImage")),
           let image = instance.value(forKey: "currentConditionsImage") as? UIImage { 
            image_view.image = image 
        }
        
        if instance.responds(to: NSSelectorFromString("currentTemperature")),
           let temp = instance.value(forKey: "currentTemperature") as? String { 
            temp_label.text = temp 
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
