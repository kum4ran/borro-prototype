#!/usr/bin/env node
/**
 * figma_pull.mjs — pull the 13 Borro frames from Figma as specs + PNG renders.
 *
 * Usage:
 *   FIGMA_TOKEN=figd_xxx node tools/figma_pull.mjs
 *   # or put the token in .figma_token (git-ignored) and run without env var
 *
 * Outputs:
 *   design/figma/nodes.json        raw Figma node trees
 *   design/figma/spec/<id>.md      flattened, human-readable spec per frame
 *   design/figma/png/<id>.png      @2x render of each frame
 *   design/figma/montage.json      index used by the app's design gallery
 */
import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const FILE_KEY = "FRdguO9GdzR7f8EeSnaRNR";

// The 13 frames from the brief, in order.
const FRAMES = [
  { index: 1, node: "701-202" },
  { index: 2, node: "703-124" },
  { index: 3, node: "703-125" },
  { index: 4, node: "703-126" },
  { index: 5, node: "703-3017" },
  { index: 6, node: "708-169" },
  { index: 7, node: "703-2704" },
  { index: 8, node: "708-1741" },
  { index: 9, node: "701-1806" },
  { index: 10, node: "700-124" },
  { index: 11, node: "735-178" },
  { index: 12, node: "739-185" },
  { index: 13, node: "708-2690" }
];

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const OUT = path.join(ROOT, "design", "figma");

async function getToken() {
  if (process.env.FIGMA_TOKEN) return process.env.FIGMA_TOKEN.trim();
  try {
    const raw = await fs.readFile(path.join(ROOT, ".figma_token"), "utf8");
    const token = raw.trim();
    if (token) return token;
  } catch {}
  console.error(`\nNo Figma token found.

1. Open Figma in a browser and log in.
2. Click your avatar (top-left) -> Settings -> Security tab.
3. Under "Personal access tokens", click "Generate new token".
4. Name it "Borro prototype", scope: File content -> Read only.
5. Copy the figd_... token and save it:

     echo 'figd_YOUR_TOKEN' > .figma_token

   ...or run:  FIGMA_TOKEN=figd_YOUR_TOKEN node tools/figma_pull.mjs
`);
  process.exit(1);
}

async function figma(endpoint, token) {
  const url = `https://api.figma.com/v1${endpoint}`;
  const res = await fetch(url, { headers: { "X-Figma-Token": token } });
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    const hint =
      res.status === 403
        ? "\nThe token is valid but has no access to this file. Make sure the token was created by an account that can open the Borro file, and that the token scope includes 'File content: Read only'."
        : res.status === 401
        ? "\nThe token was rejected. Regenerate it in Figma -> Settings -> Security."
        : "";
    throw new Error(`Figma API ${res.status} on ${endpoint}${hint}\n${body.slice(0, 500)}`);
  }
  return res.json();
}

const hex = (c) => {
  if (!c) return null;
  const to = (v) => Math.round(Math.max(0, Math.min(1, v)) * 255).toString(16).padStart(2, "0");
  return `#${to(c.r)}${to(c.g)}${to(c.b)}${c.a !== undefined && c.a !== 1 ? to(c.a) : ""}`.toUpperCase();
};

function number(v, digits = 2) {
  if (v === undefined || v === null) return null;
  return Number(Number(v).toFixed(digits));
}

