# 07. AI System Design

Source entries are in their original order. Use the space after each heading to draft an answer.

## Design a Real-Time Voice AI Agent

**Answer:**

### Requirements and quality targets

Clarify the agent’s use case (for example, customer support or a personal assistant), supported languages, inbound/outbound calling, concurrency, expected conversation length, tool access, and whether users can interrupt it. Define end-to-end response latency targets, availability, transcription and task-success targets, privacy/retention rules, escalation requirements, and cost per minute. Voice quality is not just model quality: turn-taking, barge-in, silence handling, and recovery from tool or network failures matter.

### High-level architecture

```text
Caller
  -> telephony/WebRTC gateway
  -> streaming audio ingress, VAD and session manager
  -> streaming ASR or speech-capable model
  -> dialogue orchestrator / policy / tool router
  -> streaming TTS or speech-capable response model
  -> audio egress to caller

Supporting services: identity and consent, tools, knowledge retrieval,
session state, observability, safety review, and human handoff
```

### Request and turn flow

1. **Establish a session:** Authenticate or identify the caller as appropriate, disclose recording/AI use where required, apply consent and retention rules, and create a session with explicit state and deadlines.
2. **Receive and segment audio:** Stream audio with codec handling and voice-activity detection (VAD). Use streaming ASR to produce partial and final transcripts, or a suitable speech-capable model. Preserve timestamps and speaker turns when needed.
3. **Manage turn-taking:** Begin processing partial speech when safe, but distinguish provisional hypotheses from final user intent. Support barge-in by stopping/canceling generated speech when the caller interrupts; handle silence, noise, and endpointing without prematurely cutting off the user.
4. **Plan and act:** Pass the current transcript and allowed context to a dialogue orchestrator. Apply policy checks and route only approved, typed tool calls with authentication, timeouts, idempotency, and confirmation for consequential actions.
5. **Generate speech incrementally:** Stream a response as soon as a safe, coherent segment is ready. TTS should support cancellation and backpressure; avoid speaking sensitive or unverified content. For long actions, give a brief status update rather than leaving unexplained silence.
6. **Recover and hand off:** Retry only safe transient operations, surface tool failures clearly, and provide a human transfer path with a concise transcript/context summary. Do not fabricate success when a downstream action fails.
7. **Close and persist appropriately:** Store only the transcript/audio/session data justified by the product and policy, apply retention/deletion rules, and make the session auditable without exposing sensitive data.

### Latency, reliability, and safety

Optimize perceived latency by streaming audio, ASR partials, model generation, and TTS, while measuring the complete turn—not merely model token latency. Track time to first audio, interruption response, end-of-turn delay, transcription quality, tool success, task completion, transfers, and p50/p95/p99 latency. Use bounded queues, cancellation propagation, deadlines, circuit breakers, and graceful degradation to avoid stalled sessions.

Treat transcripts as untrusted input. Defend against prompt injection in spoken content and retrieved material, constrain tools to least privilege, validate all arguments, and require explicit confirmation for purchases, account changes, or other high-impact actions. Use human review/escalation for ambiguous or high-risk requests. Evaluate accents, noise, code-switching, accessibility, and demographic/language slices; provide a non-voice fallback.

### Trade-offs, bottlenecks, and capacity assumptions

The main latency bottleneck may be end-of-turn detection, ASR, model generation, a slow external tool, or TTS; profile each stage and the complete turn before optimizing one component. Streaming lowers perceived latency but can expose partial transcription or speech that must be canceled or corrected after barge-in. A cascaded ASR/LLM/TTS design offers replaceable components and control, while a speech-to-speech model may simplify orchestration but can reduce observability or control depending on the service. Capacity depends on concurrent calls, audio bitrate/duration, model tokens per second, and tool-request rate; the prompt gives no traffic or SLO numbers, so benchmark representative peak concurrency and reserve headroom for bursts and failover.

### Concise interview answer

“I’d build a streaming session around telephony/WebRTC, VAD and streaming ASR, a stateful dialogue orchestrator with tightly controlled tools, and streaming TTS with barge-in support. I would optimize and measure end-to-end turn latency, not just model speed. Tool calls need typed validation, least privilege, timeouts, and confirmation for consequential actions; failures must be explicit, with human handoff. I’d also design for consent and retention, noisy audio and accents, cancellation, privacy, safety evaluation, and graceful recovery.”

### Revision summary

| Concern | Design choice |
|---|---|
| Low perceived latency | Streaming audio/ASR/generation/TTS and measured turn-level SLOs. |
| Natural interaction | VAD, endpointing, barge-in, interruption cancellation. |
| Safe actions | Policy checks, typed tools, least privilege, confirmation. |
| Reliability | Deadlines, backpressure, retries where safe, explicit failures, human handoff. |
| Privacy and quality | Consent/retention controls, slice-based evaluation, fallback channel. |

<br><br><br>

## Design ChatGPT: Training to Serving (End to End)

**Answer:**

### Scope and requirements

Treat this as a general conversational AI product rather than assuming any proprietary implementation details. Clarify modalities, target languages, peak concurrency, context and output limits, latency/availability targets, quality and safety expectations, data-retention policy, and whether tools or user-provided files are supported. The system spans model development and online serving; its SLOs include helpfulness, safety, and cost as well as infrastructure availability.

### End-to-end architecture

```text
Data sources -> rights/privacy filtering -> deduplication and quality checks
            -> pre-training / continued pre-training
            -> supervised and preference/safety training
            -> offline evaluation, red-team and release gates
            -> versioned model artifacts and deployment

Client -> API gateway/auth/quotas -> conversation and policy orchestrator
      -> context assembly (history, tools, optional retrieval)
      -> model router -> inference fleet -> streaming response
      -> safety/output checks -> client

Supporting: tool services, file processing, model registry, telemetry,
feedback/incident review, abuse detection, billing and rollback
```

### Model development and release

1. **Govern data:** Establish lawful source and use rights, provenance, privacy and retention controls. Filter/curate data, remove duplicates and sensitive material where required, and maintain contamination-resistant evaluation sets.
2. **Train in stages:** Pre-train a base model on the chosen objective and corpus; then adapt it to instruction-following with demonstrations. Preference or safety methods may further shape behavior. The exact approach depends on the product and model—no single training recipe guarantees correctness or alignment.
3. **Evaluate before release:** Test capability, calibration/abstention, robustness, safety, privacy leakage, multilingual performance, and regressions. Use human review for nuanced judgments and separate benchmark data from training.
4. **Package reproducibly:** Version model weights, tokenizer, chat template, safety policy, tools, inference configuration, and evaluation results together. Gate changes on quality, latency, cost, and risk thresholds; support canary rollout and rollback.

### Online request flow

1. Authenticate the user, enforce quota/rate limits, and apply account, region, and data-handling policies.
2. Validate message shape and attachments; normalize the conversation into the exact model template. Set explicit context, output, timeout, and tool budgets.
3. Assemble relevant history and optional retrieved context. Preserve message roles and provenance; do not treat retrieved or user-supplied text as trusted instructions.
4. Route to a compatible model/serving pool based on task, modality, capacity, and policy. A router may select smaller or specialized models when they meet the quality bar.
5. Run inference with batching and memory-aware scheduling; stream tokens to reduce perceived latency. Apply tool-call schema validation and authorization before executing any action.
6. Apply policy and output handling. If a response is blocked, refused, or incomplete, represent that outcome explicitly rather than returning a success-shaped answer.
7. Record privacy-minimized telemetry and feedback signals; retain conversation content only according to disclosed policy and user controls.

### Serving, safety, and operations

The inference layer needs admission control, queueing, batching, cancellation, timeouts, autoscaling/capacity management, health checks, and graceful degradation. Monitor time to first token, tokens per second, p95/p99 latency, queue depth, error/timeout rate, GPU utilization, cost per request, and quality/safety indicators. Keep user data isolated, encrypt data in transit and at rest, enforce retention/deletion, and constrain tools with least privilege and confirmation for consequential actions. Red-team prompt injection, data exfiltration, unsafe tool use, and abuse; maintain human escalation and incident response.

### Trade-offs, bottlenecks, and capacity assumptions

Training-data quality, GPU training throughput, evaluation cost, and online inference are separate capacity problems. At serving time, prompt prefill, token-by-token decoding, KV-cache memory, batching, and queueing can each become the bottleneck; optimize against the actual prompt/output length mix rather than request count alone. Larger or more capable models may improve some quality measures while increasing latency and cost, so routing to smaller models is acceptable only after quality validation. Capacity cannot be sized numerically without model sizes, hardware, context lengths, concurrency, and token-rate targets; benchmark those inputs and include rollout, replication, and failure headroom.

### Concise interview answer

“I’d design the system across two lifecycles: governed data and model training with staged evaluations, and an authenticated, policy-aware serving path. At inference, the gateway validates requests, assembles history and optional retrieval, routes to a compatible model fleet, streams generation, validates tool calls, and applies safety/output handling. The platform needs versioned artifacts, quotas, batching, cancellation, autoscaling, privacy controls, observability, canary deployment, and rollback. I’d evaluate quality and safety alongside latency, availability, and cost, without assuming any one training method guarantees them.”

### Revision summary

| Layer | Key responsibility |
|---|---|
| Data and training | Rights/provenance, quality, training stages, contamination controls. |
| Release | Capability/safety evaluation, versioning, gates, canary and rollback. |
| Request path | Authentication, context assembly, routing, streaming, tool controls. |
| Serving | Admission, batching, cancellation, capacity, resilience and SLOs. |
| Governance | Privacy, retention/deletion, abuse monitoring, human incident response. |

<br><br><br>

## Design a RAG System (Chat with Your Documents)

**Answer:**

### Requirements and system boundary

Clarify supported file formats and size, corpus and update rate, user/tenant access rules, expected query volume, citation requirements, freshness, latency and availability SLOs, and whether answers must be extractive, conversational, or both. Establish what “correct” means: retrieving source evidence is distinct from generating a correct answer.

### High-level architecture

```text
Documents -> upload/connectors -> validation and malware checks
          -> parse/OCR -> normalize -> chunk + metadata/provenance
          -> embedding + lexical indexing -> versioned retrieval store

Question -> auth/policy -> query preprocessing
         -> hybrid retrieval + metadata/ACL filters
         -> optional reranker -> evidence/context assembly
         -> LLM generation with source references
         -> citation/evidence checks -> answer to user
```

### Ingestion path

1. Authenticate the source and verify file type, size, ownership, and permissions. Scan uploads and reject unsupported or unsafe content.
2. Parse text and structure, using OCR for scanned pages where needed. Preserve page, section, table, and source offsets so evidence can be cited; record parse failures explicitly.
3. Normalize content and remove boilerplate carefully. Chunk by meaningful structure with enough context for answerability; avoid treating chunk size as universal.
4. Attach source ID/version, tenant and access metadata, timestamps, and provenance to every chunk. Apply deletion and update semantics so stale chunks do not remain searchable.
5. Generate embeddings and lexical terms using versioned models/configuration. Write idempotently and publish the document only when its index state is consistent.

### Query path

1. Authenticate and derive authorization scope from trusted identity.
2. Classify/rewrite the query if useful, preserving user intent and exact terms.
3. Retrieve candidates using dense and lexical search where appropriate, applying ACL and metadata constraints consistently.
4. Rerank a bounded candidate set if evaluation shows benefit. Deduplicate and assemble context within the model’s token budget while preserving source IDs and locations.
5. Instruct the model to answer from supplied evidence, cite the supporting sources, and abstain or ask for clarification when evidence is insufficient or conflicting.
6. Validate citations against retrieved context, then return an answer with links/snippets. Do not present a generated citation as valid unless it maps to a real source span.

### Quality, safety, and operations

Evaluate ingestion completeness, parser/OCR accuracy, Recall@k/MRR/nDCG, citation precision, answer support/faithfulness, abstention, and end-to-end task success on representative questions. Include unanswerable questions, conflicting documents, prompt injection in documents, updates/deletions, and permission tests. Monitor freshness lag, parse/index errors, retrieval quality, latency, token usage, and cost. Version corpus, chunker, embedding model, index, prompt, and generator so regressions are diagnosable and rollback is possible.

### Trade-offs, bottlenecks, and capacity assumptions

Parsing/OCR and embedding throughput determine ingestion lag; at query time, metadata filtering, ANN recall, reranking, and LLM context/generation compete for latency and cost. More chunks and larger candidate sets can improve evidence coverage but increase index size, retrieval work, and prompt tokens. Estimate vector payload from chunk count × dimension × bytes per component, then add index, metadata, replica, and cache overhead; document count alone is not enough because chunking drives vector count. Since corpus size, churn, and query SLOs are unspecified, benchmark representative documents and query mixes before choosing shard count or hardware.

### Concise interview answer

“I’d build a governed ingestion pipeline that parses and chunks documents while preserving provenance and access metadata, then creates versioned dense and lexical indexes. At query time, the authenticated user’s permissions constrain hybrid retrieval; candidates are optionally reranked and assembled within a token budget. The model answers from retrieved evidence with validated citations and abstains when support is missing. I’d evaluate retrieval, citation correctness, grounded answer quality, freshness, access control, and parser failures separately, and version every stage for rollback.”

### Revision summary

| Stage | Design focus |
|---|---|
| Ingestion | Safe parsing/OCR, structure-aware chunks, provenance, update/delete correctness. |
| Retrieval | Auth-scoped hybrid search, filters, reranking and context selection. |
| Generation | Evidence-grounded answer, real citations, abstention for gaps. |
| Evaluation | Retrieval, grounding, citations, ingestion, permissions, adversarial documents. |
| Operations | Freshness, versioning, monitoring, cost and rollback. |

<br><br><br>

## Design an enterprise RAG assistant over 10M documents with per-user permissions.

**Answer:**

### Requirements and security invariants

Clarify document formats and churn, user/group counts, query volume, permission model, latency and freshness targets, regional/data-residency needs, and audit/retention obligations. The central invariant is **no unauthorized content may influence a user-visible answer**—including snippets, citations, caches, reranker inputs, or generated summaries. Ten million documents is a scale input, but permission correctness and update propagation are the defining constraints.

### Ingestion and authorization-aware indexing

```text
Enterprise sources / change feeds
  -> connector identity and ACL extraction
  -> parse, version, chunk and preserve source provenance
  -> attach document and chunk ACL metadata
  -> lexical + vector indexes
  -> index/ACL consistency checks and deletion propagation

User query -> identity/entitlement service -> authorized retrieval
           -> rerank only authorized candidates
           -> grounded answer and citations
```

1. **Connect securely:** Use least-privilege service identities, track source document IDs and versions, and ingest ACLs/groups from the system of record. Do not infer access from filenames or user-supplied filters.
2. **Preserve ACL semantics:** Model direct users, groups, inherited permissions, deny rules, and source-specific semantics correctly. Normalize identifiers but retain enough source data to reconcile changes.
3. **Chunk with inherited access:** Every chunk must inherit the correct document-level access constraints; sub-document permissions require finer-grained ACLs. Store ACL/version metadata with searchable records or an architecture that can enforce equivalent checks.
4. **Process changes and deletes:** Consume source change feeds, handle permission revocation and document deletion promptly, and reconcile periodically. Treat stale ACLs as a security defect; measure and bound permission propagation delay.
5. **Partition thoughtfully:** Use a scalable distributed index and partitioning strategy based on corpus, region, or tenant characteristics. Avoid creating so many per-user copies that updates and storage become unmanageable.

### Query-time authorization

Authenticate the user and obtain current entitlements from a trusted identity/authorization service. Retrieve only within that scope using pre-filtering or an equivalent enforceable access-control mechanism. If the vector engine cannot enforce the full policy, use a security boundary that filters candidates before they are exposed to rerankers, logs, or the model; post-filtering only after context assembly is unsafe. Handle group expansion and revocation according to the required freshness guarantee.

Cache keys and cached results must include user/entitlement or a safely equivalent authorization version. Re-check permission before serving cached content. Never rely on the LLM to decide whether a source is authorized. Apply the same controls to citations, previews, exports, conversation history, and observability systems.

### Scale, quality, and auditability

Use hybrid retrieval to cover exact identifiers and semantic queries; tune ANN, shard routing, candidate depth, and reranking using production-shaped data. Track retrieval quality and p95/p99 latency with realistic ACL selectivity and group sizes. Build automated negative tests for cross-user/group leakage, permission changes, deletes, cache invalidation, and adversarial filters. Audit access decisions with privacy-minimized logs, encryption, retention limits, and incident response. Version index, parser, embeddings, ACL snapshots/change offsets, and policy code for reproducible rollback.

### Trade-offs, bottlenecks, and capacity assumptions

The stated 10M documents is not the vector count: average chunks per document, embedding dimension/precision, replicas, and ACL/index metadata determine storage and index footprint. Query bottlenecks include entitlement/group expansion, selective ACL filters, distributed fan-out, reranking, and synchronization delays for revocations. Per-user materialized copies may simplify isolation but multiply storage and update work; shared indexes are more efficient but demand strict authorization-aware filtering and testing. Query rate, tenant distribution, ACL complexity, freshness SLO, and document size are unspecified, so size partitions and capacity with measured workload distributions and explicit revocation-lag limits.

### Concise interview answer

“I’d ingest source ACLs and version them with each document/chunk, propagate updates and revocations promptly, and derive query scope only from authenticated identity and the authoritative entitlement service. Retrieval must enforce authorization before candidates reach rerankers or the model; filtering only the final answer is too late. I’d isolate caches by authorization state, validate citations and previews under the same policy, and test cross-user leakage continuously. At ten million documents, I’d use distributed hybrid retrieval and benchmark recall and tail latency under realistic ACL filters.”

### Revision summary

| Requirement | Design control |
|---|---|
| Per-user permissions | Authoritative identity/entitlements and enforceable pre-retrieval scope. |
| ACL freshness | Versioned change feeds, revocation/deletion propagation, reconciliation. |
| No leakage | Filter before reranking/model; authorization-aware cache and citations. |
| Ten-million scale | Distributed hybrid index, measured partitioning and filtered ANN. |
| Assurance | Negative leakage tests, audit logs, versioning and incident response. |

<br><br><br>

## Design Memory for a Personal AI Assistant

**Answer:**

### Define what “memory” should mean

Clarify which information the assistant may remember, for how long, whether the user can inspect/edit/delete it, what is stored locally versus remotely, and how consent, sensitive data, shared devices, and account deletion work. Memory is not simply “put the whole chat history in a vector database.” Separate short-lived conversation context from durable user-approved preferences and facts.

### Memory layers and architecture

```text
Current conversation -> bounded context window / session state
User-approved facts -> structured profile/preferences store
Past interactions -> optional episodic store with source/time/consent
Retrieval index -> searchable references to permitted memories

New message -> memory proposal/extraction -> policy + user controls
           -> scoped storage -> relevant-memory retrieval
           -> answer with appropriate context
```

- **Working memory:** Recent turns needed for the current conversation; bounded by context and session lifecycle.
- **Semantic/profile memory:** Stable preferences or user-provided facts represented as typed fields with provenance, confidence, and last-confirmed time.
- **Episodic memory:** Optional references to past interactions or events, stored only when useful and allowed; retrieval should return the source/time context, not an unqualified claim.

### Write and read paths

1. **Propose, do not silently infer sensitive facts:** Detect candidate memories from explicit user requests or clear preference statements. Apply policy to sensitive categories and ambiguity; ask for confirmation when storing a durable or consequential item.
2. **Store minimally:** Keep only information with a demonstrated product benefit. Record source, creation/update time, scope, confidence, expiry/retention, and whether the user confirmed it. Avoid duplicating entire conversations.
3. **Retrieve selectively:** On a new request, retrieve only memories relevant to the task and allowed for that user/session. Use structured lookup for precise preferences and semantic retrieval for episodic references; do not inject every stored fact into every prompt.
4. **Resolve conflicts:** Prefer explicit, recent user corrections over older inferred memories. Preserve provenance and ask when conflicting values matter rather than silently choosing.
5. **Expose controls:** Let users inspect, edit, forget individual memories, disable memory, and delete all related records. Propagate deletion to indexes, caches, backups as governed by the stated retention policy, and derived data where feasible.

### Privacy, safety, and evaluation

Enforce tenant/account isolation, encryption, least privilege, access logging, retention limits, and deletion workflows. Do not treat retrieved memory as trusted instructions; it is context and can be stale or malicious. Consider shared-device and household accounts explicitly. Evaluate useful recall, precision, stale/conflicting memory handling, unauthorized cross-user access, deletion effectiveness, and the rate of unwanted/inaccurate memories. Keep memory off or request confirmation when the user’s expectation is unclear.

### Trade-offs, bottlenecks, and capacity assumptions

More durable memory can improve personalization but increases privacy exposure, stale/conflicting facts, deletion complexity, and retrieval noise. Storing structured preferences is compact and predictable; episodic search can cover richer history but costs more in indexing and can retrieve irrelevant context. Estimate storage from active users × retained memory items or bytes per user, with indexes, versions, and replicas added; retrieval and deletion fan-out can become operational bottlenecks. The prompt gives no user count, retention period, or memory-write rate, so use explicit retention and per-user limits and benchmark retrieval/deletion at expected account scale.

### Concise interview answer

“I’d separate bounded session context from durable, user-controlled memory. Durable memories are minimal, typed and provenance-tagged, with explicit scope, retention, confidence, and user edit/delete controls. A write path proposes candidate memories and applies consent and sensitive-data policy; a read path retrieves only relevant, authorized items and handles stale or conflicting facts carefully. I’d avoid storing entire chats by default, enforce account isolation and deletion, and evaluate both useful recall and privacy failures.”

### Revision summary

| Memory type | Storage/use |
|---|---|
| Working | Recent turns, bounded to the active session/context. |
| Semantic | Minimal structured preferences/facts with provenance and expiry. |
| Episodic | Optional searchable references to past interactions. |
| User control | Inspect, edit, disable, forget, delete. |
| Governance | Consent, scope, isolation, retention, deletion and stale-memory handling. |

<br><br><br>

## Design a Deep Research Agent

**Answer:**

### Goal and constraints

Clarify the research domain, source restrictions, expected depth, time budget, citation standard, and whether the agent may access the public web, private corpora, or both. Define success as a useful synthesis supported by verifiable evidence—not simply a long answer or a large number of URLs. For high-stakes topics, require expert review and explicit limits.

### Architecture

```text
User question
  -> scope/ambiguity clarification
  -> research planner and budget manager
  -> query decomposition / source strategy
  -> search connectors (web, approved databases, internal RAG)
  -> fetch, parse, deduplicate and provenance store
  -> evidence extraction / claim ledger
  -> gap and contradiction analysis
  -> targeted follow-up searches
  -> synthesis with claim-linked citations
  -> citation verification and policy checks
  -> report with uncertainty and limitations
```

