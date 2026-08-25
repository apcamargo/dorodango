#!/usr/bin/env node

import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { access, mkdtemp, mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join, relative } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const root = fileURLToPath(new URL("../../..", import.meta.url));
const check = process.argv.includes("--check");
const knownArgs = new Set(["--check"]);
for (const arg of process.argv.slice(2)) {
  if (!knownArgs.has(arg)) throw new Error(`unknown argument: ${arg}`);
}

const corners = ["top-left", "top-right", "bottom-right", "bottom-left"];
const nextCw = {
  "top-left": "top-right",
  "top-right": "bottom-right",
  "bottom-right": "bottom-left",
  "bottom-left": "top-left",
};
const nextCcw = {
  "top-left": "bottom-left",
  "top-right": "top-left",
  "bottom-right": "top-right",
  "bottom-left": "bottom-right",
};
const sideCw = {
  "top-left": "top",
  "top-right": "right",
  "bottom-right": "bottom",
  "bottom-left": "left",
};
const sideCcw = {
  "top-left": "left",
  "top-right": "top",
  "bottom-right": "right",
  "bottom-left": "bottom",
};
const geometry = {
  "top-left": {
    edgeIn: [0, 1],
    edgeOut: [1, 0],
    base0: Math.PI,
    base1: (3 * Math.PI) / 2,
  },
  "top-right": {
    edgeIn: [-1, 0],
    edgeOut: [0, 1],
    base0: -Math.PI / 2,
    base1: 0,
  },
  "bottom-right": {
    edgeIn: [0, -1],
    edgeOut: [-1, 0],
    base0: 0,
    base1: Math.PI / 2,
  },
  "bottom-left": {
    edgeIn: [1, 0],
    edgeOut: [0, -1],
    base0: Math.PI / 2,
    base1: Math.PI,
  },
};

const add = ([ax, ay], [bx, by]) => [ax + bx, ay + by];
const sub = ([ax, ay], [bx, by]) => [ax - bx, ay - by];
const scale = ([x, y], factor) => [x * factor, y * factor];
const distance = ([ax, ay], [bx, by]) => Math.hypot(ax - bx, ay - by);
const cornerPoints = (width, height) => ({
  "top-left": [0, 0],
  "top-right": [width, 0],
  "bottom-right": [width, height],
  "bottom-left": [0, height],
});

function fixed(value) {
  const rounded = Number(value.toFixed(4));
  return String(Object.is(rounded, -0) ? 0 : rounded);
}

function resolveCorners(value, fallback = 0) {
  if (typeof value === "number") {
    return Object.fromEntries(corners.map((corner) => [corner, value]));
  }
  return Object.fromEntries(corners.map((corner) => [corner, value?.[corner] ?? fallback]));
}

function allocateBudgets(radii, sideLengths, perEdge) {
  const budgets = Object.fromEntries(corners.map((corner) => [corner, { cw: -1, ccw: -1 }]));
  const ordered = [...corners].sort((a, b) => radii[b] - radii[a]);
  for (const corner of ordered) {
    const radius = radii[corner];
    const term = (side, adjacent, adjacentField) => {
      const adjacentRadius = radii[adjacent];
      if (radius <= 0 && adjacentRadius <= 0) return 0;
      const adjacentBudget = budgets[adjacent][adjacentField];
      if (adjacentBudget >= 0) return sideLengths[side] - adjacentBudget;
      return (radius / (radius + adjacentRadius)) * sideLengths[side];
    };
    const cw = term(sideCw[corner], nextCw[corner], "ccw");
    const ccw = term(sideCcw[corner], nextCcw[corner], "cw");
    const shared = Math.min(cw, ccw);
    budgets[corner] = perEdge ? { cw, ccw } : { cw: shared, ccw: shared };
  }
  return budgets;
}

