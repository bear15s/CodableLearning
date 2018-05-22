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
    
    private enum CodingKeys:String,CodingKey{
        case identification
        case color
        case flightRules = "flight_rules"
        case route
        case departureDate = "departure_time"
        case remarks
    }
}

class ViewController: UIViewController {

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let airplan1 = try decoder.decode(Aircraft.self,from:json)
            print("airplan = \(airplan1)")
        }catch{
            print("error = \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

