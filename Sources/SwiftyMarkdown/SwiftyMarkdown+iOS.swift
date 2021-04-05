//
//  SwiftyMarkdown+macOS.swift
//  SwiftyMarkdown
//
//  Created by Simon Fairbairn on 17/12/2019.
//  Copyright © 2019 Voyage Travel Apps. All rights reserved.
//

import Foundation

#if !os(macOS)
import UIKit

extension SwiftyMarkdown {
    
    func font( for line : SwiftyLine, characterOverride : CharacterStyle? = nil ) -> UIFont {
        var lineProperties: LineStyles? {
            didSet {
                if oldValue?.fontSize != nil && lineProperties?.fontSize == nil {
                    lineProperties?.fontSize = oldValue?.fontSize
                }
                if oldValue?.fontStyle != nil && lineProperties?.fontStyle == nil {
                    lineProperties?.fontStyle = oldValue?.fontStyle
                }
                if oldValue?.fontName != nil && lineProperties?.fontName == nil {
                    lineProperties?.fontName = oldValue?.fontName
                }
            }
        }
        
        var textStyle = UIFont.TextStyle.body
        var fontName : String? {
            didSet {
                if oldValue != nil && fontName == nil {
                    fontName = oldValue
                }
            }
        }
        var fontSize : CGFloat? {
            didSet {
                if oldValue != nil && fontSize == nil {
                    fontSize = oldValue
                }
            }
        }
        var style: LineStyles?
        var font : UIFont = UIFont.init()
        
        var globalBold = false
        var globalItalic = false
        
        // What type are we and is there a font name set?
        line.lineStyle.reversed().forEach { markdownLineStyle in
        switch markdownLineStyle as! MarkdownLineStyle {
        case .h1:
            style = self.h1
            if #available(iOS 9, *) {
                textStyle = UIFont.TextStyle.title1
            } else {
                textStyle = UIFont.TextStyle.headline
            }
        case .h2:
            style = self.h2
            if #available(iOS 9, *) {
                textStyle = UIFont.TextStyle.title2
            } else {
                textStyle = UIFont.TextStyle.headline
            }
        case .h3:
            style = self.h3
            if #available(iOS 9, *) {
                textStyle = UIFont.TextStyle.title2
            } else {
                textStyle = UIFont.TextStyle.subheadline
            }
        case .h4:
            style = self.h4
            textStyle = UIFont.TextStyle.headline
        case .h5:
            style = self.h5
            textStyle = UIFont.TextStyle.subheadline
        case .h6:
            style = self.h6
            textStyle = UIFont.TextStyle.footnote
        case .codeblock:
            textStyle = UIFont.TextStyle.body
        case .blockquote:
            style = self.blockquotes
            textStyle = UIFont.TextStyle.body
        default:
            style = self.body
            textStyle = UIFont.TextStyle.body
        }
        
        fontName = style?.fontName
        fontSize = style?.fontSize
        switch style?.fontStyle ?? LineStyles.shared.fontStyle! {
        case .bold:
            globalBold = true
        case .italic:
            globalItalic = true
        case .boldItalic:
            globalItalic = true
            globalBold = true
        case .normal:
            break
        }

        if fontName == nil {
            fontName = body.fontName
        }
        
        if let characterOverride = characterOverride {
            switch characterOverride {
            case .code:
                fontName = code.fontName ?? fontName
                fontSize = code.fontSize
            case .link:
                fontName = link.fontName ?? fontName
                fontSize = link.fontSize
            case .bold:
                fontName = bold.fontName ?? fontName
                fontSize = bold.fontSize
                globalBold = true
            case .italic:
                fontName = italic.fontName ?? fontName
                fontSize = italic.fontSize
                globalItalic = true
            case .strikethrough:
                fontName = strikethrough.fontName ?? fontName
                fontSize = strikethrough.fontSize
            default:
                break
            }
        }
    
        fontSize = fontSize == 0.0 ? nil : fontSize

        if let existentFontName = fontName {
            font = UIFont.preferredFont(forTextStyle: textStyle)
            let finalSize : CGFloat
            if let existentFontSize = fontSize {
                finalSize = existentFontSize
            } else {
                let styleDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
                finalSize = styleDescriptor.fontAttributes[.size] as? CGFloat ?? CGFloat(14)
            }
            
            // Fix a bug https://openradar.appspot.com/6153065
            let customFont: UIFont?
            if existentFontName.hasPrefix(".SFUI") {
                customFont = UIFont.systemFont(ofSize: finalSize, weight: weight(for: existentFontName))
            } else {
                customFont = UIFont(name: existentFontName, size: finalSize)
            }
            
            if  let customFont = customFont {
                let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
                font = fontMetrics.scaledFont(for: customFont)
            } else {
                font = UIFont.preferredFont(forTextStyle: textStyle)
            }
        } else {
            font = UIFont.preferredFont(forTextStyle: textStyle)
            if let fontSize = fontSize {
                font = font.withSize(fontSize)
            }
        }
        
        if globalItalic, let italicDescriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic) {
            font = UIFont(descriptor: italicDescriptor, size: 0)
        }
        if globalBold, let boldDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
            font = UIFont(descriptor: boldDescriptor, size: 0)
        }
    }
        
        return font
        
    }
    
    func weight( for fontName: String) -> UIFont.Weight {
        switch fontName.split(separator: "-").last {
        case "Bold": return .bold
        case "Semibold": return .semibold
        case "Black" : return .black
        case "Heavy" : return .heavy
        case "Light" : return .light
        case "Medium" : return .medium
        case "Thin" : return .thin
        case "Ultralight" : return .ultraLight
        default: return .regular
        }
    }
    
    func color( for line : SwiftyLine ) -> UIColor {
        var color: UIColor? {
            didSet {
                if oldValue != nil && color == nil {
                    color = oldValue
                }
            }
        }
        // What type are we and is there a font name set?
        line.lineStyle.reversed().forEach { markdownLineStyle in
            switch markdownLineStyle as! MarkdownLineStyle  {
            case .yaml:
                color = body.color
            case .h1, .previousH1:
                color = h1.color
            case .h2, .previousH2:
                color = h2.color
            case .h3:
                color = h3.color
            case .h4:
                color = h4.color
            case .h5:
                color = h5.color
            case .h6:
                color = h6.color
            case .body:
                color = body.color
            case .codeblock:
                color = code.color
            case .blockquote:
                color = blockquotes.color
            case .unorderedList, .unorderedListIndentFirstOrder, .unorderedListIndentSecondOrder, .orderedList, .orderedListIndentFirstOrder, .orderedListIndentSecondOrder:
                color = body.color
            case .referencedLink:
                color = link.color
            }
        }
        
        return color ?? LineStyles.shared.color!
    }
    
}
#endif
