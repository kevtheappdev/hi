import Foundation
import ArgumentParser

struct hi: ParsableCommand {
    @Argument(help: "hi file to run")
    var file: String?
    
    func validate() throws {
        if let file = self.file {
            let fileManager = FileManager()
            if (!fileManager.fileExists(atPath: file)) {
                throw ValidationError("File does not exist: \(file)")
            }
        }
    }
    
    func run() {
        if let file = self.file {
            // parse file
        } else {
            // enter REPL
        }
    }
}

hi.main()