/** Turn a Figma node tree into a compact, LLM/spec-friendly markdown outline. */
function flatten(node, depth, lines, imageRefs) {
  if (!node) return;
  const pad = "  ".repeat(depth);
  const box = node.absoluteBoundingBox || node.absoluteRenderBounds || {};
  const parts = [`${node.type}`];
  if (node.name) parts.push(`"${node.name}"`);
  const w = number(box.width, 1);
  const h = number(box.height, 1);
  if (w !== null) parts.push(`${w}x${h}`);
  if (box.x !== undefined) parts.push(`@${number(box.x, 1)},${number(box.y, 1)}`);
  if (node.cornerRadius) parts.push(`r=${number(node.cornerRadius, 1)}`);
  if (node.layoutMode && node.layoutMode !== "NONE") {
    const pad4 = [node.paddingLeft, node.paddingTop, node.paddingRight, node.paddingBottom].map((p) => number(p ?? 0, 1)).join("/");
    parts.push(`layout=${node.layoutMode.toLowerCase()} pad=${pad4} gap=${number(node.itemSpacing ?? 0, 1)}${node.primaryAxisAlignItems ? ` align=${node.primaryAxisAlignItems.toLowerCase()}` : ""}${node.counterAxisAlignItems ? `/${node.counterAxisAlignItems.toLowerCase()}` : ""}`);
  }
  if (node.visible === false) parts.push("HIDDEN");

  lines.push(`${pad}- ${parts.join(" | ")}`);

  const detail = "  ".repeat(depth + 1);

  if (node.type === "TEXT") {
    const t = (node.characters ?? "").replace(/\n/g, "\\n");
    if (t) lines.push(`${detail}text: "${t}"`);
    const style = node.style || {};
    const bits = [];
    if (style.fontFamily) bits.push(`${style.fontFamily} ${style.fontPostScriptName ?? ""}`.trim());
    if (style.fontSize) bits.push(`${number(style.fontSize, 1)}px`);
    if (style.fontWeight) bits.push(`w${style.fontWeight}`);
    if (style.lineHeightPx) bits.push(`lh ${number(style.lineHeightPx, 1)}px`);
    if (style.letterSpacing) bits.push(`ls ${number(style.letterSpacing, 2)}px`);
    if (node.textAlignHorizontal) bits.push(`align=${node.textAlignHorizontal.toLowerCase()}`);
    if (bits.length) lines.push(`${detail}font: ${bits.join(" · ")}`);
  }

  // Fills
  for (const fill of node.fills || []) {
    if (fill.visible === false) continue;
    if (fill.type === "SOLID" && fill.color) {
      lines.push(`${detail}fill: ${hex(fill.color)}${fill.opacity !== undefined && fill.opacity !== 1 ? ` ${Math.round(fill.opacity * 100)}%` : ""}`);
    } else if (fill.type && fill.type.startsWith("GRADIENT")) {
      const stops = (fill.gradientStops || []).map((s) => `${hex(s.color)}@${number(s.position, 2)}`).join(" -> ");
      lines.push(`${detail}fill: ${fill.type} ${stops}`);
    } else if (fill.type === "IMAGE") {
      const ref = fill.imageRef || fill.imageHash;
      if (ref) {
        imageRefs.add(ref);
        lines.push(`${detail}fill: IMAGE ref=${ref}`);
      }
    }
  }
  if (node.strokes?.length) {
    const solid = node.strokes.find((s) => s.type === "SOLID");
    if (solid) lines.push(`${detail}stroke: ${hex(solid.color)} ${number(node.strokeWeight ?? 1, 1)}px`);
  }
  for (const effect of node.effects || []) {
    if (effect.visible === false) continue;
    if (effect.type === "DROP_SHADOW" || effect.type === "INNER_SHADOW") {
      lines.push(`${detail}${effect.type.toLowerCase()}: ${hex(effect.color)} ${number(effect.radius, 1)}px @${number(effect.offset?.x ?? 0, 1)},${number(effect.offset?.y ?? 0, 1)}`);
    } else if (effect.type === "LAYER_BLUR") {
      lines.push(`${detail}blur: ${number(effect.radius, 1)}px`);
    }
  }
  if (node.opacity !== undefined && node.opacity !== 1) lines.push(`${detail}opacity: ${number(node.opacity, 2)}`);

  for (const child of node.children || []) flatten(child, depth + 1, lines, imageRefs);
}

function collectImageRefs(node, refs = []) {
  for (const fill of node.fills || []) {
    if (fill.type === "IMAGE" && (fill.imageRef || fill.imageHash)) refs.push(fill.imageRef || fill.imageHash);
  }
  for (const child of node.children || []) collectImageRefs(child, refs);
  return refs;
}

function collectText(node, out = []) {
  if (node.type === "TEXT" && node.characters) out.push(node.characters.trim());
  for (const child of node.children || []) collectText(child, out);
  return out;
}

