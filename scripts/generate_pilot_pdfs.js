const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const outputRoot = path.join(root, "KleurplaatPrinter", "Content", "generated-v1");
const manifestPath = path.join(root, "KleurplaatPrinter", "Content", "ContentManifest.json");

const pageWidth = 595;
const pageHeight = 842;
const kappa = 0.5522847498;

const pilots = [
  { categoryID: "animals", title: "Lion", subject: "lion", draw: drawLion },
  { categoryID: "vehicles", title: "Fire Truck", subject: "fire-truck", draw: drawFireTruck },
  { categoryID: "ocean", title: "Fish", subject: "fish", draw: drawFish },
  { categoryID: "princesses", title: "Crown", subject: "crown", draw: drawCrown },
  { categoryID: "space", title: "Rocket", subject: "rocket", draw: drawRocket },
  { categoryID: "fantasy", title: "Dragon", subject: "dragon", draw: drawDragon },
  { categoryID: "nature", title: "Tree", subject: "tree", draw: drawTree }
];

const ageGroups = [
  { id: "ages-4-5", stroke: 6, detail: 1 },
  { id: "ages-6-7", stroke: 4, detail: 2 },
  { id: "ages-8-9", stroke: 2.8, detail: 3 }
];

function f(value) {
  return Number(value).toFixed(2).replace(/\.00$/, "");
}

function line(commands, x1, y1, x2, y2) {
  commands.push(`${f(x1)} ${f(y1)} m ${f(x2)} ${f(y2)} l S`);
}

function poly(commands, points, close = false) {
  const [first, ...rest] = points;
  commands.push(`${f(first[0])} ${f(first[1])} m`);
  for (const [x, y] of rest) commands.push(`${f(x)} ${f(y)} l`);
  if (close) commands.push("h");
  commands.push("S");
}

function rect(commands, x, y, width, height) {
  commands.push(`${f(x)} ${f(y)} ${f(width)} ${f(height)} re S`);
}

function circle(commands, cx, cy, r) {
  ellipse(commands, cx, cy, r, r);
}

function ellipse(commands, cx, cy, rx, ry) {
  commands.push(`${f(cx + rx)} ${f(cy)} m`);
  commands.push(`${f(cx + rx)} ${f(cy + kappa * ry)} ${f(cx + kappa * rx)} ${f(cy + ry)} ${f(cx)} ${f(cy + ry)} c`);
  commands.push(`${f(cx - kappa * rx)} ${f(cy + ry)} ${f(cx - rx)} ${f(cy + kappa * ry)} ${f(cx - rx)} ${f(cy)} c`);
  commands.push(`${f(cx - rx)} ${f(cy - kappa * ry)} ${f(cx - kappa * rx)} ${f(cy - ry)} ${f(cx)} ${f(cy - ry)} c`);
  commands.push(`${f(cx + kappa * rx)} ${f(cy - ry)} ${f(cx + rx)} ${f(cy - kappa * ry)} ${f(cx + rx)} ${f(cy)} c S`);
}

function curve(commands, x1, y1, x2, y2, x3, y3, x4, y4) {
  commands.push(`${f(x1)} ${f(y1)} m ${f(x2)} ${f(y2)} ${f(x3)} ${f(y3)} ${f(x4)} ${f(y4)} c S`);
}

function star(commands, cx, cy, r) {
  const points = [];
  for (let i = 0; i < 10; i += 1) {
    const angle = -Math.PI / 2 + (i * Math.PI) / 5;
    const radius = i % 2 === 0 ? r : r * 0.45;
    points.push([cx + Math.cos(angle) * radius, cy + Math.sin(angle) * radius]);
  }
  poly(commands, points, true);
}

function grass(commands, y = 120) {
  for (const x of [80, 125, 470, 515]) {
    line(commands, x, y, x + 10, y + 35);
    line(commands, x + 10, y, x + 10, y + 38);
    line(commands, x + 20, y, x + 10, y + 35);
  }
}

function addPattern(commands, x, y, width, height, detail) {
  if (detail < 3) return;
  for (let i = 0; i < 5; i += 1) {
    const xx = x + 20 + i * (width - 40) / 4;
    line(commands, xx, y + 20, xx + 20, y + height - 20);
  }
}

