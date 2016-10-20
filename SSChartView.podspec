#
# Be sure to run `pod lib lint SSChartView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SSChartView'
  s.version          = '0.2.0'
  s.summary          = 'A short description of SSChartView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Simple Bar Graph UI used for charting.
                       DESC

  s.homepage         = 'https://github.com/sambhav7890/SSChartView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sambhav Shah' => 'sambhav.shah@practo.com' }
  s.source           = { :git => 'https://github.com/sambhav7890/SSChartView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'SSChartView/Classes/**/*'
  
  s.resource_bundles = {
	'SSChartView' => ['SSChartView/Assets/**/*.xib']
  }

  s.frameworks = 'UIKit'
end
