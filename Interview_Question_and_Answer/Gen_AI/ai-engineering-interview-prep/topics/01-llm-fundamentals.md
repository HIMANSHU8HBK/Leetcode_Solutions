# 01. LLM Fundamentals

Source entries are in their original order. Use the space after each heading to draft an answer.

## What are foundation models, and how have they changed AI engineering?

**Answer:**

### Core idea

A **foundation model** is a model trained on broad data at substantial scale so that it learns reusable representations or capabilities that can be adapted to many downstream tasks. It is a starting point, or foundation, rather than a model built for only one narrowly defined task. Large language models are one important family of foundation models; others can work with images, audio, video, structured data, or combinations of modalities.

For example, a language foundation model learns statistical and semantic patterns from text and can then be prompted to summarize, classify, extract information, answer questions, or generate code. A vision-language model may connect image content with text, enabling image question answering or visual search. These capabilities come from pretraining, but a model's outputs are still probabilistic and must be evaluated for the task and users it will serve.

### How a foundation model becomes an application

The pretrained model is only one part of a production AI system. An engineering team typically:

1. **Selects a model** based on task quality, context length, latency, cost, licensing, deployment options, and data-handling requirements.
2. **Adapts its behavior** using instructions and prompting first, then retrieval-augmented generation (RAG), fine-tuning, or other methods when justified by evidence.
3. **Connects it to application context and tools** where needed, such as trusted documents, databases, APIs, or constrained functions.
4. **Builds a reliable product around it**, including input/output validation, access control, privacy and safety controls, timeouts, retries, fallbacks, observability, and user experience.
5. **Evaluates and monitors the complete system** against representative tasks, failure cases, and production signals—not just a model benchmark.

The key distinction is between a model capability and a product guarantee. A model may be able to produce valid JSON, for instance, but a production workflow should still validate the output against a schema and handle invalid or incomplete responses.

### How they changed AI engineering

| Earlier task-specific approach | Foundation-model-centered approach |
|---|---|
| Build or train a separate model for each task, often requiring labeled examples. | Start with a broadly pretrained model and adapt it to multiple tasks. |
| Encode task behavior primarily in model parameters and task-specific pipelines. | Combine model instructions with application code, retrieved context, tools, policies, and evaluation. |
| Measure success mainly with task metrics such as accuracy or F1. | Measure the end-to-end experience: quality, groundedness, safety, latency, cost, reliability, and user outcomes. |
| Most failures are bounded by a defined input/output schema and task distribution. | Outputs are flexible and can be incorrect, inconsistent, unsafe, or malformed; guardrails and fallback paths matter. |
| Deployment often centers on serving a fixed model. | Teams may choose a hosted API, self-hosted open-weight model, or a routed combination, and manage prompts, model versions, retrieval, and inference together. |

This changes the engineer's work in several important ways:

- **From training every capability to composing capabilities.** A team can often establish a useful baseline with prompting and existing models before considering the expense and complexity of training. The job shifts toward deciding what should be done by the model and what should remain deterministic software.
- **From labeled-data-first to evaluation-first iteration.** A small, representative evaluation set can reveal whether prompting, RAG, fine-tuning, a different model, or a non-AI solution is appropriate. Reliable test cases are essential because small prompt or model changes can alter behavior.
- **From model-only thinking to system design.** Quality depends on data preparation, context selection, tool contracts, orchestration, permissions, output validation, and user interaction—not just parameter count or benchmark scores.
- **From offline deployment to continuous operations.** Models and providers change; prompts and knowledge bases change; traffic and user behavior change. Production systems need versioning, monitoring, regression checks, cost controls, and rollback plans.
- **From a single quality metric to explicit trade-offs.** A slightly better model may be too slow or costly. A smaller model may be preferable for high-volume classification, while a stronger model may be reserved for complex requests. Routing, caching, batching, quantization, or self-hosting can help, but must be validated against quality and operational constraints.

### Example: an internal policy assistant

Suppose a company wants employees to ask questions about internal policies. A traditional approach might collect labeled question-answer pairs and train a task-specific question-answering model. With a foundation model, the team could instead:

1. Use a representative test set of employee questions, including ambiguous, unanswerable, and access-restricted cases.
2. Retrieve relevant policy passages from an authorized, versioned document index and provide those passages as context.
3. Instruct the model to answer from that context, cite the supporting sources, and abstain when the evidence is insufficient.
4. Enforce document permissions before retrieval; the prompt alone is not an access-control mechanism.
5. Validate citations and response format, and provide a safe fallback when retrieval or generation fails.
6. Evaluate retrieval recall, answer correctness and groundedness, abstention behavior, latency, cost, and permission isolation.
7. Monitor failures and user feedback, update the knowledge index as policies change, and run regression evaluations before changing prompts or models.

This illustrates both the leverage and the limits: the foundation model supplies flexible language understanding and generation, while the surrounding system supplies current knowledge, authorization, predictable interfaces, and measurable quality.

### Important trade-offs and limitations

