//
//  messaging.swift
//  WildcatExchange
//
//  Created by Oukolov, Daniel on 12/1/23.
//

import Foundation
import Firebase

class ChatViewController: UIViewController {
    var ref: DatabaseReference!
    // Connect to Firebase Database
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }

    // Send message function
    func sendMessage(text: String) {
        let message = ["sender": User.current.username, "text": text]
        self.ref.child("messages").childByAutoId().setValue(message)
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            ref = Database.database().reference()
            // Observe for new messages
            ref.child("messages").observe(.childAdded) { (snapshot) in
                if let message = snapshot.value as? [String: Any] {
                    let text = message["text"] as! String
                    let sender = message["sender"] as! String
                    let newMessage = Message(text: text, sender: sender)
                    self.messages.append(newMessage)
                    self.tableView.reloadData()
                }
            }
        }
    
    @IBOutlet weak var tableView: UITableView!
        // ...

        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.delegate = self
            tableView.dataSource = self
            // ...
        }
        
        // MARK: - UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return messages.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            let message = messages[indexPath.row]
            cell.textLabel?.text = message.text
            cell.detailTextLabel?.text = message.sender
            return cell
        }
    
    // ...
        @IBOutlet weak var messageTextField: UITextField!
        // ...

        // Send button action
        @IBAction func sendButtonTapped(_ sender: UIButton) {
            guard let text = messageTextField.text, !text.isEmpty else {
                return
            }
            sendMessage(text: text)
            messageTextField.text = ""
        }
    
    // ...
       var storageRef: StorageReference!
       // ...
       override func viewDidLoad() {
           super.viewDidLoad()
           storageRef = Storage.storage().reference()
       }

       func uploadMultimedia(file: Data, fileName: String) {
           let metadata = StorageMetadata()
           metadata.contentType = "file/type"
           // File type could be image, video, pdf, audio etc
           let fileRef = storageRef.child("multimedia").child(fileName)
           _ = fileRef.putData(file, metadata: metadata) { (metadata, error) in
             if let error = error {
               print("Error uploading: \(error)")
               return
             }
             // File uploaded successfully
           }
       }
    
    func getDownloadURL(for fileName: String) -> String? {
        let fileRef = storageRef.child("multimedia").child(fileName)
        fileRef.downloadURL { (url, error) in
            if let error = error {
                print("Error getting download URL: \(error)")
                return nil
            }
            return url?.absoluteString
        }
    }
}
