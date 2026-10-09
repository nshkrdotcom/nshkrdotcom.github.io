#!/usr/bin/env python3
"""Regenerate browser/app icons from static/favicon.svg.

Dependencies: pip install cairosvg pillow
Run from any directory: python3 scripts/generate_site_icons.py
"""
from io import BytesIO
from pathlib import Path

import cairosvg
from PIL import Image

STATIC = Path(__file__).resolve().parents[1] / "static"
SOURCE = STATIC / "favicon.svg"


def render(size):
    # Render large, then downsample so the diagonal remains crisp at tab sizes.
    png = cairosvg.svg2png(url=str(SOURCE), output_width=size * 4, output_height=size * 4)
    return Image.open(BytesIO(png)).convert("RGBA").resize((size, size), Image.Resampling.LANCZOS)


def main():
    for name, size in (
        ("favicon-16x16.png", 16),
        ("favicon-32x32.png", 32),
        ("apple-touch-icon.png", 180),
        ("android-chrome-192x192.png", 192),
        ("android-chrome-512x512.png", 512),
    ):
        icon = render(size)
        if size >= 180:
            # App launchers supply their own corner masking; give them an opaque square.
            background = Image.new("RGBA", icon.size, "#355b45")
            background.alpha_composite(icon)
            icon = background.convert("RGB")
        icon.save(STATIC / name)
    render(256).save(STATIC / "favicon.ico", sizes=[(16, 16), (32, 32), (48, 48), (64, 64)])


if __name__ == "__main__":
    main()
