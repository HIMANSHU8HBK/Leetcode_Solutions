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

### A kernel is a program launched across GPU threads

A CUDA kernel is a function executed on an NVIDIA GPU by many lightweight threads in parallel. The host (CPU) launches a kernel with a grid of thread blocks; each block contains threads that can cooperate through shared memory and synchronization. Threads are grouped into warps that execute instructions in SIMT (single instruction, multiple threads) fashion, so divergence within a warp can reduce efficiency.

### Execution and memory flow

1. The host prepares device data and launches a kernel with grid/block dimensions.
2. Each thread computes an index from its block and thread coordinates, then processes one or more data elements.
3. Threads access global device memory, caches, shared memory, and registers. Coalesced accesses and data reuse reduce memory traffic.
4. Blocks are scheduled on streaming multiprocessors (SMs); occupancy depends on registers, shared memory, and hardware limits.
5. The kernel completes asynchronously relative to the CPU unless synchronization or dependent operations require waiting.

For deep learning, many operators use hand-tuned CUDA kernels or libraries such as cuBLAS/cuDNN, while compilers can fuse operations to reduce launches and intermediate memory writes. A kernel can be compute-bound, memory-bandwidth-bound, or launch/latency-bound. Optimizing arithmetic alone may not help if memory movement or synchronization dominates.

For example, a vector-add kernel assigns each thread an element index, loads the corresponding values, adds them, and writes the result. The same mapping pattern extends to larger tensor operations, though optimized matrix kernels use more complex tiling and data reuse.

### Trade-offs, bottlenecks, and capacity assumptions

Fusion reduces launch and memory overhead but can increase register pressure or make kernels harder to maintain. Larger blocks and higher occupancy are not automatically faster; memory access patterns, divergence, and resource use matter. GPU architecture, tensor size, and kernel are unspecified, so profile with proper GPU timing tools and benchmark end-to-end execution rather than relying on theoretical occupancy.

### Concise interview answer

“A CUDA kernel is a device function launched over a grid of thread blocks. Threads within blocks cooperate via shared memory and synchronization, and execute in warps on SMs. Performance depends on parallelism, memory coalescing/reuse, registers, shared memory, occupancy, divergence, and launch overhead. Deep-learning libraries provide optimized kernels, while fusion can reduce launches and data movement; profiling determines the real bottleneck.”

### Revision summary

| CUDA concept | Role |
|---|---|
| Kernel | GPU-executed function. |
| Grid/block/thread | Hierarchy for assigning parallel work. |
| Warp/SM | Hardware execution and scheduling units. |
| Memory hierarchy | Global, cache, shared, registers. |
| Optimization | Coalescing, reuse, fusion, measured profiling. |

<br><br><br>

## How does a Google TPU work?

**Answer:**

### A domain-specific accelerator for tensor workloads

A Google Tensor Processing Unit (TPU) is an application-specific accelerator designed to execute machine-learning tensor operations efficiently. TPU generations differ, but a core design idea is specialized matrix-multiplication hardware—often described using systolic arrays—combined with high-bandwidth memory and a software/compiler stack such as XLA. TPUs can be used for training and inference in supported environments.

### High-level execution model

1. A framework expresses computation as operations on tensors.
2. The compiler (for example, XLA) lowers and schedules supported operations for the TPU architecture, including data movement and device execution.
3. Matrix units perform large multiply-accumulate operations in parallel; activations, weights, and intermediate values move through on-chip memory/buffers and high-bandwidth memory.
4. Multiple TPU chips can be connected into a pod or distributed system, with sharding and collectives coordinating larger workloads.
5. Runtime and framework APIs manage execution, synchronization, input pipelines, and device placement.

TPUs are not simply interchangeable with GPUs. Performance depends on model/operator support, tensor shapes, precision, compilation, input pipeline, and interconnect. Workloads with small or irregular operations may not use matrix hardware efficiently.

The systolic-array concept moves data through a grid of processing elements so multiply-accumulate operations can reuse values locally, reducing repeated trips to external memory for suitable matrix workloads.

### Trade-offs, bottlenecks, and capacity assumptions

Specialized matrix hardware can deliver strong throughput for supported dense tensor workloads, but software compatibility, compilation, and data layout can be limiting. Moving data between host and accelerator or across chips can dominate. Availability and cost depend on cloud region and TPU generation. Workload and framework are unspecified, so validate model support and benchmark the complete compile/run path, including input handling and distributed communication.

### Concise interview answer

“A TPU is a machine-learning accelerator optimized for tensor operations, especially matrix multiply-accumulate work. Framework graphs are compiled—often through XLA—into TPU-executable operations that use specialized matrix units, high-bandwidth memory, and, at scale, multi-chip interconnects. Performance depends on supported operators, shapes, precision, compilation, and data movement, so it is not automatically faster than a GPU for every model.”

### Revision summary

| Component | Purpose |
|---|---|
| Matrix hardware | Accelerate dense tensor operations. |
| Compiler/runtime | Lower and schedule framework computation. |
| Memory/interconnect | Feed data and scale across chips. |
| Strength | Supported, sufficiently large tensor workloads. |
| Validation | End-to-end model/operator benchmark. |

<br><br><br>

## How does an LPU work?

**Answer:**

### A specialized architecture aimed at predictable LLM inference

“LPU” commonly refers to Groq’s Language Processing Unit, a processor and software stack designed for low-latency, deterministic execution of neural-network inference. It uses a compiler-scheduled architecture with on-chip resources and explicit data movement to reduce runtime scheduling variability. Exact capabilities and performance are product- and generation-specific; the term should not be treated as a general industry standard for all language-model accelerators.

### High-level operating idea

1. A model graph is compiled and mapped to supported hardware resources.
2. The compiler plans operations and data transfers ahead of execution, rather than relying on the same dynamic scheduling model as a general-purpose GPU.
3. Specialized compute units execute supported operations, with on-chip memory and interconnect moving activations between stages.
4. Serving software manages requests and uses the compiled model to generate outputs.

This design can be attractive for latency-sensitive inference when the model, operator set, sequence sizes, and runtime fit the compiler and hardware. It may be less flexible for unsupported operators, rapidly changing graphs, or workloads that benefit from general GPU programmability.

### Trade-offs, bottlenecks, and capacity assumptions

Predictable scheduling can reduce variance and improve low-latency execution for supported models, but compiler constraints, model compatibility, capacity availability, and deployment ecosystem matter. Throughput and latency depend on batch size, context, model architecture, and provider configuration; published figures may not match application traffic. Hardware, model, and SLO are unspecified, so compare on the same end-to-end workload, including compilation, queueing, token latency, cost, and operational integration.

### Concise interview answer

“An LPU, in the Groq context, is a specialized inference processor whose compiler maps a supported neural-network graph and schedules operations/data movement to make execution predictable. This can benefit low-latency LLM serving, but it is less universally programmable than a GPU and depends on model/operator compatibility and service availability. I would evaluate it with the target model and request distribution rather than infer performance from the processor label.”

### Revision summary

| Aspect | Key point |
|---|---|
| Meaning | Commonly Groq’s Language Processing Unit. |
| Execution | Compiler-planned operations and data movement. |
| Potential fit | Predictable, low-latency supported inference. |
| Constraints | Compatibility, ecosystem, workload shape. |
| Selection | Benchmark end-to-end against alternatives. |

<br><br><br>

## Estimate the GPU memory needed to serve a 70B model (weights, KV cache, activations). Does it fit on a single 80 GB GPU?

**Answer:**

### Estimate weights first, then add runtime and KV-cache memory

Assume “70B” means 70 billion parameters and use decimal parameter counts. Weight memory is approximately parameter count × bytes per parameter:

- **FP16/BF16 (2 bytes):** 70B × 2 ≈ **140 GB** (about 130 GiB).
- **INT8 (roughly 1 byte):** about **70 GB** before scales/metadata and implementation overhead.
- **INT4 (roughly 0.5 byte):** about **35 GB** before quantization scales, metadata, packing, and runtime overhead.

These are weight-only estimates. Serving also needs CUDA/runtime workspaces, temporary activations, allocator/fragmentation headroom, and especially KV cache for active requests.

For a decoder-only transformer, a common KV-cache approximation is:

`KV bytes ≈ 2 × layers × KV heads × head dimension × cached tokens × bytes per element × active sequences`

The factor 2 accounts for keys and values. Exact cache size depends on architecture (including grouped-query attention), context length, concurrency, cache precision, and implementation. As an illustrative—not universal—case, 80 layers, 8 KV heads, head dimension 128, BF16 cache, 8,192 cached tokens, and one sequence gives roughly 2.7 GB; multiple concurrent sequences scale this approximately linearly.

Activations during inference are generally smaller than weights for batch-one decode, but prefill batch/sequence length and workspace can make temporary memory significant. An 80 GB GPU is **not enough for 70B FP16/BF16 weights alone**. INT8 might fit weights narrowly, but leaves limited or insufficient room for KV cache and runtime. INT4 may fit in some configurations, but whether it fits at useful context/concurrency depends on overhead and cache.

### Trade-offs, bottlenecks, and capacity assumptions

Quantization can reduce weight memory but may affect quality and kernel speed. Lower-precision KV cache or grouped-query attention can save memory, but have compatibility/quality implications. Sharding across GPUs adds communication and operational costs. Since architecture, context, batch, and precision are not specified, the estimate is illustrative; calculate from the actual config and reserve realistic headroom instead of treating nominal VRAM as fully available.

### Concise interview answer

“At 70B parameters, FP16/BF16 weights alone need about 140 GB decimal, so they do not fit on one 80 GB GPU. INT8 is roughly 70 GB before overhead and leaves little room for KV cache; INT4 is roughly 35 GB plus metadata, so it may fit depending on context and concurrency. KV cache scales with layers, KV heads, head dimension, token count, precision, and active sequences. Add runtime/workspace and fragmentation; the exact answer needs the model config and serving target.”

### Revision summary