### Research loop

1. **Plan before browsing:** Convert the question into subquestions, identify definitions and comparison dimensions, specify credible source types, and allocate a fixed search/time/tool budget.
2. **Search with provenance:** Use approved connectors; record URL/identifier, publisher/author, retrieval time, and relevant passage. Treat pages and documents as untrusted data, not instructions.
3. **Extract evidence:** Store atomic claims linked to exact source spans. Prefer primary sources for factual or technical claims and use independent sources for corroboration when appropriate.
4. **Assess evidence quality:** Track source authority, recency, directness, and possible conflicts. Distinguish an unsupported claim, an absence of evidence, and conflicting evidence; do not manufacture consensus.
5. **Iterate on gaps:** Ask targeted follow-up searches when a required subquestion lacks evidence or sources disagree. Stop when the plan is adequately covered or the budget is exhausted; disclose unresolved gaps.
6. **Synthesize carefully:** Build an outline from the evidence ledger, attach citations to the claims they support, distinguish fact from inference, and state dates, assumptions, confidence, and limitations.
7. **Verify before delivery:** Resolve each citation to a retrieved source span, check that it supports the adjacent claim, remove unsupported specifics, and apply safety/privacy/policy checks.

Use explicit timeouts, per-source rate limits, bounded parallelism, retries only for safe transient failures, and deterministic logging for reproducibility. The agent should request clarification for underspecified questions and never claim that a search or source check succeeded if it failed.

### Evaluation and safeguards

Measure subquestion coverage, source diversity/quality, citation correctness, claim support, factual accuracy, contradiction handling, freshness, latency, and cost. Red-team prompt injection embedded in pages, malicious downloads, hallucinated citations, source-ranking bias, and attempts to access restricted sources. Keep an audit trail of queries, retrieved evidence, tool actions, and model/version while minimizing sensitive data.

### Trade-offs, bottlenecks, and capacity assumptions

Research quality competes with search depth, source diversity, response time, and tool cost. Parallel searches reduce wall-clock latency but can hit provider quotas, duplicate work, or return correlated evidence; use bounded concurrency, deduplication, and a per-task call/time/token budget. Fetching and parsing pages, rate limits, and claim verification often bottleneck more than model generation. Capacity depends on concurrent research sessions × searches/fetches per plan, document size, and source limits; none are specified, so enforce budgets and expose incomplete coverage when exhausted rather than silently presenting a shallow search as comprehensive.

### Concise interview answer

“I’d make the agent plan a bounded research task, search approved sources, preserve provenance, extract a claim-level evidence ledger, and iterate only where the evidence has gaps or conflicts. It then synthesizes with citations tied to verified source spans and states uncertainty and limitations. Web content is untrusted input, tool access is allowlisted and budgeted, and failed searches are surfaced explicitly. I’d evaluate evidence support, citation correctness, coverage, source quality, and safe behavior—not just fluency.”

### Revision summary

| Stage | Quality requirement |
|---|---|
| Plan | Decompose question and set scope/tool budgets. |
| Collect | Approved sources, provenance and timestamps. |
| Reason | Claim ledger, corroboration, gaps and contradictions. |
| Report | Claim-linked citations, uncertainty, limitations. |
| Guard and evaluate | Treat pages as untrusted; test coverage, support, citations and cost. |

<br><br><br>

## Design a Multi-Agent Customer Support System

**Answer:**

### Requirements and design principle

Clarify channels, supported languages, ticket volume and concurrency, response-time targets, account/order systems, escalation expectations, and which actions the system may take. Define outcomes such as resolution rate, customer satisfaction, policy compliance, and cost per resolved case. Start with one orchestrator and a small set of bounded capabilities; multiple agents are justified only when specialization or independent workflows improve measurable outcomes.

### Architecture

```text
Customer channels -> identity/session gateway -> conversation orchestrator
                                              -> intent and risk triage
                                              -> knowledge retrieval
                                              -> specialist workflows/tools
                                              -> policy and response validation
                                              -> customer response or human handoff

Supporting: CRM/ticketing, order/billing APIs, knowledge management,
agent state, audit trail, evaluation, monitoring and supervisor console
```

### Interaction flow

1. Authenticate where required, identify the account/session, and apply privacy and channel policies.
2. Classify intent and risk: routine FAQ, account-specific question, transactional request, complaint, or safety-sensitive issue. Ask a focused clarification when required fields are missing.
3. Retrieve approved, current support content with citations/provenance and access controls. Use specialized workers for tasks such as order lookup or troubleshooting only through typed, authorized tool interfaces.
4. Let the orchestrator own state and task boundaries. Workers return structured results and evidence; they do not independently send customer messages or take unapproved actions.
5. Apply deterministic policy checks to tool arguments and outcomes. Require explicit user confirmation for consequential actions such as refunds, cancellations, or account changes, subject to business rules.
6. Synthesize a concise response grounded in verified evidence. If confidence is low, sources conflict, the user requests a person, or the workflow exceeds policy, transfer to a human with a summary, transcript, evidence, and completed steps.
7. Record the decision path and tool results with privacy-minimized logs so the case is auditable.

### Reliability, safety, and evaluation

Use bounded agent steps, timeouts, cancellation, idempotency keys, tool allowlists, and retry rules limited to safe transient failures. Prevent loops and duplicate side effects. Treat customer messages and retrieved documents as untrusted input; do not allow them to override system policy or expand tool permissions. Protect account data with least privilege and verify user authorization on every action.

Evaluate resolution and escalation quality, factual grounding, tool-call correctness, policy violations, latency, cost, customer satisfaction, and recontact rate. Test adversarial prompts, ambiguous requests, stale knowledge, tool outages, and handoff continuity. Review sampled conversations and use human feedback to improve retrieval, workflows, and policy—not merely add more agents.

### Trade-offs, bottlenecks, and capacity assumptions

Specialist agents may improve task focus but add model calls, handoffs, duplicated context, and failure modes; prefer the smallest workflow that meets resolution and compliance targets. External account APIs and human-agent availability can dominate end-to-end latency even when model inference is fast. Size capacity from concurrent conversations × average model/tool calls per conversation, token lengths, and expected escalation rate, then separately check API quotas and supervisor queue capacity. The prompt gives no traffic or service-level targets, so load-test peak concurrency and establish bounded agent-step and cost budgets.

### Concise interview answer

“I’d use a central orchestrator for triage, state, policy, and customer communication, with a small set of bounded specialist workflows for retrieval and account tools. Tool calls are typed, least-privilege, idempotent, and checked against deterministic business rules; consequential actions require confirmation. The system grounds answers in current support sources and hands off with a useful case summary when uncertain or out of scope. I’d evaluate resolution, grounding, tool correctness, compliance, customer experience, latency, and cost, and avoid multi-agent complexity unless it earns its keep.”

### Revision summary

| Component | Responsibility |
|---|---|
| Orchestrator | Intent, state, routing, policy and final response. |
| Specialists | Bounded retrieval or domain task; structured results only. |
| Tools | Authorized, validated, idempotent business operations. |
| Handoff | Human escalation with context, evidence, and completed actions. |
| Evaluation | Resolution, accuracy, compliance, satisfaction, latency and cost. |

<br><br><br>

## Design an On-Device AI Assistant

**Answer:**

### Requirements and constraints

Clarify supported tasks and modalities, target devices and operating systems, offline expectations, languages, response-time and battery targets, privacy guarantees, model-update frequency, and whether cloud fallback is allowed. On-device design is constrained by memory, compute, thermal limits, storage, and hardware variability; “offline” should have a precise product definition.

### Architecture

```text
App UI / voice input
  -> local permissions and session manager
  -> local preprocessing (ASR, OCR, image/audio handling as needed)
  -> compact on-device model runtime
  -> local tools and encrypted user-controlled memory
  -> response / action confirmation

Optional: consented cloud escalation for tasks exceeding local capability
```

### Model and runtime strategy

1. **Choose workloads that fit locally:** Use compact or distilled models and hardware acceleration available on target devices. Quantization can reduce memory and bandwidth, but validate quality and numerical behavior on actual devices.
2. **Budget the whole pipeline:** Account for weights, KV cache/context, activations, tokenizer, runtime libraries, and multimodal components. Limit context/output tokens and use streaming or incremental processing where useful.
3. **Adapt by device capability:** Detect supported accelerators and memory budgets; select compatible model variants without changing task behavior silently. Maintain a tested CPU fallback only if latency and battery expectations remain acceptable.
4. **Protect local data:** Keep sensitive processing on device where promised, encrypt persisted memory, require OS-level permission for sensors/files, and provide inspect/delete controls. Do not send local content to cloud services unless the user and product policy allow it.
5. **Use optional cloud escalation carefully:** Explain when data leaves the device, minimize the payload, apply authentication and transport security, and degrade gracefully when connectivity is unavailable.
6. **Update safely:** Sign model and application updates, validate compatibility and integrity, support staged rollout and rollback, and provide an explicit version/support policy.

### Quality, safety, and operations

Benchmark across device tiers, thermal states, battery conditions, languages, noisy audio, and accessibility needs. Measure cold-start and warm latency, peak memory, energy per task, crash rate, offline success, and quality. On-device does not eliminate safety concerns: constrain local actions, ask for confirmation before high-impact operations, validate outputs, and provide a clear abstention/fallback path. Maintain versioned evaluations because a smaller model may behave differently from a cloud model.

### Trade-offs, bottlenecks, and capacity assumptions

The model must fit alongside the runtime, activations, KV cache, context, and application—not merely fit by weight size. Quantization and smaller models reduce RAM, storage, energy, and often latency, but may lower task quality; longer contexts and multimodal components can dominate memory and thermal load. Capacity is device-specific: benchmark the lowest-supported memory/compute tier under sustained use, not just a flagship device or short warm run. Device models, memory budgets, offline workload, and latency targets are unspecified, so define a support matrix and make any cloud fallback an explicit privacy and connectivity trade-off.

### Concise interview answer

“I’d define the offline and privacy guarantees first, then select compact, possibly quantized models that fit the target device’s memory, compute, thermal, and battery budgets. The runtime needs local preprocessing, permission-gated tools, encrypted user-controlled state, bounded context, and signed model updates. Cloud fallback is optional, explicit, and data-minimized. I’d benchmark quality, latency, memory, energy, and reliability across real device tiers, and keep safety controls and confirmation for consequential actions.”

### Revision summary

| Constraint | Design response |
|---|---|
| Memory/compute | Compact model, measured quantization, bounded context. |
| Battery/thermal | Efficient runtime, streaming, per-device benchmarks. |
| Privacy/offline | Local-first processing and transparent, consented cloud fallback. |
| Device diversity | Capability detection, compatible variants, staged updates. |
| Safety | Permission-gated tools, confirmation, abstention and evaluation. |

<br><br><br>

## Design a Multimodal Search System (Text, Image, Video)

**Answer:**

### Requirements and data model

Clarify supported query types (text-to-image, image-to-image, text-to-video, or mixed), corpus size and update rate, languages, video length/frame rate, access controls, freshness, latency, and whether users need timestamps or exact source frames. Define relevance judgments for each query-modality pair; one embedding model may not perform equally well for all directions.

### Ingestion and index architecture

```text
Content sources -> validation/ACLs -> modality-specific processing
  text: parse, chunk, preserve document structure
  image: decode, resize/normalize, optional OCR/captions
  video: metadata + sampled frames + timestamps + optional ASR
       -> modality encoders / compatible vector spaces
       -> lexical index + per-modality vector indexes
       -> metadata/provenance store

Query -> auth -> query-type detection / modality encoder
      -> lexical + compatible vector retrieval
      -> candidate fusion and modality-aware reranking
      -> result cards with source, snippet, frame/time and permissions
```

### Indexing and query path

1. Validate media type, size, rights, and access scope; scan files and preserve stable source IDs and versions.
2. Extract useful representations: text chunks, OCR text, image embeddings, video frame embeddings with timestamps, and audio transcripts when appropriate. Keep the link between each vector and the original source region.
3. Use encoders that are trained or validated for the required cross-modal comparison. Store model/version and preprocessing metadata; keep incompatible vector spaces separate even if dimensions match.
4. At query time, authenticate and enforce permissions before exposing candidates. Encode using the matching query path, retrieve from relevant modality indexes, and optionally add lexical retrieval for names, codes, OCR, or captions.
5. Fuse candidate lists using rank/score fusion or a learned reranker calibrated on labeled data. Deduplicate near-identical frames/assets and return useful provenance, including video timestamps and relevant excerpts.
6. Apply diversity or freshness policies only where they improve the product, and provide filters or clarification for ambiguous queries.

### Scale, quality, and governance

Video frame sampling trades index size against temporal coverage; select sampling based on content and use case rather than indexing every frame by default. Deduplicate assets, cache embeddings by model version, and process updates asynchronously with consistent deletion/ACL propagation. Evaluate each retrieval direction separately with Recall@k, MRR/nDCG, cross-modal relevance, temporal localization, latency, storage, and permission correctness. Include OCR-heavy images, multilingual text, long videos, and hard negatives. Respect media rights, sensitive content policies, retention, and audit requirements.

### Trade-offs, bottlenecks, and capacity assumptions

Video frame sampling rate is a major storage/compute lever: more frames improve temporal coverage but multiply decoding, embedding, index, and query-candidate work. Text, image, and video encoders may have different quality, latency, and hosting costs, so routing and fusion should be measured per modality. Estimate vector storage from the number of indexed text chunks/images/frames × dimensions × bytes per value, then include ANN structures, metadata, replicas, and originals. The corpus size, frame-sampling policy, ingestion rate, and query mix are unspecified, so prototype representative media and load-test peak ingestion and cross-modal query fan-out before selecting capacity.

### Concise interview answer

“I’d build modality-specific ingestion and encoders, preserve provenance from each vector back to its document, image region, or video timestamp, and maintain compatible per-modality indexes plus lexical search. Query routing chooses the matching encoder/index; candidates are permission-filtered, fused, and optionally reranked before returning source-linked results. I’d control video sampling to balance coverage and scale, version all embeddings, and evaluate each cross-modal direction for relevance, latency, freshness, and access correctness.”

### Revision summary

| Layer | Design concern |
|---|---|
| Processing | Text/OCR, image encoding, video frames/timestamps, optional audio transcript. |
| Indexing | Separate compatible spaces, lexical index, metadata/provenance. |
| Retrieval | Query-modality routing, ACL filtering, fusion and reranking. |
| Result UX | Source links, excerpts, image regions, video timestamps. |
| Evaluation | Per-direction relevance, localization, scale, freshness and permissions. |

<br><br><br>

## Design an LLM Inference Platform (vLLM-as-a-Service)

**Answer:**

### Requirements and service contract

Clarify API compatibility, supported model families and context lengths, streaming/tool-call support, throughput and latency SLOs, tenant isolation, quotas, regions, model licensing, and whether workloads are shared or dedicated. Define availability and error semantics, token accounting, data-retention guarantees, and cost controls. A vLLM-based service is one possible implementation; the API and scheduling layer should not assume every model/runtime has identical capabilities.

### Architecture

```text
Client -> API gateway/auth/quotas -> request validation and model router
      -> admission control / scheduler
      -> model worker pools on GPU nodes
      -> streaming response

Supporting: model registry and artifact store, autoscaler, node manager,
metrics/logging, billing, safety policy, health checks and rollout control
```

### Request lifecycle

1. Authenticate the tenant, apply per-model permissions, rate limits, token/cost budgets, and request-size limits.
2. Validate messages, model-specific context limits, sampling parameters, tool schemas, and streaming options. Return explicit client errors for invalid requests.
3. Route to a healthy worker pool with the requested model/version and capability. Use admission control and bounded queues to protect latency and prevent unbounded GPU memory pressure.
4. Schedule compatible requests for continuous or dynamic batching where supported. Manage KV-cache allocation, prefill/decode work, cancellation, deadlines, and fairness so long prompts or one tenant do not starve others.
5. Stream tokens with backpressure; support cancellation and report usage consistently. Enforce tool-call schema validation at the API boundary, not by trusting generated arguments.
6. Recover from worker/node failure with health checks and safe retry rules. A generation retry may produce a different answer; avoid duplicate side effects and make partial-stream semantics clear.
7. Meter tokens, GPU time, queueing, and per-tenant usage for quotas and billing while minimizing retention of prompt/output content.

### Models, deployment, and operations

Store immutable, checksummed model artifacts with tokenizer, configuration, runtime compatibility, and license metadata. Load or warm models according to demand and memory constraints; isolate incompatible models into appropriate worker pools. Scale on queue depth, utilization, latency, and workload mix—not GPU utilization alone. Roll out new weights/runtime versions using canaries and automated quality/throughput checks, with fast rollback. Protect against noisy neighbors through quotas, fair scheduling, and optional dedicated pools for strict isolation.

Track time to first token, inter-token latency, request completion latency, queue depth, throughput, GPU memory/utilization, KV-cache pressure, failures, cancellations, cost per token, and per-model quality indicators. Apply transport security, access controls, audit logs, and tenant data-retention settings. Capacity planning must account for prompt length, output length, concurrency, batching, and cache behavior.

### Trade-offs, bottlenecks, and capacity assumptions

Continuous batching and larger batches can improve GPU throughput but may increase queueing or tail latency; admission control and fair scheduling protect SLOs at the cost of rejecting or delaying work under overload. Prefill is sensitive to prompt length, decode to generated tokens and concurrent sequences, and KV-cache use to context length, concurrency, and model configuration. Estimate demand in input/output tokens per second plus concurrent active sequences, then benchmark the actual model, GPU, quantization, and batching settings; request count alone is not a capacity measure. The prompt gives no workload or hardware numbers, so retain headroom for bursts, model loading, and node failure.

### Concise interview answer

“I’d expose a versioned API behind authentication, quotas, request validation, and model routing. An admission controller schedules work to compatible GPU pools with bounded queues, batching, KV-cache management, cancellation, and tenant fairness. Workers stream output with clear timeout and partial-response semantics; the platform meters usage and protects data. A model registry, health-based autoscaling, canary deployments, observability, and rollback complete the service. I’d benchmark TTFT, inter-token and tail latency, throughput, memory, and cost under realistic prompt/concurrency mixes.”

### Revision summary

| Component | Responsibility |
|---|---|
| Gateway | Auth, validation, quotas, routing, streaming contract. |
| Scheduler/workers | Admission, batching, KV-cache, fairness, cancellation. |
| Model lifecycle | Immutable artifacts, warmup, compatibility, canary/rollback. |
| Multi-tenancy | Budgets, noisy-neighbor controls, dedicated pools if needed. |
| SLOs | TTFT, inter-token latency, throughput, queueing, memory, cost, errors. |

<br><br><br>

## Design an LLM Evaluation Platform

**Answer:**

### Goals and users

Support model, prompt, retrieval, and agent changes across offline experiments and production monitoring. Users may include model developers, application teams, evaluators, and governance reviewers. Clarify evaluation scale, sensitivity of test data, human review needs, reproducibility, and which release decisions the platform is allowed to gate. A score is evidence for a decision, not a complete definition of quality.

### Architecture and evaluation lifecycle

```text
Versioned datasets + task definitions + policy rubrics
  -> experiment configuration (model, prompt, tools, retrieval)
  -> execution workers / model endpoints
  -> deterministic checks + model-based graders + human review
  -> raw traces, outputs, labels and metric computation
  -> slice/error analysis, comparison and dashboards
  -> release gate / experiment record

Production telemetry -> sampled, privacy-filtered evaluation -> alerts
```

1. **Define and version test cases:** Store inputs, expected properties or references, labels/rubrics, source/provenance, and sensitive-data classification. Split development and holdout sets to reduce leakage and overfitting to the benchmark.
2. **Capture the full configuration:** Record model/version, prompt/template, tools, retrieval corpus/index, decoding parameters, code commit, and evaluator versions so runs are reproducible.
3. **Run multiple evaluator types:** Use exact/unit checks for deterministic properties, task metrics for structured outputs, model-based graders for scalable subjective comparisons, and qualified human review for ambiguous or high-impact judgments.
4. **Store artifacts and traces:** Preserve input/output, tool calls, retrieved evidence, latency, token usage, errors, and evaluator rationale subject to privacy and retention policy. Make failures inspectable and auditable.
5. **Compare and analyze:** Report aggregate and slice metrics, confidence intervals where appropriate, regressions, failure clusters, cost, and latency. Compare paired runs on the same examples rather than relying on unrelated averages.
6. **Gate releases responsibly:** Set metric-specific thresholds and required human sign-off; block or require review when safety, privacy, or critical task metrics regress. Support canary evaluation and rollback.
7. **Monitor production:** Sample according to policy, redact/minimize personal data, detect distribution shift and emerging failure patterns, and feed reviewed cases into future evaluation sets without contaminating holdouts.

### Evaluator quality and governance

Calibrate model graders against human judgments, test for position/style bias, and do not use the same model’s unvalidated judgment as the sole release criterion. Track evaluator reliability and disagreement. Provide access controls, dataset lineage, retention/deletion controls, audit trails, and separation of duties for sensitive evaluations.

### Trade-offs, bottlenecks, and capacity assumptions

Evaluation breadth competes with run time and cost: testing every model/configuration on every example with repeated stochastic runs can multiply inference and human-review work. Parallel execution reduces wall-clock time but may be constrained by provider quotas, GPU capacity, or expensive graders; deterministic checks should handle cases where they suffice, while human review focuses on ambiguous/high-impact slices. Estimate workload as test cases × configurations × repetitions × evaluator calls, then add trace storage and reviewer throughput. No dataset size, run cadence, or model-cost assumptions are given, so support sampling for iteration but preserve a protected holdout and full release-gate suite.

### Concise interview answer

“I’d build a versioned evaluation pipeline that captures the complete system configuration and runs deterministic tests, task metrics, calibrated model graders, and human review where needed. It stores inspectable traces and reports aggregate plus slice-level quality, safety, latency, and cost. Release gates are tied to explicit thresholds and can require human sign-off; production sampling is privacy-filtered and monitored for drift. I’d protect holdout sets and validate grader reliability so the platform doesn’t turn a proxy score into false certainty.”

### Revision summary

| Platform capability | Purpose |
|---|---|
| Versioned datasets/configuration | Reproducibility and leakage control. |
| Multiple evaluators | Combine exact checks, metrics, model graders and human judgment. |
| Trace/error analysis | Explain regressions and support debugging. |
| Release gates | Enforce measurable quality/safety requirements and approvals. |
| Production loop | Privacy-aware sampling, drift detection and reviewed updates. |

<br><br><br>

## Design a Text-to-Image Generation Service (Midjourney-like)