Foundation models reduce the need to build a separate model for every task, but they do **not** remove the need for engineering or domain expertise. They can hallucinate, reflect biases in data, be sensitive to prompt wording, expose sensitive information if systems are poorly designed, and perform unevenly across languages or user groups. A model's training data may also be stale or unknown, and a larger model is not automatically better for a given workload.

Choose the simplest approach that meets the measured requirements:

- Use **deterministic software** when rules are clear and exactness is required.
- Use **prompting** when a capable model can perform the task without changing its weights or requiring a large external knowledge base.
- Use **RAG** when answers must reflect private, changing, or attributable information.
- Use **fine-tuning** when repeated evaluation shows a persistent behavior or task adaptation gap that examples, prompting, and retrieval do not adequately address.
- Use a **hybrid system** when different parts of a workflow have different needs—for example, deterministic validation around model-generated content.

The right choice depends on error tolerance, data sensitivity, update frequency, scale, latency, cost, and the team's ability to operate the system.

### Concise interview answer

“A foundation model is a broadly pretrained model that can be adapted to many downstream tasks rather than being trained from scratch for one narrow task. LLMs are a prominent example, alongside vision, audio, and multimodal models. They changed AI engineering by making it practical to build applications through a combination of model capabilities, prompts, retrieval, tools, and conventional software, instead of training a separate model for every feature. The engineering focus has therefore expanded from model training to model selection, evaluation, context and data quality, system integration, security, latency, cost, and ongoing monitoring. In production, I treat the model as a probabilistic component—not as a source of guarantees—and validate the complete user workflow. For example, a policy assistant needs permission-aware retrieval, grounded answers with citations, abstention when evidence is missing, regression evaluations, and operational monitoring. I choose prompting, RAG, fine-tuning, or deterministic code based on measured requirements rather than assuming that a larger model or more training is always the answer.”

### Revision summary

| Term | Remember |
|---|---|
| Foundation model | Broadly pretrained, reusable starting point for downstream tasks. |
| Adaptation | Prompting, retrieval, fine-tuning, tools, or combinations of these. |
| Engineering shift | From task-specific model building toward composing and operating end-to-end AI systems. |
| Production principle | The model is probabilistic; validate, evaluate, secure, monitor, and provide fallbacks around it. |
| Senior-level decision | Select the simplest approach that meets quality, privacy, latency, cost, and reliability requirements. |

<br><br><br>

## What is a Large Language Model (LLM), and how does it work?

**Answer:**

<br><br><br>

## Inside ChatGPT: What Happens After You Hit Enter?

**Answer:**

<br><br><br>

## What is the Transformer architecture and how does it work?

**Answer:**

<br><br><br>

## What are the key components of the Transformer architecture?

**Answer:**

<br><br><br>

## Walk me through what happens, step by step, in one forward pass of a decoder-only Transformer.

**Answer:**

<br><br><br>

## What is tokenization in LLMs?

**Answer:**

<br><br><br>

## Explain BPE (Byte Pair Encoding).

**Answer:**

<br><br><br>

## Explain WordPiece and SentencePiece.

**Answer:**

<br><br><br>

## What is positional encoding, and why is it needed in Transformers?

**Answer:**

<br><br><br>

## What are embeddings?

**Answer:**

<br><br><br>

## Explain the Query(Q), Key(K), and Value(V) in attention.

**Answer:**

<br><br><br>

## What is self-attention, and how does it work in Transformers?

**Answer:**

<br><br><br>

## What is Cross Attention in Transformers?

**Answer:**

<br><br><br>

## Why do we scale the dot product attention by √dₖ in the Transformer architecture?

**Answer:**

<br><br><br>

## What is causal masking?

**Answer:**

<br><br><br>

## What are multi-head attention mechanisms? Why use multiple attention heads?

**Answer:**

<br><br><br>

## What are Feed-Forward Networks in LLMs?

**Answer:**

<br><br><br>

## What is Generative AI?

**Answer:**

<br><br><br>

## What is the context window in LLMs, and why does it matter?

**Answer:**

<br><br><br>

## Why is the context window limited in LLMs?

**Answer:**

<br><br><br>

## What is temperature in the context of LLMs, and how does it affect output?

**Answer:**

<br><br><br>

## Why is the first token slower than the rest in an LLM?

**Answer:**

<br><br><br>

## Explain Top-p (nucleus) sampling and Top-k sampling. How do they differ?

**Answer:**

<br><br><br>

## Compare greedy decoding, beam search, top-k, top-p, and temperature sampling. When does each fail?

**Answer:**

<br><br><br>

## What are logits, and how are they used in text generation?

**Answer:**

<br><br><br>

## What are stop tokens in LLMs, and how does an LLM know when to stop generating?

**Answer:**

<br><br><br>

## What is the difference between a stop token and a stop sequence?

**Answer:**

<br><br><br>

## What are skip connections (residual connections) in Transformers?

**Answer:**

<br><br><br>

## What is the difference between open-source and closed-source LLMs? When would you choose one over the other?

**Answer:**

<br><br><br>

