# 08. LLMOps and Production AI

Source entries are in their original order. Use the space after each heading to draft an answer.

## How does Prompt Caching work?

**Answer:**

### What “prompt caching” usually means

In LLM serving, **prompt/prefix caching** reuses computation for an identical prompt prefix across requests. During prefill, the model computes key/value (KV) attention tensors for each layer and token. If a later request begins with the same cacheable prefix under a compatible model and configuration, the server can reuse those KV tensors and only process the uncached suffix. This avoids repeating much of the prefill work; it does not mean the model reuses a previous answer.

Some APIs also use “prompt caching” for provider-managed billing or storage of reusable prompt blocks. The exact cache matching rules, lifetime, billing behavior, and supported models vary by service, so distinguish those features from response caching.

### Typical request path

1. The serving layer tokenizes the request and identifies a cacheable prefix (often shared system instructions, tool definitions, or stable context).
2. It computes a prefix identity using the model/version, token sequence, and relevant inference configuration.
3. On a hit, it retrieves compatible KV state from memory or a cache tier; on a miss, it computes prefill and may store the resulting state.
4. It processes the request-specific suffix and continues autoregressive decoding normally.
5. Cache entries are evicted by memory pressure, age, or policy. Model changes, tokenizer/template changes, or incompatible configurations require separate keys or invalidation.

### Benefits and limitations

Caching is most useful when many requests share long prefixes. It can reduce time-to-first-token, prefill compute, and sometimes input-token charges under provider-specific terms. It generally does not reduce decode work for newly generated output. Cache hits depend on exact compatible prefixes; small changes in earlier tokens may prevent reuse. KV state can consume substantial GPU memory, so caching competes with active-request capacity and needs eviction/admission policy.

Keep tenant and data boundaries explicit. Do not share sensitive prefixes across users unless policy and cache isolation allow it; avoid placing per-user secrets in broadly shared cached prompts. Measure hit rate, prefill savings, memory pressure, latency, and cost rather than assuming caching always helps.

### Concise interview answer

“Prompt caching usually means reusing a model’s KV state for an identical, compatible prompt prefix. The server avoids recomputing prefill for shared system or context tokens, then processes the new suffix and decodes the response normally. It helps repeated long prefixes, but not the generation cost of new output, and cached KV consumes memory. Cache keys must reflect model and prompt versions, and tenant/privacy boundaries and eviction need careful handling. Provider-managed prompt caching may have different matching and billing semantics.”

### Revision summary

| Aspect | Key point |
|---|---|
| Cached item | KV state for a compatible prompt prefix. |
| Savings | Repeated prefill computation; decode remains for new output. |
| Hit conditions | Matching tokens plus compatible model/configuration. |
| Bottleneck | KV memory, eviction, and prefix mismatch. |
| Distinction | Not the same as caching a completed response. |

<br><br><br>

## Prefill vs Decode

**Answer:**

### Two phases of autoregressive inference

**Prefill** processes the prompt before the model emits its first generated token. The model evaluates the prompt tokens through its layers and builds the KV cache used by subsequent attention. These prompt positions can often be processed in parallel within a request, subject to attention dependencies and implementation.

**Decode** generates output autoregressively. At each step, the model consumes the latest token, attends to prior KV state, and produces the next token. The next step depends on the token just generated, so decoding proceeds sequentially for each request, although different requests can be batched together.

| Phase | Input/work | Common user-visible metric |
|---|---|---|
| Prefill | Prompt tokens; builds KV cache. | Time to first token (TTFT). |
| Decode | One new token step at a time; grows KV state. | Inter-token latency / output tokens per second. |

### Why the distinction matters operationally

Long prompts can make prefill the dominant part of TTFT; long outputs make decode duration and KV-cache growth more important. A request may be prefill-heavy (large document context, short answer) or decode-heavy (short prompt, long completion). Capacity planning should therefore track input and output token distributions separately, along with active sequences and context length.

Schedulers can batch requests to improve accelerator utilization, but mixing a large prefill with latency-sensitive decode requests may create head-of-line interference. Prefix/KV caching reduces repeated prefill when prefixes match; it does not eliminate decode for new tokens. Quantization, batching, context limits, and hardware affect the two phases differently, so benchmark both.

### Concise interview answer

“Prefill processes all prompt tokens and creates the KV cache; it largely determines time to first token. Decode then generates tokens one at a time, reusing that cache, and drives inter-token latency and output throughput. Prefill is parallelizable across prompt positions, while each request’s decode is sequential, though requests can be batched together. Separating input and output lengths is essential for scheduling, latency analysis, and capacity planning.”

### Revision summary

| Term | Meaning | Key effect |
|---|---|---|
| Prefill | Process prompt and build KV cache. | TTFT and prompt-processing compute. |
| Decode | Autoregressively generate output. | Inter-token latency, output duration, KV growth. |
| Workload class | Input/output token mix and concurrency. | Drives scheduler and capacity choices. |

<br><br><br>

## Why is prefill compute-bound and decode memory-bandwidth-bound?

**Answer:**

### Arithmetic intensity explains the common pattern

“Compute-bound” and “memory-bandwidth-bound” describe typical regimes, not immutable laws. **Arithmetic intensity** is the number of arithmetic operations performed per byte moved. A workload is more likely to be compute-bound when it can keep accelerator math units busy; it is more likely bandwidth-bound when moving weights or activations dominates useful computation.

### Prefill: many prompt tokens create parallel work

During prefill, a prompt’s token representations are processed together through large matrix operations. With enough tokens and a suitable batch, weight data can be reused across many token positions while doing substantial multiply-accumulate work. This gives higher arithmetic intensity and often makes large-model prefill compute-bound on modern accelerators.

Prefill is not always compute-bound: short prompts, small batches, inefficient kernels, padding, communication, or memory-capacity pressure can shift the bottleneck. Attention’s cost also depends on context length and implementation.

### Decode: small per-step work and repeated weight access

For a single decode step, each active sequence typically contributes only a small amount of new-token computation, while the model’s parameters must still be accessed to calculate that token. At low batch sizes, there may be too little parallel work to amortize those reads, making weight-memory bandwidth important. Attention also reads an increasingly long KV cache as context grows, adding memory traffic; at high concurrency or long contexts, KV-cache bandwidth/capacity can be a major constraint.

Batching more sequences can reuse weights across requests and increase arithmetic intensity, improving throughput, but it raises KV-cache use and may worsen per-request latency. Quantization can reduce bytes moved, but may affect quality and kernel efficiency.

### Concise interview answer

“Prefill handles many prompt tokens together, producing large parallel matrix operations and reusing weights across token positions, so arithmetic intensity is often high and compute becomes the limit. Decode processes one next-token step per sequence, so at low batch sizes it does relatively little work while repeatedly reading model weights and KV state; memory bandwidth often dominates. Long contexts and larger batches can change the bottleneck, so I verify with profiling rather than treating the distinction as absolute.”

### Revision summary

| Phase | Typical bottleneck | Why |
|---|---|---|
| Prefill | Compute, often. | Parallel token work and large matrix operations. |
| Decode | Memory bandwidth, often at low batch. | Repeated weight/KV reads per generated token. |
| Exceptions | Batch size, context, kernels, hardware, communication. | Can shift either phase’s dominant resource. |
| Trade-off | More batching/quantization. | Throughput or bandwidth benefit versus latency, memory, or quality. |

<br><br><br>

## What is chunked prefill, and why does it improve tail latency under mixed traffic?

**Answer:**

### Definition and scheduling problem

**Chunked prefill** divides a long prompt’s prefill into smaller token blocks instead of processing the entire prompt as one large uninterrupted scheduling unit. The server schedules these chunks alongside decode steps from active requests. This is useful in mixed traffic: long-prompt requests need substantial prefill, while users with active generations need regular decode service.

Without chunking, a large prefill can occupy accelerator execution for a long interval and delay decode work, increasing inter-token latency and p95/p99 response times for other requests. Chunking creates scheduling opportunities between blocks, reducing this head-of-line interference.

### How it works

1. Tokenize the request and determine the prompt length and available KV memory.
2. Split the prompt into bounded chunks; process each chunk and update the request’s KV state.
3. Between chunks, let the scheduler serve decode steps or other eligible requests, subject to dependency and memory constraints.
4. Continue until prefill completes, then begin normal autoregressive decoding for that request.

Chunk size and scheduling policy are runtime-specific. Smaller chunks improve responsiveness to other requests but can increase launch/scheduling overhead or reduce kernel efficiency. Larger chunks improve prefill efficiency but increase the time other requests wait. The system must also manage fairness so a stream of small decodes does not starve long-prompt requests.

### Measurement and caveats

Compare mixed-workload p95/p99 inter-token latency, TTFT for long prompts, throughput, GPU utilization, and prefill completion time against unchunked scheduling. Test prompt-length distributions and concurrency representative of production. Chunked prefill does not reduce the total number of prompt tokens or their fundamental compute; it changes when that work is scheduled.

### Concise interview answer

“Chunked prefill splits a long prompt into bounded blocks and schedules decode work between them. This prevents a large prompt from monopolizing the accelerator and creating head-of-line delays for already-streaming responses, which can improve tail inter-token latency under mixed traffic. Smaller chunks improve scheduling responsiveness but may add overhead or reduce efficiency; larger chunks do the reverse. It changes scheduling, not total prompt work, so I tune it using tail latency, TTFT, throughput, and utilization.”

### Revision summary

| Factor | Effect |
|---|---|
| Long unchunked prompt | Can block decode and worsen tail latency. |
| Smaller prefill chunks | Better scheduling granularity; more overhead possible. |
| Larger chunks | Better execution efficiency; more interference possible. |
| Capacity measurement | Mixed-workload p95/p99, TTFT, throughput, utilization. |

<br><br><br>

## What is Prefill-Decode Disaggregation, and when does it pay off?

**Answer:**

### Definition

**Prefill-decode disaggregation** separates prompt processing from token generation onto independently managed worker pools. A prefill worker processes the prompt and creates KV cache state; that state is transferred or made accessible to a decode worker, which generates output tokens. The pools can use different hardware, parallelism, batching, or scaling policies suited to each phase.

### Why separate the phases

Prefill and decode have different workload characteristics: prefill often needs high compute throughput for prompt processing, while decode is sequential per request and often sensitive to memory bandwidth, KV-cache capacity, and low inter-token latency. In a combined pool, bursts of long prompts may compete with latency-sensitive decoding. Separate pools can isolate those workloads and scale each according to its own demand.

### When it can pay off

Disaggregation is most attractive when:

- Prompt and output lengths or arrival patterns are substantially different.
- Prefill bursts cause measurable decode tail-latency problems.
- The deployment is large enough to keep both pools utilized.
- The infrastructure supports efficient KV transfer and scheduling.
- Different hardware configurations materially improve cost or throughput for each phase.

It may not be worthwhile for small deployments, uniform short prompts, or when transfer and coordination overhead exceed the saved compute or latency.

### Costs and engineering considerations

The KV cache can be large, so moving it across workers or nodes consumes network bandwidth, adds latency, and requires compatible layouts/model versions. The system needs request routing, KV ownership/lifetime management, backpressure between pools, cancellation cleanup, fault recovery, and scheduling across two queues. A prefill pool that is overloaded simply moves the bottleneck; decode capacity can also be stranded if the workload mix shifts. Compare end-to-end TTFT, inter-token latency, throughput, GPU utilization, KV-transfer time, network use, and total cost against a well-tuned colocated baseline.

### Concise interview answer

“Prefill-decode disaggregation runs prompt processing and autoregressive generation in separate worker pools. It can isolate long-prompt compute from latency-sensitive decode and let each phase use appropriate hardware and scaling. It pays off when phase workloads are imbalanced at sufficient scale and KV transfer is efficient. The costs are KV movement, network and coordination overhead, extra queues, and utilization imbalance. I’d adopt it only after comparing end-to-end latency, throughput, transfer cost, and GPU utilization against a tuned colocated system.”

### Revision summary

| Dimension | Disaggregated design |
|---|---|
| Prefill pool | Prompt processing; often compute-throughput oriented. |
| Decode pool | Autoregressive output; often bandwidth/KV oriented. |
| Main benefit | Workload isolation and independent scaling. |
| Main bottleneck | KV transfer, network, queue coordination, pool imbalance. |
| Capacity decision | Compare phase utilization and end-to-end gains at actual scale. |

<br><br><br>

## Explain the AI product lifecycle from ideation to production.

**Answer:**

### 1. Discover the problem and define success

Start with the user problem, not the model. Identify users, workflow, baseline, constraints, risk level, and the cost of errors. Decide whether AI is appropriate or whether search, rules, or conventional software is simpler. Define measurable acceptance criteria across task quality, safety, latency, availability, privacy, and cost. Specify what the system must refuse, escalate, or leave to a human.

### 2. Establish data and technical feasibility

Inventory data sources, rights, provenance, quality, representativeness, privacy, retention, and access controls. Determine whether the capability needs prompting, retrieval, fine-tuning, a pretrained model, or a non-LLM component. Build a small end-to-end prototype and a representative evaluation set early; do not rely solely on a polished demo or generic benchmark.

### 3. Build and evaluate the system

Implement ingestion/preprocessing, model orchestration, retrieval/tools, user experience, and policy controls. Version the model, prompt, data, index, tool schemas, and code. Evaluate the complete product—not only model outputs—using automated tests, expert or human review, adversarial cases, and realistic usage. Track quality slices, failure modes, and uncertainty.

### 4. Prepare production operations

Design authentication and authorization, privacy/retention, observability, quotas, rate limits, cost accounting, resilience, fallbacks, and incident response. Set SLOs and dashboards for quality and operations. Test load, dependency failure, model/provider outage, rollback, and data deletion. Document limitations and train support or human-review teams.

### 5. Release, monitor, and improve

Deploy with a canary, feature flag, or limited pilot. Compare live behavior to the baseline and stop or roll back if quality, safety, or SLOs regress. Monitor drift, user feedback, costs, error rates, and human overrides. Update evaluations using reviewed failures without contaminating protected holdouts. Reassess the product as data, models, policy, and user needs change.

### Concise interview answer

“I take an AI product from problem discovery and measurable success criteria through data/governance assessment, a feasibility prototype, system implementation, end-to-end evaluation, and production readiness. I version all model and data dependencies, define safety and operational controls, and release gradually with monitoring and rollback. In production I use feedback and reviewed failures to improve the system while protecting holdout evaluation and rechecking privacy, quality, latency, availability, and cost.”

### Revision summary

| Phase | Deliverable |
|---|---|
| Ideation | User problem, baseline, risk, success metrics. |
| Feasibility | Data audit, model/architecture choice, representative evaluation. |
| Build | Versioned pipeline, integrations, UX, tests and guardrails. |
| Launch | SLOs, security/privacy, cost, load/failure testing, rollout plan. |
| Operate | Monitoring, feedback, incident response, controlled iteration. |

<br><br><br>

## What is LLMOps, and how does it differ from traditional MLOps?

**Answer:**

### Definition

**LLMOps** is the engineering and operational practice for developing, evaluating, deploying, and maintaining applications built with large language models. It includes model lifecycle management, but also the surrounding system: prompts, retrieval indexes, context assembly, tools/agents, safety policies, inference infrastructure, and application-level evaluation.

### What carries over from MLOps

Both LLMOps and traditional MLOps need data and artifact versioning, reproducible experiments, deployment automation, monitoring, access control, rollback, and governance. Both must detect drift, test changes, and manage reliability and cost.

### What is distinctive for LLM applications

| Area | Traditional predictive ML | LLMOps emphasis |
|---|---|---|
| Inputs/outputs | Often fixed feature and label schemas. | Prompts, long contexts, retrieved evidence, generated text/tool calls. |
| Evaluation | Accuracy, precision/recall, task-specific metrics. | Grounding, instruction following, citation validity, safety, hallucination and human judgments. |
| Runtime | Often one model inference. | Token generation, streaming, variable token cost, tool/retrieval chains, long-lived context. |
| Change surface | Model and feature pipeline. | Model, prompt/template, tokenizer, retrieval data/index, tools, policies, routing. |
| Monitoring | Feature/prediction drift and service health. | Also prompt/token behavior, retrieval quality, refusal/guardrail outcomes, tool errors and output quality. |

These are tendencies rather than absolutes: traditional ML can also have complex pipelines, and not every LLM application needs agents or RAG. The operational principle is to version and evaluate the entire behavior-producing system, not just model weights. Model-based evaluators need calibration and human checks; logs must respect privacy and retention.

### Concise interview answer

“LLMOps applies MLOps discipline to LLM-based products while expanding the managed lifecycle to include prompts, retrieval, tools, context, safety policies, and variable-cost generation. It inherits reproducibility, deployment, monitoring, governance, and rollback, but evaluation must also cover grounding, instruction following, safety, citations, and tool behavior. In production I version the full configuration and data dependencies and observe both infrastructure SLOs and application quality.”

### Revision summary

| Shared with MLOps | LLMOps-specific emphasis |
|---|---|
| Versioning, CI/CD, governance, monitoring, rollback. | Prompt/model/index/tool/policy versioning. |
| Data quality and drift. | Retrieval/context quality, generated outputs and tool calls. |
| Service health and cost. | Token-based variability, streaming and inference capacity. |
| Model evaluation. | Grounding, safety, human evaluation and evaluator calibration. |

<br><br><br>

## How do you serve LLMs in production?

**Answer:**

### Define the serving contract

Specify supported models and modalities, context/output limits, streaming semantics, tool calling, latency/availability SLOs, tenant boundaries, privacy/retention, and cost limits. Serving may use a managed provider, self-hosted runtime, or a hybrid; the right choice depends on control, compliance, workload, and economics.

### Reference request path

```text
Client -> API gateway/auth/quotas -> request validation
      -> policy and model routing
      -> retrieval/context assembly or tool planning
      -> inference scheduler / model workers
      -> stream or structured response
      -> output validation / telemetry
```

1. Authenticate and authorize; apply tenant quotas, request-size limits, and data-handling rules.
2. Validate message schema, model capability, context length, tool definitions, and decoding parameters. Return explicit errors for invalid requests.
3. Assemble only necessary conversation and retrieved context; preserve source provenance and treat user/retrieved content as untrusted data.
4. Route by task, model capability, region, health, and cost. Keep a versioned registry for weights, tokenizer, prompt template, runtime, and policy.
5. Apply admission control and bounded queues. Schedule batching while balancing throughput and tail latency; manage KV-cache memory, concurrency, and cancellation.
6. Stream output with backpressure when useful. Validate structured responses and tool calls, then authorize any side effect outside the model.
7. Record privacy-minimized traces and usage metrics. Roll out changes through shadow/canary traffic, quality gates, and rollback.

### Reliability and monitoring

Use deadlines, circuit breakers, safe bounded retries, health checks, autoscaling, and graceful degradation. Monitor time-to-first-token, inter-token latency, p95/p99 completion latency, throughput, queue depth, token usage, GPU/KV-cache pressure, errors, cost, retrieval quality, safety outcomes, and task success. Protect prompts and outputs through encryption, access controls, retention limits, and deletion workflows.

### Trade-offs and capacity

Managed APIs reduce infrastructure burden but constrain control, pricing, and provider terms; self-hosting offers more control but requires GPU operations, model lifecycle management, and capacity planning. Larger models and deeper context may improve quality but increase latency, memory, and cost. Batching increases utilization but can increase queueing; strict admission limits protect SLOs but reject bursts. Estimate capacity from input/output tokens per second, active sequences, context lengths, model/hardware throughput, and provider quotas—not request count alone.

### Concise interview answer

“I serve LLMs behind an authenticated gateway that validates requests, enforces policy and quotas, assembles minimal context, and routes to a healthy compatible model pool. The inference layer uses admission control, bounded queues, batching, KV-cache management, cancellation, and streaming. Outputs and tool calls are validated, side effects are authorized separately, and changes use canary evaluation and rollback. I monitor latency percentiles, throughput, memory, errors, token cost, and application quality.”

### Revision summary

| Layer | Production responsibility |
|---|---|
| Gateway | Auth, validation, quotas, privacy and model routing. |
| Context/orchestration | Retrieval, bounded context, typed tools and provenance. |
| Inference | Scheduling, batching, KV cache, streaming and cancellation. |
| Operations | SLOs, monitoring, autoscaling, rollout and fallback. |
| Capacity | Tokens/sec, concurrency, context, model/hardware and quota. |

<br><br><br>

## What is model quantization?

**Answer:**

### Definition

**Quantization** represents model values—such as weights, activations, or KV-cache entries—using a lower-precision numeric format or compact integer code than the original representation. For example, an FP16 weight uses 16 bits, while an 8-bit or 4-bit representation uses fewer bits per stored weight, usually with scales/zero points or other metadata to approximate the original values.

### Why quantize

Reducing precision can lower model memory and storage, improve memory bandwidth, enable a model to fit on smaller hardware, and sometimes increase inference throughput. The effect depends on hardware kernels and the quantization scheme; fewer bits do not guarantee faster execution if the runtime lacks efficient support.

### Common dimensions of quantization