**Answer:**

### Requirements and user experience

Clarify expected image quality/style, supported dimensions and aspect ratios, generation/editing workflows, peak traffic, latency expectations, concurrency, privacy, retention, and commercial use. Define acceptable content policy, user reporting, provenance expectations, and whether outputs are private or shareable. The service must distinguish a queued job from a completed generation and expose progress, cancellation, and failure clearly.

### Architecture

```text
Client -> auth / quota / policy checks -> prompt and input validation
      -> generation job API -> queue / scheduler
      -> GPU inference workers (model + VAE / safety components)
      -> output validation / metadata / provenance
      -> object storage + CDN -> client gallery / download

Supporting: model registry, billing, moderation, telemetry,
feedback/reporting, abuse response and rollout controls
```

### Generation lifecycle

1. Authenticate and enforce tenant/user quotas, request-size limits, and allowed model/features.
2. Validate prompt and any uploaded image for content policy, file safety, format, dimensions, and rights/consent requirements. Treat prompt text and embedded metadata as untrusted input.
3. Normalize generation parameters (model version, resolution, aspect ratio, steps or equivalent controls, seed where supported) and record them for reproducibility.
4. Enqueue a job with an idempotency key and explicit status. Schedule by expected GPU cost and priority; provide progress without promising exact completion time.
5. Generate with bounded resource use and cancellation. Apply output moderation and policy checks before making content public or shareable; route uncertain/high-risk cases to review.
6. Store the image and minimal metadata with access controls, retention policy, model/version and provenance. Deliver via short-lived authorized links or a controlled CDN.
7. Support user feedback, reporting, deletion, and appeal. Use consented, policy-compliant signals for evaluation and improvement.

### Safety, quality, and operations

Use layered text and image moderation, rate limits, abuse detection, and clear handling for disallowed or uncertain requests. Evaluate prompt adherence, image quality, artifact rate, diversity, safety false positives/negatives, latency, and cost across languages and prompt styles. Protect training data and user uploads; define whether prompts/outputs are logged or used for training and disclose it.

### Trade-offs, bottlenecks, and capacity assumptions

GPU generation time and memory rise with resolution, batch size, model choice, and generation settings; high-resolution or multi-image requests can dominate cost. Queues improve utilization but increase wait time, while strict latency targets may require reserved capacity and priority policies. Estimate GPU demand as request rate × measured GPU-seconds per request for each resolution/model mix, then add burst and failure headroom. Traffic distribution, image sizes, model/runtime, and latency SLO are unspecified, so benchmark representative prompts and load patterns instead of asserting a fixed worker count.

### Concise interview answer

“I’d expose an asynchronous generation API behind authentication, quotas, prompt/input moderation, and validation. Jobs enter a cost-aware queue for GPU workers, then outputs pass safety checks before controlled storage and delivery. I’d version model and generation settings, support progress, cancellation, deletion, and abuse reporting, and protect user content with explicit retention rules. The main capacity driver is measured GPU time by model and resolution; I’d size from the real request mix and track quality, queue delay, safety, and cost.”

### Revision summary

| Layer | Design concern |
|---|---|
| Admission | Identity, quotas, prompt/input safety, supported parameters. |
| Execution | Async jobs, GPU scheduling, cancellation, reproducibility. |
| Output | Moderation, provenance, access-controlled storage/delivery. |
| Scale | GPU-seconds/request, resolution mix, queueing, burst headroom. |
| Governance | Retention, privacy, abuse reporting, evaluation and rollout. |

<br><br><br>

## Design a Music Generation Service (Suno-like)

**Answer:**

### Requirements and product boundaries

Clarify whether users generate full songs, short clips, instrumentals, lyrics, or edits; desired duration, format, latency, concurrency, and whether generation is interactive or asynchronous. Establish rights and policy requirements for prompts, lyrics, voice likeness, training data, and generated outputs. Define user-visible job status and whether partial previews are useful.

### Architecture

```text
Client -> auth / quota / prompt and upload policy
      -> generation request + job queue
      -> conditioning / planning (prompt, optional lyrics/audio)
      -> music model workers (GPU/accelerator)
      -> decode / mix / encode / quality checks
      -> moderation + provenance metadata
      -> object storage / streaming delivery

Supporting: rights and consent controls, model registry, billing,
report/appeal flows, evaluation and observability
```

### Generation workflow

1. Validate prompt, lyrics, audio references, duration, format, and user permissions. Apply safety and rights policies to uploads and requests, including prohibited impersonation or unauthorized use where applicable.
2. Translate the request into controlled conditioning parameters (style, tempo, structure, instruments, language, duration) without promising exact adherence.
3. Queue a bounded generation job. For long outputs, generate in segments or stages if supported, then stitch/crossfade and validate continuity; keep the method model-dependent.
4. Decode and encode to target formats, normalize loudness conservatively, and check for clipping, truncation, corrupt files, and policy issues. Avoid claiming professional mastering unless provided and tested.
5. Store output with access controls, model/version and generation metadata; provide streaming/download links, cancellation, and deletion controls.
6. Offer user feedback and reporting, and use only data permitted by product terms and user consent for future evaluation or training.

### Evaluation and safeguards

Assess audio validity, prompt adherence, musical coherence, segment transitions, duration, speech/lyric intelligibility when relevant, safety, and user satisfaction. Use human listening studies alongside automated proxies; no single audio metric captures perceived quality. Apply abuse detection, content reporting, and provenance/rights handling that reflects the service’s policy and applicable obligations.

### Trade-offs, bottlenecks, and capacity assumptions

Longer duration and higher audio quality generally increase inference, decoding, storage, and bandwidth costs; segmenting can enable previews and bounded memory but risks discontinuities. Interactive low-latency generation may require smaller models or shorter clips, while full-song requests suit asynchronous queues. Estimate capacity using requests × generated audio-seconds × measured accelerator-seconds per audio-second, stratified by model and quality setting, then add encoding/storage and burst headroom. The prompt does not specify duration mix, codec, or latency targets, so benchmark those before sizing.

### Concise interview answer

“I’d make generation an asynchronous, quota-controlled job: validate prompts and references, apply rights and safety checks, run the model, decode/encode and validate the audio, then deliver it from controlled storage with provenance and deletion controls. For longer tracks I’d consider staged generation but evaluate continuity carefully. I’d measure prompt adherence, coherence, technical audio quality, safety, latency, and cost. Capacity should be based on generated audio-seconds and measured accelerator time, not just request counts.”

### Revision summary

| Concern | Design choice |
|---|---|
| Long-running work | Queue, status, cancellation, optional staged previews. |
| Audio quality | Decode/encode validation, continuity checks, human listening. |
| Rights and safety | Prompt/reference controls, consent, reporting, clear terms. |
| Cost | Duration- and quality-aware scheduling and quotas. |
| Capacity | Accelerator-seconds per generated audio-second plus delivery/storage. |

<br><br><br>

## Design a Video Generation Service (Sora-like)

**Answer:**

### Requirements and constraints

Clarify text-to-video versus image/video conditioning or editing, duration, resolution, frame rate, aspect ratios, audio needs, expected wait time, concurrency, and whether previews or iterative edits are supported. Set content policies, rights/consent rules for uploaded references, retention, provenance, and user reporting. Avoid implying that a system can guarantee physical accuracy or temporal consistency without evaluation.

### Architecture

```text
Client -> auth / quotas / prompt and media validation
      -> asynchronous job API -> queue and cost-aware scheduler
      -> planning/conditioning -> video generation workers
      -> decode / temporal and technical validation
      -> moderation / provenance
      -> object storage + adaptive delivery -> client

Supporting: model registry, job state, billing, abuse response,
evaluation, observability and staged rollout
```

### Job lifecycle

1. Validate prompt and reference media, including file safety, format, size, rights/consent, and policy. Normalize output parameters and reject unsupported combinations explicitly.
2. Create a versioned, idempotent job with an estimated resource class, status, deadline, and cancellation token. Do not promise precise completion time without a reliable estimate.
3. Schedule generation on compatible accelerator pools. For high-resolution or longer clips, use bounded staged generation, temporal windows, or upscaling only if the chosen model supports it; preserve continuity across segments.
4. Decode frames/audio, assemble the clip, validate codec/duration/frame count, and check for corruption, flicker, abrupt transitions, or missing segments.
5. Run safety checks on prompts, references, sampled frames, and audio where applicable. Hold, block, or route uncertain outputs through the documented review process before sharing.
6. Store outputs and provenance with access controls, retention/deletion rules, and model/config version. Deliver adaptive previews or downloads without exposing private assets.
7. Support feedback, reporting, cancellation/refund policy for failed jobs, and incident investigation.

### Evaluation and governance

Evaluate prompt adherence, visual quality, temporal consistency, motion plausibility, identity consistency where relevant, audio synchronization, safety, and user-perceived quality using both automated tests and human review. Keep evaluation slices for prompt types, duration/resolution, languages, and motion patterns. Watermarking or provenance mechanisms should be described only to the extent they are implemented and validated.

### Trade-offs, bottlenecks, and capacity assumptions

Video cost grows with generated frames, resolution, model architecture, and inference steps; temporal context and high-resolution decoding can drive accelerator memory and runtime. Longer clips improve usefulness but raise cost and consistency risk. Previews and staged jobs can improve perceived responsiveness, but consume extra work and may not predict final quality. Estimate capacity with requests × frames × resolution/quality-specific measured accelerator time per frame (or equivalent model-specific unit), then include retries, post-processing, storage, and delivery bandwidth. Duration, frame rate, resolution, and SLO are unspecified, so benchmark the intended output matrix before capacity commitments.

### Concise interview answer

“I’d expose a queued generation workflow with validation, cost-aware scheduling, GPU workers, post-processing, safety review, and controlled storage/delivery. Each job is versioned, cancellable, and explicit about status and failures. I’d evaluate prompt adherence, temporal consistency, technical validity, safety, and user quality, especially across duration and resolution. Capacity is driven by generated frames and measured model cost per frame, plus retries and media delivery; I would benchmark the target output matrix rather than size from request count alone.”

### Revision summary

| Stage | Key concern |
|---|---|
| Request | Supported modes, prompt/media rights, parameter validation. |
| Generation | Queueing, accelerator scheduling, continuity and cancellation. |
| Post-processing | Decode, technical integrity, temporal checks, moderation. |
| Delivery | Secure storage, previews/downloads, retention and deletion. |
| Capacity | Frame count/resolution, model time, retries, storage and bandwidth. |

<br><br><br>

## Design an AI Coding Agent.

**Answer:**

### Requirements and trust boundary

Clarify supported languages/repositories, IDE or CI integration, tasks (explain, edit, test, or execute), network access, latency, privacy, and whether the agent may modify files or run commands. Treat repository contents, issue text, and command output as untrusted input. The agent should propose bounded changes, expose its actions, and ask permission before operations with external or destructive effects.

### Architecture

```text
IDE / CLI -> authenticated session and workspace boundary
          -> repository context (files, symbols, tests, diagnostics)
          -> planner / model
          -> constrained tools (read, search, patch, test)
          -> diff review and validation
          -> user approval / apply changes

Supporting: model router, policy engine, sandbox, audit trail,
telemetry, prompt-injection defenses and rollback
```

### Agent loop

1. Resolve the workspace root and user request; identify relevant files and repository instructions without exposing unrelated secrets.
2. Build focused context using search and code intelligence, respecting file-size and token budgets. Keep source provenance so suggestions can be tied to code.
3. Produce a plan and use read-only tools first. The model may inspect, search, and run bounded diagnostics; edits should be patch-based and limited to the requested scope.
4. Gate commands by policy. Run builds/tests in an isolated environment with explicit working directory, time/resource limits, restricted network and filesystem access, and no ambient credentials where feasible.
5. Review the resulting diff for scope, formatting, security, and accidental edits. Run targeted tests and show failures explicitly; do not claim success if a command failed or did not run.
6. Present a concise summary, changed files, test results, assumptions, and unresolved issues. Require user approval before applying or committing changes if that is the product’s interaction model.
7. Support cancellation, rollback, and session cleanup; retain only policy-approved telemetry.

### Evaluation and safeguards

Measure task completion, patch acceptance, test pass rate, regression/security findings, edit locality, tool-call correctness, latency, and cost. Test malicious repository instructions, prompt injection in documents, secret exposure, unsafe commands, path traversal attempts, and multi-step loops. Keep tool permissions least-privilege and distinguish generated code from verified behavior.

### Trade-offs, bottlenecks, and capacity assumptions

More repository context can improve reasoning but increases token cost, latency, and the risk of irrelevant or sensitive context; retrieval should be focused and permissions-aware. Running tests yields stronger verification but consumes compute and time; static checks or targeted tests are faster but provide weaker evidence. Tool execution and environment setup often bottleneck more than model inference. Capacity depends on concurrent sessions, average context size, tool/test runtime, and model calls per task; these are unspecified, so use per-session budgets, bounded parallel commands, and queueing rather than assuming a fixed machine pool.

### Concise interview answer

“I’d build a workspace-scoped agent that gathers relevant code context, plans changes, and uses constrained tools for search, patching, and tests. Repository content is untrusted; commands run with least privilege in a bounded sandbox, and edits are reviewable with rollback. The agent reports exactly which tests ran and what failed. I’d evaluate patch acceptance, correctness, safety, tool behavior, and cost, balancing context size and test coverage against latency. Capacity planning should use concurrent sessions, context tokens, and test execution time.”

### Revision summary

| Layer | Design choice |
|---|---|
| Context | Focused, permission-aware repository retrieval. |
| Tools | Read-first, constrained patch/test commands, explicit approvals. |
| Isolation | Workspace boundary, sandbox, resource/network limits. |
| Verification | Diff review, targeted tests, truthful result reporting. |
| Capacity | Concurrent sessions × context/model calls/test runtime. |

<br><br><br>

## Design a code generation and review system.

**Answer:**

### Goals and system boundary

Clarify whether the system generates code from natural language, reviews pull requests, or both; supported languages, repository size, CI integration, privacy, latency, and human approval requirements. Define quality in terms of correctness, maintainability, security, and actionable review precision—not code volume or comment count. Keep the system advisory unless an explicitly governed workflow allows automatic changes.

### Architecture

```text
Developer request / pull request
  -> auth and repository permissions
  -> diff + relevant code/context retrieval
  -> generation or review planner
  -> model with constrained read/test/analysis tools
  -> deterministic checks (lint, typecheck, tests, security scans)
  -> finding validation and confidence/rationale
  -> developer review / optional patch proposal
  -> audit and feedback
```

### Generation and review flow

1. Verify repository access and identify the changed code plus relevant call sites, tests, configuration, and project conventions.
2. For generation, clarify requirements and constraints; propose a scoped patch rather than rewriting unrelated files. For review, compare the diff to surrounding behavior and report only concrete, actionable findings with file/line references.
3. Treat repository text and PR content as untrusted. Do not run arbitrary code or follow instructions found in source files; execute tools only under explicit sandbox policy.
4. Run relevant deterministic checks. Separate model reasoning from verified findings: a test passing does not prove correctness, and a model-suggested concern is not a confirmed vulnerability until supported by evidence.
5. Deduplicate findings, prioritize by severity and confidence, and include reproduction/context only when supported. Avoid overwhelming developers with speculative or style-only comments.
6. Let a human accept, edit, or reject patches/comments. For automated fixes, show the diff, run checks, and preserve rollback.
7. Capture privacy-appropriate feedback and outcomes to measure precision, acceptance, regressions, and false-positive rates.

### Safety, quality, and operations

Enforce repository and branch permissions, redact secrets from model context/logs, and define data retention for code. Use isolated execution with timeouts, resource and network limits. Evaluate on real issue/patch datasets with human-reviewed correctness labels; track bug-finding precision, missed defects, patch test pass rate, security findings, comment usefulness, latency, and cost. Keep benchmark sets separate from prompt/model tuning.

### Trade-offs, bottlenecks, and capacity assumptions

Large context windows can improve awareness of cross-file behavior but increase inference cost and distract the model; targeted retrieval and call-graph context reduce tokens but risk missing dependencies. Running full CI gives stronger validation but can dominate latency and compute; staged checks (fast lint/type tests first, broader suites when warranted) balance feedback speed and confidence. Review throughput and test infrastructure are common bottlenecks. Estimate capacity from PR/change volume × average files/context tokens × checks and test runtime; repository size and usage rate are unspecified, so benchmark representative monorepos and small projects separately.

### Concise interview answer

“I’d retrieve the diff and relevant repository context, then use a model to propose scoped changes or concrete review findings. Deterministic lint, type, test, and security tools validate claims where possible; execution is sandboxed and repository content is treated as untrusted. Findings are prioritized, evidence-linked, and human-reviewed, with patches shown before application. I’d measure precision, missed defects, patch test success, false positives, and developer acceptance, while balancing context coverage against CI latency and cost.”

### Revision summary

| Stage | Control |
|---|---|
| Context | Diff plus focused surrounding code and project conventions. |
| Analysis | Evidence-backed generation/review; avoid speculative findings. |
| Validation | Sandboxed deterministic checks and explicit test results. |
| Human control | Reviewable patches/comments, approval and rollback. |
| Capacity | PR rate, context size, test concurrency/runtime and review throughput. |

<br><br><br>

## Design a content moderation system using AI.

**Answer:**

### Requirements and policy definition

Clarify content types (text, image, audio, video, live streams), languages, volume, moderation latency, risk categories, jurisdiction, and actions available to the system. Translate policy into operational labels, severity levels, and decision rules with examples. Distinguish clear violations from ambiguous or context-dependent cases; moderation policy is a product/governance decision, not something the model should invent.

### Architecture

```text
Content submission / stream
  -> identity, rate limits and provenance
  -> modality-specific preprocessing
  -> fast deterministic checks + specialist classifiers
  -> policy decision layer (risk, context, thresholds)
  -> allow / label / limit / hold / remove / escalate
  -> user notice, appeal and reviewer workflow

Supporting: policy/rule registry, audit store, reviewer console,
quality evaluation, abuse monitoring and model rollout controls
```

### Decision flow

1. Validate media and context, preserve relevant conversation/thread context under privacy controls, and identify whether the decision is pre-publication or post-publication.
2. Run low-latency checks first: known hashes/rules, spam signals, and modality-appropriate classifiers. Use text/OCR, image, audio transcription, or sampled video analysis only where applicable.
3. Combine model scores with policy rules, account history, and context. Calibrate thresholds by severity and category; do not treat a score as a universal probability of violation.
4. Choose an action proportional to risk: allow, add friction/label, limit reach, hold for review, or remove/escalate. For high-impact or ambiguous decisions, use trained human reviewers with relevant context and policy guidance.
5. Explain the decision to the user at an appropriate level and provide an appeal path. Record policy/model versions, evidence features, decision, and reviewer override.
6. Feed adjudicated appeals and reviewer findings into evaluation and policy review, with safeguards against feedback loops and biased labels.

### Safety, quality, and operations

Measure precision/recall by policy category and language, false positives/negatives, reviewer agreement, appeal overturn rate, time to action, and harm-sensitive slices. Red-team evasion, coded language, contextual satire/quotation, adversarial media edits, and prompt injection embedded in content. Restrict reviewer access to sensitive material, support reviewer wellbeing, and audit consistency. Apply retention and access controls to content and moderation evidence.

### Trade-offs, bottlenecks, and capacity assumptions

Fast automated decisions improve throughput but can increase false positives and miss nuanced context; human review improves contextual judgment but adds cost and queue delay. Multimodal processing, especially video/audio, is more expensive than text and may require sampling or staged analysis. Reviewer capacity is often the bottleneck during spikes or breaking events. Size using content arrival rate × modality-specific processing cost plus the expected escalation fraction × review time; the prompt gives no volume, language mix, policy thresholds, or latency SLO, so load-test normal and peak bursts and define safe queue behavior.

### Concise interview answer

“I’d encode a reviewed policy into category-specific rules and thresholds, then use fast deterministic checks and modality-appropriate models to triage content. Clear cases can be actioned proportionally; ambiguous or high-impact cases go to trained reviewers, with user notice and appeal. I’d monitor false positives and negatives, reviewer overrides, and subgroup/language slices, and version policy and models. The key trade-off is automation latency and scale versus contextual accuracy and review capacity; I’d size from modality mix and escalation rate.”

### Revision summary

| Layer | Design decision |
|---|---|
| Policy | Explicit categories, severity, examples, and versioning. |
| Detection | Deterministic checks plus modality-appropriate models. |
| Action | Risk-proportional enforcement and human escalation. |
| Due process | User notice, appeal, reviewer audit and feedback. |
| Capacity | Modality cost, event spikes, escalation fraction, reviewer throughput. |

<br><br><br>

## Design a real-time AI recommendation system.

**Answer:**

### Requirements and objective

Clarify the surface (feed, search, product page), event and catalog volume, update freshness, request-rate/latency SLO, user context, business constraints, and whether recommendations are personalized, contextual, or both. Define success beyond clicks: conversion, retention, satisfaction, diversity, long-term value, and guardrails such as safety, fairness, and inventory availability.

### Architecture

```text
Impressions / clicks / purchases / feedback
  -> event validation and stream processing
  -> feature store + user/item representations
  -> offline training and candidate/index refresh

Request -> identity/context -> candidate generation
        -> eligibility / policy filters
        -> online feature hydration
        -> ranking model + business constraints
        -> diversity/re-ranking -> response

Supporting: experimentation, monitoring, privacy controls,
catalog/inventory/availability services and fallback lists
```

### Online and offline flow

1. Ingest events with timestamps, consent/eligibility, deduplication, and schema validation. Track impressions as well as clicks to reduce exposure bias.
2. Generate candidates from complementary sources: collaborative behavior, content/item embeddings, popularity/trending, and contextual retrieval. Keep a safe fallback for cold-start users/items.
3. Apply hard eligibility filters first—availability, locale, policy, age/access restrictions, and user exclusions. Do not rely on the learned ranker to enforce these rules.
4. Hydrate online features with bounded latency, score candidates, and rerank for diversity, freshness, and business constraints. Return a bounded result set with reason codes where required.
5. Log impressions and outcomes for evaluation, while respecting consent and retention; account for delayed conversions and position bias.
6. Train and deploy with time-aware validation, online experiments, guardrail metrics, and rollback. Monitor feature freshness, drift, popularity concentration, and feedback loops.

### Quality, safety, and operations

Measure ranking quality offline (e.g., NDCG/Recall at relevant cutoffs) and online with controlled experiments; monitor latency, availability, coverage, diversity, novelty, and business outcomes. Use exploration carefully to address cold start and exposure bias without violating safety or user controls. Provide non-personalized or cached fallback recommendations when features or models are unavailable.

