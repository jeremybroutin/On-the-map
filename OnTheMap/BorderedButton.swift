//
//  ViewController.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/15/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import UIKit

class BorderedButton: UIButton {
  
  /* Constants for styling and configuration */
  let darkerOrange = UIColor(red: 0.988, green: 0.482, blue: 0.156, alpha:1.0)
  let lighterOrange = UIColor(red: 0.984, green:0.301, blue:0.039, alpha: 1.0)
  //let lighterOrange = UIColor(red: 0.988, green:0.341, blue:0.145, alpha: 1.0)
  let titleLabelFontSize : CGFloat = 17.0
  let borderedButtonHeight : CGFloat = 44.0
  let borderedButtonCornerRadius : CGFloat = 0.0
  let phoneBorderedButtonExtraPadding : CGFloat = 14.0
  
  var backingColor : UIColor? = nil
  var highlightedBackingColor : UIColor? = nil
  
  // MARK: - Initialization
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.themeBorderedButton()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.themeBorderedButton()
  }
  
  func themeBorderedButton() -> Void {
    let userInterfaceIdiom = UIDevice.currentDevice().userInterfaceIdiom
    self.layer.masksToBounds = true
    self.layer.cornerRadius = borderedButtonCornerRadius
    self.highlightedBackingColor = darkerOrange
    self.backingColor = lighterOrange
    self.backgroundColor = lighterOrange
    self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    self.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: titleLabelFontSize)
  }
  
  // MARK: - Setters
  
  private func setBackingColor(backingColor : UIColor) -> Void {
    if (self.backingColor != nil) {
      self.backingColor = backingColor;
      self.backgroundColor = backingColor;
    }
  }
  
  private func setHighlightedBackingColor(highlightedBackingColor: UIColor) -> Void {
    self.highlightedBackingColor = highlightedBackingColor
    self.backingColor = highlightedBackingColor
  }
  
  // MARK: - Tracking
  
  override func beginTrackingWithTouch(touch: UITouch, withEvent: UIEvent) -> Bool {
    self.backgroundColor = self.highlightedBackingColor
    return true
  }
  
  override func endTrackingWithTouch(touch: UITouch, withEvent: UIEvent) {
    self.backgroundColor = self.backingColor
  }
  
  override func cancelTrackingWithEvent(event: UIEvent?) {
    self.backgroundColor = self.backingColor
  }
  
  // MARK: - Layout
  
  override func sizeThatFits(size: CGSize) -> CGSize {
    let userInterfaceIdiom = UIDevice.currentDevice().userInterfaceIdiom
    let extraButtonPadding : CGFloat = phoneBorderedButtonExtraPadding
    var sizeThatFits = CGSizeZero
    sizeThatFits.width = super.sizeThatFits(size).width + extraButtonPadding
    sizeThatFits.height = borderedButtonHeight
    return sizeThatFits
    
  }
}
