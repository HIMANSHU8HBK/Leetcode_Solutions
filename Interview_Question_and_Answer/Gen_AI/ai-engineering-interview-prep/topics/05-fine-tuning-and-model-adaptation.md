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

### Training objective and parameter updates

Fine-tuning starts from a pretrained checkpoint and trains it further on examples for a target task or behavior. For supervised language-model fine-tuning, each example typically contains an input/prompt and a desired target response. The model predicts tokens, computes a loss against the target, and uses backpropagation and an optimizer to update trainable parameters.

For next-token training, a common objective is token-level cross-entropy:

\[
L(\theta)=-\sum_{t\in T}\log P_\theta(y_t\mid x,y_{<t})
\]

where \(x\) is the conditioning input, \(y\) is the target response, and \(T\) is the set of target tokens included in the loss. In instruction tuning, loss is often applied to assistant response tokens while prompt tokens are masked, but the exact masking and objective depend on the training recipe.

### Practical training flow

1. Select the base model and verify license, tokenizer, chat template, and hardware compatibility.
2. Curate, clean, deduplicate, and format representative data; split train/validation/test carefully.
3. Tokenize with the model’s tokenizer and construct labels/masks so only intended tokens contribute to loss.
4. Choose full fine-tuning or PEFT, optimizer, learning rate, batch/sequence length, scheduler, and regularization.
5. Train while tracking loss, throughput, memory, and validation performance; use checkpointing and early stopping where appropriate.
6. Evaluate against the untouched base and relevant baselines, including regressions, safety, memorization, and out-of-distribution cases.
7. Save a reproducible artifact with dataset, code, base model, tokenizer, hyperparameters, and checkpoint/adapter versions.
8. Deploy gradually and monitor; keep rollback capability.

### Important considerations

Training loss decreasing does not prove that the model is useful or safe. Data leakage between splits, low-quality labels, excessive epochs, learning rate, or narrow examples can cause overfitting and forgetting. Fine-tuning may teach behavior and patterns, but is generally a poor mechanism for facts that must be fresh, cited, or precisely queryable.

### Concise interview answer

“Fine-tuning continues training from a pretrained checkpoint using curated target examples. The model predicts target tokens, computes a loss such as cross-entropy, and updates all weights or a PEFT subset through backpropagation. The pipeline includes data curation and splitting, correct token/label masking, optimizer and hyperparameter selection, validation, regression and safety evaluation, artifact versioning, and staged deployment. Lower training loss alone is not enough; I verify held-out task quality and regressions against the base model.”

### Revision summary

| Stage | What happens |
|---|---|
| Data | Curate and split representative examples. |
| Forward pass | Predict target tokens conditioned on input/context. |
| Loss | Compare predictions with intended targets. |
| Update | Backpropagate and update full or selected parameters. |
| Release | Evaluate, version, stage, monitor, and support rollback. |

<br><br><br>

## Explain Prefix Tuning and Prompt Tuning. How are they different from LoRA?

**Answer:**

### Prompt tuning

**Prompt tuning** learns a small set of continuous task-specific embeddings—often called virtual tokens—that are prepended to the input embedding sequence. The base model is generally frozen, and gradients update the learned prompt embeddings. These vectors need not correspond to readable text tokens.

### Prefix tuning

**Prefix tuning** learns continuous prefix representations that influence the model at multiple layers, commonly by supplying learned prefix key/value states to attention layers. The base model is typically frozen. Exact implementations vary, and the term should be interpreted according to the method/library being discussed.

### LoRA

**LoRA** freezes pretrained weights and learns low-rank weight updates in selected linear layers, typically expressed as \(\Delta W=BA\) (with a scaling factor). It modifies the effective transformation of selected modules rather than learning only input/prefix embeddings.

### Comparison

| Method | Trainable artifact | Where it acts | Typical trade-off |
|---|---|---|---|
| Prompt tuning | Learned virtual-token embeddings. | Input embedding sequence. | Very small artifact; adaptation capacity may be limited, especially for some model/task combinations. |
| Prefix tuning | Learned continuous prefix states. | Attention layers, often as prefix key/value representations. | Can influence multiple layers; adds sequence/prefix computation and implementation complexity. |
| LoRA | Low-rank factors for selected weights. | Selected model weight matrices. | Often effective PEFT with modular adapters; module/rank selection and serving matter. |

All three are PEFT approaches when the base is frozen, but they are not interchangeable. Their quality depends on model architecture, task, data, and configuration. Compare held-out performance, trainable parameter count, memory, inference latency, and deployment requirements. “Prompt tuning” is also distinct from prompt engineering, which edits human-readable text without learning parameters.

### Concise interview answer

“Prompt tuning learns continuous virtual-token embeddings at the input, while prefix tuning learns continuous prefix states that influence attention across layers. LoRA instead learns low-rank updates to selected weight matrices. They all can freeze the base model and reduce trainable parameters, but place the learned adaptation in different parts of the network and have different serving and capacity trade-offs. Prompt tuning is not ordinary prompt engineering. I compare them empirically on the target model and task.”

### Revision summary

| Method | Learns | Applied at |
|---|---|---|
| Prompt tuning | Soft prompt/virtual token embeddings. | Input embeddings. |
| Prefix tuning | Prefix representations/key-values. | Attention layers. |
| LoRA | Low-rank weight update factors. | Selected linear weights. |
| Prompt engineering | No learned parameters. | Human-readable inference prompt. |

<br><br><br>

## What is adapter-based fine-tuning?

**Answer:**

### Definition

**Adapter-based fine-tuning** inserts small trainable modules—adapters—into or alongside a mostly frozen pretrained network. The adapter processes hidden activations and contributes a learned transformation, while the original model weights remain fixed or largely fixed. A common bottleneck adapter projects activations to a smaller dimension, applies a nonlinearity, and projects back, adding a residual update.

The base model can then be reused with different adapter parameters for different tasks or domains. “Adapter-based” is a family of parameter-efficient approaches; exact placement, architecture, and whether adapters can be merged vary by method.

### Why use adapters?

- Train fewer parameters than full fine-tuning.
- Maintain separate task/domain adaptations while sharing one base checkpoint.
- Reduce storage and simplify switching between specialized behaviors.
- Limit changes to the base model, which can make experiment management more modular.

### Trade-offs

Adapters add parameters and may add inference latency or memory unless the serving system optimizes or merges them. They can underfit if their capacity is too small, and a given adapter is generally tied to a compatible base model, architecture, and tokenizer. Multiple adapters require routing, versioning, and compatibility management. Parameter efficiency does not remove the need for representative data, held-out tests, safety evaluation, or rollback.

### Concise interview answer

“Adapter-based fine-tuning inserts small trainable modules into a mostly frozen pretrained model. These modules learn task-specific transformations while the shared base remains reusable, allowing multiple adaptations with smaller training and storage footprints than full checkpoints. The trade-offs are adapter capacity, compatibility with the base model, and potential inference overhead or routing complexity. I version adapters with their base model and evaluate task gains, regressions, latency, and memory.”

### Revision summary

| Component | Role |
|---|---|
| Frozen base | Supplies pretrained representations. |
| Adapter | Learns task/domain-specific transformation. |
| Benefit | Modular, parameter-efficient specialization. |
| Cost | Runtime overhead, capacity limits, compatibility management. |
| Governance | Version adapter, base, tokenizer, data, and evaluation. |

<br><br><br>

## Explain the difference between pre-training, supervised fine-tuning (SFT), and preference optimization (RLHF/DPO).

**Answer:**

### The three stages optimize different things

**Pre-training** learns broad statistical structure from large-scale data, commonly using next-token prediction for language models. It builds general language and world-pattern representations but does not by itself ensure helpful instruction following.

**Supervised fine-tuning (SFT)** trains on curated input-target demonstrations, such as instruction-response or conversation examples. It teaches the model to produce desired responses in specified formats and interaction patterns, using supervised loss on target tokens.

**Preference optimization** uses judgments comparing candidate responses—often preferred versus rejected—to shift the policy toward outputs people or a defined preference process favor. RLHF commonly trains a reward model from preference data and uses reinforcement learning such as PPO to optimize a policy, often with a reference/KL constraint. DPO optimizes directly from preference pairs in a reference-policy formulation and does not require the standard separate reward-model-plus-online-PPO loop.

### Comparison

| Stage | Training signal | Main objective |
|---|---|---|
| Pre-training | Raw or weakly labeled text tokens. | Learn general predictive representations/next-token behavior. |
| SFT | Demonstration input-output pairs. | Imitate desired responses and task formats. |
| Preference optimization | Relative comparisons or rewards. | Prefer higher-ranked responses under a chosen objective. |

These are common stages, not a mandatory one-way pipeline. Systems may combine or iterate them, and “alignment” is broader than any one optimization method.

### Limitations and evaluation