### Trade-offs, bottlenecks, and capacity assumptions

Richer real-time features can improve relevance but add network calls, stale-data risk, and tail latency; precomputed features/candidates reduce latency but lag behavior changes. Candidate count increases ranking cost, while overly aggressive filtering can reduce coverage. Feature-store lookups and fan-out to inventory/profile services often bottleneck the request path. Estimate capacity from QPS × candidates scored × feature-fetch cost, plus stream ingestion and index refresh; user count, catalog size, traffic, and freshness target are unspecified, so benchmark representative peak load and cold-start slices.

### Concise interview answer

“I’d use streaming events and offline training to maintain features and candidate indexes, then serve a low-latency path that generates candidates, applies hard eligibility filters, scores and diversifies results, and logs impressions. I’d combine collaborative, content-based, and contextual candidates with cold-start fallbacks. Offline ranking metrics are not enough, so I’d run guarded online experiments and monitor long-term outcomes, diversity, latency, and feedback loops. Capacity depends on request rate, candidates scored, and feature-service fan-out.”

### Revision summary

| Stage | Design focus |
|---|---|
| Signals | Validated events, impressions, consent, delayed outcomes. |
| Candidates | Collaborative, content, contextual, popularity and cold-start. |
| Ranking | Feature hydration, eligibility, scoring, diversity. |
| Evaluation | Offline ranking + online experiments and guardrails. |
| Capacity | QPS, candidates, feature fetch, stream/index freshness. |

<br><br><br>

## Design an AI-powered email assistant.

**Answer:**

### Requirements and user control

Clarify supported tasks (summarize, classify, search, draft, suggest replies, schedule, or send), mailbox providers, languages, response-time targets, and whether processing is local or cloud-based. Email contains highly sensitive personal and business data. Default to read-only assistance and drafts; sending, forwarding, deleting, or changing recipients must remain an explicit user-authorized action with confirmation.

### Architecture

```text
Mail provider -> scoped OAuth / permission service
              -> webhook or incremental sync
              -> encrypted mailbox index + access-controlled retrieval

User request -> intent / policy -> relevant thread retrieval
             -> summarization or draft generation
             -> recipient/attachment/action validation
             -> user review and confirmation
             -> provider API action (only if approved)

Supporting: audit trail, data-retention/deletion, abuse defenses,
model gateway, feedback and evaluation
```

### Request flow and safety

1. Obtain narrow, revocable provider permissions and clearly disclose what data is processed and retained. Encrypt tokens and mailbox data; isolate accounts and support revocation/deletion.
2. Sync incrementally with provider change tokens/webhooks, preserving thread IDs, timestamps, sender/recipient metadata, and attachment references. Avoid indexing attachments unless needed and permitted.
3. Retrieve only the messages needed for the request, enforcing mailbox and folder permissions. Treat email body text, links, and attachments as untrusted content: prompt injection inside an email must not grant tool authority or override system policy.
4. Generate summaries/drafts with source links or quoted context. Distinguish stated facts from inferred intent and ask when tone, recipient, or requested action is unclear.
5. Before any side effect, show the exact recipients, subject, body, attachments, and action. Require user confirmation; validate recipients and attachment access again at execution time. Use idempotency and audit logs for provider actions.
6. Handle provider errors explicitly and never imply an email was sent, deleted, or scheduled unless the provider confirms success.

### Evaluation and operations

Evaluate summary coverage, factual fidelity to the thread, draft usefulness, recipient/action correctness, latency, user edit/accept rates, and privacy/security incidents. Test malicious instructions in messages, spoofed senders, thread ambiguity, quoted text, stale mailbox state, and revoked permissions. Provide easy “undo” where supported and clear controls to delete stored indexes and revoke access.

### Trade-offs, bottlenecks, and capacity assumptions

Indexing the entire mailbox improves search but increases privacy surface, storage, and sync cost; on-demand retrieval reduces retained data but may increase latency. Larger thread context can improve continuity yet risks token cost and distraction. Provider API quotas, attachment parsing, and mailbox synchronization can bottleneck more than generation. Estimate work from active users × mailbox size/change rate × queries per user, with attachment and thread-length distributions; these are unspecified, so use incremental sync, per-user budgets, and narrow scopes by default.

### Concise interview answer

“I’d use narrowly scoped, revocable mailbox access, incremental sync, and permission-aware retrieval. The model can summarize or draft from relevant thread context, but email content is untrusted and cannot authorize tools. I’d keep actions read-only or draft-only by default; before sending or deleting, show the exact action and require confirmation, then verify provider success. Encryption, account isolation, retention/deletion controls, auditability, and tests for prompt injection are essential. Capacity is driven by mailbox churn, thread size, attachment parsing, and provider limits.”

### Revision summary

| Concern | Control |
|---|---|
| Sensitive mailbox data | Narrow OAuth scopes, encryption, isolation, revocation/deletion. |
| Prompt injection | Treat email/attachments as untrusted data. |
| Side effects | Draft-first, exact-action confirmation, idempotency and provider verification. |
| Quality | Thread-grounded summaries, recipient/action checks, user feedback. |
| Capacity | Mailbox size/churn, thread/attachment size, provider quotas and request rate. |

<br><br><br>

## Design a medical diagnosis assistant using AI.

**Answer:**

### Intended use and clinical boundary

Clarify users (patient, clinician, or care team), intended use, supported conditions and regions, clinical setting, data sources, and whether the system is informational, triage support, or clinician decision support. A system that influences diagnosis or treatment can have substantial safety and regulatory implications. It should not present itself as a definitive diagnosis or replace a qualified clinician; establish clinical governance and legal/regulatory review before deployment.

### Architecture

```text
Patient / clinician interface
  -> identity, consent and role authorization
  -> structured symptoms + approved record integration
  -> data validation, terminology mapping and provenance
  -> evidence retrieval from approved, current clinical sources
  -> validated clinical model / rules / decision support
  -> uncertainty, contraindication and escalation checks
  -> clinician review or appropriate care guidance

Supporting: audit, privacy/security, clinical evaluation,
incident response, version control and monitoring
```

### Safe workflow

1. Identify the user role, collect only necessary information, and distinguish patient-reported facts from verified records. Check units, timestamps, allergies, medications, and missing data.
2. Detect urgent red flags using clinically validated rules/workflows; direct users to emergency or professional care as appropriate rather than delaying with extended model interaction.
3. For non-emergency use, retrieve relevant evidence from approved, versioned clinical sources and provide source dates. Do not rely on model weights as the sole authority for current medical guidance.
4. Generate a differential or triage suggestion only within the validated intended use, include uncertainty and missing-information caveats, and avoid unsupported certainty or treatment directives.
5. Route decisions to a licensed clinician when required. Provide evidence and data provenance so the clinician can independently review; the model must not silently place orders or modify records.
6. Record auditable model/version, input provenance, evidence, output, and clinician action under strict privacy controls. Support correction and incident reporting.

### Validation and governance

Evaluate with representative clinical cases and qualified clinicians, including subgroup performance, calibration, false reassurance, false alarm, and urgent-case sensitivity. Use prospective workflow evaluation before broad deployment and monitor distribution shift and adverse events. Protect health data with strong access controls, encryption, retention limits, and applicable privacy/security controls. Establish clinical safety review, change control, and rollback.

### Trade-offs, bottlenecks, and capacity assumptions

Richer patient history can improve context but increases privacy risk, integration complexity, and the chance that stale or incorrect records mislead the system. Conservative escalation reduces missed emergencies but may overwhelm clinicians and cause false alarms; thresholds must be clinically governed. EHR/API availability and clinician review capacity may dominate latency, not inference. The prompt specifies no population, setting, or throughput, so capacity must be based on encounter volume, clinician-review fraction and time, integration limits, and peak urgent-case load. Do not trade safety thresholds for throughput without clinical approval.

### Concise interview answer

“I’d first define and govern the intended clinical use, then build a provenance-aware workflow that validates patient data, detects urgent red flags, retrieves current approved evidence, and communicates uncertainty. It supports—not replaces—a clinician, and high-risk cases escalate promptly. No consequential diagnosis or treatment action should occur without the required qualified review. I’d validate prospectively with clinicians, monitor subgroup and safety outcomes, protect health data, and size around encounter volume and human-review capacity rather than model throughput alone.”

### Revision summary

| Layer | Safety requirement |
|---|---|
| Intended use | Defined scope, clinical governance, regulatory/legal review. |
| Data | Consent, provenance, units, timestamps, missingness and privacy controls. |
| Reasoning | Approved current evidence, uncertainty, validated red-flag escalation. |
| Action | Clinician oversight; no silent diagnosis/treatment side effects. |
| Capacity | Encounter mix, urgent escalation, EHR limits, clinician-review throughput. |

<br><br><br>

## Design a fraud detection system powered by LLMs.

**Answer:**

### Role of the LLM

Clarify fraud types, decision latency, transaction volume, available labels, investigation workflow, and regulatory/explainability requirements. An LLM should generally **not** be the sole real-time fraud decision engine: structured, low-latency classification and rules are better suited to transaction scoring. Use the LLM where it adds value to unstructured evidence, analyst investigation, case summarization, or explanation, with human review for consequential actions.

### Architecture

```text
Transactions + device/account/network signals
  -> validation, feature store and entity graph
  -> deterministic rules + supervised/anomaly models
  -> calibrated risk score / decision policy
  -> approve / step-up authentication / hold / review / decline
  -> case management and investigator feedback

Unstructured evidence -> safe document/message extraction
                       -> LLM case summary / evidence references
                       -> investigator review (not autonomous disposition)
```

### Detection and investigation flow

1. Validate event schema, identity, timestamps, and duplicate/idempotency keys; compute features within the transaction latency budget.
2. Score with rules and task-specific models using account history, device signals, velocity, graph relations, and relevant context. Apply decision thresholds that reflect false-positive and false-negative costs.
3. Use policy-controlled actions: approve, request step-up verification, hold for review, or decline. Keep deterministic constraints and access controls outside the LLM.
4. For analyst cases, retrieve only authorized records and documents. Use the LLM to extract structured facts or summarize evidence with source references; validate extracted fields and mark uncertainty.
5. Treat all transaction notes, emails, and documents as untrusted input. Prevent prompt injection from invoking tools or changing a fraud disposition. The LLM should have no unrestricted payment/account mutation capability.
6. Present evidence and model signals to investigators, capture decisions and outcomes, and feed adjudicated labels into carefully governed retraining.

### Evaluation, fairness, and operations

Measure precision/recall at operational thresholds, fraud loss, false-decline/customer friction, detection latency, calibration, investigator workload, and performance across relevant populations and channels. Handle delayed labels and concept drift; avoid leakage from post-outcome features. Log decision versions and evidence for audit/appeal. Protect sensitive financial data and apply least privilege, retention, and incident-response controls.

### Trade-offs, bottlenecks, and capacity assumptions

Very low-latency transaction paths favor compact models and precomputed features; complex graph or LLM analysis may be too slow or unpredictable for synchronous authorization. More aggressive thresholds can reduce fraud loss but increase legitimate-user friction. Investigator queues and feature-store/graph lookups often bottleneck system effectiveness. Size the real-time path using peak transaction QPS and a strict latency budget; size the LLM case path separately from alert volume × average evidence tokens × analyst-review time. Transaction rate, model latency budget, and fraud base rate are unspecified, so do not claim a throughput or cost without measurement.

### Concise interview answer

“I’d use rules and calibrated structured models for real-time transaction scoring, with an explicit policy layer for approve, step-up, hold, or decline. The LLM is a bounded assistant for extracting and summarizing unstructured case evidence, with citations and analyst review—not the sole fraud classifier or an autonomous account-action tool. I’d evaluate fraud loss and false positives, calibration, latency, fairness, and investigator capacity, and keep the synchronous scoring path separate from slower LLM investigation.”

### Revision summary

| Component | Role |
|---|---|
| Real-time scoring | Rules, structured features, supervised/anomaly models. |
| Decision policy | Calibrated thresholds and controlled step-up/review/decline actions. |
| LLM | Bounded extraction/summarization of unstructured case evidence. |
| Governance | Human investigation, auditability, fairness, privacy and drift controls. |
| Capacity | Peak transaction QPS vs. separate alert/investigation workload. |

<br><br><br>

## Design an AI-powered data extraction pipeline from unstructured documents.

**Answer:**

### Requirements and output contract

Clarify document types and layouts, languages, volume and arrival pattern, required fields, accuracy thresholds, downstream consumers, latency, retention, and whether humans must approve results. Define a typed output schema with field-level requirements, units, allowed values, nullability, and validation rules. Extraction is not merely fluent summarization: every material field should be traceable to source evidence, and missing or ambiguous values must not be silently invented.

### Architecture

```text
Sources / uploads -> identity, file validation, malware scan
                  -> immutable raw-object store
                  -> document classification / routing
                  -> parse, OCR, layout/table extraction
                  -> normalize + page/region provenance
                  -> schema-guided extraction
                  -> deterministic validation + confidence checks
                  -> human review queue (when required)
                  -> versioned structured output / downstream systems

Supporting: retries, idempotency, audit, retention/deletion,
model/prompt registry, monitoring and evaluation
```

### Processing workflow

1. **Ingest safely:** Authenticate sources, validate format/size, scan files, assign a stable document ID and version, and store the original under access controls. Make ingestion idempotent.
2. **Classify and parse:** Route by document family. Extract text, layout, tables, and page/region coordinates using native parsing or OCR as appropriate. Record parse errors and preserve page numbers, spans, and table cell locations.
3. **Normalize carefully:** Handle rotations, encoding, headers/footers, dates, currencies, and units without discarding source text. Keep raw and normalized representations linked so a reviewer can trace changes.
4. **Extract to a schema:** Use deterministic parsers for stable formats and models for variable language/layout. Provide relevant context and require structured output conforming to a schema. Ask the model for evidence spans per field where feasible; evidence is a trace aid, not proof by itself.
5. **Validate:** Enforce types, required fields, cross-field/business rules, arithmetic constraints, and source-span consistency. Distinguish “not present,” “illegible,” “ambiguous,” and “failed” rather than filling gaps with guesses.
6. **Route by risk/confidence:** Auto-accept only fields/workflows whose measured error risk meets the application’s threshold; route low-confidence, conflicting, high-impact, or novel documents to trained reviewers.
7. **Publish and monitor:** Write versioned results with provenance and status; use idempotent downstream updates and correction workflows. Monitor extraction accuracy, schema failures, parse/OCR quality, review rate, and drift.

### Security and evaluation

Treat document contents as untrusted input; prompt injection in a PDF must not change extraction rules or authorize tools. Enforce source-level permissions through parsing, storage, review interfaces, and logs. Apply encryption, least privilege, retention/deletion controls, and audit trails. Evaluate field-level exactness/precision/recall, normalization, evidence localization, document-level completion, reviewer overturn rate, and performance by layout, language, scan quality, and source.

### Trade-offs, bottlenecks, and capacity assumptions

Native parsing is cheaper and faster for clean digital documents; OCR/layout models handle scans and complex tables but add latency and error modes. LLM extraction is flexible across varied layouts, while deterministic rules are easier to audit for stable templates. Human review raises quality for risky fields but can become the throughput bottleneck. Estimate capacity from documents/day × pages/document × OCR and model cost per page, plus the fraction sent to review × review time. Volume, page counts, schema width, and latency are unspecified, so benchmark representative document classes and plan queue capacity for bursts.

### Concise interview answer

“I’d build an idempotent pipeline that validates and stores the original, classifies the document, parses text/layout with OCR when needed, and preserves page-level provenance. Extraction produces a typed schema with field evidence, followed by deterministic and cross-field validation. Missing or ambiguous fields stay explicit; high-risk or low-confidence cases go to human review before downstream publication. I’d evaluate field accuracy and evidence localization by document type, and size compute and reviewers from pages processed and the review rate.”

### Revision summary

| Stage | Key control |
|---|---|
| Ingestion | Validate, scan, version, store original, idempotent processing. |
| Parsing | Text/layout/OCR with page and region provenance. |
| Extraction | Typed schema, field evidence, explicit missing/ambiguous states. |
| Validation | Rules, consistency checks, confidence-based review. |
| Capacity | Pages, OCR/model cost per page, review fraction and queue time. |

<br><br><br>

## Design a Text-to-SQL system over a data warehouse with thousands of tables.

**Answer:**

### Requirements and safety boundary

Clarify supported users, question types, warehouse/query engine, latency and cost budgets, freshness, data sensitivity, and whether the system may only read or also create artifacts. The core invariant is that generated SQL must run only under the requesting user’s authorized, read-only scope unless a separately approved workflow says otherwise. The LLM should not have unrestricted warehouse credentials.

### Architecture

```text
User question -> identity / policy / intent
              -> governed catalog + semantic layer
              -> relevant schema retrieval (tables, columns, joins, metrics)
              -> SQL generation with dialect/version context
              -> parse / static policy checks / EXPLAIN
              -> sandboxed read-only execution with resource limits
              -> result validation and explanation
              -> query + provenance + audit
```

### Query workflow

1. Authenticate the user and obtain current roles, row/column policies, and allowed schemas from the warehouse or trusted authorization layer.
2. Resolve ambiguity early: ask what metric, time range, population, or business definition the user means. Prefer a governed semantic layer for canonical metrics and approved join paths.
3. Retrieve schema selectively rather than placing thousands of tables into the prompt. Use catalog search, descriptions, lineage, usage, sample metadata, and relationship graphs to shortlist tables/columns. Avoid exposing restricted schema details.
4. Generate SQL in the correct dialect and bind user values as parameters where supported. The model may draft SQL, but a parser/validator enforces read-only statements, allowed objects, limits, and policy constraints.
5. Run EXPLAIN or cost estimation first when available. Execute in a read-only, resource-governed environment with statement timeout, row/scan limits, concurrency controls, and user identity propagated for row-level security.
6. Validate result shape, empty/truncated/error states, and metric consistency. Explain the query in plain language and expose SQL/provenance for review; do not imply a failed query succeeded.
7. Log query template, schema/catalog version, policy outcome, execution stats, and user feedback under data-retention controls.

### Evaluation and governance

Build a benchmark of natural-language questions, gold SQL or result equivalence, and expected policy behavior. Evaluate execution accuracy, result correctness, clarification behavior, unsafe-query rejection, latency, scanned bytes, and fairness across schema domains. Include adversarial prompts, prompt injection in catalog descriptions, ambiguous metrics, and permission-bypass tests. Use query lineage and reviewed feedback to update catalog descriptions and the semantic layer.

### Trade-offs, bottlenecks, and capacity assumptions

Schema retrieval reduces prompt size and irrelevant joins but can omit the needed table; semantic layers improve consistency but require governance and maintenance. Generating SQL is often not the bottleneck: catalog search, warehouse queueing, scans, and result transfer can dominate latency and cost. A text-to-SQL model cannot make an expensive query safe merely by generating valid syntax. Estimate demand from concurrent users, query rate, average scanned bytes/runtime, and catalog-retrieval cost; thousands of tables says little about query load. User count, warehouse size, and SLOs are unspecified, so enforce budgets and benchmark representative questions and query plans.

### Concise interview answer

“I’d authenticate the user, retrieve only relevant governed schema and metric definitions, and generate SQL in the correct dialect. Before execution, a parser and policy layer restrict it to authorized read-only objects, parameterize inputs, estimate cost, and apply time, scan, and row limits. Execution uses the user’s warehouse permissions; results are validated and shown with SQL and provenance. I’d evaluate result correctness and unsafe-query rejection, while capacity planning focuses on warehouse scans and concurrency—not just the number of tables.”

### Revision summary

| Layer | Requirement |
|---|---|
| Schema context | Catalog/semantic retrieval instead of loading all tables. |
| Security | User identity, row/column policies, read-only enforcement. |
| Query validation | Parse, allowlist, parameterize, EXPLAIN, resource limits. |
| Results | Validate, explain, expose SQL/provenance and explicit failures. |
| Capacity | Concurrent queries, scan bytes/runtime, catalog and warehouse limits. |

<br><br><br>

## Design a personalized learning assistant.

**Answer:**

### Learning goals and boundaries

Clarify learner age and context, subject/curriculum, learning objectives, accessibility and language needs, session frequency, educator/guardian involvement, and whether the assistant is formative practice or formal assessment. Define outcomes such as mastery and retention, not just session duration or answer acceptance. For minors or sensitive education records, apply appropriate consent, privacy, and safeguarding requirements.

### Architecture

```text
Learner / educator UI
  -> identity, consent, accessibility and curriculum scope
  -> learner model (mastery, goals, preferences, recency)
  -> approved curriculum/content retrieval
  -> tutor orchestrator (hint, explanation, practice, feedback)
  -> misconception / mastery update
  -> progress view and educator controls

Supporting: content review, assessment bank, privacy controls,
evaluation, safety escalation and model/version registry
```

### Tutoring loop

1. Establish learning goal and current knowledge with a short diagnostic or learner choice; do not infer ability or identity from sensitive traits.
2. Retrieve age- and curriculum-appropriate material from vetted sources. Preserve lesson/source provenance and align explanations to the requested level.
3. Prefer scaffolding: ask questions, offer hints, show worked examples, and adapt difficulty based on demonstrated understanding. Avoid immediately giving the answer when the learning objective is practice, unless the learner asks or accessibility needs require a different approach.
4. Check understanding with low-stakes practice and feedback. Update mastery estimates from multiple observations, with uncertainty and recency; a single correct answer should not permanently label mastery.
5. Detect frustration, confusion, unsafe disclosures, or out-of-scope requests and respond supportively or escalate to an educator/appropriate adult when policy requires.
6. Give learners and authorized educators transparent controls over goals, progress, history, and data. Avoid high-stakes automated grading or placement without validated governance and human oversight.

### Evaluation and safety

Evaluate learning gains and delayed retention through valid assessments or controlled studies, alongside explanation correctness, hint usefulness, calibration, accessibility, engagement quality, and privacy/safeguarding incidents. Check for answer leakage, bias across learner groups, hallucinated instruction, and overdependence. Provide educator-reviewed content and report uncertainty rather than inventing curriculum facts.

### Trade-offs, bottlenecks, and capacity assumptions

Personalization can improve relevance but requires more learner state, content selection, and privacy safeguards; generic tutoring is simpler and easier to audit. More frequent assessment improves adaptation but can interrupt learning and create noisy mastery estimates. Content curation and educator review may bottleneck quality more than inference. Estimate load using active learners × sessions per learner × turns per session, plus curriculum retrieval and human escalation. The prompt lacks learner scale, age groups, subject breadth, and response-time targets, so pilot by subject/age slice and capacity-plan educator escalation separately.

### Concise interview answer

