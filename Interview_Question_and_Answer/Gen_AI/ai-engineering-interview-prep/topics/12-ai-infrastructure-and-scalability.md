# 12. AI Infrastructure and Scalability

Source entries are in their original order. Use the space after each heading to draft an answer.

## How do you improve inference speed in production LLM deployments?

**Answer:**

### Optimize the measured critical path, not a single component

Inference speed depends on prompt processing (prefill), autoregressive decoding, queueing, network and provider time, and post-processing. For streaming systems, **time to first token (TTFT)** and inter-token latency matter separately; aggregate request latency can hide whether users wait for prompt ingestion or generation. First establish a representative baseline by model, prompt/output length, concurrency, and workload class.

### A practical optimization sequence

1. **Profile and classify:** Measure queue wait, prefill, decode, network, retrieval, and post-processing; collect p50/p95/p99, token rates, active sequences, GPU memory/utilization, and provider throttling.
2. **Reduce unnecessary work:** Trim redundant context, retrieve only relevant evidence, bound output tokens, cancel abandoned requests, and limit retries/tool loops. Verify quality and grounding after changing context.
3. **Choose suitable serving techniques:** Use continuous batching, efficient KV-cache management, compatible prefix caching, optimized attention/kernels, and tuned concurrency where the workload supports them.
4. **Select a model/runtime fit:** Route eligible simpler tasks to smaller models; benchmark quantization, compilation, optimized runtimes, or speculative decoding on target hardware. Preserve task-quality and safety gates.
5. **Improve admission and scheduling:** Use bounded queues, deadlines, priority classes, and token-aware limits. Batching may raise throughput but can increase latency for interactive requests.
6. **Scale the actual bottleneck:** Add replicas or accelerators only when the constrained resource and quota can scale. Keep capacity warm if startup time dominates, and reserve failover headroom.
7. **Validate in production-like tests:** Benchmark realistic prompt/output distributions, burst and sustained load, and tail latency. Canary changes and retain rollback.

Do not optimize tokens/sec at the expense of correct outputs or user-perceived responsiveness. A serving system can increase aggregate throughput while worsening per-request tail latency.

### Trade-offs, bottlenecks, and capacity assumptions

Larger batches and higher utilization improve throughput but may raise TTFT and queue delay. Smaller models and quantization reduce compute/memory but can lower quality. Caching helps only when work is safely reusable, and added parallelism may hit memory bandwidth or interconnect limits. Model size, hardware, request mix, and SLOs are unspecified, so use workload traces and target-hardware benchmarks rather than generic speedup estimates.

### Concise interview answer

“I start by separating queueing, prefill, decode, network, and post-processing, then profile TTFT, inter-token latency, throughput, memory, and tail behavior by request size. I reduce unnecessary context and work, apply efficient batching/KV-cache/runtime options, and choose model or quantization changes only after quality evaluation. Admission control and scaling must target the actual bottleneck. Every change is canaried against quality, safety, and latency SLOs.”

### Revision summary

| Lever | Validate |
|---|---|
| Prompt/output reduction | Quality, grounding, completeness. |
| Batching/cache/kernels | Throughput, TTFT, tail latency, memory. |
| Model/quantization | Quality, safety, speed, cost. |
| Scheduling/scaling | Queueing, quotas, failover headroom. |
| Measurement | TTFT, inter-token latency, tokens/sec, p95/p99. |

<br><br><br>

## LLM optimization techniques

**Answer:**

### Optimize across model, prompt, runtime, and serving layers

LLM optimization is the coordinated reduction of latency, cost, memory, or energy while preserving required task quality, safety, and reliability. Techniques operate at different layers and should be selected from a measured bottleneck, not applied as a checklist.

### Common technique groups

1. **Prompt/context optimization:** Remove repeated instructions, retrieve relevant passages, summarize history carefully, and set output budgets. Validate that compression does not remove evidence or policy.
2. **Model selection and routing:** Use a smaller or specialized model for tasks where it meets quality thresholds; reserve stronger models for harder cases. Evaluate routing errors and escalation costs.
3. **Quantization and precision:** Use INT8/INT4 or lower-precision floating point where supported to reduce weight/memory bandwidth. Benchmark quality, kernels, and actual speed; lower precision is not automatically faster on every stack.
4. **Parameter-efficient adaptation:** Adapters/LoRA can reduce fine-tuning storage and training work versus updating all weights, although this is primarily an adaptation optimization and may add inference overhead.
5. **Serving and scheduling:** Continuous batching, efficient KV-cache allocation, tensor parallelism, optimized kernels, compilation, and appropriate concurrency can improve utilization or fit.
6. **Caching:** Reuse embeddings, retrieval results, exact responses, or compatible KV prefixes only when freshness, semantics, model version, and tenant authorization allow it.
7. **Speculative decoding:** A draft mechanism proposes tokens for a target model to verify, potentially reducing sequential decode steps when acceptance is high and the runtime supports it.
8. **Operational controls:** Bound retries and agent/tool loops, cancel stale work, prioritize traffic, autoscale on queue/token signals, and monitor spend.