- **Weights:** Often quantized offline for inference; weight-only quantization can preserve higher-precision activations.
- **Activations:** Quantized during computation; calibration and supported kernels are important.
- **KV cache:** Lower-precision cache can reduce memory for long contexts and concurrency, with possible attention-quality impact.
- **Training:** Quantization can also be integrated into training or fine-tuning, such as quantization-aware training.

Methods differ in granularity (per-tensor, per-channel, per-group), calibration, and code representation. Quantization error can disproportionately affect outlier channels or sensitive layers. Evaluate perplexity or task quality and end-to-end behavior, not only model size.

### Practical selection

Choose precision against a concrete deployment constraint: whether the full model must fit on a device, whether memory bandwidth limits decode, or whether KV-cache capacity limits concurrent contexts. Compare the same model and prompt set across supported formats, measuring quality regressions on important task and safety slices alongside peak memory, TTFT, inter-token latency, and throughput. Keep a higher-precision checkpoint for rollback. If the chosen runtime falls back to slow dequantization or lacks optimized kernels, the smaller checkpoint may not improve latency.

### Concise interview answer

“Quantization reduces the number of bits used to represent weights, activations, or KV cache, trading numerical precision for lower memory and potentially lower bandwidth or faster inference. It can enable larger models or more concurrency on fixed hardware, but quality loss and speed depend on the scheme, model, and kernels. I benchmark quality, latency, throughput, and memory on the target runtime, and don’t assume lower bit width automatically means faster serving.”

### Revision summary

| Quantized component | Typical effect |
|---|---|
| Weights | Smaller model footprint and lower weight bandwidth. |
| Activations | Lower intermediate memory/traffic; requires runtime support. |
| KV cache | More context/concurrency within memory; possible quality loss. |
| Main trade-off | Memory/throughput gains versus quantization error and kernel efficiency. |

<br><br><br>

## Explain post-training quantization (PTQ) vs quantization-aware training (QAT). What breaks when you push weights to 2-4 bits?

**Answer:**

### PTQ versus QAT

**Post-training quantization (PTQ)** converts an already-trained model to a lower-precision representation without updating its original weights through a quantization-aware training process. It may use calibration data to estimate activation ranges or scales; weight-only methods can quantize weights while leaving activations at higher precision. PTQ is comparatively easy to apply and does not require the original training pipeline, but quality can degrade when rounding/clipping error is large or poorly calibrated.

**Quantization-aware training (QAT)** exposes training or fine-tuning to simulated quantization effects (often using fake-quantization operations in the forward pass) so the model can adapt to them. It can recover quality at a target precision, but requires training data, compute, implementation support, and careful validation. For LLMs, methods and tooling vary; do not assume conventional full QAT is always practical or necessary.

### What becomes difficult at 2–4 bits

At very low bit widths, each weight has few representable values, so rounding and clipping errors grow. Important issues include:

- **Outliers and uneven distributions:** A few large values can dominate a scale and reduce effective resolution for most weights. Per-channel or per-group scales and outlier handling may help, with added metadata or complexity.
- **Sensitive layers and activations:** Some layers, attention projections, normalization paths, or activation distributions may be more sensitive than others. Uniform quantization can cause disproportionate quality loss.
- **Accumulated error:** Small errors across many layers can damage perplexity, instruction following, reasoning, or long-context behavior.
- **Activation/KV effects:** Quantizing activations or KV cache adds different error sources; weight-only success does not prove that the entire inference path can use the same bit width.
- **Kernel and hardware support:** Unsupported formats may dequantize inefficiently or fail to deliver speed gains. Packing, group size, scale handling, and matrix kernels matter.
- **Distribution shift:** Calibration data that does not represent production prompts, languages, or sequence lengths may lead to poor activation ranges.

### Practical selection process

Benchmark candidate schemes at the actual model, task, prompt-length mix, and deployment hardware. Compare full-precision quality with perplexity and task-specific evaluations, safety/regression slices, latency, throughput, and memory. Consider mixed precision for sensitive layers, larger groups or a different quantizer, representative calibration data, or QAT/fine-tuning if PTQ misses quality thresholds. Validate end-to-end generation, not just a small synthetic benchmark.

### Concise interview answer

“PTQ quantizes a trained checkpoint, often with calibration, while QAT trains or fine-tunes with simulated quantization so weights can adapt. PTQ is cheaper and simpler; QAT may recover quality but needs training data and compute. At 2–4 bits, limited representable levels amplify rounding/clipping and outlier errors, which can accumulate across layers; activation/KV quantization and kernel support add separate risks. I’d benchmark representative task quality and serving performance, and use mixed precision or QAT only where measurements justify it.”

### Revision summary

| Method/issue | Key point |
|---|---|
| PTQ | Post-training conversion; simpler, quality depends on calibration/scheme. |
| QAT | Train with simulated quantization; more work, can adapt to error. |
| 2–4-bit risks | Outliers, layer sensitivity, accumulated error, activation/KV effects. |
| Runtime caveat | Hardware/kernel support determines actual speed and memory benefit. |
| Decision | Compare quality, safety, latency, throughput, and memory on target workloads. |

<br><br><br>

## How do you monitor LLM applications in production?

**Answer:**

### Monitor the service and the AI behavior

LLM monitoring should cover both conventional service health and application quality. A model endpoint can be healthy while retrieval is stale, tool calls are invalid, or answers become unsupported. Define SLOs and quality guardrails for the specific use case before selecting dashboards.

### What to measure

- **Reliability:** Request success/error rate, timeouts, retries, provider failures, cancellation, and dependency health.
- **Latency and capacity:** Time to first token, inter-token latency, end-to-end p50/p95/p99, queue depth, concurrency, throughput, and saturation.
- **Usage and cost:** Input/output tokens, model/provider, cache hit rate, tool/retrieval calls, cost per request and per successful task.
- **Application quality:** Task completion, schema validity, citation/evidence support, retrieval relevance, tool-call success, refusal/abstention, user feedback, and human override rates.
- **Safety and privacy:** Guardrail triggers, content-policy outcomes, prompt-injection signals, sensitive-data incidents, and access-control violations—recorded with minimal necessary data.

### Instrumentation and response loop

Attach a request/trace ID and version identifiers for model, prompt, retrieval index, tools, and policy. Capture structured metadata and stage timings; store prompts/outputs only when justified, access-controlled, and covered by retention policy. Use offline evaluations and sampled human review to assess quality that cannot be measured reliably from counters alone. Segment metrics by model/version, task, locale, tenant tier, and other appropriate slices while avoiding small-group privacy leaks.

Set alerts on SLO burn rates, error/latency changes, quality guardrails, cost anomalies, and data/retrieval freshness. Use canaries and rollback for regressions; investigate changes with traces and representative examples. Feed reviewed failures into regression suites without contaminating holdouts. Monitoring detects symptoms; observability and evaluation help identify causes.

### Trade-offs, bottlenecks, and capacity assumptions

Capturing full traces improves debugging but increases storage, privacy, and access risk; sampling and redaction reduce exposure but may miss rare failures. Automated quality metrics are cheap but can be weak proxies, so combine them with calibrated evaluators and human review. Evaluator calls and trace storage can become significant cost/throughput bottlenecks. Estimate telemetry volume as request rate × events/trace × average retained bytes × retention, and quality-review load as sampled requests × review time. Traffic, retention, and review rates are unspecified, so set budgets and sampling policies per risk tier.

### Concise interview answer

“I monitor infrastructure SLOs and AI-specific outcomes together: errors, p95/p99 and TTFT, queueing, token cost, retrieval quality, groundedness/citations, tool success, refusals, safety events, and user or reviewer feedback. Every trace carries model, prompt, index, and policy versions. I minimize sensitive content in telemetry, use sampled human evaluation for subjective quality, alert on regressions, and canary or roll back changes. Monitoring storage and review capacity must be budgeted, not treated as free.”

### Revision summary

| Layer | Signals |
|---|---|
| Service | Availability, errors, timeouts, latency, throughput, saturation. |
| LLM runtime | TTFT, inter-token latency, tokens, cache, model/provider. |
| Application | Retrieval, grounding, task success, schema/tool outcomes. |
| Risk | Safety, privacy, access policy, human overrides. |
| Operations | Versioned traces, alerts, sampling, retention and rollback. |

<br><br><br>

## What is LLM observability?

**Answer:**

### Definition

**LLM observability** is the ability to understand a language-model application’s internal behavior from its outputs and collected telemetry. It extends service monitoring with traces of the steps that produce an answer: request handling, prompt construction, model calls, retrieval, tool execution, validation, and response delivery.

### What an observable trace contains

A useful trace has a correlation ID and parent/child spans for each stage, with timestamps and durations. It may record:

- Model/provider and version, prompt-template version, decoding parameters, token counts, and cache status.
- Retrieved document IDs/scores/versions and reranker outcomes.
- Tool names, validated arguments, latency, result status, and retry/cancellation behavior.
- Guardrail and schema-validation outcomes, errors, and final response status.
- Privacy-safe cost, queueing, and token metrics.

Raw user content is not automatically required. When payload capture is necessary for debugging, use redaction, encryption, strict access, short retention, and user/organizational policy. Avoid placing secrets or sensitive data in logs and ensure tenant boundaries apply to traces and dashboards.

### How it differs from monitoring

Monitoring answers “Is the system within expected thresholds?” using metrics and alerts. Observability helps answer “Why did this request fail or produce this behavior?” by correlating signals across the request path. Neither replaces systematic evaluation: subjective correctness, groundedness, or safety needs labeled tests, expert review, and calibrated quality metrics.

Use traces to investigate errors such as retrieval misses, prompt-version regressions, provider latency, malformed tool arguments, or output-policy blocks. Join traces to deployment/version events so behavior changes can be attributed. Set sampling and retention based on risk and cost.

### Example diagnostic

If a user reports a wrong answer, a trace can show whether the request used an unexpected prompt/model version, retrieval returned stale or irrelevant passages, a tool timed out, or output validation altered the response. This narrows investigation to the failing stage; a trace alone does not establish that the answer is correct. Pair it with a reproducible test case and reviewed expected behavior.

### Concise interview answer

“LLM observability traces the full path that produced a response—prompt assembly, model/version, retrieval, tools, guardrails, latency, tokens, and errors—so teams can diagnose failures across components. Monitoring alerts on aggregate SLOs; observability supports per-request root-cause analysis, while evaluation measures quality against reviewed examples. I instrument structured spans and version metadata, but minimize or redact content and enforce strict access and retention.”

### Revision summary

| Concept | Purpose |
|---|---|
| Metrics | Aggregate health, latency, cost and quality signals. |
| Traces | Per-request timeline across model and dependency calls. |
| Logs/events | Structured errors, decisions, versions and outcomes. |
| Evaluation | Ground truth or reviewed quality measurement. |
| Governance | Redaction, access control, sampling and retention. |

<br><br><br>

## What are guardrails for LLMs, and how do you implement them?

**Answer:**

### Definition and layers

**Guardrails** are controls that constrain or validate an LLM application’s inputs, model behavior, tool use, and outputs against product, safety, privacy, and operational requirements. They are layered controls, not a single prompt instruction or a guarantee that the model cannot fail.

### A defense-in-depth implementation

1. **Input and identity checks:** Authenticate users, validate schema/size, enforce tenant and data permissions, and apply input policy checks where appropriate.
2. **Prompt/context construction:** Keep trusted instructions separate from user and retrieved content. Mark external content as untrusted, minimize context, and include only authorized evidence.
3. **Constrain tools:** Expose only necessary typed tools; validate arguments and authorization server-side; use least-privilege credentials, timeouts, idempotency, and user confirmation for consequential actions.
4. **Constrain outputs:** Use structured decoding/schema validation where supported, then validate business rules, citations, policy, and sensitive-data handling. Reject, repair with bounded retries, redact, or escalate as explicitly designed.
5. **Fallback and human review:** For unsupported, uncertain, high-impact, or safety-critical cases, ask for clarification, abstain, or route to a qualified reviewer.
6. **Monitor and improve:** Log policy outcomes with minimal sensitive content, test adversarial inputs, review false positives/negatives, and update versioned guardrail policies through staged rollout.

Prefer deterministic enforcement for hard requirements such as access control, spending limits, and allowed actions. Classifiers and model judges can help with nuanced content but are probabilistic; calibrate them and test against human-reviewed cases. Prompt-level instructions are useful but insufficient as the only control.

### Trade-offs, bottlenecks, and capacity assumptions

More checks improve defense but add latency, cost, and false-positive risk; retries can multiply calls and may not fix a policy violation. Model-based filters scale but can be inconsistent, while human review is costly and capacity-limited. Guardrail chains can become a latency bottleneck; measure each stage and apply risk-tiered controls without bypassing hard security requirements. Estimate overhead as request rate × checks per request × check latency/cost, plus escalation volume × review time. Risk profile and traffic are unspecified, so tune thresholds with representative red-team and benign examples.

### Concise interview answer

“I implement guardrails in layers: authenticate and validate inputs, keep untrusted content separate from trusted instructions, constrain tools with server-side authorization, validate outputs and schemas, and abstain or escalate when evidence or confidence is insufficient. Hard invariants use deterministic controls; model-based filters supplement but do not replace them. I evaluate false positives and negatives, measure added latency/cost, and version and monitor policy changes.”

### Revision summary

| Layer | Example control |
|---|---|
| Input | Auth, schema, size, privacy and policy validation. |
| Context | Provenance, authorization, prompt-injection containment. |
| Action | Typed least-privilege tools, server-side checks, confirmation. |
| Output | Schema/business/policy validation, bounded repair or refusal. |
| Operations | Risk-based review, red-team tests, monitoring and staged updates. |

<br><br><br>

## How do you implement content filtering for AI outputs?

**Answer:**

### Define policy and the filtering boundary

Start with the product’s content policy, applicable requirements, user population, modalities, languages, and consequences of false positives/negatives. Define categories, severity, thresholds, and actions with policy owners. Output filtering is one layer; it does not replace input moderation, access control, tool authorization, or human review.

### Filtering pipeline

1. **Check the request and context:** Apply input policy to user content and relevant retrieved/tool data when needed. Treat external content as untrusted and do not let it alter policy.
2. **Generate under constraints:** Use an appropriate system policy and model configuration, but do not rely on prompt instructions alone.
3. **Inspect the candidate output:** Apply deterministic rules (e.g., schema, prohibited fields, secrets where detectable) and policy classifiers for relevant categories. For multimodal output, use modality-appropriate detection.
4. **Choose a defined action:** Allow, redact a well-bounded sensitive span, regenerate once with a specific correction, refuse, or send for human review. Avoid repeated uncontrolled regeneration loops.
5. **Validate the final response:** Re-check repaired or transformed output and ensure it remains useful and does not introduce new policy violations. If checks fail or are unavailable, fail closed for high-risk categories.
6. **Communicate clearly:** Provide a policy-consistent refusal or safe alternative without exposing hidden policy details or falsely claiming that a response was delivered.
7. **Record and evaluate:** Store policy/model versions and outcome metadata with minimal content; review false positives, false negatives, appeals, and subgroup performance.

### Quality, privacy, and operations

Build a labeled evaluation set with benign boundary cases, adversarial phrasing, multilingual and modality slices. Measure category precision/recall, severity-weighted misses, overblocking, refusal quality, latency, and reviewer override. Calibrate thresholds to the use case; a single universal threshold is rarely suitable. Redact logs, control access, and define retention.

### Trade-offs, bottlenecks, and capacity assumptions

An output classifier adds latency and can block benign content; inline checks are safer but may lengthen time-to-first-token, while post-hoc checks can require buffering before release. Streaming systems may need incremental moderation with a short holdback window, which trades immediacy for reviewability. More complex multimodal checks cost more and may miss brief events. Estimate moderation compute from output rate × tokens/media segments × classifier cost, plus human escalation fraction. Output lengths, modality, and risk policy are unspecified, so benchmark category-specific quality and end-to-end latency.

### Concise interview answer

“I define policy categories and actions, then inspect generated output with deterministic checks and calibrated classifiers appropriate to the content and modality. Depending on risk, I allow, redact, perform one bounded repair, refuse, or escalate; the final response is rechecked. Hard security rules remain deterministic, and checks failing on high-risk paths fail closed. I evaluate false positives/negatives, severity, latency, and subgroup performance while protecting logged content.”

### Revision summary

| Stage | Responsibility |
|---|---|
| Policy | Category definitions, severity, thresholds, ownership. |
| Detection | Deterministic validation + calibrated modality-aware classifiers. |
| Action | Allow, bounded redact/repair, refuse, or human escalation. |
| Release | Final recheck; explicit failure behavior. |
| Evaluation | Precision/recall, severity, overblocking, latency and privacy. |

<br><br><br>

## How do you estimate the cost of running an AI-powered feature in production?

**Answer:**

### Build a workload model

Estimate cost per successful user task, not only price per model call. Define usage by request class, model/provider, input/output token distribution, modality, retrieval/tool chain, cache behavior, retries, and peak concurrency. Distinguish fixed infrastructure from variable per-request expenses.

### Cost components

1. **Inference:** Input and output tokens × model-specific rates for managed APIs, or GPU/accelerator time, node utilization, and amortized hardware/runtime costs for self-hosting.
2. **Auxiliary models:** Embeddings, rerankers, classifiers, ASR/TTS, vision, OCR, moderation, and evaluation calls.
3. **Retrieval and data:** Vector/full-text database storage, index replicas, query compute, object storage, backups, and data transfer.
4. **Tools and orchestration:** External API calls, workflow steps, queueing, retries, and orchestration infrastructure.
5. **Operations and review:** Logging/tracing, observability retention, human review, support, security/compliance controls, and model evaluation.
6. **Reliability overhead:** Reserved/idle capacity, replication, failover headroom, model warmup, index rebuilds, and failed/partial requests.

### Estimation process

1. Instrument a representative prototype to measure tokens, model calls, cache hits, retrieval/tool usage, latency, and failure/retry rates per task.
2. Multiply distributions by expected average and peak request volume; include seasonality, growth, concurrency, and user adoption scenarios.
3. Calculate cost per task and per successful outcome. Include the fraction escalated to humans or retried and separate expensive/long-context cases.
4. Run sensitivity analysis for model mix, context/output limits, provider pricing, cache rate, utilization, and traffic growth.
5. Validate with a production-like load test and compare forecast to actual billing and infrastructure usage after launch.

Avoid false precision when usage assumptions are unknown. Use ranges and state assumptions; token counts, provider rates, GPU utilization, and media duration can change the estimate substantially.

### Trade-offs, bottlenecks, and capacity assumptions

Larger models, longer context, deeper retrieval, and extra verification may improve quality but multiply token, GPU, and latency cost. Self-hosting may lower marginal cost at high utilization but introduces fixed capacity, operations, and idle-time risk; managed APIs shift cost to usage and provider constraints. Low utilization wastes reserved GPU capacity; high utilization raises queueing and tail latency. The key bottleneck may be provider quota, GPU memory, retrieval, storage, or human review. Volume, token mix, prices, and success rate are unspecified, so estimate low/base/high scenarios and report sensitivity rather than a single unsupported number.

### Concise interview answer

“I model cost per successful task by measuring the full workflow: model input/output tokens or GPU time, embedding/reranking/moderation calls, retrieval, tools, retries, storage/egress, observability, and human review. I multiply a representative per-task profile by expected volume and concurrency, then add reliability and idle-capacity overhead. I run low/base/high scenarios for token mix, model routing, cache hit rate, and utilization, and reconcile forecasts with actual usage after launch.”

### Revision summary

| Cost area | Estimate from |
|---|---|
| Model inference | Tokens or accelerator time × rate/utilization. |
| Pipeline calls | Embeddings, reranking, safety, tools, retries. |
| Data/platform | Index/storage, networking, logs and backups. |
| Human/operations | Review, support, compliance and reliability headroom. |
| Output metric | Cost per successful task across low/base/high traffic scenarios. |

<br><br><br>

## How do you optimize LLM inference costs in production?

**Answer:**

### Optimize cost per successful task, not just tokens

Start by profiling the full request path and segmenting cost by task, model, tenant, prompt length, output length, cache hit, retrieval, tool use, retries, and success. A cheaper call that fails more often or causes repeated retries may increase cost per useful outcome.

### Cost-reduction levers

1. **Right-size model and route:** Use smaller or specialized models for tasks that meet quality thresholds; reserve larger models for cases that need them. Validate routing on task-specific evaluations.
2. **Reduce unnecessary tokens:** Trim repeated instructions, retrieve only relevant context, deduplicate passages, summarize history carefully, and set sensible output limits. Do not remove evidence required for correctness or safety.
3. **Cache reusable work:** Cache embeddings, retrieval results, stable prefixes, or exact responses when semantics, freshness, model version, and tenant scope allow it. Track wrong/stale cache hits, not just hit rate.
4. **Improve serving efficiency:** Batch compatible requests, use continuous batching or prefix/KV caching where supported, tune concurrency and queueing, and use quantization only after quality/runtime benchmarking.
5. **Avoid redundant calls:** Combine stages where safe, parallelize independent calls only when it reduces wall time without waste, and stop agent/tool loops with explicit budgets and termination criteria.
6. **Choose deployment economics deliberately:** Compare managed API pricing with self-hosted accelerator utilization, operations, storage, and failover overhead at observed traffic levels.
7. **Control retries and failures:** Use bounded retries for transient errors, deadlines, idempotency, and circuit breakers. Do not spend repeatedly on a request that cannot succeed.
8. **Optimize auxiliary services:** Measure embedding, reranking, moderation, and tool calls; choose smaller/cheaper components where they meet required quality.

