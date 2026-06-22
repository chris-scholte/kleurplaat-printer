const fs = require("fs");
const path = require("path");

const outPath = path.join(
  __dirname,
  "..",
  "content-pack",
  "generated-v1",
  "content-pack-plan.json"
);

const categories = [
  {
    id: "animals",
    title: "Animals",
    symbolName: "pawprint.fill",
    colorName: "green",
    subjects: [
      "lion",
      "elephant",
      "giraffe",
      "bear",
      "fox",
      "rabbit",
      "horse",
      "penguin",
      "puppy",
      "kitten"
    ]
  },
  {
    id: "vehicles",
    title: "Vehicles",
    symbolName: "car.fill",
    colorName: "orange",
    subjects: [
      "fire truck",
      "tractor",
      "race car",
      "train",
      "airplane",
      "bicycle",
      "dump truck",
      "sailboat",
      "bus",
      "rocket car"
    ]
  },
  {
    id: "ocean",
    title: "Ocean",
    symbolName: "water.waves",
    colorName: "blue",
    subjects: [
      "fish",
      "sea turtle",
      "octopus",
      "dolphin",
      "whale",
      "crab",
      "jellyfish",
      "seahorse",
      "starfish",
      "submarine"
    ]
  },
  {
    id: "princesses",
    title: "Princesses",
    symbolName: "crown.fill",
    colorName: "pink",
    subjects: [
      "princess crown",
      "castle tower",
      "royal carriage",
      "princess dress",
      "magic mirror",
      "garden castle",
      "friendly unicorn",
      "royal puppy",
      "tea party",
      "fairy wand"
    ]
  },
  {
    id: "space",
    title: "Space",
    symbolName: "moon.stars.fill",
    colorName: "indigo",
    subjects: [
      "rocket",
      "astronaut",
      "moon rover",
      "space station",
      "satellite",
      "planet parade",
      "alien friend",
      "comet",
      "telescope",
      "moon base"
    ]
  },
  {
    id: "fantasy",
    title: "Fantasy",
    symbolName: "sparkles",
    colorName: "purple",
    subjects: [
      "dragon",
      "wizard hat",
      "fairy house",
      "friendly monster",
      "treasure chest",
      "magic tree",
      "phoenix",
      "castle gate",
      "flying carpet",
      "enchanted book"
    ]
  },
  {
    id: "nature",
    title: "Nature",
    symbolName: "leaf.fill",
    colorName: "teal",
    subjects: [
      "tree",
      "sunflower",
      "butterfly",
      "rainbow",
      "mountain",
      "mushroom",
      "garden",
      "beehive",
      "pond",
      "autumn leaves"
    ]
  }
];

const ageGroups = [
  {
    id: "ages-4-5",
    title: "Ages 4-5",
    subtitle: "Big shapes, bold outlines",
    styleName: "Bold cartoon and rounded cute",
    stylePrompt:
      "bold friendly cartoon style with very thick clean outlines, oversized simple shapes, minimal scene elements, large blank areas, easy for ages 4 to 5"
  },
  {
    id: "ages-6-7",
    title: "Ages 6-7",
    subtitle: "More scene detail",
    styleName: "Geometric and storybook",
    stylePrompt:
      "simple geometric and whimsical storybook line-art style, medium clean outlines, a small supporting scene, clear enclosed areas, moderate detail for ages 6 to 7"
  },
  {
    id: "ages-8-9",
    title: "Ages 8-9",
    subtitle: "Patterns and finer details",
    styleName: "Doodle pattern and detailed storybook",
    stylePrompt:
      "playful doodle pattern and detailed storybook line-art style, clean outlines, more decorative shapes and texture zones, still uncrowded, engaging for ages 8 to 9"
  }
];

function slugify(value) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

function promptFor(category, ageGroup, subject, index) {
  return [
    "Use case: illustration-story",
    "Asset type: printable kids coloring page for Kleurplaat Printer content pack",
    `Primary request: ${category.title} coloring page featuring a ${subject}.`,
    "Scene/backdrop: simple kid-friendly scene related to the subject, white page background.",
    `Subject: ${subject}.`,
    `Style/medium: ${ageGroup.stylePrompt}.`,
    "Composition/framing: portrait A4 sheet, centered main subject, generous margins, full-page coloring composition.",
    "Color palette: black line art only on white background.",
    "Text (verbatim): none.",
    "Constraints: closed shapes suitable for coloring, printable, no filled black areas except small eyes or tiny accents, no grayscale, no shading, no color, no watermark, no signature, no text, no unsafe objects.",
    `Series note: page ${index + 1} of 10 for ${category.title} / ${ageGroup.title}; keep the visual language consistent but make the composition distinct.`
  ].join("\\n");
}

const pages = [];

for (const category of categories) {
  for (const ageGroup of ageGroups) {
    category.subjects.forEach((subject, index) => {
      const subjectSlug = slugify(subject);
      const id = `${category.id}-${ageGroup.id}-${subjectSlug}`;
      pages.push({
        id,
        title: subject
          .split(" ")
          .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
          .join(" "),
        categoryID: category.id,
        ageGroupID: ageGroup.id,
        styleName: ageGroup.styleName,
        filename: `${category.id}/${ageGroup.id}/${subjectSlug}.png`,
        mime: "image/png",
        status: "planned",
        prompt: promptFor(category, ageGroup, subject, index)
      });
    });
  }
}

const pack = {
  id: "generated-v1",
  title: "Generated V1 Coloring Pack",
  version: 1,
  generatedOn: "2026-06-19",
  categories: categories.map(({ subjects, ...category }) => category),
  ageGroups: ageGroups.map(({ stylePrompt, ...ageGroup }) => ageGroup),
  pageCount: pages.length,
  pagesPerCategoryAgeGroup: 10,
  pages
};

fs.writeFileSync(outPath, `${JSON.stringify(pack, null, 2)}\n`);
console.log(`Wrote ${pages.length} planned pages to ${outPath}`);

