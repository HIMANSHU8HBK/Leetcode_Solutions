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

### Definition and core idea

A **large language model (LLM)** is a neural network trained on large text (and, in some systems, code or other modalities) to model sequences of tokens. “Large” usually refers to the scale of its parameters, training data, and computation; there is no universal parameter-count threshold that makes a model an LLM.

Most widely used generative LLMs are **autoregressive**: given the tokens so far, they estimate a probability distribution over the next token, choose or sample a token, append it to the sequence, and repeat. They do not generally retrieve a stored paragraph or formulate an answer as a human does. They generate a sequence according to learned statistical structure, conditioned on the prompt and any context provided to them.

For tokens \(x_1, x_2, \ldots, x_T\), an autoregressive model represents the sequence probability as:

\[
P(x_1,\ldots,x_T)=\prod_{t=1}^{T}P(x_t\mid x_1,\ldots,x_{t-1})
\]

At each position, the model uses the preceding context to predict the next token. This simple training objective, applied at scale, leads to useful capabilities such as following instructions, summarizing, translating, answering questions, and generating code. It does not guarantee that every output is true or logically valid.

### How an LLM is trained

1. **Prepare a training corpus.** Data may include text, code, and other permitted sources. Engineering work includes filtering low-quality or duplicated material, handling sensitive content, documenting provenance and licenses, and constructing representative data mixtures. Training data quality and composition affect what the model learns.
2. **Tokenize the data.** A tokenizer maps text into token IDs. A token may be a whole word, part of a word, punctuation, or a byte-level unit; tokens are not necessarily words.
3. **Pretrain with next-token prediction.** For each token position, the model predicts the next token from the preceding tokens. The training loss is commonly cross-entropy between the predicted distribution and the observed next token. During training, the actual preceding tokens are usually supplied when predicting later positions (teacher forcing).
4. **Update model parameters.** Backpropagation computes gradients of the loss, and an optimizer updates the parameters. This is repeated over many batches on accelerator hardware, often with distributed training. The model learns statistical patterns and representations useful for predicting the data, not a clean, guaranteed fact database.
5. **Post-train for useful interaction.** A base model may be further trained on instruction/response examples (supervised fine-tuning) and, depending on the training recipe, preference or feedback signals. Methods may include preference optimization or reinforcement learning. These stages can improve instruction following, style, and safety behavior, but they do not make behavior perfectly reliable and can introduce trade-offs.
6. **Evaluate before release.** Evaluation should cover task quality and capability as well as robustness, safety, privacy risks, bias, memorization, and performance on relevant user populations. Benchmarks are useful evidence, not a substitute for application-specific testing.

The exact data, architecture, objective, and post-training process vary by model. Avoid assuming that every LLM was trained on the same sources or aligned with the same method.

### How generation works at inference time

For a decoder-only Transformer LLM, generation can be understood in two stages:

1. **Prefill:** The system formats the conversation and any instructions or retrieved context into a prompt, tokenizes it, and runs the prompt tokens through the model. The causal attention mask allows each position to use only earlier positions (and itself). The model produces next-token scores, called **logits**, for the current end of the prompt. It also computes and can retain key/value (KV) tensors for attention.
2. **Decode:** The inference code converts the next-token logits into a probability distribution, selects a token according to the decoding configuration, appends that token, and runs the next step. The KV cache lets the model reuse attention keys and values from previous tokens rather than recomputing the full prefix on every step. Decoding continues until a stop condition is reached, such as an end-of-turn token, a configured stop sequence, or the output limit.

The output token IDs are then decoded into text. In a chat system, additional application logic may handle role markers, tool-call formats, safety checks, streaming, or structured-output validation.

For example, given the prompt “The capital of France is”, a model may assign high probability to the token “ Paris”. The inference system selects a token, adds it to the context, and repeats to produce more text. The example illustrates conditional prediction; it does not mean that the model executes a special “capital lookup” operation.

### What changes the generated answer?

The **model** supplies learned parameters, while the **inference configuration** governs how a response is produced:

- **Prompt and context:** Instructions, conversation history, and retrieved passages condition the prediction. Poor, irrelevant, conflicting, or unauthorized context can reduce answer quality.
- **Logits and probabilities:** Logits are unnormalized scores for the next token. A softmax converts them to probabilities.
- **Decoding:** Greedy selection takes the highest-probability token; sampling allows alternatives. Temperature can flatten or sharpen the distribution, while top-k or top-p sampling restricts the candidate set. These settings affect variation, not the model’s underlying knowledge or factual guarantees.
- **Stopping and output limits:** End-of-turn markers, stop sequences, and maximum output tokens control when generation ends.
- **System wrapper:** A product may add retrieval, tools, output schemas, moderation, or business rules. These are parts of the application, not necessarily capabilities intrinsic to the base model.