| Memory component | Estimate/driver |
|---|---|
| FP16/BF16 weights | ~140 GB for 70B parameters. |
| INT8 weights | ~70 GB plus scales/overhead. |
| INT4 weights | ~35 GB plus metadata/overhead. |
| KV cache | Layers × KV heads × head dim × tokens × sequences × precision. |
| Other | Runtime, activations, workspace, fragmentation, headroom. |

<br><br><br>

## Do the roofline math: how many tokens/sec can one H100 produce for a 70B model at batch size 1?

**Answer:**

### Use a bandwidth-bound decode estimate, not peak FLOPs alone

For batch-one autoregressive decode, a useful first-order estimate assumes the model weights must be read from high-bandwidth memory for each generated token. If weights are stored at 2 bytes/parameter:

- Weight traffic per token ≈ 70B × 2 bytes = **140 GB** (decimal), ignoring KV-cache traffic, activations, and overhead.
- An H100 SXM is commonly specified with roughly **3.35 TB/s** peak memory bandwidth; actual sustained bandwidth is lower and depends on kernel and workload.
- Ideal bandwidth roofline: 3,350 GB/s ÷ 140 GB/token ≈ **24 tokens/s**.

This is an optimistic theoretical ceiling for that simplified assumption, not a production prediction. An H100 PCIe has a different bandwidth specification, and real serving performance is reduced by imperfect bandwidth utilization, KV-cache reads, synchronization, sampling, runtime overhead, power/thermal limits, and memory contention. Quantization reduces weight bytes per token, but may add metadata and is limited by hardware/kernel throughput.

The FLOP-based view is also informative: a dense 70B model requires on the order of 2 × parameters ≈ 140 GFLOPs per generated token, before attention and other overhead. Dividing by advertised peak compute can yield a much higher number than the bandwidth estimate, which indicates why batch-one decode is often memory-bandwidth-bound. Prefill has different arithmetic intensity and may be compute-bound.

Batching can amortize weight reads across sequences and increase aggregate tokens/sec, but does not guarantee the same per-sequence latency. KV-cache traffic grows with context length and architecture, so long contexts lower the simple weight-only ceiling.

### Trade-offs, bottlenecks, and capacity assumptions

The estimate assumes a 70B dense model, BF16/FP16 weights, batch-one decode, H100 SXM peak bandwidth, and ideal bandwidth use. Different H100 form factors, quantization, grouped-query attention, context, kernel, and runtime change results. Actual sustainable tokens/sec must be benchmarked with the selected serving stack and quality settings; do not present 24 tokens/sec as a guaranteed observed rate.

### Concise interview answer

“For BF16/FP16 batch-one decode, read roughly 140 GB of 70B weights per output token. Using about 3.35 TB/s peak H100 SXM bandwidth gives an ideal ceiling of around 24 tokens/sec, before KV-cache traffic and inefficiency. This is a roofline estimate, not expected production throughput. The FLOP estimate is higher, suggesting decode is bandwidth-limited; batching can improve aggregate throughput, while long context and actual kernel efficiency reduce the rate.”

### Revision summary

| Calculation | Result |
|---|---|
| BF16/FP16 weight bytes | 70B × 2 ≈ 140 GB/token (simplified). |
| H100 SXM peak bandwidth | ~3.35 TB/s (spec-dependent). |
| Ideal roofline | ~3,350 / 140 ≈ 24 tokens/s. |
| Real-world factors | KV traffic, utilization, runtime, context, hardware variant. |
| Interpretation | Upper bound; benchmark actual serving stack. |

<br><br><br>

## What is model parallelism vs data parallelism in distributed training?

**Answer:**

### Replicate the model or split its computation

**Data parallelism** replicates the model on multiple devices and gives each replica a different batch shard. Each device computes gradients; replicas then synchronize gradients (or equivalent state) so they remain consistent. This increases the effective batch and training throughput when the model fits on each device.

**Model parallelism** divides model parameters or computations across devices because a model/layer does not fit on one device or because computation must be distributed. Common forms include tensor parallelism, which splits operations within layers, and pipeline parallelism, which assigns groups of layers to different stages.

### Compare the communication patterns

1. **Data parallel:** Each replica processes independent examples, then performs gradient all-reduce or another synchronization. Communication scales with model/gradient size and can limit scaling at high device counts.
2. **Tensor parallel:** Devices split matrix operations and communicate partial activations/results, often requiring frequent collectives within each layer. Fast interconnects are important.
3. **Pipeline parallel:** Different devices host sequential layer stages; microbatches flow through the stages. It can reduce per-device memory but introduces pipeline bubbles and activation transfers.
4. **Hybrid strategies:** Large training jobs commonly combine data parallelism with tensor and/or pipeline parallelism, plus optimizer/state sharding.

Choose data parallelism when the model fits and there is enough independent data; use model parallelism when memory or compute requires partitioning. Training memory also includes gradients, optimizer states, and activations, so parameter size alone does not determine fit.

### Trade-offs, bottlenecks, and capacity assumptions

Data parallelism is conceptually simple but duplicates model/optimizer memory per replica unless state is sharded; communication and synchronization can limit scaling. Tensor parallelism saves per-device parameter memory but adds frequent communication, while pipeline parallelism can leave devices idle in bubbles. Model size, interconnect, batch, and cluster are unspecified, so benchmark scaling efficiency and memory on the actual topology.

### Concise interview answer

“Data parallelism replicates the model and splits data batches across replicas, synchronizing gradients. Model parallelism splits model parameters or computation across devices; tensor parallelism partitions layers, while pipeline parallelism assigns layer stages. Data parallelism is effective when the model fits per device; model parallelism enables larger models but adds communication and scheduling complexity. Large jobs combine them and often shard optimizer states.”

### Revision summary

| Strategy | What is split? | Main cost |
|---|---|---|
| Data parallel | Examples/batches; model replicated. | Gradient synchronization. |
| Tensor parallel | Layer operations/weights. | Frequent activation collectives. |
| Pipeline parallel | Layer groups/stages. | Pipeline bubbles and stage transfers. |
| Hybrid | Multiple dimensions. | Topology and orchestration complexity. |

<br><br><br>

## What is tensor parallelism, and how does it help serve large models?

**Answer:**

### Partition layer computation across devices

Tensor parallelism (TP) splits tensors and associated operations—typically large linear layers or attention projections—across multiple accelerators. Instead of storing and computing every parameter on one device, each device holds a shard and contributes partial results. The serving system combines or exchanges those results using collectives such as all-reduce or all-gather, depending on the partitioning.

### How it helps inference

1. **Fit model weights:** Sharding reduces the weight memory required on each GPU, allowing a model to span devices when it cannot fit on one.
2. **Distribute computation:** Matrix operations run in parallel across shards, which may improve time-to-compute for sufficiently large layers.
3. **Share runtime state:** KV-cache and activations are distributed according to the model/runtime strategy; memory savings depend on implementation.
4. **Coordinate each layer:** Devices synchronize partial outputs and proceed through transformer layers together. Communication happens repeatedly, so interconnect performance matters.
5. **Scale serving carefully:** The model is typically replicated as a TP group for additional request capacity, while each group serves requests according to batching/scheduling policy.

TP is distinct from pipeline parallelism: TP shards work within layers, while pipeline parallelism places different layer ranges on different stages. Some serving stacks combine them.

### Trade-offs, bottlenecks, and capacity assumptions

TP can fit larger models and distribute compute, but frequent collectives add latency and consume interconnect bandwidth. For batch-one decode, synchronization overhead may offset compute gains; for large layers and high-bandwidth links, it can be worthwhile. Model dimensions, device topology, and context are unspecified, so benchmark tokens/sec, TTFT, tail latency, memory, and scaling efficiency across candidate TP degrees.

### Concise interview answer

“Tensor parallelism shards layer weights and operations across GPUs, so each device stores and computes only part of a large tensor operation. Devices exchange or reduce partial results as the model executes, allowing models to fit beyond one GPU and potentially increasing compute throughput. The trade-off is communication on many layers, making interconnect and batch shape critical. I choose TP degree from memory needs and benchmark end-to-end inference.”

### Revision summary

| Mechanism | Benefit | Cost |
|---|---|---|
| Weight/layer sharding | Fit model across devices. | Distributed setup. |
| Parallel matrix operations | Share compute. | Collective communication. |
| TP group | Serve one model replica. | Interconnect and synchronization latency. |
| Selection | Based on memory and measured scaling. | No universal optimal degree. |

<br><br><br>

## What is pipeline parallelism?

**Answer:**

### Assign sequential model stages to different devices

Pipeline parallelism (PP) partitions a model’s layers into ordered stages, with each stage placed on a separate device or device group. Activations flow forward from stage to stage; during training, gradients flow back in reverse. For inference, a request passes sequentially through all stages, so each device holds only part of the model.

### Microbatches and utilization

During training, a large batch can be divided into microbatches and injected into the pipeline. While one microbatch runs on a later stage, another can run on an earlier stage, increasing device utilization. Scheduling schemes such as fill-drain or interleaved variants trade pipeline bubbles, activation memory, and weight-version consistency.

During autoregressive inference, pipeline execution is more challenging because each token depends on the previous token. Multiple requests or sequences can be interleaved across stages, but a single request still incurs stage-to-stage communication and pipeline scheduling effects.

Partitioning should aim for balanced compute and memory, not equal layer counts alone: some layers or operations may have different costs, and embedding/output layers can be disproportionately large.

### Trade-offs, bottlenecks, and capacity assumptions

PP lowers per-device parameter memory and can scale deep models, but the slowest stage limits throughput and imbalanced layer partitions create idle time. Pipeline fill/drain bubbles reduce utilization, and activation transfers add communication latency. Microbatching may improve throughput while increasing latency or memory. Layer count, batch, topology, and stage speeds are unspecified, so profile stage balance, bubbles, activation memory, and end-to-end token latency before selecting a partition.

### Concise interview answer