Establish a baseline for cost per successful task, quality, latency percentiles, memory, and energy where relevant. Apply one change at a time where attribution matters, then test on representative and adversarial cases.

### Trade-offs, bottlenecks, and capacity assumptions

Each optimization shifts a trade-off: compression can lose details, quantization can affect quality, batching can add queue delay, caching can serve stale or cross-tenant data, and parallelism can consume communication bandwidth. Workload and resource limits are unspecified, so rank techniques by measured impact and include operational complexity and rollback cost.

### Concise interview answer

“I optimize the bottleneck across prompt/context, model, runtime, and serving: reduce redundant tokens, route tasks to the smallest capable model, benchmark quantization, use batching and efficient KV-cache management, and cache only safe reusable work. Speculative decoding or compilation may help on supported stacks. I compare cost per successful task, quality/safety, TTFT, throughput, and tail latency, because an optimization is not useful if it degrades outcomes.”

### Revision summary

| Layer | Techniques |
|---|---|
| Request | Context pruning, output limits, bounded loops. |
| Model | Routing, quantization, adapters. |
| Runtime | Kernels, compilation, speculation, KV management. |
| Serving | Batching, scheduling, autoscaling. |
| Reuse | Safe response, retrieval, embedding, prefix caches. |

<br><br><br>

## How do you select GPUs for LLM inference?

**Answer:**

### Match memory, compute, bandwidth, and interconnect to the workload

GPU selection for LLM inference is not based on peak FLOPs alone. The model weights must fit (or be sharded), active KV caches consume memory as concurrency and context grow, and decode can be limited by memory bandwidth. Prefill, batching, quantization, serving software, and latency targets change the best choice.

### Selection process

1. **Characterize the workload:** Identify model architecture/parameter count, precision or quantization, prompt and output lengths, concurrency, streaming needs, throughput target, TTFT/TPOT SLOs, and reliability requirements.
2. **Estimate memory:** Account for weights, KV cache, runtime/workspace, activations, fragmentation, and safety headroom. Validate with the serving stack because exact use depends on architecture and configuration.
3. **Assess compute and bandwidth:** Compare accelerator compute at the relevant precision, memory capacity/bandwidth, and support for attention, batching, and cache features. Prefill and decode may stress different resources.
4. **Check interconnect and topology:** If a model or KV workload spans GPUs, measure GPU-to-GPU bandwidth/latency, node topology, and network fabric; communication can erase gains from additional devices.
5. **Verify software fit:** Confirm framework, kernels, drivers, quantization formats, model architecture, and orchestration support. Evaluate operational availability and upgrade compatibility.
6. **Benchmark representative traffic:** Measure quality, TTFT, inter-token latency, throughput, p95/p99, utilization, memory, power, and cost per successful request using the target runtime.
7. **Plan capacity and resilience:** Include peak demand, model replicas, failover/rollout headroom, cold starts, and supply/availability constraints.

For small models, a lower-cost GPU or CPU may be sufficient; a large model may require high-memory accelerators or sharding. These are workload-specific decisions, not fixed parameter-count rules.

### Trade-offs, bottlenecks, and capacity assumptions

Larger-memory GPUs simplify fitting but may cost more; multiple smaller GPUs increase capacity and parallelism but add communication overhead and operational complexity. Newer accelerators can offer higher performance, but only if software kernels and workload utilize them. Model, volume, and budget are unspecified, so test candidate hardware using identical software, request distributions, and SLOs, and compare total cost including power and utilization.

### Concise interview answer

“I select GPUs from the model and serving workload: estimate weights plus KV cache and runtime headroom, then evaluate compute, memory bandwidth, interconnect, precision/kernel support, and cost. I benchmark prefill and decode separately under realistic concurrency and token lengths, measuring TTFT, inter-token latency, throughput, tail latency, and quality. If sharding is required, interconnect matters as much as device count. There is no universal GPU choice without workload data.”

### Revision summary

| Factor | Why it matters |
|---|---|
| VRAM | Weights, KV cache, workspace, headroom. |
| Bandwidth/compute | Prefill and decode performance. |
| Interconnect | Cost of multi-GPU sharding. |
| Software support | Kernels, runtime, precision, model compatibility. |
| Benchmark | SLO, quality, utilization, cost on actual traffic. |

<br><br><br>

## How does a GPU work for Deep Learning?

**Answer:**

### Execute many numerical operations in parallel

A graphics processing unit (GPU) is a parallel processor with many arithmetic units and a memory hierarchy designed to execute large numbers of similar operations. Deep learning workloads contain tensor operations—matrix multiplication, convolutions, attention, and elementwise functions—that can be partitioned across those units.

### From model operation to hardware execution

