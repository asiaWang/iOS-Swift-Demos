/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                A color palette view that allows the user to select a color defined in the List.Color enumeration.
            
*/

import Cocoa
import ListerKitOSX
import QuartzCore

// Delegate protocol to let other objects know about changes to the selected color.
@objc protocol ColorPaletteViewDelegate {
    func colorPaletteViewDidChangeSelectedColor(colorPaletteView: ColorPaletteView)
}

class ColorPaletteView: NSView {
    // MARK: Types

    struct ButtonTitles {
        static let expanded = "▶"
        static let collapsed = "◀"
    }

    // MARK: Properties

    @IBOutlet var delegate: ColorPaletteViewDelegate
    
    @IBOutlet var grayButton: NSButton
    @IBOutlet var blueButton: NSButton
    @IBOutlet var greenButton: NSButton
    @IBOutlet var yellowButton: NSButton
    @IBOutlet var orangeButton: NSButton
    @IBOutlet var redButton: NSButton
    
    @IBOutlet var overlayButton: NSButton

    @IBOutlet var overlayView: NSView
    @IBOutlet var overlayLayoutConstraint: NSLayoutConstraint

    var selectedColor: List.Color = .Gray {
        didSet {
            overlayView.layer.backgroundColor = selectedColor.colorValue.CGColor
        }
    }

    // Set in IB and saved to use for showing / hiding the overlay.
    var initialLayoutConstraintConstant: CGFloat = 0
    
    // The overlay is expanded initially in the storyboard.
    var isOverlayExpanded = true


    // MARK: View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Make the background of the color palette view white.
        layer = CALayer()
        layer.backgroundColor = NSColor.whiteColor().CGColor
        
        // Make the overlay view color (i.e. `selectedColor`) gray by default.
        overlayView.layer = CALayer()
        selectedColor = .Gray

        initialLayoutConstraintConstant = overlayLayoutConstraint.constant

        hideOverlayWithSelectedColor(selectedColor, animated: false)
        
        // Set the background color for each button.
        let buttons: NSButton[] = [grayButton, blueButton, greenButton, yellowButton, orangeButton, redButton]
        for button in buttons {
            button.layer = CALayer()

            let buttonColor = List.Color.fromRaw(button.tag)!
            button.layer.backgroundColor = buttonColor.colorValue.CGColor
        }
    }
    
    // MARK: IBActions
    
    @IBAction func colorButtonClicked(sender: NSButton) {
        // The tag for each color was set in the storyboard for each button based
        // on the type of color.
        let selectedColor = List.Color.fromRaw(sender.tag)!
        
        hideOverlayWithSelectedColor(selectedColor, animated: true)
    }
    
    @IBAction func colorToggleButtonClicked(sender: NSButton) {
        if isOverlayExpanded {
            hideOverlayWithSelectedColor(selectedColor, animated: true)
        }
        else {
            showOverlay()
        }
    }
    
    // MARK: Convenience
    
    func showOverlay() {
        setLayoutConstant(initialLayoutConstraintConstant, buttonTitle: ButtonTitles.expanded, newSelectedColor: selectedColor, animated: true, expanded: true)
    }
    
    func hideOverlayWithSelectedColor(selectedColor: List.Color, animated: Bool) {
        setLayoutConstant(0, buttonTitle: ButtonTitles.collapsed, newSelectedColor: selectedColor, animated: animated, expanded: false)
    }
    
    func setLayoutConstant(layoutConstant: CGFloat, buttonTitle: String, newSelectedColor: List.Color, animated: Bool, expanded: Bool) {
        // Check to see if the selected colors are different. We only want to trigger the colorPaletteViewDidChangeSelectedColor()
        // delegate call if the colors have changed.
        let colorsAreDifferent = selectedColor != newSelectedColor

        isOverlayExpanded = expanded
        
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                // Customize the animation parameters.
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                
                self.overlayLayoutConstraint.animator().constant = layoutConstant
                self.overlayButton.animator().title = buttonTitle
                self.selectedColor = newSelectedColor
            }, completionHandler: {
                if colorsAreDifferent {
                    self.delegate?.colorPaletteViewDidChangeSelectedColor(self)
                }
            })
        }
        else {
            overlayLayoutConstraint.constant = layoutConstant
            overlayButton.title = buttonTitle
            selectedColor = newSelectedColor
            
            if colorsAreDifferent {
                delegate?.colorPaletteViewDidChangeSelectedColor(self)
            }
        }
    }
}
