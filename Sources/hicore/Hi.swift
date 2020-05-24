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
        hadError = true
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
                print("Unexpected contents of file: \(file)")
                hadError = true
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
                let resolver = Resolver(interpreter: interpreter)
                return resolver.resolve(All: stmts)
            }.flatMap {(stmts) in
                return interpreter.interpret(statements: stmts)
            }
        
        do {
            try result.get()
        } catch let runtimeError as RuntimeError { // TODO: fill this out
            print("Runtime Error: \(runtimeError.message)")
            hadError = true
        } catch ScannerErrors.unexpectedToken(let line, let message) {
            error(line, message)
            hadError = true
        } catch ScannerErrors.unterminatedString(let line, let message) {
            error(line, message)
            hadError = true
        } catch {
            print("Encountered unexpected error: \(error.localizedDescription)")
            hadError = true
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
