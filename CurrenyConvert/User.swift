//
//  User.swift
//  CurrenyConvert
//
//  Created by Aditya Mehra on 11/08/17.
//  Copyright © 2017 Aditya Mehra. All rights reserved.
//

import Foundation
import UIKit

let delegate = UIApplication.shared.delegate as! AppDelegate
//let stack = delegate.stack

class User : NSObject {
    
    // Can't init is singleton
    private override init() { }
    
    static let apiID = "c9731aacdfdf4253b4f7995fb929cc4b"
    static let shared = User()
    
    func getDataTask(_ url : String , _ completionClosure : @escaping ((_ serialisedJSON : [String : AnyObject]? , _ error : String?) -> Void)) {
        
        let _url = URL(string: url)
        
        let urlRequest = URLRequest(url: _url!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data , response , error)  in
            
            guard let data = data else {
                completionClosure(nil, "error hitting \(_url)")
                return
            }
            let jsonData : [String:AnyObject]?
            do {
                jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
                completionClosure(jsonData,nil)
            } catch {
                completionClosure(nil, "error serializing data for \(_url)")
            }
        }
        task.resume()
        
    }
    
    func extractCurrencyData(_ completionClosure : @escaping ((_ data : [String : Float]? , _ error : String? , _ success : Bool) -> Void)) -> Void {
        
        let baseCurrency = UserDefaults.standard.object(forKey: "baseCurrency") as! String
        let baseCurrencySymbol = getKeyForSomeValue(supportedCountries, baseCurrency)
        
        let url = "https://openexchangerates.org/api/latest.json?app_id=" + User.apiID + "&base=" + baseCurrencySymbol!
        
        getDataTask(url) { (serialisedJSON , error) in
            guard let data = serialisedJSON else {
                completionClosure(nil, error, false)
                return
            }
            guard let currencyData = data["rates"] as? [String : Float] else {
                let error = data["description"] as! String
                completionClosure(nil, error, false)
                return
            }
            //print(currencyData)
            completionClosure(currencyData, nil, true)
        }
    }
}
