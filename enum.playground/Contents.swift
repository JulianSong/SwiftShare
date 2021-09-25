import Foundation
/*--------1.原始数据类型---------*/

// 默认如原始数据类型
enum Connection {
    case keepAlive,close
}

print(Connection.keepAlive)

// 整形
enum ResponseCode: Int {
    case `default`
    case ok = 200,created
    case multipleChoice = 300,movedPermanently
}

/*
 枚举值默从0开始自增
 */
print(ResponseCode.default.rawValue)
print(ResponseCode.created.rawValue)
print(ResponseCode.movedPermanently.rawValue)
let code = ResponseCode(rawValue: 200)
print(code!)

// 浮点型
enum QFactorWeighting: Double {
    case unset
    case `required` = 1.0
    case partiallySpecified = 0.8
}

/*
 枚举值默从0开始自增
 */
print(QFactorWeighting.unset.rawValue)
print(QFactorWeighting.partiallySpecified.rawValue)

// 字符串
enum ResponseDescription: String {
    case ok
    case created
    case multipleChoice
    case movedPermanentlys
}
print(ResponseDescription.ok.rawValue)

// 自定义类型
enum Hosts {
    case google
    case youtube
    case facebook
}

extension Hosts: RawRepresentable {
    typealias RawValue = URL
    init?(rawValue: URL) {
        switch rawValue.absoluteString {
        case let str where str.hasPrefix("https://www.google.com"): self = .google
        case let str where str.hasPrefix("https://www.youtube.com") : self = .youtube
        case let str where str.hasPrefix("https://www.facebook.com") : self = .facebook
        default:return nil
        }
    }
    
    var rawValue: URL {
        switch self {
        case .google: return URL(string: "https://www.google.com")!
        case .youtube: return URL(string: "https://www.youtube.com")!
        case .facebook: return URL(string: "https://www.facebook.com")!
        }
    }
}

print(Hosts.google.rawValue);

/*--------2.关联类型---------*/

enum Response{
    case ok
    case error(ResponseCode,ResponseDescription)
}

let response = Response.error(.multipleChoice,.multipleChoice)

if case let  Response.error(code,desc) = response {
    print("\(code.rawValue):\(desc)")
}else{
    print("Everything is ok.")
}

/*-------3.实现协议---------*/

extension Response : CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .ok :return "Everything is ok."
        case .error(let code,let desc):return "code : \(code.rawValue) ,desc: \(desc)"
        }
    }
}

print(response)

/*-------3.枚举嵌套&错误处理---------*/

enum ServerErrorCode: Int {
    case tokenExpired
}

enum ModelMappingError: Error {
    case leakOfData
    case incorrectDataType
}

enum NetorkError: Error {
    case urlError(URLError)
    case serverError(ServerErrorCode,String)
    case modelMappingError(ModelMappingError)
}

do{
    func doSometingWrong() throws {
        throw NetorkError.serverError(.tokenExpired, "用户token过期")
    }
    
    do{
        try doSometingWrong()
    } catch NetorkError.urlError(let error) {
        switch error.code {
        case .backgroundSessionInUseByAnotherProcess:
            break
        default:
            break
        }
    } catch NetorkError.serverError(let errorCode,let message) {
        switch errorCode {
        case .tokenExpired: print(message)
        }
    } catch NetorkError.modelMappingError(let error) {
        switch error {
        case .incorrectDataType:
            break
        case .leakOfData:
            break
        }
    }
}

do{
    func doSometingWrong(handler:(Result<Int,NetorkError>) ->Void){
        handler(.failure(NetorkError.serverError(.tokenExpired, "用户token过期")))
    }
    
    doSometingWrong {
        switch $0 {
        case .success(_):break
        case .failure(let error):
            switch error {
            case .urlError(let urlError):
                print(urlError)
            case .serverError(let errorCode,let message):
                switch errorCode {
                case .tokenExpired:
                    print(message)
                    break
                }
            case .modelMappingError(let mapingError):
                switch mapingError {
                case .incorrectDataType:
                    break
                case .leakOfData:
                    break
                }
            }
            break
        }
    }
}


/*-------4, 用作配置---------*/

enum Configuration{
    case deugMode(Bool)
    case deviceId(String)
    case userId(String)
    case info([String:String])
    
    static func maping(_ cfg:Configuration) -> (String,Any) {
        switch cfg {
        case .deugMode(let value):return ("deugMode",value)
        case .deviceId(let value):return ("deviceId",value)
        case .userId(let value):return ("userId",value)
        case .info(let value):return ("info",value)
        }
    }
}

do{
    func setup(with configurations:[Configuration]) {
        let configurationsDic =  Dictionary(uniqueKeysWithValues:configurations.map(Configuration.maping))
        print(configurationsDic)
    }
    
    setup(with: [
        .deugMode(true),
        .deviceId("dadae2e2e2"),
        .userId("13313232"),
        .info(["setttings1":"value1"])
    ])
}