function cornerParams(radius, smoothing, budget, preserveSmoothing) {
  if (radius <= 0) {
    return { a: 0, b: 0, p: 0, angleAlpha: Math.PI / 4 };
  }
  let effective = Math.max(0, Math.min(1, smoothing));
  let p = (1 + effective) * radius;
  if (!preserveSmoothing) {
    effective = Math.min(effective, budget / radius - 1);
    p = Math.min(p, budget);
  }
  const arcMeasure = (Math.PI / 2) * (1 - effective);
  const arcLength = Math.sin(arcMeasure / 2) * radius * Math.SQRT2;
  const angleAlpha = (Math.PI / 2 - arcMeasure) / 2;
  const p3ToP4 = radius * Math.tan(angleAlpha / 2);
  const angleBeta = (Math.PI / 4) * effective;
  const c = p3ToP4 * Math.cos(angleBeta);
  const d = c * Math.tan(angleBeta);
  let b = (p - arcLength - c - d) / 3;
  let a = 2 * b;
  if (preserveSmoothing && p > budget) {
    const p1ToP3Max = budget - d - arcLength - c;
    const minA = p1ToP3Max / 6;
    const maxB = p1ToP3Max - minA;
    b = Math.min(b, maxB);
    a = p1ToP3Max - b;
    p = budget;
  }
  return { a, b, p, angleAlpha };
}

function sideLengths(points) {
  return {
    top: Math.abs(points["top-right"][0] - points["top-left"][0]),
    right: Math.abs(points["bottom-right"][1] - points["top-right"][1]),
    bottom: Math.abs(points["bottom-right"][0] - points["bottom-left"][0]),
    left: Math.abs(points["bottom-left"][1] - points["top-left"][1]),
  };
}

function piece(corner, point, radius, paramsIn, paramsOut, splitAngle = null) {
  const { edgeIn, edgeOut, base0, base1 } = geometry[corner];
  if (radius <= 0) {
    const sharp = { type: "L", to: point };
    return {
      start: point,
      mid: point,
      end: point,
      full: [sharp],
      first: [sharp],
      second: [],
    };
  }
  const center = add(point, scale(add(edgeIn, edgeOut), radius));
  const angle0 = base0 + paramsIn.angleAlpha;
  const angle1 = base1 - paramsOut.angleAlpha;
  const onArc = (angle) => [
    center[0] + radius * Math.cos(angle),
    center[1] + radius * Math.sin(angle),
  ];
  const start = add(point, scale(edgeIn, paramsIn.p));
  const end = add(point, scale(edgeOut, paramsOut.p));
  const leadIn = {
    type: "C",
    c1: sub(start, scale(edgeIn, paramsIn.a)),
    c2: sub(start, scale(edgeIn, paramsIn.a + paramsIn.b)),
    to: onArc(angle0),
  };
  const leadOut = {
    type: "C",
    c1: sub(end, scale(edgeOut, paramsOut.a + paramsOut.b)),
    c2: sub(end, scale(edgeOut, paramsOut.a)),
    to: end,
  };
  const arc = (from, to) => ({
    type: "A",
    radius,
    large: 0,
    sweep: 1,
    to: onArc(to),
    from: onArc(from),
  });
  const full = [leadIn, arc(angle0, angle1), leadOut];
  if (splitAngle === null) {
    return { start, mid: point, end, full, first: [], second: [] };
  }
  const angleMid = Math.max(angle0, Math.min(angle1, splitAngle));
  return {
    start,
    mid: onArc(angleMid),
    end,
    full,
    first: [leadIn, arc(angle0, angleMid)],
    second: [arc(angleMid, angle1), leadOut],
  };
}

function buildPieces({ points, radii, smoothing, preserveSmoothing, perEdge }) {
  const smoothings = resolveCorners(smoothing);
  const budgets = allocateBudgets(radii, sideLengths(points), perEdge);
  return Object.fromEntries(
    corners.map((corner) => [
      corner,
      piece(
        corner,
        points[corner],
        radii[corner],
        cornerParams(radii[corner], smoothings[corner], budgets[corner].ccw, preserveSmoothing),
        cornerParams(radii[corner], smoothings[corner], budgets[corner].cw, preserveSmoothing),
      ),
    ]),
  );
}

