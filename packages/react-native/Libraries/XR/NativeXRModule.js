/**
 * @flow strict
 * @format
 */

import type {TurboModule} from '../TurboModule/RCTExport';

import * as TurboModuleRegistry from '../TurboModule/TurboModuleRegistry';

export interface Spec extends TurboModule {
  // $FlowIgnore[unclear-type]
  +requestSession: (sessionId?: string, userInfo: Object) => Promise<void>;
  +endSession: () => Promise<void>;
}

export default (TurboModuleRegistry.get<Spec>('XRModule'): ?Spec);