### Guardrails and validation

For every optimization, compare task success, factual grounding, safety, latency, throughput, and cost per successful task against a baseline. Preserve holdout sets and use canary/A-B rollout for impactful routing or model changes. Keep cost optimization from silently weakening required policy controls.

### Trade-offs, bottlenecks, and capacity assumptions

Smaller models and shorter context reduce cost but may lower quality or increase fallback/retry rates. Batching increases utilization but can increase queueing and tail latency; self-hosting lowers marginal cost only when utilization justifies fixed capacity. Cache effectiveness depends on repetition and freshness constraints. The bottleneck may be model inference, provider quota, retrieval, GPU memory, or human review. Request volume, token mix, traffic repetition, prices, and SLOs are unspecified, so use low/base/high scenarios and measure cost per successful task before scaling an optimization.

### Concise interview answer

“I profile end-to-end cost per successful task, then reduce avoidable work: route simple requests to cheaper models, minimize redundant context, cache only safe reusable stages, batch efficiently, and bound retries/tool loops. I also compare managed and self-hosted economics at real utilization. Each change must pass quality, safety, latency, and cost evaluation; a lower token bill is not a win if it causes more failures or harmful regressions.”

### Revision summary

| Lever | Validate against |
|---|---|
| Model routing | Task quality, fallback rate, latency. |
| Token/context reduction | Grounding and completeness. |
| Caching | Freshness, authorization, wrong-hit rate. |
| Serving/runtime | Throughput, tail latency, memory, utilization. |
| Overall objective | Cost per successful task, not nominal cost per call. |

<br><br><br>

## How do you implement A/B testing for LLM systems?

**Answer:**

### Define the experiment before routing traffic

Specify the hypothesis and the exact change: model, prompt, retrieval/index, tool policy, decoding parameters, or user experience. Choose a primary user/task outcome and guardrail metrics for safety, correctness, latency, availability, and cost. LLM outputs are stochastic, so plan for variance and use a representative sample rather than judging by a few examples.

### Experiment design

1. **Build a pre-launch evaluation:** Compare variants offline on the same held-out cases, including important task slices and safety tests. Do not deploy a variant that violates hard policy or quality gates simply to gather live data.
2. **Randomize at the right unit:** Assign users, accounts, or sessions consistently to a variant to avoid a user seeing inconsistent behavior. Use stratification where cohorts differ materially; avoid leaking treatment into control through shared cache or state.
3. **Keep the treatment isolated:** Version and log model, prompt, retrieval, tools, decoding settings, and relevant data/index versions. Change one principal factor at a time when attribution matters.
4. **Determine sample size and duration:** Use baseline rates, expected effect, variance, traffic, and statistical power. Account for delayed outcomes, repeated users, seasonality, and novelty effects.
5. **Run with safety gates:** Start with a small canary, monitor guardrails and operational SLOs, then expand only if predefined criteria pass. Stop early for safety or severe reliability regressions; avoid repeated peeking that invalidates inference.
6. **Analyze beyond averages:** Report confidence intervals, task and subgroup slices, cost per successful task, latency percentiles, human overrides, and failure modes. Check for sample-ratio mismatch and missing telemetry.
7. **Decide and preserve results:** Promote, iterate, or roll back based on the hypothesis and guardrails. Save experiment configuration and results for reproducibility.

Use human preference evaluations for subjective quality where appropriate, but blind and randomize comparisons and calibrate evaluators. A/B tests measure product impact; they do not prove safety for rare high-severity cases, which need targeted testing and review.

### Trade-offs, bottlenecks, and capacity assumptions

More traffic and longer duration improve power but expose more users and incur more inference cost. User-level randomization reduces contamination but can require larger samples than request-level tests. LLM stochasticity and delayed outcomes increase variance; offline evaluation is cheaper but may not predict real behavior. Capacity depends on traffic split, calls per task, output lengths, and the number of variants; no baseline or effect size is specified, so calculate sample size before launch and reserve evaluation/inference capacity.

### Concise interview answer

“I define a hypothesis, primary outcome, and non-negotiable quality/safety/latency guardrails, then compare variants offline before a controlled live test. I randomize consistently at the user or account level, version the complete configuration, size the experiment for power and delayed outcomes, and start with a canary. I analyze confidence intervals and slices—not just averages—and stop for guardrail regressions. A/B testing measures user impact but complements, rather than replaces, safety evaluation.”

### Revision summary

| Step | Purpose |
|---|---|
| Offline gate | Exclude clear quality/safety regressions. |
| Randomization | Avoid user inconsistency and contamination. |
| Power/duration | Account for variance, repeats, and delayed outcomes. |
| Guardrails | Protect quality, safety, latency, availability and cost. |
| Analysis | Confidence, slices, failures, cost per successful task. |

<br><br><br>

## What is CI/CD for AI applications, and how does it differ from traditional CI/CD?

**Answer:**

### Definition and distinction

**CI/CD for AI applications** automates integration, testing, release, and deployment of the code and artifacts that determine AI behavior. Traditional CI/CD commonly builds and tests deterministic code artifacts; AI releases also need evaluation of data, model, prompt, retrieval, and policy changes whose outputs can be probabilistic and distribution-dependent.

### A practical pipeline

1. **Source and artifact checks:** Lint, type-check, unit-test, scan dependencies/secrets, validate schemas, and verify model/data artifact provenance and checksums.
2. **Build reproducibly:** Package application code with pinned runtime, model/tokenizer version, prompt templates, retrieval configuration, and policy version. Do not pull mutable “latest” assets in production.
3. **Run deterministic integration tests:** Test APIs, tool schemas, authorization, failure handling, input/output limits, and data-processing paths.
4. **Run AI evaluations:** Use versioned representative regression sets for task quality, grounding, safety, structured-output validity, latency, and cost. Include slice-level and adversarial tests; compare with the current production baseline.
5. **Gate and approve:** Enforce hard safety/quality thresholds and require domain or human approval for high-impact changes. Keep protected holdouts separate from tuning and routine prompt iteration.
6. **Deploy progressively:** Use feature flags, shadow traffic, canary cohorts, or staged rollout. Monitor live guardrails and service SLOs; halt or roll back when thresholds fail.
7. **Record and reproduce:** Store commit, artifacts, configuration, evaluator versions, test results, approvals, and rollout decisions in an auditable release record.

### What differs operationally

AI output tests may be probabilistic, require statistical tolerances or human review, and can regress because the data distribution or external provider changed even when code did not. Hosted models may be updated outside the application team’s release cycle, so pin versions where possible and monitor provider changes. Data pipelines and indexes need their own validation, migration, and rollback plan.

### Trade-offs, bottlenecks, and capacity assumptions

Comprehensive evaluation increases confidence but adds inference cost and release time; smaller smoke suites are fast but may miss rare failures. Human review raises quality for subjective/high-risk cases but can limit release throughput. Model downloads, index builds, and full test suites can dominate CI capacity. Estimate pipeline load from releases × test cases × model calls/repetitions, plus artifact size and human review time. Project size, release frequency, and evaluation cost are unspecified, so use fast checks on each change and broader gated suites for promotion.

### Concise interview answer

“AI CI/CD retains code build, tests, security scans, and deployment automation, but adds versioned model/data/prompt/index artifacts and behavioral evaluation. I gate releases on task, grounding, safety, latency, and cost tests, use human approval where risk requires it, and deploy via shadow or canary with rollback. Because outputs are probabilistic and providers/data can change, I preserve evaluation sets and full release provenance rather than relying only on unit tests.”

### Revision summary

| Pipeline stage | AI-specific concern |
|---|---|
| Build | Pin code, model, tokenizer, prompt, data/index and policy. |
| Test | Deterministic integration + statistical/task/safety evaluation. |
| Gate | Thresholds, protected holdouts, human approval where needed. |
| Deploy | Shadow/canary, live monitoring, rollback. |
| Capacity | Evaluation calls, repetitions, artifact/index builds, reviewer time. |

<br><br><br>

## How do you version and manage prompts in production?

**Answer:**

### Treat prompts as release artifacts

A production prompt includes more than a text string: system/developer instructions, message structure, examples, variables, tool definitions, output schema, and sometimes retrieval/context assembly rules. Version it alongside the model, tokenizer/chat template, tools, policy, and evaluation set so the behavior can be reproduced.

### Prompt lifecycle

1. **Store prompts in source control or a governed registry:** Use immutable versions, named environments, ownership, change history, and review. Avoid editing production prompts ad hoc in a console without an audit trail.
2. **Use typed templates:** Declare required variables and escaping/serialization rules. Validate that user or retrieved content cannot alter trusted instruction boundaries; keep untrusted data in clearly separated message/content fields.
3. **Test changes:** Run unit tests for rendering, variable coverage, token budgets, and tool schemas, plus regression evaluations for task quality, grounding, safety, refusals, and cost.
4. **Promote progressively:** Deploy to development/staging, then shadow or canary traffic using a feature flag. Compare against the current prompt with explicit guardrails and rollback.
5. **Log the resolved version:** Record prompt ID/version and other behavior-affecting configuration on each trace. Store rendered prompt content only when necessary and privacy-approved.
6. **Manage secrets and data:** Never embed credentials or private keys in prompts. Minimize personal data, control access, and apply retention/deletion to prompt logs.
7. **Rollback cleanly:** Keep prior immutable versions and ensure the serving system can route back without changing model/data versions unexpectedly.

Prompt changes can interact with model and retrieval changes, so bundle or independently tag each component to preserve attribution. Use experiments for material behavior changes, and keep a protected holdout set.

### Trade-offs, bottlenecks, and capacity assumptions

Central registries improve governance and rollback but can slow iteration if review processes are heavy; ad hoc changes are fast but hard to audit and reproduce. Longer prompts may improve instructions/examples yet consume context, prefill latency, and token cost. Evaluation is often the release bottleneck, especially for subjective or multilingual tasks. Capacity depends on prompt variants × test cases × model calls/repetitions; prompt count and release cadence are unspecified, so automate fast structural checks and reserve full evaluations for promotion.

### Concise interview answer

“I version prompts as immutable, reviewed artifacts with typed variables and explicit dependencies on model, tools, schema, and retrieval configuration. Each change goes through rendering/security checks and behavioral regression evaluation, then staging and canary rollout with feature-flag rollback. Production traces record the exact prompt version, while raw content is retained only when necessary and permitted. I never put secrets in prompts, and I measure token and latency impact as well as output quality.”

### Revision summary

| Practice | Benefit |
|---|---|
| Immutable prompt versions | Reproducibility and rollback. |
| Typed templates | Safe rendering and variable validation. |
| Regression evaluation | Catch task, grounding, safety and cost regressions. |
| Canary/feature flags | Limit exposure and enable fast rollback. |
| Trace version metadata | Diagnose exactly which prompt produced behavior. |

<br><br><br>

## What is model versioning, and how do you handle model rollbacks?

**Answer:**

### Version the complete behavior-producing bundle

**Model versioning** identifies an immutable model artifact or provider model revision so a deployment can be reproduced and compared. For an LLM application, model weights alone are not enough: tokenizer, chat template, quantization/runtime, prompt, retrieval/index, tools, safety policy, and decoding configuration can all change behavior. Record these dependencies and their compatibility.

### Release and rollback workflow

1. **Register artifacts immutably:** Store model/provider identifier and revision, checksums where available, tokenizer/configuration, license/terms, quantization, runtime, and evaluation results.
2. **Establish a baseline:** Run representative task, safety, latency, throughput, and cost evaluations against the current production bundle.
3. **Deploy progressively:** Load the candidate in a separate pool or route a small canary cohort. Keep model and dependent artifacts addressable by version.
4. **Monitor release gates:** Compare quality guardrails, errors, latency percentiles, token usage, tool/retrieval behavior, and cost against the baseline. Use fast alerts for severe regressions.
5. **Rollback traffic/configuration:** Route back to the last known-good compatible bundle or model pool. Keep schemas and indexes backward-compatible during the rollback window; reverting weights alone may not undo prompt/index changes.
6. **Handle state and data:** Avoid destructive migrations during rollout; version caches, indexes, and conversation state. Ensure in-flight requests and partial streams have explicit completion or cancellation behavior.
7. **Investigate and record:** Preserve release metadata and privacy-approved traces, identify root cause, and add a regression test before re-promotion.

For hosted providers that do not expose immutable model revisions, use the most stable available identifier, record provider response metadata, maintain evaluation probes, and plan for behavior drift. Do not claim exact reproducibility if the provider can change weights behind an alias.

### Trade-offs, bottlenecks, and capacity assumptions

Keeping multiple model versions warm enables fast rollback but uses GPU memory/capacity; cold rollback saves resources but adds load time and recovery delay. Canary evaluation limits exposure but requires enough traffic and observability to detect differences. Model, tokenizer, prompt, and index migrations can be coupled; rollback compatibility is a major bottleneck if schemas or data formats change irreversibly. Capacity should reserve room for candidate and stable pools plus failover; model size, traffic, and RTO are unspecified, so determine warm/cold strategy from explicit rollback targets and load tests.

### Concise interview answer

“I version an immutable behavior bundle—not just weights—including model revision, tokenizer, runtime/quantization, prompt, tools, retrieval index, and policy. I evaluate against a production baseline, deploy to a separate pool or canary, monitor quality and SLO guardrails, and keep the last-known-good compatible bundle available. Rollback routes traffic and restores compatible configuration; it must account for caches, schemas, indexes, and in-flight requests. For mutable hosted aliases, I monitor for drift and avoid claiming reproducibility that the provider cannot guarantee.”

### Revision summary

| Control | Purpose |
|---|---|
| Immutable bundle | Reproduce and compare behavior. |
| Baseline/canary | Detect regressions with limited exposure. |
| Compatibility | Keep prompts, tokenizer, schema, index and state rollback-safe. |
| Provider drift | Record revision metadata and maintain evaluation probes. |
| Capacity | Warm candidate/stable pools versus cold rollback RTO. |

<br><br><br>

## How do you implement rate limiting and throttling for LLM APIs?

**Answer:**

### Protect shared capacity fairly

**Rate limiting** bounds how much work a caller can submit over time; **throttling** delays or rejects work when a service is at or near capacity. LLM requests consume variable resources: one long-context generation can cost far more tokens, memory, and GPU time than a short request. Therefore, enforce both request-based and token/compute-aware limits rather than relying only on requests per second.

### A practical control strategy

1. **Define limits and identities:** Apply policy at appropriate scopes, such as organization, user, API key, model, and endpoint. Combine per-minute request limits with input/output token budgets, concurrency limits, and daily spend or usage caps. Set explicit priorities for interactive, batch, and internal workloads.
2. **Use a suitable limiter:** A token bucket permits controlled bursts while enforcing a sustained rate. A sliding window can give a more precise rolling quota; a fixed window is simpler but can allow boundary bursts. For distributed gateways, use a shared store or centralized admission service when limits must be consistent across replicas; local counters alone can oversubscribe the global quota.
3. **Estimate variable request cost:** Count input tokens before dispatch when feasible, reserve an output-token budget, and reconcile with actual usage afterward. For model-serving systems, also limit concurrent sequences or estimated GPU memory/work, because token rate alone may not protect KV-cache capacity.
4. **Apply admission and queueing:** Reject, queue, or shed low-priority work when concurrency or queue limits are reached. Bound queue length and wait time; enforce request deadlines so stale interactive work does not consume capacity. Give batch workloads a separate queue or schedule them during spare capacity.
5. **Return actionable signals:** Respond with an appropriate throttling status and retry guidance, such as `Retry-After`, plus remaining quota/reset metadata when safe. Clients should use bounded exponential backoff with jitter, respect deadlines, and avoid retrying non-retryable errors.
6. **Prevent abuse and cost surprises:** Authenticate before allocating expensive inference resources, cap payload/context and generation sizes, and detect repeated retries or usage anomalies. Ensure a caller cannot bypass limits by changing model aliases or creating many keys under one account.
7. **Observe and tune:** Track allowed, queued, rejected, and timed-out requests; token usage; concurrency; queue delay; provider quota errors; and fairness by tenant and priority. Alert on saturation and sudden spend changes.

Coordinate gateway limits with upstream provider quotas and serving capacity. If an external provider throttles despite local admission control, use bounded retries or fallback only when semantically and contractually appropriate; uncontrolled retries can amplify an outage.

### Trade-offs, bottlenecks, and capacity assumptions

Strict limits protect availability and spend but can reject legitimate bursts; larger queues smooth bursts but raise latency and consume memory. Token estimation adds overhead and may differ from provider accounting. A centralized limiter improves global accuracy but adds a dependency and potential latency; distributed local limits scale well but need conservative per-replica budgets or coordination. Capacity planning needs arrival rates, token-length distributions, concurrency, provider quotas, and latency SLOs; these are unspecified, so load-test burst and sustained traffic separately and reserve headroom for variance.

### Concise interview answer

“I enforce tenant-aware limits on request rate, token budget, concurrency, and spend, because LLM calls have variable cost. A token bucket handles bursts; bounded queues, deadlines, and priority-aware admission protect latency and capacity. The gateway returns retry guidance, while clients use bounded backoff with jitter. I reconcile estimated with actual token usage, coordinate with provider quotas, and monitor fairness, saturation, rejections, and spend. Exact limits come from workload distributions and load tests, not a single requests-per-second number.”

### Revision summary

| Control | Purpose |
|---|---|
| Request, token, concurrency, spend quotas | Bound different dimensions of LLM cost. |
| Token bucket/admission | Smooth bursts and protect scarce capacity. |
| Bounded queues and deadlines | Avoid unbounded latency and wasted work. |
| Retry guidance and backoff | Reduce retry storms. |
| Tenant-level telemetry | Tune limits and identify unfairness or abuse. |

<br><br><br>

## How do you handle model updates and migrations without downtime?

**Answer:**

### Make the new path ready before shifting traffic

Zero-downtime model migration means continuing to serve requests while introducing a new model, runtime, or related artifact. The key is to separate preparation from traffic cutover and to keep a compatible, known-good path available. “No downtime” does not guarantee identical outputs; behavior and latency still require evaluation.

### Staged migration workflow

1. **Inventory dependencies:** Identify model and tokenizer revisions, serving runtime, quantization, prompt/chat template, tool schemas, retrieval configuration, safety policies, request/response contracts, caches, and state. Mark which components can be changed independently and which require coordinated migration.
2. **Validate before production:** Load the candidate in an isolated environment and run representative functional, quality, safety, load, and failure tests. Verify startup/readiness, health checks, capacity, and compatibility with current clients and downstream consumers.
3. **Provision the candidate pool:** Start a parallel deployment and wait for every replica to load artifacts and pass readiness checks before routing production traffic. Confirm enough spare capacity for overlap; do not remove the old pool just to make room before its replacement is ready.
4. **Compare without user impact:** Where practical, shadow a privacy-approved sample to the candidate and compare outputs and operational metrics without returning candidate results to users. Avoid duplicating side-effecting tool actions; use mocks, replay-safe tools, or suppress side effects.
5. **Shift gradually:** Route a small canary cohort, then increase traffic in stages using stable assignment where possible. Monitor quality proxies, safety, errors, time-to-first-token, tail latency, throughput, token cost, and downstream failures. Define automatic pause/rollback thresholds in advance.
6. **Preserve rollback compatibility:** Keep the old pool and compatible prompts, schemas, indexes, and state available through the observation window. Use backward-compatible API changes and expand/contract database migrations rather than irreversible changes in the same cutover.
7. **Complete and clean up:** Promote only after sufficient traffic and evaluation pass. Drain old replicas gracefully, finish or explicitly cancel in-flight streams, then remove old capacity after the rollback window. Record the exact bundle and decision.

For provider-hosted models, the service may change behind an alias or have no traffic-splitting controls. Pin a revision if offered; otherwise monitor behavior with probes and avoid promising a fully controlled blue/green migration.

### Trade-offs, bottlenecks, and capacity assumptions

Blue/green deployment enables fast rollback but may temporarily require nearly two pools of serving capacity; canary saves some capacity but gives slower evidence at low traffic. Shadowing improves comparison yet adds inference cost and can distort load if duplicated requests are not accounted for. Model downloads, GPU memory, KV cache, tokenizer compatibility, and index rebuilds can be migration bottlenecks. Traffic volume, model size, and downtime/RTO targets are unspecified, so size overlap capacity and measure warm-up and cutover under realistic load before promising zero downtime.

### Concise interview answer

“I validate the complete candidate bundle offline, bring up a parallel pool, and wait for readiness before routing traffic. I shadow safely where useful, then use a canary and gradual traffic shift with quality, safety, latency, error, and cost gates. I retain the old compatible pool and use backward-compatible schema/index changes so rollback is possible. Only after the observation window do I drain the old deployment; overlap capacity and in-flight streaming behavior must be tested explicitly.”

### Revision summary

| Stage | Check |
|---|---|
| Preflight | Bundle compatibility, evaluation, load and readiness. |
| Parallel pool | Candidate is healthy before cutover. |
| Canary/shift | Guardrails pass at each traffic step. |
| Rollback | Old model and dependent artifacts remain compatible. |
| Cleanup | Drain in-flight work after the observation window. |

