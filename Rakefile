# frozen_string_literal: true

namespace :strings do
  desc 'Generate Swift interface'
  task :generate do
    output = <<~SWIFT
      // Automatically generated. Do not modify.

      import Foundation

      enum LocalizedString: String {

    SWIFT

    raw = File.read('Modules/Redacted-iOS/Resources/en.lproj/Localizable.strings')
    keys = raw.scan(/^"([A-Z_]+)" = "/).collect(&:first).sort

    keys.each do |key|
      camel = key.split('_').collect(&:capitalize).join.tap { |e| e[0] = e[0].downcase }
      output += %(    case #{camel} = "#{key}"\n)
    end

    output += <<~SWIFT

          var string: String {
              return NSLocalizedString(rawValue, comment: "")
          }
      }
    SWIFT

    File.open('Modules/Redacted-iOS/Sources/LocalizedString.swift', 'w') do |f|
      f.write(output)
    end
  end
end