1. **Represent work as tensor operations:** Frameworks such as PyTorch or TensorFlow build or execute computation graphs over tensors.
2. **Launch kernels:** Each operation is implemented by a GPU kernel, often from optimized libraries or compiler-generated code.
3. **Map work to threads/blocks:** GPU programs launch many threads organized into blocks or analogous execution groups. Threads execute instructions in warps/wavefronts and cooperate through registers, shared memory, and synchronization.
4. **Use memory hierarchy:** Data moves between high-bandwidth device memory (e.g., HBM/GDDR), caches, shared memory, and registers. Reuse and coalesced access reduce expensive transfers.
5. **Exploit specialized hardware:** Matrix units (such as tensor cores on supported NVIDIA GPUs) accelerate supported lower-precision matrix operations; accumulation and precision behavior depend on hardware and kernels.
6. **Synchronize and transfer:** Operations may run asynchronously relative to the CPU, while dependencies, host-device copies, and multi-GPU communication affect end-to-end time.

Training adds forward and backward passes plus optimizer state; inference runs forward computation and, for autoregressive LLMs, repeated decode steps. Performance depends on arithmetic intensity, memory bandwidth, occupancy, launch overhead, and synchronization—not only nominal compute.

### Trade-offs, bottlenecks, and capacity assumptions

GPUs excel at large parallel workloads but may be underutilized for small operations or serial control flow. Moving data between host and device can dominate, while high concurrency can exhaust memory. Lower precision may improve throughput but needs numerical/quality validation. Model size, GPU, and workload are unspecified, so profile kernels, memory traffic, launch overhead, and end-to-end behavior.

### Concise interview answer

“A GPU accelerates deep learning by running many tensor operations in parallel. Framework operations are dispatched as kernels mapped to thread blocks, while data moves through device memory, caches, shared memory, and registers. Specialized matrix hardware accelerates supported precisions. Performance depends on compute, memory bandwidth, data reuse, occupancy, launch overhead, and synchronization, so profiling is necessary to find whether a workload is compute- or memory-bound.”

### Revision summary

| Hardware concept | Role |
|---|---|
| Parallel threads/blocks | Execute many independent tensor elements. |
| Matrix units | Accelerate supported matrix precisions. |
| Memory hierarchy | Supply and reuse tensor data. |
| Kernels | Implement operations on device. |
| Bottlenecks | Compute, bandwidth, launch, transfer, synchronization. |

<br><br><br>

## How do CUDA Kernels work?

**Answer:**

<br><br><br>

## How does a Google TPU work?

**Answer:**

<br><br><br>

## How does an LPU work?

**Answer:**

<br><br><br>

## Estimate the GPU memory needed to serve a 70B model (weights, KV cache, activations). Does it fit on a single 80 GB GPU?

**Answer:**

<br><br><br>

## Do the roofline math: how many tokens/sec can one H100 produce for a 70B model at batch size 1?

**Answer:**

<br><br><br>

## What is model parallelism vs data parallelism in distributed training?

**Answer:**

<br><br><br>

## What is tensor parallelism, and how does it help serve large models?

**Answer:**

<br><br><br>

## What is pipeline parallelism?

**Answer:**

<br><br><br>

## How does continuous batching improve LLM inference throughput?

**Answer:**

<br><br><br>

## What is speculative decoding, and how does it speed up inference?

**Answer:**

<br><br><br>

## How does Medusa (multi-head speculative decoding) work?

**Answer:**

<br><br><br>

## How does EAGLE (feature-level speculative decoding) work?

**Answer:**

<br><br><br>

## What is N-gram Speculation in LLMs, and how does it speed up generation?

**Answer:**

<br><br><br>

## What is KV cache, and how do you manage memory for it?

**Answer:**

<br><br><br>

## What is Paged Attention?

**Answer:**

<br><br><br>

## How does GGUF work?

**Answer:**

<br><br><br>

## How do you optimize inference for edge and mobile deployment?

**Answer:**

<br><br><br>

## What is model quantization (INT8, INT4, FP16, BF16), and how does it affect quality?

**Answer:**

<br><br><br>

## How do you implement auto-scaling for AI workloads?

**Answer:**

<br><br><br>

## What is the role of load balancing in AI serving infrastructure?

**Answer:**

<br><br><br>

## How do you manage GPU memory for serving multiple models?

**Answer:**

<br><br><br>

## What is model sharding, and when would you use it?

**Answer:**

<br><br><br>

## How do you implement request queuing and priority scheduling for AI services?

**Answer:**

<br><br><br>

## What are the cost trade-offs between self-hosted and API-based AI inference?

**Answer:**

<br><br><br>

## How do you handle cold start latency for serverless AI deployments?

**Answer:**

<br><br><br>

## How do you implement model caching to reduce redundant computations?

**Answer:**

<br><br><br>

## What is the difference between synchronous and asynchronous inference, and when do you use each?

**Answer:**

<br><br><br>

## What is FSDP (Fully Sharded Data Parallel), and how does it differ from DeepSpeed ZeRO?

**Answer:**

<br><br><br>

## What are TTFT, TPOT, and throughput, and how do they trade against each other?

**Answer:**

<br><br><br>

## How do you monitor and profile LLM inference in production (TTFT, inter-token latency, GPU utilization)?

**Answer:**

<br><br><br>

## What is model routing at the infrastructure level, and how do you route requests based on complexity and cost?

**Answer:**

<br><br><br>
