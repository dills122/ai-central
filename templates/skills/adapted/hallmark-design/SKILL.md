---
name: hallmark-design
description: Design, audit, redesign, or study distinctive user-facing pages without generic AI aesthetics. Use for intentional landing pages, portfolios, product marketing pages, visual redesigns, or design-DNA analysis of a screenshot or public URL.
---

# Hallmark Design

Adapted from `Nutlope/hallmark`, commit `aeb42fb354ff4efa36ab475773a082315a3af2ce`, MIT.

Use this as an opt-in creative-direction workflow. It complements the general frontend skills; it is not the default for ordinary application UI, dashboards, forms, or small component changes.

## Modes

- **Build:** create a new page whose structure and visual language fit the actual brief.
- **Audit:** inspect existing UI and return a ranked visual/UX punch list. Do not edit.
- **Redesign:** preserve routes, copy intent, information architecture, and existing ownership; change only the visual and interaction layer in scope.
- **Study:** extract portable design DNA from a user-provided screenshot or a public reference URL. Describe structure, type, colour, spacing, imagery, and interaction patterns. Never pixel-clone, copy a paid template, or reproduce protected artwork.

If the user supplies only a screenshot or URL, ask whether they want a study or a fresh build inspired by it.

## Before Editing

1. Identify whether this is a page or a component. For a component, follow the existing project system and verify relevant states; do not invent a page-wide visual system.
2. Inspect the repository for its framework, design tokens, type stack, spacing scale, component library, responsive conventions, and motion support.
3. State the files expected to change. Do not delete routes, production components, or asset directories without explicit confirmation.
4. Preserve the existing system unless the user explicitly asks for a new visual direction.

## Build Principles

- Choose the layout from the content and user task. Do not default to the same hero, three-card grid, testimonial strip, and CTA sequence.
- Make one clear visual direction: establish a deliberate type hierarchy, palette, spacing rhythm, image treatment, and interaction tone before implementation.
- Use named project tokens. Add a named token before using a new colour, font, radius, shadow, or spacing value; do not scatter raw values through components.
- Do not fabricate metrics, testimonials, customer logos, awards, pricing claims, or product screenshots. Use supplied facts, clearly labelled placeholders, or a structure that does not require invented proof.
- Prefer real content and assets. Do not draw fake browser, phone, IDE, or code-window chrome around content.
- Avoid generic AI visual tells: arbitrary purple/indigo, decorative gradients or blobs, excessive rounded cards, uniform card grids, shadow-heavy surfaces, and ornamental motion without purpose.
- Keep headings upright; use hierarchy, weight, scale, colour, or decoration—not italic display text—for emphasis.

## Quality Floor

- Verify 320 px, 375 px, 414 px, and desktop/tablet widths. No horizontal overflow; long words, images, grids, and buttons must remain contained.
- Use semantic HTML and visible keyboard focus. Interactive UI includes appropriate default, hover, focus, active, disabled, loading, error, empty, and success states when relevant.
- Respect `prefers-reduced-motion`; motion must clarify state or hierarchy, not just decorate.
- Check contrast, labels, keyboard access, and tap targets.
- For a design audit, rank findings by user impact and cite files or visible elements. For an implementation, verify in a real browser when available.

## Final Review

Before handing off, assess:

1. Does the page's structure fit this specific content rather than a familiar template?
2. Is the hierarchy obvious at a glance and in the narrow layout?
3. Are tokens, states, accessibility, and responsive behavior implemented rather than merely described?
4. Did we avoid invented proof and decorative imitation UI?
5. Would a second page for a different brief plausibly look structurally different?
