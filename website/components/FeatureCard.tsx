"use client";

import Image from "next/image";
import { useState } from "react";

type FeatureCardProps = {
  title: string;
  description: string;
  imageSrc: string | null;
  imageAlt: string;
};

export default function FeatureCard({
  title,
  description,
  imageSrc,
  imageAlt,
}: FeatureCardProps) {
  const [imageError, setImageError] = useState(false);
  const showImage = imageSrc && !imageError;

  return (
    <article className="flex flex-col rounded-2xl bg-surface-container/50 p-6 sm:p-8">
      <div className="mb-4 aspect-[9/16] max-h-[320px] w-full overflow-hidden rounded-xl bg-surface-container">
        {showImage ? (
          <Image
            src={imageSrc}
            alt={imageAlt}
            width={360}
            height={640}
            className="h-full w-full object-cover object-top"
            unoptimized
            onError={() => setImageError(true)}
          />
        ) : (
          <div
            className="flex h-full w-full items-center justify-center text-on-surface-variant/40"
            aria-hidden
          >
            <span className="text-sm">Aperçu</span>
          </div>
        )}
      </div>
      <h2 className="text-xl font-semibold tracking-tight text-on-surface">
        {title}
      </h2>
      <p className="mt-2 text-on-surface-variant leading-relaxed">
        {description}
      </p>
    </article>
  );
}
