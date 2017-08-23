//
//  UpdationDeletionConvinience.swift
//  CurrenyConvert
//
//  Created by Aditya Mehra on 21/08/17.
//  Copyright © 2017 Aditya Mehra. All rights reserved.
//

import CoreData

let container = CoreDataStack.shared.persistentContainer

extension CurrencyRatesViewController {
    
    func deleteContent() {
        
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
    }
    
    func saveContent(_ data : [String : Float]) {
        
        container.performBackgroundTask{ (context) in
            
            let updateDateTime = DateTimeRefresh(context: context)
            updateDateTime.refresh = self.getPresentDateTime()
            
            for keys in data {
                let currencyData = CurrencyRates(context: context)
                currencyData.currencyID = keys.key
                currencyData.rate = keys.value
            }
            
            do {
                 
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            self.executeSearch()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getPresentDateTime() -> String {
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        let hr = components.hour
        let mm = components.minute
        let ss = components.second
        
        return("\(day!)-\(month!)-\(year!) \(hr!):\(mm!):\(ss!)")
    }

}