async function main() {
  const token = await getToken();
  await fs.mkdir(path.join(OUT, "spec"), { recursive: true });
  await fs.mkdir(path.join(OUT, "png"), { recursive: true });

  const ids = FRAMES.map((f) => f.node.replace("-", ":")).join(",");
  console.log(`Fetching ${FRAMES.length} frames from Figma...`);
  const nodesJson = await figma(`/files/${FILE_KEY}/nodes?ids=${encodeURIComponent(ids)}&geometry=paths`, token);
  await fs.writeFile(path.join(OUT, "nodes.json"), JSON.stringify(nodesJson, null, 2));

  const index = [];
  for (const frame of FRAMES) {
    const id = frame.node.replace("-", ":");
    const entry = nodesJson.nodes?.[id];
    if (!entry?.document) {
      console.warn(`  ! frame ${id} missing from response`);
      continue;
    }
    const doc = entry.document;
    const title = [doc.name, ...collectText(doc).slice(0, 3)].filter(Boolean).join(" · ");
    const lines = [
      `# Frame ${frame.index} — ${doc.name}`,
      ``,
      `Figma node: ${id}`,
      `File: ${FILE_KEY}`,
      `Size: ${Math.round(doc.absoluteBoundingBox?.width ?? 0)} x ${Math.round(doc.absoluteBoundingBox?.height ?? 0)}`,
      `Text content: ${collectText(doc).filter(Boolean).join(" | ")}`,
      ``,
      `## Node tree`,
      ``
    ];
    const imageRefs = new Set();
    flatten(doc, 0, lines, imageRefs);
    await fs.writeFile(path.join(OUT, "spec", `${frame.node}.md`), lines.join("\n") + "\n");

    index.push({
      index: frame.index,
      node: id,
      slug: frame.node,
      name: doc.name,
      title,
      width: doc.absoluteBoundingBox?.width ?? null,
      height: doc.absoluteBoundingBox?.height ?? null,
      imageRefs: [...new Set([...collectImageRefs(doc), ...imageRefs])],
      spec: `spec/${frame.node}.md`,
      png: `png/${frame.node}.png`
    });
    console.log(`  ✓ ${frame.index}. ${doc.name} (${id})`);
  }

  // Rendered PNGs
  console.log("Rendering PNGs @2x...");
  const imagesJson = await figma(`/images/${FILE_KEY}?ids=${encodeURIComponent(ids)}&format=png&scale=2`, token);
  for (const frame of FRAMES) {
    const id = frame.node.replace("-", ":");
    const url = imagesJson.images?.[id];
    if (!url) {
      console.warn(`  ! no render for ${id}`);
      continue;
    }
    const res = await fetch(url);
    if (!res.ok) {
      console.warn(`  ! download failed for ${id}: ${res.status}`);
      continue;
    }
    const buf = Buffer.from(await res.arrayBuffer());
    await fs.writeFile(path.join(OUT, "png", `${frame.node}.png`), buf);
    console.log(`  ✓ png/${frame.node}.png (${(buf.length / 1024).toFixed(0)} kB)`);
  }

  // Image fills (photos) referenced by the frames
  const allRefs = [...new Set(index.flatMap((f) => f.imageRefs))];
  if (allRefs.length) {
    console.log(`Fetching ${allRefs.length} image fills...`);
    try {
      await fs.mkdir(path.join(OUT, "images"), { recursive: true });
      const fillsJson = await figma(`/images/${FILE_KEY}?ids=${encodeURIComponent(allRefs.join(","))}&format=png&scale=2`, token);
      for (const [ref, url] of Object.entries(fillsJson.images || {})) {
        if (!url) continue;
        const res = await fetch(url);
        if (!res.ok) continue;
        const buf = Buffer.from(await res.arrayBuffer());
        await fs.writeFile(path.join(OUT, "images", `${ref}.png`), buf);
      }
      console.log(`  ✓ ${Object.keys(fillsJson.images || {}).length} images`);
    } catch (err) {
      console.warn("  ! image fill fetch failed:", err.message);
    }
  }

  await fs.writeFile(path.join(OUT, "montage.json"), JSON.stringify({ fileKey: FILE_KEY, frames: index }, null, 2));
  console.log(`\nDone. Specs in design/figma/spec, renders in design/figma/png.`);
}

main().catch((err) => {
  console.error("\nFailed:", err.message);
  process.exit(1);
});