function drawLion(commands, detail) {
  circle(commands, 298, 520, 122);
  for (let i = 0; i < (detail === 1 ? 8 : 14); i += 1) {
    const angle = (i * Math.PI * 2) / (detail === 1 ? 8 : 14);
    circle(commands, 298 + Math.cos(angle) * 126, 520 + Math.sin(angle) * 126, detail === 1 ? 28 : 20);
  }
  circle(commands, 258, 542, 14);
  circle(commands, 338, 542, 14);
  ellipse(commands, 298, 500, 42, 32);
  curve(commands, 278, 478, 288, 458, 308, 458, 318, 478);
  ellipse(commands, 298, 315, 125, 72);
  circle(commands, 218, 332, 28);
  circle(commands, 378, 332, 28);
  curve(commands, 410, 330, 500, 330, 500, 435, 455, 458);
  circle(commands, 460, 460, 22);
  if (detail > 1) grass(commands);
  if (detail > 2) addPattern(commands, 215, 450, 165, 120, detail);
}

function drawFireTruck(commands, detail) {
  rect(commands, 130, 300, 310, 145);
  rect(commands, 350, 360, 95, 85);
  rect(commands, 372, 385, 42, 36);
  circle(commands, 195, 292, 34);
  circle(commands, 380, 292, 34);
  rect(commands, 150, 455, 255, 26);
  for (let x = 170; x <= 370; x += 40) line(commands, x, 455, x + 20, 481);
  rect(commands, 145, 330, 74, 54);
  rect(commands, 235, 330, 74, 54);
  if (detail > 1) {
    circle(commands, 456, 356, 16);
    line(commands, 440, 300, 500, 250);
    circle(commands, 512, 242, 18);
  }
  if (detail > 2) {
    for (let x = 155; x < 410; x += 36) rect(commands, x, 407, 18, 18);
    addPattern(commands, 230, 322, 92, 58, detail);
  }
}

function drawFish(commands, detail) {
  ellipse(commands, 300, 450, 130, 78);
  poly(commands, [[170, 450], [92, 510], [112, 450], [92, 390]], true);
  circle(commands, 352, 472, 12);
  curve(commands, 352, 416, 315, 392, 260, 404, 236, 432);
  for (const [x, y, r] of [[450, 560, 16], [490, 610, 12], [120, 585, 18], [95, 635, 10]]) circle(commands, x, y, r);
  if (detail > 1) {
    curve(commands, 105, 210, 180, 245, 250, 180, 330, 220);
    curve(commands, 300, 205, 390, 255, 460, 190, 520, 225);
    for (const x of [115, 470, 510]) {
      line(commands, x, 150, x, 230);
      curve(commands, x, 205, x - 30, 240, x - 8, 265, x + 22, 244);
    }
  }
  if (detail > 2) {
    for (let x = 240; x <= 330; x += 24) curve(commands, x, 510, x - 26, 462, x - 20, 426, x, 390);
  }
}

function drawCrown(commands, detail) {
  poly(commands, [[150, 350], [445, 350], [430, 505], [360, 430], [298, 545], [236, 430], [165, 505]], true);
  circle(commands, 298, 545, 20);
  circle(commands, 165, 505, 16);
  circle(commands, 430, 505, 16);
  rect(commands, 178, 300, 240, 48);
  circle(commands, 238, 394, 18);
  circle(commands, 298, 420, 20);
  circle(commands, 358, 394, 18);
  if (detail > 1) {
    rect(commands, 140, 180, 90, 110);
    rect(commands, 365, 180, 90, 110);
    poly(commands, [[130, 290], [185, 340], [240, 290]], true);
    poly(commands, [[355, 290], [410, 340], [465, 290]], true);
  }
  if (detail > 2) {
    for (let x = 205; x <= 385; x += 45) star(commands, x, 255, 13);
    addPattern(commands, 180, 352, 235, 155, detail);
  }
}

function drawRocket(commands, detail) {
  ellipse(commands, 298, 450, 72, 162);
  poly(commands, [[226, 520], [298, 672], [370, 520]], true);
  circle(commands, 298, 510, 34);
  poly(commands, [[240, 350], [185, 280], [252, 306]], true);
  poly(commands, [[356, 350], [410, 280], [344, 306]], true);
  poly(commands, [[268, 292], [298, 215], [328, 292]], true);
  if (detail > 1) {
    circle(commands, 142, 645, 34);
    circle(commands, 455, 585, 45);
    star(commands, 440, 700, 16);
    star(commands, 165, 540, 12);
  }
  if (detail > 2) {
    for (let y = 395; y <= 465; y += 28) line(commands, 240, y, 356, y + 12);
    star(commands, 500, 465, 12);
    star(commands, 110, 410, 14);
  }
}