function closedCommands(options) {
  const pieces = buildPieces(options);
  const order = ["top-right", "bottom-right", "bottom-left", "top-left"];
  const commands = [{ type: "M", to: pieces[order[0]].start }];
  for (const [index, corner] of order.entries()) {
    if (index > 0) commands.push({ type: "L", to: pieces[corner].start });
    commands.push(...pieces[corner].full);
  }
  commands.push({ type: "Z" });
  return commands;
}

function reverseSegments(segments) {
  return [...segments].reverse().map((segment) => {
    if (segment.type === "C") {
      return { type: "C", c1: segment.c2, c2: segment.c1, to: segment.from };
    }
    if (segment.type === "A") {
      return { ...segment, sweep: segment.sweep ? 0 : 1, to: segment.from };
    }
    return { type: "L", to: segment.from };
  });
}

function attachFrom(commands) {
  let current = null;
  let start = null;
  return commands.map((command) => {
    if (command.type === "M") {
      current = command.to;
      start = command.to;
      return command;
    }
    if (command.type === "Z") {
      current = start;
      return command;
    }
    const withFrom = { ...command, from: current };
    current = command.to;
    return withFrom;
  });
}

function pathData(rawCommands) {
  const commands = attachFrom(rawCommands);
  return commands
    .map((command) => {
      if (command.type === "M" || command.type === "L") {
        return `${command.type} ${fixed(command.to[0])} ${fixed(command.to[1])}`;
      }
      if (command.type === "C") {
        return `C ${fixed(command.c1[0])} ${fixed(command.c1[1])} ${fixed(command.c2[0])} ${fixed(command.c2[1])} ${fixed(command.to[0])} ${fixed(command.to[1])}`;
      }
      if (command.type === "A") {
        return `A ${fixed(command.radius)} ${fixed(command.radius)} 0 ${command.large} ${command.sweep} ${fixed(command.to[0])} ${fixed(command.to[1])}`;
      }
      return "Z";
    })
    .join(" ");
}

function translateCommands(commands, dx, dy) {
  const move = ([x, y]) => [x + dx, y + dy];
  return commands.map((command) => {
    if (command.type === "Z") return command;
    const translated = { ...command, to: move(command.to) };
    if (command.c1) translated.c1 = move(command.c1);
    if (command.c2) translated.c2 = move(command.c2);
    if (command.from) translated.from = move(command.from);
    return translated;
  });
}

function svg(width, height, elements) {
  return `<svg xmlns="http://www.w3.org/2000/svg"\n     width="${fixed(width)}" height="${fixed(height)}" viewBox="0 0 ${fixed(width)} ${fixed(height)}">\n${elements.map((element) => `  ${element}`).join("\n")}\n</svg>\n`;
}

function baseRadii(caseData, extra = 0) {
  const maximum = Math.min(caseData.width, caseData.height) / 2 + extra;
  return Object.fromEntries(
    Object.entries(resolveCorners(caseData.radius)).map(([corner, radius]) => [
      corner,
      Math.max(0, Math.min(radius, maximum)),
    ]),
  );
}

function fillFixture(caseData, pathOverride = null) {
  const commands = closedCommands({
    points: cornerPoints(caseData.width, caseData.height),
    radii: baseRadii(caseData),
    smoothing: caseData.smoothing,
    preserveSmoothing: caseData.preserveSmoothing ?? false,
    perEdge: true,
  });
  const d = pathOverride ?? pathData(commands);
  return svg(caseData.width, caseData.height, [`<path d="${d}" fill="black"/>`]);
}

