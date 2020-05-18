import Foundation
import ArgumentParser
import hicore

struct HiCommand: ParsableCommand {
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
            Hi.run(withFile: file)
        } else {
            Hi.runPrompt()
        }
    }
}

HiCommand.main()
