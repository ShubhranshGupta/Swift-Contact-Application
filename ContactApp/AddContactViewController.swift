//
//  AddContactViewController.swift
//  ContactApp
//
//  Created by Nuclei on 02/07/21.
//

import UIKit
import Contacts
protocol MyDataSendingProtocol {
    func sendDataToHomeViewController(myData: FetchedContact)
}
class AddContactViewController: UIViewController {
    var delegate: MyDataSendingProtocol? = nil
    lazy var currContact : FetchedContact? = nil
    var index = 0
    var tempFirstName : String = ""
    var tempLastName : String  = ""
    var tempTelephone : String = ""
    var tempImage : Data? = nil
    var isUpdate = false
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.addTarget(self, action:#selector(willCheckAndDisplayErrorsForName(firstName:)), for: .editingChanged)
        telephoneLabel.addTarget(self, action:#selector(willCheckAndDisplayErrorsForTelephone(telephoneLabel:)), for: .editingChanged)
        updateLabels()
        // Do any additional setup after loading the view.
    }
    @objc func willCheckAndDisplayErrorsForName(firstName : UITextField) {
        if firstName.text?.count ?? 0 < 3 {
            errorLabel.text = "Name is missing"
        }else {
            errorLabel.text = " "
        }
    }
    @objc func willCheckAndDisplayErrorsForTelephone(telephoneLabel : UITextField) {
        if telephoneLabel.text?.count ?? 0 < 9 {
            errorLabel.text = "Contact must be of 10 digits"
        }else {
            errorLabel.text = " "
        }
    }
    @IBOutlet weak var imageLabel: UIImageView!
    @IBAction func saveContact(_ sender: Any) {
          if isUpdate {
             didUpdateContacts()
          } else {
             didStoreData()
          }
        
        
    }
    @IBOutlet weak var firstName: UITextField!

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var telephoneLabel: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

    
}
extension AddContactViewController {
    private func didStoreData() {
        //let store = CNContactStore()
        let newContact = CNMutableContact()
        newContact.givenName = firstName.text ?? ""
        newContact.familyName = lastName.text ?? ""
        if let img = imageLabel.image,
           let data = img.pngData(){
          newContact.imageData = data
        }
        let homePhone = CNLabeledValue(label: CNLabelHome,
                                       value: CNPhoneNumber(stringValue: telephoneLabel.text ?? ""))
        newContact.phoneNumbers = [homePhone]
        newContact.note = "This contact is added by third-party app"
        let request = CNSaveRequest()
        request.add(newContact, toContainerWithIdentifier: nil)
        do{
            try store.execute(request)
            //addContactInCache()
          print("Successfully stored the contact")
        } catch let err{
          print("Failed to save the contact. \(err)")
        }
        if self.delegate != nil {
            let tempFullName = (firstName.text ?? "") + " " + (lastName.text ?? "")
            let currentContact = FetchedContact(firstName: firstName.text ?? "", lastName: lastName.text ?? "", fullName: tempFullName, telephone: telephoneLabel.text ?? "", favicon: imageLabel.image?.pngData())
                    self.delegate?.sendDataToHomeViewController(myData: currentContact)
        }
        didShowSuccessAlert()
    }
    private func didShowSuccessAlert() {
        let alert = UIAlertController(title: "Alert", message: "Contact saved Successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            self.navigationController?.popToRootViewController(animated: true)
        }))

        self.present(alert, animated: true, completion: nil)

    }
    private func didShowAlertForError() {
        let alert = UIAlertController(title: "Alert", message: "Add required fields first to save your contact", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            
        }))

        self.present(alert, animated: true, completion: nil)
    }
    private func addContactInCache() {
        let tempFullName = (firstName.text ?? "") + " " + (lastName.text ?? "")
        let currentContact = FetchedContact(firstName: firstName.text ?? "", lastName: lastName.text ?? "", fullName: tempFullName, telephone: telephoneLabel.text ?? "", favicon: imageLabel.image?.pngData())
        ContactApp.contacts.append(currentContact)
    }
    func updateLabels() {
        firstName.text = tempFirstName
        lastName.text = tempLastName
        telephoneLabel.text = tempTelephone
        if tempImage != nil {
            imageLabel.image = UIImage(data: tempImage ?? Data("".utf8)) ?? UIImage(named : "default")
        } else if tempImage?.count ?? 0 < 1 {
            imageLabel.image = UIImage(named: "default")
        }
        isUpdate = true
    }
    func didUpdateContacts() {
        didDeleteContact()
        ContactApp.contacts.remove(at : index)
        didStoreData()
    }
    func didDeleteContact() {
        OperationQueue().addOperation{[self,unowned store] in
            guard let searchPred = currContact?.telephone else {
                debugPrint("Error while updating")
                return
            }
            let predicate = CNContact.predicateForContacts(matchingName: searchPred)
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
    }
}
