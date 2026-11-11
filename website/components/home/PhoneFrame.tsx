import Image from "next/image";

/** A real app screenshot (1290×2796) in a quiet device bezel. */
export default function PhoneFrame({
  src,
  alt,
  className,
  sizes = "(max-width: 700px) 60vw, 300px",
  priority = false,
}: {
  src: string;
  alt: string;
  className?: string;
  sizes?: string;
  priority?: boolean;
}) {
  return (
    <div className={`nd-phone ${className ?? ""}`}>
      <Image
        src={src}
        alt={alt}
        width={1290}
        height={2796}
        sizes={sizes}
        priority={priority}
        className="nd-phone__screen"
      />
    </div>
  );
}
