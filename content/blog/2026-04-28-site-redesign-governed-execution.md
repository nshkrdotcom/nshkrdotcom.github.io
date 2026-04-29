---
title: "New Site Theme: Darker, Sharper, More Honest"
date: 2026-04-28
draft: false
tags: ["website", "design", "governed-execution", "platform"]
summary: "A redesign of NSHkr.com around the real shape of the stack: typed boundaries, durable execution truth, operator proof, and a few things the gremlins say not to name yet."
---

## New paint, less pretending

The site has a new theme.

The old version was useful, but it still had the posture of a project catalog:
cards, repo counts, a clean dark background, and enough polish to say "yes,
there is real work here." That was fine for the previous phase.

That shape had run its course.

The current work is more structural. Repository count matters less than role
clarity now. Some repos are public surfaces. Some are neutral operational
substrate. Some compile authority. Some carry durable lower truth. Some are
allowed to touch raw runtime mechanics, and most are not.

So the site now looks more like a control surface than a brochure.

## The new visual language

The redesign is built around a few constraints:

- dark background, but not the generic blue-black SaaS kind
- Space Grotesk for display text
- JetBrains Mono for labels, chips, contracts, and counters
- cyan, violet, and amber as signals instead of decoration
- thin borders, compact cards, and less rounded everything
- grid texture in the background, because this is a system map now

The homepage now reads top-down as a stack explanation:

- AppKit is the northbound product boundary.
- Mezzanine is the reusable operational substrate.
- OuterBrain and Citadel split semantic context from deterministic authority.
- Jido Integration is the durable Spine.
- Execution Plane is the hazmat runtime layer.
- Stack Lab and AITrace exist because proof needs to be executable, not vibes.

That last sentence is doing more work than it looks like.

## Why the theme changed

The visual change is really a vocabulary change.

A lot of AI software presents itself as a pile of agents, tools, prompts, and
dashboards. The direction here needs a harder spine. Once an AI system can
write, dispatch, attach, review, retry, recover, and explain itself after the
fact, the interesting question becomes:

Who was allowed to do what, under which authority, with which evidence, at what
time?

That question does not fit well in a marketing hero.

It fits better in a page that feels like a terminal, an operator console, and an
architecture packet had a quiet meeting and agreed not to embarrass each other.

## The thing under the thing

There are a few names we are not supposed to say too loudly yet.

The gremlins in the build room have made their position clear: do not stand on
the table, do not announce the whole machine before the bolts are tightened, and
do not use the phrase that makes people imagine a slide deck with too many
logos.

Fine.

So here is the quieter version.

We are turning the platform into a place where AI execution is not just invoked,
but admitted. A request enters with context. It is typed. It carries tenant,
installation, trace, causation, idempotency, and authority. It crosses a product
boundary, becomes durable operational truth, passes through semantic and policy
layers, enters the Spine, and only then reaches raw runtime machinery.

When something happens, it should leave evidence:

- a dispatch record
- a receipt
- a review decision
- a projection
- a trace
- a release-manifest ref
- a proof token
- a reason it was allowed
- a reason it would be rejected next time

That is the real project hiding behind the redesign.

The site now hints at it instead of pretending the shape is simpler than it is.

## Memory is where this gets interesting

The redesign also makes room for the next architectural thread: governed memory.

Not "memory" as a vector database with a friendly label. Governed memory as a
time-aware access problem:

- which user can invoke which agent
- which agent can touch which resource
- which user belongs to which scope
- which policy was active at the time
- which fragments were recalled
- which transforms were applied before the model saw them
- which fragments were promoted into evidence-grade state

The core idea is simple: memory access should be replayable.

If a decision happened in March, the platform should be able to reconstruct
which fragments influenced it, which policy admitted them, which authority
granted the relevant edges, and whether those same fragments would still be
admissible today.

That belongs in the core contract, not in a sidebar. It marks the line between
helpful recall and governed state.

## What changed in the site

The actual implementation is straightforward:

- replaced the old theme with a darker OKLCH token system
- moved display typography to Space Grotesk
- kept code and system labels in JetBrains Mono
- made the header fixed, translucent, and compact
- replaced the old homepage tone with stack-owner language
- tightened repo chips and section cards
- made prose pages feel closer to technical notes than generic blog posts

The blog, ecosystem pages, and repository grid all inherit the same system now.
No React runtime from the prototype. No Babel in production. Just the useful
parts of the design translated into Hugo CSS.

## What this is pointing at

The redesign only marks the entrance.

The larger machinery is behind it.

The work underneath is about making AI systems answerable at the boundary where
intent becomes effect. The names will get louder later. For now, the site has
the right posture: dark, precise, a little severe, and full of small hints that
something larger is being assembled behind the panels.

If the gremlins ask, this was only a CSS update.