<br><br><br>

## What is the role of feature flags in AI deployments?

**Answer:**

### Separate deployment from exposure

A **feature flag** controls whether a capability or configuration is active for a request or cohort, independently of deploying application code. In AI systems, flags can select a model or prompt version, enable a new retrieval/reranking path, change a tool policy, or limit a feature to an internal or canary group. This supports gradual exposure, controlled experiments, and rapid disablement without rebuilding the service.

### Use flags with explicit controls

1. **Define scope and owner:** Document the flag’s purpose, owner, default, eligible cohorts, expiry/review date, and rollback behavior. Prefer a small number of meaningful flags over an ungoverned matrix of interacting switches.
2. **Choose deterministic targeting:** Assign by user, tenant, or session as appropriate, and keep assignment stable during an experiment. Protect sensitive cohorts and ensure authorization is enforced separately; a flag is not an access-control mechanism.
3. **Version the selected behavior:** Record the flag/configuration version and resolved variant with the request trace, along with model, prompt, retrieval, and policy versions. This makes unexpected behavior diagnosable and supports valid experiment analysis.
4. **Gate rollout:** Start with internal users or a small canary, compare against predefined quality, safety, availability, latency, and cost thresholds, and expand only when gates pass. Do not use live exposure as a substitute for offline safety testing.
5. **Provide a kill switch and fallback:** A high-risk feature should be disableable quickly. Define the safe behavior when disabled—such as reverting to the previous model path, returning a clear unavailable response, or routing to a non-LLM workflow. Test that fallback rather than assuming it works.
6. **Manage interactions and lifecycle:** Test important flag combinations, especially where retrieval, tools, safety controls, and model choice interact. Remove stale flags after rollout to avoid permanent complexity and accidental configuration drift.

Flags can control exposure but do not by themselves guarantee rollback: compatible artifacts, healthy fallback capacity, and data/schema reversibility are also required. For deterministic auditability, persist the resolved configuration for each request rather than relying only on the current flag service state.

### Trade-offs, bottlenecks, and capacity assumptions

Flags make rollout and emergency disablement fast, but each additional flag creates testing, observability, and configuration complexity. Dynamic flag lookup can add latency or become a dependency; use well-defined caching and fail-safe behavior consistent with risk. Small canaries limit exposure but may not provide enough traffic to detect rare regressions. Traffic volume, risk level, and flag platform are unspecified, so define cohort size and propagation-time objectives, test kill-switch behavior, and avoid assuming flag-off instantly cancels in-flight generations.

### Concise interview answer

“I use feature flags to decouple deployment from exposure: route selected cohorts to a new model, prompt, retrieval path, or capability, then expand only after quality, safety, SLO, and cost gates pass. Assignment should be stable and the resolved variant logged. I also define and test a safe fallback and kill switch. Flags are not authorization controls and do not replace versioning, evaluation, or rollback-compatible data changes; I retire them after rollout to limit complexity.”

### Revision summary

| Flag use | Operational value |
|---|---|
| Cohort/model routing | Gradual rollout and controlled experiments. |
| Kill switch | Quickly disable a problematic capability. |
| Versioned assignment | Reproduce and analyze request behavior. |
| Fallback testing | Keep service behavior safe when disabled. |
| Lifecycle management | Limit stale flags and combination complexity. |

<br><br><br>

## How do you implement logging and tracing for LLM applications?

**Answer:**

### Observe the full request path without over-collecting

**Logging** records discrete events; **tracing** connects work across components for one request or task. For an LLM application, useful observability spans the API gateway, prompt/context assembly, moderation, retrieval, reranking, model call, tool execution, post-processing, and final response. A trace should help explain latency, failures, cost, and behavior while respecting privacy and retention requirements.

### Instrumentation plan

1. **Propagate correlation context:** Assign a request/trace ID at the edge and propagate it through asynchronous jobs, retrieval, model providers, tools, and retries. Use span parent-child relationships and record attempt numbers without placing sensitive user data in identifiers.
2. **Capture stage timing and outcomes:** Record start/end time, status, retry/timeout, queue delay, time-to-first-token, inter-token or stream duration where relevant, and dependency/model endpoint. For retrieval, record counts and score ranges; for tools, record tool name, validated outcome, and duration rather than secrets or unrestricted payloads.
3. **Record behavior-version metadata:** Include model/provider revision when available, prompt/template version, retrieval/index version, tool and policy versions, decoding settings, token counts, cache outcomes, and routing/feature-flag variant. This supports regression diagnosis without requiring raw prompt retention.
4. **Separate metrics from high-cardinality traces:** Aggregate request rate, error rate, latency percentiles, token usage, cost, queue/concurrency, cache hit rate, retrieval failures, and guardrail outcomes by appropriate dimensions. Avoid user IDs, raw text, or unbounded labels in metrics.
5. **Instrument streaming and partial failures:** Capture whether generation completed, was cancelled, hit a deadline, or failed after partial output. Track downstream disconnects and tool side effects so a truncated user response is not mistaken for a successful task.
6. **Protect logged content:** Prefer metadata and structured outcomes. If prompts or outputs are required for debugging, redact or minimize sensitive fields, restrict access, encrypt storage, set short retention, and honor deletion requirements. Make sampling explicit and preserve higher fidelity only for approved, access-controlled investigations.
7. **Use alerts and review:** Alert on SLO/error-budget breaches, provider throttling, unusual token/cost growth, queue saturation, and safety incidents. Validate telemetry quality and ensure dashboards distinguish model quality signals from service health.

Provider usage reports and application traces may disagree due to tokenization, retries, caching, or billing rules. Keep the source and definition of each cost metric clear, and avoid presenting proxy metrics as ground-truth quality.

### Trade-offs, bottlenecks, and capacity assumptions

Detailed traces improve diagnosis but add storage, ingestion cost, latency overhead, and privacy risk; high-cardinality fields can overwhelm telemetry systems. Sampling reduces volume but may miss rare failures, so combine representative sampling with targeted capture for errors and incidents under approved policies. Raw content is often the most sensitive and expensive telemetry. Request volume, retention, and regulatory constraints are unspecified, so estimate event volume as requests × spans/events × retention and set explicit data minimization, access, and sampling controls.

### Concise interview answer

“I create an end-to-end trace across gateway, retrieval, model, tools, and post-processing, using a propagated request ID and spans for latency, retries, and outcomes. I record model/prompt/index/policy versions, token usage, routing, and cache metadata, while aggregating service and cost metrics separately. Streaming completion and partial failures are explicit. I avoid raw content by default; when it is necessary, I apply redaction, access controls, encryption, retention limits, and approved sampling.”

### Revision summary

| Telemetry | Examples |
|---|---|
| Traces | Stage latency, retries, dependencies, completion state. |
| Version metadata | Model, prompt, index, tool, policy, route. |
| Metrics | SLOs, tokens, cost, queueing, errors, guardrails. |
| Privacy controls | Minimize, redact, restrict, encrypt, expire. |
| Capacity planning | Event volume, cardinality, retention, sampling. |

<br><br><br>

## How do you handle PII and sensitive data in LLM inputs and outputs?

**Answer:**

### Minimize exposure throughout the data lifecycle

Personally identifiable information (PII) and other sensitive data should be handled as a data-governance and threat-modeling problem, not only as a prompt-filtering task. Map what data enters through user input, retrieved documents, conversation history, tools, logs, model-provider requests, and generated outputs. Apply the organization’s legal, contractual, and policy requirements to each path.

### Practical safeguards

1. **Collect and send only what is needed:** Minimize fields, redact or tokenize identifiers when the task can be completed without them, and avoid putting secrets, credentials, or unnecessary customer records into prompts. Keep authorization checks in application services; the model should not be trusted to enforce access.
2. **Control retrieval and conversation context:** Enforce tenant and document-level access before retrieval results are assembled. Do not reuse caches across users or tenants unless keys include the correct authorization scope. Apply retention and deletion to conversation memory, embeddings, backups, and derived indexes as well as primary records.
3. **Review provider and tool boundaries:** Understand provider retention, training, regional processing, encryption, and contractual controls before sending data. Use approved endpoints and configurations. Limit tool permissions and data returned to the model; validate requests and outputs in trusted code.
4. **Detect and transform carefully:** Use structured schemas and context-aware detection for sensitive fields, with redaction, masking, or tokenization where appropriate. Detection is imperfect, especially for free text and indirect identifiers, so do not treat a PII scanner as a guarantee that data is safe to disclose.
5. **Protect outputs:** Validate generated responses against user authorization and disclosure rules, especially when answers include retrieved or tool-provided information. Apply output scanning or human review for higher-risk uses, and provide safe refusal/escalation behavior when policy requires it.
6. **Secure observability and storage:** Prefer metadata over raw prompts and completions. Where content capture is justified, encrypt in transit and at rest, restrict role-based access, audit access, define retention/deletion, and redact before third-party telemetry. Keep secrets out of logs and error messages.
7. **Test and respond:** Use synthetic or properly governed test data, adversarial tests for cross-tenant leakage and prompt injection, and regular access/deletion audits. Define incident response for accidental disclosure, including containment, notification, and evidence handling under applicable requirements.

Privacy protections and safety controls should be applied before and after the model call and at retrieval/tool boundaries. A model-generated assurance that information is private is not a technical control.

### Trade-offs, bottlenecks, and capacity assumptions

More redaction reduces exposure but can remove context needed for useful answers; strict retention limits improve privacy but may constrain debugging and audit evidence. Detection and human review add latency and cost, and false negatives remain possible. Encryption protects stored/transmitted data but does not prevent misuse by an authorized process. Data categories, jurisdictions, providers, and retention obligations are unspecified, so involve privacy/security owners and perform a data-flow and threat assessment before selecting controls; do not assume one universal retention or consent rule.

### Concise interview answer

“I map sensitive data across input, retrieval, tools, provider calls, outputs, and logs, then minimize it at every boundary. Authorization is enforced outside the model; retrieval and caches remain tenant-scoped. I verify provider data terms, restrict tool permissions, use context-aware redaction where appropriate, and validate outputs for unauthorized disclosure. Logs are metadata-first with access, encryption, and retention controls. Because detection is imperfect, I test leakage paths and involve privacy/security stakeholders for jurisdiction- and policy-specific requirements.”

### Revision summary

| Boundary | Safeguard |
|---|---|
| Input/provider | Minimize, redact where useful, use approved processing terms. |
| Retrieval/cache | Enforce authorization and tenant isolation. |
| Tools/output | Least privilege, validation, disclosure checks. |
| Logs/storage | Metadata-first, restricted access, encryption, retention/deletion. |
| Governance | Threat modeling, testing, audits, incident response. |

<br><br><br>

## What is a gateway pattern for LLM API management?

**Answer:**

### Put a governed control plane in front of model providers

An **LLM gateway** is a service boundary through which applications call one or more model providers or self-hosted inference endpoints. Rather than each application implementing provider-specific authentication, retries, routing, observability, and policy separately, the gateway offers a consistent API and applies shared controls. It can be a dedicated product or an application-owned service; the essential pattern is centralized mediation, not a particular vendor.

### Responsibilities and request flow

1. **Authenticate and authorize:** Validate the calling application or tenant, enforce model/tool permissions and quotas, and resolve credentials from a secret manager. Do not trust a client-supplied tenant identity or expose provider keys to clients.
2. **Validate and normalize:** Enforce payload, context, and output limits; validate supported parameters; normalize provider request/response formats where a common interface is useful. Preserve provider-specific capabilities explicitly rather than silently dropping unsupported options.
3. **Apply policy and routing:** Select an approved model or deployment based on task, tenant, data residency, quality requirements, price, or availability. Apply safety and data-handling rules before forwarding; routing should not bypass authorization or policy.
4. **Protect capacity and resilience:** Apply per-tenant rate, token, concurrency, and spend limits; enforce deadlines; use bounded retries with jitter for transient failures; and use circuit breakers or approved fallbacks when a provider is unhealthy. Avoid retrying non-idempotent tool effects blindly.
5. **Observe and account:** Propagate request IDs and record model/configuration version, token usage, latency, status, retries, cache outcome, and billing metadata. Minimize sensitive content in logs and keep tenant-level usage/audit records appropriately isolated.
6. **Return a stable contract:** Map provider errors into documented application-facing categories, preserve streaming semantics, and expose actionable retry information. Keep raw provider details available to operators without leaking internal credentials or sensitive diagnostics to end users.

An LLM gateway can also centralize prompt/version references, caching, response validation, and evaluation hooks, but these should remain composable and observable. Keep business-specific orchestration in the application where centralizing it would create a hard-to-debug “god service.”

### Trade-offs, bottlenecks, and capacity assumptions

Centralization improves consistency, governance, and provider portability, but adds a network hop, operational dependency, and possible bottleneck or single point of failure. Multi-provider abstraction can obscure differences in tokenization, tool calling, structured outputs, safety behavior, and error semantics; a “universal” API may need explicit capability negotiation. High-cardinality per-tenant accounting and streaming connections can stress gateway memory and telemetry. Traffic, latency budget, provider count, and availability target are unspecified, so load-test the gateway itself, deploy it redundantly, and define a fail-safe policy that does not accidentally bypass required controls.

### Concise interview answer

“An LLM gateway is a governed mediation layer between applications and model endpoints. It centralizes authentication, tenant quotas, request validation, policy-aware routing, retries/circuit breaking, provider normalization, and usage tracing. That reduces duplicated controls and makes provider changes easier, but it adds latency and can become a bottleneck or failure dependency. I keep provider-specific behavior explicit, deploy the gateway redundantly, preserve streaming, and ensure failures do not bypass security or safety policy.”

### Revision summary

| Gateway capability | Value |
|---|---|
| Auth, policy, quotas | Consistent tenant controls and spend protection. |
| Routing/resilience | Approved model selection and bounded failure handling. |
| Normalization | Simplifies clients while exposing provider differences. |
| Observability/accounting | Traceability, usage attribution, and operations. |
| Redundant deployment | Avoid making the gateway a single point of failure. |

<br><br><br>

## How does Token Streaming work?

**Answer:**

### Return generated output incrementally

Most chat-oriented LLMs generate autoregressively: after the input is processed, the model repeatedly predicts a next token conditioned on the prompt and previously generated tokens. **Token streaming** makes newly generated output available to the caller as generation proceeds instead of waiting for the entire completion. This can reduce perceived time-to-first-response and let a user see progress, but it does not necessarily reduce the model’s total computation or completion time.

### From model token to client event

1. **Prefill:** The model processes the input prompt and builds internal attention state (commonly a key/value cache) before it can generate the first output token. Long input context can therefore dominate time-to-first-token.
2. **Decode:** The model performs repeated decode steps, typically producing one or more token IDs per step. Serving systems may batch requests and scheduling can affect when each request advances.
3. **Detokenize and serialize:** Token IDs are converted to text fragments and wrapped in a transport event. A token is not necessarily a word: it may be a word part, punctuation, whitespace, or other text unit. Some serving APIs emit batches of tokens or text deltas rather than one event per token.
4. **Transport events:** The server flushes deltas through a streaming protocol such as Server-Sent Events (SSE), WebSocket, or a provider-specific stream. The client incrementally parses events and appends content. Network buffering, proxies, and compression can delay or combine chunks, so an emitted token does not guarantee an immediate visible update.
5. **Completion and control events:** The stream may include role/tool metadata, finish reason, usage, or an explicit terminal event. It can also end early due to cancellation, timeout, provider error, or client disconnect. Consumers should distinguish normal completion from an interrupted stream.

Streaming is especially useful for interactive text generation. Tool calls and structured output require clients to interpret typed events or wait for complete validated structures; treating every delta as user-visible prose can expose malformed partial content. Moderation and safety checks also need a deliberate policy: incremental display improves responsiveness, while buffering or validating before display can reduce exposure to unsafe partial output.

### Trade-offs, bottlenecks, and capacity assumptions

Streaming reduces perceived waiting when the model emits promptly, but does not guarantee lower total latency or higher throughput. It holds connections open longer, increases connection-management and proxy requirements, and makes retries harder after partial output has been delivered. Time-to-first-token depends on queueing, prompt prefill, network setup, and provider behavior; inter-token delay depends on decode and scheduling. Token granularity and buffering differ across APIs, so clients must not assume one event equals one word or model step. Traffic, output lengths, and protocol are unspecified; measure first-token and inter-token latency separately and test disconnects and buffering through the production network path.

### Concise interview answer

“In autoregressive generation, the model processes the prompt, then repeatedly predicts output tokens. A streaming server detokenizes and sends deltas as they become available, commonly over SSE or WebSocket, so users see progress before completion. A token is not necessarily a word, and APIs may batch deltas. Streaming improves perceived latency, not necessarily total compute time, and requires handling buffering, cancellation, partial output, finish/error events, and safety checks.”

### Revision summary

| Stage | What happens |
|---|---|
| Prefill | Process prompt and prepare generation state. |
| Decode | Generate token IDs incrementally. |
| Serialization/transport | Send text or typed deltas through a stream. |
| Client handling | Parse, display, cancel, and detect terminal/error states. |
| Key metrics | Time-to-first-token, inter-token delay, total latency. |

<br><br><br>

## How do you implement streaming responses for real-time AI applications?

**Answer:**

### Design the complete stream lifecycle

Implementing a streaming response means more than turning on a provider option: the application must carry incremental events from model to client, preserve ordering, enforce deadlines and policy, and clean up work when either side disconnects. First decide which content can safely be displayed incrementally and which must be buffered until it is complete or validated.

### Implementation steps

1. **Choose and document an event contract:** Use an appropriate transport—often SSE for one-way server-to-browser events or WebSocket when bidirectional interaction is required. Define typed events for content deltas, tool/status updates, usage where available, completion, cancellation, and errors. Include a request ID and sequence/order semantics where useful.
2. **Connect through the full path:** Enable streaming in the model client and configure the application server, reverse proxy, load balancer, and client to flush chunks rather than buffer them. Test with the production-like path; proxy timeouts and buffering frequently defeat application-level streaming.
3. **Handle incremental data safely:** Parse provider chunks into the stable public event format. Do not assume chunk boundaries align with tokens, words, JSON fields, or Unicode characters. For constrained JSON or other structured output, either use incremental parsing with a clearly provisional UI or buffer and validate the complete result before treating it as final.
4. **Enforce safety and authorization:** Apply input checks before dispatch and define how output moderation works during generation. Avoid exposing unvalidated tool calls, private retrieved context, or partial content that violates the product’s safety policy. Check authorization at retrieval/tool boundaries, not only in the UI.
5. **Support cancellation and deadlines:** Detect client disconnects and propagate cancellation to the model/provider and downstream tools when supported. Set an overall deadline and bounded limits for generation; close upstream streams and release concurrency slots on completion, timeout, or cancellation.
6. **Handle errors after partial output:** Once content has been delivered, a transparent retry can duplicate or contradict it. Emit an explicit terminal error/cancel event, preserve partial-output status, and offer a deliberate resume/restart UX only if the backend supports safe continuation.
7. **Measure and test:** Track time-to-first-byte/token, inter-event gaps, total generation time, disconnects, active streams, cancellation propagation, errors, and completion reason. Test slow clients, network interruptions, proxy idle timeouts, bursts, and long generations.

Protect against resource exhaustion: a slow client can hold a connection and model capacity for a long time. Use per-tenant concurrency limits, bounded queues, idle/write timeouts, and backpressure. For background tasks or unreliable clients, persist task state and let clients reconnect by request ID rather than keeping an unbounded in-memory stream alive.

### Trade-offs, bottlenecks, and capacity assumptions

Streaming improves perceived responsiveness but increases the duration and number of live connections; each active request may retain server, provider, and KV-cache resources. Buffering improves moderation or schema validation but delays first display and may require storing output. Backpressure protects memory but can slow generation or force cancellation. Capacity depends on concurrent streams, average generation duration, output length, provider limits, and connection infrastructure; without these workload figures, use load tests to establish safe concurrency and test graceful rejection rather than assuming ordinary HTTP request limits are sufficient.

### Concise interview answer

“I define a typed streaming contract, connect provider deltas through an unbuffered SSE/WebSocket path, and explicitly handle completion, errors, and cancellation. The client parses arbitrary chunk boundaries; structured or sensitive output may need buffering or incremental validation. I propagate disconnects and deadlines upstream, limit concurrent streams, and measure first-token and inter-event latency separately. Partial output changes retry semantics, so after a stream has started I report interruption explicitly instead of blindly replaying the request.”

### Revision summary

| Concern | Implementation |
|---|---|
| Protocol | Typed events, ordering, completion/error semantics. |
| Network path | Flush chunks; test proxy and load-balancer behavior. |
| Safety/structure | Validate or buffer content according to risk. |
| Lifecycle | Deadline, cancellation propagation, cleanup, backpressure. |
| Capacity | Bound active streams, queues, and per-tenant usage. |

<br><br><br>

## How does vLLM work?

**Answer:**

### High-throughput serving for autoregressive models

**vLLM** is an open-source inference and serving engine for large language models. Its best-known design contribution is **PagedAttention**, which manages the attention key/value (KV) cache in fixed-size blocks rather than requiring each request to reserve one large, contiguous cache region. As requests have different prompt and generation lengths, this can reduce memory fragmentation and improve the number of sequences that fit in accelerator memory.

