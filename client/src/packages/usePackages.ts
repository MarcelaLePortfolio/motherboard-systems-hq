import { useContext } from "react";

import {
  PackageReadContext,
  type PackageReadContextValue,
} from "./PackageReadProvider";

export function usePackages(): PackageReadContextValue {
  const context = useContext(PackageReadContext);

  if (!context) {
    throw new Error(
      "usePackages must be used within a PackageReadProvider.",
    );
  }

  return context;
}
