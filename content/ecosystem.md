---
title: "North Shore AI Ecosystem"
description: "The 7-tiered industrial ML ecosystem built on Elixir and the BEAM. Portfolio RAG, orchestration frameworks, CNS dialectical reasoning, and the Kitchen/Metalworking metaphors."
layout: "ecosystem"
---

# The North Shore AI Ecosystem

A comprehensive industrial ML infrastructure built on Elixir and the BEAM platform. This ecosystem comprises 50+ libraries organized into a 7-tiered architectural model, connected by organizing metaphors that encode architectural decisions into memorable concepts.

---

## The 7-Tiered Architectural Model

```
                     +------------------------------------------+
                     |        TIER 1: PUBLIC INTERFACE          |
                     |              nsai_sites                  |
                     |    (Cloudflare Workers, Edge Delivery)   |
                     +--------------------+---------------------+
                                          |
                                          v
                     +------------------------------------------+
                     |     TIER 2: GATEWAY & ORCHESTRATION      |
                     |       nsai_gateway | nsai_registry       |
                     |  (Auth, Rate Limit, Discovery, Health)   |
                     +--------------------+---------------------+
                                          |
          +-------------------------------+-------------------------------+
          |                               |                               |
          v                               v                               v
+------------------------+    +------------------------+    +------------------------+
|   TIER 3: PROCESSING   |    |   TIER 3: PROCESSING   |    |   TIER 3: PROCESSING   |
|        KITCHEN         |    |         FORGE          |    |          CNS           |
|   crucible_kitchen     |    |    forge / anvil       |    |    Dialectical AI      |
|   tinkex_cookbook      |    |    ingot / labeling_ir |    |    cns / cns_crucible  |
+------------------------+    +------------------------+    +------------------------+
          |                               |                               |
          +-------------------------------+-------------------------------+
                                          |
                                          v
                     +------------------------------------------+
                     |        TIER 4: CORE FRAMEWORK            |
                     |   crucible_framework | crucible_ir       |
                     |           crucible_bench                 |
                     | (Pipeline Orchestration, IR, Statistics) |
                     +--------------------+---------------------+
                                          |
                                          v
                     +------------------------------------------+
                     |        TIER 5: MLOPS ASSEMBLY            |
                     |  crucible_train | crucible_model_registry|
                     |  crucible_deployment | crucible_feedback |
                     |   (Train, Version, Deploy, Feedback)     |
                     +--------------------+---------------------+
                                          |
                                          v
                     +------------------------------------------+
                     |      TIER 6: RELIABILITY & SAFETY        |
                     |   LlmGuard | crucible_ensemble           |
                     |   crucible_hedging | ExFairness          |
                     |   crucible_xai | crucible_adversary      |
                     +--------------------+---------------------+
                                          |
                                          v
                     +------------------------------------------+
                     |     TIER 7: FOUNDATIONAL UTILITIES       |
                     |  tiktoken_ex | embed_ex | chz_ex         |
                     |  hf_hub_ex | hf_datasets_ex | nx_penalties|
                     +------------------------------------------+
```

---

## Organizing Metaphors

Complex systems require organizing metaphors that make abstract relationships concrete. The NSAI ecosystem uses two primary metaphor families.

### The Kitchen/Cookbook Metaphor (Training Infrastructure)

A professional kitchen is a carefully orchestrated environment where raw ingredients become finished dishes through standardized processes, specialized equipment, and skilled practitioners.

| Concept | Real-World Analog | NSAI Component | Function |
|---------|-------------------|----------------|----------|
| **Kitchen** | Restaurant kitchen facility | `crucible_kitchen` | Backend-agnostic ML training orchestration |
| **Cookbook** | Standardized recipes | `tinkex_cookbook` | Training recipes and configurations |
| **Chef** | Skilled cook | ML Practitioner | Human expertise and judgment |
| **Mise en Place** | Ingredient preparation | Data preprocessing | Dataset staging and validation |