Pre-training data can contain noise and bias; SFT can overfit demonstrations; preference labels can be inconsistent or reward superficial qualities such as verbosity. Preference optimization may exploit reward-model errors or reduce capabilities. Evaluate each stage on held-out task quality, safety, calibration, robustness, and regression suites rather than assuming later-stage training improves every property.

### Concise interview answer

“Pre-training learns general language behavior from large-scale token data, SFT imitates curated instruction-response demonstrations, and preference optimization uses relative judgments to shift outputs toward preferred behavior. RLHF often trains a reward model and then optimizes the policy with an RL method such as PPO; DPO uses preference pairs directly in a reference-policy objective. They use different supervision signals and solve different problems. Each can introduce biases or regressions, so I evaluate the resulting model on independent capability and safety tests.”

### Revision summary

| Stage | Data | Learns |
|---|---|---|
| Pre-training | Large-scale text/token sequences. | Broad predictive language capability. |
| SFT | Desired responses/demonstrations. | Instruction following and response format. |
| RLHF/DPO | Preferences or reward signals. | Relative response preference. |
| Shared caveat | N/A | No stage guarantees truth, safety, or universal improvement. |

<br><br><br>

## What is RLHF (Reinforcement Learning from Human Feedback), and how is it used to align LLMs?

**Answer:**

### Definition and typical pipeline

**RLHF (Reinforcement Learning from Human Feedback)** uses human judgments to shape model behavior. A common language-model pipeline is:

1. **Supervised fine-tuning:** Train an initial policy on high-quality demonstrations.
2. **Preference collection:** Generate multiple responses to prompts and ask annotators to rank or compare them using a rubric.
3. **Reward modeling:** Train a reward model to predict human preference from prompt-response examples.
4. **Policy optimization:** Sample responses from the language model and optimize it to increase reward, often using PPO and a KL penalty relative to a reference model.
5. **Evaluation and iteration:** Assess helpfulness, harmlessness, honesty, task capability, regressions, and reward hacking; update data and training as needed.

The exact pipeline varies. Human feedback can also be used in preference methods that do not use the traditional learned-reward-model-plus-RL loop.

### What “alignment” means here

RLHF aims to make outputs better match a specified preference distribution or policy objective, such as usefulness and safety. It does not prove that the model’s beliefs are true, guarantee ethical behavior, or resolve conflicts in human values. The learned reward is a proxy for human judgments and can be incomplete or biased.

### Benefits and limitations

RLHF can improve instruction following and preference alignment beyond next-token imitation alone. Challenges include annotation cost, disagreement, reward-model generalization, optimization instability, reward hacking, distribution shift, and capability regressions. Use diverse, well-defined rubrics; quality control; separate safety/capability evaluations; and monitor for unintended behaviors.

### Concise interview answer

“RLHF uses human preference data to guide language-model behavior. A common process starts with SFT, collects rankings of candidate responses, trains a reward model, then optimizes the policy—often with PPO and a KL constraint to a reference model. It can improve behavior according to the collected preferences, but the reward is only a proxy: annotators disagree, reward models can be exploited, and capabilities can regress. I use clear rubrics, diverse data, independent evaluations, and monitor for reward hacking.”

### Revision summary

| Stage | Role |
|---|---|
| SFT | Initialize policy from demonstrations. |
| Preference data | Human comparisons of candidate outputs. |
| Reward model | Predict preference signal. |
| RL optimization | Improve policy against reward with constraints. |
| Caveat | Proxy objective; evaluate capability, safety, and regressions independently. |

<br><br><br>

## What is Deep RL from Human Preferences, the paper that started RLHF?

**Answer:**

### Paper and contribution

