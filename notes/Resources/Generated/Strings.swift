// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum App {
    internal enum Creation {
      /// Done
      internal static let done = L10n.tr("Localizable", "App.Creation.Done")
      internal enum Placeholder {
        /// body
        internal static let body = L10n.tr("Localizable", "App.Creation.Placeholder.Body")
        /// title
        internal static let title = L10n.tr("Localizable", "App.Creation.Placeholder.Title")
      }
    }
    internal enum General {
      /// application's logo
      internal static let logoAccessibilityLabel = L10n.tr("Localizable", "App.General.logo-accessibilityLabel")
      /// Notes
      internal static let name = L10n.tr("Localizable", "App.General.name")
    }
    internal enum List {
      internal enum Empty {
        /// no additional text
        internal static let body = L10n.tr("Localizable", "App.List.Empty.body")
        /// no title
        internal static let title = L10n.tr("Localizable", "App.List.Empty.title")
      }
    }
    internal enum Login {
      /// Authorization...
      internal static let authorization = L10n.tr("Localizable", "App.Login.Authorization")
      /// Logout
      internal static let logOut = L10n.tr("Localizable", "App.Login.LogOut")
      /// Sign In
      internal static let signIn = L10n.tr("Localizable", "App.Login.SignIn")
      /// Sign Up
      internal static let signUp = L10n.tr("Localizable", "App.Login.SignUp")
      internal enum Placeholder {
        /// email
        internal static let email = L10n.tr("Localizable", "App.Login.Placeholder.Email")
        /// name
        internal static let name = L10n.tr("Localizable", "App.Login.Placeholder.Name")
        /// password
        internal static let password = L10n.tr("Localizable", "App.Login.Placeholder.Password")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