“Pipeline parallelism splits sequential layer groups across devices. Activations move forward through stages, and training gradients move backward. Microbatches keep stages busy and reduce per-device model memory, but pipeline bubbles and stage imbalance waste capacity. In autoregressive inference, token dependencies and stage transfers affect latency. It is often combined with tensor parallelism, and the partition should be balanced using measured stage time and interconnect.”

### Revision summary

| Concept | Role |
|---|---|
| Stage | Group of consecutive model layers on devices. |
| Activation transfer | Moves intermediate results between stages. |
| Microbatch | Enables overlapping stage work. |
| Bubble/imbalance | Reduces utilization. |
| Inference impact | Lower per-device memory, added stage latency. |

<br><br><br>

## How does continuous batching improve LLM inference throughput?

**Answer:**

### Admit and retire sequences as generation progresses

Static batching waits for a fixed group of requests and often keeps completed sequences’ slots idle until the slowest request finishes. **Continuous batching** (also called iteration-level or dynamic batching in some systems) updates the active batch at generation-step boundaries: completed requests leave and waiting requests can join, rather than waiting for the entire original batch.

### How it improves serving

1. The scheduler collects requests and performs prompt prefill according to the serving engine’s policy.
2. Active sequences participate in decode iterations, potentially with different prompt and output lengths.
3. When a sequence completes or is cancelled, its resources—especially KV-cache blocks—can be released.
4. New eligible sequences are admitted into available capacity, maintaining more useful work on the accelerator.
5. The engine manages per-sequence state, cache allocation, fairness, and limits while streaming outputs.

This improves utilization under variable-length requests and can raise aggregate tokens/sec. It does not mean every request has lower latency: queueing, batching policy, prefill interference, and resource contention still matter. Some systems also chunk long prefill to reduce its impact on ongoing decode.

### Trade-offs, bottlenecks, and capacity assumptions

Higher batch occupancy can improve throughput but increase queue time, memory pressure, and tail latency. Aggressive admission can starve long or low-priority requests; fairness policies and per-tenant limits are needed. Performance depends on request lengths, KV-cache capacity, scheduler, and hardware. Arrival rates and SLOs are unspecified, so benchmark throughput and TTFT/TPOT together under realistic mixed workloads.

### Concise interview answer

“Continuous batching changes the active batch at decode iterations: finished or cancelled sequences release their slots and new requests can join without waiting for the longest request in a static batch. This keeps hardware busier and improves aggregate throughput for variable-length generation. The scheduler must manage KV-cache memory, queueing, and fairness. Throughput gains can trade against TTFT and tail latency, so I tune against both capacity and per-request SLOs.”

### Revision summary

| Event | Scheduler action |
|---|---|
| Request arrives | Queue/admit based on capacity and policy. |
| Decode iteration | Advance active sequences. |
| Sequence finishes | Release cache/resources. |
| Slot opens | Admit another request. |
| Evaluation | Throughput plus TTFT, TPOT, fairness, memory. |

<br><br><br>

## What is speculative decoding, and how does it speed up inference?

**Answer:**

### Draft several tokens, then verify them with the target model

Speculative decoding accelerates autoregressive generation by using a faster draft model (or another proposal mechanism) to predict multiple candidate tokens, then asking the larger target model to verify them in a more parallel pass. The target accepts a prefix of proposed tokens according to a mathematically designed procedure; if a proposal is rejected, generation continues with a target-model token while preserving the target distribution under the method’s assumptions.

### Basic flow

1. The draft model proposes a short block of tokens conditioned on the current context.
2. The target model evaluates the proposed sequence in parallel or a more efficient pass.
3. Matching/accepted tokens are emitted together; at the first rejection, a corrected token is sampled from the appropriate distribution.
4. The process repeats from the new context.

This reduces the number of sequential target-model decode steps when draft proposals are accepted. It is most useful when drafting is cheap and acceptance is high; it cannot remove the target model’s compute and may provide little benefit for difficult-to-predict text.

### Trade-offs, bottlenecks, and capacity assumptions

The draft model consumes additional compute and memory, and verification may be constrained by target-model bandwidth or runtime support. Low acceptance can erase speedups or reduce throughput under contention. Acceptance depends on model similarity, task, sampling settings, and draft length. Model pair, batch size, and hardware are unspecified, so benchmark end-to-end latency and aggregate throughput while verifying output-distribution correctness.

### Concise interview answer

“Speculative decoding lets a small draft mechanism propose multiple next tokens, then the target LLM verifies them together and accepts a prefix or corrects the first rejected position. This can reduce sequential target-model decode steps while preserving the target distribution when implemented correctly. The gain depends on draft cost and acceptance rate; extra memory and verification work can eliminate it. I benchmark quality-equivalent sampling, latency, throughput, and acceptance on the target workload.”

### Revision summary

| Stage | Work |
|---|---|
| Draft | Propose multiple tokens cheaply. |
| Verify | Target model evaluates proposals. |
| Accept/correct | Emit accepted prefix or sample correction. |
| Benefit | Fewer sequential target decode steps. |
| Limitation | Depends on acceptance, overhead, and runtime. |

<br><br><br>

## How does Medusa (multi-head speculative decoding) work?

**Answer:**

### Predict multiple future tokens from one target-model state

Medusa is a speculative-decoding approach that augments a target language model with additional prediction heads. The base model produces its usual next-token distribution, while the extra heads predict tokens at several future positions from hidden representations. Their proposals can form a small tree of candidate continuations.

### Verification flow

1. The target model computes the current context and hidden state.
2. Medusa heads propose candidate tokens for multiple future positions.
3. A tree-based or otherwise parallel verification pass evaluates candidate paths using the target model.
4. The system accepts a valid prefix under the decoding algorithm and continues from the resulting context.

The intent is to reduce serial decoding steps by predicting and verifying several tokens together. Medusa heads are typically trained or adapted for the target model, and the exact tree construction and acceptance method depend on the implementation. It differs from classic speculative decoding with a separate draft model: the additional predictors are attached to the target model rather than necessarily running a distinct smaller LLM.

### Trade-offs, bottlenecks, and capacity assumptions

Extra heads and candidate verification add compute, memory, and implementation complexity. Gains depend on proposal acceptance, candidate-tree width/depth, batch, and target-model runtime; too many candidates can waste bandwidth. Model, hardware, and workload are unspecified, so benchmark speedup, memory, output-distribution correctness, and throughput under production concurrency.

### Concise interview answer

“Medusa adds multiple lightweight prediction heads to a target LLM so it can propose tokens at several future positions. The serving system builds candidate continuations and verifies them with the target model in parallel, accepting a valid prefix to reduce sequential decode steps. It avoids a separate full draft model, but adds heads and verification overhead; gains depend on acceptance and implementation, so I would benchmark the target workload.”

### Revision summary

| Component | Role |
|---|---|
| Extra heads | Predict tokens at future positions. |
| Candidate tree | Represent possible continuations. |
| Target verification | Check candidates efficiently. |
| Accepted prefix | Advance multiple tokens per round. |
| Main dependency | Acceptance versus verification overhead. |

<br><br><br>

## How does EAGLE (feature-level speculative decoding) work?

**Answer:**

### Speculate in the target model’s feature space

EAGLE is a family of speculative-decoding methods that predicts future tokens using representations (features/hidden states) from the target model, rather than relying only on a separate draft language model. A lightweight draft component predicts a future feature or token sequence conditioned on target-model representations and prior context; the target model then verifies the resulting candidates.

### High-level procedure

1. The target model computes its current hidden representation and next-token distribution.
2. An EAGLE draft module uses available target features and previously proposed tokens to predict candidate continuation information.
3. Candidate tokens are organized into one or more paths or a tree.
4. The target model evaluates candidates in a verification pass.
5. The algorithm accepts a prefix and resumes from the first rejected position, preserving the intended target sampling behavior under the method’s assumptions.

Using target-model features can make the draft predictor more informed than a small independent model, while still making multi-token proposals cheaper than sequential target decoding. Specific EAGLE versions and implementations differ, so the exact training targets and verification details should be taken from the version being used.

### Trade-offs, bottlenecks, and capacity assumptions

The draft module, candidate branching, and verification add memory and compute; poor proposals reduce acceptance and may erase the benefit. The method is tied to target-model representations and runtime support, so portability may be limited. Batch size, prompt length, model, and accelerator are unspecified, so compare EAGLE with baseline and other speculation methods using identical sampling semantics, latency, throughput, and memory.

### Concise interview answer

“EAGLE is feature-level speculative decoding: a lightweight draft component predicts future continuation using hidden features from the target model, then proposes candidate tokens for target-model verification. Accepted prefixes let the server advance multiple tokens per verification round. It differs from a standalone draft LLM by leveraging target features, but still trades proposal acceptance against verification and memory overhead. Performance is implementation- and workload-dependent.”

### Revision summary

| Stage | Function |
|---|---|
| Target features | Provide informative context for drafting. |
| Draft module | Predict future candidates. |
| Verification | Target model checks candidates. |
| Acceptance | Advance a prefix with fewer serial steps. |
| Evaluation | Acceptance, overhead, semantics, latency, throughput. |

<br><br><br>

## What is N-gram Speculation in LLMs, and how does it speed up generation?

**Answer:**

### Reuse likely continuations from token sequences

N-gram speculation is a draft-token technique that looks for repeated token sequences—n-grams—in the current context, prior conversation, or a cache/corpus and proposes likely continuations. A target LLM then verifies those candidate tokens in a more parallel pass. Unlike a learned draft model, the proposal mechanism can be lightweight and may use exact token-sequence matches.

### Basic flow

1. Search recent or indexed token history for a suffix matching the current context.
2. Propose the continuation observed after that n-gram, optionally constructing several candidate paths.
3. Ask the target model to verify proposals.
4. Emit the accepted prefix and continue with target-model generation where the proposal fails.

This works best when the prompt or domain contains repeated phrases, templates, code patterns, or recurring conversation text. It can provide little benefit for novel or highly variable continuations. It does not mean returning a cached response; the target model still verifies proposed tokens.

