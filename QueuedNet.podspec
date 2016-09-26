#
# Be sure to run `pod lib lint QueuedNet.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QueuedNet'
  s.version          = '2.0.0'
  s.summary          = 'QueuedNet is a Swift framework to parallelize applications more declaratively.'
  s.description      = <<-DESC
QueuedNet is a Swift framework to parallelize applications more declaratively and is comparable to a Petri Net.
                       DESC
  s.homepage         = 'https://github.com/vknabel/QueuedNet'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Valentin Knabel' => 'develop@vknabel.com' }
  s.source           = { :git => 'https://github.com/vknabel/QueuedNet.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
	s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source_files = 'QueuedNet/QueuedNet/*.swift'
end
