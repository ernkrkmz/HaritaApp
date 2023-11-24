//
//  ViewController.swift
//  HaritaApp
//
//  Created by Eren Korkmaz on 17.04.2023.
//

import UIKit
import CoreData
class ViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var nameString      = [String]()
    var idString        = [UUID]()
    
    var secilenYerisim  = ""
    var secilenYerid    : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        
        veriAl()
    }
    override func viewDidAppear(_ animated: Bool) {
        
        secilenYerisim  = ""
        secilenYerid    = nil
        veriAl()
    }
    
    func veriAl(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        request.returnsObjectsAsFaults = false
        
        do{
            let sonuclar = try context.fetch(request)
            
            if sonuclar.count > 0 {
                nameString.removeAll(keepingCapacity: false)
                idString.removeAll(keepingCapacity: false)
                
                for sonuc in sonuclar as! [NSManagedObject] {
                    
                    if let name = sonuc.value(forKey: "name") as? String {
                        nameString.append(name)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idString.append(id)
                    }
                }
                
            }
            nameString.reverse()
            idString.reverse()
            tableView.reloadData()
            
        }catch{
            
        }
        
    }
    
    @objc func addItem(){
            secilenYerisim  = ""
            performSegue(withIdentifier: "toDetailsVC", sender: nil)
        }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameString.count
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameString[indexPath.row]
        return cell
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenYerisim = nameString[indexPath.row]
        secilenYerid = idString[indexPath.row]
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.secilenisim = secilenYerisim
            destinationVC.secilenid = secilenYerid
            
        }
    }
    
}