### Trade-offs, bottlenecks, and capacity assumptions

Lookup is relatively cheap but requires indexing/history management and can propose stale or irrelevant continuations. Longer matches may be more precise but occur less often; shorter matches are common but less predictive. Search and verification overhead can outweigh gains at low repetition or high batch. Data volume, context, and workload are unspecified, so measure match/acceptance rate, memory/index cost, and end-to-end throughput, while ensuring cached histories respect tenant privacy.

### Concise interview answer

“N-gram speculation searches token history or a corpus for a matching sequence and uses its observed continuation as a draft. The target model verifies the proposed tokens together and accepts a prefix, reducing serial decode work when text repeats. It is attractive for templates, code, or repetitive domains, but gains depend on match and acceptance rates; lookup, memory, and privacy costs must be measured.”

### Revision summary

| Step | Purpose |
|---|---|
| Match n-gram | Find a repeated token suffix. |
| Draft continuation | Propose likely next tokens. |
| Verify | Target model validates candidates. |
| Benefit | Fewer sequential decode steps on repetition. |
| Limitation | Low value for novel or diverse text. |

<br><br><br>

## What is KV cache, and how do you manage memory for it?

**Answer:**

### Store attention keys and values from prior tokens

In a decoder transformer, each layer computes key and value tensors for tokens so later tokens can attend to the preceding context. During autoregressive generation, the **KV cache** stores these tensors from previous tokens, avoiding recomputation of the full prefix at every decode step. The cache grows with context length and active sequences and can become a major serving-memory cost.

An approximate memory formula is:

`KV bytes ≈ 2 × layers × KV heads × head dimension × cached tokens × bytes per element × active sequences`

The factor 2 represents keys and values. Actual usage depends on architecture (including grouped-query or multi-query attention), cache layout, sliding-window behavior, tensor parallelism, and runtime metadata.

### Memory-management strategies

1. **Estimate and cap:** Set context, output, concurrency, and per-tenant limits based on measured cache use.
2. **Allocate efficiently:** Use paged/block-based allocation to reduce fragmentation and release blocks when requests finish or are cancelled.
3. **Choose cache precision carefully:** Lower-precision KV storage can save memory, subject to quality and kernel validation.
4. **Reuse compatible prefixes:** Prefix caching can avoid recomputing shared context, but cache keys, model/version, tenant scope, and invalidation must be correct.
5. **Evict or window state:** Use sliding-window attention or eviction policies only when compatible with model behavior and task requirements; discarded context cannot be attended to later.
6. **Observe pressure:** Track allocated tokens/blocks, cache hit rate, eviction, fragmentation, and out-of-memory events.

KV cache is per active sequence state, unlike model weights, which are generally shared by requests on a replica.

### Trade-offs, bottlenecks, and capacity assumptions

Longer contexts and more concurrency increase cache memory approximately with cached tokens and active sequences. Lower precision saves capacity but may affect output quality; aggressive eviction lowers memory but can harm long-context correctness. Prefix reuse improves prefill cost but consumes cache capacity and requires strict isolation. Model configuration, context, and concurrency are unspecified, so calculate with actual layer/KV-head dimensions and reserve runtime headroom.

### Concise interview answer

“The KV cache stores each layer’s prior-token keys and values so autoregressive decoding does not recompute the entire prefix at every step. Its memory scales roughly with layers × KV heads × head dimension × token count × sequences × bytes, with a factor for keys and values. I manage it with context/concurrency limits, efficient block allocation, safe prefix reuse, and optionally lower precision or windowing after validation.”

### Revision summary

| Driver/control | Effect |
|---|---|
| Layers, KV heads, dimensions | Determine cache per token. |
| Context and active sequences | Scale total cache demand. |
| Paged allocation | Reduce fragmentation and release blocks. |
| Precision/windowing | Reduce footprint with possible trade-offs. |
| Prefix reuse | Save repeated prefill when safe and compatible. |

<br><br><br>

## What is Paged Attention?

**Answer:**

### Allocate KV cache in blocks rather than contiguous per-request regions

PagedAttention is an attention/serving approach popularized by vLLM that manages a request’s KV cache in fixed-size blocks (pages). A logical token position maps through a block table to a physical memory block. As a sequence grows, blocks can be allocated incrementally; they do not need one large contiguous allocation reserved in advance.

### Why it helps serving

1. **Reduce fragmentation:** Fixed-size blocks make memory allocation and release more flexible than variable-length contiguous buffers.
2. **Allocate on demand:** Cache blocks are added as tokens arrive, avoiding reservation for a maximum generation length that may never be used.
3. **Support sharing:** Compatible prefix blocks can be shared or reused by multiple requests with appropriate reference tracking and isolation.
4. **Enable high concurrency:** Better cache utilization can allow more active sequences to fit in accelerator memory.
5. **Perform attention through mappings:** During attention, the kernel follows block-table mappings to gather relevant keys/values for a sequence.

PagedAttention does not eliminate the fundamental KV-cache size, model-weight, compute, or bandwidth constraints. Its benefit depends on allocator, kernel, workload, cache reuse, and serving implementation.

### Trade-offs, bottlenecks, and capacity assumptions

Block tables and indirect memory access add metadata and kernel complexity; block size trades internal fragmentation against management overhead. Long contexts still consume many blocks, and memory bandwidth can remain the decode bottleneck. Traffic and model architecture are unspecified, so benchmark block size, cache occupancy, throughput, tail latency, and prefix sharing under representative lengths.

### Concise interview answer

“PagedAttention stores per-sequence KV state in fixed-size blocks and maps logical token positions to physical blocks with a block table. It allocates incrementally, reduces fragmentation, and can support prefix sharing, improving the number of active sequences that fit in memory. It does not make KV state free; long contexts still consume memory and bandwidth. The gains depend on block size, kernels, and workload.”

### Revision summary

| Feature | Benefit |
|---|---|
| Fixed-size KV blocks | Flexible allocation. |
| Block table | Map logical tokens to physical memory. |
| On-demand growth | Avoid maximum-length reservation. |
| Sharing/reference tracking | Reuse compatible prefixes. |
| Limitation | KV capacity and bandwidth still bound serving. |

<br><br><br>

## How does GGUF work?

**Answer:**

### A portable model container for inference runtimes

GGUF is a binary file format used by llama.cpp and compatible tools to package model tensors together with metadata needed to load and run a model. The file can include architecture and hyperparameter information, tensor names and shapes, tokenizer data, special-token IDs, and sometimes chat-template metadata. Tensor data may use different supported data types, including quantized representations.

A loader reads the metadata to identify the model structure and tensor layout, then maps or loads the tensor data into the runtime’s representation. Memory-mapped loading can reduce copying and make loading large files more practical, depending on the operating system, storage, and runtime configuration. Conversion tools commonly transform supported source checkpoints into GGUF and may quantize weights during conversion.

GGUF is a **container format**, not a model architecture or quantization algorithm. A GGUF file can contain different tensor types, and the fact that a file is GGUF does not by itself mean it is quantized, lossless, or compatible with every runtime. The runtime must support the model architecture, tensor types, and any required operations.

### Practical workflow

1. Select a checkpoint and verify its license and architecture support in the intended runtime.
2. Convert the checkpoint to GGUF with a compatible conversion tool, preserving required tokenizer and model metadata.
3. If appropriate, choose a supported quantization type during conversion and validate the resulting artifact.
4. Load it in the target runtime, inspect memory use, and test prompts, tokenization, chat formatting, and generation quality.
5. Pin the model revision, conversion options, and runtime version so the artifact is reproducible.

### Trade-offs, bottlenecks, and capacity assumptions

Quantized GGUF files can reduce storage and memory, but quality and speed depend on quantization type, model, hardware kernels, and workload. Conversion can introduce incompatibilities or metadata errors; validate outputs rather than assuming that a successful conversion guarantees correct behavior. Model size, device memory, and runtime are unspecified, so benchmark load time, resident memory, tokens/sec, and representative task quality on the deployment hardware.

### Concise interview answer

“GGUF is a model container used by llama.cpp-compatible inference runtimes. It stores tensor data plus metadata such as architecture, tensor layout, and tokenizer information, and supports multiple tensor types, including quantized ones. Conversion tools create the artifact, and a compatible loader maps or loads it for inference. GGUF itself is neither a model nor a quantization method, so I verify architecture/runtime support and benchmark quality, memory, and speed.”

### Revision summary

| Element | Purpose |
|---|---|
| Tensor data | Store model parameters in supported types. |
| Metadata | Describe architecture, tensors, tokenizer, and related configuration. |
| Conversion | Package a supported checkpoint, optionally quantizing it. |
| Runtime | Load and execute compatible artifacts. |
| Key caveat | Container format does not guarantee quantization or universal compatibility. |

<br><br><br>

## How do you optimize inference for edge and mobile deployment?

**Answer:**

### Optimize for device limits, not just model size

Edge and mobile inference must fit within constrained memory, compute, battery, thermal, and storage budgets while meeting the product’s latency and quality requirements. I begin by defining the on-device use case: required tasks, supported devices, offline needs, privacy boundaries, acceptable response time, and whether a cloud fallback is allowed.

### A practical optimization sequence

1. **Choose the smallest capable model:** Evaluate compact models, distillation, task-specific models, or a hybrid that delegates only difficult requests.
2. **Reduce model footprint:** Test weight quantization and, where supported, activation/KV-cache quantization. Consider pruning or structured sparsity only when the runtime can exploit it efficiently.
3. **Use device-appropriate execution:** Select a runtime and kernels that target available CPU, GPU, or neural accelerator backends; validate delegate coverage and avoid costly CPU/GPU transfers.
4. **Bound runtime state:** Set context and output limits, manage KV cache, and avoid holding multiple model copies. Stream output when it improves perceived latency.
5. **Optimize the artifact and startup path:** Package only required assets, use supported memory mapping or lazy loading, and consider keeping a model warm when memory and battery permit.
6. **Measure on real devices:** Profile cold start, time to first token, generation speed, peak memory, energy, temperature, and quality across representative device tiers and long-running sessions.
7. **Protect the user:** Keep sensitive data on-device where required, secure model files and logs, and make cloud fallback behavior explicit.

