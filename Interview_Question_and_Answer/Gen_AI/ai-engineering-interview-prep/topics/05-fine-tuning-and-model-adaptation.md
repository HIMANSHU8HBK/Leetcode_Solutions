# 05. Fine-Tuning and Model Adaptation

Source entries are in their original order. Use the space after each heading to draft an answer.

## What is fine-tuning, and when should you fine-tune an LLM?

**Answer:**

### Definition

**Fine-tuning** continues training a pretrained model on a curated dataset so its parameters adapt to a target task, domain, behavior, or response style. Training typically minimizes a task-specific objective—often next-token cross-entropy for supervised examples—using gradient updates to all or a subset of model parameters.

Fine-tuning changes model behavior; it is not the same as adding context to a prompt or retrieving external facts. It also does not guarantee that the model will memorize facts reliably, follow every instruction, or become more accurate on all tasks.

### When it is a good fit

Consider fine-tuning when:

- the task or response behavior is repeated and stable;
- the base model consistently underperforms on a well-defined task;
- representative, high-quality training examples are available;
- prompt engineering and suitable retrieval/tools do not meet quality or cost requirements;
- the expected gain justifies training, evaluation, deployment, and maintenance costs.

Fine-tuning can help with consistent formats, domain-specific language patterns, classification, task procedures, and style. For frequently changing facts, private documents, or answers requiring source citations, RAG or direct structured-data access is often a better fit. A combined design is also possible: fine-tune task behavior and retrieve current evidence at inference time.

### Decision process and risks

1. Establish a baseline with the current model, prompt, and system.
2. Create representative train/validation/test data with provenance and privacy/licensing checks.
3. Compare prompting, RAG, PEFT, and full fine-tuning against task-specific metrics.
4. Evaluate regressions, calibration, robustness, safety, and data leakage—not just training loss.
5. Version the dataset, code, base model, adapter/checkpoint, and serving configuration.
6. Roll out gradually and retain a rollback path.

Risks include overfitting, catastrophic forgetting, memorization of sensitive examples, biased or mislabeled data, and performance regressions outside the target distribution.

### Concise interview answer

“Fine-tuning continues training a pretrained model on task-specific examples to change its behavior or specialize it. I use it when the task is stable and repeated, a measurable gap remains after prompting or retrieval, and I have representative, governed training data. I prefer RAG or a direct data source for changing facts and citations. Before deployment I compare against baselines, test regressions, safety and leakage, version the training artifacts, and stage the release.”

### Revision summary

| Need | Likely approach |
|---|---|
| Stable behavior, style, or task pattern | Fine-tuning may help. |
| Fresh, private, citable facts | RAG or authorized structured query. |
| Small instruction clarification | Prompt engineering first. |
| Model specialization with limited trainable weights | PEFT/LoRA candidate. |
| Deployment | Evaluate, version, monitor, and support rollback. |

<br><br><br>

## Explain the difference between full fine-tuning and parameter-efficient fine-tuning (PEFT).

**Answer:**

### Full fine-tuning

In **full fine-tuning**, gradients update the pretrained model’s parameters (typically all trainable weights) using the target dataset. This gives the optimizer broad freedom to adapt the model, but requires storing and updating optimizer state and gradients for many parameters. Compute, memory, checkpoint size, and risk of forgetting or overfitting can be substantial.

### Parameter-efficient fine-tuning

**Parameter-efficient fine-tuning (PEFT)** freezes most or all of the base model and trains a smaller set of additional or selected parameters. Methods include LoRA/low-rank adapters, bottleneck adapters, prompt tuning, and prefix tuning. The trainable parameter count and optimizer state can be much smaller, while the base weights are reused.

### Comparison

| Dimension | Full fine-tuning | PEFT |
|---|---|---|
| Trainable parameters | Usually most/all model weights. | Small subset or added parameters. |
| Compute/memory | Higher optimizer, gradient, and checkpoint requirements. | Often lower training footprint; activations and base-model memory still matter. |
| Adaptation flexibility | Broad parameter change. | Constrained by the chosen method and capacity. |
| Artifact management | Full model checkpoint or merged model. | Base model plus adapter/soft-prompt artifact, sometimes mergeable. |
| Multiple tasks | Separate full checkpoints can be large. | Multiple adapters may be more storage-efficient. |
| Risks | Greater forgetting/overfitting and expensive updates. | May underfit or depend on exact base/model configuration. |

PEFT is not automatically cheaper at inference: an adapter may add runtime complexity unless merged or efficiently served. Full fine-tuning is not automatically higher quality; compare methods empirically on the target task.

### How to choose

Start with the least expensive approach that meets quality requirements. Compare held-out task performance, regression behavior, robustness, training/inference cost, memory, and deployment complexity. Keep base model, tokenizer, training data, and adapter versions aligned; an adapter is generally tied to a compatible base architecture and checkpoint.

