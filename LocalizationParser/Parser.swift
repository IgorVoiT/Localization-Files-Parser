//
//  Parser.swift
//  LocalizationParser
//
//  Created by Игорь on 15.1221..
//

import Foundation
import Sweep

class Parser {
    
    static let shared = Parser()
    
    let fileManager: FileManager = .default
    
    var urlsToParse: [URL] = []
    var foundStrings: Set<String> = []
    var all: [String] = []
    
    func getSwiftFileLocations(for path: String) {
        urlsToParse = []
        foundStrings = []
        urlsToParse = [URL(fileURLWithPath: path)] // fileManager.listFilesAndFilter(path: path, ext: "swift")
        
       // NotificationCenter.default.post(name: NSNotification.Name("startedParsing"), object: nil)
        
        for (i, url) in urlsToParse.enumerated() {
            readAndParseFile(from: url, fileNumber: i)
        }

        
    }
    
    func readAndParseFile(from path: URL, fileNumber: Int) {
        readAsync(from: path) { res in
            switch res {
            case .success(let value):
                self.parse(text: value, fileNumber: fileNumber)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func parse(text: String, fileNumber: Int) {
        var res: [String] = []
        
        
        res = text.components(separatedBy: ";")
        
//        let matches = text.match("[( [:blank:]]\".*\".\\blocalized\\b\\(\\bvalue\\b: \".*\"\\)")
//
//        matches.forEach({ match in
//            for str in match {
//                var new: String = str
//                if new.first == "(" || new.first == " " {
//                    new.removeFirst()
//                }
//                new = new.dropLast().replacingOccurrences(of: ".localized(value: ", with: " = ")  + ";" + "\n" + "\n"
//                print(new)
//                res.append(new)
//            }
//        })
        
        for str in res {
           // all.append(str)
            let new = str + ";"
            print(new)
            foundStrings.insert(new)
        }
        
        if fileNumber == (urlsToParse.count - 1) {
            print(foundStrings.count)
            writeResult()
        }
    }
    
    
    func writeResult() {
        
        for str in foundStrings {
            writeAsync(text: str)
        }
        
        //NotificationCenter.default.post(name: NSNotification.Name("finishedParsing"), object: nil)
    }
    
    // MARK: Private functions
    
    func readAsync(from path: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)
        
        queue.sync {
            do {
                let result = try self.doRead(from: path)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        
        
     }
    
    
    func writeAsync(text: String) {
        let queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)
        
        queue.sync {
            do {
                try self.doWrite()
            } catch {
                print(error)
            }
        }
    }
    
    
    private func doRead(from path: URL) throws -> String {
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: path.path, isDirectory: &isDir) && !isDir.boolValue else {
            throw ReadWriteError.doesNotExist
        }
        
        let string: String
        do {
            string = try String(contentsOf: path)
        } catch {
            throw ReadWriteError.readFailed(error)
        }
        
        return string
    }
    
    
    
    private func doWrite() throws {
        
       // let string = foundStrings.joined(separator: "\n")
        
        if let urlToFile = URL(string: "file:///Users/Igor/Desktop/localize2.txt") {
            
            guard fileManager.fileExists(atPath: urlToFile.path) else {
                throw ReadWriteError.canNotCreateFile
            }
            
       //     print(string)

            
            do {
                if let fileHandle = FileHandle(forWritingAtPath: urlToFile.path) {
                    for str in foundStrings {
                        if let data = str.data(using: .utf8) {
                            fileHandle.write(data)
                        }
                    }
                }
            //    try data.write(to: urlToFile)
                
                
            } catch {
                throw ReadWriteError.writeFailed(error)
            }
        } else {
            throw ReadWriteError.canNotCreateFile
        }
    }
    

}

extension FileManager {
    func listFilesAndFilter(path: String, ext: String) -> [URL] {
        let baseurl: URL = URL(fileURLWithPath: path)
        var urls = [URL]()
        enumerator(atPath: path)?.forEach({ (e) in
            guard let s = e as? String else { return }
            let relativeURL = URL(fileURLWithPath: s, relativeTo: baseurl)
            let url = relativeURL.absoluteURL
            if url.pathExtension == ext {
                urls.append(url)
            }
        })
        return urls
    }
}


enum ReadWriteError: LocalizedError {
    
    // MARK: Cases
    
    case doesNotExist
    case readFailed(Error)
    case canNotCreateFolder
    case canNotCreateFile
    case encodingFailed
    case writeFailed(Error)
}



extension String {
    func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}
