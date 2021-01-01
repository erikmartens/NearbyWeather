//
//  InfoTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxFlow
import RxCocoa
import MessageUI

final class AboutAppTableViewController: UITableViewController, Stepper {
  
  private lazy var thirdPartyLibraries: [ThirdPartyLibraryDTO]? = {
    try? JsonPersistencyWorker().retrieveJsonFromFile(
      with: R.file.thirdPartyLibrariesJson.name,
      andDecodeAsType: ThirdPartyLibraryArrayWrapper.self,
      fromStorageLocation: .bundle
      )
      .elements
      .sorted { $0.name.lowercased() < $1.name.lowercased() }
  }()
  
  private lazy var owner: [DevelopmentContributorDTO]? = {
    try? JsonPersistencyWorker().retrieveJsonFromFile(
      with: R.file.projectOwnerJson.name,
      andDecodeAsType: DevelopmentContributorArrayWrapper.self,
      fromStorageLocation: .bundle
      )
      .elements
      .sorted { $0.lastName.lowercased() < $1.lastName.lowercased() }
  }()
  
  private lazy var contributors: [DevelopmentContributorDTO]? = {
    try? JsonPersistencyWorker().retrieveJsonFromFile(
      with: R.file.projectContributorsJson.name,
      andDecodeAsType: DevelopmentContributorArrayWrapper.self,
      fromStorageLocation: .bundle
      )
      .elements
      .sorted { $0.lastName.lowercased() < $1.lastName.lowercased() }
  }()
  
  // MARK: - Routing
  
  var steps = PublishRelay<Step>()
  
  // MARK: - ViewController Life Cycle
  
