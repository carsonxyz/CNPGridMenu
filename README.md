# CNPGridMenu


**THIS PROJECT IS DEPRECATED** I no longer have the time to maintain this project, sorry. I am no longer making any changes to this codebase. Please feel free to fork it, change whatever you want, and publish it anywhere you like. I'll leave this repo open until September 1, 2019 so that you can get what you need.


`CNPGridMenu` is a Mailbox style grid menu with a blurred background for iOS 7 & iOS 8.

<p align="center"><img src="http://i.imgur.com/KhvwNU4.gif"/></p>

# Usage

You can create items for the grid menu using `CNPGridMenuItem`.

`@property (nonatomic, strong) NSString *title;`

`@property (nonatomic, strong) UIImage *icon;`

`@property (nonatomic, assign) NSInteger menuItemTag;`

`@property (nonatomic, assign) BOOL disabled;`

`@property (nonatomic, copy) SelectionHandler selectionHandler;`

# Customization

You can choose the blur style. `UIBlurEffectStyleDark` `UIBlurEffectStyleLight` `UIBlurEffectStyleExtraLight`

`@property (nonatomic, assign) UIBlurEffectStyle blurEffectStyle;`

# Installation

Requires iOS 7 or iOS 8

` pod "CNPGridMenu" `

Or if you don't want to use CocoaPods ` #import "CNPGridMenu.h" `