function uniformStrokeFixture(caseData) {
  const half = caseData.stroke.thickness / 2;
  const outer = baseRadii(caseData, half);
  const middle = Object.fromEntries(
    corners.map((corner) => [corner, Math.max(0, outer[corner] - half)]),
  );
  const commands = translateCommands(
    closedCommands({
      points: cornerPoints(caseData.width, caseData.height),
      radii: middle,
      smoothing: caseData.smoothing,
      preserveSmoothing: caseData.preserveSmoothing ?? false,
      perEdge: true,
    }),
    half,
    half,
  );
  const width = caseData.width + 2 * half;
  const height = caseData.height + 2 * half;
  const path = `<path d="${pathData(commands)}" fill="none" stroke="black" stroke-width="${fixed(caseData.stroke.thickness)}"/>`;
  return { svg: svg(width, height, [path]), imageWidth: width, imageHeight: height };
}

function thickRingFixture(caseData) {
  const half = caseData.stroke.thickness / 2;
  const outerRadii = baseRadii(caseData, half);
  const innerRadii = Object.fromEntries(
    corners.map((corner) => [corner, Math.max(0, outerRadii[corner] - 2 * half)]),
  );
  const outerPoints = Object.fromEntries(
    Object.entries(cornerPoints(caseData.width, caseData.height)).map(([corner, point]) => {
      const { edgeIn, edgeOut } = geometry[corner];
      return [corner, sub(point, scale(add(edgeIn, edgeOut), half))];
    }),
  );
  const innerPoints = Object.fromEntries(
    Object.entries(cornerPoints(caseData.width, caseData.height)).map(([corner, point]) => {
      const { edgeIn, edgeOut } = geometry[corner];
      return [corner, add(point, scale(add(edgeIn, edgeOut), half))];
    }),
  );
  const outer = translateCommands(
    closedCommands({
      points: outerPoints,
      radii: outerRadii,
      smoothing: caseData.smoothing,
      preserveSmoothing: caseData.preserveSmoothing ?? false,
      perEdge: true,
    }),
    half,
    half,
  );
  const inner = translateCommands(
    closedCommands({
      points: innerPoints,
      radii: innerRadii,
      smoothing: caseData.smoothing,
      preserveSmoothing: caseData.preserveSmoothing ?? false,
      perEdge: true,
    }),
    half,
    half,
  );
  const width = caseData.width + 2 * half;
  const height = caseData.height + 2 * half;
  const path = `<path d="${pathData(outer)} ${pathData(inner)}" fill="black" fill-rule="evenodd"/>`;
  return { svg: svg(width, height, [path]), imageWidth: width, imageHeight: height };
}

function topStrokeFixture(caseData) {
  const half = caseData.stroke.thickness / 2;
  const outerRadii = baseRadii(caseData);
  const innerRadii = Object.fromEntries(
    corners.map((corner) => [corner, Math.max(0, outerRadii[corner] - 2 * half)]),
  );
  const outerPoints = {};
  const innerPoints = {};
  for (const [corner, point] of Object.entries(cornerPoints(caseData.width, caseData.height))) {
    const { edgeIn, edgeOut } = geometry[corner];
    outerPoints[corner] = sub(point, scale(add(edgeIn, edgeOut), half));
    innerPoints[corner] = add(point, scale(add(edgeIn, edgeOut), half));
  }
  const makeSplitPieces = (points, radii) => {
    const smoothings = resolveCorners(caseData.smoothing);
    const budgets = allocateBudgets(radii, sideLengths(points), true);
    return Object.fromEntries(
      corners.map((corner) => {
        const { base0 } = geometry[corner];
        return [
          corner,
          piece(
            corner,
            points[corner],
            radii[corner],
            cornerParams(radii[corner], smoothings[corner], budgets[corner].ccw, false),
            cornerParams(radii[corner], smoothings[corner], budgets[corner].cw, false),
            base0 + Math.PI / 4,
          ),
        ];
      }),
    );
  };
  const outer = makeSplitPieces(outerPoints, outerRadii);
  const inner = makeSplitPieces(innerPoints, innerRadii);
  const raw = [
    { type: "M", to: inner["top-left"].end },
    ...reverseSegments(
      attachFrom([{ type: "M", to: inner["top-left"].mid }, ...inner["top-left"].second]).slice(1),
    ),
    { type: "L", to: outer["top-left"].mid },
    ...outer["top-left"].second,
    { type: "L", to: outer["top-right"].start },
    ...outer["top-right"].first,
    { type: "L", to: inner["top-right"].mid },
    ...reverseSegments(
      attachFrom([{ type: "M", to: inner["top-right"].start }, ...inner["top-right"].first]).slice(
        1,
      ),
    ),
    { type: "L", to: inner["top-left"].end },
    { type: "Z" },
  ];
  const commands = translateCommands(raw, half, half);
  const width = caseData.width + 2 * half;
  const height = caseData.height + 2 * half;
  return {
    svg: svg(width, height, [`<path d="${pathData(commands)}" fill="black"/>`]),
    imageWidth: width,
    imageHeight: height,
  };
}