### Serving path and main ideas

1. **Request admission:** The serving layer accepts prompts and generation parameters, applies configured limits, and places work in a scheduler.
2. **Prompt processing and cache allocation:** During prefill, the engine processes prompt tokens and allocates KV-cache blocks as needed. Block tables map a sequence’s logical positions to physical cache blocks; sequences need not own a contiguous region.
3. **Iterative decode scheduling:** The scheduler batches active sequences and advances them through decode steps. With continuous batching, completed requests can leave and new requests can join without waiting for a fixed batch to finish, improving utilization under variable request lengths.
4. **Memory-aware generation:** As output grows, additional KV blocks are allocated; completed or cancelled sequences release their blocks. The engine can use features such as prefix sharing/caching or constrained decoding when supported and configured, but behavior depends on version, model, and serving setup.
5. **API and deployment:** vLLM commonly exposes an OpenAI-compatible serving interface, but compatibility is not identical for every provider-specific option. Operators still configure model/tokenizer, parallelism, hardware, quantization or cache settings, limits, and health/metrics endpoints for their deployment.

Paged KV management addresses an important serving constraint: attention cache memory grows with active sequences, context length, model architecture, and data precision. It does not make model weights or compute disappear, and it does not make arbitrary workloads infinitely scalable. Long contexts and high concurrency can still exhaust memory or reduce throughput.

### Trade-offs, bottlenecks, and capacity assumptions

Paged allocation and dynamic batching can improve memory utilization and throughput, but benefits depend on workload shape, model support, hardware, and configuration. Scheduling to maximize throughput can increase queueing or tail latency; high-priority low-latency traffic may need separate pools or admission policies. Performance is constrained by model compute, KV-cache capacity/bandwidth, memory bandwidth, interconnect, and request-length distribution. Deployment also entails GPU management, model loading, upgrades, and compatibility testing. No model, hardware, arrival rate, or SLO is specified, so benchmark representative prompt/output lengths and concurrency on the target stack instead of assuming a fixed speedup.

### Concise interview answer

“vLLM is an LLM inference and serving engine designed for efficient concurrent generation. PagedAttention stores sequence KV caches in fixed-size blocks mapped through per-sequence tables, reducing fragmentation and enabling flexible allocation. Its scheduler can continuously batch active requests as others finish, improving utilization. It still must fit weights and active KV state in memory, and throughput/latency depend on workload, hardware, and configuration, so I benchmark the target model and SLO.”

### Revision summary

| Mechanism | Role |
|---|---|
| PagedAttention | Block-based KV-cache management and reduced fragmentation. |
| Continuous batching | Admit/join work as sequences progress or complete. |
| KV-cache allocation | Scale memory with active sequence/context demands. |
| Serving interface | Expose generation APIs and operational controls. |
| Benchmarking | Verify workload-specific throughput, latency, and memory. |

<br><br><br>

## How does SGLang work?

**Answer:**

### A runtime and language for structured LLM programs

**SGLang** is an open-source system for expressing and serving structured LLM programs. It combines a programming interface for composing operations—such as prompts, generation, choices, and control flow—with a runtime intended to execute those programs efficiently. It is useful when an application has structured multi-step generation or repeated shared context, not only for a single plain-text completion.

### Core execution ideas

1. **Express the program:** An application defines prompt construction and generation steps, including constraints or branches where supported. The program can describe a sequence of model interactions rather than forcing each step to be manually dispatched by application code.
2. **Plan and execute:** The runtime coordinates those operations with the model backend, schedules generation, and handles outputs needed by subsequent steps. Exact APIs and supported primitives evolve, so production code should follow the installed release’s documented interface.
3. **Reuse shared prefixes:** SGLang’s RadixAttention approach organizes reusable KV-cache prefixes in a radix-tree-like structure. When requests share a prefix, the runtime may reuse cached attention state rather than recomputing it, subject to cache residency, matching, and runtime constraints.
4. **Optimize structured workloads:** The system can combine runtime scheduling and caching techniques for repeated or branching LLM programs. Benefits are largest when workloads actually share reusable prefixes or have supported structured patterns; arbitrary prompts do not automatically share cache.
5. **Serve and observe:** Deploy the runtime with compatible model/hardware configuration, limits, and monitoring. Validate program correctness and cache behavior with representative traces; do not infer production semantics solely from a benchmark or API-compatible surface.

Radix-based prefix reuse is distinct from general response caching: it reuses model computation state for matching prefixes, not necessarily a previously generated answer. It also must respect tenant isolation and not allow one user’s private context to be reused or exposed to another.

### Trade-offs, bottlenecks, and capacity assumptions

Structured programming can simplify complex generation workflows and prefix reuse can reduce repeated prefill work, but introducing a specialized runtime adds concepts, deployment dependencies, and debugging complexity. Cache memory is finite; retaining useful prefixes competes with active KV state, and cache hits depend on exact compatible prefixes and workload repetition. For diverse one-off prompts, gains may be small. Model, prefix repetition, context length, and concurrency are unspecified, so profile cache hit rate, prefill savings, memory pressure, and tail latency under the real request distribution.

### Concise interview answer

“SGLang provides a way to express structured LLM programs and a serving runtime to execute them. A notable optimization is RadixAttention, which can organize and reuse KV-cache state for shared prompt prefixes, avoiding some repeated prefill computation. That is computation-state reuse, not simply returning a cached completion. Its benefit depends on prefix reuse, cache capacity, and workload; I would validate correctness, tenant isolation, hit rate, and latency on representative traffic.”

### Revision summary

| Concept | Meaning |
|---|---|
| Structured LLM program | Compose generation and control flow as a program. |
| Runtime | Schedule and execute supported operations. |
| RadixAttention | Reuse KV state for compatible shared prefixes. |
| Cache constraint | Finite memory and workload-dependent hit rate. |
| Validation | Test semantics, isolation, memory, and latency. |

<br><br><br>

## How does TensorRT-LLM work?

**Answer:**

### Optimize inference for NVIDIA hardware

**TensorRT-LLM** is NVIDIA’s open-source library and runtime for building and running optimized large-language-model inference on NVIDIA GPUs. It combines model-specific implementations and graph/runtime optimizations with lower-level NVIDIA capabilities to improve latency, throughput, or memory use for supported configurations. It is an inference stack, not a model-training framework or a guarantee that every model will run faster without engineering effort.

### Typical workflow

1. **Select a supported model and configuration:** Check the TensorRT-LLM release’s model, GPU, precision, and feature support. Compatibility can vary by version; confirm architecture, tokenizer, attention features, and serving needs.
2. **Prepare the model:** Load supported weights or convert/build an optimized engine when required. Configure precision or quantization, tensor/pipeline parallelism, maximum sequence and batch limits, and memory settings. Engine building may be hardware- and configuration-specific.
3. **Run optimized execution:** The runtime uses GPU-optimized kernels and execution strategies for prefill and autoregressive decode. Depending on the model and release, features may include fused operations, in-flight batching, paged KV-cache management, quantization, and multi-GPU execution.
4. **Serve requests:** Deploy through a compatible serving interface or integrate the runtime into an application. Configure admission limits, streaming, health checks, metrics, and failure handling; an optimized engine still needs production orchestration around it.
5. **Benchmark and validate:** Compare task quality, output correctness, latency percentiles, throughput, accelerator utilization, memory, and cost against the existing stack using representative prompt/output lengths and concurrency. Validate numerical behavior after precision changes.

Treat engine artifacts and serving configuration as versioned release dependencies. Rebuild and revalidate when changing the model, software/runtime version, GPU architecture, precision, or relevant engine parameters rather than assuming an old optimized artifact is portable.

### Trade-offs, bottlenecks, and capacity assumptions

Hardware-specific optimization can deliver strong performance on supported NVIDIA systems, but can increase engine build time, deployment complexity, and coupling to CUDA/GPU generations and software versions. Conversion or kernel support may lag new architectures or model features. Quantization can reduce memory and improve throughput but may alter quality; multi-GPU parallelism can be limited by interconnect and synchronization. Model size, GPU type, request distribution, and SLO are unspecified, so compare a validated TensorRT-LLM build with alternatives on the exact target hardware, including engine startup and upgrade costs.

### Concise interview answer

“TensorRT-LLM is NVIDIA’s inference stack for optimizing LLM execution on NVIDIA GPUs. A typical deployment selects a supported model, prepares or builds an engine with chosen precision and parallelism, then serves it using GPU-optimized kernels and scheduling features. I validate exact model/GPU/version support and benchmark quality, throughput, tail latency, and memory on representative traffic. The trade-off is potentially high hardware-specific performance versus engine-build, compatibility, and operational complexity.”

### Revision summary

| Area | Key point |
|---|---|
| Purpose | Optimized LLM inference on NVIDIA GPUs. |
| Preparation | Supported model, engine/configuration, precision, parallelism. |
| Runtime | GPU kernels and supported scheduling/cache features. |
| Deployment | Version artifacts and serving layer separately. |
| Decision | Benchmark target hardware and workload; verify compatibility. |

<br><br><br>

## How does llama.cpp run LLMs on everyday hardware?

**Answer:**

### Portable inference beyond data-center GPUs

**llama.cpp** is an open-source C/C++ inference project focused on running LLMs across a broad range of hardware, including CPUs and supported GPU backends. It is associated with the GGUF model-file format, which packages model weights and metadata for this ecosystem. Quantized model variants can make local inference practical on machines with limited memory, though supported architectures, formats, and acceleration depend on the project build and backend.

### How local inference is typically set up

1. **Choose a compatible artifact:** Obtain a model in a supported format, commonly GGUF, with a quantization level suited to available memory and quality requirements. Ensure the source and license permit the intended use.
2. **Load and map weights:** The runtime loads model tensors and metadata, often using memory mapping where available, and initializes a CPU or supported accelerator backend. Quantized weights use fewer bits than full-precision weights, trading some numerical fidelity for a smaller memory footprint.
3. **Process the prompt and decode:** The runtime performs prefill and autoregressive token generation, maintaining KV-cache state for the active context. CPU thread counts, GPU layer offload, context/cache configuration, and batch settings affect performance.
4. **Use a local interface:** The project offers command-line and server-style ways to run models; wrappers and front ends may provide additional APIs. Keep track of which component owns model loading, request handling, and security rather than treating all tooling as the same product.
5. **Measure on the actual device:** Test prompt processing and token generation separately, along with memory use, quality, concurrency, and thermal/power behavior where relevant. A configuration that fits the weights may still run out of memory once KV cache and runtime overhead are included.

llama.cpp makes local and edge experimentation accessible, but local execution does not automatically make model use private or secure: logs, downloaded artifacts, extensions, and network-enabled server interfaces still require suitable controls.

### Trade-offs, bottlenecks, and capacity assumptions

CPU inference can avoid accelerator dependencies but may have lower throughput and higher latency; GPU offload can improve speed while consuming device memory and depending on backend support. More aggressive quantization reduces weight memory but can reduce task quality, and long context increases KV-cache memory even when weights fit. Local deployment trades centralized capacity and updates for offline capability and control, while placing hardware variability and patching responsibility on the operator. Device, model, context, concurrency, and latency target are unspecified, so benchmark the intended hardware and leave memory headroom for cache and runtime overhead.

### Concise interview answer

“llama.cpp is a portable C/C++ inference runtime that runs supported LLMs on CPUs and several accelerator backends. It commonly uses GGUF artifacts, including quantized weights, to fit models on constrained or everyday hardware. It loads the model, processes prompt tokens, then decodes incrementally while using KV-cache memory; CPU threads and GPU offload shape performance. The benefit is portability and local control, but latency, quality, and context capacity depend on quantization and device resources.”

### Revision summary

| Component | Role |
|---|---|
| GGUF ecosystem | Model files and metadata used by the runtime. |
| Quantization | Reduce weight footprint with potential quality trade-offs. |
| CPU/GPU backends | Run inference on available supported hardware. |
| KV cache | Additional memory needed for active context and generation. |
| Validation | Measure quality, memory, and speed on target devices. |

<br><br><br>

## How does Ollama work?

**Answer:**

### A local model-management and serving experience

**Ollama** is a tool for downloading/managing supported model artifacts and running them locally behind a convenient command-line and API experience. It commonly uses llama.cpp-related model/runtime support for many models and quantized formats, but the exact backend, supported models, and behavior depend on Ollama version and platform. It is best understood as an application/runtime and model-management layer, not as the name of a model architecture.

### Typical request path

1. **Select and obtain a model:** The user pulls or selects a supported model package, often described through a model manifest and associated weight layers. Verify the artifact, source, and license; model names or tags may refer to different sizes or quantizations.
2. **Load for inference:** Ollama resolves the package and starts a local model process/runtime as needed. Model loading consumes memory and can make the first request slower; loaded-model residency and unloading behavior depend on configuration and version.
3. **Send a request:** A local API or CLI accepts prompt/messages and generation options. The serving layer formats the request, invokes the runtime, and can stream generated output back to the client.
4. **Manage lifecycle and resources:** The service loads and unloads models and uses available CPU/GPU resources. Concurrent requests, context length, model size, and configured parallelism determine memory pressure and throughput.
5. **Integrate safely:** Applications can use the local API, but if the service is exposed beyond the host, configure network access, authentication or an authenticated reverse proxy, request limits, and logging/privacy protections. “Local” does not mean automatically isolated from other processes or users.

The convenience layer does not remove the need to understand the underlying model’s context limit, quantization, system requirements, quality, and license. For production multi-user workloads, benchmark the exact Ollama version and configuration against a serving engine designed for the required throughput and operational controls.

### Trade-offs, bottlenecks, and capacity assumptions

Ollama lowers the setup friction of local inference and model management, but its convenience may provide fewer low-level tuning or fleet-management options than a specialized serving stack. First-load time, model residency, GPU compatibility, and parallel request behavior can be limiting. Disk storage for multiple model variants and memory for weights plus active KV caches must be budgeted separately. Hardware, model size, and concurrency are unspecified, so test startup, warm/cold latency, concurrent sessions, and memory on target machines before using it as a production service.

### Concise interview answer

“Ollama provides a convenient way to obtain, manage, and serve supported LLMs locally through CLI and API interfaces. It resolves a model package, loads the model into an available local runtime, and returns generated output, often with streaming support. It simplifies local experimentation, but model loading, backend support, quantization, concurrency, and memory still determine performance. I secure the API if exposed over a network and benchmark the exact version and device before relying on it for production.”

### Revision summary

| Layer | Responsibility |
|---|---|
| Model packaging | Select and manage model artifacts/tags. |
| Local runtime | Load model and execute inference. |
| API/CLI | Provide application and interactive interfaces. |
| Resource limits | Manage model residency, KV cache, concurrency. |
| Operations | Verify licenses, security, version, and target-device behavior. |

<br><br><br>

## When would you choose vLLM vs SGLang vs TensorRT-LLM?

**Answer:**

### Match the serving stack to workload and operating constraints

These are all LLM inference/serving options, but their strengths and trade-offs differ by release, model, hardware, and workload. Choose based on measured behavior and operational fit—not a universal ranking or a single headline throughput result.

### A practical comparison

| Option | Consider it when | Validate carefully |
|---|---|---|
| **vLLM** | You need a general-purpose high-throughput serving engine, dynamic/continuous batching, broad model serving, and a familiar API-oriented deployment path. PagedAttention is designed to manage KV-cache memory efficiently. | Confirm architecture and feature support in the chosen version, latency under your concurrency, memory behavior, and compatibility with required API features. |
| **SGLang** | Your application has structured multi-step LLM programs, repeated shared prefixes, or branching patterns where its runtime and prefix/KV-cache reuse may help. | Verify that your workload actually has cacheable prefixes and supported program structure; measure cache hit rate, memory impact, debuggability, and isolation. |
| **TensorRT-LLM** | You run on NVIDIA GPUs and can invest in a hardware-optimized, versioned engine/build workflow for a supported model and deployment. | Check exact GPU/model/version support, engine build and upgrade effort, precision/quality, and portability across hardware/software changes. |

### Decision process

1. **Set requirements:** Define quality, first-token and end-to-end latency, throughput, availability, context/output lengths, streaming, structured output, and deployment constraints.
2. **Check capability fit:** Confirm model architecture, quantization, hardware, tool/API behavior, parallelism, and observability needs are supported by the exact versions under consideration.
3. **Benchmark fairly:** Use the same model revision, prompts, token distributions, concurrency, hardware budget, and measurement method. Report p50/p95/p99 latency, throughput, accelerator memory/utilization, errors, and task quality.
4. **Test production operations:** Measure startup/warm-up, rolling upgrades, autoscaling, queue behavior, failure recovery, model artifact management, and operator expertise required. Include cost of engine building or idle capacity.
5. **Choose and revisit:** Select the simplest stack that meets SLOs with headroom; re-benchmark after model, runtime, or hardware changes. It may be reasonable to run different engines for distinct workload classes, provided routing and operations remain manageable.

Do not treat API compatibility as behavioral equivalence: tokenization, tool calling, constrained decoding, sampling, and streaming/error semantics can differ. Preserve a small integration suite for the application’s actual contract.

### Trade-offs, bottlenecks, and capacity assumptions

vLLM offers a broadly useful serving path, SGLang can benefit structured/shared-prefix workloads, and TensorRT-LLM can exploit supported NVIDIA-specific optimizations; these are tendencies, not guaranteed performance outcomes. Specialization may improve efficiency but increases coupling, build/configuration effort, or debugging burden. Bottlenecks can be model compute, KV-cache memory, prefill/decode mix, interconnect, scheduler, or queueing. With no model, hardware, workload, or SLO specified, conduct a representative head-to-head benchmark and size for peak concurrency plus failure/rollout headroom rather than selecting on generic rankings.

### Concise interview answer

“I choose by workload and operational constraints. I would start with vLLM for a general high-throughput serving path, evaluate SGLang when structured programs or shared prefixes can benefit from its runtime/cache, and consider TensorRT-LLM for supported NVIDIA deployments where engine optimization is worth the coupling. I verify exact model/version support, then benchmark quality, p99 latency, throughput, memory, and upgrade operations on identical target hardware. There is no universal winner.”

### Revision summary

| Decision factor | Why it matters |
|---|---|
| Workload shape | Prefix reuse, context lengths, concurrency, structured steps. |
| Hardware/support | Model/GPU/runtime compatibility. |
| Measured SLOs | Quality, p99, throughput, memory, cost. |
| Operations | Build, upgrade, debug, autoscale, recover. |
| Selection rule | Simplest validated stack that meets targets with headroom. |

<br><br><br>

## What are the key SLAs and metrics for production AI systems (latency, throughput, availability)?

**Answer:**

### Define user-visible service objectives

An **SLA** is a formal service commitment, often with remedies or contractual terms; an **SLO** is an internal or customer-facing reliability target, and **SLIs** are the measurements used to assess it. Production AI needs both conventional service reliability and AI-specific outcome measures. A service can meet HTTP availability while returning unusable, unsafe, or ungrounded answers, so define objectives around the complete user task where possible.

### Core SLIs and how to measure them

1. **Latency:** Measure end-to-end request latency and key stages. For streamed generation, separately track time-to-first-token/byte, inter-token or inter-event delay, and total completion time. Report percentiles (especially p95/p99), not only averages, and segment by model, route, task, and input/output length.
2. **Throughput and saturation:** Track completed requests and tokens per second, active sequences, queue depth/wait, concurrency, accelerator utilization, and rejection rates. Distinguish offered load from successfully completed work so overload does not look like improved efficiency.
3. **Availability and errors:** Define successful response semantics, measure successful task/API requests over eligible requests, and classify provider errors, timeouts, throttles, cancellations, invalid outputs, and dependency failures. Track error-budget consumption and recovery time.
4. **Quality and safety:** Use versioned offline and production evaluations for task success, groundedness or citation validity where applicable, structured-output validity, refusal/policy outcomes, human correction, and incident rates. Online proxies are not substitutes for well-designed quality evaluation.
5. **Cost and efficiency:** Measure cost per request and per successful task, input/output token usage, cache-hit effectiveness, retry/fallback volume, and compute utilization. Attribute charges consistently across provider and infrastructure components.
6. **Fairness and data dimensions:** Examine important product cohorts, languages, task types, tenants, and risk groups where lawful and appropriate. Establish privacy-aware aggregation so metrics do not expose raw personal content.
7. **Set objective windows and alerts:** Choose measurement windows, exclusions, and thresholds based on user expectations and business risk. Alert on actionable SLO burn or severe safety/availability conditions, not every noisy metric fluctuation.

SLOs should distinguish interactive and batch workloads, and normal completion from a safe refusal or explicit fallback. In an LLM system, a response can be technically successful but semantically wrong; combine operational SLIs with evaluation and human feedback, and state clearly which metrics are contractual versus diagnostic.

### Trade-offs, bottlenecks, and capacity assumptions

Tighter latency SLOs may require reserved capacity, smaller models, or shorter contexts, increasing cost or reducing quality. Percentiles expose tail behavior but need enough samples and careful cohorting; a global average can hide a slow model/tenant. Quality metrics are slower and noisier than infrastructure metrics, while human review adds cost and delay. Request rate, token distributions, risk tolerance, and user expectations are unspecified, so baseline the workload, choose objectives per task class, and capacity-plan using peak load, queueing, failure headroom, and error-budget policy rather than borrowing a generic SLA percentage.

