//
//  KBMainVC.swift
//  KartBuys
//
//  Created by Krishna Panchal on 06/01/24.
//

import UIKit
import CoreData

class KBMainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var KBTableView: UITableView!
    
    var controller: NSFetchedResultsController<KBItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        KBTableView.delegate = self
        KBTableView.dataSource = self
        
        //generateTestData()
        attemptKBFetch()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Creating cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "KBItemCell", for: indexPath) as! KBItemCell
        
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    func configureCell(cell: KBItemCell, indexPath:NSIndexPath) {
        
        let item = controller.object(at: indexPath as IndexPath)
        cell.configureKBCell(item: item)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let objects = controller.fetchedObjects , objects.count > 0 {
            
            let item = objects[indexPath.row]
            performSegue(withIdentifier: "KBItemDetailVC", sender: item)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "KBItemDetailVC" {
            if let destination = segue.destination as? KBItemDetailVC {
                if let item = sender as? KBItem {
                    destination.kbItemToEdit = item
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = controller.sections {
            
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = controller.sections {
            
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 150
    }
    
    func attemptKBFetch() {
        let fetchRequest: NSFetchRequest<KBItem> = KBItem.fetchRequest()

        // Add a predicate to exclude items with empty data
        fetchRequest.predicate = NSPredicate(format: "title != '' AND price != 0 AND details != ''")

        let dateSort = NSSortDescriptor(key: "created", ascending: false)
        let priceSort = NSSortDescriptor(key: "price", ascending: false)
        let titleSort = NSSortDescriptor(key: "title", ascending: true)

        if segment.selectedSegmentIndex == 0 {
            fetchRequest.sortDescriptors = [dateSort]
        } else if segment.selectedSegmentIndex == 1 {
            fetchRequest.sortDescriptors = [priceSort]
        } else if segment.selectedSegmentIndex == 2 {
            fetchRequest.sortDescriptors = [titleSort]
        }

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // In order for methods below to work
        controller.delegate = self
        
        self.controller = controller
        
        do {
            try controller.performFetch()
        } catch {
            let error = error as NSError
            print("\(error)")
        }
    }

    
    @IBAction func segmentChange(_ sender: UISegmentedControl) {
        
        attemptKBFetch()
        KBTableView.reloadData()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        KBTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        KBTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
            
        case.insert:
            if let indexPath = newIndexPath {
                KBTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case.delete:
            if let indexPath = indexPath {
                KBTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case.update:
            if let indexPath = indexPath {
                let cell = KBTableView.cellForRow(at: indexPath) as! KBItemCell
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
        case.move:
            if let indexPath = indexPath {
                KBTableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                KBTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
    }
    
}
