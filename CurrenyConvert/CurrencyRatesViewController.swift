//
//  CurrencyRatesViewController.swift
//  CurrenyConvert
//
//  Created by Aditya Mehra on 10/08/17.
//  Copyright © 2017 Aditya Mehra. All rights reserved.

import UIKit
import CoreData

class CurrencyRatesViewController: CoreDataTableViewController {
    
    @IBOutlet weak var setBaseCurrency: UIBarButtonItem!
    
    let container = CoreDataStack.shared.persistentContainer
   
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the title
        
        title = "Currency Rates"
        
        hideKeyBoardWhenTappedAround()
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(fetchAndLoad), for: .valueChanged)
        //tableView.addSubview(refreshControl)  not required in UITAbleViewController
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Change", style: .plain, target: self, action: nil)
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyRates")
        fr.sortDescriptors = [NSSortDescriptor(key: "currencyID", ascending: true),
                              NSSortDescriptor(key: "rate", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        let baseCurrency = UserDefaults.standard.object(forKey: "baseCurrency") as! String
        let baseCurrencySymbol = getKeyForSomeValue(supportedCountries, baseCurrency)
        setBaseCurrency.title = baseCurrencySymbol
        
        if !(isConnectedToNetwork()) {
            setBaseCurrency.isEnabled = false
        }
        
        fetchAndLoad()
    }
}

extension CurrencyRatesViewController {
    
  
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "DateTimeRefresh")
        let entities : [NSManagedObject]
        entities = try! container.viewContext.fetch(fr) as! [NSManagedObject]
        var dateTime : String?
        for entity in entities {
            dateTime = entity.value(forKey: "refresh") as? String
        }
        return dateTime
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currencyRate = fetchedResultsController!.object(at: indexPath) as! CurrencyRates
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
        
        cell.textLabel?.text = currencyRate.currencyID
        cell.detailTextLabel?.text = "\(currencyRate.rate)"
        return cell
    }
    
}

extension CurrencyRatesViewController : UISearchBarDelegate {
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyRates")
        
        var pred : NSPredicate?
        if (searchBar.text != nil) {
            pred = NSPredicate(format: "currencyID contains[cd] %@", searchBar.text!)
            fr.predicate = pred
        }
        if (searchBar.text == "") {
            fr.predicate = nil
        } // added because on "" condition : table shows no content
        
        fr.sortDescriptors = [NSSortDescriptor(key: "currencyID", ascending: true),
                              NSSortDescriptor(key: "rate", ascending: false)]
        
            
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
}

extension CurrencyRatesViewController {
    
    func hideKeyBoardWhenTappedAround() {
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CurrencyRatesViewController {
    
    func fetchAndLoad() {
        if (isConnectedToNetwork()) {
            
            User.shared.extractCurrencyData{ (data, error, success) in
                if !(success) {
                    print(error!)
                    self.executeSearch()
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                } else {
                    
                    self.deleteContent()
                    
                    guard let importData = data else {
                        print("error saving fetched data")
                        return
                    }
                  
                    self.saveContent(importData)
                    self.refreshControl?.endRefreshing()
                }
            }
        }else {
            print("not connected to network")
        }
            }
}
