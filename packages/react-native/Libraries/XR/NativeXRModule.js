/**
 * @flow strict
 * @format
 */

import type {TurboModule} from '../TurboModule/RCTExport';

import * as TurboModuleRegistry from '../TurboModule/TurboModuleRegistry';

export type XRModuleConstants = {|
  +supportsMultipleScenes?: boolean,
|};

export interface Spec extends TurboModule {
  +getConstants: () => XRModuleConstants;

  +requestSession: (sessionId?: string) => Promise<void>;
  +endSession: () => Promise<void>;
}

export default (TurboModuleRegistry.get<Spec>('XRModule'): ?Spec);
