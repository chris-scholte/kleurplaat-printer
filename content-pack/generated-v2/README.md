# Generated v2 Pilot

This pilot replaces the procedural PDF placeholders with real raster coloring-page exports generated through the built-in image generation tool.

## Scope

- Categories: animals, space, princesses
- Age groups: ages 4-5, ages 6-7, ages 8-9
- Output: 9 PNG files in `KleurplaatPrinter/Content/generated-v2`
- Dimensions: 1024 x 1536 pixels

## Quality Gate

- Use only real generated image exports for pilot pages.
- Stop instead of substituting procedural placeholders if generated assets cannot be saved.
- Keep pages black-and-white, print-ready, and free of text, labels, watermarks, color, gray shading, shadows, gradients, and filled background areas.
- Scale detail by age group:
  - ages 4-5: one large subject, thick rounded outlines, large coloring regions.
  - ages 6-7: simple scene context, medium-bold outlines, moderate detail.
  - ages 8-9: richer storybook/doodle detail, still clean enough to color.

## Accepted Pilot Pages

- `animals/ages-4-5/lion.png`
- `animals/ages-6-7/lion.png`
- `animals/ages-8-9/lion.png`
- `space/ages-4-5/rocket.png`
- `space/ages-6-7/rocket.png`
- `space/ages-8-9/rocket.png`
- `princesses/ages-4-5/princess.png`
- `princesses/ages-6-7/princess.png`
- `princesses/ages-8-9/princess.png`

## Notes

- Two princess generations were rejected before copying because they used filled pupils or were too busy for the target age band.
- The ages 8-9 princess page intentionally tests a more ornate framed style. Decide before bulk generation whether frames and blank banner shapes are allowed.
