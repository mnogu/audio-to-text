//
// Copyright 2021 Muneyuki Noguchi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import ArgumentParser
import Foundation
import Speech

func convertFile(input: String, output: String, locale: String) {
    SFSpeechRecognizer.requestAuthorization { authStatus in
        OperationQueue.main.addOperation {
            switch authStatus {
            case .notDetermined:
                print("Speech recognition not yet authorized")
                exit(1)
            case .denied:
                print("User denied access to speech recognition")
                exit(1)
            case .restricted:
                print("Speech recognition restricted on this device")
                exit(1)
            case .authorized:
                break
            default:
                break
            }
        }
    }
    guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: locale)) else {
        print("A recognizer is not supported for the current locale")
        exit(1)
    }

    if !recognizer.isAvailable {
        print("The recognizer is not available right now")
        exit(1)
    }

    let request = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: input))
    recognizer.recognitionTask(with: request) { (result, error) in
        guard let result = result else {
            print("Recognition failed, so check error for details and handle it")
            if let error = error {
                print(error.localizedDescription)
            }
            exit(1)
        }
        print("Transcribing audio...")
        if result.isFinal {
            let transcription = result.bestTranscription.formattedString
            do {
                try transcription.write(to: URL(fileURLWithPath: output), atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("Error: \(error.domain)")
                exit(1)
            }
            exit(0)
        }
    }
}

@main
struct AudioToText: ParsableCommand {
    @Option(name: .shortAndLong, help: "The audio file.")
    var input: String
    
    @Option(name: .shortAndLong, help: "The text file.")
    var output: String
    
    @Option(name: .shortAndLong, help: "The locale.")
    var locale: String

    mutating func run() throws {
        convertFile(input: input, output: output, locale: locale)
        while RunLoop.current.run(mode: RunLoop.Mode.default, before: Date.distantFuture) {
        }
    }
}
