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

<br><br><br>

## What is LLMOps, and how does it differ from traditional MLOps?

**Answer:**

<br><br><br>

## How do you serve LLMs in production?

**Answer:**

<br><br><br>

## What is model quantization?

**Answer:**

<br><br><br>

## Explain post-training quantization (PTQ) vs quantization-aware training (QAT). What breaks when you push weights to 2-4 bits?

**Answer:**

<br><br><br>

## How do you monitor LLM applications in production?

**Answer:**

<br><br><br>

## What is LLM observability?

**Answer:**

<br><br><br>

## What are guardrails for LLMs, and how do you implement them?

**Answer:**

<br><br><br>

## How do you implement content filtering for AI outputs?

**Answer:**

<br><br><br>

## How do you estimate the cost of running an AI-powered feature in production?

**Answer:**

<br><br><br>

## How do you optimize LLM inference costs in production?

**Answer:**

<br><br><br>

## How do you implement A/B testing for LLM systems?

**Answer:**

<br><br><br>

## What is CI/CD for AI applications, and how does it differ from traditional CI/CD?

**Answer:**

<br><br><br>

## How do you version and manage prompts in production?

**Answer:**

<br><br><br>

## What is model versioning, and how do you handle model rollbacks?

**Answer:**

<br><br><br>

## How do you implement rate limiting and throttling for LLM APIs?

**Answer:**

<br><br><br>

## How do you handle model updates and migrations without downtime?

**Answer:**

<br><br><br>

## What is the role of feature flags in AI deployments?

**Answer:**

<br><br><br>

## How do you implement logging and tracing for LLM applications?

**Answer:**

<br><br><br>

## How do you handle PII and sensitive data in LLM inputs and outputs?

**Answer:**

<br><br><br>

## What is a gateway pattern for LLM API management?

**Answer:**

<br><br><br>

## How does Token Streaming work?

**Answer:**

<br><br><br>

## How do you implement streaming responses for real-time AI applications?

**Answer:**

<br><br><br>

## How does vLLM work?

**Answer:**

<br><br><br>

## How does SGLang work?

**Answer:**

<br><br><br>

## How does TensorRT-LLM work?

**Answer:**

<br><br><br>

## How does llama.cpp run LLMs on everyday hardware?

**Answer:**

<br><br><br>

## How does Ollama work?

**Answer:**

<br><br><br>

## When would you choose vLLM vs SGLang vs TensorRT-LLM?

**Answer:**

<br><br><br>

## What are the key SLAs and metrics for production AI systems (latency, throughput, availability)?

**Answer:**

<br><br><br>

## Cloud vs on-device Model Deployment for AI applications.

**Answer:**

<br><br><br>

## How do you implement fallback strategies when the primary model is unavailable or rate-limited?

**Answer:**

<br><br><br>

## How do you implement structured output from LLMs reliably in production?

**Answer:**

<br><br><br>

## How do you handle long contexts efficiently in production (context compression, prefix caching)?

**Answer:**

<br><br><br>

## What is semantic routing, and how do you implement it in a multi-model system?

**Answer:**

<br><br><br>

## How do you manage secrets and API keys securely in LLM applications?

**Answer:**

<br><br><br>

## Your LLM API has latency spikes during peak hours. How do you stabilize it?

**Answer:**

<br><br><br>

## Your LLM endpoint's p99 latency doubled after a deploy with no model change. How do you diagnose it?

**Answer:**

<br><br><br>

## Your LLM costs are too high in production. How do you reduce costs without degrading quality?

**Answer:**

<br><br><br>

## Your application is hitting LLM provider rate limits during peak hours. How do you handle it?

**Answer:**

<br><br><br>

## Your application depends on one LLM provider. How do you switch providers without downtime?

**Answer:**

<br><br><br>

## Your AI system handles 100 requests/sec but crashes at 5000. How do you scale for concurrent requests?

**Answer:**

<br><br><br>

## A traffic spike brings down your AI system. How do you handle peak traffic?

**Answer:**

<br><br><br>

## One LLM provider outage took down your entire system. How do you eliminate single points of failure?

**Answer:**

<br><br><br>

## Your multi-LLM pipeline fails when one model in the chain breaks. How do you handle orchestration failure?

**Answer:**

<br><br><br>

## Your AI pipeline has zero visibility into which step is failing. How do you add observability?

**Answer:**

<br><br><br>

## You quantized your LLM, but accuracy dropped significantly. How do you minimize quantization loss?

**Answer:**

<br><br><br>

## One failing AI component can take down your entire platform. How do you design graceful degradation?

**Answer:**

<br><br><br>