## What is the difference between encoder-only, decoder-only, and encoder-decoder Transformer architectures?

**Answer:**

<br><br><br>

## What is KV cache, and how does it speed up inference?

**Answer:**

<br><br><br>

## Estimate the KV cache memory needed to serve a large model. How does it constrain batch size and context length?

**Answer:**

<br><br><br>

## KV Cache Compression

**Answer:**

<br><br><br>

## What is model distillation, and how is it used with LLMs?

**Answer:**

<br><br><br>

## What is Mixture of Experts (MoE), and how does it work in models like Mixtral?

**Answer:**

<br><br><br>

## What is the difference between dense and sparse models?

**Answer:**

<br><br><br>

## How does DeepSeek-V4 work?

**Answer:**

<br><br><br>

## What is Flash Attention?

**Answer:**

<br><br><br>

## What is Cross-Entropy Loss?

**Answer:**

<br><br><br>

## What is Grouped-Query Attention (GQA), and how does it differ from Multi-Head Attention (MHA)?

**Answer:**

<br><br><br>

## How does Sliding Window Attention work?

**Answer:**

<br><br><br>

## How do Attention Sinks work?

**Answer:**

<br><br><br>

## How does Rotary Position Embedding (RoPE) work, and why is it preferred over learned positional embeddings?

**Answer:**

<br><br><br>

## Explain Layer Normalization

**Answer:**

<br><br><br>

## Explain RMSNorm (Root Mean Square Layer Normalization)

**Answer:**

<br><br><br>

## Why do modern Transformers use Pre-LayerNorm (Pre-Norm) instead of Post-LayerNorm?

**Answer:**

<br><br><br>

## What are scaling laws (Chinchilla), and how do they guide model size vs training data decisions?

**Answer:**

<br><br><br>

## Your LLM keeps ignoring your instructions. How do you make it follow structured output formats?

**Answer:**

<br><br><br>

## Your LLM-powered tool hits the context window limit on long documents. How do you handle it?

**Answer:**

<br><br><br>

## Your LLM does not admit when it does not know the answer. How do you make it say "I don't know"?

**Answer:**

<br><br><br>

## Your LLM generates responses that are too verbose. How do you control response length?

**Answer:**

<br><br><br>

## Your LLM memorized proprietary training data and leaks it in responses. How do you prevent this?

**Answer:**

<br><br><br>

## Your LLM coding assistant generates outdated code using deprecated libraries. How do you fix it?

**Answer:**

<br><br><br>

## Your tokenizer splits important domain terms into meaningless subword pieces. How do you fix it?

**Answer:**

<br><br><br>

## Your Transformer's KV cache grows too large during long sequence generation. How do you manage memory?

**Answer:**

<br><br><br>

## Your Transformer runs out of memory on long documents due to quadratic self-attention. How do you scale it?

**Answer:**

<br><br><br>

## Your distilled student model fails on the complex reasoning that the teacher model handled. How do you close the gap?

**Answer:**

<br><br><br>

## After RLHF alignment, your LLM became safer but lost capability on hard tasks. How do you manage the alignment tax?

**Answer:**

<br><br><br>

## Your RLHF-trained LLM is gaming the reward model instead of being genuinely helpful. How do you fix reward hacking?

**Answer:**

<br><br><br>

## Your chatbot loses context after 10 turns in a conversation. How do you maintain a long conversation context?

**Answer:**

<br><br><br>

## Your chatbot fails when users switch topics mid-conversation. How do you handle topic switches?

**Answer:**

<br><br><br>

## Your QA system always generates an answer even when no answer exists in the context. How do you detect unanswerable questions?

**Answer:**

<br><br><br>

## Your summarization system hallucinated facts not in the original article. How do you fix it?

**Answer:**

<br><br><br>

## Your text generation repeats phrases in long outputs. How do you fix repetition?

**Answer:**

<br><br><br>

## Transformers work on text, so can they also understand images?

**Answer:**

<br><br><br>

## Small Language Models (SLMs)

**Answer:**

<br><br><br>

## Large Reasoning Models (LRMs)

**Answer:**

<br><br><br>

## Jev and System One Models

**Answer:**

<br><br><br>

## What are Autoregressive Models?

**Answer:**

<br><br><br>

## Explain the difference between autoregressive and masked language modeling.

**Answer:**

<br><br><br>

## Proximal Policy Optimization (PPO)

**Answer:**

<br><br><br>

## Direct Preference Optimization (DPO)

**Answer:**

<br><br><br>

## Group Relative Policy Optimization (GRPO)

**Answer:**

<br><br><br>

## Recursive Language Models (RLMs)

**Answer:**

<br><br><br>

## Continual Learning in LLMs

**Answer:**

<br><br><br>

## What is Recursive Self-Improvement (RSI)?

**Answer:**

<br><br><br>

## How do Diffusion Language Models (DLMs) work?

**Answer:**

<br><br><br>

## How Does LLM Watermarking Work?

**Answer:**

<br><br><br>

## How do RNNs and Transformers differ?

**Answer:**

<br><br><br>
