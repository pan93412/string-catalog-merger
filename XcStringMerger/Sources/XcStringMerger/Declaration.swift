public typealias LanguageCode = String
public typealias StringKey = String

public struct StringCatalogV1: Hashable, Equatable, Codable, Clonable {
  public let sourceLanguage: String
  public let strings: Dictionary<StringKey, Localizations>

  public let version: String

  public func clone() -> Self {
    Self(sourceLanguage: sourceLanguage, strings: strings.clone(), version: version)
  }
}

public struct Localizations: Hashable, Equatable, Codable, Clonable {
  public let localizations: Dictionary<LanguageCode, LocalizedString>

  public func clone() -> Self {
    Self(localizations: localizations.clone())
  }
}

public struct LocalizedString: Hashable, Equatable, Codable, Clonable {
  public let stringUnit: StringUnit

  public func clone() -> Self {
    Self(stringUnit: stringUnit.clone())
  }
}

public struct StringUnit: Hashable, Equatable, Codable, Clonable {
  public let state: String  // ex. "translated"
  public let value: String

  public func clone() -> Self {
    Self(state: state, value: value)
  }
}

public protocol Clonable {
  func clone() -> Self
}

extension Dictionary: Clonable
where
Value: Clonable
{
  public func clone() -> Self {
    Self.init(uniqueKeysWithValues: self.enumerated().map { (_, element) in
      (element.key, element.value.clone())
    })
  }
}
