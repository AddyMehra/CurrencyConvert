//
//  chooseBaseCurrencyViewController.swift
//  CurrenyConvert
//
//  Created by Aditya Mehra on 12/08/17.
//  Copyright © 2017 Aditya Mehra. All rights reserved.
//

import UIKit
import CoreData

class chooseBaseCurrencyViewController: UITableViewController {
    
    let container = CoreDataStack.shared.persistentContainer
    
    var searchActive : Bool = false
    
    var temporaryBaseCurrency = UserDefaults.standard.object(forKey: "baseCurrency") as! String
    
    var data : [supportedCountryData] = []
    var filteredData : [supportedCountryData] = []
    var baseCurrency : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose Your Country"
        
        hideKeyBoardWhenTappedAround()
        
        data = structObjectOfCountryData(supportedCountries)
        
        data.sort { (scd1 , scd2) in
            scd1.countryName < scd2.countryName
            } // sort required because dictionary to struct gives unsorted objects
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if isConnectedToNetwork() {
            performUpdation() // check if newBaseCurrency is different. If different then drop core data stack, fetch new data and update mainViewTable
        } else {
            //print("internet connection lost - preference cannot be saved")
        }
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchActive) {
            return filteredData.count
        }
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "baseCurrency")
        
        if (searchActive) {
            cell?.textLabel?.text = filteredData[indexPath.row].countryName
            cell?.detailTextLabel?.text = filteredData[indexPath.row].countryCurrencySym

        } else {
            cell?.textLabel?.text = data[indexPath.row].countryName
            cell?.detailTextLabel?.text = data[indexPath.row].countryCurrencySym
        }
        
        if cell?.textLabel?.text == temporaryBaseCurrency {
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell?.accessoryType == UITableViewCellAccessoryType.none {
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            
            temporaryBaseCurrency = (cell?.textLabel?.text)!
            
            tableView.reloadData()
        }
    }
        

}

extension chooseBaseCurrencyViewController : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if (searchBar.text != nil) {
            searchActive = true
        }
        
        if (searchBar.text == "") {
            searchActive = false
        } // added because on "" condition : table shows no content
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text != nil {
            searchActive = true
        }
        
        if (searchBar.text == "") {
            searchActive = false
        } // added coz on "" condition : table shows no content
        
        let filter = supportedCountries.filter { pair in
            pair.value.contains(searchText)
        } // this returns array of tuples
        
        var filterData : [String:String] = [:]
        
        filter.forEach { pair in
            filterData[pair.key] = pair.value
        } // this converts array of tuples to dictionary
        
        filteredData = structObjectOfCountryData(filterData)
        
        filteredData.sort { (fcd1 , fcd2) in
            fcd1.countryName < fcd2.countryName
        } // sort required because dictionary to struct gives unsorted objects
        
        self.tableView.reloadData()
    }
    
}

extension chooseBaseCurrencyViewController {

    func performUpdation() {
        
        let currency = UserDefaults.standard.object(forKey: "baseCurrency") as! String

        if currency != temporaryBaseCurrency {
            
            UserDefaults.standard.set(temporaryBaseCurrency, forKey: "baseCurrency")
            UserDefaults.standard.synchronize()
            
            container.performBackgroundTask{ (context) in
                
                var fr =  NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyRates")
                var deleteRequest = NSBatchDeleteRequest(fetchRequest: fr)
                do {
                    try context.execute(deleteRequest)
                } catch {
                    fatalError("\(error)")
                }
                fr =  NSFetchRequest<NSFetchRequestResult>(entityName: "DateTimeRefresh")
                deleteRequest = NSBatchDeleteRequest(fetchRequest: fr)
                do {
                    try context.execute(deleteRequest)
                    try context.save()
                } catch {
                    fatalError("\(error)")
                }
            }

        } else {
            return
        }
    }
}

extension chooseBaseCurrencyViewController {
    
    func hideKeyBoardWhenTappedAround() {
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}