“I’d build a curriculum-grounded tutor with a transparent learner model that tracks goals and uncertain mastery, not fixed labels. It retrieves vetted content, uses hints and practice to scaffold learning, checks understanding, and updates state from repeated evidence. Learner/educator controls, age-appropriate safety, privacy, accessibility, and human oversight are core requirements. I’d evaluate actual learning and retention—not just engagement—and size from active learners, session turns, curriculum coverage, and escalation rates.”

### Revision summary

| Component | Purpose |
|---|---|
| Learner model | Goals, preferences, mastery estimates with uncertainty/recency. |
| Content | Vetted, curriculum-aligned, source-grounded material. |
| Tutor loop | Diagnose, scaffold, practice, feedback, update. |
| Safeguards | Age-appropriate policy, privacy, accessibility, educator control. |
| Capacity | Active learners, sessions, turns, content breadth and escalation. |

<br><br><br>

## Design an AI system for automated code migration.

**Answer:**

### Scope and migration contract

Clarify source/target languages and versions, repository count/size, migration rules, dependency/tooling changes, allowed code transformations, downtime constraints, and whether the system may open pull requests or merge changes. Define success as behavior-preserving, reviewable migration with explicit unsupported cases—not merely syntactically valid code.

### Architecture

```text
Repositories -> inventory / dependency and version analysis
             -> migration planning and rule selection
             -> AST/codemod transformations
             -> model-assisted ambiguous changes
             -> formatter / compiler / tests / static analysis
             -> diff and risk report
             -> developer review / staged merge
             -> migration telemetry and rollback
```

### Migration workflow

1. Discover repository versions, dependencies, build/test commands, and generated/vendor files. Exclude paths outside the approved migration scope.
2. Create a baseline: run existing tests and record known failures so the migration is not blamed for pre-existing issues.
3. Build a deterministic codemod for mechanical transformations using syntax trees and type/symbol information where available. Use a model only for context-dependent changes, and provide surrounding definitions and target-version documentation.
4. Apply changes in small, idempotent batches. Preserve formatting and comments where possible; mark uncertain or unsupported cases instead of guessing.
5. Run formatting, compilation/type checks, targeted tests, full tests as appropriate, and static/security analysis in a sandbox. Compare behavior and API contracts; passing tests alone is not proof of semantic equivalence.
6. Produce a PR with migration summary, affected patterns, test evidence, residual manual steps, and risk classification. Require human review for behavior changes and broad/high-risk diffs.
7. Roll out incrementally by repository or service, monitor runtime errors, and keep revert commits or feature flags for operational rollback.

### Quality and governance

Evaluate transformation coverage, compile/test pass delta, semantic regressions, false edits, review acceptance, and migration time by pattern. Test on representative repositories before broad automation. Protect secrets and proprietary code; sandbox build scripts and dependency installation with network and credential restrictions.

### Trade-offs, bottlenecks, and capacity assumptions

AST codemods are deterministic and scalable for known patterns but cannot handle all semantic changes; model-assisted transformations cover ambiguity but add nondeterminism, review cost, and error risk. Running full test suites gives stronger evidence but may dominate runtime and CI capacity; baseline plus targeted tests and risk-based full suites can improve throughput. Large monorepo indexing, dependency resolution, and flaky tests are common bottlenecks. Estimate capacity from repositories × files/change density × migration passes and test runtime, then include human review per high-risk diff. The repository count, test times, and migration rate are unspecified, so pilot on representative codebases and track regressions before expanding.

### Concise interview answer

“I’d inventory repositories and establish a baseline, then use syntax-aware codemods for mechanical changes and model assistance only for context-dependent cases. Changes are small, scoped, idempotent, and validated with formatting, compilation, tests, and static checks. Each migration produces a reviewable PR with evidence, residual risks, and rollback; uncertain cases are flagged rather than guessed. I’d scale based on repository/file volume and test runtime, and measure semantic regressions and review load—not just migration speed.”

### Revision summary

| Stage | Control |
|---|---|
| Inventory | Versions, dependencies, scope, baseline failures. |
| Transform | AST/codemod first; bounded model help for ambiguous cases. |
| Validate | Compile, tests, static checks, semantic review, sandbox. |
| Release | Small PRs, human review, staged rollout and rollback. |
| Capacity | Repositories/files, migration passes, CI runtime, review throughput. |

<br><br><br>

## Design an AI-powered legal document review system.

**Answer:**

### Intended use and legal boundary

Clarify document types, jurisdictions, languages, review tasks (clause extraction, comparison, obligation/risk spotting, or summarization), confidentiality rules, and whether the users are lawyers or business teams. The system should support qualified legal review, not present itself as a substitute for counsel or issue unreviewed legal conclusions. Establish privilege, retention, access, and client/matter separation requirements with the organization’s legal and security teams.

### Architecture

```text
Matter/document intake -> identity, consent, malware and format checks
                       -> encrypted matter-scoped storage
                       -> OCR/layout parsing + provenance
                       -> clause/obligation extraction
                       -> versioned legal-source retrieval (if authorized)
                       -> risk rules + LLM analysis with evidence links
                       -> validation / attorney review / annotations
                       -> approved report and audit trail
```

### Review workflow

1. Verify matter access and document provenance; preserve original, version, metadata, and chain of custody as required.
2. Parse text, tables, signatures, and page/paragraph coordinates. Flag OCR uncertainty and missing pages rather than silently proceeding.
3. Classify document type and route to a task-specific checklist or schema. Extract clauses and obligations with exact source spans, parties, dates, conditions, and uncertainty.
4. Retrieve only authorized, current playbooks or legal sources for the jurisdiction and matter. Keep source versions and citations; do not infer that a general web source is authoritative for the case.
5. Generate issue summaries or deviations with evidence and explanation of the applicable checklist/rule. Distinguish text found in the document from legal interpretation or recommendation.
6. Require attorney review for material risk ratings, legal advice, and external communications. Provide side-by-side source text and model suggestion so reviewers can verify and edit.
7. Store reviewer decisions and audit data under matter-specific access and retention policies; support correction, export, and deletion according to legal obligations.

### Quality, security, and governance

Evaluate clause recall/precision, citation/span accuracy, risk-rating calibration, OCR quality, reviewer agreement, and false-negative rates on attorney-labeled examples by document type and jurisdiction. Test prompt injection embedded in documents, confidential data leakage across matters, stale playbooks, conflicting clauses, and malformed scans. Encrypt data, use least privilege, isolate tenants/matters, avoid training on client documents absent explicit authorization, and maintain auditable model/prompt/source versions.

### Trade-offs, bottlenecks, and capacity assumptions

Broad context can help identify cross-document interactions but increases token cost and may miss precise clause-level evidence; structured extraction plus targeted retrieval is more auditable but needs robust parsing and indexing. OCR and human attorney review often dominate throughput, especially for poor scans and high-risk issues. Automation can accelerate triage but must not remove required legal judgment. Estimate workload from matters × documents/pages per matter × OCR/extraction cost, plus attorney-review fraction × review time. Jurisdiction count, document mix, and review SLA are unspecified, so pilot with representative counsel-labeled sets and capacity-plan reviewers separately.

### Concise interview answer

“I’d build a matter-isolated workflow that preserves originals and page-level provenance, parses/OCRs documents, extracts clauses into a schema, and compares them with authorized playbooks or sources. The model reports evidence-linked issues and uncertainty; it does not deliver unreviewed legal conclusions. Attorneys verify material findings in a side-by-side review UI. I’d evaluate clause recall, citation accuracy, risk calibration, and privacy leakage, and size capacity around pages, OCR quality, and required attorney review.”

### Revision summary

| Layer | Requirement |
|---|---|
| Matter governance | Confidentiality, privilege, access and retention boundaries. |
| Evidence | Original/version, page-level spans, OCR uncertainty, source citations. |
| Analysis | Structured extraction, checklist deviations, explicit uncertainty. |
| Human control | Attorney review for material legal conclusions/actions. |
| Capacity | Documents/pages, OCR workload, review fraction and counsel time. |

<br><br><br>

## Design a conversational AI system with memory across sessions.

**Answer:**

### Requirements and memory boundaries

Clarify what continuity should mean: remembering preferences, facts, unresolved tasks, or prior conversation details; how long memory persists; whether users can inspect/edit/delete it; and what data must never be retained. Distinguish current-turn context from durable memory and historical transcripts. Memory should be user-scoped, purpose-limited, and transparent—not an indiscriminate archive of every chat.

### Architecture

```text
Client -> identity / consent / conversation service
       -> recent-turn store (bounded window)
       -> memory proposal and policy gate
       -> structured profile + optional episodic store
       -> scoped retrieval and conflict resolution
       -> prompt/context assembly -> model
       -> response + citations/controls where appropriate

Supporting: encryption, retention/deletion workflow, audit,
memory review UI, evaluation and versioned extraction logic
```

### Read/write lifecycle

1. Authenticate the account and establish memory settings, tenant/device boundaries, and retention policy.
2. Keep recent turns in bounded session context or a summarization state; do not assume that a summary is equivalent to the full transcript.
3. Extract candidate long-term memories only when relevant and allowed. Prefer explicit user statements or requests; avoid inferring sensitive attributes. Ask for confirmation where a durable memory may surprise the user.
4. Store minimal typed facts or episodic references with provenance, source turn, timestamp, confidence, scope, and expiry/last-confirmed time. Keep conflicting observations rather than silently overwriting when uncertainty matters.
5. On a new turn, retrieve only relevant memories using structured lookup and/or semantic search. Apply account authorization before results enter model context; rank by relevance, recency, and confidence.
6. Resolve stale or conflicting memories by honoring explicit corrections and asking when an important ambiguity remains. Clearly distinguish recalled user-provided facts from model inference.
7. Expose inspect/edit/forget/disable controls. Deletion must propagate to indexes, caches, summaries, and derived stores according to the disclosed retention policy; handle backups and legal retention transparently.

### Quality, privacy, and operations

Evaluate memory precision/recall, helpfulness, stale-memory errors, conflict resolution, unwanted-memory rate, cross-account isolation, and deletion effectiveness. Treat retrieved memory as untrusted contextual data, not instructions. Encrypt at rest/in transit, restrict access, minimize logs, and support export/deletion. Version extraction and retrieval logic so regressions are auditable.

### Trade-offs, bottlenecks, and capacity assumptions

Longer histories can improve continuity but increase prompt tokens, latency, and cost while risking irrelevant or stale context; summarization and selective retrieval reduce cost but may omit details. Structured memory is easier to inspect and update, while episodic vector search is flexible but less deterministic. The write/extraction path and deletion propagation across stores can be operational bottlenecks. Estimate storage from active users × memory items/bytes × retention, plus indexes, versions, and replicas; estimate query cost from turns × retrieval/generation tokens. User count, retention, and session rates are unspecified, so enforce per-user limits and benchmark retrieval and deletion at expected scale.

### Concise interview answer

“I’d separate bounded session context from durable, user-controlled memory. A policy-gated write path stores minimal, provenance-tagged facts or episodic references; a read path retrieves only relevant memories for the authenticated user and handles recency and conflicts explicitly. Users can inspect, correct, disable, or delete memory, and deletion propagates through indexes and caches. I’d evaluate useful recall alongside privacy, stale-memory, and isolation failures. Capacity depends on active users, retention, memory size, and turns per session.”

### Revision summary

| Area | Design control |
|---|---|
| Memory types | Bounded recent context, structured profile, optional episodic references. |
| Write path | Purpose/consent gate, minimal data, provenance, confidence and expiry. |
| Read path | User-scoped relevance retrieval, recency/conflict handling. |
| User control | Inspect, edit, disable, forget, delete. |
| Capacity | Users × retained memory plus indexes; turns × retrieval/generation cost. |

<br><br><br>

## How do you design for latency vs quality trade-offs in AI systems?

**Answer:**

### Start with a measurable quality-of-service target

Latency-versus-quality is not one universal curve. Identify the user-visible task, hard correctness/safety constraints, p50/p95/p99 latency SLOs, throughput, and cost budget. Define which quality dimensions can be traded—such as answer completeness or reranking depth—and which cannot, such as authorization, safety policy, or required validation.

### Design a staged request path

```text
Request validation / cache
  -> fast retrieval or small-model route
  -> confidence / risk / evidence check
  -> optional deeper retrieval, larger model, tool call, or reranker
  -> validated response or explicit abstention/escalation
```

1. **Profile the end-to-end path:** Break out queueing, retrieval, feature/API calls, prompt assembly, prefill, decoding, tool execution, and post-processing. Optimize the measured bottleneck rather than only model token speed.
2. **Use adaptive effort:** Route simple requests to a smaller/faster model or cached result; use a larger model, deeper retrieval, or extra verification when risk or uncertainty warrants it.
3. **Stream and parallelize safely:** Streaming improves perceived latency; parallel retrieval or independent checks may reduce wall time but must respect dependencies, budgets, and cancellation.
4. **Bound work:** Cap input/output tokens, retrieval candidates, tool calls, retries, and deadlines. Prefer a useful partial result or explicit “cannot complete” state over waiting without limit.
5. **Protect minimum quality:** Define quality gates and fallback behavior. A low-confidence answer may abstain or ask a question rather than degrade silently.
6. **Measure trade-offs experimentally:** Compare routes on the same representative test cases; include quality, safety, latency distribution, throughput, and cost. Use controlled online experiments where appropriate and monitor slices so aggregate improvements do not hide regressions.

### Operational considerations

Tail latency often comes from queueing and slow dependencies rather than average model latency. Use admission control, bounded queues, deadlines propagated to downstream calls, cancellation, circuit breakers, and concurrency limits. Record route/model/configuration and explain why a path was selected so quality changes are diagnosable.

### Trade-offs, bottlenecks, and capacity assumptions

Larger models, more retrieved context, reranking, and verification can improve quality but consume tokens, accelerator time, and sequential latency. Batching increases throughput but can increase queueing; speculative or parallel work can waste compute when canceled. The critical bottleneck depends on input/output length, cache hit rate, retrieval/index latency, external tool calls, and concurrency. Capacity needs request rate × per-request resource profile (tokens, model calls, retrieval, tools), not request count alone. With no SLO or traffic profile supplied, benchmark representative workloads and select explicit latency/quality tiers rather than asserting one optimal model.

### Concise interview answer

“I’d set non-negotiable safety/correctness constraints and explicit latency and quality SLOs, then profile the full path. A staged router can use a fast path for simple requests and add larger models, deeper retrieval, or verification when risk and uncertainty justify it. I’d bound tokens, calls, queues, and deadlines, and use streaming where it improves perceived latency. The trade-off is measured on the same test set across quality, p95/p99 latency, throughput, and cost; capacity depends on the request mix and tokens per second.”

### Revision summary

| Lever | Quality/latency effect |
|---|---|
| Smaller model/cache | Faster and cheaper; may reduce capability or freshness. |
| More context/reranking/checks | Better evidence/verification potential; higher cost and latency. |
| Streaming/parallelism | Lower perceived/wall latency; more coordination/compute. |
| Budgets/deadlines | Bound tail latency and cost; require explicit partial/failure behavior. |
| Capacity | Request mix × tokens, model calls, tools, retrieval and concurrency. |

<br><br><br>

## How do you implement caching strategies for LLM applications?

**Answer:**

### Cache only where reuse preserves semantics

Caching can reduce model inference cost and latency, but LLM outputs depend on prompt, model/version, sampling parameters, conversation context, retrieved evidence, tools, and user permissions. Define what may be cached and for whom before selecting a cache layer.

### Cache layers and keys

- **Exact response cache:** Reuse an output only for a semantically identical request/configuration where response reuse is acceptable. Key on canonicalized messages, model/version, system/developer prompt version, decoding settings, tool state, and relevant context.
- **Semantic response cache:** Match near-duplicate queries by embedding similarity. This can improve hit rate but risks returning an answer to a different question; require a calibrated threshold, scope/tenant checks, freshness policy, and often a verification step.
- **Prompt/prefix or KV cache:** Reuse stable computation for common prompt prefixes when the serving runtime supports it. Ensure cache identity includes model/tokenizer and compatible prefix state; avoid cross-tenant data leakage.
- **Retrieval and embedding caches:** Cache query embeddings, retrieval results, or document embeddings by model/index/preprocessing version and authorization scope.

### Correctness, privacy, and operations

1. Include all response-affecting inputs in the key; do not cache tool results or personalized answers without the relevant state and authorization version.
2. Use TTLs and explicit invalidation when model, prompt, source data, permissions, policy, or index changes. Versioned keys reduce stale reads during deployments.
3. Cache only policy-permitted content; isolate tenants and users where needed, encrypt sensitive entries, minimize retention, and support deletion.
4. Use bounded storage, eviction, stampede protection (single-flight/coalescing), and request timeouts. Avoid unbounded retries on cache or backend failure.
5. Monitor hit rate, avoided tokens/cost, stale/wrong-hit rate, latency, eviction, and storage. Validate cache correctness with tests for user, tenant, model, and version boundaries.

Semantic similarity is not proof of equivalent intent. For dynamic facts or actions, prefer caching stable components or retrieval artifacts over a final answer; revalidate current state before any side effect.

### Trade-offs, bottlenecks, and capacity assumptions

Higher TTLs and semantic matching increase reuse but risk stale or mismatched answers; strict exact keys are safer but yield fewer hits. Cache lookup/serialization/network overhead can erase gains for cheap requests, while large prompts and outputs increase storage cost. The cache may shift the bottleneck to retrieval, model capacity on misses, or invalidation fan-out. Estimate savings as requests × hit rate × avoided per-request inference cost, and storage as entry rate × average entry size × retention plus replicas. Traffic repetition, response size, and freshness needs are unspecified, so start with high-confidence, low-risk cache layers and measure wrong-hit rate as a first-class metric.

### Concise interview answer

“I’d cache deterministic, reusable stages first—embeddings, retrieval results, and stable prompt prefixes—then consider exact responses with complete versioned keys. Semantic response caches need stricter relevance thresholds and tenant/freshness checks because similar queries may need different answers. TTL and invalidation must reflect model, prompt, data, and permission changes; actions must always revalidate state. I’d measure hit rate, avoided cost, stale/wrong hits, latency, and storage, not optimize hit rate alone.”

### Revision summary

| Layer | Key requirements |
|---|---|
| Exact response | Full prompt/config/context identity and scope. |
| Semantic response | Similarity threshold, intent/freshness validation, authorization. |
| Embedding/retrieval | Model/index/preprocessing version and permission-aware key. |
| Lifecycle | TTL, invalidation, bounded storage, stampede protection. |
| Capacity | Hit rate × avoided cost; entry rate × size × retention. |

<br><br><br>

## How do you design rate limiting and cost management for AI APIs?

**Answer:**

### Define limits around resource use and fairness

AI requests vary greatly in cost: a long context, large output, multimodal payload, or tool loop may consume far more resources than a short prompt. Use layered limits rather than a single requests-per-minute counter. Clarify service SLOs, tenant tiers, burst behavior, fairness goals, and what happens when budgets are exhausted.

### Admission and accounting

1. Authenticate each request and resolve tenant, user, model, region, and entitlement from trusted server-side identity.
2. Validate payload and estimate cost before admission: input/output token budget, modality, model price/resource class, and expected tool calls. Reject malformed or over-budget work explicitly.
3. Apply token-bucket or leaky-bucket limits at relevant scopes (organization, project, user, model, and global pool), with separate concurrency limits and bounded queues. Add burst budgets only where capacity permits.
4. Reserve estimated quota before execution, meter actual usage, and reconcile the difference. Handle cancellation, partial streams, retries, and provider errors so usage is not double-counted or silently lost.
5. Enforce daily/monthly spend ceilings, per-request maximums, and alerts at budget thresholds. Provide usage dashboards and clear error responses with retry guidance where safe.
6. Prioritize fairly under load; prevent one tenant or expensive workload from starving others. Use backpressure or shed low-priority traffic when capacity is exhausted.
7. Optimize cost through validated model routing, batching, caching, prompt/context reduction, and output-token limits. Do not silently downgrade quality or weaken safety to meet a budget.

### Monitoring and governance

Track tokens and spend by tenant/model/feature, cost per successful task, queue/rejection rate, latency, cache savings, retries, and anomalous usage. Protect billing records and apply least privilege. Make limits observable to clients, and document whether tokens from failed or partial requests are billed.

### Trade-offs, bottlenecks, and capacity assumptions

Fine-grained accounting improves fairness and budget accuracy but adds admission-path state and metering complexity. Strict limits control spend but can reject legitimate bursts; generous bursts can overload GPU pools and harm tail latency. Token estimation is imperfect, particularly for multimodal inputs and provider-specific tokenization, so reserve conservatively and reconcile actual usage. Capacity is constrained by both provider spend limits and local throughput (tokens/sec, concurrency, GPU memory); requests/minute alone is misleading. Tenant distribution, token mix, pricing, and burst profile are unspecified, so set per-resource budgets and calibrate estimates from observed usage.

### Concise interview answer

“I’d authenticate requests and meter resource cost, not just request count. Before admission, estimate tokens/model/modality cost, reserve tenant and global quota, and enforce token-bucket, concurrency, and spend limits with bounded queues. After execution, reconcile actual usage, including cancellations and partial streams. Dashboards, alerts, fair scheduling, and backpressure control operations. Routing, batching, caching, and token limits can reduce cost, but any quality downgrade must be explicit and validated. Capacity planning needs tokens per second, concurrency, modality mix, and provider quotas.”

### Revision summary

| Control | Purpose |
|---|---|
| Token/cost budgets | Bound highly variable request cost. |
| Rate + concurrency limits | Protect service capacity and fairness. |
| Reservation/reconciliation | Account for actual usage and partial failures. |
| Spend alerts/ceilings | Prevent budget surprises and abuse. |
| Capacity | Tokens/sec, concurrency, GPU memory, provider quota and burst shape. |

<br><br><br>

## How do you handle failover and fallback strategies for AI systems?

**Answer:**

### Distinguish failover from fallback

**Failover** moves a request or workload to a healthy equivalent instance/region/provider after a failure. **Fallback** changes the capability or behavior—such as a smaller model, cached response, lexical retrieval, a rules-based flow, or human handoff—when equivalent service is unavailable or too costly. Define which failures are transient, which degrade quality, and which require stopping safely.

### Design the recovery path