### Concise interview answer

“Full fine-tuning updates most or all pretrained weights, giving broad adaptation at higher memory, compute, and checkpoint cost. PEFT freezes the base and trains a small set of added or selected parameters, such as LoRA adapters or soft prompts, which can lower training costs and make task-specific artifacts smaller. PEFT can be more constrained and still needs base-model memory and validation. I compare both on held-out quality, regressions, serving cost, and operational complexity.”

### Revision summary

| Property | Full FT | PEFT |
|---|---|---|
| Updated weights | Most/all base parameters. | Small adapter/prompt/subset. |
| Training resources | Generally higher. | Generally lower, not zero. |
| Capacity | Broad adaptation. | Method-dependent constrained adaptation. |
| Deployment | Full checkpoint. | Compatible base plus adapter; possibly mergeable. |
| Selection | Benchmark task and operational requirements. |

<br><br><br>

## What is LoRA (Low-Rank Adaptation), and how does it work?

**Answer:**

### Core idea

**LoRA (Low-Rank Adaptation)** is a PEFT method that freezes a pretrained weight matrix \(W_0\) and learns a low-rank update \(\Delta W\). Instead of updating the full \(d \times k\) matrix, LoRA parameterizes the update as a product of two smaller matrices:

\[
W = W_0 + \Delta W,\qquad
\Delta W = \frac{\alpha}{r}BA
\]

where \(A\in\mathbb{R}^{r\times k}\), \(B\in\mathbb{R}^{d\times r}\), \(r\) is the rank, and \(\alpha\) is a scaling factor (exact conventions can vary by implementation). The trainable parameter count is roughly \(r(d+k)\), rather than \(dk\), when \(r\) is much smaller than the original dimensions.

For an input activation \(x\), the adapted layer computes the base transformation plus a low-rank residual:

\[
y = W_0x + \frac{\alpha}{r}BAx
\]

The base weights are frozen; gradients update \(A\) and \(B\). Implementations often initialize one factor so that the initial adapter update is zero or near zero, preserving the base model’s starting behavior.

### Where LoRA is applied and why it helps

LoRA is commonly applied to selected linear projections in Transformer layers, such as attention projections, though target modules depend on the architecture and task. It reduces trainable parameters, optimizer state, and adapter checkpoint size, and allows one base model to support multiple task adapters.

### Trade-offs

- Rank \(r\), target modules, scaling, and training data affect capacity and quality.
- Too little capacity may underfit; too much reduces the efficiency advantage.
- The frozen base model still occupies memory, and training activations still consume resources.
- Adapters add serving/version-management considerations; they may be merged into weights for inference in compatible workflows.
- Quality, regressions, and safety still require evaluation; LoRA is not inherently safer or more accurate.

### Concise interview answer

“LoRA freezes a pretrained matrix \(W_0\) and learns a low-rank residual \(\Delta W=(\alpha/r)BA\), where the rank \(r\) is small. This replaces updating a large dense matrix with training two smaller factors, reducing trainable parameters and optimizer-state memory. It is often attached to Transformer linear projections and can be stored as a task-specific adapter. The base model and activations still consume memory, and rank/module choices affect quality, so I tune and evaluate it against a full fine-tuning or baseline approach.”

### Revision summary

| Symbol | Meaning |
|---|---|
| \(W_0\) | Frozen pretrained weight matrix. |
| \(A,B\) | Trainable low-rank factors. |
| \(r\) | Rank controlling adapter capacity/size. |
| \(\alpha/r\) | Common scaling convention. |
| Benefit | Fewer trainable parameters; base remains reusable. |
| Caveat | Base weights and activation memory are still required. |

<br><br><br>

## What is QLoRA, and how does it enable fine-tuning on consumer hardware?

**Answer:**

### Core idea

**QLoRA** combines low-bit quantization of a frozen base model with trainable LoRA adapters. The base weights are stored in a quantized representation to reduce memory, while gradients update the adapter parameters rather than the quantized base weights. The objective is to make fine-tuning of larger models feasible on more memory-constrained hardware.

The original QLoRA work introduced techniques including **4-bit NormalFloat (NF4)** quantization, **double quantization** to reduce quantization-constant overhead, and **paged optimizers** to help manage memory spikes. Exact support and defaults vary by library and hardware; these techniques are not a guarantee that every model fits on any consumer GPU.

### High-level training flow

1. Load and quantize the pretrained base weights, typically to 4-bit for the QLoRA setup.
2. Keep the quantized base frozen.
3. Attach LoRA modules to selected layers.
4. Run forward/backward computation using the quantized base and trainable adapters, often with higher-precision compute for selected operations.
5. Save the adapter and the exact base-model/quantization configuration needed to reproduce it.