The right design may combine local inference for common/private/low-latency tasks with remote inference for requests that need greater capability. That introduces network availability, consent, data handling, and cost considerations.

### Trade-offs, bottlenecks, and capacity assumptions

More aggressive quantization or smaller models can reduce memory and energy but may degrade task quality. A model that fits in RAM may still be too slow or thermally unsustainable; accelerator support varies by device and operator. Device fleet and workload are unspecified, so test a representative hardware matrix, including sustained performance after thermal throttling rather than relying only on desktop benchmarks.

### Concise interview answer

“I start with device and product constraints, then select the smallest model that meets quality needs, quantize or distill it, and use optimized kernels for the device’s CPU/GPU/NPU. I bound context and KV memory, minimize startup and data movement, and benchmark latency, memory, energy, thermals, and quality on real devices. A hybrid cloud fallback can expand capability, but must be explicit about connectivity, privacy, and cost.”

### Revision summary

| Area | Decision or measurement |
|---|---|
| Model | Compact, distilled, task-specific, or hybrid. |
| Runtime | Device backend, kernel coverage, and transfer cost. |
| Memory | Quantization, context limits, and KV management. |
| Performance | Cold start, latency, throughput, energy, and thermals. |
| Product constraints | Offline operation, privacy, and fallback policy. |

<br><br><br>

## What is model quantization (INT8, INT4, FP16, BF16), and how does it affect quality?

**Answer:**

### Represent model values with fewer bits

Quantization maps weights and sometimes activations or KV-cache values from a higher-precision representation to a lower-bit representation. Lower precision can reduce model memory and data movement and may improve throughput when the hardware and kernels support the format efficiently. It is not automatically faster on every device or workload.

- **FP16:** 16-bit floating point with more mantissa precision but a narrower exponent range than BF16.
- **BF16:** 16-bit floating point with an exponent range similar to FP32 and fewer mantissa bits than FP16; often useful for stable training and inference on supported accelerators.
- **INT8:** 8-bit integer representation, usually with scaling/zero-point or related quantization parameters. It can substantially reduce weight storage versus FP16/FP32.
- **INT4:** 4-bit weight representation, often with group-wise scales and specialized kernels. It can reduce weight memory further, but is more sensitive to quantization choices and hardware implementation.

These are broad categories: formats, scaling schemes, grouping, and whether weights/activations are quantized vary by implementation. For example, weight-only quantization leaves some computation at higher precision.

### Quantization workflow and quality checks

Post-training quantization (PTQ) converts an existing model, sometimes using representative calibration data to estimate activation ranges. Quantization-aware training (QAT) exposes training to quantization effects and can recover quality, at the cost of training complexity. I compare candidate formats against a full-precision or trusted baseline using task-specific quality, safety, and regression tests, as well as latency and memory on the target hardware.

Quality impact depends on model architecture, task, calibration data, quantization granularity, and which tensors are quantized. Lower-bit weights may disproportionately affect rare tokens, reasoning, multilingual tasks, or sensitive outputs; aggregate benchmarks alone can hide regressions.

### Trade-offs, bottlenecks, and capacity assumptions

Lower bit width reduces nominal tensor storage, but scales, padding, runtime buffers, and KV cache add overhead. Dequantization or unsupported kernels can erase speed gains. FP16 versus BF16 is a numeric-range/precision choice, not a simple quality ranking; use the format best supported by the model and hardware. Model and workload are unspecified, so measure end-to-end memory, latency, throughput, and per-task quality for each candidate.

### Concise interview answer

“Quantization stores weights, activations, or cache values at lower precision to reduce memory traffic and sometimes improve inference speed. FP16 and BF16 are 16-bit floating-point formats with different precision/range characteristics; INT8 and INT4 use fewer bits and require quantization scales, with INT4 generally more quality-sensitive. I choose based on hardware support and validate representative quality, safety, memory, and latency—bit width alone does not guarantee a speedup.”

### Revision summary

| Format | Typical characteristic |
|---|---|
| FP16 | 16-bit float; higher mantissa precision than BF16. |
| BF16 | 16-bit float; wider exponent range, fewer mantissa bits. |
| INT8 | Lower storage with quantization parameters. |
| INT4 | Smaller weight representation; more sensitive to method and kernels. |
| Validation | Compare real task quality and target-runtime performance. |

<br><br><br>

## How do you implement auto-scaling for AI workloads?

**Answer:**

### Scale on service objectives and inference-specific signals

AI workloads have costs and delays that ordinary CPU-only autoscaling can miss: model loading is expensive, GPU capacity is limited, prompt lengths vary, and active sequences hold KV-cache memory while generating. I define service objectives first—for example, TTFT and inter-token latency percentiles, availability, queue delay, and error rate—then autoscale replicas or workers against both demand and capacity.

### Implementation approach

1. **Instrument the serving path:** Track request rate, input/output token rates, active sequences, queue depth and age, GPU memory/cache occupancy, utilization, TTFT, inter-token latency, and failures.
2. **Forecast demand and capacity:** Estimate sustainable token throughput and memory per replica from representative load tests; include model size, context lengths, batching, and cache use.
3. **Use multiple scaling signals:** Combine queue depth/oldest-request age and token demand with GPU utilization, memory pressure, and latency objectives. CPU utilization alone is usually insufficient.
4. **Scale with hysteresis:** Set thresholds, cooldowns, minimum/maximum replicas, and scale-up/scale-down policies to avoid oscillation. Scale up quickly enough to protect latency; scale down only after load and in-flight work have drained.
5. **Plan provisioning and warm capacity:** GPU provisioning and model loading can take time. Use warm pools, preloaded replicas, or scheduled capacity for predictable peaks; scale-to-zero only when cold-start latency is acceptable.
6. **Drain safely:** Stop assigning new work to a replica before shutdown, allow or explicitly cancel active generations, and deregister it from routing.
7. **Test failure and surge behavior:** Validate quota exhaustion, cold starts, model-download bottlenecks, uneven prompt lengths, and fallback behavior.

Autoscaling should not replace admission control. When demand exceeds the allowed capacity or supply, queue with bounded wait, shed lower-priority work, or return a clear overload response rather than letting memory pressure trigger cascading failures.

### Trade-offs, bottlenecks, and capacity assumptions

More warm GPUs reduce scale-up delay but increase idle cost; scale-to-zero saves cost but adds cold starts. GPU metrics can be misleading if high utilization is healthy while queueing and latency are within targets. Model sizes, provisioning times, and service objectives are unspecified, so derive thresholds from measured capacity and test scale policies under realistic bursts.

### Concise interview answer

“I autoscale against user-facing latency and queued token demand, not CPU utilization alone. I instrument TTFT, inter-token latency, queue age, active sequences, GPU memory/KV pressure, and token throughput; then use load-tested per-replica capacity, bounded scaling policies, warm capacity for slow GPU startups, and graceful draining. Admission control handles demand beyond capacity, and I validate behavior during bursts and cold starts.”

### Revision summary

| Control | Purpose |
|---|---|
| SLOs and queue signals | Trigger scaling based on user impact and demand. |
| Token/cache metrics | Capture inference-specific resource pressure. |
| Warm pools and hysteresis | Balance startup delay, stability, and cost. |
| Safe draining | Avoid interrupting in-flight generations. |
| Admission control | Prevent overload when scaling cannot meet demand. |

<br><br><br>

## What is the role of load balancing in AI serving infrastructure?

**Answer:**

### Route work to healthy capacity while protecting latency

Load balancing distributes inference requests across serving replicas so that no single worker becomes a bottleneck and the service can use available accelerator capacity. A basic implementation routes only to healthy replicas, but AI serving benefits from considering more than request count: prompts and generated outputs vary greatly in token count, active generations occupy memory for different durations, and prefill and decode can have different resource profiles.

### Design considerations

1. **Health and readiness:** Remove replicas that are unhealthy, overloaded, still loading a model, or unable to serve the requested model/version.
2. **Capacity-aware routing:** Use active sequences, queued tokens, KV-cache occupancy, measured throughput, and latency—not just round robin—to avoid sending work to a saturated GPU.
3. **Preserve request state:** Route each generation’s continuation to the worker holding its KV cache unless the serving system can transfer or reconstruct that state. Session affinity can help prefix reuse but should not create long-lived hotspots.
4. **Account for request shape:** Consider estimated prompt length, output limits, model, and priority so a single long request does not unfairly consume a small worker’s capacity.
5. **Support streaming and cancellation:** Maintain the connection for streaming responses, propagate client cancellations, and release worker resources promptly.
6. **Handle overload explicitly:** Apply bounded queues, deadlines, retries only when safe, and load shedding or clear rejection when capacity is exhausted.
7. **Observe outcomes:** Compare per-replica queueing, token throughput, TTFT, inter-token latency, errors, and utilization to identify routing imbalance.

For larger systems, routing may first select a model or hardware pool and then select a replica within that pool. The router should avoid blind retries that duplicate expensive work or produce multiple generations.

### Trade-offs, bottlenecks, and capacity assumptions

More sophisticated scheduling can improve utilization but requires timely, accurate metrics and adds router complexity. Sticky routing can improve cache reuse but reduce fairness; global routing improves balancing but may lose reusable KV state. Region, model, and workload details are unspecified, so compare policies under realistic request-length distributions and failures, measuring tail latency and cache effects.

### Concise interview answer

“Load balancing routes requests among healthy, compatible inference replicas while respecting their real capacity. Because request lengths and decode times vary, I use queue/token demand, active sequences, KV-cache pressure, and latency rather than request count alone. I preserve a generation’s KV locality, support streaming and cancellation, and use bounded queues and safe overload behavior. I measure tail latency, throughput, and per-replica imbalance to tune the policy.”

### Revision summary

