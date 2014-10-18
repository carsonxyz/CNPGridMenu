#CNPGridMenu

`CNPGridMenu` is a Mailbox style grid menu with a blurred background.

<p align="center"><img src="http://i.imgur.com/KhvwNU4.gif"/></p>

#Usage

You can create items for the grid menu using `CNPGridMenuItem`.

`@property (nonatomic, strong) NSString *title;`

`@property (nonatomic, strong) UIImage *icon;`

`@property (nonatomic, copy) SelectionHandler selectionHandler;`

#Customization

You can choose the blur style. `UIBlurEffectStyleDark` `UIBlurEffectStyleLight` `UIBlurEffectStyleExtraLight`

`@property (nonatomic, assign) UIBlurEffectStyle blurEffectStyle;`

#Installation

Requires iOS 8 (for now)

` Pod "CNPGridMenu" `

Or if you don't want to use Cocoapods ` #import "CNPGridMenu.h" `

#Notes

- iOS 7 suport comming very soon
