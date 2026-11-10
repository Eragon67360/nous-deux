// Types for the vendored scrollcraft engine (scrollcraft.js is copied verbatim
// from the scroll-craft skill and must not be edited).
export {};

declare global {
  interface ScrollCraftInstance {
    destroy?: () => void;
  }
  interface Window {
    ScrollCraft?: {
      mount: (root?: Element | string | null, opts?: object) => ScrollCraftInstance;
    };
  }
}