1. **Detect and classify:** Use health checks, deadlines, error rates, queue depth, and circuit breakers to distinguish overload, timeout, model failure, dependency failure, and invalid input.
2. **Set retry policy:** Retry only transient, idempotent operations, with bounded attempts, jittered backoff, and an overall deadline. Do not blindly retry non-idempotent tools or already-partially-streamed generations.
3. **Choose a compatible failover:** Route to another healthy replica or region only if model version, tokenizer, policy, data scope, and availability are compatible. Respect residency and tenant-isolation constraints.
4. **Choose a transparent fallback:** Use a smaller/alternate model, stale-but-labeled cache, deterministic workflow, reduced feature set, or human support only if it is safe for the task. Re-evaluate safety and quality; never present a degraded result as equivalent without indication.
5. **Fail closed where needed:** If authorization, safety checks, or required evidence are unavailable, refuse or defer rather than bypassing those controls.
6. **Preserve state and idempotency:** Use request IDs and durable workflow state to avoid duplicate side effects. Return explicit status for partial output and allow clients to resume or restart deliberately.
7. **Recover and learn:** Apply circuit-breaker recovery, staged traffic restoration, post-incident analysis, and tests for dependency and region failures.

### Trade-offs, bottlenecks, and capacity assumptions

Retries and cross-region failover improve success probability but consume extra capacity and can amplify overload or latency; bounded deadlines and load shedding are essential. Alternate models may differ in output quality, features, privacy terms, or tool support. Warm standby increases cost but reduces recovery time; cold failover saves resources but requires model loading and index/state recovery. Capacity must include failure-mode load: if one region/provider is unavailable, surviving capacity must handle transferred traffic or deliberately shed it. Traffic distribution, recovery objectives, model sizes, and fallback quality are unspecified, so test degraded modes and size for explicit RTO/RPO and overload policies.

### Concise interview answer

“I distinguish replica/region failover from capability fallback. I detect failures with health and SLO signals, use bounded retries only for safe idempotent operations, and route to a compatible healthy pool when possible. If equivalent service is unavailable, I use an explicitly disclosed fallback—such as a smaller model, deterministic path, cache, or human handoff—or fail closed when safety, authorization, or evidence checks are required. I test transferred-load capacity and recovery objectives, since retries can worsen overload.”

### Revision summary

| Situation | Response |
|---|---|
| Transient replica failure | Bounded retry/failover with deadline and idempotency. |
| Model/provider outage | Compatible pool or explicitly labeled capability fallback. |
| Safety/auth dependency down | Fail closed or defer. |
| Partial/non-idempotent operation | Preserve state; prevent duplicate side effects. |
| Capacity | Surviving-region load, warm/cold start, RTO/RPO, load shedding. |

<br><br><br>

## How do you design an AI system for high availability and fault tolerance?

**Answer:**

### Define availability at the user-visible workflow

Clarify the availability SLO, latency/error budget, recovery time objective (RTO), recovery point objective (RPO), consistency needs, data residency, and which capabilities are critical versus optional. An AI workflow may depend on several services—identity, retrieval, model inference, tools, storage, and safety checks—so availability is the end-to-end success rate of a safe, useful outcome, not just whether the model endpoint returns HTTP 200.

### Architecture and resilience mechanisms

```text
Client -> global/regional routing -> stateless API replicas
      -> durable request/workflow state
      -> dependency-aware orchestration
      -> replicated model / retrieval / tool services
      -> response validation -> client

Cross-cutting: health checks, deadlines, circuit breakers,
queues, idempotency, backups, telemetry and recovery automation
```

1. **Remove single points of failure:** Run stateless services across failure domains; replicate critical stores and indexes according to consistency and recovery needs. Keep configuration, secrets, and model artifacts recoverable.
2. **Bound work:** Propagate deadlines and cancellation, use bounded queues, concurrency controls, and admission shedding. Prevent overload from turning a partial outage into a system-wide failure.
3. **Isolate dependencies:** Use circuit breakers, bulkheads, timeouts, and dependency-specific health. A failure in optional analytics should not block core responses; a failure in authorization or required safety checks may require fail-closed behavior.
4. **Make operations safe to retry:** Use request IDs and idempotency for side effects; distinguish retryable transient errors from invalid requests and completed/partially streamed generations.
5. **Plan recovery:** Maintain backups, tested restore procedures, replica/index rebuild plans, and documented failover/runbooks. Practice node, zone, provider, and region failures with game days.
6. **Deploy safely:** Use canaries, health gates, rollback, and compatible schema/model changes. Avoid simultaneous changes that make incident diagnosis difficult.
7. **Observe user outcomes:** Monitor end-to-end success, latency percentiles, queue depth, dependency errors, recovery time, data lag, and quality/safety indicators.

### Trade-offs, bottlenecks, and capacity assumptions

More replicas and regions improve fault tolerance but increase cost, coordination, and consistency complexity. Active-active operation can reduce failover time but requires conflict handling and sufficient capacity in every region; warm standby is cheaper but has recovery delay. Redundancy must cover correlated failures, not just single-process crashes. During a failure, surviving capacity must support transferred traffic or deliberately shed load. No traffic, SLO, or RTO/RPO values are specified, so use workload tests and failure exercises to set replica counts, headroom, backup cadence, and recovery targets.

### Concise interview answer

“I define availability for the full user workflow and set explicit SLO, RTO, and RPO targets. I eliminate single points of failure, bound queues and deadlines, isolate optional dependencies, make retries safe with idempotency, and fail closed when required authorization or safety controls are unavailable. Backups and failover are tested through failure exercises, not assumed. I size surviving capacity for transferred peak load and monitor end-to-end success and quality, not just model uptime.”

### Revision summary

| Principle | Implementation |
|---|---|
| Redundancy | Replicas across independent failure domains; tested backups. |
| Fault isolation | Deadlines, bounded queues, bulkheads, circuit breakers. |
| Safe recovery | Idempotency, replay/rebuild plan, runbooks and game days. |
| AI-specific safety | Preserve authorization and safety gates during fallback. |
| Capacity | Failure-mode load, headroom, RTO/RPO and recovery tests. |

<br><br><br>

## How do you design an AI system that gracefully degrades when the model is unavailable?

**Answer:**

### Decide what can safely degrade

Start by classifying requests and dependencies: which tasks can use a cached or deterministic answer, which can use a smaller/alternate model, and which must stop because model output, current evidence, authorization, or safety validation is essential. “Graceful” means the user gets a clear, safe outcome—not a fabricated success or silent quality downgrade.

### Request path and fallback ladder

```text
Request -> auth / validation -> model health + admission
        -> primary model
        -> compatible alternate or approved smaller model
        -> task-specific cache / deterministic workflow
        -> explicit defer, retry-later, or human handoff
```

1. Detect unavailability using health signals, timeouts, queue pressure, and circuit breakers; distinguish provider outage from overload or request-specific errors.
2. Apply an overall deadline and retry only transient, safe operations with bounded attempts and jitter. Respect partial-stream state and avoid duplicate side effects.
3. Route to an alternate model only if its capabilities, policy, data scope, and quality are acceptable for that task. Do not send sensitive data to a provider with incompatible terms or residency.
4. Use a cache only when freshness, user/tenant scope, and request equivalence are established. Mark stale information where appropriate; do not use cached generated actions as authority.
5. Fall back to deterministic rules, keyword search, saved draft, or human assistance for tasks where those paths remain correct. If required model-based safety or evidence checks are unavailable, fail closed or defer.
6. Communicate the state clearly: distinguish “unavailable,” “queued,” “partial,” and “completed.” Offer retry or alternate workflow without claiming the requested task succeeded.
7. Restore traffic gradually after recovery, monitor quality/latency, and retain incident diagnostics without logging unnecessary sensitive content.

### Evaluation and operations

Test provider outages, regional failure, latency spikes, rate limits, malformed partial streams, and cache staleness. Measure fallback success, quality delta, user abandonment, queue wait, error rate, and recovery time. Include capacity reserved for the fallback path and ensure it does not become an overload amplifier.

### Trade-offs, bottlenecks, and capacity assumptions

Alternate models and retries can improve availability but may increase latency, cost, or output inconsistency; retries against an overloaded service can worsen the outage. Deterministic paths are predictable but may support fewer tasks; human handoff is safer for complex cases but depends on staffed capacity. Cached answers improve speed only when permission and freshness remain valid. Capacity assumptions must include the outage case: transferred traffic, alternate-model quotas, cache hit rate, and human queue throughput. Traffic mix and outage duration are unspecified, so define per-task fallback eligibility and test it under sustained failure.

### Concise interview answer

“I’d define per-task fallback policy before an outage: compatible alternate model, fresh scoped cache, deterministic reduced workflow, human handoff, or safe refusal. Health checks, bounded retries, deadlines, and circuit breakers prevent cascading failures; side effects remain idempotent and explicit. I would never bypass required authorization or safety checks, and I’d tell users when a result is partial or unavailable. I’d load-test fallback capacity and measure quality loss, queueing, and recovery.”

### Revision summary

| Failure case | Safe response |
|---|---|
| Primary model down | Compatible alternate if policy and quality permit. |
| Stale/current facts needed | Fresh authorized retrieval or defer; do not trust stale cache. |
| Safety/auth dependency down | Fail closed or hand off. |
| Prolonged outage | Deterministic limited workflow or human queue. |
| Capacity | Outage traffic, alternate quotas, cache validity, human throughput. |

<br><br><br>

## What are the key considerations for multi-region deployment of AI systems?

**Answer:**

### Requirements and regional boundaries

Clarify user geography, latency SLOs, data residency and transfer rules, availability targets, consistency requirements, model/provider availability, and RTO/RPO. Decide whether regions serve independent user populations, active-active traffic, or active-passive failover. AI systems have region-specific dependencies: model endpoints, GPU capacity, embeddings/indexes, prompts, secrets, and safety policies must all be available and compatible.

### Architecture and data flow

```text
Global DNS / traffic manager
  -> regional API + auth + quota enforcement
  -> regional model workers / approved provider endpoint
  -> regional retrieval index and policy/config
  -> regional data stores and telemetry

Controlled replication: model artifacts, indexes, metadata,
configuration and permitted user data
```

1. **Route by policy and health:** Choose a region based on user location, residency, service health, capacity, and model capability. Do not route data across borders merely because another region is available.
2. **Replicate stateless services and artifacts:** Version and verify model weights, tokenizers, prompts, safety rules, and index snapshots. Ensure a regional rollout uses a compatible bundle.
3. **Choose state consistency deliberately:** Conversation state, quotas, memory, and writes may require strong consistency, regional ownership, or eventual replication. Define conflict resolution and behavior during partitions.
4. **Protect identity and secrets:** Use region-appropriate key management, least privilege, tenant isolation, and audit trails. Avoid placing sensitive prompts or outputs in global logs by default.
5. **Plan failover:** Define health thresholds, traffic shift, data freshness, warmup/model-loading time, and failback. Ensure the target region has capacity or intentionally sheds load.
6. **Handle indexes and caches:** Keep retrieval vectors and query embeddings version-compatible; replicate or rebuild indexes with freshness/ACL guarantees. Scope caches by model, region, tenant, and authorization state.
7. **Test regional failure and recovery:** Exercise region isolation, network partition, identity-provider outage, index lag, and recovery of asynchronous jobs.

### Observability and compliance

Track per-region availability, latency, model quality, capacity, queue depth, replication lag, data residency, and failover outcomes. Keep logs regionally scoped as required, retain data only under policy, and make the routing decision auditable.

### Trade-offs, bottlenecks, and capacity assumptions

Active-active reduces regional failover time and user latency but increases replication, consistency, and duplicate-work complexity. Active-passive is simpler and may reduce cost, but cold model loading, index warmup, and state recovery raise RTO. Replicating full indexes and model artifacts improves readiness but consumes storage/bandwidth; rebuilding on demand saves replication but extends recovery. Cross-region calls may violate residency and add network latency. Capacity must tolerate the chosen failover scenario—often a full region’s peak traffic shifted to survivors—or apply explicit admission shedding. User distribution, data rules, model footprints, and RTO/RPO are unspecified, so benchmark replication and failover rather than assume symmetrical regions.

### Concise interview answer

“I’d make regional routing policy-aware, so residency and user scope are checked before health-based failover. Each region needs compatible model, tokenizer, policy, retrieval index, and secrets, while state replication follows explicit consistency and RPO requirements. Active-active improves availability but adds coordination; active-passive is simpler but slower to recover. I’d test model/index warmup, replication lag, partitions, and failover under peak transferred load, and monitor quality and residency per region.”

### Revision summary

| Decision | Concern |
|---|---|
| Routing | Latency, health, capacity, residency and capability. |
| State | Consistency, replication lag, conflicts, RPO. |
| AI artifacts | Version-compatible models, prompts, policies and indexes. |
| Mode | Active-active versus active-passive recovery/cost complexity. |
| Capacity | Failover traffic, warmup, replication and data-transfer limits. |

<br><br><br>

## Design an AI-powered search engine for an e-commerce platform.

**Answer:**

### Requirements and relevance goals

Clarify catalog size and churn, query volume, markets/languages, product attributes, personalization and privacy constraints, inventory/price freshness, latency SLOs, and business goals. Optimize not only semantic relevance but also exact product matching, availability, policy compliance, conversion and customer satisfaction. Hard requirements such as discontinued items or restricted products should be enforced by trusted catalog/business logic, not left to the model.

### Architecture

```text
Catalog / inventory / pricing / content
  -> validation, normalization, attribute extraction
  -> lexical index + product embeddings + facet index
  -> incremental updates and versioned indexes

Query -> normalize / spell / intent / optional rewrite
      -> lexical + dense candidate retrieval
      -> availability, locale and policy filters
      -> ranking (relevance + structured features)
      -> personalization / diversity / facets
      -> results with explanations and analytics
```

### Indexing and query flow

1. Ingest products with stable IDs, variants, attributes, descriptions, images, taxonomy, price, inventory, locale, and update timestamps. Validate units and normalize synonyms without losing canonical values.
2. Generate lexical fields and embeddings from appropriate text/image representations. Version models and preserve a link to catalog source/version.
3. Apply incremental updates for inventory, price, and availability with freshness guarantees; use full rebuilds for major schema/model migrations, with shadow indexes and rollback.
4. At query time, interpret intent and extract structured constraints (brand, size, price range, category) while preserving exact terms and product codes.
5. Retrieve a broad candidate set with lexical and dense search, fuse/rerank, then apply hard eligibility filters from authoritative current inventory/policy. Avoid letting personalized ranking resurrect unavailable or disallowed items.
6. Rank using relevance plus calibrated business features, with controlled personalization and diversity. Explain filters and provide refinements when the query is ambiguous or has no result.
7. Log impressions, position, clicks, purchases, and reformulations with privacy controls; use time-aware evaluation to account for delayed conversion and exposure bias.

### Evaluation and governance

Measure Recall@k/NDCG, exact-match success for SKU/brand queries, zero-result rate, add-to-cart/conversion, latency, inventory freshness, diversity, and subgroup or locale quality. Use A/B tests with guardrails; avoid optimizing clicks at the cost of relevance, user trust, or fairness. Monitor index lag, stale price/stock, and feed failures.

### Trade-offs, bottlenecks, and capacity assumptions

Dense retrieval improves paraphrase matching but can blur exact attributes; lexical retrieval preserves product IDs and terms but may miss intent. Hybrid search and reranking improve candidate quality at extra query latency and compute. Personalized features can increase relevance but introduce privacy, cold-start, and feature freshness costs. Catalog ingestion and real-time inventory/price lookups are common bottlenecks. Estimate storage from product variants × text/image vectors and indexes; estimate online load from QPS × candidates × reranker/feature calls. Catalog size, update rate, and traffic are unspecified, so benchmark market/seasonal peaks and set explicit freshness and latency targets.

### Concise interview answer

“I’d maintain a normalized, versioned catalog with lexical, vector, and facet indexes plus fast inventory updates. Queries are parsed for exact terms and constraints, searched through lexical and dense channels, fused/reranked, then filtered against authoritative availability and policy before personalization. I’d evaluate exact SKU queries and semantic discovery separately, run guarded experiments, and monitor conversion, relevance, freshness, and latency. The main trade-off is semantic coverage versus exactness and ranking cost; capacity depends on catalog variants, QPS, candidates scored, and update rate.”

### Revision summary

| Layer | Design focus |
|---|---|
| Catalog | Canonical attributes, variants, locale, price/stock freshness. |
| Retrieval | Lexical + dense + facets; preserve exact constraints. |
| Ranking | Relevance, eligibility, personalization, diversity. |
| Evaluation | Query-type metrics, business outcomes, latency and freshness. |
| Capacity | Variants/vectors, QPS, candidate count, updates and feature calls. |

<br><br><br>

## Design an AI gateway/proxy for managing LLM access across an organization.

**Answer:**

### Requirements and policy goals

Clarify which users, teams, applications, and providers are in scope; supported APIs/models/modalities; regional and data-residency constraints; throughput and latency SLOs; and whether the gateway is a mandatory network path or an SDK/library. Define policies for model approval, sensitive-data handling, retention, cost allocation, logging, and emergency provider/model disablement. A gateway centralizes control, but should not become an unbounded single point of failure.

### Architecture

```text
Applications / users
  -> identity and application registration
  -> gateway API (auth, policy, validation, quotas)
  -> data-loss prevention / redaction where permitted
  -> model router / provider adapter
  -> approved provider or internal model pool
  -> response normalization / usage metering
  -> caller

Control plane: model registry, policies, budgets, keys, routing config
Data plane: stateless gateway replicas, queues, provider connections
Audit plane: privacy-scoped usage, policy decisions and incidents
```

### Request lifecycle and governance

1. Authenticate the user/service and resolve organization, project, purpose, entitlement, and budget from trusted identity—not client-asserted headers alone.
2. Validate request shape, model capability, context length, tool definitions, and allowed parameters. Reject unsupported or disallowed requests clearly.
3. Apply policy: approved model/provider, region, data classification, retention terms, and allowed use. Redact or block sensitive data only according to the organization’s documented policy; never silently alter content in a way that changes meaning.
4. Route by task, model capability, health, latency, cost, and residency constraints. Keep provider adapters versioned and normalize streaming/error/usage semantics without concealing provider-specific limitations.
5. Enforce per-user/team/project/model rate limits, concurrency limits, and spend budgets. Use bounded queues, backpressure, and circuit breakers; meter estimated and actual tokens/cost.
6. Apply response policy and record a privacy-minimized audit event: principal, model/provider/version, policy decision, usage, latency, and error class. Avoid retaining prompts/responses centrally unless approved and necessary.
7. Provide dashboards, key rotation/revocation, model allowlists, incident controls, and a documented path for approved exceptions.

### Reliability, security, and observability

Keep the data plane highly available across independent instances; make policy/config updates signed, versioned, and auditable. Store provider credentials in a secrets manager and isolate them from applications. Protect against prompt injection and unsafe tool use by treating model output as untrusted; the gateway cannot replace application-level authorization for business actions. Monitor availability, p95/p99 latency, queue depth, provider errors, policy blocks, token usage, spend, and per-tenant fairness.

### Trade-offs, bottlenecks, and capacity assumptions

A mandatory gateway improves governance and visibility but adds network hops, latency, operational cost, and a centralized failure domain; SDK-only controls are easier to bypass and fragment policy. Deep inspection/redaction can improve data controls but increase latency and create false positives. Provider rate limits, gateway connection pools, policy lookups, and centralized accounting can bottleneck. Estimate capacity from request rate × tokens/modal payload × provider/model mix, plus streaming concurrency and logging volume. Organization size, traffic, and provider limits are unspecified, so use stateless horizontal scaling, bounded queues, regional routing, and load tests against provider quotas.

### Concise interview answer

“I’d separate a highly available data plane from a governed control plane. The gateway authenticates the calling service, enforces model/data/region policies and budgets, routes to approved providers, normalizes responses, and meters actual usage. Provider credentials stay in a secrets manager; prompts are not centrally retained by default. I’d make policies versioned and auditable, apply bounded queues and provider-aware limits, and monitor latency, errors, spend, and policy decisions. The main trade-off is centralized governance versus added latency and a potential chokepoint, so I’d scale regionally and test provider-limit behavior.”

### Revision summary

| Layer | Responsibility |
|---|---|
| Identity/policy | Trusted principal, model allowlist, data and residency rules. |
| Routing | Provider adapters, capability/health/cost-aware selection. |
| Controls | Quotas, concurrency, spend, redaction policy, key rotation. |
| Audit | Privacy-minimized usage and policy decision records. |
| Capacity | QPS, token/modality mix, streaming concurrency, provider quotas. |

<br><br><br>

## How do you design a RAG system that handles conflicting information across sources?

**Answer:**

### Preserve disagreements instead of forcing a single answer

Conflicts may arise because sources have different publication dates, authority, scope, jurisdictions, versions, or definitions—or because one is simply wrong. The system should represent source identity and context, detect materially inconsistent claims, and communicate the conflict with evidence. It should not average incompatible statements or choose whichever passage has the highest embedding score.

### Retrieval and evidence architecture

```text
Sources -> version/date/authority metadata -> chunk + index
Question -> scoped retrieval -> rerank for relevance and source quality
         -> claim/evidence extraction with provenance
         -> conflict grouping and freshness/authority checks
         -> answer with attributed claims / clarification / abstention
```

1. **Capture provenance at ingestion:** Store source, author/publisher, version, effective/publication date, jurisdiction/scope, and supersession relationships where known. Preserve exact spans and document versions.
2. **Retrieve broadly enough:** Use hybrid retrieval and query decomposition to find corroborating and potentially contradictory evidence, not only the top semantic match. Apply user permissions consistently.
3. **Extract atomic claims:** Associate each claim with its source span and qualifiers (date, scope, entity, conditions). Do not combine statements that refer to different versions or populations.
4. **Detect contradictions:** Compare claims about the same entity, time, and proposition. Distinguish true contradiction from compatible scope differences, temporal updates, or terminology differences. Use deterministic rules for structured facts and model-assisted comparison with evidence for less structured cases.
5. **Resolve only with justified precedence:** Apply an explicit source policy (e.g., designated system of record, effective date, jurisdiction, or approved hierarchy). A newer source is not automatically more authoritative; encode domain rules and disclose them.
6. **Answer transparently:** If one source is established as authoritative, state the chosen answer and cite it. If conflict remains unresolved, present both attributed positions and dates, explain the uncertainty, or abstain/ask which scope the user means.
7. **Support corrections:** Log the conflict and reviewer disposition; allow source owners to supersede or correct records and propagate updates/deletions through indexes.

### Evaluation and operations

Create test cases with stale/current, jurisdictional, version, and genuinely contradictory sources. Measure conflict detection/recall, correct precedence, citation support, unsupported synthesis, abstention, and user comprehension. Monitor source freshness and conflict rates; keep a review path for high-impact domains.

### Trade-offs, bottlenecks, and capacity assumptions

