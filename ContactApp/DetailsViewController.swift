//
//  DetailsViewController.swift
//  ContactApp
//
//  Created by Nuclei on 01/07/21.
//

import UIKit
import Contacts
protocol RefreshDataDelegate {
    func refreshDataToHomeViewController(currData : Int)
}
class DetailsViewController: UIViewController {
    var contactD = [FetchedContact]()
    var myIndex = 0
    var refreshDelegate: RefreshDataDelegate?
    @IBOutlet weak var telephonehandler: UILabel!
    @IBOutlet weak var dphandler: UIImageView!
    @IBOutlet weak var namehandler: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeButton(buttonName: deletebutton)
        loadData()
        //loadData()
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var emailhandler: UILabel!
    @IBAction func deletebutton(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Do you really want to delete this contact?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] action in
            self.didDeleteContact()
            ContactApp.contacts.remove(at: myIndex)
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
       
    }
    private func loadData() {
        namehandler.text = contactD[myIndex].fullName
        telephonehandler.text = contactD[myIndex].telephone
        dphandler.image = UIImage(data : contactD[myIndex].favicon ?? Data("".utf8)) ?? UIImage(named: "def")
        emailhandler.text = "No Email Exist"
        }
    @IBOutlet weak var deletebutton: UIButton!
    
    @IBAction func updatehandler(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(identifier: "AddContactViewController") as! AddContactViewController
        viewController.currContact? = contactD[myIndex]
        viewController.index = myIndex
        viewController.tempFirstName = contactD[myIndex].firstName
        viewController.tempLastName = contactD[myIndex].lastName
        viewController.tempTelephone = contactD[myIndex].telephone
        viewController.tempImage = contactD[myIndex].favicon ?? Data("def".utf8)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension DetailsViewController {
    func customizeButton(buttonName : UIButton) {
        // change UIbutton propertie
//        let c1GreenColor = (UIColor(red: -0.108958, green: 0.714926, blue: 0.758113, alpha: 1.0))
        //let c2GreenColor = (UIColor(red: 0.108958, green: 0.714926, blue: 0.758113, alpha: 1.0))
        //buttonName.backgroundColor = UIColor.systemBlue
        buttonName.layer.cornerRadius = 30
        //buttonName.layer.borderWidth = 0.2
        //buttonName.layer.borderColor = c1GreenColor.cgColor
        
       // buttonName.layer.shadowColor = UIColor.cyan
//        buttonName.layer.shadowOpacity = 0.3
//        buttonName.layer.shadowRadius = 11
//        buttonName.layer.shadowOffset = CGSize(width: 1, height: 1)
//
//        buttonName.setImage(UIImage(named:"plus"), for: .normal)
//        buttonName.imageEdgeInsets = UIEdgeInsets(top: 6,left: 100,bottom: 6,right: 14)
//        buttonName.titleEdgeInsets = UIEdgeInsets(top: 0,left: -30,bottom: 0,right: 34)
        
    }
    func didDeleteContact() {

        OperationQueue().addOperation{[self, unowned store] in
            let predicate = CNContact.predicateForContacts(matchingName: contactD[myIndex].telephone )
          let toFetch = [CNContactGivenNameKey]

          do{

            let contacts = try store.unifiedContacts(matching: predicate,
                                                keysToFetch: toFetch as [CNKeyDescriptor])

            guard contacts.count > 0 else{
              print("No contacts found")
              return
            }

            //only do this to the first contact matching our criteria
            guard let contact = contacts.first else{
              return
            }

            let req = CNSaveRequest()
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            req.delete(mutableContact)

            do{
                try store.execute(req)
              print("Successfully deleted the user")

            } catch let e{
              print("Error = \(e)")
            }

          } catch let err{
            print(err)
          }
        }
        if self.refreshDelegate != nil {
            self.refreshDelegate?.refreshDataToHomeViewController(currData : myIndex)
        }
        dismiss(animated: true, completion: nil)
    }
}
