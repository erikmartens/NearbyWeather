//
//  AlertCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class AlertCell: UITableViewCell {
  
  private var timer: Timer?
  
  @IBOutlet weak var backgroundColorView: UIView!
  @IBOutlet weak var warningImageView: UIView!
  @IBOutlet weak var noticeLabel: UILabel!
  
  deinit {
    warningImageView.layer.removeAllAnimations()
    timer?.invalidate()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    warningImageView.layer.removeAllAnimations()
    timer?.invalidate()
  }
  
  func configure(with errorMessage: String) {
    backgroundColorView.layer.cornerRadius = 5.0
    backgroundColorView.layer.backgroundColor = UIColor.black.cgColor
    
    noticeLabel.text = errorMessage
    
    startAnimationTimer()
  }
  
  func configureWithErrorDataDTO(_ errorDataDTO: WeatherInformationErrorDTO?) {
    guard let errorDataDTO = errorDataDTO else {
      configure(with: R.string.localizable.unknown_error())
      return
    }
    switch errorDataDTO.errorType.value {
    case .httpError:
      let errorCode = errorDataDTO.httpStatusCode ?? -1
      configure(with: R.string.localizable.http_error(String(describing: errorCode)))
    case .requestTimOutError:
      configure(with: R.string.localizable.request_timeout_error())
    case .malformedUrlError:
      configure(with: R.string.localizable.malformed_url_error())
    case .unparsableResponseError:
      configure(with: R.string.localizable.unreadable_result_error())
    case .jsonSerializationError:
      configure(with: R.string.localizable.unreadable_result_error())
    case .unrecognizedApiKeyError:
      configure(with: R.string.localizable.unauthorized_api_key_error())
    case .locationUnavailableError:
      configure(with: R.string.localizable.location_unavailable_error())
    case .locationAccessDenied:
      configure(with: R.string.localizable.location_denied_error())
    }
  }
  
  private func startAnimationTimer() {
    timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(AlertCell.animateWarningShake), userInfo: nil, repeats: false)
  }
  
  @objc private func animateWarningShake() {
    warningImageView.layer.removeAllAnimations()
    warningImageView.animatePulse(withAnimationDelegate: self)
  }
}

extension AlertCell: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    startAnimationTimer()
  }
}
