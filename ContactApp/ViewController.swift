//
//  ViewController.swift
//  ContactApp
//
//  Created by Nuclei on 01/07/21.
//

import UIKit
import Contacts

var contacts = [FetchedContact]()
let store = CNContactStore()
class ViewController: UIViewController {
    var searchFilter = [FetchedContact]()
    var isSearching = false
    
    @IBOutlet weak var contactTable: UICollectionView!
    private let imageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        imageView.image = UIImage(named: "Image")
        return imageView
    }()
   
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        title = "Contact Application"
        contactTable.register(UINib(nibName: "GridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectioncell")
        contactTable.reloadData()
        fetchContacts()

    }
    override func viewWillAppear(_ animated: Bool) {
        contactTable.reloadData()
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

        if isSearching {
            cell.namehandler.text = searchFilter[indexPath.row].firstName + " " + searchFilter[indexPath.row].lastName
//            cell.telephonehandler?.text = searchFilter[indexPath.row].telephone
            cell.imagehandler.image = UIImage(data: searchFilter[indexPath.row].favicon ?? Data("".utf8)) ?? UIImage(named : "def")
        } else {
        cell.namehandler.text = contacts[indexPath.row].firstName + " " + contacts[indexPath.row].lastName
        //tempName = contacts[indexPath.row].firstName + " " + contacts[indexPath.row].lastName
//        cell.telephonehandler?.text = contacts[indexPath.row].telephone
        //tempMobile = contacts[indexPath.row].telephone
        cell.imagehandler.image = UIImage(data: contacts[indexPath.row].favicon ?? Data("".utf8)) ?? UIImage(named: "def")!
         
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
        searchFilter = contacts.filter({ $0.fullName.lowercased().prefix(searchText.count) == searchText.lowercased() })
        isSearching = true
        contactTable.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        contactTable.reloadData()
    }
}



