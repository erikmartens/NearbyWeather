//
//  Factory+UIImageView.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIImageView

extension Factory {
  
  struct ImageView: FactoryFunction {
    
    enum ImageViewType {
      case symbol(image: UIImage? = nil)
      case appIcon
      case cellPrefix
    }
    
    typealias InputType = ImageViewType
    typealias ResultType = UIImageView
    
    static func make(fromType type: InputType) -> ResultType {
      let imageView = UIImageView()
      
      switch type {
      case let .symbol(image):
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.image = image
      case .appIcon:
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Constants.Dimensions.Size.AppIconImageSize.cornerRadius
        imageView.layer.masksToBounds = true
      case .cellPrefix:
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Constants.Dimensions.Size.TableCellImageSize.cornerRadius
        imageView.layer.masksToBounds = true
      }
      
      return imageView
    }
  }
}
