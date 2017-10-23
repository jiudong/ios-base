//
//  ViewController.swift
//  swift-base
//
//  Created by TopTier labs on 15/2/16.
//  Copyright © 2016 TopTier labs. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyJSON

class FirstViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var facebookSign: UIButton!
  @IBOutlet weak var signIn: UIButton!
  @IBOutlet weak var signUp: UIButton!
  
  @IBOutlet weak var testView: UIView!
  @IBOutlet weak var textView: PlaceholderTextView!
  @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setText()
    setTestView()
    setTextView()
  }
  
  // MARK: - Setters
  func setText() {
    facebookSign.setTitle("Try Facebook Login".localized, for: .normal)
    signUp.setTitle("Try Sign up".localized, for: .normal)
    signIn.setTitle("Try Sign in".localized, for: .normal)
  }
  
  func setTestView() {
    testView.addBorder()
    testView.setRoundBorders()
    textView.addBorder(color: textView.placeholderColor!, weight: 1.0)
  }
  
  func setTextView() {
    let topBarHeight: CGFloat = navigationController!.navigationBar.bounds.height + UIApplication.shared.statusBarFrame.height
    textViewHeightConstraint.constant = view.frame.height - topBarHeight - textView.frame.minY - textViewBottomConstraint.constant
    if #available(iOS 11.0, *) {
      textViewHeightConstraint.constant -= UIApplication.shared.delegate!.window!!.safeAreaInsets.bottom
    }
  }

  //MARK: Actions
  @IBAction func facebookLogin() {
    Spinner.show()
    let fbLoginManager = FBSDKLoginManager()
    //Logs out before login, in case user changes facebook accounts
    fbLoginManager.logOut()
    fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
      guard error == nil else {
        self.showMessageError(title: "Oops..", errorMessage: "Something went wrong, try again later.")
        Spinner.hide()
        return
      }
      if result?.grantedPermissions == nil || result?.isCancelled ?? true {
        Spinner.hide()
      } else if !(result?.grantedPermissions.contains("email"))! {
        Spinner.hide()
        self.showMessageError(title: "Oops..", errorMessage: "It seems that you haven't allowed Facebook to provide your email address.")
      } else {
        self.facebookLoginCallback()
      }
    }
  }

  //MARK: Facebook callback methods
  func facebookLoginCallback() {
    //Optionally store params (facebook user data) locally.
    guard FBSDKAccessToken.current() != nil else {
      return
    }
    UserAPI.loginWithFacebook(token: FBSDKAccessToken.current().tokenString,
     success: { _ in
      Spinner.hide()
      self.performSegue(withIdentifier: "goToMainView", sender: nil)
    }, failure: { error in
      Spinner.hide()
      self.showMessageError(title: "Error", errorMessage: error._domain)
    })
  }
}
