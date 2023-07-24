//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import RswiftResources
import UIKit

private class BundleFinder {}
let R = _R(bundle: Bundle(for: BundleFinder.self))

struct _R {
  let bundle: Foundation.Bundle

  let entitlements = entitlements()

  var string: string { .init(bundle: bundle, preferredLanguages: nil, locale: nil) }
  var color: color { .init(bundle: bundle) }
  var image: image { .init(bundle: bundle) }
  var file: file { .init(bundle: bundle) }
  var nib: nib { .init(bundle: bundle) }
  var storyboard: storyboard { .init(bundle: bundle) }

  func string(bundle: Foundation.Bundle) -> string {
    .init(bundle: bundle, preferredLanguages: nil, locale: nil)
  }
  func string(locale: Foundation.Locale) -> string {
    .init(bundle: bundle, preferredLanguages: nil, locale: locale)
  }
  func string(preferredLanguages: [String], locale: Locale? = nil) -> string {
    .init(bundle: bundle, preferredLanguages: preferredLanguages, locale: locale)
  }
  func color(bundle: Foundation.Bundle) -> color {
    .init(bundle: bundle)
  }
  func image(bundle: Foundation.Bundle) -> image {
    .init(bundle: bundle)
  }
  func file(bundle: Foundation.Bundle) -> file {
    .init(bundle: bundle)
  }
  func nib(bundle: Foundation.Bundle) -> nib {
    .init(bundle: bundle)
  }
  func storyboard(bundle: Foundation.Bundle) -> storyboard {
    .init(bundle: bundle)
  }
  func validate() throws {
    try self.nib.validate()
    try self.storyboard.validate()
  }

  struct project {
    let developmentRegion = "en"
  }

  /// This `_R.string` struct is generated, and contains static references to 3 localization tables.
  struct string {
    let bundle: Foundation.Bundle
    let preferredLanguages: [String]?
    let locale: Locale?
    var infoPlist: infoPlist { .init(source: .init(bundle: bundle, tableName: "InfoPlist", preferredLanguages: preferredLanguages, locale: locale)) }
    var launchScreen: launchScreen { .init(source: .init(bundle: bundle, tableName: "LaunchScreen", preferredLanguages: preferredLanguages, locale: locale)) }
    var localizable: localizable { .init(source: .init(bundle: bundle, tableName: "Localizable", preferredLanguages: preferredLanguages, locale: locale)) }

    func infoPlist(preferredLanguages: [String]) -> infoPlist {
      .init(source: .init(bundle: bundle, tableName: "InfoPlist", preferredLanguages: preferredLanguages, locale: locale))
    }
    func launchScreen(preferredLanguages: [String]) -> launchScreen {
      .init(source: .init(bundle: bundle, tableName: "LaunchScreen", preferredLanguages: preferredLanguages, locale: locale))
    }
    func localizable(preferredLanguages: [String]) -> localizable {
      .init(source: .init(bundle: bundle, tableName: "Localizable", preferredLanguages: preferredLanguages, locale: locale))
    }


    /// This `_R.string.infoPlist` struct is generated, and contains static references to 1 localization keys.
    struct infoPlist {
      let source: RswiftResources.StringResource.Source

      /// en translation: Wecyn
      ///
      /// Key: CFBundleDisplayName
      ///
      /// Locales: en, zh-Hans
      var cfBundleDisplayName: RswiftResources.StringResource { .init(key: "CFBundleDisplayName", tableName: "InfoPlist", source: source, developmentValue: "Wecyn", comment: nil) }
    }

    /// This `_R.string.launchScreen` struct is generated, and contains static references to 0 localization keys.
    struct launchScreen {
      let source: RswiftResources.StringResource.Source
    }

    /// This `_R.string.localizable` struct is generated, and contains static references to 11 localization keys.
    struct localizable {
      let source: RswiftResources.StringResource.Source

      /// en translation: Activity
      ///
      /// Key: Activity
      ///
      /// Locales: en
      var activity: RswiftResources.StringResource { .init(key: "Activity", tableName: "Localizable", source: source, developmentValue: "Activity", comment: nil) }

      /// en translation: Education
      ///
      /// Key: Education
      ///
      /// Locales: en
      var education: RswiftResources.StringResource { .init(key: "Education", tableName: "Localizable", source: source, developmentValue: "Education", comment: nil) }

      /// en translation: Experience
      ///
      /// Key: Experience
      ///
      /// Locales: en
      var experience: RswiftResources.StringResource { .init(key: "Experience", tableName: "Localizable", source: source, developmentValue: "Experience", comment: nil) }

