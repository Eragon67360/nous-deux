"use client";

import { useEffect } from "react";

/**
 * Mounts the vendored scroll-craft engine on the element with `rootId` and
 * tears it down on unmount (client navigation, language switch).
 * The engine touches `window` at load, so it is imported on the client only.
 */
export default function ScrollCraftMount({ rootId }: { rootId: string }) {
  useEffect(() => {
    let instance: ScrollCraftInstance | undefined;
    let cancelled = false;
    import("@/vendor/scrollcraft/scrollcraft.js").then(() => {
      if (cancelled) return;
      const root = document.getElementById(rootId);
      instance = window.ScrollCraft?.mount(root ?? document.body);
    });
    return () => {
      cancelled = true;
      instance?.destroy?.();
    };
  }, [rootId]);
  return null;
}