| Responsibility | AI-serving concern |
|---|---|
| Health routing | Model/version readiness and replica health. |
| Capacity balancing | Token work, active sequences, cache, and latency. |
| State locality | KV cache and prefix reuse. |
| Overload control | Deadlines, bounded queues, safe retries, shedding. |
| Validation | Tail latency, throughput, and imbalance. |

<br><br><br>

## How do you manage GPU memory for serving multiple models?

**Answer:**

### Treat GPU memory as a shared, capacity-planned resource

Serving multiple models on one GPU requires accounting for more than model weights. Each model may also need runtime workspaces, temporary activations, kernels or graph-capture buffers, and per-request KV cache. I first establish the device’s usable memory and the measured peak footprint of each model under its expected context and concurrency.

### Practical management strategy

1. **Right-size placement:** Keep only models that fit with headroom for runtime allocations and worst-case KV cache. Use smaller or quantized variants when quality permits.
2. **Load selectively:** Keep frequently used models resident; load infrequent models on demand only when the load/eviction delay is acceptable. Avoid unbounded copies of weights across workers.
3. **Partition or schedule:** Use separate GPU pools for large or latency-sensitive models, or use supported memory partitioning where isolation and predictable capacity matter. Avoid assuming that nominally free memory guarantees safe co-residency.
4. **Control request state:** Bound context lengths, active sequences, and output tokens. Enforce per-model concurrency limits based on KV-cache demand.
5. **Use explicit eviction:** Track model usage and unload or evict less-used models before memory pressure becomes an out-of-memory failure. Coordinate with routing so requests are not sent to an unloading model.
6. **Observe and test:** Monitor allocated/reserved memory, KV-cache occupancy, load failures, eviction rate, utilization, and latency. Test simultaneous peak traffic and model switching, not just each model in isolation.

If models share compatible weights or prefixes, reuse can reduce redundant storage or computation, but only where the runtime supports it and correctness and tenant isolation are preserved.

### Trade-offs, bottlenecks, and capacity assumptions

Co-location can improve utilization and reduce fleet cost, but memory contention, model loading, cache eviction, and interference may increase tail latency. Keeping all models warm improves readiness but consumes memory; unloading saves space but adds startup time and I/O. Model sizes, GPU capacity, and traffic are unspecified, so use measured peak footprints and reserve operational headroom rather than packing to the advertised device limit.

### Concise interview answer

“I budget weights, runtime buffers, and per-request KV cache for every co-resident model, then set context and concurrency limits with explicit headroom. I keep hot models resident, load or evict cold models through routing-aware policies, and isolate large or latency-sensitive models when contention is unacceptable. I validate peak concurrent traffic and monitor memory, evictions, load failures, and tail latency; nominal free memory alone is not a safe capacity plan.”

### Revision summary

| Memory consumer/control | Serving implication |
|---|---|
| Weights and runtime buffers | Per-model baseline and transient usage. |
| KV cache | Grows with active sequences and context. |
| Residency/eviction | Trades readiness against capacity. |
| Concurrency limits | Bound variable request memory. |
| Headroom and monitoring | Reduce OOM risk and reveal contention. |

<br><br><br>

## What is model sharding, and when would you use it?

**Answer:**

### Split model state across devices

Model sharding partitions model parameters—and, depending on the parallelism strategy, associated computation or optimizer state—across multiple devices. It is useful when a model or its runtime state cannot fit on one accelerator, or when parallel execution is needed to meet throughput or latency goals.

Common approaches include:

- **Tensor parallelism:** Split individual layer operations, such as weight matrices, across devices. Devices communicate during layer execution; this is commonly used to serve a model that is too large for one GPU.
- **Pipeline parallelism:** Assign groups of layers to different devices and pass activations between stages. It can distribute model capacity but may leave stages idle unless work is pipelined effectively.
- **Fully sharded data parallelism:** Shard parameters and often gradients/optimizer state across devices for training, gathering parameter shards as needed. This is primarily a distributed-training technique rather than the usual inference serving strategy.

### How to choose

I first determine what must be distributed: weights for capacity, computation for throughput, or training state. Then I select a supported sharding scheme, topology, and framework; map communication-heavy partitions to fast interconnects; and benchmark end-to-end behavior. In inference, account for per-request KV cache and communication as well as weights. In training, also account for gradient, optimizer, and activation memory.

Sharding is distinct from data parallelism: data parallel replicas each process separate inputs with model copies (or synchronized shards), while model-parallel approaches divide a model’s computation/state. Frameworks may combine these strategies.

### Trade-offs, bottlenecks, and capacity assumptions

Sharding makes larger models feasible but introduces communication, synchronization, placement, and operational complexity. Slow links or imbalanced partitions can dominate latency; adding devices does not guarantee linear throughput scaling. Model dimensions, device count, and interconnect are unspecified, so measure fit, communication time, utilization, and request-level latency on the actual topology.

### Concise interview answer

“Model sharding distributes model parameters or computation across devices. Tensor parallelism splits layer operations, pipeline parallelism splits layers into stages, and FSDP-style sharding is commonly used to distribute training state. I use it when a model or state does not fit on one device or when scaling justifies the communication cost. The right method depends on training versus inference, device topology, memory needs, and measured end-to-end performance.”

### Revision summary

| Strategy | Typical partition |
|---|---|
| Tensor parallelism | Layer tensors/operations across devices. |
| Pipeline parallelism | Layer groups across stages. |
| FSDP-style sharding | Training parameters and related state. |
| Main benefit | Capacity and/or parallel computation. |
| Main cost | Communication and orchestration overhead. |

<br><br><br>

## How do you implement request queuing and priority scheduling for AI services?

**Answer:**

### Queue with explicit limits, deadlines, and fairness

Inference requests have variable cost: prompt processing, generated-token count, model choice, and active KV cache all affect service time and capacity. I use a bounded queue and admission control rather than accepting unlimited work, then schedule requests according to product objectives and resource availability.

### Design the scheduler

1. **Define classes and guarantees:** For example, interactive, batch, and background work, with documented latency targets and allowed preemption or cancellation behavior.
2. **Estimate work:** Track model, prompt tokens, requested output limit, and current worker load. Token-based or capacity-aware estimates are more useful than request count alone.
3. **Set deadlines and bounds:** Apply queue length, queue-age, request timeout, and per-tenant concurrency limits. Reject or shed work clearly when its deadline cannot reasonably be met.
4. **Choose a policy:** Use weighted fair queuing, deficit/token-based scheduling, or aging to balance priority with fairness. Strict priority alone can starve lower classes; aging or reserved capacity can mitigate that.
5. **Integrate with batching:** Form compatible batches while respecting maximum wait time, model, sequence, and memory limits. Do not delay urgent work indefinitely to build a larger batch.
6. **Handle cancellations and retries:** Remove cancelled requests, release reservations, and make retries bounded and idempotent where possible so overload does not multiply.
7. **Observe behavior:** Measure queue depth and age by class/tenant, rejection rate, TTFT, completion latency, token throughput, and starvation.

Streaming requests should receive prompt first-token service, while batch jobs may tolerate longer queues and benefit from higher-throughput scheduling. Priority should be tied to a clear policy and protected from untrusted client-supplied values.

### Trade-offs, bottlenecks, and capacity assumptions

Higher priority improves some users’ latency but can increase others’ wait; larger batches may improve throughput while adding queue delay and memory pressure. Queueing smooths bursts but cannot fix sustained demand above capacity. Service objectives and workload mix are unspecified, so load-test burst and sustained overload, tune bounds to latency budgets, and expose explicit overload outcomes.

### Concise interview answer

“I use bounded queues, deadlines, and admission control, then schedule by service class and estimated token/resource cost rather than request count alone. Weighted fairness or aging prevents strict-priority starvation, while compatible requests can batch subject to a maximum wait and KV-memory limits. I propagate cancellation, bound retries, and monitor queue age, per-class latency, throughput, rejections, and starvation.”

### Revision summary

| Mechanism | Purpose |
|---|---|
| Bounded queue and deadlines | Limit latency and memory exposure. |
| Cost-aware scheduling | Account for model and token workload. |
| Fairness/aging | Prevent starvation across priorities. |
| Batch wait limit | Balance throughput with responsiveness. |
| Admission control | Handle demand beyond sustainable capacity. |

<br><br><br>

## What are the cost trade-offs between self-hosted and API-based AI inference?

**Answer:**

### Compare total cost at the required service level

Self-hosted inference runs on infrastructure the organization provisions and operates. API-based inference uses a provider’s managed model endpoint, typically charging by tokens, requests, or provisioned capacity. The lower unit price is not enough to determine which is cheaper: compare total cost for the workload, quality, latency, availability, and compliance requirements.

### Cost model and decision process

For **self-hosting**, include accelerator purchase or rental, utilization and idle capacity, networking, storage, power, redundancy, deployment engineering, on-call operations, model updates, and observability. Costs are often more fixed; high and predictable utilization can spread infrastructure cost across many tokens, but spare capacity and low utilization still cost money.

For **API inference**, include input/output token rates, premium models or features, retries, rate-limit workarounds, data transfer, and any reserved-capacity or minimum commitments. It reduces infrastructure operations and enables rapid scaling, but variable usage, long outputs, repeated calls, or provider price changes can make spend unpredictable. Also account for provider limits, regional availability, data handling, and switching costs.

I estimate request and token distributions, benchmark equivalent quality and latency, project normal and peak demand, and calculate cost per successful task—not only cost per token. A hybrid design can route routine traffic to a lower-cost model or self-hosted pool and use a stronger managed endpoint for selected requests, with explicit fallback and privacy controls.

### Trade-offs, bottlenecks, and capacity assumptions

Self-hosting offers control and may be economical at sustained scale, but incurs capital, operational, and utilization risks. APIs reduce operational burden and may be preferable for low or variable volume, but create vendor dependency and usage-based cost exposure. Model choice, traffic, and regional pricing are unspecified, so use current quotes and measured utilization; include capacity for peaks and outages rather than comparing idealized rates.

### Concise interview answer

