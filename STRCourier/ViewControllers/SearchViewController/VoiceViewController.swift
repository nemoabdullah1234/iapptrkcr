//
//  VoiceViewController.swift
//  STRCourier
//
//  Created by Nitin Singh on 12/06/17.
//  Copyright © 2017 OSSCube. All rights reserved.
//

import UIKit
import AWSLex

class VoiceViewController: UIViewController, AWSLexVoiceButtonDelegate {

    @IBOutlet weak var voiceButton: AWSLexVoiceButton!
    @IBOutlet weak var input: UILabel!
    @IBOutlet weak var output: UILabel!
    
     @IBOutlet var lblNavigation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblNavigation.font =  UIFont(name: "Roboto-Light", size: 20)!
       
        (self.voiceButton as AWSLexVoiceButton).delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func voiceButton(_ button: AWSLexVoiceButton, on response: AWSLexVoiceButtonResponse) {
        DispatchQueue.main.async(execute: {
            // `inputranscript` is the transcript of the voice input to the operation
            print("Input Transcript: \(response.inputTranscript)")
            if let inputTranscript = response.inputTranscript {
                self.input.text = "\"\(inputTranscript)\""
            }
            print("on text output \(response.outputText)")
            self.output.text = response.outputText
        })
    }
    
    public func voiceButton(_ button: AWSLexVoiceButton, onError error: Error) {
        print("error \(error)")
    }

    

    
    @IBAction func btnBack(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

}
