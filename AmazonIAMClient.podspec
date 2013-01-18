Pod::Spec.new do |s|
  s.name         = "AmazonIAMClient"
  s.version      = "0.1.0"
  s.summary      = "AFNetworking client for the Amazon IAM API."
  s.homepage     = "https://github.com/brcosm/AmazonIAMClient"
  s.license      = 'MIT'
  s.author       = { "Brandon Smith" => "brcosm@gmail.com" }
  s.source       = { :git => "https://github.com/brcosm/AmazonIAMClient.git",
                     :tag => "0.1.0" }
  s.platform     = :ios, '5.0'
  s.source_files = 'AmazonIAMClient'
  s.framework    = 'Security'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 1.0'
  s.dependency 'AFKissXMLRequestOperation', '~> 0.0.1'
end
