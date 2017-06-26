namespace :strings do
  desc 'Import strings files'
  task :import do
    # TODO: Ensure clean git status

    # Clone strings
    unless Dir.exists? 'tmp/i18n'
      puts 'ℹ️  Cloning strings…'
      system 'mkdir -p tmp'
      system 'git clone https://github.com/nothingmagical/redacted-i18n tmp/i18n'
    else
      puts 'ℹ️  Updating strings…'
      Dir.chdir 'tmp/i18n' do
        system 'git pull origin master'
      end
    end

    # Get language list
    languages = Dir.chdir 'tmp/i18n' do
      Dir['*.lproj']
    end
    puts "ℹ️  Found #{languages.count} languages: #{languages.join(', ')}"

    # Clean local strings
    puts 'ℹ️  Removing local strings…'
    Dir['*/Sources/*.lproj'].each do |lproj|
      next if File.basename(path) == 'Base.lproj'
      system "rm -rf '#{lproj}'"
    end

    # Import RedactedKit strings
    shared = {
      'Shared.strings' => 'Localizable.strings'
    }
    import_strings 'RedactedKit/Support', shared, languages

    # Import iOS strings
    ios = {
      'iOS.strings' => 'Localizable.strings',
      'iOS InfoPlist.strings' => 'InfoPlist.strings',
    }
    import_strings 'Redacted-iOS/Support', ios, languages

    # Import macOS strings
    mac = {
      'macOS.strings' => 'Main.strings'
    }
    import_strings 'Redacted-macOS/Support', mac, languages

    puts
    puts '✅  Success!'
  end

  desc 'Generate Swift interface'
  task :generate do
    output = <<~SWIFT
      // Automatically generated. Do not modify.

      import Foundation

      enum LocalizedString: String {

    SWIFT

    raw = File.read('Redacted-iOS/Support/en.lproj/Localizable.strings')
    keys = raw.scan(/^"([A-Z_]+)" = "/).collect(&:first).sort

    keys.each do |key|
      camel = key.split('_').collect(&:capitalize).join.tap { |e| e[0] = e[0].downcase }
      output << %(    case #{camel} = "#{key}"\n)
    end

    output << <<~SWIFT

          var string: String {
              return NSLocalizedString(rawValue, comment: "")
          }
      }
    SWIFT

    File.open('Redacted-iOS/Sources/LocalizedString.swift', 'w') do |f|
      f.write(output)
    end
  end
end

private

def import_strings(local_dir, map, languages)
  puts "ℹ️  Importing strings to #{local_dir}…"

  languages.each do |language|
    system "mkdir -p '#{local_dir}/#{language}'"

    map.each do |key, value|
      system "cp 'tmp/i18n/#{language}/#{key}' '#{local_dir}/#{language}/#{value}'"
    end
  end
end