      /// en translation: Interests
      ///
      /// Key: Interests
      ///
      /// Locales: en
      var interests: RswiftResources.StringResource { .init(key: "Interests", tableName: "Localizable", source: source, developmentValue: "Interests", comment: nil) }

      /// en translation: Skills
      ///
      /// Key: Skills
      ///
      /// Locales: en
      var skills: RswiftResources.StringResource { .init(key: "Skills", tableName: "Localizable", source: source, developmentValue: "Skills", comment: nil) }

      /// en translation: Add new section
      ///
      /// Key: add_new_section
      ///
      /// Locales: en, zh-Hans
      var add_new_section: RswiftResources.StringResource { .init(key: "add_new_section", tableName: "Localizable", source: source, developmentValue: "Add new section", comment: nil) }

      /// en translation: Pull down to refresh
      ///
      /// Key: pull_down_to_refresh
      ///
      /// Locales: en, zh-Hans
      var pull_down_to_refresh: RswiftResources.StringResource { .init(key: "pull_down_to_refresh", tableName: "Localizable", source: source, developmentValue: "Pull down to refresh", comment: nil) }

      /// en translation: Pull up to load more
      ///
      /// Key: pull_up_to_refresh
      ///
      /// Locales: en, zh-Hans
      var pull_up_to_refresh: RswiftResources.StringResource { .init(key: "pull_up_to_refresh", tableName: "Localizable", source: source, developmentValue: "Pull up to load more", comment: nil) }

      /// en translation: Release to refresh
      ///
      /// Key: release_refresh
      ///
      /// Locales: en, zh-Hans
      var release_refresh: RswiftResources.StringResource { .init(key: "release_refresh", tableName: "Localizable", source: source, developmentValue: "Release to refresh", comment: nil) }

      /// en translation: View Calendar
      ///
      /// Key: view_calendar
      ///
      /// Locales: en, zh-Hans
      var view_calendar: RswiftResources.StringResource { .init(key: "view_calendar", tableName: "Localizable", source: source, developmentValue: "View Calendar", comment: nil) }

      /// en translation: View NameCard
      ///
      /// Key: view_namecard
      ///
      /// Locales: en, zh-Hans
      var view_namecard: RswiftResources.StringResource { .init(key: "view_namecard", tableName: "Localizable", source: source, developmentValue: "View NameCard", comment: nil) }
    }
  }

  /// This `_R.color` struct is generated, and contains static references to 11 colors.
  struct color {
    let bundle: Foundation.Bundle

    /// Color `AccentColor`.
    var accentColor: RswiftResources.ColorResource { .init(name: "AccentColor", path: [], bundle: bundle) }

    /// Color `BackgroundColor`.
    var backgroundColor: RswiftResources.ColorResource { .init(name: "BackgroundColor", path: [], bundle: bundle) }

    /// Color `SeperatorColor`.
    var seperatorColor: RswiftResources.ColorResource { .init(name: "SeperatorColor", path: [], bundle: bundle) }

    /// Color `TextColor162C46`.
    var textColor162C46: RswiftResources.ColorResource { .init(name: "TextColor162C46", path: [], bundle: bundle) }

    /// Color `TextColor52`.
    var textColor52: RswiftResources.ColorResource { .init(name: "TextColor52", path: [], bundle: bundle) }

    /// Color `TextColor74`.
    var textColor74: RswiftResources.ColorResource { .init(name: "TextColor74", path: [], bundle: bundle) }

    /// Color `TheamColor`.
    var theamColor: RswiftResources.ColorResource { .init(name: "TheamColor", path: [], bundle: bundle) }

    /// Color `agreeColor`.
    var agreeColor: RswiftResources.ColorResource { .init(name: "agreeColor", path: [], bundle: bundle) }

    /// Color `disableColor`.
    var disableColor: RswiftResources.ColorResource { .init(name: "disableColor", path: [], bundle: bundle) }

    /// Color `rejectColor`.
    var rejectColor: RswiftResources.ColorResource { .init(name: "rejectColor", path: [], bundle: bundle) }

    /// Color `unknownColor`.
    var unknownColor: RswiftResources.ColorResource { .init(name: "unknownColor", path: [], bundle: bundle) }
  }

  /// This `_R.image` struct is generated, and contains static references to 71 images.
  struct image {
    let bundle: Foundation.Bundle

