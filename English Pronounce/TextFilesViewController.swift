
import UIKit

enum fileAtrribute {
    case fileName
    case fileExtension
}

class TextFilesViewController: UITableViewController {
    
    var filesList = [""]
    let someText = ""
    var userText = ""
    var segueAllowed: [Bool] = []
    var attributedText: NSAttributedString = NSMutableAttributedString(string: "")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        filesList = try! FileManager.default.contentsOfDirectory(atPath: documentsDirectoryURL().path)
    }

    override func viewDidLoad() {
        print("Put your text files along this path:")
        print(documentsDirectoryURL())
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        segueAllowed.append(false)
        let labelText = cell.viewWithTag(1000) as! UILabel
        let text = filesList[indexPath.row]
        let file = fileSeparation(for: text)
        let nameOfFile = file[.fileName]!
        let fileExtension = file[.fileExtension]!
        var attributedString = NSMutableAttributedString(string: nameOfFile)
        if fileExtension != "txt" && fileExtension !=  "rtf" {
            segueAllowed.removeLast()
            segueAllowed.append(true)
            let italicStyle = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 17)]
            attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttributes(italicStyle, range: NSMakeRange(0, text.count))
        }
        labelText.attributedText = attributedString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segueAllowed[indexPath.row] == false {
            self.performSegue(withIdentifier: "Segue", sender: nil)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
  
    func documentsDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue", let indexPath = tableView.indexPathForSelectedRow {
            let selectedRow = indexPath.row
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! PronounciationViewController
            attributedText = readTheFile(fileName: filesList[selectedRow])
            controller.textFromFile = attributedText as! NSMutableAttributedString
        }
    }
    
    func readTheFile(fileName: String) -> NSMutableAttributedString {
        var attributedStringWithRtf = NSMutableAttributedString(string: "")
        let file = fileSeparation(for: fileName)
        var inString = ""
        let nameOfFile = file[.fileName]!
        let fileExtension = file[.fileExtension]!
        let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileURL = dir?.appendingPathComponent(nameOfFile).appendingPathExtension(fileExtension) {
            do {
                if fileExtension == "rtf" {
                    attributedStringWithRtf = try NSMutableAttributedString(url: fileURL, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                } else if fileExtension == "txt" {
                    inString = try String(contentsOf: fileURL)
                    attributedStringWithRtf = NSMutableAttributedString(string: inString)
                }
            } catch {
                print("Failed reading from URL someFile: \(fileURL), Error: " + error.localizedDescription)
            }
        }
        return attributedStringWithRtf
    }
    
    func fileSeparation(for fileName: String) -> [fileAtrribute: String] {
        var nameOfFile = ""
        var fileExtension = ""
        var components = fileName.components(separatedBy: ".")
        if components.count > 1 {
            fileExtension = components.removeLast()
            nameOfFile = components.joined(separator: ".")
        } else {
            fileExtension = fileName
        }
        let key: [fileAtrribute: String] = [
            .fileName : nameOfFile,
            .fileExtension : fileExtension
        ]
        return key
    }
    
}
