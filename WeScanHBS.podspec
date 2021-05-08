Pod::Spec.new do |spec|
  spec.name             = 'WeScanHBS'
  spec.version          = '1.9.1'
  spec.summary          = 'Document Scanning Made Easy for iOS'
  spec.description      = 'WeScan makes it easy to add scanning functionalities to your iOS app! It\'s modelled after UIImagePickerController, which makes it a breeze to use.'

  spec.homepage         = 'https://github.com/MarcW1g/WeScan'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors           = {
    'Boris Emorine' => 'boris@wetransfer.com',
    'Antoine van der Lee' => 'antoine@wetransfer.com',
    'Marc Wiggerman' => 'marc@mwsd.dev'
  }
  spec.source           = { :git => 'https://github.com/MarcW1g/WeScan.git', :tag => "#{spec.version}" }
  # spec.social_media_url = 'https://twitter.com/WeTransfer'

  spec.swift_version = '5.0'
  spec.ios.deployment_target = '10.0'
  spec.source_files = 'WeScan/**/*.{h,m,swift}'
  spec.resources = 'WeScan/**/*.{strings,png}'
end
