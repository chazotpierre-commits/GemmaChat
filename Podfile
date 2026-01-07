<<<<<<< HEAD
platform :ios, '26.0'
=======
platform :ios, '17.0'
>>>>>>> 60b3b5f (Fresh start without heavy files)
target 'GemmaChat' do
  use_frameworks!
  pod 'MediaPipeTasksGenAI'
  pod 'MediaPipeTasksGenAIC'
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
<<<<<<< HEAD
end
=======
end
>>>>>>> 60b3b5f (Fresh start without heavy files)
