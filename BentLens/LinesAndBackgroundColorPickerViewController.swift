//
//  LinesAndBackgroundColorPickerViewController.swift
//  BentLens
//
//  Created by Rehan Shariff on 5/26/16.
//  Copyright © 2016 Stackhall Learning Services, LLC. All rights reserved.
//

import UIKit
import PagingMenuController

@objc protocol LinesAndBackgroundColorPickerViewControllerDelegate: class {
    func linesAndBackgroundColorPickerViewController(linesColor: UIColor, backgroundColor: UIColor)
}

public class LinesAndBackgroundColorPickerViewController: UIViewController {
    
    weak var delegate: LinesAndBackgroundColorPickerViewControllerDelegate?
    private var linesColorController: HRSampleColorPickerViewController?
    private var backgroundColorController: HRSampleColorPickerViewController?
    var initialLinesColor:UIColor?
    var initalBackgroundColor: UIColor?

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupPagingMenuController(createViewControllers(), menuOptions:createPagingMenuOptions())
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func donePressed(sender: AnyObject) {
        delegate?.linesAndBackgroundColorPickerViewController(self.linesColorController!.color, backgroundColor: self.backgroundColorController!.color)
    }
    
    private func setupPagingMenuController(viewControllers: [UIViewController], menuOptions: PagingMenuOptions) {        
        let pagingMenuController = PagingMenuController(viewControllers: viewControllers, options: menuOptions)
        self.addChildViewController(pagingMenuController)
        self.view.addSubview(pagingMenuController.view)
        pagingMenuController.didMoveToParentViewController(self)
    }
    
    private func createPagingMenuOptions() -> PagingMenuOptions {
        let options =  PagingMenuOptions()
        options.menuDisplayMode = .SegmentedControl
        options.menuItemMode = .RoundRect(radius: 0, horizontalPadding: 0, verticalPadding: 0, selectedColor: UIColor.darkGrayColor())
        options.backgroundColor = UIColor.clearColor()
        options.selectedBackgroundColor = options.backgroundColor
        options.textColor = UIColor.grayColor()
        options.selectedTextColor = UIColor.whiteColor()
        options.font = UIFont(name: "Avenir Book", size: 16)!
        options.selectedFont = options.font
        options.menuPosition = .Bottom
        options.scrollEnabled = false
        return options
    }
    
    private func createViewControllers() -> [UIViewController] {
        linesColorController = HRSampleColorPickerViewController(color: initialLinesColor, fullColor: true);
        linesColorController!.title = "Lines"
        backgroundColorController = HRSampleColorPickerViewController(color: initalBackgroundColor, fullColor: true);
        backgroundColorController!.title = "Background"
        return [linesColorController!, backgroundColorController!]
    }
}