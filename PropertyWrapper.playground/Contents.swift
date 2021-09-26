import Foundation
//可以在不影响调用代码的情况添加属性映射或者处理

// 依赖注入
do{
    @propertyWrapper
    struct UserDefaultsWrapper<V> {
        private var key: String
        private var defaultValue: V
        private var overwrite: Bool
        
        public init(key: String, overwrite: Bool = false, defaultValue: V) {
            self.key = key
            self.overwrite = overwrite
            self.defaultValue = defaultValue
        }
        
        public var wrappedValue: V {
            get {
                guard let value = UserDefaults.standard.object(forKey: key) as? V else {
                    return defaultValue
                }
                return value
            }
            set {
                if overwrite {
                    UserDefaults.standard.set(newValue, forKey: key)
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    
    struct User {
        @UserDefaultsWrapper(key: "USER_TOKEN",defaultValue: nil)
        var token:String?
        static let current = User()
    }
    //数据源不止于UserDefaults也可以来自于配置文件，数据库，自定义的内存数据等。
    UserDefaults.standard.set("USER_TOKEN", forKey: "My Token")
    print(User.current.token ?? "")
}

//字符串格式化
do{
    @propertyWrapper
    struct CurrencyFormater {
        private var cur: String
        private var value: String = ""
        public init(cur: String) {
            self.cur = cur
        }
        
        public var wrappedValue: String {
            get { value }
            set {
                if !value.hasPrefix(self.cur) {
                    value = self.cur + newValue;
                }
            }
        }
    }
    
    
    @propertyWrapper
    struct LengthLimition {
        private var length: Int
        private var value: String = ""
        public init(maxlength: Int) {
            self.length = maxlength
        }
        
        public var wrappedValue: String {
            get { value }
            set {
                if newValue.count > length {
                    value = String(newValue[newValue.startIndex..<newValue.index(newValue.startIndex, offsetBy: String.IndexDistance(length))])
                }else{
                    value = newValue
                }
            }
        }
    }
    
    struct Product {
        @CurrencyFormater(cur: "￥")
        var price:String
        @LengthLimition(maxlength:3)
        var name:String
    }
    
    var p1 = Product();
    p1.price = "122";
    print(p1.price)
    p1.name = "123456";
    print(p1.name)
}
