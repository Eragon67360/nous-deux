/** The Nous Deux mark: two rings locked together, the partner dot where they meet. */
export default function RingsMark({
  className,
  title,
  strokeWidth = 4.5,
}: {
  className?: string;
  title?: string;
  strokeWidth?: number;
}) {
  return (
    <svg
      className={className}
      viewBox="0 0 120 76"
      role={title ? "img" : undefined}
      aria-hidden={title ? undefined : true}
      aria-label={title}
    >
      <circle cx="46" cy="38" r="30" fill="none" stroke="var(--sc-accent)" strokeWidth={strokeWidth} />
      <circle cx="74" cy="38" r="30" fill="none" stroke="var(--nd-cream)" strokeWidth={strokeWidth} />
      <circle cx="60" cy="38" r={strokeWidth * 1.25} fill="var(--nd-rose)" />
    </svg>
  );
}