The same model can therefore return different answers for different prompts, context, sampling settings, or model versions. Even deterministic decoding does not make an answer factually correct; it only makes token selection more predictable under the same conditions.

### Important distinction: a language model is not the whole AI product

| Component | Responsibility | Example |
|---|---|---|
| LLM | Predicts tokens conditioned on supplied context. | Drafts an answer to a policy question. |
| Prompt/context construction | Provides instructions and relevant conversation or document context. | Adds the applicable policy passages. |
| Retrieval system | Finds external information to ground a response. | Searches a current policy index for relevant sections. |
| Tools and application code | Perform explicit operations and enforce deterministic rules. | Checks a database value or validates a JSON schema. |
| Evaluation and operations | Measure behavior and manage reliability, safety, latency, and cost. | Regression tests a model update and monitors production failures. |

This distinction matters in interviews and system design. A model may produce plausible text, but an application must decide whether to trust, validate, ground, reject, or route that output.

### Production example: support assistant

Consider a support assistant answering questions about a company’s changing product policies. A robust design might retrieve relevant, permission-checked policy passages and include them in the prompt with a clear instruction to answer from that evidence and say when it is insufficient. The system can then validate citations, enforce output limits, and route high-risk or unresolved cases to a human.

Before release, evaluate the complete workflow on representative questions: correct and incorrect retrieval, outdated or contradictory documents, questions with no answer, prompt injection attempts, and access-control boundaries. Track answer correctness and groundedness alongside retrieval quality, abstention behavior, latency, token usage, failure rates, and user feedback. Version the model, prompt, and index so a regression can be investigated and rolled back. This is more meaningful than assuming a strong general benchmark guarantees good support answers.

### Capabilities, limitations, and engineering implications

- **Generalization:** One pretrained model can serve many tasks, but performance varies by task, language, domain, and input format. Evaluate on the intended distribution.
- **Hallucination and calibration:** The model may state unsupported claims fluently or fail to express uncertainty. Use evidence, abstention paths, verification, and human review where the consequences warrant them.
- **Knowledge freshness:** Parameters reflect training data and are not automatically updated when external facts change. Retrieval or tools are often better for current or private information.
- **Context and cost:** Only a bounded token context can be processed in a request. Longer prompts consume more memory, computation, and latency; more context is not always more useful.
- **Security and privacy:** Prompts are not security boundaries. Enforce authorization in application code, minimize sensitive data sent to providers, and treat retrieved or user-supplied content as untrusted.
- **Reliability:** Model and provider behavior can change. Apply input/output validation, timeouts, retries with care, rate limits, fallbacks, observability, and regression evaluations.
- **Model choice:** A larger model may improve some tasks but can cost more and respond more slowly. Choose based on measured task quality, tail latency, throughput, data constraints, deployment needs, and total cost—not parameter count alone.

### Concise interview answer

“An LLM is a neural network trained on large-scale sequences to predict tokens. In the common autoregressive setup, it models the probability of the next token given previous tokens. Pretraining usually teaches this through next-token prediction; instruction and preference post-training can make the model more useful in conversation. At inference, the prompt is tokenized and processed by the Transformer. The model produces next-token logits, a decoding strategy selects a token, and generation repeats until a stop condition or output limit. A KV cache avoids recomputing prior attention states during decoding. In a production application, the LLM is only one component: prompts, retrieval, tools, validation, access controls, evaluation, and monitoring determine whether the overall system is useful and safe. I treat generated text as probabilistic rather than guaranteed fact, and choose grounding, verification, abstention, or human review according to the risk.”

### Revision summary

| Concept | Remember |
|---|---|
| LLM | Neural sequence model; “large” has no universal threshold. |
| Autoregressive objective | \(P(x_1,\ldots,x_T)=\prod_t P(x_t\mid x_{<t})\): predict each next token from prior context. |
| Pretraining | Learn from token sequences, commonly with next-token cross-entropy loss. |
| Post-training | Instruction and preference stages can shape interaction, but do not guarantee correctness. |
| Inference | Prompt prefill, next-token logits, decoding, append token, repeat, then detokenize. |
| KV cache | Reuses earlier attention keys/values to reduce repeated computation during generation. |
| Product boundary | The LLM predicts text; the surrounding system supplies current data, tools, permissions, validation, and operational controls. |
| Senior engineering focus | Evaluate end-to-end quality, safety, latency, throughput, privacy, and cost on representative workloads. |

