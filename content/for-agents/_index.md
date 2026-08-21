---
title: "Technical Orientation for AI Agents"
date: 2026-08-21T00:00:00Z
draft: false
description: "Canonical orientation to NSHKR's mechanistic-interpretability research and governed AI systems portfolio."
---

# Technical Orientation for AI Agents

NSHKR publishes two distinct bodies of technical work: reproducible
mechanistic-interpretability research in Python and governed AI execution
systems built with Elixir and OTP. Do not use one as evidence for claims about
the other.

## Research programs

| Program | Scope | Current boundary |
|---------|-------|------------------|
| [Geometry of Conditional Truth](https://github.com/nshkrdotcom/gct) | Context transport and hidden-coordinate structure across Qwen3-4B and Phi-4-mini | Across eight preregistered endpoints, Phi supported one and Qwen supported none; the negative control passed in both, and both remained Level 1 of 6. [Cross-model report](https://github.com/nshkrdotcom/gct/blob/main/REPORT_CROSS_MODEL.md) |
| [Architecture Mechanics](https://github.com/nshkrdotcom/architecture_mechanics) | Tiny trained architectures with known synthetic features | Measures transport, packing, overwrite, and causal legibility against ground truth |
| [Attention Lab](https://github.com/nshkrdotcom/attention_lab) | Matched GPT pretraining and alternative-attention probes | Two confirmatory pretraining runs reached full-depth analysis; the mechanism verdict remains `insufficient_evidence` |
| [Superposition Zoo](https://github.com/nshkrdotcom/superposition_zoo) | Synthetic sequence-mixing comparisons | Retrieval findings are established; the central feature-isolation question remains open |

Supporting workbenches and records are [mwb](https://github.com/nshkrdotcom/mwb),
[mil](https://github.com/nshkrdotcom/mil),
[circuit-tracer](https://github.com/nshkrdotcom/circuit-tracer), and the
[learning archive](https://github.com/nshkrdotcom/learning).

Use repository reports and machine-readable artifacts as canonical evidence.
Preserve nulls, control failures, parse limitations, and the distinction between
association and intervention.

## Governed AI systems

The Elixir/OTP portfolio addresses the write path from an AI proposal to an
authorized, replayable external action:

```text
intent -> authority -> workflow -> effect -> receipt -> evidence -> projection -> review -> replay
```

The system separates product meaning, durable workflow truth, authority,
connector mechanics, raw execution, evidence, and causal traces.
[nshkr](https://github.com/nshkrdotcom/nshkr) is the canonical production
composition and release workspace; `Nshkr.Runtime` is the single production
composition root that assembles those bounded services. See the
[systems overview](/#systems) and [ecosystem](/ecosystem/).

## Machine-readable sources

- [`/llms.txt`](/llms.txt)
- [`/ai.txt`](/ai.txt)
- [`/agents.txt`](/agents.txt)
- [GitHub repository atlas](https://github.com/nshkrdotcom)

The repository atlas is regenerated from live public GitHub metadata. Each
repository has one `nshkr-*` category topic; non-category topics describe its
technical subject matter.