Broader retrieval raises the chance of finding contradictions but increases latency, context tokens, and noise; aggressive source filtering is faster but may hide relevant disagreement. Provenance-rich, versioned ingestion makes resolution more reliable but increases metadata and update-maintenance work. Conflict extraction and domain precedence rules can bottleneck review, especially for legal or policy content. Capacity depends on source count/churn, queries requiring multi-source retrieval, and reviewer fraction; none are specified, so tune candidate depth and escalation thresholds on labeled conflict cases rather than assume a universal top-k.

### Concise interview answer

“I’d preserve provenance, date, scope, and version for every retrieved claim, then retrieve enough evidence to compare sources rather than trust the top similarity score. The system groups claims about the same proposition, distinguishes temporal or scope differences from real contradictions, and applies an explicit domain source hierarchy only when justified. If conflict remains, it presents attributed evidence and uncertainty or abstains instead of inventing consensus. I’d evaluate conflict detection, precedence, citation support, and review capacity.”

### Revision summary

| Step | Goal |
|---|---|
| Provenance | Source, version, date, scope and exact evidence span. |
| Retrieval | Find corroborating and conflicting candidates. |
| Comparison | Separate true contradictions from scope/time differences. |
| Resolution | Apply governed precedence or disclose unresolved conflict. |
| Capacity | Retrieval depth, source churn, conflict review and latency. |

<br><br><br>

## How do you approach capacity planning for an AI system?

**Answer:**

### Start from workload and service objectives

Capacity planning translates expected workload and SLOs into compute, memory, storage, network, and human-operations requirements. Define average and peak request rates, burst duration, concurrency, input/output token or media-size distributions, latency percentiles, availability, freshness, and growth horizon. Separate online inference from ingestion, training, evaluation, and human review because their resource profiles differ.

### Estimate demand in units that drive cost

1. **Build workload classes:** Segment by model, modality, context/output length, tool/retrieval path, priority, tenant, and cacheability. Use distributions (including p95/p99), not only average request size.
2. **Estimate inference throughput:** For text generation, estimate input and output tokens per second and active sequences. Benchmark tokens/sec and memory on the actual model/runtime/hardware; weight count alone does not determine serving capacity.
3. **Budget memory:** Include model weights, KV cache as concurrency/context grows, activations/workspaces, batching buffers, runtime overhead, and replicas. For retrieval, add vectors, ANN structures, metadata, caches, and replicas.
4. **Estimate asynchronous work:** For document/audio/video pipelines, use items × pages/seconds/frames × measured compute per unit, plus retry and post-processing cost. Include queue age and freshness constraints.
5. **Include dependencies and people:** Model provider quotas, database/feature-store/API limits, network egress, storage IOPS, reviewer throughput, and on-call/recovery needs.
6. **Add failure and growth headroom:** Account for peak bursts, node/zone/region loss, rolling deployments, model loading, index rebuilds, and forecast growth. Headroom should follow SLO and risk tolerance, not an arbitrary universal percentage.
7. **Validate with load tests:** Replay production-shaped workloads, test saturation and failure modes, and measure throughput, p95/p99 latency, queue depth, error rate, memory, cost, and quality. Revisit estimates as traffic and models change.

Use admission control, quotas, autoscaling signals, and backpressure so overload degrades predictably. Capacity is not just server count: a system may be GPU-bound, memory-bound, provider-quota-bound, retrieval-bound, or reviewer-bound.

### Trade-offs, bottlenecks, and capacity assumptions

Overprovisioning improves burst and failure tolerance but raises idle cost; aggressive utilization lowers cost but can create queueing and tail-latency collapse. Batching increases throughput but may delay small requests; larger context/output limits improve capability but consume KV cache and tokens. The dominant bottleneck must be measured by workload class. No traffic, model, hardware, growth, or SLO values are provided, so avoid invented instance counts: derive demand from measured per-unit service rates, then validate with peak and failure load tests and explicit headroom/RTO requirements.

### Concise interview answer

“I start with workload classes and SLOs, then estimate demand in the units that consume resources: tokens and active sequences for LLM serving, pages/audio-seconds/frames for media pipelines, and vectors/indexes for retrieval. I benchmark the actual model and hardware, include dependencies and human review, and add headroom for bursts, deployment, rebuild, and failure scenarios. Load tests validate p95/p99 latency, throughput, memory, queueing, cost, and quality. I would not derive capacity from model size or average QPS alone.”

### Revision summary

| Workload | Main capacity drivers |
|---|---|
| LLM inference | Input/output tokens, concurrency, KV cache, batching, model/hardware. |
| Retrieval | Vectors, dimensions, ANN structures, filters, replicas, QPS. |
| Media/document pipeline | Pages/seconds/frames, parsing/OCR, model cost per unit. |
| Operations | Provider/database quotas, reviewer throughput, failover headroom. |
| Validation | Production-shaped peak and failure load tests against SLOs. |

<br><br><br>

## Design a multi-tenant AI chatbot platform where each business gets a custom chatbot.

**Answer:**

### Requirements and tenant boundaries

Clarify tenant count and size distribution, channels, supported models, customization depth, expected traffic, data residency, uptime, branding, billing, and whether tenants upload knowledge or configure tools. Define isolation guarantees for prompts, data, conversations, indexes, caches, analytics, and credentials. A custom chatbot should be configurable without allowing tenant instructions to weaken platform safety or access controls.

### Architecture

```text
Tenant admin -> control plane (config, knowledge, model/tool policy)
             -> validation / approval / versioned publish

End user -> tenant resolution + auth
         -> tenant-scoped chatbot runtime
         -> policy and configuration
         -> tenant-authorized retrieval
         -> approved model/tool gateway
         -> response + tenant-specific analytics

Shared services: model pools, billing, audit, monitoring, rollout
Isolation boundary: tenant IDs, scoped storage/index/cache/secrets
```

### Tenant setup and request flow

1. Authenticate end users and tenant administrators; resolve tenant from trusted domain/token mapping, not a client-provided arbitrary ID.
2. Let admins configure appearance, approved prompts, knowledge sources, escalation routes, and tool scopes through schemas and policy checks. Version each configuration and support draft, test, publish, and rollback.
3. Ingest tenant documents with source authorization, provenance, deletion propagation, and tenant-scoped embeddings/indexing. Shared physical indexes are possible only with enforceable tenant filtering and leakage tests.
4. At runtime, load the published tenant configuration, enforce tenant and user permissions, retrieve only authorized knowledge, and route to an approved model with the tenant’s region and budget constraints.
5. Validate tool requests against both platform policy and tenant-specific allowlists. Credentials are secret-managed per tenant; the model never receives raw credentials. Require confirmation for consequential actions.
6. Store conversation history and caches under tenant/user scope, with retention/deletion controls. Meter usage by tenant and expose a usage dashboard.
7. Provide a human escalation path and include conversation context/evidence only for authorized support personnel.

### Governance and operations

Enforce strong tenant isolation in storage, retrieval, caches, logs, metrics, and support tools. Test cross-tenant prompt injection, misconfigured filters, cache collisions, secret exposure, and deletion. Evaluate answer quality, citations, policy compliance, tool correctness, latency, cost, and configuration regression by tenant tier. Use canary configuration rollout and explicit status when provider/tool failures prevent a successful action.

### Trade-offs, bottlenecks, and capacity assumptions

Dedicated indexes and model pools strengthen isolation and predictable performance but increase cost and operational overhead; shared pools improve utilization but need strict quotas, noisy-neighbor protection, and tenant-scoped caching. Per-tenant custom prompts can create a large configuration/testing matrix. Retrieval/embedding ingestion and slow tenant APIs may dominate latency. Estimate capacity from active tenants × peak users/conversations × tokens and tool calls per turn, plus per-tenant corpus size and update rate. Tenant count, traffic skew, and isolation requirements are unspecified, so use tiered isolation and benchmark largest-tenant and noisy-neighbor scenarios.

### Concise interview answer

“I’d separate a tenant control plane for configuring and publishing chatbots from a tenant-scoped runtime. Tenant identity is resolved from trusted auth; documents, conversations, caches, credentials, and analytics are isolated or filtered at enforceable boundaries. Admins can configure prompts, sources, and allowlisted tools, but cannot override platform safety. I’d version and canary configuration, meter usage, and test cross-tenant leakage. Capacity depends on tenant traffic skew, token use, corpus size, and tool/API latency.”

### Revision summary

| Layer | Responsibility |
|---|---|
| Control plane | Tenant config, validation, versioning, publish/rollback. |
| Runtime | Authenticated tenant resolution, policy, retrieval, model/tool routing. |
| Isolation | Tenant-scoped data/index/cache/secrets/logs and deletion. |
| Operations | Quotas, billing, monitoring, human escalation, canaries. |
| Capacity | Tenant/user concurrency, tokens, tool calls, corpus and update rates. |

<br><br><br>

## Design an AI meeting summarizer system for thousands of meetings daily.

**Answer:**

### Requirements and consent

Clarify meeting platforms, daily volume, duration and concurrency distribution, languages, diarization needs, output formats, delivery latency, and whether summaries are for attendees, managers, or downstream systems. Define consent and recording disclosure, retention/deletion, access to transcripts, and whether action items may be assigned automatically. Summaries must distinguish what was said from inferred decisions, and should not attribute a statement to a speaker unless diarization confidence is adequate.

### Architecture

```text
Meeting provider / live audio
  -> consent + meeting identity + encrypted media intake
  -> durable job queue and metadata store
  -> ASR + speaker diarization
  -> transcript cleanup / timestamps
  -> topic segmentation / summarization / action extraction
  -> citation and speaker/time validation
  -> attendee/organizer review and delivery
  -> retention/deletion + metrics
```

### Processing workflow

1. Authenticate integration and verify meeting/participant permissions; capture consent and recording state. Use provider webhooks or uploads with idempotent meeting IDs.
2. Store audio securely with retention metadata. Transcribe using a language-appropriate ASR model; preserve timestamps, speaker labels, and uncertainty. Provide correction for names, acronyms, and low-confidence spans.
3. Segment long meetings by time/topic with overlap or hierarchical summaries so context is preserved without exceeding model limits. Maintain links from each summary claim to transcript spans.
4. Generate structured outputs: executive summary, decisions, open questions, and action items with owner/deadline only when explicitly supported. Flag uncertain attribution and avoid inventing commitments.
5. Validate structure and evidence; allow organizer review/edit before distribution, especially for sensitive or external meetings. Deliver to authorized participants and respect meeting-specific sharing rules.
6. Apply deletion and correction requests across audio, transcript, summaries, indexes, caches, and exports. Keep audit records without unnecessary content retention.

### Evaluation and operations

Evaluate transcription word error rate and diarization, factual coverage, omission/hallucination rate, action-item precision/recall, speaker attribution, citation/time-link accuracy, user edits, and delivery latency. Test accents, overlapping speech, poor audio, multilingual/code-switching meetings, and long sessions. Monitor processing failures, queue age, retention compliance, and per-tenant access.

### Trade-offs, bottlenecks, and capacity assumptions

Higher-quality ASR and diarization can improve summaries but add compute and turnaround time; streaming can deliver early notes but risks omissions before the meeting ends. Long meetings require chunking/hierarchical synthesis, trading global context against bounded memory and cost. Audio decoding/transcription and summary generation are separate resource pools; review and correction can become bottlenecks. Estimate work from meetings/day × duration × ASR real-time factor, plus summary tokens per audio-hour and review fraction. “Thousands daily” is insufficient to size capacity without duration, concurrency, language mix, and delivery SLO; benchmark peak overlapping meetings and retain queue headroom.

### Concise interview answer

“I’d build a consented, encrypted asynchronous pipeline: ingest meeting audio, transcribe with timestamps and diarization, segment long sessions, and generate structured summaries and action items linked to transcript evidence. Uncertain speaker attribution or unsupported commitments are flagged, and organizers can review before distribution. Access, retention, and deletion apply to every derived artifact. I’d evaluate ASR, attribution, factual coverage, action-item precision, and latency. Capacity depends primarily on concurrent audio-hours and ASR real-time factor, not just meetings per day.”

### Revision summary

| Stage | Key control |
|---|---|
| Intake | Consent, authorization, idempotent jobs, encrypted storage. |
| Transcription | ASR, diarization, timestamps, uncertainty/correction. |
| Summarization | Hierarchical context, evidence-linked decisions/actions. |
| Delivery | Access checks, review, retention and deletion propagation. |
| Capacity | Audio-hours, peak concurrency, language mix, review rate. |

<br><br><br>

## Design an AI notification system that prioritizes instead of broadcasting.

**Answer:**

### Objective and user controls

Clarify notification channels, event sources, user preferences, urgency classes, daily volume, latency needs, and what counts as harmful over-notification. Optimize for timely, useful delivery and successful action—not total sends or opens. Respect opt-outs, quiet hours, accessibility, legal notices, and channel-specific consent. Critical alerts must follow deterministic rules and must not be suppressed solely by a learned ranker.

### Architecture

```text
Product events / scheduled tasks
  -> schema validation + deduplication
  -> eligibility and policy rules
  -> user context / preferences / frequency state
  -> priority and relevance scoring
  -> ranking, batching and suppression
  -> channel adapter (push/email/SMS/in-app)
  -> delivery, feedback and outcome logging
```

### Decision flow

1. Validate event source, user identity, timestamp, deduplication key, and expiration. Reject or quarantine malformed events.
2. Apply hard eligibility and consent rules first: account status, opt-outs, quiet hours, required channel permissions, and critical-event policy.
3. Estimate relevance, urgency, and expected value using the event, user preferences, recent activity, and frequency caps. Use minimum necessary data and avoid sensitive inferences that are not approved.
4. Rank eligible notifications against one another; suppress duplicates, batch low-priority updates, and defer items likely to be more useful later. Preserve expiration and re-evaluate time-sensitive events before sending.
5. Apply global and per-user caps, channel-specific throttles, and delivery retry/idempotency. Do not retry expired or already-delivered notifications.
6. Measure delivery, dismissal, action, unsubscribe, complaint, and downstream outcomes. Use controlled experiments with guardrails; update ranking without creating feedback loops that amplify already popular events.
7. Let users inspect and change preferences, explain categories, and opt out. Provide audit and rollback for policy/model updates.

### Evaluation and safety

Measure precision/usefulness, time-to-action, missed critical notifications, duplicate rate, opt-out/unsubscribe rate, complaints, and outcomes by user/channel cohort. Test burst events, timezone changes, stale context, and attempts to bypass consent. Monitor channel-provider failures and delivery lag.

### Trade-offs, bottlenecks, and capacity assumptions

More personalization can improve relevance but requires fresh user state and increases privacy risk; batching reduces interruption but can delay useful alerts. Aggressive suppression lowers fatigue but risks missing important events, so critical categories need deterministic override and auditable rules. Event ingestion, user-state lookups, and channel-provider quotas commonly bottleneck. Estimate capacity from event arrival rate × scoring/feature cost, plus delivery fan-out and burstiness; user base, channel mix, and critical-event SLOs are unspecified, so load-test peak campaigns and enforce bounded queues and provider-aware backpressure.

### Concise interview answer

“I’d ingest events through a deduplicating pipeline, apply consent and hard eligibility rules, then score and rank eligible notifications using urgency, relevance, preferences, and frequency state. The system batches or suppresses low-value duplicates but never lets an ML ranker hide policy-defined critical alerts. It delivers through channel adapters with caps and idempotent retries, and learns from outcomes under unsubscribe and complaint guardrails. Capacity depends on burst event rate, user-state lookups, and provider delivery quotas.”

### Revision summary

| Layer | Responsibility |
|---|---|
| Eligibility | Consent, quiet hours, critical rules, expiry. |
| Prioritization | Relevance/urgency, batching, deduplication, frequency caps. |
| Delivery | Channel adapters, quotas, idempotency, retries. |
| Evaluation | Usefulness, action, missed critical events, fatigue and opt-outs. |
| Capacity | Event bursts, feature lookups, channel fan-out and provider limits. |

<br><br><br>

## Design an AI-powered anomaly detection system for cloud infrastructure.

**Answer:**

### Requirements and anomaly definition

Clarify monitored signals (metrics, logs, traces, events), cardinality, sampling frequency, detection latency, cloud environments, incident workflow, and acceptable alert volume. Define anomaly types and operational action: notify, open an incident, or trigger a reversible automated remediation. The goal is actionable incidents, not merely unusual points; anomalies may be benign during deployments, seasonality, or traffic shifts.

### Architecture

```text
Cloud telemetry sources
  -> streaming ingestion / schema normalization
  -> enrichment (service, region, deployment, dependency)
  -> baselines + rules + statistical/ML detectors
  -> correlation and incident grouping
  -> severity / confidence / ownership
  -> alert / dashboard / incident platform
  -> operator feedback and post-incident labels
```

### Detection workflow

1. Ingest metrics, logs, traces, and change events with timestamps and source identity. Deduplicate, handle late/out-of-order data, and maintain per-signal quality indicators.
2. Establish baselines that account for seasonality, service tiers, deployments, and known maintenance. Combine deterministic thresholds for known failure modes with statistical or learned detectors for novel patterns.
3. Score anomalies with context: correlated service signals, recent deployments, dependencies, region, and incident history. Group related alerts into incidents to reduce alert storms.
4. Route by severity, confidence, ownership, and on-call policy. Show supporting time windows, affected services, relevant changes, and model uncertainty.
5. Keep automated remediation narrowly scoped, reversible, rate-limited, and permissioned; require human approval for risky infrastructure changes. A language model may summarize evidence or suggest runbook steps, but should not directly execute unrestricted cloud operations.
6. Capture operator acknowledgment, suppression, resolution, and postmortem labels. Use these for calibration and detector updates with safeguards against learning from unverified suppressions.

### Evaluation and operations

Measure detection precision/recall, time to detect, alert-to-incident conversion, false-alert burden, missed-severity rate, and performance during novel incidents and changes. Run backtests and shadow detectors before paging. Monitor telemetry lag, missing data, cardinality, model drift, and alert delivery. Protect infrastructure metadata and credentials; keep audit trails for automated actions.

### Trade-offs, bottlenecks, and capacity assumptions

Simple thresholds are fast and explainable but miss context and seasonal changes; complex models catch patterns but require representative history and can create opaque false alarms. Lower detection windows reduce time-to-detect but increase noise and streaming compute. High-cardinality telemetry can overwhelm storage, feature computation, and baseline maintenance; incident correlation and on-call capacity may be the operational bottleneck. Estimate throughput from time series × sampling frequency × dimensions, plus logs/traces volume and retention. Signal count, cadence, retention, and alert SLO are unspecified, so cardinality controls and backtesting on peak telemetry are essential.

### Concise interview answer

“I’d normalize cloud telemetry in a streaming pipeline, enrich it with service/deployment context, and combine rules with statistical or learned detectors. Correlation groups anomalies into incidents, then routes actionable evidence to the right owner. LLMs can summarize or suggest runbooks, but remediation is bounded and approval-gated. I’d evaluate precision/recall, detection delay, alert burden, and novel-incident behavior, and capacity-plan from signal cardinality × sampling rate plus retention and correlation costs.”

### Revision summary

| Stage | Design focus |
|---|---|
| Ingestion | Timestamped metrics/logs/traces, late data, quality, cardinality. |
| Detection | Rules + baselines/ML + deployment and dependency context. |
| Alerting | Correlation, severity, ownership, evidence and uncertainty. |
| Remediation | Least privilege, reversible actions, human approval where risky. |
| Capacity | Signal count × cadence, telemetry volume, retention, on-call load. |

<br><br><br>

## Design an AI-powered document processing pipeline for financial institutions.

**Answer:**

### Requirements and control environment

Clarify document types (statements, forms, invoices, identity records), jurisdictions, daily volume and peak arrivals, fields/workflows, accuracy and turnaround targets, retention, audit requirements, and whether outputs affect regulated decisions. Establish data classification, source lineage, approved model/service boundaries, and human review policy. Financial extraction must be reproducible and explainable at the field level.

### Architecture

```text
Secure intake -> malware/type validation -> immutable original store
              -> document classification / routing
              -> OCR + layout/table extraction
              -> schema-guided field extraction
              -> deterministic validation / reconciliation
              -> confidence and risk routing
              -> human review / approval
              -> core-system integration + audit

Supporting: key management, access controls, retention/deletion,
model registry, monitoring, exception queues and disaster recovery
```

### Processing and control workflow

1. Authenticate source systems, validate document integrity, scan uploads, assign an immutable document/version ID, and encrypt the original. Use idempotent ingestion and retain chain-of-custody metadata.
2. Classify document family and route to appropriate native parser/OCR/layout model. Preserve page, cell, and source-span coordinates; flag low-quality scans, missing pages, and unsupported formats.
3. Extract into versioned schemas with typed values, currency/units, dates, and field-level evidence. Distinguish missing, illegible, ambiguous, and conflicting values; never coerce uncertain text into a confident value.
4. Validate with deterministic business rules and cross-document reconciliation (for example totals, account/date consistency, required fields). Verify critical fields against authoritative systems where permitted.
5. Route low-confidence, high-risk, inconsistent, or novel documents to trained staff. Provide side-by-side source/evidence and record reviewer corrections and approvals.
6. Publish only validated outputs to downstream systems using controlled APIs, idempotency, approval gates, and reconciliation. Preserve source, schema, model, prompt, and validation versions.
7. Monitor and reconcile document counts from intake through completion; alert on missing/duplicate jobs, queue age, OCR/extraction drift, and downstream write failures.

### Security, audit, and evaluation

Use least privilege, segregation of duties, encryption/key management, audit logging, retention limits, and tested backup/restore. Do not train on customer documents without explicit legal and organizational authorization. Evaluate field-level accuracy, critical-field false acceptance, evidence localization, exception rate, reviewer overturns, and performance by document type/language/scan quality. Maintain traceability for every downstream value.

### Trade-offs, bottlenecks, and capacity assumptions

Deterministic templates are efficient and auditable but brittle to layout variation; OCR/LLM pipelines generalize better but introduce uncertainty and review needs. Auto-processing reduces manual effort only if false acceptance remains below risk thresholds; review capacity becomes a bottleneck for poor scans and exceptions. Reconciliation and core-system APIs may dominate completion time. Estimate processing from documents × pages × OCR/model cost per page, plus exception fraction × human review time; “financial institution” gives no volume, document mix, or SLA, so pilot by document class and plan for peak-period bursts and disaster recovery.

### Concise interview answer

“I’d build a secure, idempotent pipeline from immutable intake through classification, OCR/layout parsing, schema-based extraction, deterministic reconciliation, and risk-based human review. Every field retains page-level evidence and explicit uncertainty; only validated, approved results flow to core systems. I’d enforce segregation of duties, encryption, retention, and full lineage, and evaluate critical-field false acceptance as well as accuracy. Capacity is pages and OCR/model time plus exception-review throughput, with peak and recovery headroom.”

