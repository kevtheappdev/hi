//
//  Hi.swift
//
//
//  Created by Kevin Turner on 5/18/20.
//

import Foundation

public class Hi {
    static var hadError = false
    static let interpreter = Interpreter()
    
    // MARK: Error handling
    public static func error(_ line: Int, _ message: String) {
        report(atLine: line, where: "", withMessage: message) // TODO: implement 'where' part
    }
    
    private static func report(atLine line: Int, where location: String, withMessage message: String) {
        print("[line \(line)] Error \(location): \(message)")
    }
    
    public static func run(withFile file: String) {
        let fm = FileManager()
        if !fm.isReadableFile(atPath: file) {
            print("File not readable: \(file)")
            exit(65)
        } else {
            guard let fileData = fm.contents(atPath: file) else { print("Failed to read from file: \(file)"); return }
            if let fileContents = String(data: fileData, encoding: .utf8) {
                run(withInput: fileContents)
            } else {
                fatalError("Unexpected contents of file: \(file)")
            }
            
            if hadError {
                exit(65)
            }
        }
    }
    
    public static func run(withInput input: String) {
        let scn = Scanner(withSource: input)
        let result = scn.scanTokens()
            .flatMap {(tokens) in
                return Parser(withTokens: tokens).parse()
            }.flatMap {(stmts) in
                return interpreter.interpret(statements: stmts)
            }
        
        do {
            try result.get()
        } catch { // TODO: fill this out
            print("Encountered error: \(error)")
        }
    }
    
    public static func runPrompt() {
        while true {
            print("> ", terminator: "")
            run(withInput: readLine() ?? "")
            hadError = false
        }
    }
}