### Concise interview answer

“I define SLIs and SLOs for end-to-end task success, latency, throughput, availability, safety/quality, and cost. For streaming I separate time-to-first-token, inter-token delay, and total time; I use p95/p99 and segment by model and task. I measure offered versus completed traffic, queues and saturation, and classify provider failures. Because an HTTP 200 can still be a bad answer, operational SLOs are paired with versioned evaluations and privacy-aware quality signals. Targets must come from user needs and measured capacity.”

### Revision summary

| Dimension | Example signals |
|---|---|
| Latency | End-to-end p95/p99, first-token, inter-token. |
| Throughput | Requests/tokens completed, concurrency, queueing. |
| Availability | Successful task/API rate, errors, recovery, error budget. |
| AI quality/safety | Task evaluations, grounding, validity, policy outcomes. |
| Economics | Cost per successful task, tokens, retries, utilization. |

<br><br><br>

## Cloud vs on-device Model Deployment for AI applications.

**Answer:**

### Choose where inference runs based on product and data constraints

Cloud deployment sends requests to remotely operated model endpoints, which may be a managed provider or infrastructure the organization operates. **On-device deployment** runs inference on a user’s phone, laptop, embedded system, or other local hardware. The choice affects privacy, connectivity, latency, model capability, update control, and who owns operations; it is not simply “secure local” versus “insecure cloud.”

### Compare the operational dimensions

| Dimension | Cloud | On-device |
|---|---|---|
| Model capacity | Can serve large models and scale accelerator pools, subject to quota and cost. | Limited by device memory, compute, battery, and thermal envelope; typically favors smaller or quantized models. |
| Connectivity/latency | Requires network round trips and can be affected by regional routing, congestion, and provider availability. | Can respond offline and avoid network round trips, though local inference may be slower on constrained devices. |
| Data handling | Inputs leave the device unless transformed; provider terms, residency, retention, and access controls matter. | Raw inputs can remain local, but telemetry, backups, app permissions, and compromised devices still create exposure. |
| Cost | Usage-based API charges or fixed cloud capacity and operations. | No per-call cloud inference charge, but hardware, battery, distribution, support, and model-update costs remain. |
| Updates/consistency | Central updates simplify rollout and version control, but provider behavior may change. | Updates are staged across devices; version fragmentation and offline clients complicate support. |
| Reliability | Can use centralized redundancy and monitoring, but depends on network/provider. | Works without service connectivity, but device resources and local app lifecycle constrain availability. |
| Governance | Easier centralized telemetry and policy enforcement, with privacy obligations. | Less centralized visibility; policy and model versions must be managed across a device fleet. |

### A practical selection process

1. Define latency, offline, privacy, residency, quality, and availability requirements.
2. Benchmark candidate model quality and resource usage on actual target devices, including cold start, memory, battery, and thermal behavior.
3. Compare total cost: cloud tokens/accelerators and operations versus on-device engineering, distribution, support, and upgrade burden.
4. Decide which data can leave the device. If using cloud inference, minimize or transform sensitive fields and apply authorization and retention controls.
5. Plan model lifecycle and fallback: how versions are rolled out, monitored, rolled back, and handled when the device is offline or unsupported.
6. Consider a hybrid architecture: local model for offline/private or low-latency tasks, cloud model for complex tasks, with explicit user/data policy and consistent evaluation.

### Trade-offs, bottlenecks, and capacity assumptions

Cloud provides more elastic compute and often stronger model capability but introduces network latency, provider dependency, data-transfer risk, and recurring usage cost. On-device inference improves offline availability and can reduce raw-data transfer, but has heterogeneous hardware, constrained memory/battery, and slower fleet updates. Hybrid routing can balance these needs but creates duplicated paths and consistency/testing complexity. Device distribution, model size, traffic, data sensitivity, and SLOs are unspecified, so benchmark representative devices and calculate total lifecycle cost rather than comparing inference price alone.

### Concise interview answer

“I choose cloud versus on-device based on capability, latency/offline requirements, privacy, cost, and operational control. Cloud supports larger models and centralized scaling but depends on connectivity and data-provider governance. On-device can keep data local and work offline, but is constrained by device memory, compute, battery, and fragmented updates. A hybrid design is often useful: handle suitable tasks locally and escalate only when allowed. I benchmark real devices and include lifecycle and fleet-management costs.”

### Revision summary

| Decision factor | Cloud tendency | On-device tendency |
|---|---|---|
| Model scale | Larger and centrally managed. | Smaller, compressed, device constrained. |
| Connectivity | Network-dependent. | Can work offline. |
| Data path | Requires provider/cloud governance. | Can keep raw input local, but not automatically secure. |
| Operations | Central fleet. | Device/version fragmentation. |
| Best practice | Decide from measured product constraints; consider hybrid. |

<br><br><br>

## How do you implement fallback strategies when the primary model is unavailable or rate-limited?

**Answer:**

### Preserve a useful and safe service during dependency failure

A **fallback strategy** defines what the application does when its preferred model cannot accept or complete a request—for example, because of rate limits, timeouts, regional outages, or unhealthy responses. The goal is not to blindly send every request to another model; it is to preserve the required user experience and policy while controlling retries, cost, and semantic changes.

### Build a deliberate fallback path

1. **Classify failure and retryability:** Distinguish transient network/server failures, explicit rate limits, invalid requests, authentication/configuration errors, and safety refusals. Retry only transient conditions; a refusal or malformed request is not repaired by repeating the same call.
2. **Bound retries:** Use a small retry budget with exponential backoff and jitter, honor provider retry timing where available, and enforce an overall deadline. Avoid synchronized retries that amplify provider recovery load.
3. **Use circuit breaking and health signals:** Stop sending traffic to an endpoint after a defined failure threshold, probe recovery cautiously, and prevent one unhealthy dependency from consuming all application workers.
4. **Select an approved alternative:** Route to a secondary model only if its data terms, region, capabilities, quality, and safety profile are acceptable for that request. Maintain task-specific model evaluations and account for differences in tokenization, tools, structured output, and refusal behavior.
5. **Gracefully degrade when no model is suitable:** Offer a cached answer only when it is authorized and fresh; use deterministic retrieval/rules for supported tasks; queue a background job; or return a clear temporary-unavailable response. Do not invent a successful answer or bypass required checks to mask an outage.
6. **Handle partial streams and side effects:** Once output has been delivered, a retry may duplicate or contradict it. Mark partial completion explicitly. For tool execution, use idempotency keys or compensation and do not replay side effects without checking whether they already occurred.
7. **Observe and test:** Track primary failure causes, fallback rate, fallback quality, latency, cost, provider throttling, and circuit state. Exercise provider outages, quota exhaustion, delayed responses, and recovery in resilience tests.

Define whether fallback is transparent or user-visible. If the alternate model materially changes capability or data handling, communicate that where appropriate and record the selected model/version for audit and troubleshooting.

### Trade-offs, bottlenecks, and capacity assumptions

Retries can recover transient errors but increase latency and load; aggressive failover can overload the secondary provider during correlated outages. A fallback model may be cheaper or more available but have weaker quality, different policy behavior, or incompatible output formats. Keeping warm secondary capacity improves recovery time but costs money; cold capacity risks slow start and quota exhaustion. Traffic, provider quotas, acceptable quality loss, and recovery objectives are unspecified, so reserve/test secondary capacity and define explicit failure budgets and safe degraded responses.

### Concise interview answer

“I classify failures, retry only transient errors with bounded backoff and deadlines, and use a circuit breaker to stop traffic to an unhealthy provider. A secondary model is used only if it meets the request’s data, capability, quality, and safety requirements; otherwise I degrade explicitly, for example by queueing or returning a clear unavailable response. I account for partial streams and tool side effects, then monitor fallback rate and quality. Failover capacity must be tested so it does not create a retry storm or overload.”

### Revision summary

| Mechanism | Failure it addresses |
|---|---|
| Bounded retry/backoff | Transient errors and rate limits. |
| Circuit breaker | Persistent unhealthy endpoint. |
| Approved alternate | Primary outage with compatible task/data policy. |
| Graceful degradation | No safe or available model path. |
| Resilience tests | Failover capacity, recovery, partial work, side effects. |

<br><br><br>

## How do you implement structured output from LLMs reliably in production?

**Answer:**

### Treat model output as untrusted input

Structured output asks a model to return data in a machine-readable shape, often JSON matching a schema. A prompt that says “return valid JSON” is not a reliability guarantee: output may be malformed, incomplete, semantically invalid, truncated, or inconsistent with the application’s business rules. Validate and handle it as you would any external input.

### A robust production pipeline

1. **Define a narrow schema:** Specify required fields, types, enums, bounds, nullability, and cross-field invariants. Use the smallest schema that serves the consumer; avoid ambiguous optional fields and undocumented coercions.
2. **Use constrained generation when supported:** Prefer provider/model features such as schema-constrained or grammar-constrained decoding when they meet the needed schema and model compatibility. This can improve syntactic conformance but does not prove factual correctness or business validity.
3. **Keep a validated fallback path:** If constrained generation is unavailable, instruct the model clearly and parse strictly. Do not extract arbitrary substrings or silently repair content into a success-shaped response without validation.
4. **Validate in trusted application code:** Parse the complete output, validate against a schema, then apply semantic checks such as authorized identifiers, numeric limits, and consistency with source data. Reject unexpected fields or handle them under an explicit compatibility policy.
5. **Handle incomplete and unsafe results:** Detect truncation, finish reason, refusal, and tool-call states. Do not treat partial streamed JSON as final; buffer until completion or use a careful incremental parser for provisional display.
6. **Bound recovery:** On parse/schema failure, retry or request a repair at most a small number of times, preserving the original failure and respecting deadlines/cost limits. A repair prompt can introduce new errors and must pass the same validator. If recovery fails, return a typed error or safe alternate flow.
7. **Version, monitor, and test:** Version schemas with prompts/models and maintain backward-compatible consumers. Log validation categories and rates without unnecessary raw sensitive payloads. Test valid, invalid, missing, extra, adversarial, oversized, and truncated outputs across model updates.

When structured output triggers actions—payments, access changes, or tool calls—validate authorization and business rules independently and use idempotency/transaction controls. Schema validity alone does not make an action safe.

### Trade-offs, bottlenecks, and capacity assumptions

Constrained decoding can improve format adherence but may restrict supported schemas, increase decoding overhead, or behave differently across providers. Strict validation prevents bad data from propagating but may increase retries and user-visible failures. Repair retries improve some recoverable cases but add latency and cost and can conceal a weak prompt/schema if not monitored. Schema complexity, output size, and model support are unspecified, so test exact constraints and establish parse/semantic-validity SLOs with bounded recovery budgets.

### Concise interview answer

“I treat generated structured data as untrusted. I define a narrow versioned schema, use constrained decoding where supported, parse the complete response, and validate both schema and business semantics in trusted code. I detect truncation/refusal, bound any repair retries, and return a typed failure rather than silently accepting malformed output. For action-taking outputs, authorization and business rules are checked independently; schema-valid JSON is not inherently safe.”

### Revision summary

| Layer | Guarantee |
|---|---|
| Schema | Defines shape, types, bounds, and invariants. |
| Constrained decoding | Helps syntax/shape when supported. |
| Application validation | Enforces schema, semantics, and authorization. |
| Recovery | Bounded retry/repair; explicit failure when unresolved. |
| Monitoring | Versioned validity, truncation, and failure metrics. |

<br><br><br>

## How do you handle long contexts efficiently in production (context compression, prefix caching)?

**Answer:**

### Spend context budget on information that changes the answer

Long prompts increase prefill work, token cost, and memory used by attention state; they can also distract the model with irrelevant or conflicting material. Efficient context handling combines **selection and compression** of relevant content with **reuse** of repeated computation where the serving stack supports it. Compression should preserve evidence and instructions needed for correctness rather than merely shortening text.

### Practical techniques

1. **Measure and budget:** Track prompt tokens, output budget, prefill latency, cache behavior, and task quality by workload. Reserve capacity for system instructions, tool schemas, retrieved evidence, history, and output; enforce a maximum context before dispatch.
2. **Select before compressing:** Retrieve or filter only relevant documents and conversation turns, remove duplicates, and order evidence for the task. This often preserves more fidelity than summarizing everything.
3. **Compress with safeguards:** Summarize older turns, extract structured facts, or shorten documents while retaining provenance, uncertainty, constraints, and citations. Keep the original source available for verification and use task-specific evaluations to detect lost details.
4. **Manage conversation state:** Maintain a concise, versioned state summary plus recent turns rather than resending the full history indefinitely. Let users correct or inspect important remembered facts where the product requires it.
5. **Reuse stable prefixes:** If prompts share an identical prefix and the serving provider supports prefix/KV caching, structure requests so stable system instructions or common templates precede variable content. Cache reuse depends on exact tokenized prefix, model/runtime, cache lifetime, and provider policy; it is not guaranteed by putting similar text in a prompt.
6. **Respect cache correctness and isolation:** Keep tenant-sensitive or personalized material scoped correctly, invalidate on model/template/policy changes, and observe hit rates and stale/wrong-hit behavior. Prefix caching reuses computation state; it is distinct from caching a completed response.
7. **Consider model/context alternatives:** A model with a larger context window can avoid truncation but may still incur higher prefill latency and memory cost. Use chunking or staged retrieval when the task can be decomposed without losing global dependencies.

### Trade-offs, bottlenecks, and capacity assumptions

Compression and summarization reduce tokens but can discard rare details, negation, provenance, or safety constraints; aggressive truncation is especially risky. Retrieval reduces context size but can miss relevant evidence. Prefix caching can lower repeated prefill cost but uses finite memory and benefits only from compatible shared prefixes. Long contexts can bottleneck prefill compute, KV-cache memory/bandwidth, or queueing, depending on model and serving runtime. Context lengths, repetition rate, and traffic are unspecified, so benchmark quality and latency across realistic context-size percentiles and measure cache benefit rather than assuming a larger window or cache solves the problem.

### Concise interview answer

“I first measure prompt tokens and prefill cost, then select relevant context, deduplicate it, summarize older history with provenance, and enforce a context budget. Stable prefixes can benefit from provider/runtime KV-prefix caching, but only when tokenized prefixes and cache scope match; this is not response caching. I validate compression against task quality and grounding, and account for long-context KV memory, cache isolation, and invalidation. The goal is useful evidence per token, not simply the shortest prompt.”

### Revision summary

| Technique | Main benefit | Primary risk |
|---|---|---|
| Retrieval/filtering | Fewer irrelevant tokens. | Missed evidence. |
| Summarization/state | Avoid repeated full history. | Lost detail or provenance. |
| Prefix/KV caching | Reuse repeated prefill computation. | Limited hit rate, memory, scope/invalidation. |
| Context budgets | Bound latency and cost. | Truncation if poorly allocated. |
| Evaluation | Verify compression preserves outcomes. | Requires representative test cases. |

<br><br><br>

## What is semantic routing, and how do you implement it in a multi-model system?

**Answer:**

### Route by request meaning and required capability

**Semantic routing** selects a model or processing path based on the content or inferred intent of a request, rather than routing only by a static endpoint or round-robin policy. A router may use rules, a classifier, embeddings/similarity, a small model, or a combination to distinguish task types and match them to candidates with appropriate capability, latency, cost, data-handling constraints, and availability.

### A controlled routing workflow

1. **Define task classes and constraints:** Identify supported intents and non-negotiable requirements such as data residency, tenant entitlements, tool/structured-output needs, quality floor, and latency budget. Enforce security/policy constraints before any model-selection optimization.
2. **Build a capability map:** For each candidate, record supported modalities, context and output limits, tool/schema support, quality by task slice, latency distribution, price, quota, and fallback behavior. Keep the map versioned and verified against actual provider behavior.
3. **Implement staged selection:** Apply deterministic eligibility rules first; then use a classifier or semantic similarity to estimate the task; select among eligible models using a measured policy such as quality threshold plus cost/latency objectives. Route uncertain or high-impact cases to a safe default or human review.
4. **Handle confidence and drift:** Set confidence thresholds and an explicit “unknown” path rather than forcing every request into a class. Test paraphrases, multilingual inputs, ambiguous tasks, prompt injection, and distribution shifts. Monitor class frequencies, overrides, and route-specific quality.
5. **Evaluate counterfactually:** Compare router choices with alternatives on labeled representative data, including quality, safety, latency, and cost. Use shadow evaluation or controlled experiments; avoid training and evaluating on the same examples in a way that overstates routing performance.
6. **Apply operational guardrails:** Enforce per-model quotas and deadlines, circuit-break unhealthy endpoints, and use only policy-compatible fallbacks. Log router version, predicted class/confidence, eligible candidates, selected route, and outcome while minimizing sensitive input retention.
7. **Control change:** Version routing rules/model and capability metadata, canary changes, and roll back if quality, safety, or SLOs regress. Ensure routing does not unexpectedly move sensitive requests to a provider with different data terms.

Semantic routing is different from load balancing: the former chooses based on task meaning/capability, while the latter distributes eligible work to manage capacity. A production system often combines both—semantic selection followed by health- and load-aware endpoint selection.

### Trade-offs, bottlenecks, and capacity assumptions

Routing simple tasks to smaller models can reduce cost and latency, but classification errors can send difficult requests to an inadequate model or send sensitive requests to an ineligible provider. A router adds its own latency and failure mode; an LLM-based router can cost nearly as much as the call it is meant to save. More routing dimensions increase evaluation and observability complexity. Traffic, task taxonomy, model quality, and cost are unspecified, so justify routing against a single-model baseline and require measured net benefit after router cost and fallback rates.

### Concise interview answer

“Semantic routing maps request intent to an eligible model or workflow based on capability, quality, cost, latency, and data policy. I first enforce hard authorization and residency constraints, then classify with rules or a calibrated model and use an explicit low-confidence path. I evaluate route quality on representative task slices, monitor drift and fallback, and canary router changes. It complements load balancing: semantic routing selects the capability; health/load-aware balancing selects a serving endpoint.”

### Revision summary

| Step | Purpose |
|---|---|
| Eligibility constraints | Prevent policy-incompatible destinations. |
| Capability map | Compare models on verified task and operational fit. |
| Classification/confidence | Route by intent with an unknown path. |
| Evaluation/monitoring | Detect misroutes, drift, and regressions. |
| Load-aware dispatch | Combine semantic choice with endpoint health/capacity. |

<br><br><br>

## How do you manage secrets and API keys securely in LLM applications?

**Answer:**

### Keep credentials out of prompts, clients, and routine logs

LLM applications often use provider API keys, cloud credentials, database passwords, and tool-specific tokens. Treat these as privileged secrets: a prompt is not a secure storage mechanism, and model output or logs must never be relied on to protect a credential. The goal is to limit where secrets exist, who can retrieve them, what they can authorize, and how quickly they can be rotated or revoked.

### A practical secrets lifecycle

1. **Use a secrets manager:** Store production credentials in a managed secret store or approved platform facility, not in source code, prompt templates, notebooks, container images, or committed `.env` files. Inject them at runtime using workload identity or short-lived credentials where supported.
2. **Apply least privilege:** Use separate credentials per environment, service, and provider where practical. Restrict scopes, models, projects, and spend; keep tools on separate credentials from model-provider access. Avoid shared, long-lived administrator keys.
3. **Protect access and transport:** Limit secret retrieval to the workload identity that needs it, audit reads and changes, encrypt storage and transport, and restrict network egress to approved endpoints. Never send provider keys to browsers, mobile clients, user prompts, or untrusted tools.
4. **Prevent leakage:** Redact authorization headers and secret values from application logs, traces, exceptions, support bundles, and analytics. Keep secrets out of model context and test logging/telemetry paths for accidental capture. Use repository secret scanning and CI checks as additional detection—not a substitute for secure runtime storage.
5. **Rotate and revoke:** Establish ownership, expiry/rotation policy, and a tested emergency-revocation procedure. Support overlap of old and new credentials during rotation if the provider allows it; verify that all replicas have refreshed before revoking the old key.
6. **Handle compromise explicitly:** Revoke or rotate the exposed credential, review access and usage/billing records, identify affected deployments, and follow incident-response and provider-notification processes. Deleting a leaked value from the latest commit does not remove it from history or copies.
7. **Separate configuration from secret values:** Configuration can identify the secret reference or provider/model route; the actual credential is resolved by the runtime. Avoid printing full environment or configuration dumps in diagnostics.

For multi-tenant applications, do not accept a client-provided provider key as trusted authorization. If customer-supplied keys are a supported product feature, isolate storage and access, encrypt them, enforce ownership and deletion, and prevent accidental cross-tenant use.

### Trade-offs, bottlenecks, and capacity assumptions

Central secret management improves audit and rotation but adds a dependency; use platform-supported caching with bounded lifetime and clear behavior during secret-store outages rather than fetching a secret on every token. Short-lived credentials reduce exposure but may require token-refresh plumbing and resilient identity services. Rotation frequency, provider capabilities, deployment platform, and compliance obligations are unspecified, so define a threat-based policy with security owners and test revocation/rotation without interrupting service. A fallback must never silently use an unapproved or over-privileged key.

