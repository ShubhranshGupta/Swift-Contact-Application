//
//  AddContactViewController.swift
//  ContactApp
//
//  Created by Nuclei on 02/07/21.
//

import UIKit
import Contacts

class AddContactViewController: UIViewController {
    var tempFirstName : String = ""
    var tempLastName : String  = ""
    var tempTelephone : String = ""
    var tempImage : Data? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var imageLabel: UIImageView!
    @IBAction func saveContact(_ sender: Any) {
        if telephoneLabel.text == nil || firstName.text == nil {
            didShowAlertForError()
        } else {
            didStoreData()
        }
        
    }
    @IBOutlet weak var firstName: UITextField!

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
        newContact.givenName = firstName.text ?? "Untitled"
        newContact.familyName = lastName.text ?? ""
        if let img = imageLabel.image,
           let data = img.pngData(){
          newContact.imageData = data
        }
        let homePhone = CNLabeledValue(label: CNLabelHome,
                                       value: CNPhoneNumber(stringValue: telephoneLabel.text ?? "000"))
        newContact.phoneNumbers = [homePhone]
        newContact.note = "This contact is added by third-party app"
        let request = CNSaveRequest()
        request.add(newContact, toContainerWithIdentifier: nil)
        do{
            try store.execute(request)
            addContactInCache()
          print("Successfully stored the contact")
        } catch let err{
          print("Failed to save the contact. \(err)")
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
        contacts.append(currentContact)
    }
    func updateLabels() {
        firstName.text = tempFirstName
        lastName.text = tempLastName
        telephoneLabel.text = tempTelephone
        if tempImage != nil {
            imageLabel.image = UIImage(data: tempImage ?? Data("".utf8))
        } else {
            imageLabel.image = UIImage(named: "def")
        }
    }
}