function parsePath(data) {
  const tokens = data.match(/[A-Za-z]|[-+]?(?:\d*\.)?\d+(?:e[-+]?\d+)?/gi) ?? [];
  const commands = [];
  let index = 0;
  let current = [0, 0];
  let start = [0, 0];
  while (index < tokens.length) {
    const code = tokens[index++];
    const relativeCommand = code === code.toLowerCase();
    const command = code.toUpperCase();
    const number = () => Number(tokens[index++]);
    const point = () => {
      const value = [number(), number()];
      return relativeCommand ? add(current, value) : value;
    };
    if (command === "M" || command === "L") {
      const to = point();
      commands.push({ type: command, to });
      current = to;
      if (command === "M") start = to;
    } else if (command === "C") {
      const c1 = point();
      const c2 = point();
      const to = point();
      commands.push({ type: "C", from: current, c1, c2, to });
      current = to;
    } else if (command === "A") {
      const radiusX = number();
      const radiusY = number();
      const rotation = number();
      const large = number();
      const sweep = number();
      const to = point();
      commands.push({
        type: "A",
        from: current,
        radius: radiusX,
        radiusY,
        rotation,
        large,
        sweep,
        to,
      });
      current = to;
    } else if (command === "Z") {
      commands.push({ type: "Z", from: current, to: start });
      current = start;
    } else {
      throw new Error(`unsupported SVG path command ${code}`);
    }
  }
  return commands;
}

function arcCenter(command) {
  const [x1, y1] = command.from;
  const [x2, y2] = command.to;
  let radius = Math.max(command.radius, command.radiusY ?? command.radius);
  const xPrime = (x1 - x2) / 2;
  const yPrime = (y1 - y2) / 2;
  const lengthSquared = xPrime * xPrime + yPrime * yPrime;
  if (lengthSquared === 0) return null;
  radius = Math.max(radius, Math.sqrt(lengthSquared));
  const sign = command.large === command.sweep ? -1 : 1;
  const coefficient =
    sign * Math.sqrt(Math.max(0, (radius * radius - lengthSquared) / lengthSquared));
  const center = [(x1 + x2) / 2 + coefficient * yPrime, (y1 + y2) / 2 - coefficient * xPrime];
  let start = Math.atan2(y1 - center[1], x1 - center[0]);
  let delta = Math.atan2(y2 - center[1], x2 - center[0]) - start;
  if (command.sweep && delta < 0) delta += 2 * Math.PI;
  if (!command.sweep && delta > 0) delta -= 2 * Math.PI;
  return { center, radius, start, delta };
}