### Concise interview answer

“I keep provider credentials in a managed secrets system, inject them server-side through workload identity, and grant each workload only the minimum required scope. Keys never go into prompts, client apps, source control, images, or logs. I audit access, scan for accidental exposure, rotate with a tested overlap/revocation process, and investigate usage if compromise is suspected. Secret-store availability and multi-tenant customer keys need explicit isolation and failure handling.”

### Revision summary

| Control | Purpose |
|---|---|
| Managed secret store/workload identity | Avoid hard-coded, broadly shared credentials. |
| Least privilege | Limit impact of credential compromise. |
| Redaction/scanning | Prevent leakage through code and observability. |
| Rotation/revocation | Reduce exposure window and support incident response. |
| Tenant isolation | Prevent cross-customer credential access or use. |

<br><br><br>

## Your LLM API has latency spikes during peak hours. How do you stabilize it?

**Answer:**

### Diagnose queueing and saturation before changing models

Peak-hour latency spikes usually indicate that demand, request shape, or a dependency is exceeding some part of the serving path. First determine whether the regression is in queue wait, model prefill, token decode, network/provider time, retrieval, or post-processing. For streamed responses, separate time-to-first-token from inter-token delay and total completion time; a single aggregate latency number hides the cause.

### Stabilization sequence

1. **Confirm the signal and scope:** Compare p50/p95/p99 and error rates by model, route, tenant, region, prompt/output length, cache status, and request type. Check whether offered load increased, requests became longer, a cache hit rate dropped, or a provider changed quota behavior.
2. **Inspect saturation:** Examine queue depth/wait, active sequences, GPU/CPU and memory utilization, KV-cache pressure, throttling, connection pools, retrieval/index latency, and downstream timeouts. Identify the first saturated or slowing component rather than assuming the model is the only bottleneck.
3. **Protect the service immediately:** Enforce bounded admission, per-tenant concurrency/token limits, deadlines, and priority-aware queues. Shed or defer low-priority batch work, cap excessive context/output, and avoid unbounded retries. Return a clear overload response when work cannot meet its deadline.
4. **Use capacity safely:** Add replicas or accelerator capacity if the bottleneck scales horizontally and quotas/hardware allow. Confirm warm-up and model-load time; autoscale on leading saturation signals such as queued tokens or active sequences, not only CPU. Keep rollout/failover headroom and avoid scaling faster than the provider or cluster can supply capacity.
5. **Reduce work where quality permits:** Route suitable tasks to smaller models, use safe caching or prefix reuse, trim redundant context, batch compatible work, and bound agent/tool loops. Validate changes against task quality and safety; do not make a blanket truncation change during an incident without checking impact.
6. **Check dependencies and resilience:** If an upstream provider is throttling or slow, use bounded retries and circuit breaking; route to an approved alternate only if it has capacity and equivalent data-policy eligibility. Degrade explicitly if no safe path exists.
7. **Verify and prevent recurrence:** Compare latency and quality before/after mitigation, review capacity forecasts and load-test peak/burst patterns, and set alerts on queue growth, saturation, p99, and error-budget burn.

### Trade-offs, bottlenecks, and capacity assumptions

More capacity can reduce queueing but increases fixed cost and may not fix a provider quota or memory bottleneck. Higher batching improves utilization but can increase tail latency; stricter admission protects SLOs while rejecting more bursts. Smaller models and shorter contexts reduce service time but may lower quality. Traffic shape, model, quota, and SLO are unspecified, so quantify the bottleneck and run peak plus burst load tests; estimate capacity from request and token arrival rates, not request count alone.

### Concise interview answer

“I split end-to-end latency into queueing, prefill, decode, network/provider, retrieval, and post-processing, then segment p99 by model and token length. I inspect queue depth, active sequences, KV memory, utilization, and provider throttling to find the first bottleneck. I stabilize with bounded admission, deadlines, priority queues, retry controls, and safe capacity/route changes. I verify quality and safety after mitigation and load-test both sustained peak and bursts. Scaling alone will not solve quota, memory, or unbounded-work problems.”

### Revision summary

| Step | Goal |
|---|---|
| Decompose latency | Identify where requests wait or slow down. |
| Inspect saturation | Find capacity, memory, quota, or dependency limit. |
| Stabilize | Bound queues, concurrency, retries, and request size. |
| Scale/optimize | Add capacity or safely reduce per-request work. |
| Verify | Check p99, errors, quality, safety, and peak resilience. |

<br><br><br>

## Your LLM endpoint's p99 latency doubled after a deploy with no model change. How do you diagnose it?

**Answer:**

### Treat the deployment as a change in the whole serving path

An unchanged model identifier does not mean the system is unchanged. Prompt templates, tokenizer/chat formatting, runtime or drivers, batching, queue limits, routing, retrieval, caches, network paths, and infrastructure can all affect p99. Start by confirming the timing and cohort of the regression, then correlate it with the deployment and isolate the changed component.

### A disciplined diagnostic workflow

1. **Validate the measurement:** Check that p99 uses the same population, time window, success criteria, and instrumentation before and after deployment. Compare time-to-first-token, inter-token delay, total latency, and queue time; verify traffic mix and output-length changes.
2. **Scope and contain:** Compare canary versus stable pool, regions, tenants, models, and request sizes. If the SLO is breached and the change is implicated, pause rollout or roll back the application/runtime/configuration while preserving evidence.
3. **Diff the complete release bundle:** Inspect code/configuration, prompt and chat template, tokenizer, runtime/library versions, hardware/driver, container image, scheduler/batching/concurrency, resource limits, routing, feature flags, retrieval/index version, and cache policy—not just model weights.
4. **Compare traces and resource signals:** Find which span gained time. Check queue depth, active sequences, GPU utilization and memory, KV-cache allocation/eviction, CPU contention, network retries, provider quota, connection reuse, retrieval/reranker latency, and post-processing.
5. **Control for request shape:** Replay the same representative prompts and token lengths against both deployments under equivalent concurrency. Check whether token counts changed because of formatting/tokenizer or whether long-context requests became more common.
6. **Form and test hypotheses:** Use a controlled rollback or one-variable-at-a-time change; avoid changing batching, resources, and routing simultaneously because attribution is lost. Reproduce in a load test and compare latency distributions, not one sample.
7. **Close the loop:** Fix the root cause, add a regression check or deploy guardrail, retain release metadata, and expand rollout only after the p99 and quality/safety metrics recover.

If the endpoint is hosted by a provider and the model alias is mutable, provider-side changes can still occur without an application model-name change. Record available provider revision/response metadata and compare provider status and traces before concluding the local deployment caused the issue.

### Trade-offs, bottlenecks, and capacity assumptions

Immediate rollback can restore SLOs but may discard a beneficial change; a staged pause preserves control while investigation continues. p99 is sensitive to traffic mix and sample volume, so comparing unlike cohorts leads to false diagnoses. Detailed traces and replay improve attribution but incur overhead and must avoid exposing sensitive prompt data. No stack or workload details are supplied, so establish a baseline, compare identical request distributions, and use span-level evidence rather than assuming “no model change” excludes model-serving regressions.

### Concise interview answer

“I first validate that the p99 measurement and traffic mix are comparable, then split latency into queue, prefill, decode, provider/network, retrieval, and post-processing. I compare canary and stable traces and diff the full release bundle—runtime, prompt/template, tokenizer, scheduler, resources, routing, cache, and dependencies. I replay the same token-length workload under equal concurrency, test one hypothesis at a time, and roll back if the SLO is at risk. A stable model name does not rule out provider drift or serving-stack changes.”

### Revision summary

| Diagnostic step | Evidence |
|---|---|
| Validate regression | Comparable p99, cohorts, and token distributions. |
| Decompose spans | Locate the stage responsible for added latency. |
| Diff deployment | Include runtime, config, prompts, infra, routing, caches. |
| Controlled test | Same requests/concurrency; one change at a time. |
| Mitigate and prevent | Roll back if needed; add regression gates. |

<br><br><br>

## Your LLM costs are too high in production. How do you reduce costs without degrading quality?

**Answer:**

### Make cost per successful task the optimization target

Reducing nominal cost per call can be counterproductive if it creates more retries, escalations, human corrections, or failed tasks. Establish a baseline for cost per successful outcome and segment it by task, model, tenant, prompt/output tokens, retrieval/reranking, tools, retries, caching, and fallback. Keep quality, safety, and latency as explicit guardrails.

### Find and address the largest cost drivers

1. **Verify billing and attribution:** Reconcile provider usage with application logs and infrastructure costs. Separate input/output tokens, cached tokens if billed differently, embeddings, rerankers, moderation, tools, GPU idle capacity, and human review.
2. **Eliminate waste:** Bound retries and agent/tool loops, deduplicate repeated context, avoid unnecessary model calls, set task-appropriate output budgets, and cancel work that is no longer needed. Ensure caching is authorization- and freshness-safe.
3. **Route by task:** Use a smaller or lower-cost model for cases where it meets quality and safety thresholds; reserve stronger models for harder tasks or fallback. Evaluate router errors and escalation rates because misrouting can erase savings.
4. **Improve context and retrieval:** Retrieve only relevant evidence, remove duplicates, compact history while preserving provenance, and use prefix/KV caching where repeated compatible prefixes make it effective. Evaluate grounding and completeness after changes.
5. **Optimize serving economics:** Batch compatible traffic, improve utilization, tune concurrency, and compare managed API with self-hosting at actual sustained utilization. Include fixed operations, redundancy, idle capacity, and accelerator cost—not just marginal token pricing.
6. **Run controlled experiments:** Use representative held-out evaluation and canary/A-B rollout for prompt, model, routing, or quantization changes. Compare cost per successful task alongside quality by important slices, safety incidents, p95/p99, and human overrides.
7. **Set governance and budgets:** Attribute spend to product/tenant, forecast scenarios, alert on anomalies, and set budgets or quotas with a deliberate user-impact policy.

Avoid silently weakening safety filters, data governance, or evaluation coverage to meet a cost target. If a cost reduction creates a measurable quality or safety regression, report the trade-off and choose a different lever.

### Trade-offs, bottlenecks, and capacity assumptions

Cheaper models may increase failure and escalation rates; shorter prompts save tokens but can remove necessary evidence. Batching improves utilization but may harm latency. Self-hosting has lower marginal inference cost only at utilization sufficient to offset GPUs, operations, redundancy, and idle periods. Cache savings depend on request repetition and freshness. Cost mix, volume, and quality baseline are unspecified, so rank opportunities by measured cost contribution and use low/base/high traffic scenarios before committing to savings.

### Concise interview answer

“I first establish cost per successful task and attribute it across model tokens, retrieval, tools, retries, and serving overhead. Then I remove redundant work, bound loops/retries, optimize relevant context, route easy tasks to cheaper models, and improve caching or batching where the workload supports it. Every change is evaluated for task quality, safety, latency, and escalation rate. I compare hosted and self-hosted total cost at observed utilization and set spend attribution/alerts; a lower token bill is not success if outcomes degrade.”

### Revision summary

| Lever | Guardrail |
|---|---|
| Smaller-model routing | Quality, safety, fallback/escalation rate. |
| Context and output reduction | Grounding and completeness. |
| Cache/batch/serving tuning | Freshness, isolation, p99, utilization. |
| Retry/tool-loop controls | Successful completion and recovery. |
| Cost objective | Cost per successful task, fully attributed. |

<br><br><br>

## Your application is hitting LLM provider rate limits during peak hours. How do you handle it?

**Answer:**

### Treat provider limits as an admission-control and capacity problem

Provider rate limits may apply to requests, tokens, concurrent jobs, model families, projects, or other dimensions. During peak traffic, repeated immediate retries can worsen the overload and cause a retry storm. The application should control work before it reaches the provider, honor provider signals, and preserve a safe experience when available quota is insufficient.

### Response plan

1. **Understand the quota:** Identify limit scope and provider error semantics, including request/token limits, concurrency, reset timing, shared project/model quotas, and any separate input/output accounting. Track usage and throttling by model, tenant, and credential.
2. **Add local admission control:** Enforce per-tenant request/token budgets and concurrency limits with a distributed limiter when multiple app replicas share quota. Reserve capacity for high-priority interactive or safety-critical traffic, and isolate batch work.
3. **Shape demand:** Bound prompt and output tokens, queue eligible batch requests with a maximum wait, reject or defer work that cannot meet its deadline, and deduplicate/coalesce identical safe work where appropriate. Avoid unbounded queues.
4. **Handle throttling correctly:** Honor `Retry-After` or provider guidance. Apply bounded exponential backoff with jitter and a total deadline; do not retry permanent validation/auth errors. After a retry budget is exhausted, return a clear retryable response or enter a defined degraded path.
5. **Use alternatives carefully:** Route to another approved model/provider only if it meets capability, quality, privacy, residency, and contract requirements and has available quota. Maintain separate credentials/quotas and avoid assuming the secondary can absorb all primary traffic.
6. **Request quota or scale where justified:** Use measured peak demand and token distributions to request quota increases, reserve capacity, or adjust deployment. Quota increases are not a substitute for protecting the service from bursts or runaway clients.
7. **Monitor and rehearse:** Alert on approaching quota, throttling rate, queue age, token usage, retries, and fallback outcomes. Load-test bursts and run provider-throttle/failure exercises.

### Trade-offs, bottlenecks, and capacity assumptions

Queueing smooths bursts but increases wait and memory and can make stale requests useless. Rejection preserves latency and provider health but affects availability from the user’s perspective. A secondary provider can help only if pre-approved and independently provisioned; correlated demand or regional incidents may affect both. Quotas, request/token mix, and deadlines are unspecified, so size limits using peak token consumption and provider reset behavior, then set queue and rejection policies from the product’s latency SLO.

### Concise interview answer

“I confirm which provider quota is binding, then enforce matching local request, token, and concurrency limits so replicas do not collectively oversubscribe it. I prioritize interactive work, bound queues, and honor provider retry timing with jitter and a deadline. After a small retry budget, I return a clear overload response or use an approved, capacity-tested alternative. I monitor quota headroom, tokens, throttles, queue age, and fallback quality; simply increasing retries makes the problem worse.”

### Revision summary

| Control | Benefit |
|---|---|
| Quota-aware limiter | Prevent predictable provider throttling. |
| Priority queues/budgets | Allocate scarce capacity intentionally. |
| Bounded backoff | Avoid retry storms. |
| Approved fallback | Preserve selected tasks when compatible capacity exists. |
| Forecast/load tests | Validate peak and burst token demand. |

<br><br><br>

## Your application depends on one LLM provider. How do you switch providers without downtime?

**Answer:**

### Decouple the application contract from provider-specific behavior

Switching providers without downtime requires more than changing a base URL. Providers differ in model quality, tokenization, context limits, tool calling, structured outputs, streaming events, safety behavior, quotas, error semantics, and data-processing terms. First make the application’s provider dependency explicit behind an adapter or gateway while retaining access to provider-specific capabilities that the product needs.

### Migration plan

1. **Inventory dependencies and constraints:** Identify models, prompts, tools, structured-output schemas, streaming behavior, embeddings/rerankers, data residency and retention requirements, credentials, quotas, and contractual controls. Map provider-specific features and unsupported equivalents.
2. **Build a compatibility layer:** Define a stable internal request/response contract and provider adapters. Normalize common concepts—timeouts, errors, token usage, tool calls, and stream events—while rejecting or exposing unsupported features rather than silently changing semantics.
3. **Evaluate the candidate:** Run representative offline quality, grounding, safety, structured-output, tool, latency, and cost tests. Test important slices and failure cases; check model licensing and the provider’s data terms before sending production data.
4. **Provision and validate capacity:** Set up credentials, quotas, networking, monitoring, and rate/concurrency limits. Verify health checks, warm-up, regional behavior, and capacity for canary plus failover traffic.
5. **Shadow and compare safely:** Send a privacy-approved sample to the new provider without returning its responses to users. Avoid duplicate side effects from tools; compare outputs and operational measures with redaction and evaluation controls.
6. **Canary and shift gradually:** Route a small stable cohort to the new provider using feature flags or gateway routing. Monitor task quality, safety, errors, p95/p99, first-token delay, token usage, and cost. Increase traffic only after defined gates pass.
7. **Preserve rollback and complete migration:** Keep the old provider, credentials, compatible prompts, and quota available during the observation window. Roll back routing quickly if guardrails fail; migrate fully only after sustained evidence, then retire old credentials and integrations through a controlled process.

If providers use different models, record the selected provider/model and configuration on each request. Do not promise bit-for-bit reproducibility across vendors, and test that a failover does not send data to a provider disallowed by policy.

### Trade-offs, bottlenecks, and capacity assumptions

Running both providers during migration reduces risk but temporarily doubles integration, evaluation, and possibly inference cost. An abstraction layer improves portability but can hide important differences or constrain access to provider-native features. Shadow traffic increases cost and may raise privacy concerns; canaries provide real outcomes but expose users to a small amount of variation. Provider quota, traffic, latency targets, and fallback needs are unspecified, so verify the secondary provider can carry the planned traffic, including peak/failover load, before cutover.

### Concise interview answer

“I first map provider-specific behavior and data constraints, then add or validate an adapter with explicit semantics for tools, streaming, errors, and structured output. I evaluate the candidate offline, provision and load-test its quota/capacity, and shadow safely before a gradual canary. I keep the old route available for rollback and monitor quality, safety, latency, and cost by provider/model. Only after the new provider meets guardrails do I migrate fully and retire the old credentials.”

### Revision summary

| Phase | Control |
|---|---|
| Compatibility | Explicit adapter; preserve provider-specific differences. |
| Validation | Offline quality, safety, feature, latency, and cost tests. |
| Rollout | Privacy-aware shadow, canary, staged traffic shift. |
| Resilience | Tested secondary capacity and fast routing rollback. |
| Retirement | Remove old integration/credentials after observation. |

<br><br><br>

## Your AI system handles 100 requests/sec but crashes at 5000. How do you scale for concurrent requests?

**Answer:**

### Find the concurrency limit, not just the request-rate limit

A service that handles 100 requests per second may still fail at a sudden 5,000-request burst because requests remain in flight for seconds, each generation holds model/KV-cache and connection resources, or an upstream quota limits admission. Request rate alone does not describe concurrent work. First establish whether “5,000” means a burst, sustained requests per second, or simultaneous open requests; the capacity plan differs substantially.

### Scale and protect the complete serving path

1. **Measure the failure mode:** Collect offered/completed rate, in-flight requests, queue depth and age, token arrival rates, input/output lengths, active sequences, GPU/CPU/memory, KV-cache pressure, connection pools, provider throttling, and error/timeout rates. Determine whether failure starts at gateway, application workers, model server, or dependency.
2. **Bound work before saturation:** Add per-tenant and global request/token/concurrency limits, bounded queues, deadlines, payload/context/output caps, and priority-aware admission. Reject or defer excess work with an explicit response instead of allowing an unbounded queue to exhaust memory.
3. **Model concurrency:** Use observed request duration and arrival rate to estimate in-flight load (Little’s Law: average concurrency ≈ arrival rate × average time in system). For generation, also track active sequences and token lengths because equal request counts can consume very different GPU memory and compute.
4. **Scale the bottleneck:** Horizontally scale stateless gateways/workers where appropriate, and add model-serving replicas/accelerators if the deployment and quota permit. Ensure load balancing is health-aware and that model loading, warm-up, and autoscaling delays are included. Avoid scaling application workers past a fixed provider quota.
5. **Use backpressure and workload isolation:** Separate interactive, batch, and long-context workloads; schedule batch when capacity is available. Tune batching/continuous batching against tail latency, and prevent slow clients or long streams from holding unlimited resources.
6. **Design for bursts and failure:** Keep headroom, use circuit breakers, bound retries, and reserve capacity for critical paths. If external inference capacity cannot expand quickly, use queued asynchronous work or a clear overload response rather than pretending all requests can be served synchronously.
7. **Load-test progressively:** Test ramp, burst, and sustained scenarios at realistic token distributions. Identify the saturation knee and verify p95/p99, quality, memory, queue behavior, autoscaling, and recovery after load falls.

### Trade-offs, bottlenecks, and capacity assumptions

More replicas improve throughput only if compute, memory, provider quota, and network dependencies scale too. Larger batches can improve utilization while increasing queueing and tail latency. Queues absorb short bursts but cannot solve sustained overload; if arrival rate exceeds service rate, queue length and wait grow without bound. “5,000 requests” is ambiguous and no request duration, tokens, hardware, or provider quota is supplied, so do not assert a replica count: define burst versus sustained load, measure service rate per replica, and provision for token-weighted peak concurrency with failure headroom.

### Concise interview answer

“I clarify whether 5,000 is a burst, requests per second, or concurrent sessions, then inspect in-flight work, token lengths, queueing, KV-cache/memory, and provider limits. I protect the system with bounded admission, tenant quotas, deadlines, and backpressure; excess work is queued only within a latency budget or rejected clearly. I scale the actual bottleneck and load-test ramp, burst, and sustained traffic. Request rate alone is not enough—generation duration and tokens determine concurrency and capacity.”

### Revision summary