function drawDragon(commands, detail) {
  ellipse(commands, 315, 390, 120, 70);
  ellipse(commands, 420, 455, 70, 52);
  circle(commands, 445, 470, 10);
  curve(commands, 214, 390, 135, 430, 115, 330, 205, 300);
  poly(commands, [[330, 455], [245, 565], [355, 530]], true);
  poly(commands, [[260, 430], [225, 470], [250, 505], [288, 465]], true);
  for (let x = 240; x <= 380; x += 35) poly(commands, [[x, 462], [x + 16, 500], [x + 32, 462]], true);
  if (detail > 1) {
    circle(commands, 455, 437, 12);
    line(commands, 365, 326, 365, 260);
    line(commands, 435, 332, 452, 265);
    circle(commands, 365, 252, 18);
    circle(commands, 452, 255, 18);
  }
  if (detail > 2) {
    for (let x = 255; x <= 360; x += 30) circle(commands, x, 392, 10);
    star(commands, 145, 575, 13);
    star(commands, 480, 610, 12);
  }
}

function drawTree(commands, detail) {
  rect(commands, 260, 235, 72, 190);
  circle(commands, 230, 475, 72);
  circle(commands, 300, 535, 86);
  circle(commands, 370, 475, 72);
  circle(commands, 300, 450, 74);
  curve(commands, 260, 340, 230, 365, 220, 398, 205, 425);
  curve(commands, 330, 350, 365, 375, 380, 407, 398, 438);
  if (detail > 1) {
    circle(commands, 120, 650, 46);
    curve(commands, 80, 160, 170, 220, 250, 160, 330, 205);
    curve(commands, 300, 185, 395, 250, 520, 185, 545, 220);
  }
  if (detail > 2) {
    for (const [x, y] of [[238, 504], [290, 578], [360, 500], [318, 455], [260, 438]]) {
      poly(commands, [[x, y], [x + 24, y + 16], [x + 48, y], [x + 24, y - 18]], true);
    }
    addPattern(commands, 262, 245, 68, 170, detail);
  }
}

function pagePdf(commands) {
  const stream = commands.join("\n");
  const objects = [
    "<< /Type /Catalog /Pages 2 0 R >>",
    "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
    `<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ${pageWidth} ${pageHeight}] /Contents 4 0 R >>`,
    `<< /Length ${Buffer.byteLength(stream)} >>\nstream\n${stream}\nendstream`
  ];

  let pdf = "%PDF-1.4\n";
  const offsets = [0];

  objects.forEach((object, index) => {
    offsets.push(Buffer.byteLength(pdf));
    pdf += `${index + 1} 0 obj\n${object}\nendobj\n`;
  });

  const xrefOffset = Buffer.byteLength(pdf);
  pdf += `xref\n0 ${objects.length + 1}\n0000000000 65535 f \n`;
  for (let i = 1; i <= objects.length; i += 1) {
    pdf += `${String(offsets[i]).padStart(10, "0")} 00000 n \n`;
  }
  pdf += `trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n${xrefOffset}\n%%EOF\n`;

  return Buffer.from(pdf, "ascii");
}

function drawPage(pilot, ageGroup) {
  const commands = [
    "q",
    "1 1 1 rg",
    `0 0 ${pageWidth} ${pageHeight} re f`,
    "1 J",
    "1 j",
    "0 0 0 RG",
    `${ageGroup.stroke} w`
  ];

  pilot.draw(commands, ageGroup.detail);
  commands.push("Q");

  return pagePdf(commands);
}

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function main() {
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  const pages = [];

  for (const pilot of pilots) {
    for (const ageGroup of ageGroups) {
      const dir = path.join(outputRoot, pilot.categoryID, ageGroup.id);
      ensureDir(dir);
      const filename = `${pilot.subject}.pdf`;
      fs.writeFileSync(path.join(dir, filename), drawPage(pilot, ageGroup));

      pages.push({
        id: `${pilot.categoryID}-${ageGroup.id}-${pilot.subject}`,
        title: pilot.title,
        categoryID: pilot.categoryID,
        ageGroupID: ageGroup.id,
        filename: `${pilot.categoryID}/${ageGroup.id}/${filename}`,
        mime: "application/pdf",
        license: "Generated pilot content",
        licenseURL: "",
        artist: "Kleurplaat Printer",
        source: "content-pack/generated-v1/pilot"
      });
    }
  }

  manifest.pages = pages;
  fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);

  console.log(`Generated ${pages.length} pilot PDFs`);
}

main();