“I compare total cost per successful request at equivalent quality and SLOs. Self-hosting has fixed accelerator, operations, and idle-capacity costs but offers control and can work well at high sustained utilization. APIs avoid most infrastructure operations and scale easily, but have variable token charges, quotas, and provider dependency. I model actual prompt/output distributions, peak capacity, reliability, compliance, and switching costs; a hybrid can balance them.”

### Revision summary

| Cost factor | Self-hosted | API-based |
|---|---|---|
| Capacity cost | Provisioned hardware and idle headroom. | Usage pricing or reserved commitments. |
| Operations | Owned by the serving team. | Mostly provider-managed. |
| Scaling | Requires capacity planning/provisioning. | Usually easier, subject to quotas. |
| Control | Greater deployment and data control. | Provider and contract constraints. |
| Best comparison | Total cost per successful task at target SLO. | Total cost per successful task at target SLO. |

<br><br><br>

## How do you handle cold start latency for serverless AI deployments?

**Answer:**

### Reduce startup work and make cold-start behavior explicit

An AI serverless cold start can include scheduling a GPU, downloading or mounting model files, initializing the runtime and kernels, allocating memory, and warming compilation or caches. These costs can be much larger than for a small stateless function, so I measure each phase and decide whether the product can tolerate a cold path.

### Mitigation options

1. **Keep a warm minimum:** Maintain a small number of ready, model-loaded instances for interactive or predictable traffic. This improves readiness but incurs idle cost.
2. **Pre-stage artifacts:** Keep versioned model files on fast local or shared storage, use container/image layers effectively, and avoid downloading large artifacts on every start.
3. **Initialize efficiently:** Defer nonessential work, reuse compiled kernels or runtime artifacts when safe, and load only the required model. Ensure readiness is not reported until inference can actually run.
4. **Scale ahead when possible:** Use schedules or demand forecasts to create capacity before expected peaks; account for GPU provisioning and model-load time in the lead window.
5. **Use explicit warm-up:** Send representative warm-up inputs only when needed to initialize kernels/caches, and do not route user requests until health and model checks pass.
6. **Provide a fallback:** Queue briefly, use a smaller already-warm model, or route to a managed endpoint if the latency and privacy policy permits.
7. **Control scale-to-zero:** Use it for workloads that tolerate startup delays, such as asynchronous jobs; avoid it for strict interactive latency unless an alternate warm path exists.

Track cold-start frequency and duration by phase, along with warm capacity cost, queueing, and user-facing tail latency. Avoid masking startup failures as successful empty responses.

### Trade-offs, bottlenecks, and capacity assumptions

Warm pools and preloaded models reduce latency but consume scarce GPU memory and money. Shared storage saves local disk but may become a download bottleneck during fleet-wide scale-out. A fallback can improve availability but may change quality, cost, or data handling. Model size, platform, and latency target are unspecified, so profile the full provisioning path and choose warm capacity based on measured cold-start percentiles and demand.

### Concise interview answer

“I profile the cold path—GPU provisioning, model artifact access, runtime initialization, memory allocation, and warm-up—then reduce repeated work with staged artifacts and efficient initialization. For latency-sensitive traffic, I keep a warm minimum or scale ahead; scale-to-zero is more appropriate for tolerant asynchronous workloads. I expose readiness only after the model is usable and define a policy-compliant fallback, measuring cold-start percentiles and warm-capacity cost.”

### Revision summary

| Technique | Benefit | Cost or caveat |
|---|---|---|
| Warm instances | Lower interactive startup latency. | Idle GPU expense. |
| Pre-staged artifacts | Avoid repeated large downloads. | Storage/version management. |
| Predictive scaling | Capacity ready before a peak. | Forecast and provisioning uncertainty. |
| Warm-up/readiness checks | Avoid routing to unready models. | Startup work and implementation care. |
| Scale-to-zero | Lower idle cost. | Cold-start delay on demand. |

<br><br><br>

## How do you implement model caching to reduce redundant computations?

**Answer:**

### Cache reusable artifacts or computation with exact validity rules

“Model caching” can refer to several different optimizations, so I first identify the repeated work:

- **Artifact/weight caching:** Keep model files or loaded weights available across deployments or requests to avoid repeated downloads and initialization.
- **Prefix/KV caching:** Reuse prefill computation and cached attention state for an identical prompt prefix when the serving runtime supports it.
- **Response caching:** Return a prior result for an equivalent request when the application’s correctness, freshness, and privacy requirements allow it.
- **Embedding or feature caching:** Reuse deterministic outputs from a fixed model and preprocessing pipeline for repeated inputs.

### Safe implementation

1. Define the cache unit and exact equivalence rules; include model/version, tokenizer, preprocessing, prompt/template, decoding parameters, and relevant tenant or permission scope in the key.
2. Use bounded storage with TTL, LRU or workload-appropriate eviction, and explicit invalidation on model, prompt, or policy changes.
3. Prevent cache stampedes with request coalescing or single-flight computation for identical misses.
4. Ensure authorization is checked before returning cached data. Isolate tenants when prompts, outputs, or prefixes may contain private information.
5. Cache only deterministic or semantically safe outputs. For stochastic generation, decide whether caching is allowed and include all sampling settings and seeds if exact replay is intended.
6. Measure hit rate, avoided compute, lookup latency, storage cost, stale-hit rate, and correctness/privacy incidents.

For prefix caching, token-level prefix identity and model/runtime compatibility matter; for response caching, semantic similarity alone is not proof that two requests are interchangeable.

### Trade-offs, bottlenecks, and capacity assumptions

Caches can lower latency and compute but consume memory/storage, add lookup and invalidation complexity, and risk stale or cross-tenant results. Low-reuse workloads may pay overhead without enough hits. Request patterns, determinism, and data sensitivity are unspecified, so start with a narrowly defined cache and validate exactness, isolation, freshness, and cost benefit before expanding.

### Concise interview answer

“I identify whether the repeated work is model loading, shared-prefix prefill, embeddings, or a full response, then choose the corresponding cache. Keys must include every factor that affects correctness—model and prompt versions, preprocessing, generation settings, and security scope. I use bounded TTL/eviction, explicit invalidation, stampede control, and authorization checks, then measure hit rate and compute saved against storage, freshness, and privacy risk.”

### Revision summary

| Cache type | Reused work | Key concern |
|---|---|---|
| Artifact/weight | Download and initialization | Version and runtime compatibility |
| Prefix/KV | Shared prompt prefill | Exact token prefix and tenant isolation |
| Response | Full result | Request equivalence, freshness, authorization |
| Embedding/feature | Deterministic transformation | Model and preprocessing version |

<br><br><br>

## What is the difference between synchronous and asynchronous inference, and when do you use each?

**Answer:**

### Choose the interaction contract to match the workload

In **synchronous inference**, the caller waits for the result on the same request/response interaction. The service may stream generated tokens while keeping that interaction open; streaming does not make the job asynchronous. This fits interactive chat, inline assistance, and other use cases where the caller needs an immediate answer and the duration fits connection and gateway timeouts.

In **asynchronous inference**, the caller submits work and receives an acknowledgement or job identifier. The service processes it independently, and the caller retrieves the result later or receives a callback/event. This fits long-running generation, bulk document processing, evaluations, and workloads that need durable retries or can tolerate delayed completion.

### Design the lifecycle

For synchronous requests, enforce deadlines, stream when useful, propagate cancellation, and avoid retrying non-idempotent work blindly. For asynchronous jobs, persist the request and status, make submission idempotent, track queued/running/succeeded/failed/cancelled states, define retry and dead-letter behavior, and provide polling or callback delivery with authorization. Both paths need admission control, observability, and a clear overload response.

An API can expose both modes: a short request may complete synchronously, while a long job returns a job handle. The transition must be explicit so clients know whether they have a final result or only an accepted task.

### Trade-offs, bottlenecks, and capacity assumptions

Synchronous interaction is simple and offers low perceived latency but ties up connections and is vulnerable to timeout boundaries. Asynchronous processing improves resilience and accommodates longer jobs, but adds durable queues, state management, delivery semantics, and client complexity. Request duration and client constraints are unspecified, so choose based on end-to-end deadlines, cancellation needs, and expected job volume.

### Concise interview answer

“Synchronous inference returns the result in the current interaction, often token-streamed, and is best for latency-sensitive requests that fit the client’s deadline. Asynchronous inference acknowledges a durable job and returns its result later, which suits long-running or batch work. I choose based on latency and lifecycle requirements, then add deadlines and cancellation for sync, or idempotency, job state, retries, and result delivery for async.”

### Revision summary

| Mode | Client behavior | Typical fit |
|---|---|---|
| Synchronous | Waits for result or stream | Interactive, deadline-bounded inference |
| Asynchronous | Submits job, retrieves result later | Long-running and batch inference |
| Shared requirements | Admission control, status, observability | Safe operation under load |

<br><br><br>

## What is FSDP (Fully Sharded Data Parallel), and how does it differ from DeepSpeed ZeRO?

**Answer:**

### Shard training state to fit larger workloads

FSDP is PyTorch’s fully sharded data-parallel approach. Instead of keeping a full copy of parameters, gradients, and optimizer state on every data-parallel rank, it shards these states across ranks. During computation, required parameter shards are gathered for a layer or unit and then released or reshared according to the configured strategy. This reduces per-device persistent memory, at the cost of communication and orchestration.

DeepSpeed ZeRO (“Zero Redundancy Optimizer”) offers related stages of state partitioning:

- **ZeRO Stage 1:** Shard optimizer states.
- **ZeRO Stage 2:** Shard optimizer states and gradients.
- **ZeRO Stage 3:** Shard optimizer states, gradients, and parameters.

FSDP’s fully sharded mode is conceptually closest to ZeRO Stage 3, but the implementations are not interchangeable labels. They differ in APIs, wrapping and partitioning configuration, communication scheduling, offload options, checkpoint formats, integrations, and operational maturity. FSDP also has sharding strategies that can retain some state replicated.

### How to choose and validate