function flattenPath(data, steps = 48) {
  const commands = parsePath(data);
  const points = [];
  let current = [0, 0];
  let start = [0, 0];
  for (const command of commands) {
    if (command.type === "M") {
      current = command.to;
      start = command.to;
      points.push(current);
    } else if (command.type === "L" || command.type === "Z") {
      current = command.type === "Z" ? start : command.to;
      points.push(current);
    } else if (command.type === "C") {
      for (let step = 1; step <= steps; step++) {
        const t = step / steps;
        const u = 1 - t;
        points.push([
          u ** 3 * current[0] +
            3 * u * u * t * command.c1[0] +
            3 * u * t * t * command.c2[0] +
            t ** 3 * command.to[0],
          u ** 3 * current[1] +
            3 * u * u * t * command.c1[1] +
            3 * u * t * t * command.c2[1] +
            t ** 3 * command.to[1],
        ]);
      }
      current = command.to;
    } else if (command.type === "A") {
      const arc = arcCenter(command);
      if (arc === null) {
        current = command.to;
        points.push(current);
        continue;
      }
      for (let step = 1; step <= steps; step++) {
        const angle = arc.start + arc.delta * (step / steps);
        points.push([
          arc.center[0] + arc.radius * Math.cos(angle),
          arc.center[1] + arc.radius * Math.sin(angle),
        ]);
      }
      current = command.to;
    }
  }
  return points;
}

function distanceToSegment(point, start, end) {
  const dx = end[0] - start[0];
  const dy = end[1] - start[1];
  const lengthSquared = dx * dx + dy * dy;
  const t =
    lengthSquared === 0
      ? 0
      : Math.max(
          0,
          Math.min(1, ((point[0] - start[0]) * dx + (point[1] - start[1]) * dy) / lengthSquared),
        );
  return distance(point, [start[0] + t * dx, start[1] + t * dy]);
}

function pathDeviation(left, right) {
  const a = flattenPath(left);
  const b = flattenPath(right);
  const oneWay = (from, to) =>
    Math.max(
      ...from.map((point) => {
        let nearest = Infinity;
        for (let index = 0; index + 1 < to.length; index++) {
          nearest = Math.min(nearest, distanceToSegment(point, to[index], to[index + 1]));
        }
        return nearest;
      }),
    );
  return Math.max(oneWay(a, b), oneWay(b, a));
}

function assertPathsNear(label, actual, expected, tolerance = 0.03) {
  const deviation = pathDeviation(actual, expected);
  if (deviation > tolerance) {
    throw new Error(`${label}: path deviation ${deviation} exceeds ${tolerance}`);
  }
}

async function fetchPackage(source, temporary, cache) {
  if (cache.has(source.package)) return cache.get(source.package);
  const response = await fetch(source.tarball);
  if (!response.ok) throw new Error(`failed to download ${source.tarball}: ${response.status}`);
  const archive = Buffer.from(await response.arrayBuffer());
  const digest = createHash("sha256").update(archive).digest("hex");
  if (digest !== source.sha256) {
    throw new Error(`${source.package}: SHA-256 ${digest}, expected ${source.sha256}`);
  }
  const packageRoot = join(temporary, source.package.replaceAll("/", "-"));
  const archivePath = `${packageRoot}.tgz`;
  await mkdir(packageRoot, { recursive: true });
  await writeFile(archivePath, archive);
  execFileSync("tar", ["-xzf", archivePath, "-C", packageRoot]);
  const loaded = { root: join(packageRoot, "package") };
  const metadata = await readJson(join(loaded.root, "package.json"));
  if (metadata.name !== source.package || metadata.version !== source.version) {
    throw new Error(
      `${source.package}: archive identifies itself as ${metadata.name}@${metadata.version}`,
    );
  }
  cache.set(source.package, loaded);
  return loaded;
}

function typstValue(value, indent = 0) {
  if (typeof value === "number") return `${fixed(value * 100)}%`;
  if (typeof value === "boolean") return String(value);
  if (typeof value === "string") return value;
  const pad = " ".repeat(indent);
  const inner = " ".repeat(indent + 2);
  const entries = Object.entries(value)
    .map(([key, entry]) => `${inner}${key}: ${typstValue(entry, indent + 2)},`)
    .join("\n");
  return `(\n${entries}\n${pad})`;
}