### Revision summary

| Control | Purpose |
|---|---|
| Immutable intake | Provenance, integrity, replay and audit. |
| Extraction | Typed schema, field evidence, uncertainty states. |
| Validation | Business rules, reconciliation, approval gates. |
| Governance | Least privilege, retention, lineage, backup/restore. |
| Capacity | Documents/pages, processing time, exception rate and review SLA. |

<br><br><br>

## Design an AI dynamic pricing engine.

**Answer:**

### Objective and guardrails

Clarify the product/market, price update cadence, inventory and competitor data, customer segments, business objective, legal constraints, and whether prices are shown per user or uniformly. Optimize long-term contribution and business health—not short-term revenue alone. Set explicit constraints for minimum/maximum prices, contract terms, non-discrimination, price-change frequency, and human approval. Do not infer sensitive traits or use protected attributes for individualized pricing.

### Architecture

```text
Catalog / inventory / costs / demand / promotions / market signals
  -> validation, lineage and feature store
  -> demand forecasting / elasticity estimates
  -> constrained optimizer or policy
  -> approval / guardrail validation
  -> pricing service + cache/invalidation
  -> storefront / quote APIs
  -> exposure and outcome logging
  -> experiment, monitoring and retraining
```

### Decision and rollout flow

1. Ingest time-stamped data with source quality and freshness checks; reconcile inventory, cost, promotions, and realized sales. Handle missing or delayed signals explicitly.
2. Forecast demand and estimate price elasticity using historical and experimental data while controlling for confounding, seasonality, stockouts, and promotions.
3. Generate candidate prices using an optimizer or constrained policy. Enforce hard floors/ceilings, margin and inventory rules, contract/market requirements, and change-rate limits outside the model.
4. Apply human approval or a conservative policy for new products, low-confidence estimates, high-impact segments, and unusually large price moves.
5. Serve prices from a low-latency, versioned pricing service. Keep displayed price, quote, checkout, and audit records consistent; define behavior when the pricing service is stale or unavailable.
6. Run controlled experiments with guardrails and adequate duration; account for interference between users/markets and delayed outcomes. Roll back quickly if customer or business harm appears.
7. Monitor revenue and margin alongside conversion, retention, complaints, price volatility, fairness, stockouts, and data/model drift. Maintain an auditable reason and model/policy version for each price.

### Trade-offs, bottlenecks, and capacity assumptions

Frequent price updates react quickly to demand but increase system load, customer confusion, and operational risk; slower updates are stable but can miss market changes. Sophisticated elasticity models need high-quality causal/experimental data; simple rules are easier to audit but less adaptive. Inventory freshness, feature pipelines, experiment design, and pricing-service cache invalidation can bottleneck. Capacity depends on SKU × market × segment decision count, update cadence, forecast horizon, and serving QPS; none are specified, so separate offline optimization throughput from online lookup latency and set explicit freshness and price-change limits.

### Concise interview answer

“I’d build a data-validated forecasting and constrained optimization pipeline, with hard business and fairness guardrails outside the learned model. Candidate prices are reviewed or conservatively gated for high-impact/low-confidence cases, then published through a versioned low-latency service with consistent checkout behavior. I’d use controlled experiments and monitor margin, conversion, retention, volatility, complaints, and fairness. Capacity is driven by SKU/market combinations, update frequency, data freshness, and price-lookup QPS—not just model inference.”

### Revision summary

| Layer | Design choice |
|---|---|
| Data | Fresh, lineage-tracked costs, inventory, demand and market signals. |
| Optimization | Demand/elasticity model plus hard constraints and approval gates. |
| Serving | Versioned pricing API, coherent cache/checkout behavior, fallback. |
| Evaluation | Controlled experiments and customer/business guardrails. |
| Capacity | SKU × market × segment, cadence, forecasts and online QPS. |

<br><br><br>

## Design an AI resume screening system that handles 100K applications per week.

**Answer:**

### Requirements and employment decision boundary

Clarify regions and applicable employment rules, job families, languages, application formats, hiring-team workflow, turnaround SLO, retention, and whether the system only organizes evidence or influences ranking. Treat it as decision support: the system should not autonomously reject candidates or infer protected/sensitive attributes. Define job-related criteria with hiring stakeholders, provide human review and contestability, and conduct legal, privacy, and bias assessment before deployment.

### Architecture

```text
ATS / application intake
  -> identity, consent/notice, malware and format validation
  -> encrypted document store + application/job version
  -> parsing/OCR + normalized candidate evidence
  -> job-specific criteria matching (not personality inference)
  -> structured evidence + uncertainty / missing-data checks
  -> recruiter review UI with source citations
  -> human decision in ATS + audit and monitoring
```

### Processing workflow

1. Ingest applications idempotently; link each resume and candidate to the correct job requisition and maintain the original document and version.
2. Parse resumes with format-specific extraction/OCR. Preserve page/span provenance and distinguish missing information from an unqualified candidate.
3. Use a hiring-team-approved, job-related rubric derived from actual role requirements. Extract evidence such as stated skills, experience, credentials, and dates; avoid proxies for protected characteristics, personality, or “culture fit.”
4. Compare evidence to explicit criteria and show matched, partially matched, and not-found items with citations to the resume. Do not equate absence of a phrase with absence of a capability.
5. Route parsing failures, low confidence, nonstandard career histories, and borderline cases to human review. Keep human decisions independent and provide a mechanism to correct candidate data.
6. Integrate with ATS using authorized APIs, clear status, and audit records of rubric/model versions and reviewer actions. Set retention/deletion and candidate-access policies with legal/privacy teams.
7. Monitor outcomes and investigate disparate impact, error rates, drift, and recruiter overrides. Revalidate criteria and models when a role or hiring process changes.

### Evaluation, fairness, and governance

Evaluate extraction accuracy, evidence citation precision, criterion-level agreement with trained reviewers, false-negative rates, and consistency across resume formats and relevant demographic groups where lawful and appropriate. Use independent audits; do not treat historical hiring decisions as unbiased ground truth. Test accessibility and alternative formats. Human review must be meaningful—not a rubber stamp—and decisions need accountable owners.

### Trade-offs, bottlenecks, and capacity assumptions

Automated extraction can reduce repetitive review but may miss unconventional career paths, OCR errors, or equivalent skills; strict keyword matching is fast but brittle. Human review improves context but can become the bottleneck, especially for exceptions and appeals. At 100K/week, a simple average is about 14.3K applications/day or 595/hour if evenly distributed; actual peaks, retries, and file/page distributions determine capacity. Estimate parser throughput from peak applications × pages × processing time, and reviewer workload from exception fraction × review minutes. The average alone is not a sizing target; benchmark peak bursts and review staffing without lowering fairness or accuracy thresholds.

### Concise interview answer

“I’d build a secure ATS-integrated decision-support pipeline: parse each resume, map explicit evidence to a hiring-team-approved job rubric, and present cited matches and uncertainty to a recruiter. It would not autonomously reject candidates or infer protected traits or personality. I’d evaluate extraction and criterion accuracy, audit disparate impact, preserve meaningful human review, and govern retention and appeals. The stated 100K/week averages roughly 595 applications per hour, but I’d size parsing and recruiter review from peak arrival rates, pages per application, and exception rate.”

### Revision summary

| Area | Safeguard |
|---|---|
| Criteria | Job-related, explicit, approved, versioned rubric. |
| Model output | Evidence/citations and uncertainty; no unsupported rejection score. |
| Human process | Recruiter decision, correction, review, contestability. |
| Fairness | Independent audits, subgroup/error analysis, no proxy inference. |
| Capacity | 100K/week average plus peak factor, pages, parsing and exception review. |

<br><br><br>

## Design an AI voice assistant architecture.

**Answer:**

### Requirements and interaction model

Clarify whether the assistant is voice-only or multimodal, supported devices/channels, languages, expected concurrency, wake-word/on-device needs, latency, offline behavior, tool access, and privacy/recording policy. Define barge-in, turn-taking, accessibility, and human escalation expectations. Distinguish an always-listening wake-word component from cloud processing; users need clear indicators and controls.

### Architecture

```text
Microphone / telephony
  -> device permission + wake word / push-to-talk
  -> secure streaming ingress + session manager
  -> VAD / endpointing / streaming ASR
  -> dialogue manager + context/memory policy
  -> retrieval and constrained tool router
  -> response generation
  -> streaming TTS / audio rendering
  -> speaker, with barge-in cancellation

Supporting: identity, consent, safety policy, observability,
human handoff, retention/deletion, offline/local fallback
```

### Turn lifecycle

1. Start a session only through an explicit wake/activation mechanism; provide visible/audible feedback and apply consent/retention rules.
2. Stream audio with codec handling, VAD, and partial ASR. Keep partial hypotheses provisional; endpoint only when the user has finished, balancing responsiveness with premature cutoff.
3. Combine transcript with only authorized and relevant conversation context. Treat spoken text, retrieved sources, and device content as untrusted input.
4. Route the request to retrieval, a model, or a deterministic skill. Tool calls use typed schemas, least-privilege credentials, timeouts, idempotency, and user confirmation for consequential actions.
5. Stream a response through TTS. Cancel speech immediately on barge-in, propagate cancellation to model/tools where safe, and avoid speaking unverified sensitive content.
6. Handle uncertainty by clarifying, abstaining, or handing off. Report tool failures explicitly and never claim an action completed without confirmation from the downstream system.
7. Close the session and retain audio/transcripts only as disclosed and necessary; support deletion and access controls.

### Safety, quality, and operations

Evaluate ASR word error rate and intent accuracy across accents, noise, languages, and code-switching; measure task completion, interruption success, time to first audio, p95/p99 turn latency, tool success, and user-reported errors. Red-team prompt injection in speech and retrieved content, unauthorized actions, wake-word false activations, and data leakage. Provide a visual/text alternative and emergency path.

### Trade-offs, bottlenecks, and capacity assumptions

Separate ASR–LLM–TTS stages are observable and replaceable but add network hops and latency; an end-to-end speech model may streamline interaction but can reduce granular control or diagnostics. On-device inference improves privacy/offline behavior but is constrained by model size, battery, and device variance. Streaming reduces perceived delay but complicates partial hypotheses and cancellation. Capacity depends on concurrent audio streams, audio duration, ASR/TTS real-time factor, model tokens, and tool calls; no traffic or SLO is specified, so benchmark each stage under peak concurrency and reserve capacity for long turns and failover.

### Concise interview answer

“I’d use an explicit activation/session layer, streaming VAD/ASR, a stateful dialogue manager, authorized retrieval and tool routing, and cancellable streaming TTS. Barge-in and end-of-turn detection are core interaction features. Tools are least-privilege and consequential actions require confirmation; uncertainty leads to clarification or handoff. I’d protect recordings with consent and retention controls and evaluate accents, noise, latency, task success, and safety. Capacity is based on concurrent audio streams and measured ASR/model/TTS cost per audio-second.”

### Revision summary

| Layer | Key concern |
|---|---|
| Capture | Explicit activation, permissions, streaming audio, VAD/endpointing. |
| Dialogue | Context policy, retrieval, constrained tools, confirmation. |
| Response | Streaming TTS, barge-in cancellation, explicit failures. |
| Governance | Consent, privacy, safety, human and non-voice fallback. |
| Capacity | Concurrent streams, audio duration, real-time factors and tool rate. |

<br><br><br>

## Design a multi-agent workflow system where agents collaborate on complex tasks.

**Answer:**

### Decide whether multiple agents are justified

Clarify the task, required tools, workflow duration, consistency and audit needs, failure tolerance, and which actions may have side effects. Multi-agent orchestration is useful when work decomposes into bounded tasks with distinct expertise or parallelizable evidence gathering. It is not automatically better than one model call: every agent adds latency, cost, coordination, and potential disagreement.

### Architecture

```text
User request -> auth / policy / task planner
             -> workflow state machine and budget manager
             -> bounded specialist agents (parallel/sequential)
             -> shared typed artifacts / evidence store
             -> verifier / policy gate
             -> approved tools or human confirmation
             -> final response + audit trail
```

### Orchestration pattern

1. Validate user authority, request scope, and available tools. Define a finite task plan, acceptance criteria, deadline, token/tool-call budget, and stop conditions.
2. Decompose only where subtasks are separable. Assign each worker a narrow objective, relevant context, allowed tools, output schema, and prohibition on expanding its own permissions.
3. Run independent research or analysis in parallel when dependencies allow; execute dependent tasks sequentially. Persist workflow state so retries and restarts do not duplicate work.
4. Return structured outputs with provenance, assumptions, and uncertainty. The orchestrator resolves disagreement against evidence or asks for human input; it should not average incompatible claims blindly.
5. Verify outputs and proposed actions using deterministic rules, schemas, tests, or authoritative sources. Keep side effects behind idempotent, least-privilege tools and human confirmation where consequential.
6. Stop when acceptance criteria are met, the budget/deadline is reached, or the workflow cannot proceed. Surface partial completion and failed subtasks explicitly.
7. Log trace IDs, prompts/config versions, agent/tool calls, evidence, and decisions under privacy controls for debugging and audit.

### Reliability, safety, and evaluation

Use timeouts, bounded retries, cancellation propagation, circuit breakers, and per-agent concurrency. Treat tool output and retrieved documents as untrusted; defend against cross-agent prompt injection and prevent secrets from entering unrelated agent contexts. Evaluate end-task success, evidence correctness, coordination overhead, duplicate work, tool accuracy, policy violations, latency, cost, and human intervention. Compare against a single-agent baseline to prove the architecture helps.

### Trade-offs, bottlenecks, and capacity assumptions

Parallel agents can shorten wall-clock time but multiply model calls and may saturate provider quotas; sequential handoffs preserve dependencies but accumulate latency. Shared context improves consistency but increases token cost and risks unnecessary data exposure; isolated contexts improve least privilege but require artifact handoff. The planner, shared tool APIs, verification, and human approvals can bottleneck. Estimate cost from workflows × agents invoked × calls/tokens per agent, and concurrency from parallel branches; task complexity and service targets are unspecified, so use strict budgets and benchmark parallel versus sequential plans.

### Concise interview answer

“I’d use a workflow orchestrator—not free-form agent conversations—to decompose a task into bounded specialists with explicit inputs, tools, output schemas, budgets, and stop conditions. Independent work can run in parallel; the orchestrator verifies evidence and reconciles disagreement before any side effect. Tool permissions remain least-privilege and consequential actions require approval. I’d compare end-task quality with a single-agent baseline and measure coordination overhead, latency, cost, and failure recovery.”

### Revision summary

| Component | Responsibility |
|---|---|
| Planner/orchestrator | Finite plan, state, budgets, dependencies and stopping. |
| Worker agents | Narrow tasks, constrained tools, structured evidence. |
| Verifier | Validate outputs, resolve conflicts, enforce acceptance criteria. |
| Safety | Least privilege, untrusted tool output, approval for side effects. |
| Capacity | Workflows × calls/tokens/agents; parallel branches and tool limits. |

<br><br><br>

## Design a real-time AI transcription system for concurrent audio streams.

**Answer:**

### Requirements and latency targets

Clarify audio sources/codecs, languages, stream count and burst profile, transcription latency, partial versus final transcript semantics, diarization, domain vocabulary, retention, and downstream integrations. Define whether this is live captions, call analytics, or regulated transcription; distinguish provisional partial text from finalized segments and preserve timestamps.

### Architecture

```text
Audio clients -> auth/session admission -> stream gateway
              -> codec/resampling + jitter buffer
              -> VAD / streaming ASR workers
              -> partial/final segment assembler
              -> optional diarization / punctuation / vocabulary boost
              -> transcript event stream + client delivery
              -> encrypted storage / analytics (policy-controlled)

Supporting: autoscaling, language/model routing, observability,
backpressure, reconnect/resume, retention and deletion
```

### Stream lifecycle

1. Authenticate each stream, validate codec/sample rate and language configuration, enforce concurrent-stream quotas, and assign a durable session ID.
2. Ingest audio over a streaming transport with sequence numbers and timestamps. Handle jitter, packet loss, reconnects, and duplicate frames; apply VAD and resample only as required by the ASR model.
3. Route to a compatible streaming ASR pool by language/model and capacity. Emit interim hypotheses quickly, then stable/final segments with confidence and timestamps; clients must be able to replace interim text rather than append duplicates.
4. Optionally add diarization, punctuation, and domain vocabulary. Keep these stages bounded and expose their uncertainty; do not silently rewrite names or numbers.
5. Apply backpressure and deadlines. If the worker falls behind, report lag, reduce optional work, or explicitly mark dropped audio rather than return a misleading complete transcript.
6. Deliver transcript events with ordering and idempotent sequence IDs. Support reconnect/resume from a checkpoint and mark whether the session is partial, final, or failed.
7. Store only permitted audio/transcripts with encryption, retention, access controls, and deletion propagation.

### Evaluation and operations

Measure word error rate and critical-entity accuracy by language/accent/noise, time-to-first-partial, finalization lag, diarization error, dropped audio, reconnect success, stream availability, and cost per audio-hour. Load-test long-lived streams and correlated reconnect bursts. Monitor real-time factor, queue depth, GPU/accelerator use, packet loss, and per-model performance.

### Trade-offs, bottlenecks, and capacity assumptions

Smaller/faster ASR lowers latency and cost but may increase word and entity errors; larger models or extra diarization improve quality with added compute and delay. Partial hypotheses improve responsiveness but can revise, so downstream consumers need explicit interim/final semantics. Long-lived connections, audio ingress bandwidth, ASR real-time factor, and reconnect storms can bottleneck. Estimate capacity as concurrent streams × audio real-time factor × per-worker stream capacity, with separate ingress bandwidth and storage estimates; stream count, codec, languages, and latency SLO are unspecified, so benchmark sustained and peak concurrency, not only short clips.

### Concise interview answer

“I’d authenticate and admit streams, handle codec/jitter and sequence order, then route audio to streaming ASR workers that emit replaceable partials and timestamped final segments. Backpressure, reconnect/resume, and explicit partial/failure states prevent silently incomplete transcripts. I’d add diarization or vocabulary boosts only when measured useful, protect stored audio/transcripts, and evaluate WER, entity accuracy, partial/final latency, and dropped-stream rate. Capacity is concurrent streams times measured ASR real-time factor, plus ingress bandwidth and reconnect headroom.”

### Revision summary

| Layer | Design focus |
|---|---|
| Ingress | Authentication, codec handling, jitter, sequencing and quotas. |
| Recognition | Streaming ASR, language routing, partial/final semantics. |
| Delivery | Ordered events, reconnect/resume, explicit lag/failure. |
| Evaluation | WER, entity accuracy, diarization, latency and stream loss. |
| Capacity | Concurrent audio streams, real-time factor, bandwidth, reconnect bursts. |

<br><br><br>

## Design an AI-powered live streaming content moderation system.

**Answer:**

### Requirements and harm-response policy

Clarify stream volume, supported media/languages, acceptable moderation delay, categories and severity, live versus replayed content, jurisdiction, reviewer availability, and actions (warn, mute, pause, remove, suspend). Define policy and escalation rules with human governance. For live streams, detection quality competes directly with response latency; false positives can disrupt creators, while false negatives can expose viewers to harm.

### Architecture

```text
Stream ingest -> authenticated channel/session + policy lookup
              -> low-latency audio/video frame sampling
              -> ASR / OCR / vision / audio classifiers
              -> temporal context + risk aggregation
              -> policy decision and confidence thresholds
              -> allow / label / delay / mute / pause / escalate
              -> moderator console + creator notice / appeal
              -> audit, feedback and post-stream review
```

### Real-time decision path

1. Establish stream identity, region, audience settings, policy version, and consent/retention rules. Maintain a short, bounded temporal buffer so classifiers can use context without delaying indefinitely.
2. Sample video frames and analyze audio/transcript on modality-appropriate workers. Use fast classifiers for high-confidence categories; reserve more expensive models or human review for uncertain/high-impact cases.
3. Aggregate evidence over a time window to avoid acting on a single ambiguous frame or phrase. Track timestamps, model confidence, relevant clips, and policy category.
4. Apply explicit policy thresholds and graduated actions: no action, warning/label, temporary delay/mute, stream pause, or account-level escalation. Hard safety rules are policy-owned; an LLM may summarize evidence but should not independently set policy or execute unrestricted actions.
5. Route uncertain cases to moderators with a synchronized short clip, transcript, evidence, and context. Support moderator override, appeal, and creator notification; preserve a reviewable audit trail.
6. Continue monitoring after an action and avoid repeated toggling; use hysteresis/cooldowns and a defined emergency path for imminent severe harm.
7. Retain only the evidence needed for appeals and policy, apply access controls and deletion limits, and use reviewed outcomes to improve evaluation.

### Evaluation and safeguards

Measure time-to-detect/action, category precision/recall, false mute/removal and missed-severe-event rates, reviewer agreement, appeal overturns, and performance across languages, accents, lighting, and stream types. Red-team evasion, coded speech, brief events between sampled frames, adversarial overlays, and coordinated abuse. Monitor classifier lag, dropped media, queue delay, reviewer saturation, and policy changes.

### Trade-offs, bottlenecks, and capacity assumptions

Higher frame/audio sampling improves temporal coverage but multiplies decoding and model inference; sparse sampling reduces cost but can miss brief events. Longer context windows improve interpretation but increase action latency. Human moderators provide nuanced judgment but are limited by queue and shift capacity. Estimate compute from concurrent streams × sampled frames/second and audio real-time factor × model cost, plus reviewer volume from uncertain-event rate. Stream concurrency, sampling policy, severity thresholds, and latency SLO are unspecified; benchmark severe-event detection latency against false-action rates and reserve capacity for viral traffic spikes.

### Concise interview answer

“I’d process live audio and sampled video through low-latency specialist detectors, aggregate evidence over a bounded time window, and apply a versioned policy with graduated actions. High-confidence cases can trigger reversible interventions; ambiguous or high-impact cases go to moderators with synchronized evidence, and users have notice and appeal. I’d measure detection delay, false actions, missed severe events, and subgroup performance. The main trade-off is temporal coverage versus latency and compute; capacity depends on concurrent streams, sampling rate, model cost, and reviewer escalation rate.”

### Revision summary

| Layer | Control |
|---|---|
| Media analysis | Streaming ASR/audio and sampled-frame vision with timestamps. |
| Decision | Temporal aggregation, confidence, policy-owned graduated actions. |
| Human process | Moderator evidence, override, notice and appeal. |
| Evaluation | Detection delay, precision/recall, false actions, subgroup slices. |
| Capacity | Concurrent streams, sampling/audio rate, event escalation and spikes. |

<br><br><br>