Choose according to framework integration, model structure, hardware topology, supported features, and team familiarity. Profile memory and communication; tune wrapping granularity, prefetching, mixed precision, activation checkpointing, and CPU offload only as appropriate. Validate checkpoint save/load, numerical behavior, fault recovery, and throughput at the intended scale.

Both primarily address distributed **training** memory and execution. They do not automatically make inference serving faster, and parameter gathering or communication can become a bottleneck.

### Trade-offs, bottlenecks, and capacity assumptions

More sharding reduces replicated memory but increases collectives and communication sensitivity. Offload can enable larger models but may be limited by host-memory bandwidth and transfer latency. FSDP and ZeRO capabilities evolve across versions, so compare the specific framework releases and configuration rather than assuming exact feature parity. Hardware, model, and version are unspecified; benchmark the actual training topology.

### Concise interview answer

“FSDP shards parameters, gradients, and optimizer state across data-parallel ranks, gathering parameter shards as needed for computation. DeepSpeed ZeRO stages progressively shard optimizer state, gradients, and—at Stage 3—parameters. FSDP fully sharded mode is conceptually similar to ZeRO-3, but APIs, communication, offload, checkpointing, and integrations differ. I choose by workload and ecosystem, then benchmark memory savings against communication and throughput.”

### Revision summary

| Approach | What is sharded |
|---|---|
| ZeRO-1 | Optimizer state |
| ZeRO-2 | Optimizer state and gradients |
| ZeRO-3 | Optimizer state, gradients, parameters |
| FSDP fully sharded | Parameters and training state across ranks |
| Shared trade-off | Lower memory per rank versus communication cost |

<br><br><br>

## What are TTFT, TPOT, and throughput, and how do they trade against each other?

**Answer:**

### Measure different parts of user experience and system capacity

- **TTFT (time to first token):** Time from request arrival (or the chosen measurement start) until the first generated token is delivered. It includes queueing, prompt prefill, and scheduling/network effects according to the metric definition.
- **TPOT (time per output token):** Average time to produce each generated token after the first token. Some systems use the term for average inter-token latency; report the exact calculation and whether first-token delay is excluded.
- **Throughput:** Work completed per unit time, such as output tokens/sec across the service, requests/sec, or total input-plus-output tokens/sec. State whether it is per replica or aggregate and whether tokens are generated or processed.

### Understand the trade-offs

Reducing queueing and using prompt-efficient execution can improve TTFT. Larger batches and continuous batching can improve aggregate throughput by keeping accelerators busy, but may increase queueing or inter-token delay for individual requests. More concurrency can raise throughput until compute, memory bandwidth, or KV-cache capacity saturates; beyond that point, latency and failures may worsen. Shorter output limits lower service time and resource occupancy but change the product behavior.

These metrics are related but not interchangeable. A system can deliver high aggregate throughput while having poor p99 TTFT, or low TPOT for one request while underutilizing the fleet. Measure percentiles by request class and sequence length, plus throughput at the target SLO.

### Trade-offs, bottlenecks, and capacity assumptions

The optimal operating point depends on service objectives, prompt/output distributions, model, and hardware. Reported token throughput can be misleading if it hides input processing, queue delay, streaming behavior, or failed requests. Define metric start/end points, aggregate versus per-request scope, and percentile targets before tuning batch size, queueing, or concurrency.

### Concise interview answer

“TTFT is how long until the user sees the first generated token; TPOT is the average delay per subsequent output token; throughput is completed requests or tokens per unit time. Batching and concurrency can improve aggregate throughput but may raise queueing, TTFT, or per-request token latency, while excessive concurrency can exhaust KV memory. I define metric boundaries and optimize throughput subject to latency percentiles and workload-specific SLOs.”

### Revision summary

| Metric | Captures | Typical influence |
|---|---|---|
| TTFT | Time to first visible token | Queueing and prompt prefill |
| TPOT | Delay between generated tokens | Decode speed and contention |
| Throughput | Aggregate work rate | Batching, utilization, capacity |
| Tuning objective | Service-level balance | Meet latency targets at required load |

<br><br><br>

## How do you monitor and profile LLM inference in production (TTFT, inter-token latency, GPU utilization)?

**Answer:**

### Combine user-facing metrics with resource and trace data

I instrument each request end to end and correlate service behavior with model and hardware activity. Core measures include TTFT, inter-token latency/TPOT, end-to-end completion time, request and token throughput, queue delay, error/timeout/cancellation rates, and input/output token counts. I break them down by model/version, serving pool, request class, and relevant prompt/output length buckets, while avoiding sensitive prompt content in telemetry.

### Monitoring and profiling workflow

1. **Define measurement boundaries:** Specify when timing begins, when the first token is considered delivered, how inter-token latency is calculated, and how streaming disconnects or cancellations are counted.
2. **Track distributions and SLOs:** Alert on p50/p95/p99 latency, queue age, throughput, saturation, and error budgets—not only averages.
3. **Observe accelerator health:** Monitor GPU utilization, memory usage, KV-cache occupancy, power/thermal or throttling signals where available, and host CPU, RAM, network, and storage. Low GPU utilization can indicate input starvation or CPU/runtime bottlenecks; high utilization alone does not prove a problem.
4. **Use traces and profiles:** Trace queueing, tokenization, prefill, decode, batching, model execution, and network delivery. Profile representative workloads with framework/runtime tools and GPU profilers to find kernels, synchronization, transfers, or allocator overhead that dominate.
5. **Compare cohorts and changes:** Tag deployment/model/runtime versions and compare latency and quality before/after changes at similar load and request mix.
6. **Protect privacy and cardinality:** Use redaction and access controls; avoid raw prompts and unbounded labels such as request IDs in metric dimensions.

Dashboards should show both per-request experience and aggregate capacity. Averages can conceal slow long-context requests or tail-latency regressions.

### Trade-offs, bottlenecks, and capacity assumptions

Detailed tracing and profiling add overhead and may expose sensitive data if poorly designed; use sampled traces, minimized attributes, and secure retention. Utilization is a diagnostic signal, not an SLO. Workload, runtime, and targets are unspecified, so establish a baseline under representative load and tie alerts to user impact and capacity signals.

### Concise interview answer

“I define TTFT, inter-token latency, and completion-time boundaries, then monitor their percentiles alongside token throughput, queue delay, errors, and cancellations. I correlate them with GPU memory/utilization, KV-cache pressure, CPU, network, and per-stage traces for tokenization, prefill, batching, decode, and delivery. I profile representative traffic, compare model/runtime cohorts, and protect privacy by minimizing prompt telemetry. GPU utilization alone is not enough to diagnose user experience.”

### Revision summary

| Signal | Diagnostic value |
|---|---|
| TTFT/TPOT percentiles | User-perceived responsiveness |
| Queue and token throughput | Demand and serving capacity |
| GPU/KV/host metrics | Resource saturation or starvation |
| Traces/profiles | Locate the slow stage or kernel |
| Version/cohort labels | Attribute regressions safely |

<br><br><br>

## What is model routing at the infrastructure level, and how do you route requests based on complexity and cost?

**Answer:**

### Select a compatible model and serving pool per request

Infrastructure-level model routing decides which model, endpoint, or hardware pool should handle a request. The router can select among models with different capabilities, latency, and cost, while also considering availability, context limits, region, privacy requirements, and current capacity. The goal is not simply to send every request to the cheapest model; it is to satisfy the request’s quality and service constraints at an appropriate cost.

### A practical routing policy

1. **Apply hard constraints first:** Enforce tenant authorization, data-residency rules, supported modalities, model context limits, and required reliability or latency targets.
2. **Estimate request needs:** Use explicit task type, prompt/token length, requested output, tool requirements, and—where justified—a lightweight complexity classifier or initial low-cost attempt. Keep the classifier’s uncertainty in mind.
3. **Choose from evaluated tiers:** Route routine tasks to a smaller or lower-cost model and complex/high-risk tasks to a more capable model, using evaluation data to define the quality-cost boundary.
4. **Account for live capacity:** Among eligible endpoints, consider queue age, token throughput, active sequences, KV-cache pressure, and health, not just static price.
5. **Use escalation carefully:** If a low-cost model fails a validated confidence or quality check, escalate to a stronger model when the deadline and budget allow. Bound retries and avoid duplicate work.
6. **Make decisions observable:** Record the selected route and reason codes, model/version, estimated and actual cost, latency, fallback/escalation, and outcome metrics—without logging sensitive prompt content unnecessarily.
7. **Continuously evaluate:** Compare routed outcomes against fixed-model baselines for task quality, safety, latency, and cost. Use controlled rollout and a safe default route when the classifier or routing service is unavailable.

Model routing is distinct from load balancing: routing picks the appropriate model or pool; load balancing distributes work among compatible replicas within that pool. They are often implemented as connected stages.

### Trade-offs, bottlenecks, and capacity assumptions

Routing can reduce average cost and protect specialized capacity, but a poor classifier may under-serve difficult requests or send too many to expensive models. Escalation adds latency and can duplicate tokens/cost; highly dynamic routing complicates evaluation, caching, and debugging. Request mix, candidate models, prices, and SLOs are unspecified, so tune thresholds from representative labeled traffic and monitor quality and cost by route.

### Concise interview answer

“Model routing selects the appropriate model or serving pool for each request based on hard constraints, task complexity, quality needs, cost, latency, and live capacity. I apply policy constraints first, use evaluated complexity signals to select among model tiers, and allow bounded escalation when a cheaper model is insufficient. I distinguish this from load balancing within a pool, log route reasons safely, and continuously compare quality, safety, latency, and cost against baselines.”

### Revision summary

| Routing input | Use |
|---|---|
| Policy and capability | Exclude incompatible or disallowed models. |
| Complexity and task type | Select a quality tier. |
| Cost and latency objectives | Choose an acceptable operating point. |
| Live pool health/capacity | Avoid overloaded endpoints. |
| Evaluation and route telemetry | Detect regressions and tune decisions. |

<br><br><br>