| Concern | Action |
|---|---|
| Ambiguous load | Separate burst, sustained RPS, and concurrency. |
| Saturation | Measure queues, active sequences, tokens, memory, quotas. |
| Protection | Limits, deadlines, backpressure, bounded queues. |
| Scaling | Add capacity at the constrained tier and verify quota. |
| Validation | Load-test realistic token distributions and recovery. |

<br><br><br>

## A traffic spike brings down your AI system. How do you handle peak traffic?

**Answer:**

### Stabilize first, then improve peak capacity

During a spike, the immediate goal is to preserve a useful, safe subset of service and prevent overload from cascading across the application, model server, provider, and data services. Distinguish a short burst from sustained demand: buffers can absorb bursts, but sustained arrival above service capacity requires shedding, scaling, or reducing work.

### Incident response and prevention

1. **Assess and contain:** Check offered traffic, successful completions, latency percentiles, errors, active generations, queue age, token volume, provider quota, and resource saturation. Freeze risky deployments and identify the first failing dependency.
2. **Apply admission control:** Enforce global and per-tenant request/token/concurrency budgets. Prioritize interactive or critical workloads; defer batch jobs and reject requests that cannot meet their deadline. Keep queues bounded so overload does not turn into memory exhaustion and stale work.
3. **Reduce avoidable work safely:** Cap excessive input/output lengths, avoid duplicate requests, cancel abandoned streams, and bound retries/tool loops. Route simple tasks to an approved lower-cost/lower-latency path only if quality and policy gates are met.
4. **Scale with a tested plan:** Add replicas or GPU capacity if the bottleneck supports scaling, using queue/token-based signals and warm capacity where startup is slow. Confirm cloud/provider quotas and regional limits before relying on autoscaling. Do not create retry storms while capacity is provisioning.
5. **Protect dependencies:** Use timeouts, circuit breakers, bounded retry with jitter, and load shedding to stop failures cascading to retrieval, tools, and storage. Use a pretested fallback or a clear degraded response if primary inference is unavailable.
6. **Communicate and observe:** Return explicit retry guidance or status for throttled requests, communicate degraded features to operators/users as appropriate, and maintain incident timeline and metrics. Do not silently drop requests or claim success for incomplete generations.
7. **Run post-incident analysis:** Reproduce the traffic shape, find the saturation knee, update forecasts and limits, add burst and failover tests, and tune autoscaling and capacity reserves.

### Trade-offs, bottlenecks, and capacity assumptions

Reserved warm capacity improves burst response but incurs idle cost; reactive autoscaling is cheaper but may be too slow for sudden peaks. Queueing preserves work but increases latency, while shedding protects healthy traffic at the expense of rejected requests. Token-aware limits are more resource-sensitive than simple request counts but require estimation and reconciliation. Traffic duration, token distribution, quotas, and priority policy are unspecified, so define a maximum queue/wait, load-test burst and sustained scenarios, and size headroom for the slowest-to-scale dependency.

### Concise interview answer

“I contain the incident with bounded, priority-aware admission, short deadlines, bounded retries, and explicit shedding or deferral so queues and dependencies do not collapse. I identify the actual bottleneck and scale it only where capacity and quotas permit, while canceling abandoned work and using tested fallbacks. Afterward I load-test the real burst and sustained patterns, set token-aware limits and autoscaling signals, and reserve enough warm capacity for the system’s recovery target.”

### Revision summary

| Phase | Focus |
|---|---|
| Contain | Stop cascading overload and protect critical requests. |
| Shape | Limit tokens/concurrency, prioritize, bound queue and retries. |
| Scale | Add capacity at the bottleneck; verify quotas and warm-up. |
| Degrade | Fail explicitly and safely when capacity is exhausted. |
| Prevent | Load-test burst/sustained demand and refine headroom. |

<br><br><br>

## One LLM provider outage took down your entire system. How do you eliminate single points of failure?

**Answer:**

### Remove the provider as a hard dependency, not just add a second endpoint

If one provider outage takes down the product, the architecture has a single critical dependency. Resilience requires an alternate path that is actually operable and compatible, plus graceful behavior when no equivalent capacity exists. Multi-provider routing alone does not eliminate single points of failure if credentials, gateway, DNS, region, queue, or policy services remain shared dependencies.

### Resilience design

1. **Map the dependency graph:** Identify provider APIs, regions, model families, gateway, credentials/secret store, DNS/network, identity, retrieval, tools, observability, and data stores. Determine which are on the synchronous critical path and where failure propagates.
2. **Define failure objectives:** Set availability and recovery objectives per feature, and decide which tasks can use an alternate model, deterministic path, queue, or explicit unavailable response. A weaker alternate should not silently serve high-risk use cases.
3. **Qualify independent alternatives:** Select a secondary provider or self-hosted deployment with appropriate model capability, data terms, region, policy, and quota. Avoid shared failure domains where feasible; verify that the secondary does not depend on the same critical infrastructure.
4. **Abstract without erasing differences:** Use adapters for requests, streaming, tools, structured outputs, errors, and usage, but expose capability differences. Maintain provider-specific evaluation suites and version the route/model selected for each request.
5. **Pre-provision and control failover:** Keep credentials, connectivity, quota, and sufficient warm capacity ready. Use health checks, circuit breakers, and controlled traffic shifts; bounded retries prevent a failing primary from amplifying load. Avoid automatic failover loops between unhealthy providers.
6. **Design graceful degradation:** Cache only safe/fresh responses, use deterministic or reduced-capability workflows for suitable tasks, queue background work within a limit, and otherwise return a clear service state. Preserve authorization and safety controls in every path.
7. **Test and monitor:** Run provider outage, quota exhaustion, network partition, secret-store failure, and recovery exercises. Track dependency health, failover rate, recovery time, secondary saturation, and quality/safety during fallback. Ensure operators can manually route traffic if automation fails.

Eliminating every single point is often uneconomic or impossible; the goal is to identify critical dependencies, reduce correlated failure, and bound user impact with tested recovery objectives.

### Trade-offs, bottlenecks, and capacity assumptions

Multi-provider readiness costs engineering, evaluation, contracts, duplicated integrations, and reserved capacity. A secondary that is rarely tested may fail precisely during an outage, while sending all traffic there can exceed its quota. Cross-provider behavior is not identical, and data terms may constrain which requests can fail over. Provider independence, traffic, RTO, and quality requirements are unspecified, so measure whether the alternate can handle the intended share under peak conditions and explicitly document tasks that cannot fail over.

### Concise interview answer

“I map the full critical dependency chain, then qualify an independent alternate with compatible data terms, model capability, credentials, and tested quota. I keep routing, circuit breaking, bounded retries, and a safe degraded path, but do not assume two providers are automatically redundant—gateways, secrets, regions, and tools can remain shared failure points. I exercise outage and recovery scenarios and monitor fallback quality and capacity. The goal is bounded impact and a tested recovery objective, not an unverified second endpoint.”

### Revision summary

| Resilience element | Check |
|---|---|
| Dependency map | Find shared and correlated failure domains. |
| Alternate path | Compatible policy, capability, independent infrastructure. |
| Capacity | Warm/available quota for planned failover load. |
| Degradation | Safe behavior when no model path is available. |
| Exercises | Validate outage, routing, recovery, and quality. |

<br><br><br>

## Your multi-LLM pipeline fails when one model in the chain breaks. How do you handle orchestration failure?

**Answer:**

### Make each step failure-aware and the workflow recoverable

A multi-LLM pipeline may use separate models for classification, retrieval query generation, drafting, verification, or summarization. A failure in one step can invalidate later outputs or leave side effects incomplete. Treat the pipeline as an explicit workflow with typed inputs/outputs, dependencies, deadlines, and recovery rules—not as an untracked sequence of model calls.

### Orchestration design

1. **Represent the workflow explicitly:** Define each step, input/output schema, dependency, timeout, retry policy, and whether it is safe to repeat. Validate outputs at every boundary before passing them downstream.
2. **Classify errors:** Distinguish provider throttling/timeouts, transient network errors, invalid or truncated output, model refusal, business-rule failure, and permanent configuration errors. Retry only transient and recoverable errors; use bounded exponential backoff with jitter and an overall workflow deadline.
3. **Isolate failures:** Use per-step concurrency limits, circuit breakers, and bulkheads so a slow model does not exhaust all workers or block unrelated workflows. Propagate cancellation and deadlines across steps.
4. **Choose step-specific recovery:** Retry an idempotent step, route to an evaluated alternate model, use a deterministic fallback, skip an optional enrichment step, or stop and return a clear partial/unavailable result. Do not feed stale or invalid intermediate output into later steps.
5. **Persist checkpoints where appropriate:** For long-running workflows, store validated intermediate results and workflow state with version metadata. Resume from the last safe checkpoint rather than rerunning costly completed stages. Protect checkpoint data with the same access and retention controls as the original input.
6. **Control side effects:** For tool calls or external actions, use idempotency keys, transactional boundaries, or compensation. A retry after an uncertain timeout must first determine whether the side effect already occurred.
7. **Make completion semantics explicit:** Return complete, partial, failed, or pending status with the failed step and a safe user-facing explanation. Do not label a degraded or partial response as a successful complete answer.
8. **Observe and test the graph:** Trace each step and model/version, record attempts and failure categories, and test provider outages, malformed output, timeouts, cancellation, and recovery. Replay tests should prevent accidental duplicate external side effects.

Fallback models must be evaluated for the particular stage: a model suitable for drafting may not be suitable for verification or policy-sensitive decisions. Keep policy, authorization, and validation independent of the model chain.

### Trade-offs, bottlenecks, and capacity assumptions

Retries and alternate models improve recoverability but increase latency, cost, and load during an outage. Checkpointing saves recomputation but adds storage, versioning, and consistency requirements. Skipping optional steps improves availability but can reduce output quality; mandatory safety or authorization steps must not be bypassed. Workflow length, step costs, and recovery objectives are unspecified, so set per-step and total deadlines, bound retry/fallback capacity, and identify which outputs are safe to resume or degrade.

### Concise interview answer

“I model the pipeline as a typed, checkpointable workflow with per-step deadlines, validation, retryability, and idempotency. I classify failures, retry only transient errors with a bounded budget, isolate slow steps with bulkheads/circuit breakers, and select a step-appropriate fallback or return an explicit partial/failure state. Checkpoints avoid recomputing safe completed stages, while side effects use idempotency controls. I trace each model/version and test failures at every stage; safety and authorization steps are never silently skipped.”

### Revision summary

| Mechanism | Benefit |
|---|---|
| Typed steps and validation | Prevent invalid intermediates from cascading. |
| Bounded retries/deadlines | Recover transient faults without retry storms. |
| Bulkheads/circuit breakers | Isolate slow or unhealthy components. |
| Checkpoints/idempotency | Resume safely and avoid duplicated side effects. |
| Explicit status/fallback | Preserve honest completion semantics. |

<br><br><br>

## Your AI pipeline has zero visibility into which step is failing. How do you add observability?

**Answer:**

### Instrument the pipeline as a traceable workflow

When an AI pipeline has no step-level visibility, a final request status is insufficient: retrieval, model calls, tools, safety checks, parsing, and post-processing can fail or slow independently. Add observability around the workflow’s actual boundaries, preserving a correlation path from user request to every sub-operation.

### Instrumentation plan

1. **Create and propagate trace context:** Start a trace/request ID at ingress and propagate it through asynchronous jobs, retries, model/provider calls, retrieval, and tools. Each stage should have a span with parent-child relationships and a stable step name.
2. **Record step outcomes and timing:** Capture start/end time, status, timeout/cancellation, attempt number, queue wait, provider/model, and a bounded error category. For generation, separately record time-to-first-token, inter-token delay, total duration, completion reason, and whether output was partial.
3. **Capture AI-specific metadata:** Record prompt/model/index/tool/policy versions, token counts, retrieval document counts and score summaries, cache outcomes, validation status, and route/feature-flag variant. Avoid placing raw prompts, completions, PII, or secrets in trace attributes by default.
4. **Define stage-level metrics:** Aggregate request and token throughput, failure/retry/fallback rate, latency percentiles, queue depth, active concurrency, retrieval empty/error rates, parse/schema failures, and safety outcomes. Use bounded labels; do not make user IDs or raw text high-cardinality metric dimensions.
5. **Correlate with end outcomes:** Track whether each stage failure correlates with task completion, user retry, human correction, cost, and quality. Operational success does not establish answer correctness, so combine traces with versioned evaluations and approved feedback signals.
6. **Build actionable dashboards and alerts:** Show end-to-end and per-stage latency/error, queue/saturation, provider throttling, and cost. Alert on SLO/error-budget burn and meaningful anomaly thresholds; include trace links and release metadata for investigation.
7. **Protect and validate telemetry:** Apply access controls, redaction, encryption, sampling, and retention. Test that errors and partial streams are captured and that trace context survives queue boundaries, retries, and cancellation.

Use structured logs for discrete events and distributed traces for causality; metrics are for aggregate trends and alerting. Keep clock synchronization and consistent status semantics so cross-service timing is interpretable.

### Trade-offs, bottlenecks, and capacity assumptions

More spans and attributes improve diagnosis but increase ingestion cost, storage, and cardinality. Sampling reduces overhead but can miss rare failures; preserve targeted error traces under approved privacy controls. Raw content may aid debugging but creates significant privacy/security risk and should not be the default. Pipeline shape, request volume, and retention are unspecified, so estimate telemetry volume from requests × stages × events and establish sampling, retention, and cardinality budgets.

### Concise interview answer

“I propagate a trace ID through the pipeline and create spans for retrieval, each model call, tools, validation, and post-processing. Each span records duration, outcome, retries, queue wait, and safe version/token metadata; streaming records first-token and partial completion explicitly. I add stage-level latency/error/throughput metrics and dashboards, with bounded labels and privacy-aware sampling. This lets us find the failing step while keeping raw prompts and sensitive data out of telemetry by default.”

### Revision summary

| Signal | Use |
|---|---|
| Distributed traces | Follow causality and identify slow/failing stages. |
| Structured logs | Diagnose specific events and bounded error details. |
| Metrics | Trends, SLO alerts, throughput and saturation. |
| AI metadata | Reproduce model/prompt/index/route behavior. |
| Privacy controls | Redaction, access, sampling, retention, low cardinality. |

<br><br><br>

## You quantized your LLM, but accuracy dropped significantly. How do you minimize quantization loss?

**Answer:**

### Find the source of degradation before changing precision

Quantization maps model parameters or activations to lower-precision representations to reduce memory use and potentially improve inference efficiency. Accuracy loss can come from an unsuitable quantization method or calibration set, sensitive layers, activation outliers, incorrect scale/zero-point settings, unsupported kernels, or a mismatch in evaluation. First reproduce the regression against the same model, tokenizer, prompts, decoding configuration, and evaluation data.

### Recovery workflow

1. **Validate the comparison:** Confirm identical model revision, tokenizer/chat template, prompt, context truncation, decoding settings, and evaluation set. Use repeated runs or suitable statistical analysis for stochastic tasks, and inspect task slices rather than one aggregate score.
2. **Check the quantization path:** Verify weight-only versus weight-and-activation quantization, bit width, calibration procedure/data, group size, scales, clipping, and runtime/kernel support. Ensure the loaded artifact is the intended quantized model.
3. **Improve calibration and evaluation coverage:** Use representative, privacy-approved calibration examples spanning production languages, context lengths, and task types. Include outliers and difficult cases; calibration is not a substitute for held-out quality evaluation.
4. **Use mixed precision selectively:** Keep sensitive layers, embeddings, normalization, output head, or activation paths at higher precision if measurement shows they drive loss. Apply per-channel or group-wise quantization and outlier handling when supported by the method/runtime.
5. **Try a less aggressive format:** Compare nearby bit widths and supported quantization algorithms. A modestly larger artifact can be the best system choice if it restores quality while still fitting target hardware.
6. **Consider quantization-aware training or adaptation:** If post-training quantization (PTQ) cannot meet the quality bar, evaluate quantization-aware training (QAT) or targeted adaptation using appropriate data and compute. This changes training/deployment complexity and needs independent evaluation.
7. **Benchmark the actual deployment:** Measure task quality, safety, latency, throughput, memory, and cost on target hardware. Some low-bit formats may not accelerate the chosen backend, and speed improvements can be offset by dequantization or memory behavior.
8. **Gate and roll out carefully:** Keep the full-precision or last-known-good artifact available, canary the quantized version, and roll back if quality/safety guardrails fail. Version quantization config and calibration artifacts for reproducibility.

### Trade-offs, bottlenecks, and capacity assumptions

Lower bit width reduces weight memory but can increase quantization error; higher precision or selective mixed precision uses more memory and can limit concurrency. Better calibration and QAT require representative data, time, and compute, and may not fix all model/task degradations. Hardware kernel support determines whether reduced precision improves speed. Model size, method, hardware, and acceptable quality loss are unspecified, so compare several validated precision points and optimize the quality-memory-latency frontier rather than assuming the lowest bit width is best.

### Concise interview answer

“I first reproduce the drop under identical evaluation and inspect quantization method, calibration coverage, scales, outliers, and runtime support. Then I test representative calibration data, group/per-channel or outlier-aware methods, and selectively retain higher precision in sensitive layers; if PTQ is insufficient, I evaluate QAT or a less aggressive bit width. Each candidate is benchmarked for task/safety quality and real hardware latency/memory, canaried with rollback. Quantization is a quality-efficiency trade-off, not just a file-size change.”

### Revision summary

| Step | Goal |
|---|---|
| Reproduce | Exclude evaluation and configuration mismatch. |
| Diagnose | Find sensitive layers, calibration, or kernel issue. |
| Adjust | Calibration, mixed precision, method, or bit width. |
| Escalate | Consider QAT/adaptation when PTQ misses quality bar. |
| Validate | Quality, safety, speed, memory, and rollback readiness. |

<br><br><br>

## One failing AI component can take down your entire platform. How do you design graceful degradation?

**Answer:**

### Keep failures contained and preserve a safe core experience

Graceful degradation means that when a component becomes unavailable or overloaded, the platform continues to provide a reduced but correct and clearly communicated service instead of cascading into a total outage. AI systems have multiple failure-prone components—providers, retrieval, embeddings, rerankers, tools, moderation, vector stores, and orchestration. The degraded path must preserve authorization and mandatory safety controls.

### Resilience design

1. **Map criticality and dependencies:** Classify components as essential, optional enhancement, or task-dependent. Define what the user can safely receive if each dependency fails; do not mark policy or authorization checks as optional merely to improve availability.
2. **Set deadlines and resource isolation:** Give each stage a timeout within an overall request deadline. Use bulkheads, separate queues, concurrency limits, and circuit breakers so a failing component does not consume all workers or connection pools.
3. **Provide explicit fallbacks:** Examples include a direct model response when nonessential reranking is unavailable (only if grounding requirements still hold), a deterministic FAQ path, cached authorized content with freshness checks, queued background processing, or a clear unavailable response. Never present stale or unsupported output as a verified answer.
4. **Control retries and side effects:** Retry only transient failures with bounded backoff and jitter; cancel abandoned work. Use idempotency and compensation for tools or external mutations so timeouts do not create duplicate actions.
5. **Reduce load intentionally:** Shed low-priority traffic, defer batch jobs, cap context/output, and offer lower-cost paths only when quality and policy are acceptable. Keep queues bounded and expose retry-after information when applicable.
6. **Make degraded status visible:** Record which components were bypassed or substituted, return appropriate completion/fallback status, and provide operators with dashboards and alerts. User-facing messaging should be accurate without exposing internal sensitive details.
7. **Test failure modes:** Inject dependency timeouts, provider rate limits, retrieval failures, cache staleness, malformed outputs, and secret/network outages. Verify recovery, rollback, safety invariants, and whether the system returns to normal without manual state cleanup.

Graceful degradation is a product decision as much as an infrastructure feature: define acceptable reduced capabilities with product, safety, and domain owners, then encode those modes explicitly.

### Trade-offs, bottlenecks, and capacity assumptions

Fallbacks improve availability but may reduce answer quality, freshness, or functionality; operating multiple paths adds cost and test surface. Circuit breakers can prevent cascading failure but require careful thresholds to avoid flapping. Caches reduce dependency load but risk stale or cross-tenant information if scoped incorrectly. Traffic, component criticality, and recovery targets are unspecified, so define per-feature degradation contracts and test that remaining dependencies can support the prioritized load during failure.

### Concise interview answer

“I identify essential versus optional components and define an explicit safe degraded mode for each failure. Deadlines, bounded queues, bulkheads, circuit breakers, and bounded retries contain the fault; fallback may use an approved alternate, deterministic path, fresh authorized cache, queue, or clear unavailable response. I never bypass authorization or mandatory safety checks, and I expose degraded status operationally. Fault-injection tests verify both user behavior and recovery under the remaining capacity.”

### Revision summary

| Principle | Implementation |
|---|---|
| Failure containment | Deadlines, bulkheads, limits, circuit breakers. |
| Safe fallback | Approved alternate, deterministic path, cache, queue, or explicit error. |
| Invariants | Preserve authorization, privacy, and required safety. |
| Clarity | Record and communicate degraded completion status. |
| Resilience tests | Exercise faults, recovery, and reduced-capacity operation. |

<br><br><br>