```
                THE KITCHEN METAPHOR
                ====================

+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|    RAW DATA      | --> |     KITCHEN      | --> |  TRAINED MODEL   |
|   (Ingredients)  |     |  (Infrastructure)|     |     (Dish)       |
|                  |     |                  |     |                  |
+------------------+     +--------+---------+     +------------------+
                                  |
                                  | uses
                                  v
                         +------------------+
                         |    COOKBOOK      |
                         |    (Recipes)     |
                         +--------+---------+
                                  |
                                  | guided by
                                  v
                         +------------------+
                         |      CHEF        |
                         |  (Practitioner)  |
                         +------------------+
```

### The Metalworking Metaphor (Data Labeling Stack)

A blacksmith's forge transforms raw ore into refined metal through heat, pressure, and skilled craftsmanship.

| Concept | Real-World Analog | NSAI Component | Function |
|---------|-------------------|----------------|----------|
| **Forge** | Smelting furnace | `forge` | Domain-agnostic sample factory |
| **Anvil** | Shaping surface | `anvil` | Human-in-the-loop labeling and governance |
| **Ingot** | Finished metal product | `ingot` | Phoenix LiveView labeling UI |
| **Crucible** | High-heat testing vessel | `crucible_*` | ML experimentation infrastructure |

```
                THE METALWORKING METAPHOR
                =========================

+------------------+     +------------------+     +------------------+
|    RAW DATA      | --> |      FORGE       | --> |   CANDIDATES     |
|   (Raw Ore)      |     |  (Bulk Process)  |     | (Shaped Metal)   |
+------------------+     +------------------+     +--------+---------+
                                                          |
                                                          v
+------------------+     +------------------+     +------------------+
|  LABELED DATA    | <-- |      ANVIL       | <-- |   CANDIDATES     |
|    (Refined)     |     | (Human Review)   |     |   (Queue)        |
+------------------+     +------------------+     +------------------+
        |
        |  displayed via
        v
+------------------+
|      INGOT       |
|    (UI Layer)    |
+------------------+
```

---

## Portfolio RAG Ecosystem

Hexagonal architecture (ports and adapters) for Retrieval-Augmented Generation systems.

```
                       PORTFOLIO ECOSYSTEM ARCHITECTURE
========================================================================

                       +---------------------------+
                       |    portfolio_manager      |
                       |    (Application Layer)    |
                       |  CLI, Multi-Provider,     |
                       |  Pipeline Orchestration   |
                       +-------------+-------------+
                                     |
                                     | uses
                                     v
                       +---------------------------+
                       |    portfolio_index        |
                       |  (Implementation Layer)   |
                       |  Adapters, Broadway,      |
                       |  RAG Strategies           |
                       +-------------+-------------+
                                     |
                                     | implements
                                     v
+-----------------------------------------------------------------------+
|                        portfolio_core                                  |
|                      (Foundation Layer)                                |
|                                                                        |
|  +------------+  +------------+  +------------+  +------------+        |
|  | VectorStore|  | GraphStore |  |  Embedder  |  |    LLM     |        |
|  |    Port    |  |    Port    |  |    Port    |  |    Port    |        |
|  +------------+  +------------+  +------------+  +------------+        |
|                                                                        |
|  +---------------------------------------------------+                 |
|  |           ETS-backed Adapter Registry             |                 |
|  +---------------------------------------------------+                 |
+-----------------------------------------------------------------------+
                                     |
                                     | domain-specific
                                     v
                       +---------------------------+
                       |    portfolio_coder        |
                       |    (Domain Layer)         |
                       |  Code Intelligence,       |
                       |  Multi-Language Support   |
                       +---------------------------+
```

### Stack Components

| Component | Version | Description |
|-----------|---------|-------------|
| **portfolio_core** | v0.3.0 | 16 Port Specifications, ETS Registry, Manifest Engine |
| **portfolio_index** | v0.2.0 | Pgvector, Neo4j adapters, Broadway pipelines, RAG strategies |
| **portfolio_manager** | v0.3.0 | CLI, multi-provider routing, agents, evaluation framework |
| **portfolio_coder** | v0.1.0 | Code intelligence platform, multi-language AST analysis |