    /// Image `alarm`.
    var alarm: RswiftResources.ImageResource { .init(name: "alarm", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `appicon`.
    var appicon: RswiftResources.ImageResource { .init(name: "appicon", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `attendace_delete`.
    var attendace_delete: RswiftResources.ImageResource { .init(name: "attendace_delete", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `calendar`.
    var calendar: RswiftResources.ImageResource { .init(name: "calendar", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `calendar.badge.plus`.
    var calendarBadgePlus: RswiftResources.ImageResource { .init(name: "calendar.badge.plus", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `calendar.day.timeline.left`.
    var calendarDayTimelineLeft: RswiftResources.ImageResource { .init(name: "calendar.day.timeline.left", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `calendar_add`.
    var calendar_add: RswiftResources.ImageResource { .init(name: "calendar_add", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `calendar_calendar`.
    var calendar_calendar: RswiftResources.ImageResource { .init(name: "calendar_calendar", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `calendar_item_arrow_down`.
    var calendar_item_arrow_down: RswiftResources.ImageResource { .init(name: "calendar_item_arrow_down", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `calendar_item_arrow_right`.
    var calendar_item_arrow_right: RswiftResources.ImageResource { .init(name: "calendar_item_arrow_right", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `checkmark`.
    var checkmark: RswiftResources.ImageResource { .init(name: "checkmark", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `chevron.up`.
    var chevronUp: RswiftResources.ImageResource { .init(name: "chevron.up", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `circle.fill`.
    var circleFill: RswiftResources.ImageResource { .init(name: "circle.fill", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `clock`.
    var clock: RswiftResources.ImageResource { .init(name: "clock", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `clock.arrow.circlepath`.
    var clockArrowCirclepath: RswiftResources.ImageResource { .init(name: "clock.arrow.circlepath", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `comment`.
    var comment: RswiftResources.ImageResource { .init(name: "comment", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `connection_delete`.
    var connection_delete: RswiftResources.ImageResource { .init(name: "connection_delete", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `connection_message`.
    var connection_message: RswiftResources.ImageResource { .init(name: "connection_message", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `connection_search`.
    var connection_search: RswiftResources.ImageResource { .init(name: "connection_search", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `gear.circle`.
    var gearCircle: RswiftResources.ImageResource { .init(name: "gear.circle", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `google`.
    var google: RswiftResources.ImageResource { .init(name: "google", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `job_location`.
    var job_location: RswiftResources.ImageResource { .init(name: "job_location", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `job_mark`.
    var job_mark: RswiftResources.ImageResource { .init(name: "job_mark", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `job_marked`.
    var job_marked: RswiftResources.ImageResource { .init(name: "job_marked", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `like`.
    var like: RswiftResources.ImageResource { .init(name: "like", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `line.3.horizontal`.
    var line3Horizontal: RswiftResources.ImageResource { .init(name: "line.3.horizontal", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `link`.
    var link: RswiftResources.ImageResource { .init(name: "link", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `location`.
    var location: RswiftResources.ImageResource { .init(name: "location", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `magnifyingglass`.
    var magnifyingglass: RswiftResources.ImageResource { .init(name: "magnifyingglass", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `namecard_background`.
    var namecard_background: RswiftResources.ImageResource { .init(name: "namecard_background", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `navbar_bell`.
    var navbar_bell: RswiftResources.ImageResource { .init(name: "navbar_bell", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `navbar_message`.
    var navbar_message: RswiftResources.ImageResource { .init(name: "navbar_message", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `navbar_more`.
    var navbar_more: RswiftResources.ImageResource { .init(name: "navbar_more", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `navigation_back_default`.
    var navigation_back_default: RswiftResources.ImageResource { .init(name: "navigation_back_default", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `password_invisible`.
    var password_invisible: RswiftResources.ImageResource { .init(name: "password_invisible", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `password_visible`.
    var password_visible: RswiftResources.ImageResource { .init(name: "password_visible", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `pencil.line`.
    var pencilLine: RswiftResources.ImageResource { .init(name: "pencil.line", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `person.2`.
    var person2: RswiftResources.ImageResource { .init(name: "person.2", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `person.badge.plus`.
    var personBadgePlus: RswiftResources.ImageResource { .init(name: "person.badge.plus", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `person.circle`.
    var personCircle: RswiftResources.ImageResource { .init(name: "person.circle", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `person.fill`.
    var personFill: RswiftResources.ImageResource { .init(name: "person.fill", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `person.fill.checkmark`.
    var personFillCheckmark: RswiftResources.ImageResource { .init(name: "person.fill.checkmark", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `person.fill.questionmark`.
    var personFillQuestionmark: RswiftResources.ImageResource { .init(name: "person.fill.questionmark", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `person.fill.xmark`.
    var personFillXmark: RswiftResources.ImageResource { .init(name: "person.fill.xmark", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `placeholder`.
    var placeholder: RswiftResources.ImageResource { .init(name: "placeholder", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `plus.circle`.
    var plusCircle: RswiftResources.ImageResource { .init(name: "plus.circle", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `profile_edit_userinfo`.
    var profile_edit_userinfo: RswiftResources.ImageResource { .init(name: "profile_edit_userinfo", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `proile_user`.
    var proile_user: RswiftResources.ImageResource { .init(name: "proile_user", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `repeat`.
    var `repeat`: RswiftResources.ImageResource { .init(name: "repeat", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `retweet`.
    var retweet: RswiftResources.ImageResource { .init(name: "retweet", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `search_icon`.
    var search_icon: RswiftResources.ImageResource { .init(name: "search_icon", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `send`.
    var send: RswiftResources.ImageResource { .init(name: "send", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `square.and.arrow.up`.
    var squareAndArrowUp: RswiftResources.ImageResource { .init(name: "square.and.arrow.up", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `square.fill.7`.
    var squareFill7: RswiftResources.ImageResource { .init(name: "square.fill.7", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `switch.2`.
    var switch2: RswiftResources.ImageResource { .init(name: "switch.2", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tab_calendar`.
    var tab_calendar: RswiftResources.ImageResource { .init(name: "tab_calendar", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tab_calendar_selected`.
    var tab_calendar_selected: RswiftResources.ImageResource { .init(name: "tab_calendar_selected", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tab_connection`.
    var tab_connection: RswiftResources.ImageResource { .init(name: "tab_connection", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tab_home`.
    var tab_home: RswiftResources.ImageResource { .init(name: "tab_home", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tab_job`.
    var tab_job: RswiftResources.ImageResource { .init(name: "tab_job", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tab_profile`.
    var tab_profile: RswiftResources.ImageResource { .init(name: "tab_profile", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tab_setting`.
    var tab_setting: RswiftResources.ImageResource { .init(name: "tab_setting", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tag.fill`.
    var tagFill: RswiftResources.ImageResource { .init(name: "tag.fill", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tag.fill.1`.
    var tagFill1: RswiftResources.ImageResource { .init(name: "tag.fill.1", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tag.fill.2`.
    var tagFill2: RswiftResources.ImageResource { .init(name: "tag.fill.2", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tag.fill.3`.
    var tagFill3: RswiftResources.ImageResource { .init(name: "tag.fill.3", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tag.fill.4`.
    var tagFill4: RswiftResources.ImageResource { .init(name: "tag.fill.4", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `tag.fill.5`.
    var tagFill5: RswiftResources.ImageResource { .init(name: "tag.fill.5", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `text.quote`.
    var textQuote: RswiftResources.ImageResource { .init(name: "text.quote", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `triangle.fill`.
    var triangleFill: RswiftResources.ImageResource { .init(name: "triangle.fill", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `xmark`.
    var xmark: RswiftResources.ImageResource { .init(name: "xmark", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }
  }

  /// This `_R.entitlements` struct is generated, and contains static references to 1 properties.
  struct entitlements {
    let comAppleDeveloperNfcReadersessionFormats = comAppleDeveloperNfcReadersessionFormats()
    struct comAppleDeveloperNfcReadersessionFormats {
      let taG: String = "TAG"
    }
  }

  /// This `_R.file` struct is generated, and contains static references to 3 resource files.
  struct file {
    let bundle: Foundation.Bundle

    /// Resource file `bundle.js`.
    var bundleJs: RswiftResources.FileResource { .init(name: "bundle", pathExtension: "js", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `nlp.js`.
    var nlpJs: RswiftResources.FileResource { .init(name: "nlp", pathExtension: "js", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `rrule.js`.
    var rruleJs: RswiftResources.FileResource { .init(name: "rrule", pathExtension: "js", bundle: bundle, locale: LocaleReference.none) }
  }

  /// This `_R.nib` struct is generated, and contains static references to 17 nibs.
  struct nib {
    let bundle: Foundation.Bundle

    /// Nib `CaledarItemCell`.
    var caledarItemCell: RswiftResources.NibReference<CaledarItemCell> { .init(name: "CaledarItemCell", bundle: bundle) }

    /// Nib `ConnectAuditItemCell`.
    var connectAuditItemCell: RswiftResources.NibReference<ConnectAuditItemCell> { .init(name: "ConnectAuditItemCell", bundle: bundle) }

    /// Nib `ConnectionItemCell`.
    var connectionItemCell: RswiftResources.NibReference<ConnectionItemCell> { .init(name: "ConnectionItemCell", bundle: bundle) }

    /// Nib `CreateGroupHeaderView`.
    var createGroupHeaderView: RswiftResources.NibReference<CreateGroupHeaderView> { .init(name: "CreateGroupHeaderView", bundle: bundle) }

    /// Nib `HomeHeaderJobItemCell`.
    var homeHeaderJobItemCell: RswiftResources.NibReference<HomeHeaderJobItemCell> { .init(name: "HomeHeaderJobItemCell", bundle: bundle) }

    /// Nib `HomeHeaderView`.
    var homeHeaderView: RswiftResources.NibReference<HomeHeaderView> { .init(name: "HomeHeaderView", bundle: bundle) }

    /// Nib `HomeItemCell`.
    var homeItemCell: RswiftResources.NibReference<HomeItemCell> { .init(name: "HomeItemCell", bundle: bundle) }

    /// Nib `JobItemCell`.
    var jobItemCell: RswiftResources.NibReference<JobItemCell> { .init(name: "JobItemCell", bundle: bundle) }

    /// Nib `LoginView`.
    var loginView: RswiftResources.NibReference<LoginView> { .init(name: "LoginView", bundle: bundle) }

    /// Nib `NameCardContentView`.
    var nameCardContentView: RswiftResources.NibReference<NameCardContentView> { .init(name: "NameCardContentView", bundle: bundle) }

    /// Nib `NameCardEditView`.
    var nameCardEditView: RswiftResources.NibReference<NameCardEditView> { .init(name: "NameCardEditView", bundle: bundle) }

    /// Nib `NameCardQRCodeView`.
    var nameCardQRCodeView: RswiftResources.NibReference<NameCardQRCodeView> { .init(name: "NameCardQRCodeView", bundle: bundle) }

    /// Nib `ProfileHeaderView`.
    var profileHeaderView: RswiftResources.NibReference<ProfileHeaderView> { .init(name: "ProfileHeaderView", bundle: bundle) }

    /// Nib `RegistAddAvatarView`.
    var registAddAvatarView: RswiftResources.NibReference<RegistAddAvatarView> { .init(name: "RegistAddAvatarView", bundle: bundle) }

    /// Nib `RegistConfirmView`.
    var registConfirmView: RswiftResources.NibReference<RegistConfirmView> { .init(name: "RegistConfirmView", bundle: bundle) }

    /// Nib `RegistInfoView`.
    var registInfoView: RswiftResources.NibReference<RegistInfoView> { .init(name: "RegistInfoView", bundle: bundle) }

    /// Nib `RegistProfileView`.
    var registProfileView: RswiftResources.NibReference<RegistProfileView> { .init(name: "RegistProfileView", bundle: bundle) }

    func validate() throws {
      if UIKit.UIImage(named: "person.fill.checkmark", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'person.fill.checkmark' is used in nib 'CaledarItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "repeat", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'repeat' is used in nib 'CaledarItemCell', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor52", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor52' is used in nib 'CaledarItemCell', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor74", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor74' is used in nib 'CaledarItemCell', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'ConnectAuditItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "proile_user", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'proile_user' is used in nib 'ConnectionItemCell', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor52", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor52' is used in nib 'ConnectionItemCell', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'ConnectionItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "plus.circle", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'plus.circle' is used in nib 'CreateGroupHeaderView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "BackgroundColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'BackgroundColor' is used in nib 'CreateGroupHeaderView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor52", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor52' is used in nib 'CreateGroupHeaderView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor74", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor74' is used in nib 'CreateGroupHeaderView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'CreateGroupHeaderView', but couldn't be loaded.") }
      if UIKit.UIImage(named: "job_mark", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'job_mark' is used in nib 'HomeHeaderJobItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "placeholder", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'placeholder' is used in nib 'HomeHeaderJobItemCell', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor52", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor52' is used in nib 'HomeHeaderJobItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "search_icon", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'search_icon' is used in nib 'HomeHeaderView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor162C46", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor162C46' is used in nib 'HomeHeaderView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor52", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor52' is used in nib 'HomeHeaderView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'HomeHeaderView', but couldn't be loaded.") }
      if UIKit.UIImage(named: "comment", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'comment' is used in nib 'HomeItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "like", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'like' is used in nib 'HomeItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "proile_user", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'proile_user' is used in nib 'HomeItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "retweet", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'retweet' is used in nib 'HomeItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "send", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'send' is used in nib 'HomeItemCell', but couldn't be loaded.") }
      if UIKit.UIColor(named: "BackgroundColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'BackgroundColor' is used in nib 'HomeItemCell', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor52", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor52' is used in nib 'HomeItemCell', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'HomeItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "job_location", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'job_location' is used in nib 'JobItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "job_mark", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'job_mark' is used in nib 'JobItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "placeholder", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'placeholder' is used in nib 'JobItemCell', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor52", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor52' is used in nib 'JobItemCell', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'JobItemCell', but couldn't be loaded.") }
      if UIKit.UIImage(named: "google", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'google' is used in nib 'LoginView', but couldn't be loaded.") }
      if UIKit.UIImage(named: "password_invisible", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'password_invisible' is used in nib 'LoginView', but couldn't be loaded.") }
      if UIKit.UIImage(named: "password_visible", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'password_visible' is used in nib 'LoginView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'LoginView', but couldn't be loaded.") }
      if UIKit.UIImage(named: "namecard_background", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'namecard_background' is used in nib 'NameCardContentView', but couldn't be loaded.") }
      if UIKit.UIImage(named: "profile_edit_userinfo", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'profile_edit_userinfo' is used in nib 'NameCardContentView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor52", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor52' is used in nib 'NameCardContentView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor52", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor52' is used in nib 'NameCardEditView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'NameCardEditView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TextColor52", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TextColor52' is used in nib 'NameCardQRCodeView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'NameCardQRCodeView', but couldn't be loaded.") }
      if UIKit.UIImage(named: "profile_edit_userinfo", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'profile_edit_userinfo' is used in nib 'ProfileHeaderView', but couldn't be loaded.") }
      if UIKit.UIImage(named: "proile_user", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'proile_user' is used in nib 'ProfileHeaderView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'ProfileHeaderView', but couldn't be loaded.") }
      if UIKit.UIImage(named: "proile_user", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'proile_user' is used in nib 'RegistAddAvatarView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'RegistAddAvatarView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'RegistConfirmView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'RegistInfoView', but couldn't be loaded.") }
      if UIKit.UIColor(named: "TheamColor", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Color named 'TheamColor' is used in nib 'RegistProfileView', but couldn't be loaded.") }
    }
  }

  /// This `_R.storyboard` struct is generated, and contains static references to 2 storyboards.
  struct storyboard {
    let bundle: Foundation.Bundle
    var attachmentDetailsViewController: attachmentDetailsViewController { .init(bundle: bundle) }
    var launchScreen: launchScreen { .init(bundle: bundle) }

    func attachmentDetailsViewController(bundle: Foundation.Bundle) -> attachmentDetailsViewController {
      .init(bundle: bundle)
    }
    func launchScreen(bundle: Foundation.Bundle) -> launchScreen {
      .init(bundle: bundle)
    }
    func validate() throws {
      try self.attachmentDetailsViewController.validate()
      try self.launchScreen.validate()
    }


    /// Storyboard `AttachmentDetailsViewController`.
    struct attachmentDetailsViewController: RswiftResources.StoryboardReference {
      let bundle: Foundation.Bundle

      let name = "AttachmentDetailsViewController"

      var attachmentDetailsViewController: RswiftResources.StoryboardViewControllerIdentifier<AttachmentDetailsViewController> { .init(identifier: "AttachmentDetailsViewController", storyboard: name, bundle: bundle) }

      func validate() throws {
        if attachmentDetailsViewController() == nil { throw RswiftResources.ValidationError("[R.swift] ViewController with identifier 'attachmentDetailsViewController' could not be loaded from storyboard 'AttachmentDetailsViewController' as 'AttachmentDetailsViewController'.") }
      }
    }

    /// Storyboard `LaunchScreen`.
    struct launchScreen: RswiftResources.StoryboardReference, RswiftResources.InitialControllerContainer {
      typealias InitialController = UIKit.UIViewController

      let bundle: Foundation.Bundle

      let name = "LaunchScreen"
      func validate() throws {
        if UIKit.UIImage(named: "appicon", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'appicon' is used in storyboard 'LaunchScreen', but couldn't be loaded.") }
      }
    }
  }
}