function typstRadius(value, indent = 0) {
  if (typeof value === "number") return `${fixed(value)}pt`;
  const pad = " ".repeat(indent);
  const inner = " ".repeat(indent + 2);
  const entries = Object.entries(value)
    .map(([key, entry]) => `${inner}${key}: ${fixed(entry)}pt,`)
    .join("\n");
  return `(\n${entries}\n${pad})`;
}

function typstArguments(caseData, indent = 4) {
  const pad = " ".repeat(indent);
  const lines = [
    `${pad}width: ${fixed(caseData.width)}pt,`,
    `${pad}height: ${fixed(caseData.height)}pt,`,
    `${pad}radius: ${typstRadius(caseData.radius, indent)},`,
    `${pad}smoothing: ${typstValue(caseData.smoothing, indent)},`,
  ];
  if (caseData.preserveSmoothing) lines.push(`${pad}preserve-smoothing: true,`);
  if (caseData.perEdgeSmoothing) lines.push(`${pad}per-edge-smoothing: true,`);
  if (caseData.fill) lines.push(`${pad}fill: ${caseData.fill},`);
  if (caseData.stroke?.kind === "uniform") {
    lines.push(`${pad}stroke: ${fixed(caseData.stroke.thickness)}pt + ${caseData.stroke.paint},`);
  } else if (caseData.stroke?.kind === "top") {
    lines.push(
      `${pad}stroke: (top: ${fixed(caseData.stroke.thickness)}pt + ${caseData.stroke.paint}),`,
    );
  }
  return lines.join("\n");
}

function casesTyp(cases, generatedBy) {
  const entries = cases
    .map(
      (caseData) =>
        `  (\n    id: "${caseData.id}",\n    width: ${fixed(caseData.imageWidth ?? caseData.width)}pt,\n    height: ${fixed(caseData.imageHeight ?? caseData.height)}pt,\n    args: arguments(\n${typstArguments(caseData, 6)}\n    ),\n    reference: arguments(\n      id: "${caseData.id}",\n      width: ${fixed(caseData.imageWidth ?? caseData.width)}pt,\n      height: ${fixed(caseData.imageHeight ?? caseData.height)}pt,\n    ),\n  ),`,
    )
    .join("\n");
  return `// Generated by ${generatedBy}; do not edit by hand.\n#let cases = (\n${entries}\n)\n`;
}

async function readJson(path) {
  return JSON.parse(await readFile(path, "utf8"));
}

