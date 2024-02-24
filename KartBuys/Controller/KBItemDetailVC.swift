//
//  KBItemDetailVC.swift
//  KartBuys
//
//  Created by Krishna Panchal on 06/01/24.
//

import UIKit
import CoreData

class KBItemDetailVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var storeKBPicker: UIPickerView!
    @IBOutlet weak var titleTF: CustomTextField!
    @IBOutlet weak var priceTF: CustomTextField!
    @IBOutlet weak var detailsTF: CustomTextField!
    
    @IBOutlet weak var thumbImage: UIImageView!
    
    var stores = [KBStore]()
    
    var kbItemToEdit: KBItem?
    
    var imageKBPicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let kbTextFields = [titleTF, priceTF, detailsTF]
        
        for textField in kbTextFields {
            textField?.backgroundColor = #colorLiteral(red: 0.9140681624, green: 0.9339862466, blue: 0.9465422034, alpha: 1)
        }
        
        self.hideKeyboardWhenTappedAround()
        
        //Navigation bar styling
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        }
        
        storeKBPicker.delegate = self
        storeKBPicker.dataSource = self
        
        imageKBPicker = UIImagePickerController()
        imageKBPicker.delegate = self
        
        getKBStores()
        
        if kbItemToEdit != nil {
            loadKBItemData()
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let store = stores[row]
        return store.name
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return stores.count
    }
    
    func numberOfComponents(in: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //Update when selected
    }
    
    //Fetch stores.
    func getKBStores() {
        let fetchRequest: NSFetchRequest<KBStore> = KBStore.fetchRequest()
        
        do {
            self.stores = try context.fetch(fetchRequest)
            
            // If there are no stores, add default ones
            if stores.isEmpty {
                addDefaultStores()
                getKBStores() // Reload the data after adding default stores
            }
            
            self.storeKBPicker.reloadAllComponents()
            
        } catch {
            // Handle error
        }
    }
    
    func addDefaultStores() {
        let defaultStoreNames = ["Amazon", "Flipkart", "Shein", "Urbanic"]
        
        for storeName in defaultStoreNames {
            let defaultStore = KBStore(context: context)
            defaultStore.name = storeName
        }
        
        ad.saveContext()
    }
    
    func showAddStoreAlert() {
        let alert = UIAlertController(title: "Add Store Name", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter store name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let storeName = alert.textFields?.first?.text, !storeName.isEmpty {
                self?.addStoreToData(storeName: storeName)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func addStoreToData(storeName: String) {
        let newStore = KBStore(context: context)
        newStore.name = storeName
        ad.saveContext()
        
        // Reload your data after adding the new store
        getKBStores()
    }
    
    @IBAction func addStore(_ sender: UIButton) {
        showAddStoreAlert()
    }
    
    @IBAction func savePressed(_ sender: UIButton){
        var item: KBItem!
        let picture = KBImage(context: context)
        picture.image = thumbImage.image

        // If creating a new entry
        if kbItemToEdit == nil {
            item = KBItem(context: context)
        } else {
            item = kbItemToEdit
        }

        item.toImage = picture

        guard let title = titleTF.text, !title.isEmpty,
              let priceText = priceTF.text, !priceText.isEmpty,
              let details = detailsTF.text, !details.isEmpty else {
            showAlert(message: "Please fill in all required fields.")
            return
        }

        guard let price = Double(priceText) else {
            showAlert(message: "Invalid price format.")
            return
        }

        item.title = title
        item.price = price
        item.details = details
        item.toStore = stores[storeKBPicker.selectedRow(inComponent: 0)]

        ad.saveContext()

        backToMainScreen()
    }


    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Input Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        
        if kbItemToEdit != nil {
            
            context.delete(kbItemToEdit!)
            
            ad.saveContext()
        }
        
        backToMainScreen()
    }
    
    func backToMainScreen() {
        
        //Dismiss view once new entry is made.
        _ = navigationController?.popViewController(animated: true)
    }
    
    func loadKBItemData() {
        
        
        if let item = kbItemToEdit {
            
            titleTF.text = item.title
            priceTF.text = "\(item.price)"
            detailsTF.text = item.details
            
            thumbImage.image = item.toImage?.image as? UIImage
            
            if let store = item.toStore {
                
                var index = 0
                
                repeat {
                    
                    let s = stores[index]
                    if s.name == store.name {
                        storeKBPicker.selectRow(index, inComponent: 0, animated: false)
                        break
                    }
                    
                    index += 1
                    
                } while (index < stores.count)
            }
        }
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        
        present(imageKBPicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            thumbImage.image = img
        }
        
        imageKBPicker.dismiss(animated: true, completion: nil)
    }
    
}
