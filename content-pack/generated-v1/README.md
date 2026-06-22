# Generated V1 Coloring Pack

This is the planned first generated content pack.

## Scope

- 7 categories: Animals, Vehicles, Ocean, Princesses, Space, Fantasy, Nature
- 3 age groups: Ages 4-5, Ages 6-7, Ages 8-9
- 10 pages per category per age group
- 210 planned pages total

## Age and Style Mapping

| Age group | Style direction | Intent |
|---|---|---|
| Ages 4-5 | Bold cartoon and rounded cute | Big shapes, very thick outlines, minimal scene detail |
| Ages 6-7 | Geometric and storybook | Moderate detail, clearer scenes, consistent enclosed areas |
| Ages 8-9 | Doodle pattern and detailed storybook | More decorative details and texture zones without crowding |

## Files

- `content-pack-plan.json` is the source-of-truth prompt manifest.
- Each planned page has a stable `id`, `categoryID`, `ageGroupID`, output `filename`, and image-generation `prompt`.
- Planned output filenames are relative to this pack, for example `animals/ages-4-5/lion.png`.

## Production Notes

The app supports age-group and category enable/disable settings now, but this pack does not yet include generated bitmap files. Generate and review the images before moving them into the app bundle.

Quality bar before shipping:

- Black line art only on white background
- No text, watermark, signature, grayscale, color, or heavy filled areas
- Closed shapes suitable for coloring
- Recognizable category and age-appropriate complexity
- Print test on the target AirPrint printer