Quantization can introduce approximation error. Training still needs memory for activations, temporary buffers, optimizer state for adapters, sequence context, and batch size. Consumer hardware feasibility depends on model size, sequence length, batch, checkpointing, implementation, and available VRAM/RAM.

### Benefits and limitations

QLoRA can reduce base-weight memory substantially and make PEFT accessible on constrained devices. It does not remove all memory bottlenecks, make fine-tuning free, or guarantee quality equal to full-precision/full-parameter training. Serving the adapter may require compatible quantized kernels and software; evaluate both training and deployment.

### Concise interview answer

“QLoRA quantizes a frozen pretrained base—commonly to 4-bit—and trains LoRA adapters on top. The original method uses NF4, double quantization, and paged optimizers to reduce memory overhead. This lowers the space needed for base weights and optimizer updates, enabling some larger-model fine-tuning setups on limited GPUs. Activations, sequence length, batch size, and runtime buffers still consume memory, and quantization may affect quality. I benchmark the actual hardware/configuration and save the base, quantization, and adapter versions together.”

### Revision summary

| Component | Role |
|---|---|
| Quantized base | Reduces memory for frozen pretrained weights. |
| LoRA adapters | Carry trainable task-specific update. |
| NF4/double quantization | Reduce representation/quantization-constant memory in original method. |
| Paged optimizers | Help handle memory peaks. |
| Caveat | Activations/context still matter; hardware fit is configuration-dependent. |

<br><br><br>

## How does fine-tuning work?

**Answer:**

<br><br><br>

## Explain Prefix Tuning and Prompt Tuning. How are they different from LoRA?

**Answer:**

<br><br><br>

## What is adapter-based fine-tuning?

**Answer:**

<br><br><br>

## Explain the difference between pre-training, supervised fine-tuning (SFT), and preference optimization (RLHF/DPO).

**Answer:**

<br><br><br>

## What is RLHF (Reinforcement Learning from Human Feedback), and how is it used to align LLMs?

**Answer:**

<br><br><br>

## What is Deep RL from Human Preferences, the paper that started RLHF?

**Answer:**

<br><br><br>

## Why did DPO displace PPO-based RLHF at many labs? When is online RL still better?

**Answer:**

<br><br><br>

## What is instruction tuning, and why is it important for chat models?

**Answer:**

<br><br><br>

## How do you prepare a dataset for fine-tuning an LLM?

**Answer:**

<br><br><br>

## What is catastrophic forgetting, and how do you prevent it during fine-tuning?

**Answer:**

<br><br><br>

## When should you choose fine-tuning over RAG over prompt engineering?

**Answer:**

<br><br><br>

## How do you evaluate a fine-tuned model's performance?

**Answer:**

<br><br><br>

## What is synthetic data generation, and how do you use it for fine-tuning?

**Answer:**

<br><br><br>

## What are the key hyperparameters for fine-tuning (learning rate, epochs, batch size, LoRA rank)?

**Answer:**

<br><br><br>

## Do the GPU memory math for full fine-tuning a 7B model in bf16 with Adam. Now with LoRA and QLoRA.

**Answer:**

<br><br><br>

## How do you fine-tune a model for a specific domain (legal, medical, finance)?

**Answer:**

<br><br><br>

## What is continual pre-training, and when would you use it?

**Answer:**

<br><br><br>

## How do you merge multiple LoRA adapters?

**Answer:**

<br><br><br>

## What is the difference between SFT (Supervised Fine-Tuning) and alignment training?

**Answer:**

<br><br><br>

## What is RLAIF (RL from AI Feedback), and how does it differ from RLHF?

**Answer:**

<br><br><br>

## What is Constitutional AI, and how does it differ from RLHF?

**Answer:**

<br><br><br>

## What is RLVR (Reinforcement Learning with Verifiable Rewards), and when does it beat a learned reward model?

**Answer:**

<br><br><br>

## What is knowledge distillation for fine-tuning, and what are the legal considerations?

**Answer:**

<br><br><br>

## Your fine-tuned LLM produces factually wrong outputs due to training data quality issues. How do you fix it?

**Answer:**

<br><br><br>

## You must choose between LoRA and full fine-tuning for a domain-specific assistant. How do you decide?

**Answer:**

<br><br><br>

## Your fine-tuned model memorized training data verbatim instead of learning patterns. How do you fix overfitting?

**Answer:**

<br><br><br>

## Your fine-tuned LLM forgot its general capabilities after domain-specific fine-tuning. How do you fix catastrophic forgetting?

**Answer:**

<br><br><br>

## Your RLHF preference data has low annotator agreement. How do you ensure data quality?

**Answer:**

<br><br><br>