### 16 Port Specifications

**Storage Ports:** VectorStore, GraphStore, Cache

**Processing Ports:** Embedder, Chunker, Retriever, Reranker

**Generation Ports:** LLM, Router

**Orchestration Ports:** Pipeline, Agent, Tool

**Quality Ports:** Evaluation

### RAG Strategies

| Strategy | Description |
|----------|-------------|
| **Hybrid (RRF)** | Reciprocal Rank Fusion of dense and sparse retrieval |
| **Self-RAG** | Model decides when to retrieve, critiques its own generations |
| **GraphRAG** | Graph traversal for entity-centric retrieval |
| **Agentic** | Agent-driven retrieval with tool use |

---

## Orchestration Frameworks

### flowstone (v0.5.2) - Asset-First Data Orchestration

Flowstone treats data assets as first-class citizens. The scheduler derives execution plans from asset dependencies. Materialization is incremental: only stale assets are recomputed.

**Core Concepts:**
- **Assets:** Named data artifacts with materialization functions
- **I/O Managers:** Storage abstraction (Memory, Postgres, S3, Parquet)
- **Lineage Tracking:** Records which upstream assets contributed to each downstream asset
- **Partition-Aware Execution:** Only stale partitions are recomputed

**Execution Patterns:** Scatter/Gather, Signal Gates, Approval Gates, Conditional Branches

### synapse (v0.1.1) - Headless Multi-Agent Orchestration

Synapse provides declarative multi-agent systems with a domain-agnostic signal bus and durable workflows persisted to Postgres.

**Core Components:**
- **Signal Bus:** Pub/sub for agent communication with persistence
- **Workflow Engine:** FSM state management with checkpointing
- **Agent Definition:** Declarative specification of subscriptions and emissions
- **LLM Gateway:** Unified interface for OpenAI, Anthropic, Gemini

```
    Framework Comparison
    ====================

    | Aspect              | flowstone                      | synapse                         |
    |---------------------|--------------------------------|---------------------------------|
    | Primary abstraction | Data assets                    | Agents and signals              |
    | Execution model     | Pull (materialize what's needed)| Push (react to signals)        |
    | Typical latency     | Seconds to hours (batch)       | Milliseconds to minutes         |
    | Use case            | Data pipelines, ETL            | Multi-agent coordination        |
```

---

## CNS Dialectical Reasoning

Chiral Narrative Synthesis implements dialectical reasoning where claims are systematically challenged, contradictions are surfaced, and resolutions are synthesized through evidence-guided critique.

### The Dialectical Flow

```
+------------------+         +------------------+         +------------------+
|     PROPOSER     | ------> |    ANTAGONIST    | ------> |   SYNTHESIZER    |
|    (Thesis)      |         |   (Antithesis)   |         |   (Synthesis)    |
+--------+---------+         +--------+---------+         +--------+---------+
         |                            |                            |
         v                            v                            v
+------------------+         +------------------+         +------------------+
|  Extract SNOs    |         | Flag Contra-     |         | Resolve with     |
|  (claims +       |         | dictions         |         | Evidence         |
|   evidence)      |         | (B1 gaps,        |         | (critic-guided)  |
|                  |         |  chirality)      |         |                  |
+------------------+         +------------------+         +------------------+
```

### Agents

| Agent | Role | Responsibilities |
|-------|------|------------------|
| **Proposer** | Thesis Generator | Claim extraction, evidence linking, SNO graph construction |
| **Antagonist** | Antithesis Generator | Contradiction detection, B1 gap identification, chirality analysis |
| **Synthesizer** | Resolution Generator | Claim reconciliation, evidence weighting, critic-guided resolution |

### The Critic Ensemble

Five specialized critics evaluate different dimensions of reasoning quality:

