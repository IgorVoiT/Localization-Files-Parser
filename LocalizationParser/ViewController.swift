//
//  ViewController.swift
//  LocalizationParser
//
//  Created by Игорь on 15.1221..
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var pathLabel: NSTextField!
    @IBOutlet weak var urlsTableView: NSTableView!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlsTableView.delegate = self
        urlsTableView.dataSource = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(startedParsing), name: NSNotification.Name("startedParsing"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishedParsing), name: NSNotification.Name("finishedParsing"), object: nil)
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func openFileDialog(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title                   = "Choose a directory"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = true

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file

            if (result != nil) {
                let path: String = result!.path
                pathLabel.stringValue = path
                Parser.shared.getSwiftFileLocations(for: path)
                urlsTableView.reloadData()
            }
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    
    @objc func startedParsing() {
        progressSpinner.startAnimation(self)
        progressLabel.isHidden = false
    }
    
    @objc func finishedParsing() {
        progressSpinner.stopAnimation(self)
        progressLabel.isHidden = true
    }
}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Parser.shared.urlsToParse.count
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultCell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = "\(Parser.shared.urlsToParse[row].relativeString)"
            return cell
        }
        
        return nil
        
    }
    
}