  override init(style: UITableView.Style) {
    super.init(style: style)
    
    tableView.delegate = self
    tableView.estimatedRowHeight = 44
    
    tableView.register(AppVersionCell.self, forCellReuseIdentifier: AppVersionCell.reuseIdentifier)
    
    tableView.register(UINib(nibName: R.nib.singleLabelCell.name, bundle: R.nib.singleLabelCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.singleLabelCell.identifier)
    
    tableView.register(UINib(nibName: R.nib.subtitleCell.name, bundle: R.nib.subtitleCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.subtitleCell.identifier)
    
    tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = R.string.localizable.about()
  }
  
  // MARK: - TableView Delegate
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if indexPath.section == 1 && indexPath.row == 0 {
      UIApplication.shared.open(Constants.Urls.kAppStoreRatingDeepLinkUrl, completionHandler: nil)
      return
    }
    
    var urlStringValue: String?
    if indexPath.section == 2 && indexPath.row == 0 {
      urlStringValue = Constants.Urls.kPrivacyPolicyUrl.absoluteString
    }
    if indexPath.section == 2 && indexPath.row == 1 {
      urlStringValue = Constants.Urls.kTermsOfUseUrl.absoluteString
    }
    if indexPath.section == 3 && indexPath.row == 0 {
      urlStringValue = Constants.Urls.kGitHubProjectContributionGuidelinesUrl.absoluteString
    }
    if indexPath.section == 3 && indexPath.row == 1 {
      urlStringValue = Constants.Urls.kGitHubProjectMainPageUrl.absoluteString
    }
    if indexPath.section == 4 {
      urlStringValue = owner?[indexPath.row].urlString
    }
    if indexPath.section == 5 {
      urlStringValue = contributors?[indexPath.row].urlString
    }
    if indexPath.section == 6 {
      urlStringValue = thirdPartyLibraries?[indexPath.row].urlString
    }
    guard let urlString = urlStringValue, let url = URL(string: urlString) else {
      return
    }
    steps.accept(SettingsStep.webBrowser(url: url))
  }
  
  // MARK: - TableView Data Source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    7
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return 2
    case 2:
      return 2
    case 3:
      return 2
    case 4:
      return owner?.count ?? 0
    case 5:
      return contributors?.count ?? 0
    case 6:
      return thirdPartyLibraries?.count ?? 0
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return nil
    case 1:
      return R.string.localizable.resources()
    case 2:
      return nil
    case 3:
      return R.string.localizable.contributing()
    case 4:
      return R.string.localizable.contributors()
    case 5:
      return nil
    case 6:
      return R.string.localizable.libraries()
    default:
      return nil
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let singleLabelCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.singleLabelCell.identifier, for: indexPath) as! SingleLabelCell
    let subtitleCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.subtitleCell.identifier, for: indexPath) as! SubtitleCell
    let buttonCell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseIdentifier, for: indexPath) as! ButtonCell
    
    [singleLabelCell, subtitleCell].forEach {
      $0.selectionStyle = .default
      $0.accessoryType = .disclosureIndicator
    }
    buttonCell.selectionStyle = .none
    buttonCell.accessoryType = .none
    
    switch indexPath.section {
    case 0:
      let appVersionCell = tableView.dequeueReusableCell(withIdentifier: AppVersionCell.reuseIdentifier, for: indexPath) as! AppVersionCell
      appVersionCell.configure(
        withImage: Bundle.main.appIcon,
        title: R.string.localizable.app_name().append(contentsOf: R.string.localizable.app_name_subtitle(), delimiter: .custom(string: " - ")),
        subtitle: Constants.Values.AppVersion.kVersionBuildString
      )
      return appVersionCell
    case 1:
      if indexPath.row == 0 {
        singleLabelCell.contentLabel.text = R.string.localizable.rate_version()
        return singleLabelCell
      }
      buttonCell.configure(
        withTitle: R.string.localizable.report_issue(),
        leftButtonTitle: R.string.localizable.viaGitHub(),
        rightButtonTitle: R.string.localizable.viaEmail(),
        leftButtonHandler: { [weak self] _ in
          DispatchQueue.main.async {
            self?.presentSafariViewController(for: Constants.Urls.kGitHubProjectIssuesUrl)
          }
        },
        rightButtonHandler: { [weak self] _ in
          self?.sendMail(
            to: [Constants.EmailAdresses.mainContact],
            withSubject: R.string.localizable.app_name()
              .append(contentsOf: R.string.localizable.report_issue(), delimiter: .custom(string: " - ")),
            withMessage: R.string.localizable.email_salutation()
          )
        }
      )
      return buttonCell
    case 2:
      if indexPath.row == 0 {
        singleLabelCell.contentLabel.text = R.string.localizable.privacy_policy()
        return singleLabelCell
      } else {
        singleLabelCell.contentLabel.text = R.string.localizable.terms_of_use()
        return singleLabelCell
      }
    case 3:
      if indexPath.row == 0 {
        singleLabelCell.contentLabel.text = R.string.localizable.how_to_contribute()
        return singleLabelCell
      } else {
        singleLabelCell.contentLabel.text = R.string.localizable.source_code_via_github()
        return singleLabelCell
      }
    case 4:
      let contributor = owner?[indexPath.row]
      subtitleCell.contentLabel.text = contributor?.firstName.append(contentsOf: contributor?.lastName, delimiter: .space)
      subtitleCell.subtitleLabel.text = contributor?.localizedContributionDescription
      return subtitleCell
    case 5:
      let contributor = contributors?[indexPath.row]
      subtitleCell.contentLabel.text = contributor?.firstName.append(contentsOf: contributor?.lastName, delimiter: .space)
      subtitleCell.subtitleLabel.text = contributor?.localizedContributionDescription
      return subtitleCell
    case 6:
      singleLabelCell.contentLabel.text = thirdPartyLibraries?[indexPath.row].name
      return singleLabelCell
    default:
      return UITableViewCell()
    }
  }
}

// MARK: - Private Helpers

private extension AboutAppTableViewController {
  
  func sendMail(to recipients: [String], withSubject subject: String, withMessage message: String) {
    guard MFMailComposeViewController.canSendMail() else {
      return // TODO: tell user needs to set up a mail account
    }
    
    let mailController = MFMailComposeViewController()
    mailController.mailComposeDelegate = self
    
    mailController.setToRecipients(recipients)
    mailController.setSubject(subject)
    mailController.setMessageBody(message, isHTML: false)
    
    navigationController?.present(mailController, animated: true, completion: nil)
  }
}

extension AboutAppTableViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }
}