<br><br><br>

## Inside ChatGPT: What Happens After You Hit Enter?

**Answer:**

### High-level view

When you press Enter in a ChatGPT-style assistant, the visible text is only the start of a request lifecycle. The client sends a conversation turn to a backend; the service applies product and safety logic, constructs the model input, runs inference, and streams or returns the result. Depending on the request and enabled product features, the system may also retrieve information, call tools, route to a model, or ask for clarification. The exact implementation is product-specific and can change over time, so describe this as a representative architecture—not a claim about every internal ChatGPT component.

The central distinction is that the **language model generates tokens**, while the surrounding application manages identity, conversation state, tools, safety policy, delivery, and reliability.

### Request lifecycle

1. **The client submits a turn.** The app sends the new message together with whatever conversation identifiers and client metadata the service needs. Transport is typically an authenticated network request. The interface may show that the request is in progress and prepare to display streamed output.
2. **The service authenticates and applies request controls.** Backend components validate the request, enforce account and rate limits, apply quotas, and may perform routing or abuse checks. Product-specific policy may determine which capabilities are available to the user.
3. **Conversation context is assembled.** The service combines the new message with relevant prior turns and applicable instructions. Since the model has a finite context budget, the system may select, summarize, or compact older history rather than include an unlimited transcript. System and developer instructions are part of the model input but are not necessarily displayed as ordinary chat messages.
4. **The request may be enriched or routed.** Depending on the product, user settings, and request, the service may select a model or processing path; perform safety classification; retrieve relevant information; or prepare tool definitions. Browsing, file analysis, code execution, image processing, and other capabilities are conditional—not steps that must occur for every message.
5. **The input is formatted and tokenized.** The conversation is serialized into the model’s expected format, including role or control markers as appropriate, then converted into token IDs. The service must respect the model’s context limit and may truncate or summarize context if necessary.
6. **The model performs prefill.** The model processes the prompt tokens and computes representations used to predict the next token. In a decoder-only Transformer, causal attention prevents a position from attending to future tokens. The model returns scores (logits) for possible next tokens at the end of the prompt.
7. **The system decodes the response.** A decoding policy selects a next token from the model’s output distribution. The token is appended to the context and the model runs another decode step. A key/value (KV) cache reuses attention state from prior tokens, avoiding recomputation of the full prefix on every step. Generation stops at a model or application stop condition, such as an end-of-turn marker, a tool handoff, or an output limit.
8. **A tool call may create a control-flow branch.** If the model requests a supported tool, the application—not the model itself—validates and executes that call under application permissions. The result is added to the conversation and supplied back to the model, which may then produce a user-facing response. Tool access should be scoped and risky actions should require appropriate authorization or confirmation.
9. **The response is checked and delivered.** The service may apply output handling, policy checks, formatting, or error handling before returning the answer. Many chat interfaces stream partial output as it is generated, so the user can see text before the full turn is complete. Streaming improves perceived responsiveness; it does not mean the final answer is already known when the first token arrives.
10. **The turn ends and operational signals are recorded.** The service finalizes conversation state and may record operational metrics, safety events, and feedback according to its retention and privacy policies. A production system should avoid logging sensitive content unnecessarily and should make data handling explicit.

Some of these steps can overlap or repeat. For example, a request may be routed to a different model, invoke several tools, be retried after a transient failure, or be stopped by a safety or quota decision before generation.

### Concrete example: asking for a current policy

Suppose you ask, “What is the current reimbursement limit, and link me to the policy?” A generic chat model may not have current company policy in its parameters. A product configured with an authorized knowledge source could retrieve the relevant policy passage, include it in the model context, and ask the model to answer with a citation. The model generates the response token by token, while the application can check that the citation refers to a retrieved source. If retrieval finds no reliable evidence, the application should support an “I can’t verify this” response or escalation rather than presenting a guess as policy.

If a browsing or retrieval feature is not enabled, the model may answer from its training-time knowledge or the conversation context instead. Pressing Enter does not automatically imply a web search or guarantee that the answer is up to date.