The question refers to **“Deep Reinforcement Learning from Human Preferences”** by Paul Christiano and coauthors, first submitted to arXiv in 2017 ([arXiv:1706.03741](https://arxiv.org/abs/1706.03741)). The work studied how to specify goals through non-expert human preferences between pairs of trajectory segments, rather than requiring access to a hand-coded reward function.

At a high level, the system:

1. collected short trajectory segments from an agent;
2. asked a human to compare pairs of segments;
3. learned a reward predictor from those preference labels; and
4. optimized the agent with reinforcement learning against the learned reward.

The authors demonstrated tasks including Atari games and simulated robot locomotion, and reported that human feedback could be a small fraction of the agent’s environment interactions.

### Why it matters for RLHF

The paper is an important precursor and landmark in modern human-preference-based RL. However, calling it literally “the paper that started RLHF” is a simplification: preference-based learning and human-feedback research had earlier roots, and the 2017 work was not the later language-model RLHF recipe. It applied learned human preferences to reinforcement-learning tasks; later work adapted preference reward modeling and RL optimization to language models.

### What it does not establish

The paper does not imply that preference-trained agents are automatically aligned, truthful, or safe. A learned reward is a proxy for the preferences represented in the labels; limited, noisy, or biased comparisons can lead to reward-model error and reward hacking.

### Concise interview answer

“Christiano et al.’s 2017 paper, ‘Deep Reinforcement Learning from Human Preferences’ (arXiv:1706.03741), trained a reward model from non-expert human comparisons of trajectory segments and used RL to optimize behavior without a hand-specified reward function. It demonstrated tasks including Atari and simulated locomotion with relatively sparse human feedback. It is a landmark precursor to modern RLHF, but saying it single-handedly ‘started RLHF’ is historically imprecise, and it was not itself the later LLM-specific recipe.”

### Revision summary

| Point | Remember |
|---|---|
| Citation | Christiano et al., 2017, arXiv:1706.03741. |
| Human signal | Pairwise preferences over trajectory segments. |
| Method | Learn reward predictor, then optimize policy with RL. |
| Contribution | Landmark preference-based deep RL work and precursor to modern RLHF. |
| Historical caveat | Not literally the sole origin of all RLHF research; not an LLM paper. |

<br><br><br>

## Why did DPO displace PPO-based RLHF at many labs? When is online RL still better?

**Answer:**

### First qualify the premise

**DPO (Direct Preference Optimization)** became attractive in many preference-tuning workflows because it can train directly from fixed chosen/rejected response pairs without the standard separate reward-model training and online PPO rollout loop. But “displace” is not universal: methods vary by lab, task, and time, and DPO is not always better.

### Why DPO is operationally attractive

- **Simpler pipeline:** Avoids training and maintaining a separate reward model for the standard formulation.
- **Offline optimization:** Reuses a fixed preference dataset rather than generating fresh policy rollouts each update.
- **Fewer moving parts:** Avoids PPO-specific rollout, value/advantage estimation, and some stability-tuning burdens.
- **Practical iteration:** Can be easier to reproduce and run with conventional supervised fine-tuning infrastructure.

DPO still requires good preference data, a reference policy, careful hyperparameters, and robust evaluation. It can overfit to static comparisons, inherit their coverage gaps, or produce capability regressions. It also optimizes a preference objective under modeling assumptions; it does not guarantee alignment or truth.

### When online RL can be better

Online RL can be useful when the policy must interact with an environment, explore actions, or optimize rewards that are generated by fresh rollouts—for example, verifiable task outcomes, tool use, games, simulations, or tasks where fixed preference pairs do not cover the policy’s new behavior. Fresh interaction can provide learning signal beyond a static dataset.

However, online methods such as PPO require rollout generation and reward evaluation, and can be costly or unstable. The choice depends on whether exploration and current-policy feedback justify those costs.

### Decision framework

Use DPO when preference pairs are representative and a simpler offline workflow meets targets. Consider online RL when the reward is reliable and measurable on new behavior, exploration matters, and the environment can be safely sampled. Compare on held-out task success, preference quality, safety, robustness, capability retention, training compute, and operational complexity.

### Concise interview answer

“DPO became attractive because it learns directly from fixed preference pairs and avoids the standard separate reward-model-plus-online-PPO loop, reducing engineering and rollout cost. It did not universally replace PPO: DPO is limited by static data coverage and still depends on preference quality. Online RL can be preferable when exploration or fresh environment outcomes provide useful reward signal that offline pairs cannot capture. I choose empirically, weighing reward reliability, rollout cost, stability, held-out performance, and safety.”

### Revision summary

| Method | Strong fit | Main trade-off |
|---|---|---|
| DPO | Fixed, representative preference pairs; simpler offline training. | Static coverage and preference-data limits. |
| Online RL/PPO | Fresh rollouts, exploration, environment/verifiable rewards. | Rollout cost, reward quality, tuning, stability. |
| Decision | Compare on the target workload. | Neither method universally dominates. |

<br><br><br>

## What is instruction tuning, and why is it important for chat models?

**Answer:**

### Definition

**Instruction tuning** is supervised fine-tuning on examples that pair instructions or conversational context with desired responses. The examples teach a pretrained model to interpret user requests and produce task-appropriate answers, rather than merely continuing arbitrary text in the style of its pretraining data.

Training examples may include question-answer pairs, transformations, classification, tool-related formats, refusals, and multi-turn conversations. A conversation is typically serialized with the model’s required chat template, and loss is often applied to target assistant tokens rather than the user prompt, depending on the training recipe.

### Why it matters for chat

Pretraining teaches broad next-token prediction but does not by itself define a helpful assistant role. Instruction tuning can improve:

- following varied user requests;
- adapting response format and level of detail;
- respecting conversational roles and turn structure;
- handling task-specific conventions represented in the data.

Instruction tuning is distinct from preference optimization: SFT imitates demonstrated targets, while preference methods optimize relative preference judgments. Many chat models use both stages, but recipes differ.

### Data and limitations

Quality and coverage matter more than simply scaling the number of examples. Include diverse, representative instructions, correct targets, edge cases, and clear role formatting. Poor demonstrations can teach inconsistent behavior, bias, leakage, or brittle patterns. Instruction tuning does not guarantee factuality, safety, tool correctness, or robust generalization.

### Concise interview answer

“Instruction tuning is supervised fine-tuning on instruction-response or conversation examples. It adapts a pretrained next-token model to follow user tasks, respect dialogue structure, and produce desired formats. It is important because pretraining alone does not specify assistant behavior. SFT imitates demonstrations; preference optimization is a separate signal that ranks outputs. I curate diverse, high-quality examples and evaluate instruction following, safety, and capability regressions rather than assuming tuning guarantees reliable behavior.”

### Revision summary

| Stage | Signal | Main contribution |
|---|---|---|
| Pretraining | Broad token prediction. | General language modeling. |
| Instruction tuning/SFT | Desired response demonstrations. | Task following and chat behavior. |
| Preference tuning | Relative rankings/rewards. | Shift outputs toward preferred behavior. |
| Caveat | N/A | Demonstrations do not guarantee truth or safety. |

<br><br><br>

## How do you prepare a dataset for fine-tuning an LLM?

**Answer:**

### Start from the target behavior

Define the task, intended users, output contract, and success metrics before collecting examples. Data should represent the deployment distribution and the behaviors the model should learn—not merely be easy to obtain.

### Dataset preparation workflow

1. **Establish rights and governance:** Verify licensing, consent, privacy basis, retention, and permitted use. Remove or protect sensitive data.
2. **Collect representative examples:** Cover common cases, boundary conditions, languages, formats, failure cases, and desired refusal/abstention behavior where relevant.
3. **Normalize format:** Apply the correct model chat template and role structure; make inputs and targets unambiguous. For tool examples, ensure the tool-call/result sequence is valid for the target model.
4. **Clean and deduplicate:** Remove malformed, contradictory, low-quality, irrelevant, and exact/near-duplicate records while preserving meaningful variation.
5. **Validate labels:** Use clear annotation guidelines, expert review for domain content, adjudication for disagreements, and quality checks for generated examples.
6. **Split without leakage:** Create train/validation/test splits by source, user, time, or entity as appropriate so near-duplicates and related records do not leak across splits.
7. **Tokenize and inspect:** Use the correct tokenizer and sequence limits; inspect truncation, padding, loss masks, and examples after serialization.
8. **Version and document:** Track source, preprocessing code, label schema, split, license, tokenizer, and dataset version for reproducibility.

### Balance and measure

Check class/intent balance, coverage, label consistency, length distribution, language/domain representation, and sensitive-data exposure. Avoid balancing blindly if deployment prevalence matters; use sampling or weighting intentionally and calibrate evaluation to real traffic. Maintain a held-out test set that is not used for prompt or hyperparameter tuning.

### Concise interview answer

“I define target behavior and metrics first, then build a representative, legally and privacy-compliant dataset. I normalize to the model’s exact chat template, clean and deduplicate, validate labels with clear guidelines, include edge cases, and split by source/user/time to prevent leakage. I inspect tokenization, truncation, and loss masks, document provenance and preprocessing, and keep a held-out test set. Dataset quality, distribution coverage, and governance are as important as training configuration.”

### Revision summary

| Step | Check |
|---|---|
| Governance | Rights, consent, privacy, retention. |
| Coverage | Representative users, tasks, boundaries, and languages. |
| Quality | Correct labels, clear formats, deduplication. |
| Leakage | Source-aware splits and protected test set. |
| Reproducibility | Version data, tokenizer, templates, code, and schema. |

<br><br><br>

## What is catastrophic forgetting, and how do you prevent it during fine-tuning?

**Answer:**

### Definition

**Catastrophic forgetting** occurs when adapting a model to new data or tasks degrades capabilities it previously had. Fine-tuning shifts parameters to reduce loss on the new training distribution; if that distribution is narrow or very different, earlier behaviors may no longer be represented as well.

### Mitigation options

- **Replay/rehearsal:** Mix a carefully selected, permission-compliant subset of prior-task examples with new data.
- **Data mixture:** Include diverse general and domain examples representative of capabilities that must be retained.
- **Parameter-efficient tuning:** Freeze most of the base and train adapters/LoRA; this limits changes but does not guarantee no regression.
- **Regularization:** Penalize changes to important parameters or constrain divergence from a reference model; these methods add assumptions and tuning.
- **Modular adaptation:** Keep task-specific adapters or experts separate and route explicitly rather than overwriting one shared behavior.
- **Conservative optimization:** Tune learning rate, epochs, batch composition, and early stopping using held-out regression data.
- **Rollback/versioning:** Preserve the original checkpoint and deploy a candidate only after evaluation.

### Evaluate retention

Maintain a regression suite for general capabilities, safety, instruction following, and critical previous tasks. Compare base and adapted models across both new-task and retention metrics, including adversarial and out-of-distribution examples. Check for data leakage and benchmark contamination. If the requirement is only to add changing factual knowledge, use RAG rather than weight updates where appropriate.

No technique eliminates forgetting universally. The best mitigation depends on task overlap, data volume, training method, and the capabilities that matter.

### Concise interview answer

“Catastrophic forgetting is regression on previously learned capabilities after fine-tuning on new data. I mitigate it with representative replay or mixed data, conservative training and early stopping, regularization where appropriate, and PEFT or modular adapters to limit shared-weight changes. None guarantees retention, so I keep a regression suite covering old tasks, safety, and general behavior, compare the candidate with the base model, and preserve rollback. For new facts that change frequently, retrieval may avoid unnecessary weight updates.”

### Revision summary

| Cause/control | Example |
|---|---|
| Narrow new data | Mix representative prior/general examples. |
| Large parameter shift | PEFT, regularization, conservative learning rate. |
| Task interference | Separate adapters or modular routing. |
| Undetected regression | Held-out retention/safety regression suite. |
| Release risk | Version checkpoints, stage deployment, rollback. |

<br><br><br>

## When should you choose fine-tuning over RAG over prompt engineering?

**Answer:**

### Choose the mechanism that matches the change

These approaches solve related but different problems, and can be combined:

- **Prompt engineering** changes inference-time instructions, examples, and context. Start here when the task is clear and the model is close to the desired behavior; it is fast to iterate and requires no training.
- **RAG** retrieves external evidence at inference time. Prefer it for fresh, private, changing, or citable facts and documents. It requires indexing/retrieval and can fail to retrieve or faithfully use evidence.
- **Fine-tuning** updates model parameters (fully or with PEFT) from examples. Consider it for repeated, relatively stable behavior or task patterns—such as format, style, domain terminology, or classification—when prompting is insufficient and representative training data exists.

Fine-tuning is usually not the best way to maintain frequently changing facts: those facts can become stale, are difficult to update selectively, and may not be reliably recalled or cited. RAG is not a substitute for teaching a consistent response behavior. A common combination is fine-tuning for task behavior plus RAG for current evidence.

### Decision framework

1. Define the actual failure or requirement: behavior, knowledge freshness, grounding, format, latency, or cost.
2. Establish a baseline with prompting and deterministic tools; add RAG if answers require external sources.
3. Fine-tune only if a measurable, stable behavior gap remains and high-quality governed examples are available.
4. Compare alternatives on the same held-out task set, including safety, regression, freshness, latency, and total operating cost.
5. Account for data governance, training and deployment burden, evaluation, and rollback.

### Concise interview answer

“I use prompt engineering first for instruction changes, RAG for fresh or source-grounded knowledge, and fine-tuning for stable repeated behavior or task patterns that prompting cannot reliably produce. I avoid encoding frequently changing facts into weights. They can be combined—for example, a fine-tuned response style with RAG evidence. I decide from a measured baseline and compare quality, safety, freshness, latency, cost, data availability, and maintenance burden.”

### Revision summary

| Requirement | First option to evaluate |
|---|---|
| Clarify instructions or output style | Prompt engineering. |
| Current/private/citable knowledge | RAG or direct structured data access. |
| Stable behavior/task pattern | Fine-tuning/PEFT if data and evidence support it. |
| Mixed need | Fine-tune behavior, retrieve facts. |
| Selection | Benchmark total quality and lifecycle cost. |

<br><br><br>

## How do you evaluate a fine-tuned model's performance?

**Answer:**

### Evaluate against the right baseline

Compare the fine-tuned candidate with the untouched base model and relevant alternatives (prompted model, RAG system, or existing production model) on the same frozen evaluation set. Training loss is a diagnostic, not a deployment metric.

### Build a reliable evaluation suite

- **Task performance:** Choose metrics appropriate to the task—exact match/F1, ranking, extraction accuracy, format validity, or rubric-based quality.
- **General capability retention:** Re-test important tasks the base model already handled.
- **Safety and policy:** Evaluate refusals, unsafe compliance, privacy leakage, and misuse cases relevant to the application.
- **Robustness:** Include paraphrases, edge cases, distribution shifts, ambiguous inputs, and adversarial examples.
- **Calibration and abstention:** Check whether confidence/abstention behavior is appropriate where needed.
- **Data leakage and memorization:** Probe for training examples or sensitive content and ensure evaluation sources did not leak into training.
- **Operations:** Measure inference latency, throughput, memory, model size, and cost.

Use separate train, validation, and held-out test sets; split by source/user/time where needed to prevent near-duplicate leakage. Human review is valuable for nuanced domains; use clear rubrics, multiple raters on a sample, and adjudication. Automated or LLM-based judges should be calibrated against human/ground-truth labels and should not be the only measure.

### Analyze slices and regressions

Report metrics by language, intent, class, domain, input length, and risk category—not only one aggregate score. Inspect examples where the candidate regresses, quantify uncertainty where possible, and set acceptance thresholds before training. Stage deployment and keep a rollback path.

### Concise interview answer

“I compare the fine-tuned model with the base and relevant prompt/RAG baselines on a held-out, leakage-resistant evaluation set. I measure task-specific quality, general capability retention, safety, robustness, calibration/abstention, memorization, latency, and cost. I analyze slices and failure examples rather than only aggregate scores. For subjective quality I use a rubric and human review; LLM judges are calibrated, not treated as ground truth. I define release thresholds and rollback before deployment.”

### Revision summary

| Evaluation dimension | Question |
|---|---|
| Task quality | Did the target task improve on held-out data? |
| Retention | Did prior capabilities regress? |
| Safety/robustness | Did risk increase on adversarial or shifted inputs? |
| Leakage | Did examples or sensitive data get memorized? |
| Operations | Can the model meet latency, memory, and cost targets? |

<br><br><br>

## What is synthetic data generation, and how do you use it for fine-tuning?

**Answer:**

### Definition

**Synthetic data generation** creates training examples using a model, simulator, program, or rules rather than collecting every example directly from human-labeled data. For LLM fine-tuning, a teacher model may draft instructions, responses, paraphrases, edge cases, or preference comparisons that are then filtered and reviewed.

Synthetic data can expand coverage, reduce annotation effort, and create examples for rare or controlled scenarios. It is not automatically correct or diverse: a generator can hallucinate, reproduce bias, leak its own training content, or produce many superficially different but redundant examples.

### A quality-controlled pipeline

1. Define the target capability and identify data gaps from evaluation.
2. Generate examples from trusted prompts, sources, simulators, or rules; preserve provenance and generator/version metadata.
3. Apply deterministic checks where possible (schema, unit tests, arithmetic, policy constraints).
4. Use expert or human review for facts, domain correctness, safety, and ambiguous cases.
5. Deduplicate and detect contamination against training, validation, and benchmark data.
6. Measure diversity, label balance, difficulty, and distribution match; avoid letting synthetic volume swamp trusted examples.
7. Mix accepted synthetic data with high-quality human/real examples and compare ablations.
8. Evaluate on an independent, preferably human-curated test set and inspect regressions.

For preference data, do not treat teacher-generated rankings as human preferences unless the source and objective are explicitly defined. Label synthetic provenance so its influence can be analyzed and removed if it harms results.

### Concise interview answer

“Synthetic data is generated by models, simulators, or rules to supplement fine-tuning data. I use it to target gaps found in evaluation, then validate examples with deterministic tests and human/domain review, deduplicate, check diversity and contamination, and preserve provenance. I mix it carefully with trusted data and run ablations against an independent test set. Synthetic data lowers collection cost, but can amplify generator errors, bias, and model-specific patterns.”

### Revision summary

| Stage | Practice |
|---|---|
| Target | Generate to address measured coverage gaps. |
| Validate | Rules/tests and qualified human review. |
| Clean | Deduplicate; check diversity, balance, contamination. |
| Track | Record generator, prompts, sources, filters, versions. |
| Prove value | Ablations and independent held-out evaluation. |

<br><br><br>

## What are the key hyperparameters for fine-tuning (learning rate, epochs, batch size, LoRA rank)?

**Answer:**

### Optimization hyperparameters

- **Learning rate:** Controls update magnitude; often the most sensitive choice. Too high can destabilize or erase useful behavior; too low can underfit or require excessive steps. PEFT and full fine-tuning may need different ranges.
- **Epochs / training steps:** More passes can improve fit but increase overfitting and forgetting. Select using validation and early stopping rather than a fixed rule.
- **Batch size and gradient accumulation:** Determine examples/tokens per optimizer update and affect gradient noise, memory, and throughput. Compare effective batch size, not only microbatch size.
- **Optimizer and scheduler:** AdamW-like optimizers and warmup/decay schedules are common, but the right setup depends on model, data, and framework.
- **Weight decay / regularization:** May help generalization; must be tuned with the task and optimizer.
- **Sequence length:** Sets the maximum context per example and strongly affects memory/compute; truncation can remove essential context or targets.
- **Precision and gradient controls:** Mixed precision, gradient clipping, gradient checkpointing, and accumulation affect stability and resource use.

### PEFT-specific parameters

For LoRA, **rank \(r\)** controls the dimension/capacity of the low-rank update; larger ranks add trainable parameters and memory but do not guarantee better results. Also choose target modules, scaling \(\alpha\), dropout, and which layers receive adapters. For QLoRA, quantization format and compute dtype are additional relevant settings. Prompt/prefix tuning has its own virtual-token or prefix-length parameters.

### Tuning strategy

Start from a known recipe compatible with the model and training framework, then tune a small number of high-impact variables using validation data or controlled sweeps. Track training/validation loss, task metrics, regression tests, throughput, peak memory, and seeds where reproducibility matters. Avoid selecting hyperparameters on the final test set.

There are no universally correct values: dataset size/quality, model scale, task, hardware, and implementation determine appropriate settings.

### Concise interview answer

“The main knobs are learning rate, training steps/epochs, effective batch size, optimizer/scheduler, sequence length, regularization, and precision/checkpointing settings. For LoRA I also tune rank, target modules, scaling, and dropout; QLoRA adds quantization/compute choices. I start with a model-compatible baseline, then tune high-impact parameters on validation data while tracking task quality, regressions, loss, memory, and throughput. More epochs or higher LoRA rank do not automatically improve generalization.”

### Revision summary

| Hyperparameter | Main effect |
|---|---|
| Learning rate | Update size and stability. |
| Steps/epochs | Fit versus overfitting/forgetting. |
| Effective batch | Gradient variance, memory, throughput. |
| Sequence length | Context coverage and compute/memory. |
| LoRA rank/modules | Adapter capacity and parameter cost. |
| Selection rule | Validation and regression metrics, not test-set tuning. |

<br><br><br>

## Do the GPU memory math for full fine-tuning a 7B model in bf16 with Adam. Now with LoRA and QLoRA.

**Answer:**

### State the assumptions first

Memory depends on optimizer implementation, gradient precision, whether FP32 master weights are retained, activation checkpointing, sequence length, batch size, attention implementation, and fragmentation. The estimates below are **parameter/optimizer-state estimates only**; activations, temporary buffers, CUDA/runtime allocations, and fragmentation are additional.

Use \(N=7\times10^9\) parameters. One BF16 value uses 2 bytes:

\[
7\text{B}\times2 = 14\text{ GB decimal}\approx13.0\text{ GiB}
\]

(A “7B” model’s exact parameter count varies, so this is an approximation.)

### Full fine-tuning with Adam

A common mixed-precision accounting assumes:

| State | Bytes/parameter | 7B estimate |
|---|---:|---:|
| BF16 model weights | 2 | 14 GB |
| BF16 gradients (assumed) | 2 | 14 GB |
| FP32 Adam first moment \(m\) | 4 | 28 GB |
| FP32 Adam second moment \(v\) | 4 | 28 GB |
| Optional FP32 master weights | 4 | 28 GB |
| **Total with master copy** | **16** | **112 GB \(\approx104.3\) GiB** |

Without the FP32 master copy, that accounting is about **84 GB decimal** (~78.2 GiB). Some frameworks use FP32 gradients or different optimizer/state layouts; FP32 gradients would add about 14 GB in this simplified 7B calculation. Thus the often-quoted estimate is roughly **14–18 bytes per parameter** (about **98–126 GB decimal** for 7B) before activations and runtime overhead, depending on assumptions. Do not treat 112 GB as a guaranteed exact requirement.

### LoRA

With LoRA, the base weights are frozen in BF16, so the base alone is about **14 GB decimal** (~13 GiB). Gradients and Adam states apply to the much smaller adapter parameter count, not all 7B base parameters. The total is approximately:

\[
\text{base weights }(14\text{ GB})
+ \text{adapter weights/gradients/optimizer}
+ \text{activations and runtime buffers}
\]

Adapter-state memory depends on rank, target modules, and optimizer precision. Activations can dominate, especially with long sequences or large batches, so LoRA does not mean “14 GB and nothing else.”

### QLoRA

For a 4-bit quantized frozen base, the raw lower-bound weight storage is:

\[
7\text{B}\times0.5\text{ byte}=3.5\text{ GB decimal}\approx3.26\text{ GiB}
\]

Actual base storage is higher because of quantization scales/metadata, alignment, non-quantized modules, and implementation details. Add trainable LoRA weights, their gradients and optimizer state, activations, temporary dequantization/compute buffers, and runtime overhead. QLoRA therefore reduces base-weight memory substantially, but the exact GPU requirement is configuration-dependent; sequence length, batch size, checkpointing, kernels, and model architecture still matter.

### Practical takeaway

- **Full FT:** Roughly 100+ GB of parameter/optimizer state under common mixed-precision Adam assumptions, before activations; often requires multi-GPU sharding for a 7B model and practical context/batch sizes.
- **LoRA BF16:** About 14 GB for frozen base weights plus small adapter state and activations.
- **QLoRA 4-bit:** About 3.5 GB raw base-weight lower bound, plus quantization overhead, adapters, activations, and runtime buffers.

Use a memory profiler on the actual training stack and target sequence/batch configuration before choosing hardware.

### Concise interview answer

“For 7B parameters, BF16 weights alone are \(7\text{B}\times2\) bytes, or about 14 GB decimal. A common full-Adam mixed-precision estimate adds BF16 gradients, two FP32 moments, and sometimes FP32 master weights: about 14–16 bytes per parameter, or roughly 98–112 GB before activations; alternate gradient/master-state implementations can raise it further. LoRA keeps the 14 GB BF16 base frozen and adds optimizer state only for adapters. QLoRA’s 4-bit base has a 3.5 GB raw lower bound, plus quantization metadata, adapters, activations, and buffers. These are estimates, not complete GPU sizing.”

### Revision summary

| Method | Base weight estimate | Other important memory |
|---|---:|---|
| Full BF16 + Adam | 14 GB weights | Gradients + FP32 \(m,v\) + optional master copy: commonly ~98–112 GB state total before activations. |
| LoRA BF16 | 14 GB frozen base | Adapter gradients/optimizer + activations/buffers. |
| QLoRA 4-bit | 3.5 GB raw lower bound | Quantization metadata + adapter state + activations/buffers. |
| Exact sizing | Not a parameter-count-only calculation | Profile actual batch, sequence, kernels, and framework. |

<br><br><br>

## How do you fine-tune a model for a specific domain (legal, medical, finance)?

**Answer:**

### Begin with the domain requirement and risk

“Domain adaptation” may mean better understanding of domain language, following a specialized workflow, producing a standard format, or answering domain facts. Diagnose which need is failing before selecting training:

- Use **RAG or authoritative APIs** for current laws, policies, prices, clinical references, or user records that must be cited or updated.
- Use **continued pre-training** when the base model lacks broad exposure to domain text or terminology.
- Use **SFT/PEFT** when the model needs to follow stable domain-specific instructions, formats, or task procedures.
- Combine methods when the model needs both specialized behavior and current, source-grounded knowledge.

For legal, medical, and financial applications, model fine-tuning does not confer professional authority or replace licensed review, governance, and risk controls.

### A domain adaptation workflow

1. **Define scope and acceptance criteria:** Specify users, permitted tasks, prohibited decisions, escalation behavior, and quality/safety thresholds.
2. **Choose authoritative data:** Verify rights, provenance, privacy basis, retention, and domain-expert approval. Keep source versions and effective dates.
3. **Curate examples:** Cover normal cases, edge cases, jurisdiction/locale or patient/product distinctions where applicable, uncertainty, citations, and safe refusal/escalation.
4. **Select the adaptation path:** Benchmark prompting/RAG first; then compare continual pre-training, SFT, PEFT, or combinations based on the failure type.
5. **Prevent leakage and contamination:** Deduplicate, redact sensitive data, and split evaluation by source, time, entity, or organization to avoid near-duplicate leakage.
6. **Evaluate rigorously:** Test domain accuracy, source support, calibration/abstention, safety, subgroup/language slices, general capability retention, and out-of-distribution cases with domain-qualified reviewers.
7. **Deploy with controls:** Version data/model/adapters, use staged rollout, maintain human oversight, monitor drift and incidents, and retain rollback.

### Concise interview answer

“I first distinguish a knowledge problem from a behavior or terminology problem. Current domain facts should usually come from authorized RAG or source APIs; continual pre-training can improve domain language exposure, while SFT/PEFT can teach stable task behavior and formats. I use expert-reviewed, rights-cleared data, preserve provenance and effective dates, split evaluation to prevent leakage, and test domain accuracy, citations, safety, abstention, and general-capability regressions. For high-stakes domains, adaptation supplements—not replaces—professional oversight and governance.”

### Revision summary

| Need | Candidate approach |
|---|---|
| Current/citable domain facts | RAG or authoritative API. |
| Broad domain language adaptation | Continued pre-training. |
| Stable task behavior/style/format | SFT or PEFT. |
| High-stakes decisions | Domain validation, explicit limits, human oversight. |
| Release | Provenance, leakage controls, evaluation, monitoring, rollback. |

<br><br><br>

## What is continual pre-training, and when would you use it?

**Answer:**

### Definition

**Continual pre-training** (also called continued or domain-adaptive pre-training) continues the pre-training objective of an existing language model on additional, usually unlabeled or weakly labeled, text. For a causal language model, this commonly means continuing next-token prediction on a new corpus. The goal is to adapt representations and language modeling to a domain, language, or updated data distribution—not directly to teach a specific instruction-response behavior.

### When to use it

It may be appropriate when the model has a broad, systematic gap in domain language or specialized text patterns and a sufficiently large, high-quality, rights-cleared corpus is available. If the goal is to follow a stable task instruction, SFT is more direct. If the goal is to provide current facts with citations, RAG is usually more appropriate than trying to bake facts into weights.

### Risks and controls

Continued training can cause catastrophic forgetting, overfit to a narrow corpus, memorize sensitive content, or shift general capabilities. Data quality, duplication, contamination, and distribution balance matter. Mix general and domain data where retention is important, use conservative optimization, evaluate old and new capabilities, and retain the original checkpoint for rollback. Validate licensing, privacy, and data provenance.

### Concise interview answer

“Continual pre-training continues the model’s original language-modeling objective on additional text, often to improve domain or language coverage. It is useful for broad vocabulary and distribution adaptation when I have a large, governed corpus. It is not the same as SFT, which teaches desired responses, and it is usually not the right way to keep changing facts current. I mitigate forgetting and memorization with data mixtures, conservative training, provenance controls, and regression evaluations.”

### Revision summary

| Training stage | Data/objective | Purpose |
|---|---|---|
| Continual pre-training | Additional text; usually original LM objective. | Broader domain/language distribution adaptation. |
| SFT | Demonstration input-target pairs. | Teach task and response behavior. |
| RAG | Retrieved external evidence at inference. | Fresh, citable knowledge. |
| Main risk | Narrow training distribution. | Forgetting, memorization, and regressions. |

<br><br><br>

## How do you merge multiple LoRA adapters?

**Answer:**

### First clarify what “merge” means

There are two distinct operations:

1. **Merge one adapter into its compatible base:** For a LoRA update \(\Delta W_i=s_iB_iA_i\), compute an effective weight \(W'=W_0+\Delta W_i\) for the targeted modules. This can simplify serving by removing the separate adapter operation, but often creates a full-precision or higher-precision merged checkpoint.
2. **Combine multiple adapters:** Construct one effective update from several adapters, for example a weighted sum \(\Delta W=\sum_i \lambda_i\Delta W_i\), where the coefficients and any normalization are chosen deliberately. This is not guaranteed to preserve each task’s behavior.

### Compatibility and workflow

Before merging, verify that adapters share the same base checkpoint, architecture, tokenizer, target modules, tensor shapes, and compatible configuration. If adapters were trained on different base revisions, their deltas generally cannot be assumed to combine meaningfully.

1. Preserve and version the base model and each adapter.
2. Decide whether to load adapters dynamically, merge one adapter, or combine updates.
3. Choose merge coefficients or a supported composition method; do not assume simple addition is optimal.
4. Apply the operation in a numerically suitable precision and record exact tooling/configuration.
5. Validate tensor shapes, NaNs, and model loading; compare output behavior with each source adapter and the intended combined behavior.
6. Run task-specific, regression, safety, and latency evaluations before deployment.
7. Retain the original adapters and rollback path.

Adapters trained for conflicting objectives can interfere. Dynamic routing or keeping adapters separate may be better than merging when tasks are distinct or require independent updates. Quantized bases may require dequantization or special supported merge paths; details depend on the library.

### Concise interview answer

“Merging one LoRA adapter adds its low-rank delta to the compatible base weights; combining multiple adapters may use a weighted combination of their deltas or another supported composition method. I first verify they use the same compatible base, architecture, modules, and shapes. I preserve originals, record precision and merge coefficients, validate the resulting checkpoint, and test each task plus regressions. If tasks conflict or need independent control, dynamic adapter routing is safer than forcing a merge.”

### Revision summary

| Operation | Meaning |
|---|---|
| Adapter merge | \(W'=W_0+sBA\) for compatible target weights. |
| Multi-adapter composition | Combine deltas, often with task-specific weights/methods. |
| Preconditions | Compatible base, architecture, module targets, shapes/configuration. |
| Risks | Task interference, precision issues, incompatibility. |
| Alternative | Keep adapters separate and route dynamically. |

<br><br><br>

## What is the difference between SFT (Supervised Fine-Tuning) and alignment training?

**Answer:**

### SFT

**Supervised fine-tuning (SFT)** trains on demonstrations: given an input or conversation context, the model is optimized to reproduce a target response. It teaches the model how to perform tasks and follow examples, using supervised targets.

### Alignment training

**Alignment training** is a broader, less precisely bounded term for methods intended to make model behavior better match specified human preferences, policies, or values. It can include preference optimization (such as RLHF or DPO), safety training, constitutional/self-critique methods, and in some usage SFT itself. Therefore, SFT and alignment training are not mutually exclusive categories: SFT may be one stage in an alignment pipeline, while preference-based alignment uses comparative or reward signals beyond direct demonstrations.

### Key distinction

| Dimension | SFT | Preference/alignment methods |
|---|---|---|
| Typical signal | Example input paired with desired output. | Relative preferences, reward, policy constraints, or safety criteria. |
| Learning target | Imitate demonstrations. | Shift behavior toward a chosen preference/policy objective. |
| Common methods | Instruction tuning, supervised response training. | RLHF/PPO, DPO, RLAIF, and other preference/policy methods. |
| Limitation | Learns what examples show; coverage is limited. | Depends on quality and completeness of the preference/policy signal. |

Neither guarantees truth, robustness, or universal agreement on values. Evaluate task capability and safety separately, and be explicit about what “alignment” means in the context of the question.

### Concise interview answer

“SFT is a specific supervised objective: imitate curated input-output demonstrations. Alignment training is a broader umbrella for methods that steer behavior toward human preferences or policy constraints; it can include SFT, but often refers to additional preference or reward optimization such as RLHF or DPO. The distinction is the supervision signal—demonstrations versus preference/policy feedback—not simply whether one is aligned. Both are limited by data and objectives, so I evaluate capability, safety, and regressions independently.”

### Revision summary

| Term | Signal | Relationship |
|---|---|---|
| SFT | Desired response demonstrations. | Can be part of alignment pipeline. |
| Preference optimization | Relative comparisons/rewards/policy. | Additional behavior-steering methods. |
| Alignment | Broad objective category. | Define the intended values/policies explicitly. |
| Shared caveat | N/A | No training signal alone guarantees truth or safety. |

<br><br><br>

## What is RLAIF (RL from AI Feedback), and how does it differ from RLHF?

**Answer:**

### Definition

**RLAIF (Reinforcement Learning from AI Feedback)** uses an AI model to provide feedback—such as comparisons, critiques, or preference labels—in a reinforcement-learning or preference-optimization pipeline. The AI feedback may train a reward model or directly form preference pairs, depending on the method. It can reduce reliance on human annotations for some feedback, but the exact pipeline varies.

**RLHF** uses human judgments as the preference signal, often with a learned reward model and an RL policy-optimization stage. RLAIF changes or supplements the source of feedback; it does not necessarily mean every later training step is different.

### Comparison

| Dimension | RLHF | RLAIF |
|---|---|---|
| Feedback source | Human annotators or experts. | AI judge/critic, sometimes combined with human labels. |
| Potential advantage | Direct human judgment and domain expertise. | Scalable, consistent-at-scale feedback generation. |
| Main risk | Cost, disagreement, fatigue, and rubric variation. | Judge bias, correlated model errors, self-preference, and reward hacking. |
| Quality control | Annotation guidelines, adjudication, agreement checks. | Calibration against human labels, audits, and independent tests. |

AI feedback is a proxy, not ground truth. If the judge and policy share model families or training data, errors may be correlated. Use diverse prompts and judge models where appropriate, human audits, explicit rubrics, and independent capability/safety evaluation. High-stakes domain feedback should not be replaced by an unvalidated model judge.

### Concise interview answer

“RLAIF uses AI-generated judgments or preferences to guide a reinforcement or preference-optimization process, while RLHF uses human feedback. The optimization stage can otherwise be similar, and RLAIF may supplement rather than replace humans. It can scale feedback collection, but the AI judge can be biased or share the policy model’s errors. I calibrate it against human judgments, audit difficult cases, use clear rubrics, and evaluate the final model independently.”

### Revision summary

| Aspect | RLHF | RLAIF |
|---|---|---|
| Feedback generator | Human. | AI model. |
| Scalability | Human labeling can be costly. | Potentially faster and broader. |
| Main concern | Agreement and annotation quality. | Judge bias/correlation and proxy errors. |
| Good practice | Rubrics and adjudication. | Human calibration, audits, independent evaluation. |

<br><br><br>

## What is Constitutional AI, and how does it differ from RLHF?

**Answer:**

### Core idea

**Constitutional AI (CAI)** is an approach to training assistants using an explicit set of principles—a “constitution”—to guide critiques and revisions of model outputs. In the approach described by Anthropic, a model first critiques and revises responses against written principles using supervised learning, then AI-generated comparisons informed by those principles can provide preference data for a further preference-optimization stage. Implementations and later variants can differ; the important idea is making the behavioral criteria explicit and using them to generate or evaluate feedback.

### How it differs from RLHF

RLHF typically uses human preference judgments as a central feedback signal, often to train a reward model and then optimize the policy. CAI makes a written set of principles central to critique and preference generation, and can use AI feedback to reduce the amount of direct human labeling. It does not imply that humans are unnecessary: people define and review the principles, assess difficult cases, and evaluate whether the system follows its intended policy.

| Aspect | Constitutional AI | Typical RLHF |
|---|---|---|
| Guidance | Explicit written principles. | Human preference judgments and annotation rubric. |
| Feedback generation | May use model critiques/revisions and AI comparisons against principles. | Human comparisons commonly train a reward signal. |
| Strength | Criteria are inspectable and can scale feedback generation. | Direct human preferences can capture judgments not covered by a written rule set. |
| Risks | Principles may be incomplete, conflicting, or misinterpreted by the model. | Annotator disagreement, cost, and reward-model limitations. |

Neither approach guarantees harmlessness or correctness. Principles can encode bias or leave ambiguous cases unresolved; model-generated critiques can also be wrong. Evaluate against independent human-reviewed test cases, measure regressions, and maintain escalation and monitoring.

### Concise interview answer

“Constitutional AI uses an explicit set of principles to guide model self-critique and revision and, in some implementations, to generate AI preference feedback for further training. Typical RLHF relies more directly on human preference labels, often through a reward model and policy optimization. CAI can make the criteria more explicit and scale feedback, but the principles and AI critiques can be incomplete or biased. Human review and independent safety evaluation remain necessary.”

### Revision summary

| Concept | Takeaway |
|---|---|
| Constitution | Written principles used to guide critiques and preferences. |
| Feedback | Can be generated by an AI following those principles. |
| Difference from typical RLHF | More explicit principle-based feedback; less dependence on direct labels in some stages. |
| Limitation | Principles and model critiques require validation and human oversight. |

<br><br><br>

## What is RLVR (Reinforcement Learning with Verifiable Rewards), and when does it beat a learned reward model?

**Answer:**

### Definition

**RLVR (Reinforcement Learning with Verifiable Rewards)** trains or optimizes a model using rewards that can be checked by a verifier against an explicit criterion, rather than relying only on a learned reward model's judgment. Examples include checking whether a generated program passes specified tests, whether a mathematical result matches an accepted answer, or whether a structured output satisfies a formal constraint. A verifier may be deterministic, but only relative to the specification and test coverage it implements.

### When verifiable rewards are preferable

RLVR is especially attractive when the task has an objective, reliable, and sufficiently informative checker. It avoids some problems of learned reward models, such as subjective label noise, reward-model generalization errors, and exploiting patterns the reward model scores highly without satisfying the real task.

| Task property | Verifiable reward is a strong fit when… |
|---|---|
| Objective correctness | There is a trusted answer, executable test, proof checker, or formal constraint. |
| Repeatability | The same valid output consistently receives the same result. |
| Coverage | Tests or checks cover meaningful cases rather than only a narrow benchmark. |
| Reward usefulness | The verifier provides enough signal to guide learning, possibly with partial checks. |

For open-ended writing, empathy, nuanced policy judgments, or subjective quality, there may be no complete verifier. A learned reward model or human/AI preference feedback may be more practical, potentially combined with verifiable constraints.

### Important caveats

A verifier is only as good as its specification. Weak unit tests can reward code that passes tests but is incorrect elsewhere; exact-match checks can reject equivalent answers; incomplete formal constraints can leave loopholes. Models may optimize for the checker rather than the intended outcome. Validate verifier correctness and coverage, use hidden or diverse tests where appropriate, inspect reward hacking, and separately evaluate real-world quality and safety.

### Concise interview answer

“RLVR uses rewards checked against explicit criteria—for example, execution tests, exact mathematical results, or formal constraints—instead of relying solely on a learned preference reward. It is preferable when the task has a trustworthy, broad-coverage verifier, because the signal is more directly tied to correctness and less vulnerable to reward-model error. For subjective tasks, learned or human preference signals may still be needed. A verifier can itself be incomplete, so I test its coverage and watch for reward hacking.”

### Revision summary

| Reward type | Best suited for | Main limitation |
|---|---|---|
| Verifiable | Objective tasks with reliable checks. | Checker/specification gaps and gaming. |
| Learned reward | Nuanced or subjective preferences. | Approximation error and reward hacking. |
| Hybrid | Tasks with both hard constraints and subjective quality. | Requires independent evaluation of both signals. |

<br><br><br>

## What is knowledge distillation for fine-tuning, and what are the legal considerations?

**Answer:**

### What distillation means

**Knowledge distillation** trains a student model using information from a teacher model, with the goal of transferring useful behavior into a smaller, cheaper, or otherwise different model. The student may learn from teacher-generated input-output demonstrations, preference labels, intermediate representations, or softened probability distributions (logits), depending on the method and what the teacher exposes. In practical fine-tuning, synthetic teacher responses are often curated and used as supervised targets.

Distillation can reduce inference cost or latency and adapt a smaller model to a defined task. It does not guarantee that the student retains all teacher capabilities: it can inherit errors and biases, lose coverage, or overfit to the teacher’s response style. Teacher-generated data should be filtered, tested for diversity and correctness, and evaluated independently from the teacher.

### Legal and governance considerations

There is no single universal rule that makes distillation automatically permitted or prohibited. Review the applicable law, contracts, model and API terms, and organizational policies for the specific teacher, data, jurisdictions, and use case. In particular:

- Confirm that the teacher’s license or service terms permit generating training data and using it to train or improve another model; API access alone should not be assumed to grant these rights.
- Check the rights and provenance of prompts, source data, and teacher outputs, including restrictions on redistribution or commercial use.
- Assess privacy and confidentiality: do not send personal, sensitive, or confidential inputs to a teacher service without an approved basis and safeguards; control retention and prevent memorization or disclosure.
- Review intellectual-property, attribution, and output-use obligations with qualified counsel where material; the legal treatment of generated outputs can depend on facts and jurisdiction.
- Preserve records of model/version, prompts, data sources, filtering, permissions, and downstream use so the process is auditable.

This is a risk checklist, not legal advice. Where rights or terms are unclear, pause the use of that source and obtain guidance from the organization’s legal/privacy teams.

### Concise interview answer

“Distillation transfers behavior from a teacher to a student, commonly by training on curated teacher-generated examples, though some methods use logits or other signals. It can lower serving cost but may transfer errors and does not guarantee capability parity. Before using teacher outputs, I verify the model/API terms and data rights, privacy and confidentiality controls, and jurisdiction-specific obligations; I retain provenance and involve counsel when rights are unclear.”

### Revision summary

| Area | Practical point |
|---|---|
| Teacher signal | Demonstrations, preferences, logits, or other available outputs. |
| Benefit | Potentially smaller or more efficient task model. |
| Technical risk | Teacher errors, bias, missing capabilities, or narrow imitation. |
| Legal/governance | Verify terms, rights, privacy, provenance, and intended use. |

<br><br><br>

## Your fine-tuned LLM produces factually wrong outputs due to training data quality issues. How do you fix it?

**Answer:**

### Treat it as a data and system-quality incident

Do not start by training longer or adding more examples blindly: that can reinforce the bad signal. First determine whether the errors come from incorrect, stale, contradictory, duplicated, mislabeled, or out-of-scope training data—or from retrieval, prompting, model limitations, or evaluation defects.

### Diagnose and remediate

1. **Contain impact:** If errors can cause material harm, reduce exposure, add human review or abstention, and roll back to a known-good model if needed.
2. **Reproduce and classify failures:** Build a representative error set; trace each answer to its training example, retrieval evidence, source version, or annotation where possible.
3. **Audit data lineage and labels:** Check source authority, effective dates, transformations, deduplication, labeling rules, conflicts, and train/evaluation contamination. Have qualified domain reviewers adjudicate disputed facts.
4. **Correct the corpus at the source:** Remove or repair demonstrably wrong or superseded records, mark conflicting claims with provenance and dates, and exclude data that cannot be validated. Do not silently convert uncertainty into a confident target.
5. **Choose the right knowledge mechanism:** If facts change or must be cited, prefer authoritative retrieval or APIs with freshness and source attribution. Fine-tune for stable behavior, not as the sole store of volatile facts.
6. **Retrain only after data remediation:** Rebuild a versioned dataset, keep a clean holdout, and compare the corrected model with the previous model and base model.
7. **Evaluate and monitor:** Test factual accuracy, evidence support, citation correctness, abstention, freshness, and regressions by domain slice. Use a staged rollout and monitor new failures.

### Concise interview answer

“I contain risk, reproduce and categorize the failures, then trace them to their source data, labels, or retrieval path. I have domain experts validate corrections, remove or version stale and unsupported examples, and prevent leakage into evaluation. For facts that change, I move knowledge to authoritative, citable retrieval rather than trying to memorize it in weights. Only then do I retrain and evaluate accuracy, evidence support, abstention, and regressions before a monitored rollout.”

### Revision summary

| Step | Goal |
|---|---|
| Contain and reproduce | Limit harm and establish a reproducible failure set. |
| Trace and validate | Find root cause; use authoritative domain review. |
| Repair/version data | Correct, remove, or date unsupported/stale examples. |
| Select architecture | RAG/API for changing facts; fine-tuning for stable behavior. |
| Verify release | Clean holdout, targeted metrics, staged rollout, monitoring. |

<br><br><br>

## You must choose between LoRA and full fine-tuning for a domain-specific assistant. How do you decide?

**Answer:**

### Start with the objective and a measured baseline

I first clarify the failure the domain assistant must solve. If it mainly needs current facts, citations, or access to private records, I would evaluate RAG or an API before either training option. If the gap is stable behavior, task performance, terminology, or response format, compare LoRA and full fine-tuning on the same held-out domain evaluation set.

### Decision factors

| Factor | LoRA is attractive when… | Full fine-tuning is attractive when… |
|---|---|---|
| Compute and training budget | GPU memory, training time, or budget is constrained. | Adequate compute and operational capacity are available. |
| Update and deployment | Small adapters, fast iteration, or multiple task-specific variants are useful. | A single integrated checkpoint is desired and model-wide adaptation is justified. |
| Expected adaptation | The task can be learned through low-rank updates to selected modules. | Experiments show the adapter’s capacity is insufficient for the required shift. |
| Rollback and model management | Isolated adapters simplify versioning and rollback. | A consolidated model is preferable despite full-checkpoint management. |
| Evaluation results | It meets quality, safety, and latency thresholds with acceptable regressions. | It delivers a meaningful, reproducible improvement over LoRA. |

These are tendencies, not guarantees. Full fine-tuning changes more parameters but is not automatically more accurate; LoRA is not automatically sufficient. The outcome depends on data, target modules, rank, training setup, and task.

### Practical comparison process

1. Establish a prompt/RAG baseline and define quality, safety, latency, memory, and cost thresholds.
2. Create a rights-cleared, representative dataset and a leakage-resistant held-out evaluation set.
3. Train a LoRA baseline with a small, controlled search over rank/target modules and compare it with the unmodified model.
4. Escalate to full fine-tuning only if LoRA repeatedly misses a justified capability target and the expected benefit outweighs cost, regression, and maintenance risks.
5. Evaluate both on in-domain tasks, safety/abstention, general capability retention, calibration, and deployment performance.
6. Choose the simplest option that meets the acceptance criteria; preserve versioning and rollback.

### Concise interview answer

“I decide from the measured task gap, not from a blanket rule. For current knowledge I would first use retrieval or APIs. For stable behavior adaptation, I benchmark LoRA because it is cheaper to train, easier to version, and can support separate adapters. I consider full fine-tuning when a well-controlled LoRA experiment cannot meet a defined quality target and broader parameter updates are worth the compute and regression risk. I compare both on the same held-out domain, safety, retention, and serving-cost metrics.”

### Revision summary

| Decision | Preferred approach |
|---|---|
| Changing/citable facts | RAG or authoritative API, not weight updates alone. |
| Limited compute or modular updates | Try LoRA first. |
| LoRA demonstrably insufficient | Evaluate full fine-tuning against explicit acceptance criteria. |
| Final selection | Best measured quality/safety/cost trade-off with rollback. |

<br><br><br>

## Your fine-tuned model memorized training data verbatim instead of learning patterns. How do you fix overfitting?

**Answer:**

### Diagnose before changing the training run

First confirm that the behavior is memorization rather than legitimate reproduction of a common phrase, a retrieval/cache leak, or a flawed evaluation prompt. Test exact and near-duplicate prompts, paraphrases, and held-out examples; inspect whether outputs reproduce rare sequences, identifiers, or sensitive material. Trace examples to dataset records and determine whether the cause is duplication, narrow coverage, excessive training, leakage, or sensitive data inclusion.

If personal, confidential, or otherwise restricted information is exposed, treat it as a privacy/security incident under the organization’s process: contain exposure, restrict the affected model or endpoint, and involve the appropriate privacy and security owners. Removing a record from the next dataset does not by itself guarantee that the trained model has unlearned it.

### Reduce memorization and improve generalization

1. **Fix the corpus:** Remove unauthorized or unnecessary sensitive records; deduplicate exact and near-duplicate examples; correct labels; broaden coverage with representative, rights-cleared examples instead of repeating a few templates.
2. **Reduce overtraining:** Lower epochs or training duration, use early stopping based on a leakage-resistant validation set, and tune learning rate and regularization conservatively.
3. **Improve task formulation:** Train on varied inputs and desired behaviors rather than repeated verbatim target strings; avoid including secrets or unique identifiers when they are not necessary for the task.
4. **Consider model/adaptation choices:** Use parameter-efficient adaptation or a less expressive/smaller model if it meets quality requirements, but do not assume LoRA alone prevents memorization.
5. **Test generalization and extraction risk:** Compare train/validation behavior, exact and approximate match rates, canary or privacy tests where appropriate, and useful task performance. Do not rely on one metric as proof that extraction is impossible.
6. **Retrain and release safely:** Version the cleaned data and model, follow incident procedures for affected checkpoints, run regression and privacy evaluations, and stage deployment with monitoring and rollback.

### Concise interview answer

“I verify the output is model memorization, identify whether duplicates, narrow data, excessive training, leakage, or sensitive examples caused it, and contain any privacy exposure. I remove unauthorized or unnecessary sensitive records, deduplicate and diversify the corpus, reduce training duration, and use early stopping on a leakage-resistant validation set. Then I test both task generalization and extraction risk. I would not claim that deleting data or switching to LoRA automatically erases memorized information from an existing checkpoint.”

### Revision summary

| Action | Purpose |
|---|---|
| Verify and trace | Distinguish model memorization from retrieval, prompt, or test artifacts. |
| Clean corpus | Remove sensitive/unauthorized data and duplicates; improve coverage. |
| Tune training | Reduce overtraining and use independent validation/early stopping. |
| Handle exposure | Follow privacy/security incident processes; do not assume deletion unlearns weights. |
| Release | Evaluate utility and extraction risk; stage, monitor, and retain rollback. |

<br><br><br>

## Your fine-tuned LLM forgot its general capabilities after domain-specific fine-tuning. How do you fix catastrophic forgetting?

**Answer:**

### Diagnose the regression

**Catastrophic forgetting** is a substantial loss of previously learned capabilities after further training on a narrower or different data distribution. Establish that the apparent loss is reproducible and not caused by changed prompts, decoding settings, tokenizer/template differences, or evaluation noise. Compare the fine-tuned checkpoint with the base model on a fixed general-capability suite and domain tasks, broken down by skill and language.

### Mitigation options

1. **Rebalance training data:** Mix representative general data with domain examples, using a justified sampling ratio rather than letting the narrow domain corpus dominate. Avoid indiscriminate replay of data that is unlicensed or otherwise inappropriate.
2. **Use less disruptive updates:** Lower the learning rate, reduce training steps/epochs, use early stopping, and consider parameter-efficient methods such as LoRA. These can reduce the extent of updates but do not guarantee retention.
3. **Constrain or stage adaptation:** Train on a curriculum, freeze selected layers when supported by evidence, or use regularization/knowledge-preservation methods if the workload justifies their complexity.
4. **Keep capabilities modular:** For distinct tasks, retain the base model and use separate adapters or routing rather than baking every capability into one checkpoint.
5. **Evaluate trade-offs continuously:** Track domain quality and general capability retention throughout training. Set regression thresholds and stop or revert if they are exceeded.
6. **Deploy with rollback:** Version the base, data, and adapters/checkpoints; perform a staged rollout and monitor the same evaluations in production.

The right remedy depends on which capabilities regressed and why. A general-data mixture is a common starting point, not a universal fix; training examples and evaluation must reflect the intended deployment distribution.

### Concise interview answer

“I reproduce the regression against a fixed base-model baseline and check for evaluation or serving changes. Then I reduce the narrow-domain update’s impact—typically by mixing in representative general data, lowering the learning rate or training duration, and using early stopping; I may try LoRA or modular adapters. I track domain gains and general-capability retention together, set regression limits, and keep a rollback path. No single method guarantees that forgetting is eliminated.”

### Revision summary

| Lever | How it helps | Caveat |
|---|---|---|
| General-data mixture | Preserves exposure to prior task distributions. | Sampling must be representative and appropriately licensed. |
| Conservative optimization | Limits destructive updates. | May reduce domain adaptation speed or magnitude. |
| LoRA/adapters | Makes changes smaller or separable. | Does not guarantee no forgetting. |
| Regression suite and rollback | Detects and limits deployment impact. | Must cover actual capabilities and use cases. |

<br><br><br>

## Your RLHF preference data has low annotator agreement. How do you ensure data quality?

**Answer:**

### Low agreement is a signal to investigate

Low inter-annotator agreement does not automatically mean annotators are careless: the task may be subjective, the rubric ambiguous, examples under-specified, or outputs genuinely close. Do not simply discard disagreements or force a single label before understanding their cause.

### Improve the preference data

1. **Inspect disagreements by category:** Separate rubric ambiguity, missing context, domain expertise gaps, ties, policy conflicts, and random or inconsistent judgments.
2. **Clarify the decision protocol:** Define the preference dimensions and priority rules (for example, correctness before style), specify how to handle ties and unjudgeable cases, and provide calibrated examples including difficult boundary cases.
3. **Train and calibrate annotators:** Use practice rounds, feedback, and periodic calibration. Require domain-qualified reviewers where the judgment depends on specialized knowledge.
4. **Improve presentation:** Randomize response order, hide model identity where feasible, provide the same relevant context for each candidate, and collect a reason code or concise rationale when it helps diagnose labels.
5. **Measure quality appropriately:** Track agreement with a statistic suited to the label design, such as pairwise agreement or a chance-corrected measure, but interpret it alongside class balance, disagreement categories, and adjudication outcomes. Agreement statistics alone do not prove labels are correct.
6. **Adjudicate selectively:** Escalate high-impact and systematically disputed cases to a senior or expert reviewer. Preserve genuine ambiguity as a tie/uncertain label when the method supports it.
7. **Audit and monitor the resulting signal:** Maintain gold/check examples, review annotator drift and quality, compare preference outcomes with independent evaluations, and test the trained model for reward-model exploits or unwanted shifts.

### Concise interview answer

“I treat low agreement as a diagnostic rather than forcing consensus. I categorize disagreements, refine the rubric with priority rules and tie handling, calibrate annotators on difficult examples, and ensure the task supplies enough context and expertise. I track suitable agreement measures together with class balance and adjudication, keep genuine uncertainty where appropriate, and audit the learned reward and final policy against independent human-reviewed evaluations.”

### Revision summary

| Quality control | What it addresses |
|---|---|
| Disagreement analysis | Reveals ambiguous rubrics, expertise gaps, and true subjectivity. |
| Calibration and examples | Aligns annotators on the intended criteria. |
| Context and randomized presentation | Reduces avoidable judgment bias. |
| Agreement + adjudication | Measures consistency without treating agreement as ground truth. |
| Independent model evaluation | Detects reward/model failures beyond label consistency. |

<br><br><br>
