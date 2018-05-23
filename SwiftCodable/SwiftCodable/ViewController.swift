//
//  ViewController.swift
//  SwiftCodable
//
//  Created by zbmy on 2018/5/22.
//  Copyright © 2018年 HakoWaii. All rights reserved.
//

import UIKit

enum FlightRules:String,Codable{
    case visual = "VFR"
    case instrument = "IFR"
}

struct Aircraft:Codable{
    var identification:String
    var color:String
}

struct FlightPlan:Codable{
    var aircraft:Aircraft
    var flightRules:FlightRules
    var route:[String]
    
    private var departureDate:[String:Date]
    
    var proposedDepartureDate:Date?{
        return departureDate["proposed"]
    }
    
    var actualDepartureDate:Date?{
        return departureDate["actual"]
    }
    
    var remarks:String?
    
    //MARK: - 这里很恶心的是，即使是只有要取别名的属性要单独解析，也要把所有属性一一写全在CodingKeys里面
    private enum CodingKeys:String,CodingKey{
        case aircraft
        case flightRules = "flight_rules"
        case route
        case departureDate = "departure_time"
        case remarks
    }
}



struct Route:Decodable{
    struct Airport: Decodable {
        var code: String
        var name: String
    }
    
    var points:[Airport]
   
    private struct CodingKeys: CodingKey {
        var stringValue: String
        
        var intValue: Int? {
            return nil
        }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            return nil
        }
        
        static let points =
            CodingKeys(stringValue: "points")!
    }
    
    //MARK: - 未知Keys类型真的是坑
    public init(from coder: Decoder) throws {
        let container = try coder.container(keyedBy: CodingKeys.self)
        
//        var points: [Airport] = []
        //先将points转化成[String]类型
        let codes:[String] = try container.decode([String].self, forKey: .points)
        
//        let points:[Airport] = try codes.map { (code) -> Airport in
//            let key = CodingKeys(stringValue: code)!
//            let airport = try container.decode(Airport.self, forKey: key)
//            return airport
//        }
        
        let points:[Airport] = try codes.map {
            let key = CodingKeys(stringValue: $0)!
            let airport = try container.decode(Airport.self, forKey: key)
            return airport
        }
        
//      for code in codes {
//         let key = CodingKeys(stringValue: code)!
//         let airport = try container.decode(Airport.self, forKey: key)
//         points.append(airport)
//      }
        self.points = points
    }
}

 //MARK:- decodable无法解析any类型的数据，所以就诞生了AnyDecodable这个用来解析any类型的结构体
public struct AnyDecodable:Decodable{
    public let value:Any
    public init(_ value:Any?){
        self.value = value ?? () //??可以判断左边的值是否为nil，如果是就返回??右侧的值
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = ()
        }else if let bool = try? container.decode(Bool.self){
            self.value = bool
        }else if let int = try? container.decode(Int.self){
            self.value = int
        }else if let uint = try? container.decode(UInt.self){
            self.value = uint
        }else if let double = try? container.decode(Double.self){
            self.value = double
        }else if let string = try? container.decode(String.self){
            self.value = string
        }else if let array = try? container.decode([AnyDecodable].self){
            self.value = array.map{ $0.value }
        }else if let dictionary = try? container.decode([String:AnyDecodable].self){
            self.value = dictionary.map{ $0.value }
        }else{
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable value cannot be decoded")
        }
    }
}

struct LocationInfo:Decodable{
    var coordinates:[AnyDecodable]
}

class ViewController: UIViewController {
 //MARK:-  json1
    let json = """
    {
        "aircraft": {
            "identification": "NA12345",
            "color": "Blue/White"
        },
        "route": ["KTTD", "KHIO"],
        "departure_time": {
            "proposed": "2018-04-20T14:15:00-0700",
            "actual": "2018-04-20T14:20:00-0700"
        },
        "flight_rules": "IFR",
        "remarks": null
    }
    """.data(using: .utf8)!
 //MARK:-  json2
    let json2 = """
    {
        "points": ["KSQL", "KWVI"],
        "KSQL": {
            "code": "KSQL",
            "name": "San Carlos Airport"
        },
        "KWVI": {
            "code": "KWVI",
            "name": "Watsonville Municipal Airport"
        }
    }
    """.data(using: .utf8)!
    
  //MARK:-  json3//这种只有傻逼后端才会弄出来的格式，
    let json3 = """
    {
    "coordinates": [
            {
                "latitude": 37.332,
                "longitude": -122.011
            },
            [-122.011, 37.332],
            "37.332, -122.011"
        ]
    }
    """.data(using: .utf8)!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            //MARK:-       json1   json2
            let point1:Route =  try decoder.decode(Route.self,from:json2)
            
            for point in point1.points{
                print("name = \(point.name),code = \(point.code)")
            }
            
            let p1name = point1.points[0].name
            print("name = \(p1name)")
            
        }catch{
            print("error = \(error)")
        }
 
        
        let arr = [1,3,2]
        
        //用reduce 实现 map
        let res = arr.reduce([]) { (a:[Int], element:Int) -> [Int] in
            var t = Array(a)
            t.append(element * 2)
            return t
        }
        
        print("res = \(res)")
        
        
        do{
             let localInfo = try decoder.decode(LocationInfo.self, from: json3)
             print("localInfo = \(localInfo)")
        }catch{
             print("error = \(error)")
        }
        
        
        var value:Int?
        var totalValue:Int = 0
        //正常的拆包
        if let res = value {
            totalValue = res * 2
        }
        

        var testArr:[Any?] = [1,"aaa",nil]
        
        //骚套路 - 不拆包进行操作
        let wrapValue = value.map{
            $0 * 2
        }
        
        let noOptionArr = testArr.flatMap {
            $0
        }
        print("no optional = \(noOptionArr)")
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