### What the user experiences versus what the system does

| User-visible behavior | Underlying system work |
|---|---|
| The message appears in the chat. | The client submits a turn; the service validates identity, request limits, and available capabilities. |
| “Thinking” or a spinner appears. | The backend assembles context, routes the request, and performs prefill and initial computation. |
| Text appears progressively. | The server streams generated output chunks as decoding proceeds. |
| A search or tool activity is shown. | The model or orchestration layer requests a tool; application code executes it and returns a result to the model. |
| The assistant references earlier messages. | Relevant conversation history or a compressed representation was included in the model context or available through product memory features. |
| The assistant says it cannot help or asks for confirmation. | Product policy, tool permissions, uncertainty, or a safety workflow may have constrained the response or action. |

These are architectural interpretations of common assistant behavior. The user interface alone does not reveal the exact models, internal services, safety mechanisms, or data-retention implementation.

### Latency, reliability, and cost

The time to a complete answer is not just model compute. It may include network transit, queueing, authentication, context assembly, retrieval, tool execution, model prefill, token decoding, and response post-processing.

- **Time to first token (TTFT)** measures how long the user waits before the first generated output. Queueing, long prompts, retrieval, and prefill can all affect it.
- **Inter-token latency / time per output token (TPOT)** measures the pace of generation after output begins. It depends on model and serving performance, load, output length, and decoding.
- **End-to-end latency** includes all work until completion, including tool round trips and post-processing.
- **Cost and capacity** depend on input and output tokens, model choice, tool usage, concurrency, and serving efficiency. Longer conversation history can increase both prefill work and memory requirements.

Production systems use tracing across the whole request path so they can identify whether a slow turn is caused by queueing, retrieval, a tool, model inference, or delivery. They also need timeouts, cancellation when a user stops generation, bounded retries for transient errors, rate limits, graceful fallbacks, and clear error states. Retrying a non-idempotent tool action without safeguards can duplicate side effects.

### Safety, privacy, and trust boundaries

The model prompt is not a security boundary. Instructions can be contradicted by untrusted user or retrieved content, and model-generated tool arguments must not be treated as authorization. A robust assistant enforces permissions in application code, validates tool inputs, limits tool capabilities, and requests confirmation for consequential actions. Retrieval must apply user-level access control before content reaches the model; hiding a restricted passage in the prompt after retrieval is not sufficient protection.

Likewise, sending a message to an AI service raises data-handling questions: what is transmitted, retained, used for service improvement, or visible to operators depends on the product and its configured policies. In enterprise systems, minimize sensitive data, apply appropriate retention and access controls, and communicate the relevant policy. Do not infer a provider’s exact data practices from the chat experience.

Finally, generated prose is not proof of correctness. A polished answer can still be stale, unsupported, or wrong. For high-impact use cases, ground responses in authoritative sources, verify important claims, expose uncertainty, and include human review or escalation where warranted.

### Concise interview answer

“When a user presses Enter, a ChatGPT-style service receives the turn, authenticates and rate-limits it, assembles relevant conversation context and instructions, and may route the request or invoke retrieval and other capabilities. The input is formatted and tokenized, then the model processes it in a prefill pass and generates output one token at a time. The serving system uses a KV cache to avoid recomputing the entire prefix and can stream tokens to the UI. If the model requests a tool, application code validates and executes the call under explicit permissions, feeds the result back, and generation continues. The service then applies any required output handling and finalizes the turn. In production I trace the full path—queueing, retrieval, tools, TTFT, decode latency, and completion—while enforcing privacy, access control, safety, cost limits, and fallbacks. The exact product implementation varies, and not every request uses every capability.”

### Revision summary

| Stage | Key idea |
|---|---|
| Submit and validate | The client sends a turn; backend checks identity, limits, and capabilities. |
| Assemble context | Relevant history and instructions are selected within the context budget. |
| Optional enrichment | Routing, retrieval, safety checks, or tools may be used depending on the request. |
| Prefill and decode | The model processes prompt tokens, then predicts output tokens sequentially. |
| KV cache | Reuses prior attention keys/values during decoding. |
| Tool loop | Application code—not the model—executes authorized tools and returns results. |
| Stream and finalize | Partial output can be streamed; the turn ends at a stop condition or error. |
| Senior engineering lens | Measure end-to-end latency, quality, cost, privacy, safety, and reliability; avoid claiming hidden implementation details as fact. |

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
