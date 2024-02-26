require "json"

package = JSON.parse(File.read(File.join(__dir__, "..", "..", "package.json")))
version = package['version']

source = { :git => 'https://github.com/facebook/react-native.git' }
if version == '1000.0.0'
  # This is an unpublished version, use the latest commit hash of the react-native repo, which we’re presumably in.
  source[:commit] = `git rev-parse HEAD`.strip if system("git rev-parse --git-dir > /dev/null 2>&1")
else
  source[:tag] = "v#{version}"
end

is_new_arch_enabled = ENV["RCT_NEW_ARCH_ENABLED"] == "1"
new_arch_enabled_flag = (is_new_arch_enabled ? " -DRCT_NEW_ARCH_ENABLED" : "")

folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -DFOLLY_CFG_NO_COROUTINES=1 -Wno-comma -Wno-shorten-64-to-32'
folly_version = '2022.05.16.00'
compiler_flags = folly_compiler_flags + new_arch_enabled_flag + ' -Wno-nullability-completeness'

header_search_paths = [
  "\"$(PODS_ROOT)/RCT-Folly\"",
  "\"${PODS_ROOT}/Headers/Public/React-Codegen/react/renderer/components\"",
]

Pod::Spec.new do |s|
  s.name                   = "React-RCTWindowManager"
  s.version                = version
  s.summary                = "Window manager module for React Native."
  s.homepage               = "https://callstack.github.io/react-native-visionos-docs"
  s.documentation_url      = "https://callstack.github.io/react-native-visionos-docs/api/windowmanager"
  s.license                = package["license"]
  s.author                 = "Callstack"
  s.platforms              = min_supported_versions
  s.compiler_flags         = compiler_flags
  s.source                 = source
  s.source_files           = "*.{m,mm,swift}"
  s.preserve_paths         = "package.json", "LICENSE", "LICENSE-docs"
  s.header_dir             = "RCTWindowManager"
  s.pod_target_xcconfig    = {
                               "USE_HEADERMAP" => "YES",
                               "CLANG_CXX_LANGUAGE_STANDARD" => "c++20",
                               "HEADER_SEARCH_PATHS" => header_search_paths.join(' ')
                             }

  s.dependency "RCT-Folly", folly_version
  s.dependency "RCTTypeSafety"
  s.dependency "React-jsi"
  s.dependency "React-Core/RCTWindowManagerHeaders"

  add_dependency(s, "React-Codegen", :additional_framework_paths => ["build/generated/ios"])
  add_dependency(s, "ReactCommon", :subspec => "turbomodule/core", :additional_framework_paths => ["react/nativemodule/core"])
  add_dependency(s, "React-NativeModulesApple", :additional_framework_paths => ["build/generated/ios"])
end