async function buildOutputs(temporary) {
  const outputs = new Map();
  const packageCache = new Map();
  const scriptName = "tests/_helpers/scripts/generate-smoothing-fixtures.mjs";

  const figmaDirectory = join(root, "tests/smoothing/figma-reference");
  const figmaManifest = await readJson(join(figmaDirectory, "fixtures.json"));
  const figmaPackage = await fetchPackage(figmaManifest.source, temporary, packageCache);
  const { getSvgPath } = await import(pathToFileURL(join(figmaPackage.root, "dist/index.js")));
  const figmaCases = figmaManifest.fixtures.map((fixture) => {
    const options = fixture.options;
    const radius = options.cornerRadius ?? {
      "top-left": options.topLeftCornerRadius,
      "top-right": options.topRightCornerRadius,
      "bottom-right": options.bottomRightCornerRadius,
      "bottom-left": options.bottomLeftCornerRadius,
    };
    return {
      id: fixture.id,
      width: options.width,
      height: options.height,
      radius,
      smoothing: options.cornerSmoothing,
      preserveSmoothing: options.preserveSmoothing ?? false,
      fill: "black",
      path: getSvgPath(options),
    };
  });
  for (const caseData of figmaCases) {
    outputs.set(
      join(figmaDirectory, "fixtures", `${caseData.id}.svg`),
      fillFixture(caseData, caseData.path),
    );
  }
  outputs.set(join(figmaDirectory, "cases.typ"), casesTyp(figmaCases, scriptName));

  for (const caseData of figmaCases) {
    const spec = pathData(
      closedCommands({
        points: cornerPoints(caseData.width, caseData.height),
        radii: baseRadii(caseData),
        smoothing: caseData.smoothing,
        preserveSmoothing: caseData.preserveSmoothing,
        perEdge: false,
      }),
    );
    assertPathsNear(`figma/${caseData.id}`, spec, caseData.path);
  }

  const perEdgeDirectory = join(root, "tests/smoothing/per-edge-reference");
  const perEdgeManifest = await readJson(join(perEdgeDirectory, "fixtures.json"));
  const lissePackage = await fetchPackage(perEdgeManifest.sources.lisse, temporary, packageCache);
  const { generatePath } = await import(pathToFileURL(join(lissePackage.root, "dist/path.js")));
  const perEdgeCases = perEdgeManifest.fixtures.map((fixture) => ({
    ...fixture,
    perEdgeSmoothing: true,
    fill: "black",
  }));
  for (const caseData of perEdgeCases) {
    const specPath = pathData(
      closedCommands({
        points: cornerPoints(caseData.width, caseData.height),
        radii: baseRadii(caseData),
        smoothing: caseData.smoothing,
        preserveSmoothing: caseData.preserveSmoothing ?? false,
        perEdge: true,
      }),
    );
    let path = specPath;
    if (caseData.oracle === "lisse") {
      path = generatePath(caseData.width, caseData.height, {
        radius: caseData.radius,
        smoothing: caseData.smoothing,
        preserveSmoothing: false,
        curve: "squircle",
      });
      assertPathsNear(`lisse/${caseData.id}`, specPath, path, 0.05);
    }
    outputs.set(
      join(perEdgeDirectory, "fixtures", `${caseData.id}.svg`),
      fillFixture(caseData, path),
    );
  }
  outputs.set(join(perEdgeDirectory, "cases.typ"), casesTyp(perEdgeCases, scriptName));

  const inertDirectory = join(root, "tests/smoothing/per-edge-inert");
  const inertManifest = await readJson(join(inertDirectory, "fixtures.json"));
  outputs.set(join(inertDirectory, "cases.typ"), casesTyp(inertManifest.fixtures, scriptName));

  const strokeDirectory = join(root, "tests/smoothing/per-edge-strokes");
  const strokeManifest = await readJson(join(strokeDirectory, "fixtures.json"));
  const strokeCases = strokeManifest.fixtures.map((fixture) => ({
    ...fixture,
    perEdgeSmoothing: true,
  }));
  for (const caseData of strokeCases) {
    let rendered;
    if (caseData.stroke.kind === "uniform" && !caseData.stroke.ring) {
      rendered = uniformStrokeFixture(caseData);
    } else if (caseData.stroke.kind === "top") {
      rendered = topStrokeFixture(caseData);
    } else {
      rendered = thickRingFixture(caseData);
    }
    caseData.imageWidth = rendered.imageWidth;
    caseData.imageHeight = rendered.imageHeight;
    outputs.set(join(strokeDirectory, "fixtures", `${caseData.id}.svg`), rendered.svg);
  }
  outputs.set(join(strokeDirectory, "cases.typ"), casesTyp(strokeCases, scriptName));
  return outputs;
}

async function main() {
  const temporary = await mkdtemp(join(tmpdir(), "dorodango-fixtures-"));
  try {
    const outputs = await buildOutputs(temporary);
    const mismatches = [];
    for (const [path, content] of outputs) {
      if (check) {
        try {
          await access(path);
          const existing = await readFile(path, "utf8");
          if (existing !== content) mismatches.push(relative(root, path));
        } catch {
          mismatches.push(relative(root, path));
        }
      } else {
        await mkdir(dirname(path), { recursive: true });
        await writeFile(path, content);
      }
    }
    if (mismatches.length > 0) {
      throw new Error(`generated fixtures differ:\n${mismatches.join("\n")}`);
    }
    console.log(check ? "smoothing fixtures are current" : "generated smoothing fixtures");
  } finally {
    await rm(temporary, { recursive: true, force: true });
  }
}

await main();
