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
            run(withFile: file)
        } else {
            // enter REPL
        }
    }
    
    func run(withFile file: String) {
        let fm = FileManager()
        if !fm.isReadableFile(atPath: file) {
            print("File not readable: \(file)") // TODO: replce with exception handling
        } else {
            guard let fileData = fm.contents(atPath: file) else { print("Failed to read from file: \(file)"); return }
            if let fileContents = String(data: fileData, encoding: .utf8) {
                run(withInput: fileContents)
            } else {
                print("Unexpected contents of file: \(file)")
            }
        }
    }
    
    func run(withInput input: String) {
        let scn = Scanner(withSource: input)
        _ = scn.scanTokens().map {(tokens) in
            for token in tokens {
                print(token)
            }
        }
    }
}

hi.main()
