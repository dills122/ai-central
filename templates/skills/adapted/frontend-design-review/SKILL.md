---
name: frontend-design-review
description: Reviews and improves frontend interfaces for visual craft, UX clarity, accessibility, responsive behavior, interaction states, content hierarchy, and implementation quality. Use when building, redesigning, auditing, or polishing user-facing UI.
---

# Frontend Design Review

Adapted from `pbakaus/impeccable`, commit `1d5d745823aae7019044e8b0a621af4366dae224`, Apache-2.0.

Use this skill when the task involves a website, app shell, dashboard, form, landing page, component, empty state, onboarding flow, settings page, visual system, or frontend interaction.

## Review Axes

Evaluate the interface across these axes:

- Purpose: the primary user action is obvious and not diluted by decoration.
- Information architecture: groups, labels, navigation, and hierarchy match the user workflow.
- Visual hierarchy: typography, spacing, contrast, and layout guide the eye deliberately.
- Interaction quality: hover, focus, active, loading, empty, disabled, and error states are present.
- Accessibility: semantic HTML, keyboard navigation, focus visibility, labels, contrast, and reduced-motion behavior are handled.
- Responsiveness: layouts work at mobile, tablet, laptop, and wide desktop sizes.
- Performance: images, animations, and rendering choices are appropriate for the page.
- Fit: the visual language matches the product domain rather than defaulting to generic AI aesthetics.

## Workflow

1. Identify the target user, task, and context.
2. Inspect the current UI or implementation.
3. List concrete issues, ordered by user impact.
4. Make focused changes that improve the actual experience.
5. Verify in a real browser when possible.
6. Check responsive breakpoints and important states.
7. Report what changed and any remaining risk.

## Implementation Guidance

- Prefer existing design tokens, components, icons, and layout primitives.
- Keep UI dense and scannable for operational tools.
- Use cards only for repeated items, modals, or genuinely framed tools.
- Avoid decorative gradients, blobs, and purely atmospheric visuals when the user needs clarity.
- Do not use in-app instructional text to explain obvious controls.
- Make controls complete: inputs have labels, buttons have states, forms have validation, and lists have empty states.
- Keep text within containers at all viewport sizes.
- Use real assets or generated bitmap assets when a website or app needs visual content.

## Browser Verification

When a local frontend is available:

- open the page in a browser
- check console errors
- inspect at desktop and mobile widths
- verify text does not overlap or overflow
- verify loading, empty, error, and interaction states
- capture a screenshot or summarize visual evidence

## Output

For reviews, lead with issues ordered by severity and include file references when available.

For implementation tasks, make the changes, verify them, and summarize the behavioral and visual result.