| Critic | Core Question | Checks |
|--------|---------------|--------|
| **Grounding** | Are claims supported by cited evidence? | Citation accuracy, evidence-claim alignment |
| **Logic** | Is the reasoning chain valid? | Syllogistic validity, fallacy detection |
| **Novelty** | Does this add new information? | Semantic novelty, redundancy detection |
| **Bias** | Is the reasoning systematically skewed? | Evidence selection balance, framing analysis |
| **Causal** | Are causal claims justified? | Correlation vs causation, confounder identification |

### Key Concepts

**B1 Gaps (Betti-1 Gaps):** Holes in the argument structure detected through topological analysis. The first Betti number counts one-dimensional holes; applied to argument graphs, B1 gaps indicate missing inferential steps.

**Chirality:** Asymmetric perspective in reasoning. A chiral argument looks different when viewed from opposing positions, revealing implicit framing choices.

---

## Crucible Reliability Stack

### Core Framework (Tier 4)

| Component | Purpose |
|-----------|---------|
| **crucible_framework** | ML experimentation orchestration, pipeline runner, stage definitions |
| **crucible_ir** | Intermediate representation for ML pipelines |
| **crucible_bench** | Statistical testing (t-tests, ANOVA, effect sizes, power analysis) |

### MLOps Assembly (Tier 5)

| Component | Purpose |
|-----------|---------|
| **crucible_train** | Unified ML training (supervised, RL, DPO, distillation) |
| **crucible_model_registry** | Model versioning, artifact storage (S3/HF/local) |
| **crucible_deployment** | Model deployment (vLLM/Ollama/TGI/K8s), canary rollouts |
| **crucible_feedback** | Production feedback, drift detection, active learning |

### Reliability & Safety (Tier 6)

| Component | Purpose |
|-----------|---------|
| **LlmGuard** | AI firewall - prompt injection, jailbreak, data leakage detection |
| **crucible_ensemble** | Multi-model voting (majority, weighted, ranked-choice) |
| **crucible_hedging** | Request hedging (fixed, adaptive, percentile, workload-aware) |
| **crucible_adversary** | Adversarial testing - attacks, perturbations, defenses |
| **ExFairness** | Bias detection and mitigation |
| **crucible_xai** | Explainable AI - LIME, SHAP, PDP/ICE |
| **ExDataCheck** | Data validation with 34 expectation types |

---

## Foundational Utilities (Tier 7)

| Component | Purpose |
|-----------|---------|
| **tiktoken_ex** | Pure Elixir BPE tokenizer (Kimi K2 compatible) |
| **embed_ex** | Vector embeddings with multiple providers |
| **chz_ex** | Configuration management with CLI parsing |
| **hf_hub_ex** | HuggingFace Hub API client |
| **hf_datasets_ex** | Native HuggingFace Datasets port for Elixir |
| **nx_penalties** | Composable regularization penalties for Nx |

---

## Related Domains

### NSAI Sites

| Domain | Purpose |
|--------|---------|
| [nsai.online](https://nsai.online) | Corporate presence |
| [nsai.store](https://nsai.store) | Marketplace |
| [nsai.space](https://nsai.space) | Research documentation |

### GitHub Organizations

- [North-Shore-AI](https://github.com/North-Shore-AI) - Primary ecosystem organization
- [nshkrdotcom](https://github.com/nshkrdotcom) - Personal projects and experiments

---

## Key Patterns

- **Stages:** Composable pipeline steps implementing `Crucible.Stage` behaviour
- **Adapters:** Pluggable backends (TDA, fairness, analysis) with noop fallbacks
- **LiveView:** Real-time dashboards with PubSub integration
- **Telemetry:** Event-driven metrics collection across all projects
- **IR Structs:** Shared intermediate representation structs across related projects

---

## Tech Stack

**Languages:** Elixir, Erlang, Python, Rust

**Frameworks:** Phoenix, OTP, FastAPI

**Platforms:** BEAM VM, AWS, GCP, Cloudflare Workers

**Focus Areas:**
- Distributed systems and fault tolerance
- AI/LLM infrastructure and reliability
- Functional programming and metaprogramming
- Statistical analysis and experimental design
