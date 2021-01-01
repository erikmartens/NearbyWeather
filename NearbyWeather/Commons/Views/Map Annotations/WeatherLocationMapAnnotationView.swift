//
//  WeatherLocationMapAnnotationView.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import MapKit

public let kMapAnnotationViewInitialFrame = CGRect(x: 0, y: 0, width: kWidth, height: kHeight)

private let kMargin: CGFloat = 4
private let kWidth: CGFloat = 110
private let kHeight: CGFloat = 50
private let kTriangleHeight: CGFloat = 10
private let kRadius: CGFloat = 10
private let kBorderWidth: CGFloat = 4

final class WeatherLocationMapAnnotationView: MKAnnotationView {

  // MARK: - Properties

  private var titleLabel = UILabel()
  private var subtitleLabel = UILabel()

  private var title: String? {
    didSet {
      titleLabel.text = title
    }
  }

  private var subtitle: String? {
    didSet {
      subtitleLabel.text = subtitle
    }
  }

  private var fillColor: UIColor? {
    didSet {
      layer.sublayers?.forEach { ($0 as? CAShapeLayer)?.fillColor = fillColor?.cgColor }
    }
  }

  private var textColor: UIColor? {
    didSet {
      titleLabel.textColor = textColor
      subtitleLabel.textColor = textColor
    }
  }

  private var gestureRecognizer = UITapGestureRecognizer()
  private var tapHandler: ((UITapGestureRecognizer) -> Void)?

  // MARK: - Overrides

  override var reuseIdentifier: String? {
    return Constants.Keys.MapAnnotation.kMapAnnotationViewIdentifier
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    tapHandler = nil
    removeGestureRecognizer(gestureRecognizer)
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    drawAnnotationView()
  }

  // MARK: - Public Functions

  // gets called before draw
  func configure(
    withTitle title: String,
    subtitle: String,
    fillColor: UIColor,
    textColor: UIColor,
    tapHandler: ((UITapGestureRecognizer) -> Void)?
  ) {
    self.title = title
    self.subtitle = subtitle
    self.fillColor = fillColor
    self.textColor = textColor

    if let tapHandler = tapHandler {
      self.tapHandler = tapHandler
      gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WeatherLocationMapAnnotationView.didTapAnnotationView(_:)))
      addGestureRecognizer(gestureRecognizer)
    }

    backgroundColor = .clear
  }

  // MARK: - Private Helpers

  @objc private func didTapAnnotationView(_ sender: UITapGestureRecognizer) {
    tapHandler?(sender)
  }

  private func drawAnnotationView() {
    let circleLayer = CAShapeLayer()
    circleLayer.path = UIBezierPath(arcCenter: CGPoint(x: kRadius, y: kRadius), radius: CGFloat(kRadius - kBorderWidth/2), startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true).cgPath
    circleLayer.frame.size = CGSize(width: kRadius*2, height: kRadius*2)
    circleLayer.bounds.origin = CGPoint(x: -frame.width/2 + kRadius, y: -frame.height/2 + kRadius)
    circleLayer.fillColor = fillColor?.cgColor ?? Constants.Theme.Color.MarqueColors.standardDay.cgColor
    circleLayer.strokeColor = textColor?.cgColor
    circleLayer.lineWidth = kBorderWidth/2
    layer.addSublayer(circleLayer)

    let speechBubbleLayer = CAShapeLayer()
    speechBubbleLayer.path = bubblePath(forContentSize: CGSize(width: kWidth, height: kHeight)).cgPath
    speechBubbleLayer.fillColor = fillColor?.cgColor ?? Constants.Theme.Color.MarqueColors.standardDay.cgColor
    speechBubbleLayer.strokeColor = textColor?.cgColor
    speechBubbleLayer.position = .zero
    layer.addSublayer(speechBubbleLayer)

    let labelWidth: CGFloat = kWidth - 2 * kMargin
    let labelHeight: CGFloat = (kHeight - 2 * kMargin - kTriangleHeight)/2

    titleLabel = label(withFontSize: 12)
    titleLabel.frame.size = CGSize(width: labelWidth, height: labelHeight)
    titleLabel.center = CGPoint(x: frame.size.width/2, y: titleLabel.frame.size.height/2 + kMargin)
    titleLabel.frame = titleLabel.frame.offsetBy(dx: 0, dy: -kHeight/2)
    titleLabel.text = title
    addSubview(titleLabel)

    subtitleLabel = label(withFontSize: 10)
    subtitleLabel.frame.size = CGSize(width: labelWidth, height: labelHeight)
    subtitleLabel.center = CGPoint(x: frame.size.width/2, y: titleLabel.frame.size.height/2 + kMargin + titleLabel.frame.size.height)
    subtitleLabel.frame = subtitleLabel.frame.offsetBy(dx: 0, dy: -kHeight/2)
    subtitleLabel.text = subtitle
    addSubview(subtitleLabel)

    clipsToBounds = false
  }

  private func bubblePath(forContentSize size: CGSize) -> UIBezierPath {
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height).offsetBy(dx: 0, dy: -kHeight/2)
    let radiusBorderAdjusted = kRadius - kBorderWidth/2

    let path = UIBezierPath()
    path.move(to: CGPoint(x: rect.width/2, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.width/2 - kTriangleHeight*0.75, y: rect.maxY - kTriangleHeight))
    path.addArc(withCenter: CGPoint(x: rect.minX + radiusBorderAdjusted + kMargin/4, y: rect.maxY - radiusBorderAdjusted - kTriangleHeight), radius: radiusBorderAdjusted, startAngle: CGFloat(CGFloat.pi/2), endAngle: CGFloat(CGFloat.pi), clockwise: true)
    path.addArc(withCenter: CGPoint(x: rect.minX + radiusBorderAdjusted + kMargin/4, y: rect.minY + radiusBorderAdjusted + kMargin/4), radius: radiusBorderAdjusted, startAngle: CGFloat(CGFloat.pi), endAngle: CGFloat(-CGFloat.pi/2), clockwise: true)
    path.addArc(withCenter: CGPoint(x: rect.maxX - radiusBorderAdjusted - kMargin/4, y: rect.minY + radiusBorderAdjusted + kMargin/4), radius: radiusBorderAdjusted, startAngle: CGFloat(-CGFloat.pi/2), endAngle: 0, clockwise: true)
    path.addArc(withCenter: CGPoint(x: rect.maxX - radiusBorderAdjusted - kMargin/4, y: rect.maxY - radiusBorderAdjusted - kTriangleHeight), radius: radiusBorderAdjusted, startAngle: 0, endAngle: CGFloat(CGFloat.pi/2), clockwise: true)
    path.addLine(to: CGPoint(x: rect.width/2 + kTriangleHeight*0.75, y: rect.maxY - kTriangleHeight))
    path.close()
    return path
  }

  private func label(withFontSize size: CGFloat) -> UILabel {
    let label = UILabel()
    label.numberOfLines = 1
    label.font = UIFont.systemFont(ofSize: size)
    label.textAlignment = .center
    label.textColor = textColor
    label.minimumScaleFactor = 0.8
    label.backgroundColor = .clear
    return label
  }
}
