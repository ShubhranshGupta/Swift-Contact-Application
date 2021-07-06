//
//  ViewController.swift
//  ContactApp
//
//  Created by Nuclei on 01/07/21.
//

import UIKit
import Contacts

var contacts : [FetchedContact] = []
let store = CNContactStore()
class ViewController: UIViewController {
    
    var searchFilter = [FetchedContact]()
    var isSearching = false
    var isChangeLayout = true
    @IBOutlet weak var contactTable: UICollectionView!
    private let imageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        imageView.image = UIImage(named: "Image")
        return imageView
    }()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backsegue" {
            let secondVC: AddContactViewController = segue.destination as! AddContactViewController
            secondVC.delegate = self
        }
        if segue.identifier == "forwardsegue" {
            let secondVC: DetailsViewController = segue.destination as! DetailsViewController
            secondVC.refreshDelegate = self
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        title = "Contact App"
        contactTable.register(UINib(nibName: "GridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectioncell")
        contactTable.reloadData()
        tableview.register(UINib(nibName: "ConatctViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableview.reloadData()
        fetchContacts()
        
    }
    
    @IBOutlet weak var tableview: UITableView!
    @IBAction func didChangeLayout(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            contactTable.alpha = 0
            tableview.alpha = 1
            tableview.register(UINib(nibName: "ConatctViewCell", bundle: nil), forCellReuseIdentifier: "cell")
            tableview.reloadData()
            isChangeLayout = false
        } else {
            tableview.alpha = 0
            contactTable.alpha = 1
            contactTable.register(UINib(nibName: "GridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectioncell")
            contactTable.reloadData()
            isChangeLayout = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isChangeLayout {
        contactTable.reloadData()
        } else {
            tableview.reloadData()
        }
        
        //contacts = Array(Set(contacts))
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
            self.animate()
        })
    }
    private func animate() {
        UIView.animate(withDuration: 1, animations: {
            let size = self.view.frame.size.width * 1.5
            let diffx = size - self.view.frame.size.width
            let diffy = self.view.frame.size.height - size
            self.imageView.frame = CGRect(x: -(diffx/2), y: diffy/2, width: size, height: size)
        })
            UIView.animate(withDuration: 1.5, animations: {
            self.imageView.alpha = 0
            })
        
    }


}
extension ViewController : MyDataSendingProtocol {
    func sendDataToHomeViewController(myData: FetchedContact) {
        contacts.append(myData)
    }
}
extension ViewController : RefreshDataDelegate {
    func refreshDataToHomeViewController(currData: Int) {
        if isSearching {
            searchFilter.remove(at: currData)
        }
        contacts.remove(at : currData)
    }
}


//CollectionView Layout
extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return searchFilter.count
        } else {
        return contacts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = contactTable.dequeueReusableCell(withReuseIdentifier: "collectioncell", for: indexPath) as! GridCollectionViewCell
        cell.layer.cornerRadius = 15.0
        cell.layer.borderWidth = 0.2
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 1
        cell.layer.masksToBounds = false 
        
        if isSearching {
            cell.namehandler.text = searchFilter[indexPath.row].firstName + " " + searchFilter[indexPath.row].lastName
//            cell.telephonehandler?.text = searchFilter[indexPath.row].telephone
            cell.imagehandler.image = UIImage(data: searchFilter[indexPath.row].favicon ?? Data("".utf8)) ?? UIImage(named : "default")
        } else {
        cell.namehandler.text = contacts[indexPath.row].firstName + " " + contacts[indexPath.row].lastName
        //tempName = contacts[indexPath.row].firstName + " " + contacts[indexPath.row].lastName
//        cell.telephonehandler?.text = contacts[indexPath.row].telephone
        //tempMobile = contacts[indexPath.row].telephone
        cell.imagehandler.image = UIImage(data: contacts[indexPath.row].favicon ?? Data("".utf8)) ?? UIImage(named: "default")!
         
        //to select selection style
        //cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
        if isSearching {
            viewController.contactD = searchFilter
        } else {
            viewController.contactD = contacts
        }
        viewController.myIndex = indexPath.row
        navigationController?.pushViewController(viewController, animated: true)
    }
    private func fetchContacts() {
        // 1.
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    // 3.
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, fullName: contact.givenName + " " + contact.familyName  , telephone: contact.phoneNumbers.first?.value.stringValue ?? "", favicon : (contact.imageData) ?? Data("".utf8)))
                        
                    })
                    
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
            
        }
        
    }
    
}
//for search bar to search a string
extension ViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchFilter = contacts.filter({ $0.firstName.lowercased().prefix(searchText.count) == searchText.lowercased() })
        isSearching = true
        if isChangeLayout {
        contactTable.reloadData()
        } else {
            tableview.reloadData()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        if isChangeLayout {
        contactTable.reloadData()
        } else {
            tableview.reloadData()
        }
    }
}
//Custom TableView Layout
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return searchFilter.count
        } else {
        return contacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConatctViewCell
        
        if isSearching {
            cell.namehandler.text = searchFilter[indexPath.row].firstName + " " + searchFilter[indexPath.row].lastName
            cell.telephonehandler?.text = searchFilter[indexPath.row].telephone
            cell.imagehandler.image = UIImage(data: searchFilter[indexPath.row].favicon ?? Data("".utf8)) ?? UIImage(named : "default")
        } else {
        cell.namehandler.text = contacts[indexPath.row].firstName + " " + contacts[indexPath.row].lastName
        cell.telephonehandler?.text = contacts[indexPath.row].telephone
        cell.imagehandler.image = UIImage(data: contacts[indexPath.row].favicon ?? Data("".utf8)) ?? UIImage(named: "default")!
         
        //to select selection style
        //cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        }
            return cell
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
        if isSearching {
            viewController.contactD = searchFilter
        } else {
            viewController.contactD = contacts
        }
        viewController.myIndex = indexPath.row
        navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteCell = initDeleteAction(at : indexPath)
        return UISwipeActionsConfiguration(actions: [deleteCell])
    }
    func initDeleteAction(at indexPath : IndexPath) -> UIContextualAction {
        //let currContact = contacts[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completion) in
            contacts.remove(at : indexPath.row)
            self.tableview.deleteRows(at : [indexPath], with : .automatic)
            completion(true)
        }
        //let theme : UIImage = UIImage(named : "🗑")
        action.image = UIImage(named : "bin")
        action.backgroundColor = .red
        return action
    }

}

