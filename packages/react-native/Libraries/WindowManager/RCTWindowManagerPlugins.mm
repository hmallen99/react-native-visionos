#import "RCTWindowManagerPlugins.h"

#import <string>
#import <unordered_map>

Class RCTWindowManagerClassProvider(const char *name) {
  // Intentionally leak to avoid crashing after static destructors are run.
  static const auto sCoreModuleClassMap = new const std::unordered_map<std::string, Class (*)(void)>{
    {"WindowManager", RCTWindowManagerCls},
  };

  auto p = sCoreModuleClassMap->find(name);
  if (p != sCoreModuleClassMap->end()) {
    auto classFunc = p->second;
    return classFunc();
  }
  return nil;
}
