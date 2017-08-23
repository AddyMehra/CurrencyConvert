//
//  CountryCurrencyData.swift
//  CurrenyConvert
//
//  Created by Aditya Mehra on 12/08/17.
//  Copyright © 2017 Aditya Mehra. All rights reserved.
//

import Foundation

struct supportedCountryData {
    var countryName : String
    var countryCurrencySym : String

    init() {
        countryName = ""
        countryCurrencySym = ""
    }
}
    
func structObjectOfCountryData(_ data : Dictionary<String,String>) -> [supportedCountryData] {
    
    var returnedData : [supportedCountryData] = []
    
    for keys in data {
        var newItem = supportedCountryData()
        newItem.countryName = keys.value
        newItem.countryCurrencySym = keys.key
        returnedData.append(newItem)
    }
    
    return returnedData
}

func getKeyForSomeValue(_ dic : Dictionary<String,String> , _ val : String) -> String? {
    
    var key : String?
    
    for keys in dic {
        if keys.value == val {
            key = keys.key
        }
    }
    
    return key
}


