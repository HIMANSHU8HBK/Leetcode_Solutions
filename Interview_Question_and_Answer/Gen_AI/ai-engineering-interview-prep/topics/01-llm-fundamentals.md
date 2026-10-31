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

### Core idea

A **Transformer** is a neural-network architecture for processing sequences. Introduced as an attention-based alternative to recurrent sequence models, it builds contextual representations by allowing tokens to interact through **attention** rather than processing the sequence strictly one token at a time during training. Transformers are the architectural basis of most modern LLMs, though practical model families differ in their attention patterns, positional methods, normalization, feed-forward blocks, and training objectives.

The defining idea is **self-attention**: while representing a token, the model computes which other allowed tokens are relevant and combines information from them. Repeated attention and feed-forward layers transform token representations into increasingly contextual features.

### How the data flows

For an input sequence of \(T\) tokens:

1. **Token IDs become vectors.** Each token ID is mapped to a learned embedding of width \(d_{\text{model}}\).
2. **Position information is added or applied.** Since attention alone does not encode token order, the model incorporates positions using a method such as sinusoidal or learned positional embeddings, or rotary position embeddings (RoPE).
3. **The sequence passes through Transformer blocks.** Each block typically applies normalization, an attention sublayer, a residual connection, a position-wise feed-forward sublayer, and another residual connection. Exact ordering varies; many modern decoder-only models use pre-normalization.
4. **Attention mixes information across positions.** Each token representation produces a query, key, and value. Queries are compared with keys to produce attention weights, and those weights determine how values are combined. A causal mask is used for autoregressive decoder models so a position cannot use future tokens.
5. **The feed-forward sublayer transforms each position.** After attention has mixed contextual information across the sequence, a nonlinear network transforms each token position independently (apart from shared weights).
6. **The final representations feed a task-specific head.** In a decoder-only language model, a linear projection maps the final representation at each position to vocabulary logits, which become next-token probabilities.

In scaled dot-product attention, for query matrix \(Q\), key matrix \(K\), and value matrix \(V\):

\[
\operatorname{Attention}(Q,K,V)=\operatorname{softmax}\left(\frac{QK^\top}{\sqrt{d_k}}+M\right)V
\]

Here \(d_k\) is the key dimension, and \(M\) is an optional mask: disallowed positions receive a very negative value before softmax, giving them effectively zero attention probability. In causal self-attention, this blocks future positions. Multi-head attention performs several learned attention operations in parallel and combines their outputs.

### Why attention is useful

Attention provides **content-dependent interactions**: the model can use different parts of the input depending on what a token is representing. For example, when processing “The animal didn’t cross the street because it was tired,” a model can learn to connect “it” more strongly to “animal” than to “street,” based on context.

Unlike a recurrent network, a Transformer can process all training positions in parallel within a layer (subject to the attention mask). This makes large-scale training efficient on accelerator hardware and allows information to move across many positions in a layer. During autoregressive generation, however, output tokens are still generated sequentially because each new token depends on the preceding generated tokens.

### Encoder, decoder, and common LLM variants

The original Transformer has an encoder and a decoder, but modern systems commonly use one side or a modified form:

| Variant | Attention pattern and typical objective | Common use |
|---|---|---|
| Encoder-only | Bidirectional self-attention: a token can use context on both sides. Often trained with masked-token objectives. | Classification, embeddings, and understanding tasks. |
| Decoder-only | Causal self-attention: a token uses only previous tokens. Commonly trained with next-token prediction. | Generative LLMs and autoregressive text/code generation. |
| Encoder-decoder | Encoder reads the input bidirectionally; decoder generates output autoregressively and may cross-attend to encoder states. | Conditional generation such as translation or summarization. |

These are broad patterns, not strict limits on what a model can do. A decoder-only LLM can perform many understanding tasks when they are expressed as text-generation problems, and encoder-decoder models can also generate text.

### Example: next-token prediction

Given the tokenized input “The capital of France is”, token embeddings and position information enter the decoder stack. Each causal self-attention layer lets the final position build a representation from the preceding tokens. The final vocabulary projection produces logits for possible next tokens. A decoding rule selects a token—perhaps “ Paris”—and that token is appended to the sequence. The model then predicts another token using the updated context. Attention and learned representations make the continuation context-sensitive; they do not guarantee that the generated statement is correct.

### Strengths and trade-offs

- **Parallelizable training:** Unlike a recurrent network, Transformer training can process positions in parallel within a layer. This supports efficient scaling, although training still requires substantial computation and memory.
- **Flexible context use:** Attention can connect distant tokens directly within a layer, but the model’s context length is finite and attention over long sequences can be expensive.
- **High capacity and transfer:** Large pretrained Transformers can be adapted to many tasks, but model capability depends on data, objective, scale, and post-training—not architecture alone.
- **Inference cost:** Standard full self-attention has computation and attention-memory costs that grow roughly quadratically with sequence length during prefill. Autoregressive decoding has sequential token latency and uses KV-cache memory that grows with context length and batch size.
- **Long-context engineering:** FlashAttention improves memory traffic and practical efficiency without changing the exact attention result; sliding-window, sparse, or other attention patterns reduce or alter interactions and introduce different trade-offs.
- **Not inherently factual or safe:** Attention is a computation mechanism, not a guarantee of reasoning, truth, or policy compliance. Those properties must be assessed at the model and system levels.

### Concise interview answer

“A Transformer is a sequence-model architecture built around attention. Tokens are mapped to vectors, position information is incorporated, and the vectors pass through repeated attention and feed-forward blocks with residual connections and normalization. In self-attention, queries compare against keys to compute weights over values, so each token can build a context-dependent representation. Multi-head attention learns several such interaction patterns in parallel. A causal mask makes decoder-only LLMs autoregressive by preventing a position from attending to future tokens; a vocabulary head then produces next-token logits. Transformers train efficiently because sequence positions can be processed in parallel within a layer, but generation remains sequential, and long-context attention and KV-cache memory create serving costs. Encoder-only, decoder-only, and encoder-decoder models use different attention patterns for different objectives. The architecture enables powerful sequence modeling, but it does not by itself guarantee factuality or safety.”

### Revision summary

| Concept | Remember |
|---|---|
| Transformer | Sequence architecture whose core operation is attention, typically stacked with feed-forward layers. |
| Self-attention | Queries score keys; the resulting weights combine values into contextual representations. |
| Position | Must be represented because attention alone does not encode sequence order. |
| Causal mask | Prevents a decoder position from using future tokens. |
| Multi-head attention | Several learned attention patterns operate in parallel. |
| Training vs generation | Positions can be parallelized in training; autoregressive output tokens are generated sequentially. |
| Main trade-off | Strong parallelizable sequence modeling versus context, memory, and inference-latency costs. |

<br><br><br>

## What are the key components of the Transformer architecture?

**Answer:**

### A block-by-block map

A Transformer is not just attention. It is a stack of components that first represents tokens, repeatedly mixes contextual information, transforms each position, and finally maps hidden states to task outputs. The exact design varies by model family, but the following are the main components in a modern language Transformer.

| Component | What it does | Why it matters |
|---|---|---|
| Tokenizer and token IDs | Converts text into discrete vocabulary IDs before the neural network is called. | Defines the units the model sees and affects sequence length, coverage, and interface compatibility. |
| Token embedding | Maps each token ID to a learned vector of width \(d_{\text{model}}\). | Provides the initial continuous representation of token identity. |
| Positional representation | Adds or applies sequence-position information, such as learned positions or RoPE. | Lets the model distinguish order and relative position. |
| Attention sublayer | Uses queries, keys, and values to mix information across permitted positions. | Supplies content-dependent context across tokens. |
| Attention mask | Marks positions that must not be attended to, for example future tokens in a causal decoder. | Enforces the model’s information-flow pattern. |
| Multi-head structure | Splits attention into multiple learned heads, then combines their outputs. | Enables different representation subspaces and token relationships to be modeled in parallel. |
| Feed-forward network (MLP/FFN) | Applies learned nonlinear transformations independently at each sequence position, with shared weights. | Adds per-position transformation capacity after attention has exchanged context. |
| Normalization | Scales and shifts hidden activations, using LayerNorm, RMSNorm, or a variant. | Helps stabilize optimization and activation behavior. |
| Residual connection | Adds a sublayer’s input to its output. | Preserves information and provides a direct path for gradients through deep stacks. |
| Output head | Projects final hidden states to task outputs; for an LLM, usually vocabulary logits. | Converts internal representations into predictions. |

The tokenizer is a necessary part of the end-to-end language system, but it is usually a separate preprocessing component rather than a neural layer inside the Transformer.

### Inside a typical Transformer block

For a hidden-state matrix \(X\) with shape approximately \([B,T,d_{\text{model}}]\), where \(B\) is batch size and \(T\) is sequence length, a typical pre-normalized decoder block can be sketched as:

1. Normalize the current hidden states.
2. Project them into queries, keys, and values.
3. Apply masked multi-head self-attention.
4. Project and add the attention result back through a residual connection.
5. Normalize the updated hidden states.
6. Apply the feed-forward network and add its result through another residual connection.

Conceptually:

\[
X' = X + \operatorname{Attention}(\operatorname{Norm}(X))
\]
\[
Y = X' + \operatorname{FFN}(\operatorname{Norm}(X'))
\]

This is a common pre-norm form, not a universal specification. Some architectures use different normalization placement, gated MLPs, expert layers, attention variants, or positional schemes.

### Attention components in more detail

For each token representation \(x\), learned projections produce a query (what this position seeks), key (what this position can be matched against), and value (the information this position contributes):

\[
Q=XW_Q,\qquad K=XW_K,\qquad V=XW_V
\]

Attention scores compare each query with keys, scale by the square root of the key dimension, apply the mask, and normalize with softmax. The resulting weights mix the values. Multi-head attention runs this calculation across multiple heads and combines the head outputs through another learned projection. The roles of “query,” “key,” and “value” are useful intuitions for the learned projections; they are not literal labels or symbolic database lookups inside the model.

The **mask** controls information flow. A causal mask is used for next-token language modeling; encoder self-attention is generally bidirectional; encoder-decoder cross-attention uses decoder queries against encoder keys and values. Padding masks may also prevent padded positions from contributing.

### The feed-forward sublayer

The FFN operates independently at each position but shares its parameters across positions. A common pattern expands the hidden width, applies a nonlinearity, and projects back:

\[
\operatorname{FFN}(x)=W_2\,\phi(W_1x+b_1)+b_2
\]

Modern LLMs often use gated variants, such as SwiGLU, rather than a simple activation between two linear layers. Attention mixes information between tokens; the FFN transforms each token’s resulting representation. Both are needed for the block’s expressive capacity.

### Normalization and residual paths

LayerNorm normalizes using per-example feature statistics; RMSNorm uses a root-mean-square scaling and typically omits mean-centering. Residual connections add the sublayer input to its transformed output, helping preserve signal and improve gradient flow. Pre-norm architectures normalize before the attention or FFN operation and are common in deep modern Transformers, although details differ by implementation.

### Input and output components

At the input, token embeddings and positional information produce the initial hidden states. At the output of a language model, a final normalization may be applied, then an output projection maps each hidden vector to one logit per vocabulary token. A softmax can convert logits to probabilities for the next-token distribution. Some models tie the input embedding and output-projection weights; others do not.

During autoregressive inference, the attention system can store keys and values from previous tokens in a **KV cache**. This is a serving-time optimization, not a separate learned Transformer block: it avoids recomputing old attention projections on every decode step, at the cost of memory that grows with cached sequence length, layers, KV-head count, and batch size.

### How variants change the components

| Architecture | Attention configuration | Typical output/use |
|---|---|---|
| Encoder-only | Bidirectional self-attention over input tokens. | Contextual representations for classification, retrieval embeddings, or understanding tasks. |
| Decoder-only | Causal self-attention over the prefix. | Next-token generation for chat, text, and code. |
| Encoder-decoder | Bidirectional encoder attention; causal decoder attention plus cross-attention to encoder outputs. | Conditional sequence-to-sequence generation. |
| Mixture-of-Experts Transformer | Replaces or augments some dense FFNs with routed expert FFNs. | Increases total parameter capacity while activating only selected experts per token; adds routing and load-balancing complexity. |

The named components are a useful mental model, but exact implementations differ. For example, grouped-query attention shares key/value heads to reduce KV-cache size, and FlashAttention changes how attention is computed in hardware without changing the mathematical attention result.

### Practical engineering implications

- **Shapes and dimensions:** Hidden width, number of layers, query heads, KV heads, and head dimension determine compute and memory. Confirm the model’s actual configuration rather than inferring it from a marketing label.
- **Context cost:** Attention prefill and the KV cache can become bottlenecks for long prompts or large concurrent batches. Serving choices include efficient kernels, batching, cache management, context limits, and—in some architectures—sparse or local attention.
- **Numerical stability:** Precision, normalization, residual paths, and kernel implementations affect training stability and inference quality. Quantization can reduce memory and cost but needs quality evaluation on the target workload.
- **Compatibility:** Tokenizer, model weights, prompt/chat template, and special tokens must agree. A mismatch can degrade behavior even if the model loads successfully.
- **Debugging:** When an output is poor, investigate the full path: tokenization and formatting, context/mask behavior, model and decoding configuration, then application logic. Do not assume every issue is an attention issue.

### Concise interview answer

“The main Transformer components are token embeddings, positional information, stacked blocks containing attention and feed-forward sublayers, normalization, residual connections, masks, and an output head. Attention projects hidden states into queries, keys, and values; query-key scores produce weights that combine values across allowed positions. Multi-head attention performs this in parallel across learned subspaces. The mask controls which positions can interact, such as blocking future tokens for a causal decoder. The FFN transforms each position independently after attention has mixed context. Normalization and residual paths support stable deep networks. For an LLM, the final hidden state is projected to vocabulary logits for next-token prediction; at inference, a KV cache reuses past attention states. Exact variants—such as encoder-only, decoder-only, GQA, gated MLPs, or MoE—change these components to meet different task and efficiency requirements.”

### Revision summary

| Component | One-line recall |
|---|---|
| Token embedding | Token ID \(\rightarrow\) learned vector. |
| Positional method | Encodes order/position information. |
| Q, K, V attention | Selects and combines information across positions. |
| Mask | Restricts which positions can contribute. |
| Multiple heads | Learns several attention patterns in parallel. |
| FFN/MLP | Nonlinear transformation at each position. |
| Norm + residual | Stabilize activations and preserve signal/gradient paths. |
| Output head | Hidden states \(\rightarrow\) vocabulary logits or task output. |
| KV cache | Reuses past keys/values during autoregressive decoding. |

<br><br><br>

## Walk me through what happens, step by step, in one forward pass of a decoder-only Transformer.

**Answer:**

### What “one forward pass” means

A **forward pass** is the computation that maps a model input to outputs without updating the model’s parameters. For a decoder-only language model, it maps a sequence of token IDs to hidden representations and vocabulary logits at each sequence position. During training, this is commonly done for a whole token sequence at once. During inference, an initial **prefill** processes the prompt, then autoregressive generation usually runs repeated decode steps for newly generated tokens.

The term can be ambiguous: a forward pass over an entire prompt is not the same as one incremental decode step. The steps below describe a causal Transformer’s computation for a sequence, then explain how caching changes inference.

### Step-by-step data flow

Assume a batch of tokenized sequences with shape \([B,T]\), where \(B\) is batch size and \(T\) is sequence length.

1. **Token IDs enter the model.** The tokenizer has already converted text into vocabulary IDs. Special tokens, chat-role markers, and padding (if used) are part of this input representation.
2. **Token embedding lookup.** Each integer token ID indexes a learned embedding table. The result is a hidden-state tensor \(X\) with shape \([B,T,d_{\text{model}}]\).
3. **Position information is incorporated.** The model applies its positional method—such as learned or sinusoidal positional embeddings, or rotary position embedding (RoPE) within attention projections. The exact method varies by architecture.
4. **The causal attention mask is prepared.** For each position \(i\), positions \(j>i\) are disallowed. In a common additive-mask implementation, those attention logits are set to a very negative value before softmax, giving future tokens effectively zero weight. Padding masks may add further restrictions.
5. **The hidden states enter each Transformer block.** For every block, normalization and residual ordering follow that model’s design. A common pre-norm block first normalizes \(X\), then projects it:
   \[
   Q=XW_Q,\qquad K=XW_K,\qquad V=XW_V
   \]
   These projections are reshaped into attention heads. With \(H\) query heads and head dimension \(d_h\), the query representation is conceptually shaped \([B,H,T,d_h]\); key and value shapes depend on the number of KV heads (which may be fewer in grouped-query or multi-query attention).
6. **Causal self-attention mixes information across positions.** Each query is compared with keys using scaled dot products:
   \[
   S=\frac{QK^\top}{\sqrt{d_h}}+M
   \]
   where \(M\) is the causal (and possibly padding) mask. A softmax over the key positions yields attention weights, which are used to take weighted sums of \(V\). Each head’s output is combined with the others and projected back to \(d_{\text{model}}\). In a decoder-only model, every position can use its own token and earlier tokens, but not future tokens.
7. **The attention residual is applied.** The attention result is added to the block’s input hidden states. In a pre-norm design, this is commonly \(X' = X + \operatorname{Attention}(\operatorname{Norm}(X))\). This provides a direct path for information and gradients.
8. **The feed-forward network transforms each position.** The block normalizes the updated states, applies a position-wise MLP (often a gated MLP in modern models), and adds another residual:
   \[
   Y=X'+\operatorname{FFN}(\operatorname{Norm}(X'))
   \]
   The same FFN weights are used at each position, but each position has a different contextual input. The output becomes the input to the next block.
9. **The block stack repeats.** Steps 5–8 are repeated across all Transformer layers. The representation at each position becomes contextualized through successive attention and nonlinear transformations.
10. **Final normalization and vocabulary projection.** After the last block, a final normalization may be applied. A learned output projection maps each position’s hidden vector from \(d_{\text{model}}\) to vocabulary size \(V\), producing logits shaped \([B,T,V]\).
11. **Logits are used according to the task.** For next-token language modeling, the logits at position \(t\) predict token \(t+1\). During training they are compared with target tokens to compute cross-entropy loss. During inference, the final prompt position’s logits are typically converted into a distribution and used to select the first generated token.

### Why the causal mask matters

The mask ensures that prediction at position \(t\) cannot read the ground-truth token at position \(t+1\) or any later position. This prevents **information leakage** during training and makes the same model usable for left-to-right generation.

Training can still process all positions in parallel: the causal mask makes each position’s computation depend only on valid earlier inputs, while the implementation computes the full masked attention matrix efficiently. Parallel computation does not mean the model is allowed to see future tokens.

### Training versus inference

| Mode | Input and computation | Which logits are used? |
|---|---|---|
| Training | A full sequence is supplied; masked attention computes representations for all positions in parallel. | Each position predicts the next target token; losses are aggregated over valid target positions. |
| Prompt prefill | The full prompt is processed to produce prompt representations and usually a KV cache. | The logits at the prompt’s final position predict the first output token. |
| Incremental decode | One new token is processed at a time, attending to cached prior keys and values plus the new token’s states. | The new final-position logits predict the next token. |

During ordinary next-token training, inputs and targets are shifted by one token. For example, given “The cat sat”, the model uses “The” to predict “cat” and “The cat” to predict “sat”. Teacher forcing supplies the actual preceding training tokens at each position. At generation time, the model instead conditions on its own previously selected output tokens, so an early generation error can influence later tokens.

### KV caching during generation

Without a KV cache, a naive implementation could recompute keys and values for the entire growing prefix every time a new token is generated. With caching, each layer retains the keys and values already computed for previous positions and calculates only the new token’s projections. The new query attends over cached keys/values and its own current state.

This reduces repeated work during autoregressive decoding, but the cache consumes memory that grows with the number of layers, sequence length, batch size, KV-head count, head dimension, and cache precision. The cache is a serving optimization; it does not change the model’s learned parameters or the causal attention rule.

### Worked shape intuition

For a single request with prompt length \(T=4\), batch size \(B=1\), and hidden width \(d_{\text{model}}\):

- Embeddings produce \([1,4,d_{\text{model}}]\).
- Each layer projects Q/K/V and reshapes them across attention heads.
- The causal mask permits attention patterns like:

  | Query position | Tokens it may attend to |
  |---|---|
  | 1 | 1 |
  | 2 | 1, 2 |
  | 3 | 1, 2, 3 |
  | 4 | 1, 2, 3, 4 |

- Each attention output and FFN output is combined with residual paths; the tensor remains \([1,4,d_{\text{model}}]\) through the block stack.
- The output head produces \([1,4,V]\) logits. For generation, position 4’s logits predict token 5. Once that token is selected, it is appended and decoded using the KV cache.

### Common pitfalls and implementation notes

- **Confusing forward pass and generation loop:** A forward pass produces logits; decoding and token selection are surrounding inference steps. A user-facing answer may require many forward/decode iterations.
- **Assuming the whole output is parallel:** Prompt prefill processes prompt positions in parallel, but autoregressive output tokens depend on earlier generated tokens and are produced sequentially.
- **Mask and shift errors:** Incorrect causal masks or target alignment can leak future information or train the wrong prediction task.
- **Ignoring architecture variants:** RoPE, RMSNorm, GQA/MQA, gated FFNs, parallel residuals, and other design choices change details and tensor shapes. Check the actual model configuration.
- **Assuming all logits are useful at inference:** A generation API often only needs the final prompt position’s logits for the next token, while training uses predictions across many positions.
- **Treating a forward pass as an update:** Parameters are updated during backpropagation and optimizer steps in training, not by the forward computation alone.

### Concise interview answer

“Given token IDs shaped \([B,T]\), the model looks up token embeddings and applies its positional method. A causal mask prevents each position from attending to future tokens. In every decoder block, normalized hidden states are projected into queries, keys, and values; masked scaled dot-product multi-head attention mixes information from allowed prior positions. The attention output is added through a residual connection, then a normalized feed-forward network transforms each position and is added through another residual. Repeating this through the layer stack yields contextual hidden states. A final normalization and vocabulary projection produce logits \([B,T,V]\); at training time each position predicts the next token and contributes to cross-entropy loss. At inference, prompt prefill computes the initial states and KV cache, the final prompt logits select the first output token, and subsequent decode steps reuse cached keys and values. The forward pass computes logits; sampling and the repeated generation loop are separate inference logic.”

### Revision summary

| Step | Recall |
|---|---|
| IDs \(\rightarrow\) embeddings | Convert token indices to hidden vectors. |
| Position + causal mask | Represent order and block access to future tokens. |
| Q/K/V attention | Compare queries to keys, then combine values across permitted positions. |
| Residual + FFN | Preserve signal and transform each contextualized position. |
| Repeat layers | Build deeper contextual representations. |
| Output projection | Produce vocabulary logits at each position. |
| Training | Shift targets; compute next-token loss across sequence positions. |
| Inference | Use final prompt logits, then decode sequentially with KV-cache reuse. |

<br><br><br>

## What is tokenization in LLMs?

**Answer:**

### Core idea

**Tokenization** converts input text into a sequence of discrete units called **tokens**, then maps those tokens to integer IDs from a model-specific vocabulary. The model consumes token IDs—not raw characters, words, or meanings directly. After generation, the reverse process decodes output token IDs back into text.

A token is not necessarily a word. Depending on the tokenizer and vocabulary, it may represent a whole common word, a word fragment, punctuation, whitespace together with text, a byte or character unit, or a special control marker. For example, a common word such as `playing` might be one token in one vocabulary, while a less common technical term might split into several subword tokens. Exact splits vary by tokenizer.

### The tokenization pipeline

1. **Input text is normalized or pre-tokenized.** Implementations may apply normalization and divide text into preliminary segments using whitespace, punctuation, or language-specific rules. Details are tokenizer-specific.
2. **Segments are mapped to vocabulary pieces.** Common subword tokenizers use a learned vocabulary and segmentation algorithm to represent common sequences compactly while still handling uncommon strings through smaller pieces or byte-level units.
3. **Pieces become token IDs.** Each vocabulary entry maps to an integer index. These IDs are the model’s symbolic input.
4. **The model embeds the IDs.** An embedding table maps IDs to learned vectors; the Transformer processes those vectors along with positional information.
5. **Output IDs are decoded.** Generated token IDs are converted back to text according to the tokenizer’s decoding rules. Special tokens may be interpreted as control flow rather than printed as ordinary text.

Tokenization is deterministic for a fixed tokenizer configuration and input, but two different model tokenizers can segment the same text differently. The tokenizer and model vocabulary must match; passing IDs from a different tokenizer can make the input meaningless to the model.

### Why use subword tokenization?

Word-level vocabularies require an entry for every possible word form and struggle with rare words, names, typos, and newly coined terms. Character-level tokenization avoids a large word vocabulary but produces long sequences, increasing computational cost and making it harder for the model to learn patterns over meaningful units. Subword tokenization is a practical compromise:

- Frequent words and fragments can be represented compactly.
- Rare or novel words can be split into known pieces rather than mapped to one unknown-word token.
- The vocabulary remains bounded, while sequence length is usually much shorter than character-level encoding.

This compromise is imperfect. A domain-specific term may be split into many pieces, while another tokenizer may encode it more efficiently. Token counts are therefore tokenizer-dependent.

### Why tokenization matters in practice

- **Context length:** Model context windows are measured in tokens, not words or characters. A long document, code sample, or non-English text can consume more tokens than expected.
- **Cost and latency:** Hosted model prices often depend on input and output tokens. More tokens increase prompt-processing work and can increase latency and serving memory requirements.
- **Truncation and chunking:** Applications must estimate token counts with the tokenizer for the target model. Character-count limits are only rough approximations and can truncate relevant content or exceed model limits.
- **Language and domain coverage:** Tokenizers can be less efficient for some languages, scripts, code, identifiers, or specialized vocabulary. Inefficient segmentation consumes more of the context budget and can affect downstream quality.
- **Input/output constraints:** A model may have special token IDs for message boundaries, roles, end-of-turn markers, or tool calls. These control tokens are distinct from ordinary text and are part of the model’s expected format.
- **Security and robustness:** Applications should not assume that a visual string corresponds to one token or that token boundaries are obvious. Tokenization is not a security filter; validate inputs and enforce policy outside the tokenizer.
- **Training and compatibility:** Tokenizer design affects the model’s sequence lengths and learned input/output interface. Changing the tokenizer for an existing model is not a drop-in update: embedding and output vocabulary weights must remain aligned or be deliberately adapted and evaluated.

### Example: estimating a prompt budget

Suppose a request contains a system instruction, conversation history, retrieved passages, and a user question. The application cannot safely budget only the number of characters. It should count the serialized prompt using the target model’s tokenizer, reserve space for the maximum expected response and any tool or formatting overhead, then trim, summarize, or retrieve fewer passages if needed.

If a document is chunked by characters alone, two chunks of equal character length may have very different token counts—for example, ordinary prose versus source code, a URL-heavy passage, or text in a language that the tokenizer represents less compactly. Token-aware chunking helps respect model limits, although semantic boundaries and retrieval quality still matter.

### Common tokenization approaches

| Approach | Basic unit | Advantage | Limitation |
|---|---|---|---|
| Word-level | Whole words | Short sequences for known words. | Large vocabulary; poor handling of unseen words and inflections. |
| Character-level | Characters | Very small vocabulary; can represent arbitrary text. | Long sequences and less efficient modeling of word-level patterns. |
| Subword (e.g., BPE or WordPiece) | Frequent words and word fragments | Balances vocabulary size and sequence length; handles many rare words compositionally. | Segmentation can be unintuitive or inefficient for some domains and languages. |
| Byte-level or byte-fallback variants | Bytes, often combined with subword pieces | Can represent arbitrary input without a conventional unknown character. | Some content may require more tokens; implementation details vary. |

These are broad categories. Real tokenizers may combine pre-tokenization, subword merges, byte-level handling, normalization, and special-token rules.

### Tokenization versus embeddings

| Stage | Representation | Example role |
|---|---|---|
| Tokenization | Text \(\rightarrow\) discrete token IDs | Converts `hello` into one or more vocabulary indices. |
| Embedding lookup | Token IDs \(\rightarrow\) learned vectors | Supplies continuous input representations to the Transformer. |
| Transformer processing | Vectors \(\rightarrow\) contextual hidden states | Models relationships among tokens in context. |
| Output projection and decoding | Hidden states \(\rightarrow\) token probabilities/IDs \(\rightarrow\) text | Generates a continuation and renders it as text. |

The tokenizer does not understand meaning. It defines a representation interface between text and the model; contextual representations and behavior are learned by the neural network.

### Concise interview answer

“Tokenization maps text into a sequence of vocabulary units and then integer token IDs that an LLM can process. Tokens are not necessarily words; they may be word fragments, punctuation, bytes, whitespace-associated pieces, or special control markers. Subword tokenization is common because it balances vocabulary size and sequence length while allowing rare words to be composed from known pieces. Tokenization matters operationally because context limits, latency, and many API costs are token-based. I use the tokenizer corresponding to the deployed model to budget prompts, chunk documents, and reserve output capacity. Tokenizer/model mismatch is a compatibility bug, and changing a tokenizer is not a harmless replacement because its IDs must align with learned embedding and output weights. Tokenization itself does not understand meaning or provide a safety boundary.”

### Revision summary

| Concept | Remember |
|---|---|
| Tokenization | Text \(\rightarrow\) token pieces \(\rightarrow\) integer IDs. |
| Token | May be a word, subword, punctuation, byte, or special marker—not necessarily a word. |
| Subword motivation | Bounded vocabulary with better rare-word coverage than word-level tokenization. |
| Operational impact | Context, cost, latency, chunking, and truncation are token-dependent. |
| Compatibility | Use the tokenizer and formatting expected by the specific model. |
| Key caveat | Tokenization is a representation step, not semantic understanding or a security control. |

<br><br><br>

## Explain BPE (Byte Pair Encoding).

**Answer:**

### Core idea

**Byte Pair Encoding (BPE)** is a subword tokenization method that builds a vocabulary by repeatedly merging frequently occurring adjacent symbols in a training corpus. Once the merges are learned, the tokenizer applies them in a fixed order to split new text into vocabulary tokens. In LLMs, BPE-style tokenizers help balance a bounded vocabulary with the ability to represent uncommon words as smaller pieces.

The original data-compression algorithm operated on byte pairs. NLP tokenizers adapt the merge idea to text symbols, often starting from characters or bytes and adding frequent merged sequences to the vocabulary. “BPE tokenizer” can refer to variations in initial alphabet, pre-tokenization, normalization, byte handling, and special-token rules.

### How the vocabulary is learned

At a high level, training proceeds as follows:

1. **Choose the initial symbols.** The text is prepared according to tokenizer-specific normalization and pre-tokenization rules. The starting units may be characters or bytes.
2. **Count adjacent pairs.** Across the training corpus, count how often each neighboring symbol pair occurs.
3. **Merge a frequent pair.** Select a pair according to the algorithm’s frequency rule and combine it into a new symbol.
4. **Update the corpus representation.** Replace occurrences of the selected adjacent pair with the merged symbol, then recount candidate pairs.
5. **Repeat until the target vocabulary or merge budget is reached.** The learned symbols and merge order form part of the tokenizer vocabulary and configuration.

These are tokenizer-training steps. A deployed tokenizer generally does **not** relearn pair frequencies for each prompt; it uses the fixed vocabulary and merge ranks learned earlier.

### Encoding text with the learned merges

For encoding, the tokenizer begins with the allowed initial symbols for each pre-tokenized segment, then applies available merges in the learned priority order. The final symbols are mapped to token IDs.

Illustrative example, with simplified symbols and a toy corpus:

- Suppose `l`, `o`, `w`, `e`, and `r` are initial symbols.
- If the merge `l + o -> lo` is learned, `l o w` may become `lo w`.
- If `lo + w -> low` is subsequently learned, `low` may become a single token.
- If the exact word `lower` was not merged, it can still be represented as `low er` or another sequence of known pieces, depending on the learned vocabulary and merge ranks.

The example shows the principle, not the exact segmentation of any real tokenizer. Real tokenizers may include whitespace markers, byte-level units, pre-tokenization rules, and other constraints that affect the result. A token can include leading whitespace, and the same visible word can split differently across tokenizer vocabularies.

### Why BPE is useful for LLMs

- **Bounded vocabulary:** The model uses a manageable number of embedding and output classes rather than one entry for every possible word.
- **Rare-word coverage:** Unseen or rare words can often be composed from smaller known units instead of becoming one unknown token.
- **Compression of common text:** Frequent words and fragments can become single tokens, reducing sequence length relative to character-level encoding.
- **Deterministic interface:** Given a fixed tokenizer version and configuration, the same input is encoded consistently.

### Limitations and engineering implications

- **Token counts vary.** A text’s token count depends on the exact vocabulary, merge rules, normalization, and pre-tokenization. Always count with the tokenizer paired with the target model.
- **Domain mismatch.** Uncommon product names, biomedical terms, identifiers, source code, or non-Latin scripts may fragment into many tokens. This consumes context and can increase latency and cost.
- **No semantic guarantee.** A frequent merge reflects statistics in the tokenizer’s training corpus; it does not mean the model understands that piece as a meaningful concept.
- **Vocabulary and sequence-length trade-off.** More merges can shorten common sequences but expand vocabulary and embedding/output tables. Fewer merges shrink the vocabulary but can lengthen sequences.
- **Tokenizer changes affect compatibility.** Token IDs index learned model weights. Swapping the tokenizer or changing vocabulary order without compatible model weights breaks the input/output mapping; adapting a tokenizer requires corresponding model changes and evaluation.
- **Not all “BPE” variants are identical.** Byte-level BPE can represent arbitrary byte sequences, while other implementations use different initial symbols or fallback behavior. Details matter for exact token counts and handling of unusual text.

For production, tokenizer-aware budgeting should reserve capacity for both input and generated output. When a domain term fragments inefficiently, first measure the effect on task quality and cost. Possible mitigations include domain-aware chunking, glossary context, retrieval, or selecting a model/tokenizer with better coverage. Adding tokens to an existing model is a model adaptation change, not merely a tokenizer configuration tweak.

### BPE compared with related tokenization approaches

| Method | How units are chosen | Typical strength | Common trade-off |
|---|---|---|---|
| BPE | Repeatedly merges frequent adjacent symbol pairs. | Simple merge-based vocabulary construction; common sequences become compact. | Segmentation is frequency-driven and may not align with linguistic morphemes. |
| WordPiece | Selects subword units using a likelihood-oriented vocabulary-learning objective and uses learned pieces during segmentation. | Widely used subword approach with strong rare-word handling. | Exact learning and segmentation behavior is implementation-specific. |
| Unigram language model | Starts with candidate pieces and removes pieces to optimize a probabilistic segmentation model. | Can represent multiple plausible segmentations during training in some implementations. | More complex learning and probabilistic segmentation behavior. |
| Character/byte-based | Uses character or byte units as the basic alphabet, possibly with subword merges. | Robust coverage of unusual strings when byte fallback is available. | May produce longer sequences for some inputs. |

These methods all appear in subword tokenization systems, but their names alone do not fully specify a tokenizer. Pre-tokenization, normalization, byte fallback, special tokens, and vocabulary size also matter.

### Concise interview answer

“BPE is a subword vocabulary-learning method. It starts with basic symbols—often characters or bytes—counts adjacent pairs in a training corpus, and repeatedly merges frequent pairs until it reaches a vocabulary target. At inference, the tokenizer applies the fixed learned merge ranks to new text and maps the resulting pieces to token IDs; it does not relearn merges per request. This gives a bounded vocabulary, compresses common text, and lets many rare words be represented compositionally. The trade-offs are tokenizer-dependent segmentation and token counts: domain terms or some languages may fragment, increasing context use, latency, and cost. The tokenizer must match the model because token IDs correspond to learned embedding and output weights. BPE is a statistical segmentation procedure, not a semantic understanding mechanism.”

### Revision summary

| Step or concept | Remember |
|---|---|
| Initialize | Start from characters, bytes, or another defined base alphabet. |
| Learn merges | Count adjacent pairs and repeatedly merge frequent pairs. |
| Encode | Apply fixed learned merge priorities, then map pieces to IDs. |
| Benefit | Bounded vocabulary with compact common sequences and rare-piece coverage. |
| Trade-off | Segmentation and token efficiency depend on corpus and tokenizer design. |
| Production rule | Use the model’s exact tokenizer for budgeting and preserve tokenizer/model compatibility. |

<br><br><br>

## Explain WordPiece and SentencePiece.

**Answer:**

### Core distinction

**WordPiece** is a subword vocabulary-learning and segmentation method associated with models such as BERT. It builds a fixed vocabulary of pieces so common words can be represented compactly and rarer words can be split into known subword units. During encoding, it uses vocabulary-based segmentation (commonly a greedy longest-match procedure with conventions for marking non-initial word pieces). Its original vocabulary-learning objective is likelihood-oriented; it should not be described simply as “BPE with a different name.”

**SentencePiece** is an open-source tokenizer framework, not one single segmentation algorithm. It can train and apply subword tokenizers—commonly **Unigram** or **BPE**—directly from raw sentences, including languages that do not use whitespace to separate words. It handles text normalization and whitespace as part of a configurable, reproducible pipeline, often representing whitespace with a visible marker such as `▁`.

So the comparison is not strictly “WordPiece algorithm versus SentencePiece algorithm”: WordPiece describes a method, while SentencePiece describes a framework that can implement methods such as Unigram and BPE.

### WordPiece in practice

WordPiece starts from a basic set of symbols and learns a bounded vocabulary of subword units from training text. At encoding time, a word is matched against vocabulary pieces. A common convention prefixes continuation pieces with a marker such as `##`, making their position within a word explicit. For example, a toy vocabulary might encode `unaffordable` as `un`, `##afford`, `##able`; the actual segmentation depends on the trained vocabulary and tokenizer implementation.

Important properties:

- Common words or fragments can be single tokens; uncommon words can be decomposed into several known pieces.
- Some WordPiece tokenizers use a greedy longest-match-first encoding procedure.
- The tokenizer may have a defined unknown-token fallback when a string cannot be represented under its rules.
- Its normalization, pre-tokenization, continuation markers, vocabulary, and special-token conventions are part of the full tokenizer specification.

The precise training and encoding details can vary between implementations; do not infer them solely from the name “WordPiece.”

### SentencePiece in practice

SentencePiece trains a tokenizer from raw text rather than requiring an external pre-tokenizer to split input into words. It makes whitespace and normalization behavior explicit and stores the model vocabulary and configuration together, supporting consistent training and inference.

Common SentencePiece model types include:

- **Unigram:** Starts from a set of candidate pieces and selects a vocabulary that optimizes a probabilistic model of segmentations. Encoding can be performed with a most-probable segmentation, and some training or regularization setups can sample alternative segmentations.
- **BPE:** Uses pair-merging ideas to construct subword units; SentencePiece provides a BPE model type and its own implementation details.

SentencePiece’s whitespace marker often appears as `▁`. It represents a whitespace boundary in the encoded sequence; it is not necessarily a literal character that the user typed. Depending on the configuration, byte fallback can help represent unusual or previously unseen Unicode content rather than mapping it immediately to one unknown token.

### Comparison

| Aspect | WordPiece | SentencePiece |
|---|---|---|
| What the name refers to | A subword vocabulary-learning and tokenization method. | A tokenizer framework and serialized model format with configurable algorithms. |
| Common algorithms | WordPiece vocabulary learning and vocabulary-based segmentation. | Commonly Unigram or BPE; behavior depends on the selected model type. |
| Input preparation | Often paired with a separate normalization and pre-tokenization pipeline. | Designed to process raw sentences, with normalization and whitespace handling represented in the tokenizer configuration. |
| Typical visible convention | Continuation pieces may use a marker such as `##`. | Whitespace boundaries may be represented by a marker such as `▁`. |
| Segmentation behavior | Common implementations use greedy vocabulary matching at encoding time. | Depends on the selected model type and configuration; Unigram is probabilistic, while BPE uses merge-based segmentation. |
| Unseen text handling | May use an unknown token if its vocabulary/rules cannot represent the input. | May use unknown tokens or byte fallback, depending on configuration. |
| Main engineering concern | Match the exact vocabulary, normalization, pre-tokenization, and special-token rules expected by the model. | Preserve the SentencePiece model file and its normalization, algorithm, and special-token settings as part of model compatibility. |

These are typical characteristics, not universal guarantees for every tokenizer bearing the name. The actual tokenizer model and configuration are authoritative.

### Choosing or working with them

For an application engineer, the most important question is usually not which algorithm sounds best in isolation, but whether the **exact tokenizer associated with the model** is used consistently:

1. Use the model’s published tokenizer and chat template for token counting, prompt construction, and decoding.
2. Measure token counts on representative data: target languages, code, identifiers, domain terminology, and user-provided text.
3. Check how special tokens, whitespace, normalization, and unknown or byte-fallback cases behave.
4. Reserve context capacity for instructions, conversation history, retrieved material, output, and tool-format overhead.
5. Treat a tokenizer change as a compatibility and evaluation change. Token IDs index learned embedding and output weights; changing the vocabulary or mapping without a compatible model can corrupt the interface.

For domain-specific vocabulary, first quantify fragmentation and its effect on quality, context use, and cost. Retrieval, glossary context, or a model with better tokenizer coverage may be safer than changing the tokenizer. Adding vocabulary entries generally requires corresponding embedding/output weight initialization and training or adaptation, followed by careful evaluation.

### Concise interview answer

“WordPiece is a subword tokenization method that learns a fixed vocabulary of pieces and commonly encodes a word by vocabulary matching, with continuation markers such as `##` in some implementations. SentencePiece is a framework rather than one algorithm: it can train Unigram or BPE tokenizers directly from raw sentences and package normalization and whitespace handling with the model. Its visible `▁` marker often denotes whitespace boundaries. The key distinction is method versus framework. In production I would not swap or choose one based only on the name; I would use the tokenizer and configuration paired with the model, measure token efficiency on real languages and domain text, and keep the tokenizer vocabulary aligned with the model’s embedding and output weights.”

### Revision summary

| Term | Remember |
|---|---|
| WordPiece | A subword algorithm; vocabulary pieces are used to represent words and rare forms compositionally. |
| SentencePiece | A framework that can implement Unigram or BPE and package normalization/whitespace behavior. |
| `##` | Common WordPiece-style continuation marker; implementation convention, not a universal rule. |
| `▁` | Common SentencePiece whitespace-boundary marker. |
| Key correction | SentencePiece is not synonymous with Unigram; it also supports BPE. |
| Production rule | Use the exact tokenizer and configuration that match the model weights. |

<br><br><br>

## What is positional encoding, and why is it needed in Transformers?

**Answer:**

### Why Transformers need position information

Self-attention compares token representations and combines information across positions. By itself, attention does not inherently know whether a token appeared first, last, or next to another token: if the same token vectors are presented in a different order, a plain self-attention operation without position-dependent information is permutation-equivariant. Language, however, depends strongly on order: “dog bites person” and “person bites dog” contain the same words but express different relationships.

A Transformer therefore needs a way to make position or relative order available to its layers. **Positional encoding** is the broad term for injecting this information into a model’s token representations or attention computation. Some designs add position vectors to token embeddings; others alter queries and keys or the attention scores directly.

### Common approaches

| Approach | How position enters the model | Strengths | Trade-offs |
|---|---|---|---|
| Sinusoidal absolute encoding | Adds fixed sine/cosine vectors at each position to token embeddings. | No learned position table; deterministic and provides structured position signals. | Extrapolation to much longer sequences is not guaranteed to preserve model quality. |
| Learned absolute embeddings | Adds a learned vector for each supported position. | Simple and directly trainable for positions seen during training. | Position table has a configured maximum; extending it requires adaptation and does not guarantee reliable long-context behavior. |
| Relative position representations/biases | Represents relative offsets between query and key positions, often as an attention bias or learned feature. | Makes relative distances explicit and can suit tasks where relative order matters. | Specific mechanisms have different limits, implementation complexity, and extrapolation properties. |
| Rotary Position Embedding (RoPE) | Rotates query and key dimensions according to position so their attention interaction reflects relative offsets. | Common in decoder-only LLMs; integrates position into attention scores and naturally expresses relative-position effects. | Long-context extension still requires careful design and evaluation; ordinary training-range behavior does not imply arbitrary length generalization. |

These are families of methods, not interchangeable configurations. The correct interpretation depends on the model’s actual architecture and implementation.

### Sinusoidal intuition

In the original Transformer, a position \(p\) is represented by sine and cosine values at different frequencies. A standard form is:

\[
PE(p,2i)=\sin\left(\frac{p}{10000^{2i/d_{\text{model}}}}\right),\qquad
PE(p,2i+1)=\cos\left(\frac{p}{10000^{2i/d_{\text{model}}}}\right)
\]

Different dimensions vary at different rates, creating a structured signature for each position. The model receives the sum of token and position representations:

\[
X_p = E(\text{token}_p)+PE(p)
\]

This formula is useful as a classic example; many current LLMs do not use additive sinusoidal encodings.

### RoPE intuition

With RoPE, position-dependent rotations are applied to query and key vectors inside attention. The dot product between a query at one position and a key at another becomes sensitive to their relative offset. Position information therefore affects how tokens attend to each other without simply adding a separate position vector to the token embedding.

RoPE is widely used in decoder-only models, but the name alone does not guarantee good extrapolation beyond training context. Long-context methods may rescale or modify position frequencies, and the resulting model should be evaluated on long inputs for retrieval, reasoning, and quality—not just for whether it accepts a larger token count.

### Example: order changes meaning

Suppose the tokens are `A`, `chases`, and `B`. Without positional information, attention can access the same set of token representations regardless of their ordering, making it difficult to represent which entity is the subject and which is the object. Position-aware representations allow the network to learn patterns associated with the tokens’ order and relative locations. Position does not itself encode grammar or meaning; it gives the model information from which those patterns can be learned.

### Practical implications

- **Position is distinct from token identity.** Token embeddings identify token types; positional information identifies where tokens occur or how far apart they are.
- **Context capacity is not the same as context quality.** Extending a model’s configured context limit does not ensure it can use distant information accurately. Positional scheme, training data, attention design, and evaluation all matter.
- **Long input has system costs.** Position support does not eliminate the memory and compute costs of attention or the growing KV cache during generation.
- **Truncation and chunking still matter.** If the application’s prompt exceeds the supported context, it must select, retrieve, summarize, or chunk content. A larger positional range is not a substitute for relevant context.
- **Checkpoint compatibility matters.** Positional scheme and configuration are part of the model architecture. Changing them while loading weights can alter behavior; context-extension adaptations need corresponding implementation support and validation.
- **Different components can use positions differently.** Encoder, decoder, and multimodal architectures may use different positional schemes or position IDs. Follow the specific model’s documented input format.

### Concise interview answer

“Self-attention alone does not encode token order: it computes interactions over representations, so a Transformer needs position-dependent information to distinguish sequences such as ‘A chases B’ and ‘B chases A.’ Positional encoding is the broad mechanism for injecting position or relative-distance information into token representations or attention. The original Transformer added sinusoidal vectors to token embeddings; learned absolute embeddings are another option. Many modern decoder-only LLMs use RoPE, which applies position-dependent rotations to queries and keys so attention scores reflect relative offsets. Relative biases are another family. Each approach has trade-offs, and none guarantees arbitrary-length generalization. In production I check the checkpoint’s positional configuration, budget against the actual context limit, and evaluate quality at the intended long-context lengths rather than assuming a larger configured window will work.”

### Revision summary

| Question | Recall |
|---|---|
| Why needed? | Attention alone does not tell the model token order. |
| What does it do? | Injects absolute or relative position information into representations or attention. |
| Classic method | Sinusoidal vectors are added to token embeddings. |
| Common modern method | RoPE applies position-dependent rotations to queries and keys. |
| Key caveat | A larger context limit does not guarantee long-context quality or extrapolation. |
| Engineering action | Match positional configuration to checkpoint; test quality and resource use at target lengths. |

<br><br><br>

## What are embeddings?

**Answer:**

### Core idea

An **embedding** is a dense numeric vector that represents an item—such as a token, sentence, image, user, or product—in a learned or designed vector space. In machine learning, embeddings give models a continuous representation on which mathematical operations can be applied. Similarity in that space can capture useful patterns, but only to the extent that the model and training objective have shaped it to do so.

The word “embedding” is used for different representations:

- **Token embeddings** map discrete vocabulary IDs to vectors used as inputs to a language model.
- **Hidden-state embeddings** are contextual vectors produced by intermediate or final Transformer layers for tokens or sequences.
- **Text or semantic embeddings** are vectors produced by an embedding model, often used to compare, cluster, classify, or retrieve passages.
- **Multimodal embeddings** represent images, audio, video, or different modalities in a shared or related vector space.

These are related ideas, but they are not interchangeable. In particular, a generative LLM’s internal token embedding table is not automatically a good sentence-embedding model for semantic search.

### Token embeddings inside an LLM

Token IDs are categorical integers, not quantities: token ID 200 is not inherently “twice” token ID 100. A learned embedding matrix \(E\in\mathbb{R}^{V\times d}\), where \(V\) is vocabulary size and \(d\) is hidden width, maps each ID to a vector:

\[
x_t=E[\text{token\_id}_t]
\]

The vectors are learned as part of model training. They are combined with positional information and processed by Transformer layers. As the token representations move through the network, they become **contextual**: the representation for a token can differ depending on its surrounding sequence.

For example, the token “bank” can occur in “river bank” and “bank account.” Its initial token embedding may be the same if the tokenizer uses the same token ID, but the contextual hidden states can differ because attention incorporates surrounding words.

### Semantic embeddings for retrieval

An embedding model can map an entire text, query, or chunk to a fixed-dimensional vector \(f(x)\in\mathbb{R}^d\). A retrieval system embeds documents and queries, then ranks candidate documents using a similarity or distance measure such as cosine similarity, dot product, or Euclidean distance.

In a retrieval-augmented generation (RAG) pipeline, a common flow is:

1. Split source documents into chunks that preserve useful context.
2. Encode each chunk with a chosen embedding model and store the vector alongside text, identifiers, and access-control metadata.
3. Encode a user query using the compatible query-embedding path.
4. Search the vector index for candidate chunks, optionally combined with keyword search or metadata filters.
5. Rerank and select evidence, then provide authorized passages to the generative model.

The embedding represents learned features of the input; the vector index performs nearest-neighbor search. Retrieval quality depends on the embedding model, text processing, chunking, query distribution, index configuration, and ranking—not simply on vector dimensionality.

### Similarity is useful, not identical to meaning

If vectors are normalized to unit length, cosine similarity is:

\[
\cos(\theta)=\frac{u\cdot v}{\|u\|\|v\|}
\]

It measures the angle between two vectors. Dot product also depends on vector magnitudes; Euclidean distance measures geometric separation. Whether these metrics rank results similarly depends on normalization and the embedding model’s training.

An embedding space is not a universal map of truth or meaning. “Close” means close according to the model’s learned representation and the chosen metric. A high similarity score does not prove that a passage answers a query, is factually correct, or is authorized for the user. Similarity thresholds must be calibrated on representative data, and retrieval should be evaluated with task-relevant metrics.

### How embeddings are learned

The training objective determines what information an embedding is useful for:

- **Language-model training** learns token representations that help predict tokens in context.
- **Contrastive learning** can bring related query/document or image/text pairs closer and push unrelated pairs apart.
- **Supervised metric learning** uses labels or relevance judgments to shape neighborhoods for a specific task.
- **Self-supervised or multimodal objectives** can align representations across views or modalities without requiring every example to have a manual class label.

An embedding vector’s individual dimensions usually do not have simple human-interpretable meanings. Useful behavior is often distributed across dimensions and reflected in relative geometry.

### Production considerations

- **Model and dimension compatibility:** Query and document vectors must be generated by compatible models, versions, preprocessing, and dimensionality. Mixing incompatible vector spaces can silently degrade retrieval.
- **Versioning and migrations:** When changing embedding models, do not mix old and new vectors blindly. Re-embed and rebuild or version the index, run retrieval evaluations, and plan a safe cutover.
- **Normalization and metric:** Follow the model’s recommendation for vector normalization and index metric. A mismatch between training assumptions and search configuration can change rankings.
- **Chunking and metadata:** Good vectors cannot compensate for chunks that omit needed context. Preserve source identifiers, timestamps, tenant/access labels, and other metadata needed for filtering and citations.
- **Privacy and security:** Embeddings may encode information about their source text and should not be assumed anonymous. Protect the vectors and associated text with appropriate access controls and retention policies; apply authorization during retrieval.
- **Cost and scale:** Embedding generation, vector storage, indexing, and query traffic have costs. Batch ingestion, caching where appropriate, quantization, index choice, and dimensionality trade-offs should be evaluated against recall and latency.
- **Evaluation:** Measure task-level retrieval quality such as recall@k and ranking quality, plus downstream answer quality. Offline embedding benchmarks may not predict performance on the application’s corpus and queries.

### Example: support-document search

Suppose a support team wants to find policy passages for customer questions. A document embedding model converts each authorized chunk into a vector. When a question arrives, the system embeds it in the same vector space, retrieves candidate chunks, applies tenant and permission filters, and optionally reranks them. The generator then answers from those passages and cites their source identifiers.

If a query uses a product code that is rare in the embedding model’s training data, semantic search may retrieve conceptually similar but incorrect products. A hybrid system that combines vector similarity with exact keyword matching and metadata filters can improve results. The team should evaluate whether the correct passage appears in the top \(k\), whether the answer is grounded in it, and whether access controls prevent cross-customer retrieval.

### Concise interview answer

“An embedding is a dense vector representation of an item that makes it usable by machine-learning models and similarity-based methods. In an LLM, token embeddings map vocabulary IDs to learned input vectors, which become contextual hidden states as they pass through Transformer layers. Separately, semantic embedding models map whole queries or documents to vectors trained for tasks such as retrieval; those are commonly used in vector search and RAG. The training objective determines what similarity in the space means, so a nearby vector is not automatically a true, relevant, or authorized answer. In production I keep query and document embeddings compatible, evaluate retrieval on the target corpus, version model migrations, apply metadata permissions, and select normalization and distance metrics based on the model’s intended use.”

### Revision summary

| Term | Remember |
|---|---|
| Embedding | Dense vector representation learned or designed for a task. |
| Token embedding | Vocabulary ID \(\rightarrow\) input vector for a language model. |
| Contextual representation | Hidden state shaped by the token’s surrounding sequence. |
| Semantic embedding | Often a fixed-size vector for a sentence, query, document, or other item. |
| Similarity | Geometry induced by the model and metric—not a guarantee of truth or relevance. |
| RAG use | Embed chunks and queries in a compatible space, retrieve, filter, rerank, and evaluate. |
| Production rule | Version embeddings, secure vector data, and measure retrieval quality on real queries. |

<br><br><br>

## Explain the Query(Q), Key(K), and Value(V) in attention.

**Answer:**

### Core idea

In attention, **queries (Q), keys (K), and values (V)** are learned projections of hidden-state vectors that let a model decide what information to collect from other positions:

- A **query** represents what the current position is looking for.
- A **key** represents features that other positions can be matched against.
- A **value** represents the information a position contributes if it receives attention.

These are useful functional analogies, not literal database queries or human-readable semantic labels. Q, K, and V are vectors learned through training so the attention layer can compute context-dependent mixtures of information.

### How the computation works

Let \(X\in\mathbb{R}^{T\times d_{\text{model}}}\) contain the hidden states for \(T\) sequence positions. The attention layer applies learned linear projections:

\[
Q=XW_Q,\qquad K=XW_K,\qquad V=XW_V
\]

The query at one position is compared with keys at allowed positions. Scaled dot products become attention scores; a mask may remove disallowed positions; softmax normalizes the scores into weights. Those weights are used to take a weighted sum of values:

\[
\operatorname{Attention}(Q,K,V)
=\operatorname{softmax}\left(\frac{QK^\top}{\sqrt{d_k}}+M\right)V
\]

Here \(d_k\) is the key/query dimension, and \(M\) is an optional additive mask. Each output position is therefore a mixture of value vectors, where the mixture weights depend on the queries and keys.

For batch size \(B\), sequence length \(T\), and \(H\) attention heads, implementations commonly reshape projected tensors into forms like \([B,H,T,d_h]\), where \(d_h\) is the per-head dimension. The matrix \(QK^\top\) then produces a score for every query/key position pair within each head.

### Simple example

Consider the sentence “The dog chased the ball because it was moving.” At the position for “it,” the query can produce high compatibility with keys at “ball” and other useful contextual positions. The resulting attention weights combine their value vectors into a representation for “it.” During training, the model learns the projections that make useful relationships emerge for its objective.

This example is an intuition, not a guarantee that one specific head resolves pronouns in a human-readable way. Attention weights describe one component of the computation and should not automatically be interpreted as a complete explanation of model behavior.

### How Q/K/V differ across attention types

| Attention type | Query source | Key/value source | Typical use |
|---|---|---|---|
| Self-attention | The sequence’s current hidden states | The same sequence’s hidden states | Tokens exchange information with other allowed tokens in that sequence. |
| Causal self-attention | Decoder hidden states | Decoder hidden states, with future positions masked | Autoregressive LLMs use prior tokens to predict the next token. |
| Cross-attention | Decoder or querying-stream hidden states | A separate encoder or context sequence | A decoder attends to encoded input, as in encoder-decoder generation. |

In **self-attention**, \(Q\), \(K\), and \(V\) are projected from the same hidden-state sequence, though with different learned matrices. In **cross-attention**, queries come from one sequence while keys and values come from another. In a causal decoder, the causal mask ensures that a query at position \(t\) cannot use keys or values from future positions.

### Why project three representations?

If attention compared raw hidden states directly and used the same representation for matching and content, the model would have less flexibility. Separate learned projections allow it to learn:

- which features make a position relevant to a query (Q/K matching),
- which information should be passed along when that position is selected (V content),
- different transformations for different attention heads and layers.

The projections are optimized end-to-end through the model’s training objective. Their dimensions and parameterization depend on the architecture. In grouped-query attention or multi-query attention, multiple query heads share fewer key/value heads, reducing KV-cache memory while preserving separate query projections.

### Practical interpretation and caveats

- **Attention weights are input-dependent.** The same model parameters can produce different weights for different tokens and contexts.
- **Softmax weights are relative.** They normalize over candidate key positions; a larger weight indicates greater allocation within that particular distribution, not an absolute measure of truth or importance.
- **Masks define the allowed set.** Padding, causal, or task-specific masks alter which keys can contribute.
- **Q/K/V are per layer.** Each Transformer layer has its own learned projections (subject to architecture-specific parameter sharing).
- **Caching uses K and V.** During autoregressive decoding, past keys and values can be cached so the model need not recompute them for every new token. Queries are computed for the newly processed position.
- **Implementation dimensions vary.** Head count, head size, number of KV heads, and projection layout differ across architectures; inspect the model configuration rather than assuming \(d_{\text{model}}/H\) for every variant.

### Concise interview answer

“Queries, keys, and values are learned projections of Transformer hidden states. The query at a position is compared with keys at candidate positions to produce scaled attention scores; after masking and softmax, those scores weight the corresponding value vectors. So Q and K determine where information is read from, while V carries the content that is combined. In self-attention all three come from the same sequence; in cross-attention the query comes from one sequence and keys/values from another. Causal masks prevent a decoder from reading future positions. The query/key/value analogy is useful, but they are learned vectors—not literal database fields—and attention weights alone are not a complete explanation of model behavior. In serving, K/V caching reuses past states, and GQA/MQA reduce cache size by sharing KV heads.”

### Revision summary

| Symbol | Role | Mental model |
|---|---|---|
| \(Q\) | Query projection | What this position seeks. |
| \(K\) | Key projection | What each candidate position can match against. |
| \(V\) | Value projection | Information contributed by each candidate. |
| \(QK^\top\) | Compatibility scores | Which allowed positions receive attention. |
| Softmax weights \(\times V\) | Weighted context | The information gathered for each query position. |
| Mask \(M\) | Information-flow constraint | Which candidate positions are allowed. |

<br><br><br>

## What is self-attention, and how does it work in Transformers?

**Answer:**

### Core idea

**Self-attention** is a Transformer operation that lets positions in one sequence exchange information with other allowed positions in that same sequence. Each position forms a query, key, and value from the sequence’s hidden states. Query-key compatibility determines how much each position uses the values from candidate positions, producing contextualized representations.

It is called **self**-attention because the queries, keys, and values are all derived from the same sequence of hidden states (using different learned projections). “Self” does not mean each token attends only to itself; it may attend to many other positions, subject to the mask.

### Computation step by step

Let \(X\in\mathbb{R}^{B\times T\times d_{\text{model}}}\) be the batch of hidden states, with batch size \(B\), sequence length \(T\), and model width \(d_{\text{model}}\).

1. **Project hidden states:**
   \[
   Q=XW_Q,\qquad K=XW_K,\qquad V=XW_V
   \]
   The learned matrices \(W_Q,W_K,W_V\) produce query, key, and value representations.
2. **Split into heads.** The projections are reshaped into attention heads. In standard multi-head attention, each head computes its own query-key scores and value mixture.
3. **Compute compatibility scores:**
   \[
   S=\frac{QK^\top}{\sqrt{d_k}}+M
   \]
   Each query is compared against candidate keys. \(d_k\) is the key dimension, and \(M\) is an optional mask that suppresses disallowed connections.
4. **Normalize over candidate positions.** A softmax over the key-position dimension turns each query’s scores into weights that sum to one over allowed positions.
5. **Mix values.** The attention weights form a weighted sum of the corresponding value vectors. Positions with larger relative weight contribute more to that head’s output.
6. **Combine heads and project.** Head outputs are concatenated and passed through an output projection, then combined with the surrounding block’s residual and normalization structure.

In compact form:

\[
\operatorname{SelfAttention}(X)=
\operatorname{softmax}\left(\frac{(XW_Q)(XW_K)^\top}{\sqrt{d_k}}+M\right)(XW_V)
\]

This formula represents one head for clarity. Multi-head attention repeats the operation using different learned projections and combines the results.

### Example: resolving context-dependent relationships

In “The dog chased the ball because it was moving,” the representation at “it” can attend to earlier words such as “dog” and “ball.” The model learns query/key/value projections that make useful contextual information available for later computation. The attention output is not necessarily a final pronoun-resolution decision; subsequent layers and feed-forward networks continue processing it.

Similarly, “A helps B” and “B helps A” have the same token types but different order and relationships. Positional information and attention together allow the model to produce different contextual representations for the two sequences.

### Masks determine what can be seen

Self-attention does not always allow every position to attend to every other position. The mask encodes the task’s information-flow rules:

| Masking pattern | Allowed context | Common use |
|---|---|---|
| Bidirectional | A token can attend to positions on both its left and right (subject to padding or other masks). | Encoder-style representations and many understanding tasks. |
| Causal | Position \(t\) can attend only to positions \(1,\ldots,t\), never future positions. | Decoder-only autoregressive language models. |
| Padding mask | Padded positions are excluded as keys/values. | Batched inputs of different lengths. |
| Local or sparse mask | Only selected nearby or patterned positions are visible. | Some long-sequence architectures to reduce compute or memory. |

For causal language modeling, the mask is essential: during training, the model can compute outputs for all positions in parallel, but each position must only use its valid prefix to predict the next token. Without the mask, a position could leak information from the token it is supposed to predict.

### Why self-attention is useful

- **Content-dependent routing:** The model can weight different context positions differently for each input and each query position.
- **Direct interactions across distance:** A token can attend to a distant token in one layer, instead of information necessarily passing through every intermediate position as in a basic recurrent chain.
- **Parallel training:** All positions’ attention outputs can be computed together within a layer (with causal masking applied where needed).
- **Flexible representations:** Different heads and layers can learn different interaction patterns, although attention heads should not be assumed to map neatly to human-readable concepts.

### Complexity and inference considerations

For full attention over \(T\) positions, the score matrix has \(T\times T\) entries per head. Standard full self-attention therefore has attention computation and intermediate score-size that grow approximately quadratically with sequence length during prefill. Optimized kernels such as FlashAttention reduce memory traffic and avoid materializing the full matrix in the same way, but do not change the underlying full-attention interactions or their asymptotic pairwise computation.

During autoregressive decoding, causal structure allows the model to cache keys and values from prior tokens. A new token’s query attends over the cached history plus its current state, avoiding recomputation of earlier K/V projections. The cache reduces repeated compute but consumes memory proportional to sequence length, batch size, layers, KV-head count, head dimension, and cache precision. Grouped-query and multi-query attention reduce the number of stored key/value heads.

### Common misunderstandings

- Self-attention is not an explicit search over words or a symbolic reasoning procedure; it is a learned tensor computation.
- Attention weights are relative to the candidate positions and are not, by themselves, a complete explanation of the model’s decision.
- A causal decoder does not see future tokens, but a bidirectional encoder can see tokens on both sides.
- Attention’s ability to connect distant positions does not mean the model reliably uses all long-context information.
- Efficient kernels improve execution, but do not necessarily reduce the model’s theoretical full-attention interactions.

### Concise interview answer

“Self-attention lets tokens in the same sequence build context-dependent representations by exchanging information. The hidden states are projected into Q, K, and V; scaled query-key dot products, plus any mask, produce softmax weights over candidate positions; those weights combine the values. Multi-head attention performs this in parallel across learned subspaces. In a decoder-only LLM, a causal mask prevents a token from seeing future positions, while encoder attention is often bidirectional. This operation supports direct token interactions and parallel training, but full attention has quadratic pairwise cost in sequence length. At inference, KV caching avoids recomputing prior keys and values, trading memory for decode efficiency. Attention is a useful mechanism, not a guarantee of reasoning, factuality, or interpretability.”

### Revision summary

| Element | Recall |
|---|---|
| Self-attention | Q, K, and V all originate from the same sequence. |
| Score | Query-key compatibility, scaled by \(\sqrt{d_k}\), then masked. |
| Output | Softmax weights form a weighted mixture of values. |
| Causal mask | Blocks future-token information in autoregressive decoding. |
| Benefit | Content-dependent interactions and parallelizable sequence processing. |
| Cost | Full attention compares position pairs, with roughly \(O(T^2)\) sequence scaling. |
| Serving | KV cache avoids recomputing prior K/V but consumes memory. |

<br><br><br>

## What is Cross Attention in Transformers?

**Answer:**

### Core idea

**Cross-attention** lets one sequence of representations attend to a separate sequence of representations. The **queries** come from the sequence that needs information, while the **keys and values** come from the sequence that provides the information:

\[
Q=X_{\text{query}}W_Q,\qquad
K=X_{\text{source}}W_K,\qquad
V=X_{\text{source}}W_V
\]

\[
\operatorname{CrossAttention}(X_{\text{query}},X_{\text{source}})
=\operatorname{softmax}\left(
\frac{QK^\top}{\sqrt{d_k}}+M
\right)V
\]

The query sequence determines **where to read**; the source sequence supplies **what can be read**. This differs from self-attention, where Q, K, and V are all projected from the same sequence.

### Encoder-decoder example

In a machine-translation Transformer, the encoder processes the source sentence and produces contextual encoder states. The autoregressive decoder processes the partial translated output. In each decoder layer’s cross-attention sublayer:

1. Decoder hidden states are projected to queries.
2. Encoder outputs are projected to keys and values.
3. Each decoder position compares its query against source keys.
4. The resulting attention weights combine source values into a context vector.
5. That context is incorporated into the decoder representation used to predict the next translated token.

For example, while generating a translation of a sentence, a decoder position can assign attention to different source words or phrases as it produces each target token. The model learns the alignment behavior; cross-attention does not require a fixed one-to-one mapping between source and output tokens.

In a typical encoder-decoder architecture, the encoder may use bidirectional self-attention over source tokens, the decoder uses causal self-attention over generated tokens, and cross-attention connects decoder queries to encoder states.

### How it differs from self-attention

| Property | Self-attention | Cross-attention |
|---|---|---|
| Query source | A sequence’s hidden states | The querying/decoder sequence |
| Key/value source | The same sequence’s hidden states | A separate source/context sequence |
| Main function | Mix information within one stream | Condition one stream on another |
| Example | Tokens in a prompt attend to prior prompt tokens | Generated text attends to encoded input or image features |
| Masking | May be bidirectional or causal | Often masks padding in the source; decoder causality is typically handled by decoder self-attention |

Cross-attention itself does not necessarily enforce causal ordering on the source. If the decoder also needs to avoid future generated tokens, its self-attention sublayer uses a causal mask separately.

### Other applications

- **Text-to-image or image-conditioned generation:** Text or latent queries may attend to visual features, or a denoising model may use cross-attention to condition image generation on text embeddings.
- **Multimodal models:** One modality’s representation stream can query another modality’s features, such as text attending to image patches or audio representations.
- **Sequence-to-sequence tasks:** Summarization, translation, and speech recognition can use a decoder conditioned on encoder representations.
- **Conditioning on external context:** Architectures may use cross-attention to incorporate encoded documents or other context, though many decoder-only RAG systems instead concatenate retrieved text into the prompt and apply self-attention to the combined sequence.

These are architectural patterns rather than universal implementation details. Some modern models fuse modalities through shared tokens or other mechanisms without a distinct cross-attention layer.

### Computation and engineering considerations

If the query sequence length is \(T_q\) and source length is \(T_s\), cross-attention computes score interactions with shape approximately \([T_q,T_s]\) per head. Its cost depends on both lengths, roughly \(O(T_qT_s)\) for the attention interaction, rather than a single square \(T\times T\) matrix. The source K/V projections can often be computed once and reused across decoder generation steps when the source is fixed. Padding masks are important for variable-length source batches.

In an encoder-decoder serving system, caching source-side keys and values can reduce repeated work during autoregressive decoding. The cache and source representations still consume memory, and long source sequences increase attention work. In multimodal systems, patch, frame, or audio-token counts can make source length large, so efficient encoders, downsampling, selection, and attention strategies may be necessary.

### Common misunderstandings

- Cross-attention is not simply “attention across distant words”; its defining distinction is that Q and K/V come from different representation streams.
- In the original encoder-decoder Transformer, the decoder uses both causal self-attention and cross-attention; one does not replace the other.
- A decoder-only LLM that receives retrieved text concatenated into its prompt may process it with self-attention, not a separate cross-attention layer.
- Attention weights indicate a computation’s relative weighting, not a complete explanation or guarantee that the model used evidence correctly.

### Concise interview answer

“Cross-attention allows one representation stream to read from another. Queries come from the target or decoder states, while keys and values are projected from a separate source, such as encoder outputs. The scaled query-key scores are masked and normalized, and the weights combine source values into context for each query position. In an encoder-decoder model, the decoder uses causal self-attention for its generated prefix and cross-attention to condition on the encoded input. The pattern is also used in some multimodal models. Its attention cost depends on query length times source length, and source K/V can often be cached when the source is fixed. It is distinct from decoder-only RAG setups that concatenate retrieved passages and use ordinary self-attention over the combined prompt.”

### Revision summary

| Concept | Remember |
|---|---|
| Cross-attention | One sequence attends to a separate source sequence. |
| Queries | Come from the stream that needs information. |
| Keys and values | Come from the stream providing information. |
| Encoder-decoder | Decoder self-attention handles target history; cross-attention reads encoder outputs. |
| Cost shape | Attention interaction scales with query length \(\times\) source length. |
| Common use | Translation, conditional generation, and some multimodal architectures. |
| Important distinction | Retrieved text concatenated into an LLM prompt usually uses self-attention, not necessarily cross-attention. |

<br><br><br>

## Why do we scale the dot product attention by √dₖ in the Transformer architecture?

**Answer:**

### Core reason

Scaled dot-product attention divides the query-key dot product by \(\sqrt{d_k}\), where \(d_k\) is the dimensionality of each query/key head:

\[
\operatorname{Attention}(Q,K,V)
=\operatorname{softmax}\left(\frac{QK^\top}{\sqrt{d_k}}+M\right)V
\]

The scaling keeps attention logits at a reasonable magnitude as the head dimension grows. Without it, dot products tend to have larger variance in higher dimensions, often making the softmax distribution too sharp and its gradients too small to learn effectively.

### Intuition from variance

Assume, for intuition, that the components of a query \(q\) and key \(k\) are independent, zero-mean, and have unit variance. Their dot product is:

\[
q\cdot k=\sum_{i=1}^{d_k}q_i k_i
\]

Each product has approximately unit variance under these assumptions, so the sum has variance approximately \(d_k\) and standard deviation approximately \(\sqrt{d_k}\). Dividing by \(\sqrt{d_k}\) brings the score’s scale back to roughly constant as \(d_k\) changes.

This is an explanatory approximation, not a claim that trained query/key components are always independent unit-variance random variables. The key engineering effect is that the scale is controlled rather than growing directly with head dimension.

### Why softmax cares

Softmax is sensitive to the relative magnitude of its input logits:

\[
\operatorname{softmax}(z_i)=\frac{e^{z_i}}{\sum_j e^{z_j}}
\]

If unscaled query-key scores become large, exponentials amplify their differences. The distribution can become close to one-hot: one key receives almost all probability and others receive nearly none. In saturated regions, small parameter changes may produce very small gradients, making optimization harder or less stable. Scaling helps keep scores in a range where the model can learn useful, non-degenerate attention distributions.

The factor is \(\sqrt{d_k}\), not \(d_k\), because the dot-product standard deviation grows approximately with the square root of the number of summed components under the usual variance assumptions.

### Numerical illustration

Suppose a head has \(d_k=64\). Under the simplifying assumptions above, an unscaled dot product has standard deviation on the order of \(\sqrt{64}=8\). Dividing by 8 puts the score scale back near 1. This does not force any particular attention distribution; learned projections, masks, and actual input statistics still determine the logits.

### What the scaling does—and does not do

- **Does:** Normalize the expected scale of query-key scores across head dimensions, helping softmax and optimization behave well.
- **Does not:** Guarantee uniform attention, improve factuality, or tell the model which token is semantically important.
- **Does not replace masks:** The mask still determines which positions are allowed to contribute.
- **Does not mean temperature:** Attention scaling is part of the attention computation; generation temperature is a separate decoding control applied to output logits.
- **Architecture detail:** Implementations may combine scaling into a kernel or projection, but the effective attention score must follow the model’s intended scaling convention.

### Concise interview answer

“The query-key dot product sums \(d_k\) componentwise products. If those components have roughly independent unit variance, the score variance grows proportional to \(d_k\), so its standard deviation grows like \(\sqrt{d_k}\). Large logits passed to softmax make it very peaked, which can saturate gradients and make attention harder to train. Dividing by \(\sqrt{d_k}\) keeps the score scale more stable across head dimensions. It’s a variance-control factor, not a semantic rule or generation temperature, and masking is still applied separately.”

### Revision summary

| Point | Remember |
|---|---|
| Formula | Scale scores as \(QK^\top/\sqrt{d_k}\). |
| Statistical intuition | A sum of \(d_k\) terms has standard deviation roughly proportional to \(\sqrt{d_k}\). |
| Softmax effect | Prevents logits from becoming unnecessarily large and overly saturated. |
| Benefit | More stable attention distributions and useful gradients. |
| Distinction | Attention scaling is not output sampling temperature and does not replace masking. |

<br><br><br>

## What is causal masking?

**Answer:**

### Core idea

**Causal masking** restricts each position in an autoregressive sequence from attending to future positions. At position \(t\), the model can use tokens at positions \(1,\ldots,t\), but not tokens after \(t\). This enforces the left-to-right information flow required for next-token prediction.

Without a causal mask, a model trained to predict the next token could look at the answer token—or even later tokens—while computing its representation. That would be information leakage: training would solve an easier task than inference can perform.

### How the mask works

Attention first computes query-key scores. A mask is added before softmax so disallowed scores contribute zero probability:

\[
\operatorname{Attention}(Q,K,V)
=\operatorname{softmax}\left(\frac{QK^\top}{\sqrt{d_k}}+M\right)V
\]

For causal self-attention, an additive mask has the conceptual form:

\[
M_{ij}=
\begin{cases}
0, & j\le i\\
-\infty, & j>i
\end{cases}
\]

Here \(i\) is the query position and \(j\) is the key position. Adding \(-\infty\) before softmax makes the probability for a future key zero. Real kernels often use an equivalent boolean mask or a numerically safe finite representation.

For a sequence of four positions, the visible attention pattern is:

| Query position | Allowed key positions |
|---|---|
| 1 | 1 |
| 2 | 1, 2 |
| 3 | 1, 2, 3 |
| 4 | 1, 2, 3, 4 |

This lower-triangular pattern allows each token to use itself and its prefix, but never its future.

### Why training can still be parallel

Causal masking restricts **what information** each position can access; it does not require the implementation to compute positions one at a time. During training, the full sequence is present and all position representations can be calculated in parallel using the triangular mask. Each position’s output remains independent of future tokens by construction.

At inference, prompt prefill can also process the supplied prompt positions in parallel under a causal mask. Newly generated tokens are then produced autoregressively: each next token depends on the preceding tokens selected so far.

### Causal mask versus other masks

| Mask | Purpose |
|---|---|
| Causal mask | Prevents a query position from reading future sequence positions. |
| Padding mask | Prevents padded tokens in a batch from being treated as valid context. |
| Cross-attention source mask | Prevents attending to padding or unavailable positions in a separate source sequence. |
| Local/sparse attention mask | Restricts attention to a designed neighborhood or pattern, often to manage long-sequence cost. |

These masks can be combined. Correct mask shape, broadcasting, polarity, and position offsets matter in implementation, especially with packed sequences, padding, cached decoding, or variable-length batches.

### Cached decoding and common pitfalls

During incremental decoding, the model may process only the newly appended token and let it attend to cached keys and values from the prefix plus its own current key/value. Since the cache contains only past and current positions, a full square causal mask may not be needed in that particular kernel path. The equivalent causal constraint must still hold.

Common mistakes include:

- **Wrong mask polarity:** Some APIs use `true` to mean “keep”; others use it to mean “mask out.” Confirm the library contract.
- **Off-by-one alignment:** The current token may attend to itself; masking it accidentally can break the computation.
- **Target leakage:** Training targets and input shifts must align with the mask so the model predicts the next token, not a visible target token.
- **Padding leakage:** A causal mask alone may not exclude padding keys in batched inputs.
- **Incorrect cached positions:** When using KV cache, positions and mask offsets must correspond to the full sequence, not merely the current chunk.
- **Unstable all-masked rows:** Softmax over only masked logits is undefined in ideal arithmetic; robust kernels and input layouts should avoid or safely handle such rows.

### Concise interview answer

“Causal masking enforces autoregressive information flow: a query at position \(i\) may attend to keys at positions \(j\le i\), but not future positions \(j>i\). We add a mask—conceptually negative infinity—to future attention logits before softmax, giving them zero probability. This prevents target leakage during next-token training and matches generation, where future tokens are unavailable. The full training sequence can still be computed in parallel because the triangular mask preserves the constraint independently at each position. Padding and cache-position masks may also be needed; implementation details such as mask polarity and offsets are common sources of bugs.”

### Revision summary

| Question | Recall |
|---|---|
| What does it block? | Future keys for each query position. |
| When applied? | To attention logits before softmax. |
| Why needed? | Prevents future-token leakage and supports next-token generation. |
| Does it prevent parallel training? | No; all positions can be computed together with the triangular constraint. |
| Other masks? | Padding, cross-attention, and local/sparse masks may also apply. |
| Debug focus | Mask polarity, target shift, padding, and KV-cache position offsets. |

<br><br><br>

## What are multi-head attention mechanisms? Why use multiple attention heads?

**Answer:**

### Core idea

**Multi-head attention (MHA)** runs several attention operations in parallel, each with its own learned query, key, and value projections. Each head computes a contextual representation in a different learned subspace; the head outputs are concatenated and projected back to the model width.

For input hidden states \(X\), head \(h\) typically computes:

\[
\operatorname{head}_h
=\operatorname{Attention}(XW_Q^{(h)},XW_K^{(h)},XW_V^{(h)})
\]

Then the heads are combined:

\[
\operatorname{MHA}(X)
=\operatorname{Concat}(\operatorname{head}_1,\ldots,\operatorname{head}_H)W_O
\]

Masks, including a causal mask in decoder-only models, are applied within each head’s attention calculation.

### Why use multiple heads?

With one attention operation, all query-key matching and value aggregation would share one projection space. Multiple heads allow the model to learn distinct projections and combine several context-mixing patterns in one layer. Different heads may respond to different relationships or features, such as nearby syntax, longer-range references, or other contextual patterns.

This is a capacity and optimization benefit, not a guarantee that each head learns one clean, human-interpretable function. Heads can be redundant, specialize in unexpected ways, or change behavior across layers and models. Attention visualization alone is not a complete explanation of what the network computes.

### Dimensions and computation

Let the model width be \(d_{\text{model}}\) and number of query heads be \(H\). A common design uses per-head dimension \(d_h=d_{\text{model}}/H\), so concatenating all head outputs returns a vector of width \(d_{\text{model}}\). However, this relationship is a common configuration, not a universal rule; architectures can use different head dimensions or grouped key/value heads.

For a batch with \(B\) sequences of length \(T\), the query, key, and value projections are reshaped to include a head dimension, conceptually \([B,H,T,d_h]\). Each head forms attention scores across sequence positions, applies the mask and softmax, and computes a weighted sum of its values. The outputs are transposed and concatenated along the feature dimension, then passed through the output projection \(W_O\).

### Why not simply make one very wide head?

Separate heads provide multiple learned similarity and aggregation spaces. A single head with the same aggregate width would still have one set of attention weights per query position, whereas MHA can produce different attention distributions in parallel and combine their outputs. This can make the layer more expressive for a fixed model width.

In practice, head count also changes implementation efficiency, parameter organization, memory behavior, and hardware utilization. Increasing the number of heads while holding \(d_{\text{model}}\) fixed often decreases each head’s width; it does not automatically increase total representational capacity or quality.

### MHA, GQA, and MQA

| Variant | Query heads | Key/value heads | Main implication |
|---|---:|---:|---|
| MHA | Multiple | Usually one KV head per query head | Flexible head-specific keys/values, but larger KV cache. |
| Grouped-query attention (GQA) | Multiple | Fewer than query heads | Groups query heads to share K/V heads, reducing KV-cache memory and bandwidth. |
| Multi-query attention (MQA) | Multiple | One shared K/V head | Further reduces K/V storage, with a different quality/architecture trade-off. |

These variants retain multiple query heads but differ in how keys and values are shared. They are especially important for inference because KV-cache size depends on the number of KV heads, not just the number of query heads.

### Costs and trade-offs

- **Compute:** Every head performs attention over sequence positions. Standard full attention retains quadratic sequence-length interaction cost during prefill; splitting into heads does not remove that cost.
- **KV-cache memory:** In standard MHA, storing per-head keys and values can be expensive for long contexts and large batches. GQA/MQA reduce this by using fewer KV heads.
- **Parallel hardware execution:** Heads are naturally parallelizable, but very small head dimensions or poor alignment can be inefficient on a given kernel/hardware stack.
- **Model quality:** More heads are not automatically better. Quality depends on total width, depth, training data, optimization, and workload.
- **Interpretability:** A head’s attention pattern can be inspected, but should not be equated with a complete causal explanation of the model’s output.

### Concise interview answer

“Multi-head attention computes attention several times in parallel using distinct learned Q/K/V projections. Each head produces a different weighted mixture of context; the results are concatenated and passed through an output projection. This lets the layer combine multiple learned attention patterns rather than forcing all token interactions through one score distribution. Head count and dimension are architectural choices, not a guarantee that every head has a human-readable role. Standard MHA can use substantial KV-cache memory; GQA and MQA keep multiple query heads but share fewer key/value heads to reduce inference memory and bandwidth. All variants still require evaluating quality, latency, and memory on the target workload.”

### Revision summary

| Concept | Remember |
|---|---|
| Head | Its own learned Q/K/V projections and attention distribution. |
| Combine heads | Concatenate outputs, then apply output projection \(W_O\). |
| Why multiple? | Compute several contextual mixing patterns in parallel. |
| Interpretability caveat | Heads are not guaranteed to map to distinct human concepts. |
| MHA | Separate KV heads; larger cache. |
| GQA/MQA | Share fewer KV heads to reduce cache size and bandwidth. |
| Quality rule | More heads alone do not guarantee a better model. |

<br><br><br>

## What are Feed-Forward Networks in LLMs?

**Answer:**

### Core idea

A **feed-forward network (FFN)** in a Transformer—often called the **MLP** or **feed-forward sublayer**—is a learned nonlinear transformation applied independently to each token position’s hidden state. Attention lets positions exchange information; the FFN transforms the information available at each position. The two operations complement one another and are typically repeated in every Transformer block.

“Independently” means the FFN does not mix information between sequence positions within that sublayer. The same FFN weights are applied at every position, but each position has a different input vector after attention.

### Standard computation

A classic two-layer FFN takes a hidden vector \(x\in\mathbb{R}^{d_{\text{model}}}\), expands it to a wider intermediate dimension \(d_{\text{ff}}\), applies a nonlinear activation, and projects it back:

\[
\operatorname{FFN}(x)=W_2\,\phi(W_1x+b_1)+b_2
\]

Typically \(d_{\text{ff}}>d_{\text{model}}\). In a Transformer block, the FFN is combined with normalization and a residual path. A common pre-norm form is:

\[
Y=X'+\operatorname{FFN}(\operatorname{Norm}(X'))
\]

where \(X'\) is the hidden state after the attention sublayer and its residual update. Exact normalization order and residual layout vary across architectures.

### Modern gated FFNs

Many current LLMs use a gated FFN rather than a single activation between two linear projections. A representative SwiGLU-style form is:

\[
\operatorname{FFN}(x)=W_{\text{down}}\left(\operatorname{SiLU}(W_{\text{gate}}x)\odot W_{\text{up}}x\right)
\]

Here \(\odot\) is element-wise multiplication. One branch produces a gate, another produces features, and their product is projected back to the model width. Names and exact parameterization differ; gated FFNs are common, not mandatory.

### Why the FFN matters

- **Per-position transformation:** The FFN adds nonlinear computation after attention has gathered contextual information.
- **Capacity:** The wider intermediate representation and learned matrices contribute substantially to model parameters and compute.
- **Layer composition:** Repeated attention and FFN operations allow the model to transform representations across depth.
- **Different role from attention:** Attention mixes information across sequence positions; the FFN transforms each position’s feature vector using shared weights.

An intuitive view is: attention decides what contextual information is brought together, while the FFN applies learned transformations to the resulting representation. This is a helpful division of labor, not a literal separation of “memory” and “reasoning.”

### Dense FFNs and Mixture of Experts

In a **dense FFN**, every token position passes through the same feed-forward subnetwork in a layer. In a **Mixture-of-Experts (MoE)** FFN, a router selects one or more expert subnetworks for each token, so only a subset of the total expert parameters may be activated for that token. MoE can increase total parameter capacity without proportionally activating all parameters per token, but introduces routing, load-balancing, communication, and serving complexity.

### Practical engineering considerations

- **Compute and memory:** FFN matrix multiplications are a significant part of Transformer compute and parameter storage. Intermediate activations can also affect training memory.
- **Precision and quantization:** FFN weights and activations can be quantized or computed at lower precision to reduce cost, but quality and numerical behavior must be evaluated.
- **Architecture compatibility:** Activation function, expansion width, gating, bias usage, normalization, and tensor layout are checkpoint-specific. Reproducing or loading a model requires matching these details.
- **Inference optimization:** FFNs are generally applied to each token’s states; batching, kernel fusion, and efficient matrix multiplication can improve throughput. During single-token decoding, attention KV-cache traffic may also be a major bottleneck.
- **MoE serving:** Expert placement and routing can make latency and throughput depend on token distribution and all-to-all communication, so parameter count alone does not predict inference cost.

### Concise interview answer

“The Transformer FFN, or MLP, is a nonlinear transformation applied independently at each token position, with shared weights across positions. A classic version expands the hidden dimension, applies an activation, and projects back; many LLMs use gated variants such as SwiGLU. The attention sublayer mixes information across tokens, while the FFN transforms each token’s contextualized features. Both are repeated throughout the block stack, typically with normalization and residual connections. FFNs account for substantial model parameters and compute, and MoE models replace some dense FFNs with routed experts to increase total capacity while activating only a subset per token—at the cost of routing and systems complexity.”

### Revision summary

| Component | Remember |
|---|---|
| FFN/MLP | Nonlinear transformation of each token position’s hidden state. |
| Classic form | Expand \(\rightarrow\) activation \(\rightarrow\) project back. |
| Modern form | Often gated, e.g. SwiGLU-style activation and element-wise gating. |
| Contrast with attention | Attention mixes across positions; FFN transforms features position-wise. |
| MoE relation | Routes tokens to selected expert FFNs; adds system complexity. |
| Engineering lens | FFN dimensions, precision, kernels, and routing affect memory, compute, and throughput. |

<br><br><br>

## What is Generative AI?

**Answer:**

### Core idea

**Generative AI** refers to AI systems that learn patterns from data and use those learned patterns to produce new outputs. Outputs may include text, code, images, audio, video, structured data, or actions represented through a tool interface. “Generative” describes the system’s ability to create or continue data; it does not mean the output is necessarily novel in a legal sense, correct, safe, or produced through human-like understanding.

Generative AI is a broad category, not one model architecture. Large language models are one example. Other generative approaches include diffusion models, generative adversarial networks, variational autoencoders, autoregressive image/audio models, and multimodal systems.

### How generation works

A generative model learns a probability distribution or other generative process from training data. Given a prompt, condition, or latent input, it produces output according to that learned process.

For an autoregressive language model, text is represented as tokens and the model predicts one token at a time:

\[
P(x_1,\ldots,x_T)=\prod_{t=1}^{T}P(x_t\mid x_1,\ldots,x_{t-1})
\]

At inference, a decoding method selects tokens from the model’s output distributions until a stop condition is reached. A diffusion image model works differently: it learns to transform noise into a sample through a sequence of denoising steps, often conditioned on text or other inputs. These examples show why “generative AI” should not be equated only with chatbots or LLMs.

### Model capability versus application

A generative model supplies a learned generation capability. A product may wrap it with prompts, retrieval, tools, structured-output constraints, filters, deterministic business logic, or human review. For example, an AI drafting tool may generate suggested text, while application code checks permissions, validates required fields, logs a version, and asks a user to approve the draft before sending it.

This boundary is important: the model’s fluent output is not itself a guarantee that the application’s task completed correctly. Generation can be one stage in a workflow whose final result also depends on data quality, validation, authorization, and user experience.

### Generative AI compared with discriminative AI

| Dimension | Generative AI | Discriminative/predictive AI |
|---|---|---|
| Typical goal | Produce or model plausible data, conditioned on an input. | Predict a label, score, or decision boundary from an input. |
| Example | Draft a response, synthesize an image, or generate code. | Classify a support ticket as billing or technical. |
| Output | Often a sequence, sample, or structured artifact. | Often a class, probability, ranking, or scalar score. |
| Evaluation | Quality, relevance, fidelity, groundedness, safety, and task success may all matter. | Often evaluates predictive metrics such as accuracy, precision/recall, calibration, or ranking quality. |
| Key caveat | Plausible output can be incorrect or unsupported. | A score can also be biased or miscalibrated; it is not automatically a valid decision. |

The boundary is not absolute. A generative model can perform classification by generating a label, and a predictive model can be part of a generative workflow. Choose the paradigm based on the task, requirements, and measured system performance.

### Where it is useful—and where it is not

Generative AI is useful when flexible synthesis, transformation, or interaction is valuable: drafting, summarization, code assistance, multimodal creation, conversational interfaces, and extraction from varied inputs. It may be a poor choice when a deterministic rule, database query, or conventional model can meet the requirement more cheaply and reliably.

A senior engineer should start with the actual user problem and acceptance criteria, then decide whether generation is needed. The design should establish how correctness is measured, what errors are tolerable, what data can be used, when the model must abstain, and when a human must review the result.

### Risks and production requirements

- **Factual errors and hallucinations:** Generated content may be plausible but unsupported. Ground with trusted data, verify important claims, and provide abstention or escalation paths.
- **Bias and uneven performance:** Training data and deployment context can produce different quality across languages or populations. Evaluate representative cohorts and mitigate harms.
- **Privacy and intellectual property:** Data provenance, licensing, sensitive inputs, retention, and output handling require explicit governance and controls.
- **Prompt injection and misuse:** Treat user and retrieved content as untrusted; enforce permissions and tool restrictions in application code, not only in prompts.
- **Evaluation difficulty:** There may be many acceptable outputs and no single exact label. Use task-specific automated checks, human review, adversarial tests, and production monitoring.
- **Operational cost and latency:** Input/output length, model choice, tool calls, traffic, and serving setup determine cost and responsiveness.

### Concise interview answer

“Generative AI describes systems that learn from data and produce new outputs such as text, code, images, audio, or video. It is broader than LLMs: autoregressive models generate token sequences, while diffusion models generate samples through iterative denoising, among other approaches. The model generates candidates, but a production application adds context, validation, permissions, safety controls, evaluation, and human oversight as appropriate. I use generative AI when flexible synthesis provides value that simpler deterministic or predictive methods cannot meet as effectively, and I evaluate the complete workflow for quality, groundedness, safety, latency, cost, and user impact. Fluency is not evidence of correctness.”

### Revision summary

| Concept | Remember |
|---|---|
| Generative AI | AI that models data patterns to produce conditioned outputs. |
| Scope | Includes LLMs, diffusion, and other modalities/architectures. |
| Generation | Can be autoregressive, iterative denoising, or another generative process. |
| Not guaranteed | Plausibility does not imply correctness, safety, or originality. |
| Product boundary | Model output must be integrated with application logic and controls. |
| Senior decision | Use generation when it earns its cost and risk against simpler alternatives. |

<br><br><br>

## What is the context window in LLMs, and why does it matter?

**Answer:**

### Core idea

An LLM’s **context window** is the bounded amount of tokenized input and, depending on the model/API, generation state that the model can process for a request or conversation. It is not measured in words or characters, and the exact accounting rules vary by provider and architecture. The window generally has to accommodate the serialized prompt—such as instructions, conversation history, retrieved passages, and tool results—and leave room for generated output.

The context window is the model’s immediate working input for a forward computation. It should not be confused with persistent user memory, a database, the model’s training data, or a guarantee that every included token receives equal attention.

### What consumes the context budget?

A request can include:

- system and developer instructions,
- user messages and relevant conversation history,
- retrieved documents or other grounding context,
- tool definitions, tool calls, and tool results,
- formatting or response-schema instructions,
- multimodal content represented as tokens or model-specific inputs,
- output tokens reserved or generated for the response.

Special control tokens and serialization templates may also contribute. Consequently, a conversation that appears short in the UI can consume more tokens than expected, and the same text can tokenize differently across models.

### Why it matters

- **Input capacity:** If the prompt exceeds the supported limit, the request may be rejected, truncated, or require application-side selection and summarization.
- **Answer quality:** Relevant context can support grounded answers, but irrelevant or contradictory text may distract the model. More context is not automatically better.
- **Long-range use:** A model may accept a long sequence yet use information unevenly, for example overlooking content buried in the middle. Effective long-context performance must be evaluated.
- **Latency and throughput:** Processing long prompts increases prefill work and can reduce serving throughput. Generation still adds decode time.
- **Memory and concurrency:** During autoregressive serving, KV-cache memory grows with active sequence length, batch size, model layers, and KV-head configuration. Longer contexts can reduce the number of concurrent requests a GPU can support.
- **Cost:** API pricing commonly accounts for input and output tokens. Large histories, retrieved context, or tool traces can increase cost.
- **System design:** Context limits influence chunking, retrieval, summarization, conversation memory, and whether a model or architecture is suitable.

### Example: an assistant with a large document collection

Suppose a user asks about one clause in thousands of policy documents. Putting every document into the prompt would likely exceed the context window, increase cost and latency, and add irrelevant material. A RAG system instead retrieves a small set of relevant, permission-checked passages, places them in the prompt with the question and instructions, and reserves context for the answer. The system should measure whether the supporting passage was retrieved and whether the answer is grounded; fitting text into the window alone does not ensure the model used it correctly.

For a long conversation, the application may retain recent turns, summarize older discussion, or retrieve relevant past facts from a separate memory store. That memory mechanism is a system design choice, not an unlimited context window.

### Context window versus effective context

| Term | Meaning |
|---|---|
| Maximum context window | The model/API’s configured or documented token capacity under its input/output accounting rules. |
| Prompt length | Tokens actually supplied for a specific request, including formatting and context. |
| Effective context | The amount and location of information the model can use reliably for the task. |
| Persistent memory | Information stored outside the current model input and selectively reintroduced when needed. |
| Output budget | Tokens available for generated response; it may share an overall limit with input. |

A larger maximum window increases capacity, but not necessarily reliable recall or reasoning across that entire range. Evaluate retrieval, position sensitivity, distractor robustness, and task success at realistic sequence lengths.

### Practical context budgeting

1. Use the exact target model’s tokenizer and request format to estimate token use; character counts are only approximate.
2. Reserve space for the expected answer and any tool or structured-output overhead.
3. Keep instructions concise and prioritize relevant context.
4. Retrieve targeted passages rather than appending entire corpora.
5. Apply permission filters before retrieved material enters the prompt.
6. For long conversations, define a deliberate memory policy—recent turns, summaries, retrieval, or a combination—and test that important details are retained.
7. Monitor token counts, truncation, latency, cost, and quality in production, and handle limit errors explicitly.

### Concise interview answer

“The context window is the token capacity available to a model for processing a request, including the serialized instructions, conversation, retrieved context, tool content, and often output-budget constraints. It matters because it sets input limits and drives prefill latency, cost, throughput, and KV-cache memory. It also shapes system architecture: we need token-aware budgeting, retrieval or summarization for long inputs, and a clear conversation-memory strategy. A larger window does not guarantee that the model will reliably use every token, so I evaluate effective long-context performance on the application’s actual tasks. I also distinguish the request context from persistent memory, which lives outside the current model input and must be selectively retrieved.”

### Revision summary

| Topic | Remember |
|---|---|
| Definition | Bounded tokenized information available to the model for a request. |
| Budget includes | Instructions, history, retrieved/tool content, formatting, and output constraints. |
| System impact | Quality, latency, throughput, KV-cache memory, and cost. |
| Key distinction | Maximum window is not the same as effective context or persistent memory. |
| Engineering response | Token-aware budgeting, retrieval, summarization, memory policy, and explicit limit handling. |
| Evaluation | Test whether relevant information is actually used across realistic long inputs. |

<br><br><br>

## Why is the context window limited in LLMs?

**Answer:**

### Core idea

An LLM’s context window is limited because processing a longer sequence requires more computation and memory, the model must be trained to use positional information across that range, and deployed systems have finite hardware, latency, throughput, and cost budgets. The limit is therefore not just a tokenizer setting: it emerges from architecture, training, inference implementation, and product constraints.

The exact limits differ by model and serving API. A context window also does not imply the model can reliably use every token within it.

### Main sources of the limit

1. **Attention work grows with sequence length.** In standard full self-attention, each query position scores against key positions. For a sequence of length \(T\), the attention interaction involves roughly \(T^2\) position pairs per head. Optimized algorithms reduce memory traffic and improve practical efficiency, but full attention still has pairwise sequence scaling.
2. **KV-cache memory grows during generation.** Autoregressive serving stores past keys and values so it does not recompute the entire prefix each decode step. Cache memory grows approximately linearly with active sequence length, batch size, number of layers, KV-head count, head dimension, and bytes per value. Long contexts therefore reduce concurrent batch capacity.
3. **Training length matters.** A model trained mostly on shorter sequences may not reliably use much longer inputs even if its architecture or serving stack can accept them. Position representations, data, training objectives, and long-context examples influence extrapolation and recall.
4. **Hardware and latency are finite.** Long prompts increase prefill compute, memory bandwidth, queueing pressure, and time to first token. They can also lower throughput under concurrent traffic.
5. **The service must enforce a practical budget.** Providers and self-hosted systems set limits based on supported model configurations, memory allocation, batching, reliability, and economics. Input and output tokens may share a total request budget.

### Why longer context is not always better

A large context can contain irrelevant, redundant, stale, or contradictory material. This may raise cost and latency while making important evidence harder to locate. Models can also exhibit positional sensitivity—sometimes using information near the beginning or end better than information buried in the middle. Effective long-context performance must be measured for the actual task.

### Practical example

For a question-answering system over thousands of documents, placing the entire corpus in every prompt is generally infeasible and wasteful. A more scalable design retrieves a small set of relevant, permission-checked chunks, reranks them if needed, and includes only the best evidence in the prompt. For long conversations, retain recent turns and use summaries or an external memory store to bring back relevant older facts.

### Mitigation strategies and trade-offs

| Strategy | What it addresses | Trade-off |
|---|---|---|
| Retrieval (RAG) | Selects relevant external passages rather than sending all documents. | Retrieval can miss evidence or return distractors; requires indexing and access control. |
| Summarization/compaction | Compresses older conversation or documents. | Can omit details or distort facts; summaries need validation and update policies. |
| Chunking and hierarchical processing | Processes long content in bounded pieces, then combines results. | May lose cross-chunk relationships or require multiple calls. |
| Sliding-window or sparse attention | Reduces the number of token interactions in some architectures. | Restricts global interactions and changes model behavior/architecture. |
| Efficient attention kernels | Reduce memory traffic and improve practical full-attention execution. | Do not remove all sequence-length scaling or model context constraints. |
| KV-cache optimization | Reduces cache footprint or improves allocation, for example via GQA or quantization. | May involve quality, precision, or architecture trade-offs. |
| Long-context training/adaptation | Improves use of longer positions. | Costs compute and still requires task-level evaluation. |

### Senior-level engineering approach

- Count tokens with the deployed model’s tokenizer and account for serialization, tool schemas, retrieved passages, and output reserve.
- Measure quality, latency, memory, throughput, and cost at representative prompt lengths—not just the maximum supported length.
- Test whether key facts are retrieved and used at different positions, including middle-of-context and distractor cases.
- Prefer relevant context over maximum context; use retrieval and memory policies with explicit freshness and permission handling.
- Treat context extension as a model/system change that needs regression testing and capacity planning.

### Concise interview answer

“Context windows are limited by the costs of processing long sequences, especially full-attention prefill and the KV cache, as well as by training coverage, positional behavior, hardware, latency, throughput, and provider limits. Full attention has roughly quadratic position-pair work, while the KV cache grows with sequence length and concurrency. A model accepting a longer prompt also does not guarantee reliable use of all that information. In practice I use the target tokenizer to budget context, reserve output tokens, retrieve relevant passages or summarize history, and evaluate quality, latency, memory, and cost at realistic lengths. I treat retrieval or context extension as an evaluated system design choice, not as simply increasing a maximum-token setting.”

### Revision summary

| Cause | Impact |
|---|---|
| Full attention | Roughly \(O(T^2)\) interactions in sequence length. |
| KV cache | Memory grows with active tokens, layers, KV heads, and batch. |
| Training/positions | Long accepted inputs may still be poorly used. |
| Serving constraints | Latency, throughput, GPU memory, and cost set practical limits. |
| Main mitigation | Select relevant context with retrieval, chunking, and memory/summary policies. |
| Key caveat | Maximum window is not the same as effective context quality. |

<br><br><br>

## What is temperature in the context of LLMs, and how does it affect output?

**Answer:**

### Core idea

**Temperature** is a decoding parameter that rescales a model’s next-token logits before converting them to probabilities. It controls how concentrated or spread out the sampling distribution is; it does not retrain the model or add knowledge.

If the next-token logits are \(z_i\), temperature \(T>0\) produces:

\[
p_i(T)=\frac{\exp(z_i/T)}{\sum_j \exp(z_j/T)}
\]

### Effect on the distribution

- **Lower temperature** makes differences between logits more pronounced. High-probability tokens receive more probability, so sampled output is generally more predictable and less varied.
- **Higher temperature** flattens the distribution. Lower-ranked candidates become more likely, increasing variation but also the risk of incoherence or irrelevant output.
- **Temperature near zero** is often implemented as greedy or near-greedy selection, but exact handling of zero is implementation-specific; the formula itself divides by \(T\).

For example, if one token has a substantially larger logit than alternatives, lowering temperature concentrates probability on it. Raising temperature gives more probability mass to plausible alternatives. The model’s conditional ranking is generally preserved for positive temperature before other truncation transforms, but the sampling probabilities change.

### Temperature is not a quality switch

Temperature changes randomness in token selection, not the underlying model weights, context, factual grounding, or correctness. Lowering it can make a wrong answer more consistently wrong; raising it does not create useful knowledge. For tasks requiring exactness, rely on validation, constrained decoding, tools, or deterministic logic rather than temperature alone.

Temperature is also distinct from the \(\sqrt{d_k}\) scaling in attention. Attention scaling controls query-key score magnitude inside the Transformer; generation temperature rescales output logits during decoding.

### Interaction with other decoding controls

Temperature may be combined with top-k or top-p filtering. Those methods first restrict candidate tokens according to their respective rules, and sampling then occurs from the remaining distribution. The order and implementation details may vary by serving stack. A temperature value should therefore be evaluated with the rest of the decoding configuration, not interpreted in isolation.

### Choosing temperature in a product

| Workload | Typical consideration |
|---|---|
| Structured extraction or classification | Favor predictable output and add schema validation; low temperature or constrained decoding may help, but is not a correctness guarantee. |
| Creative drafting or brainstorming | Some diversity may be desirable; evaluate usefulness and unwanted variation. |
| Code generation | Balance alternative solutions against reliability; compile, test, or otherwise validate generated code. |
| High-stakes answer generation | Temperature is not a safety control; ground, verify, abstain, and use human review where appropriate. |

There is no universally correct temperature for a task. Build an evaluation set, vary decoding settings, compare task success and failure rates, and pin the selected configuration so regressions are detectable.

### Concise interview answer

“Temperature rescales next-token logits before softmax: \(p_i=\operatorname{softmax}(z_i/T)\). Lower temperature sharpens the distribution and makes sampling more predictable; higher temperature flattens it and increases diversity, with greater risk of low-probability continuations. It changes decoding behavior, not model knowledge or factual reliability, and it is separate from attention’s \(\sqrt{d_k}\) scaling. I tune it empirically alongside top-p/top-k on representative tasks, and use schema validation or deterministic checks when correctness matters rather than assuming low temperature guarantees it.”

### Revision summary

| Temperature change | Distribution effect | Typical output effect |
|---|---|---|
| Lower \(T\) | Sharper; more mass on top logits | More predictable, potentially repetitive |
| Higher \(T\) | Flatter; more mass on alternatives | More varied, potentially less coherent |
| \(T\to0\) | Approaches argmax behavior in common implementations | Near-greedy selection |
| Key caveat | Does not alter weights or guarantee correctness | Evaluate with other decoding controls |

<br><br><br>

## Why is the first token slower than the rest in an LLM?

**Answer:**

### Core idea

The first generated token often has higher latency because the system must first process the entire input prompt and produce the logits needed to choose that token. This initial work is called **prefill**. After that, autoregressive decoding usually processes one new token at a time and reuses cached key/value (KV) tensors from the prefix.

This is a common pattern, not an absolute law. Queueing, retrieval, network overhead, batching, model architecture, and serving implementation can change the observed latency.

### Prefill versus decode

1. **Request preparation:** The service receives the request, formats conversation history and instructions, may retrieve context or route the request, and tokenizes the prompt.
2. **Prefill:** The model processes all prompt tokens through its layers. Attention and feed-forward computation produce hidden states and KV tensors. The final prompt position’s logits are used to select the first output token.
3. **First-token delivery:** The selected token must be sampled or chosen, decoded into a displayable piece, and delivered to the client. If the application waits on a tool or safety step, that can add latency before visible output.
4. **Steady-state decode:** For each subsequent token, the model processes the new token and attends to cached prior K/V rather than recomputing all prefix K/V. The token is selected and streamed, then the process repeats.

The initial prompt may contain hundreds or thousands of tokens, while each decode iteration adds only one (or a small chunk of) token. As a result, prefill and the first-token path can take longer than the interval between later tokens, especially for long prompts.

### Latency terms

| Metric | What it measures |
|---|---|
| Time to first token (TTFT) | Time from request submission (or service-defined start) until the first output token is available. Includes queueing and prefill, plus any retrieval/tool path before generation. |
| Time per output token (TPOT) | Average or distribution of time between generated tokens after output starts. |
| End-to-end latency | Time until the full response or workflow completes, including output length and possible tool calls. |

Be precise about metric boundaries: some teams measure server-side inference only, while users experience network, client, and orchestration time too.

### What affects first-token latency?

- **Prompt length:** Longer prompts generally require more prefill work and can increase TTFT.
- **Queueing and concurrency:** A busy server may delay the request before model execution begins.
- **Model and hardware:** Parameter count, precision, accelerator capacity, memory bandwidth, and kernel efficiency matter.
- **Retrieval and tools:** Search, reranking, safety classification, or a required tool call may happen before user-visible generation.
- **Batching and scheduling:** Continuous batching improves throughput but scheduling choices can affect individual request latency.
- **Cold starts and initialization:** Serverless or newly loaded models may need startup, weight loading, or compilation.
- **Streaming and buffering:** A token may be generated but not visible until buffered, decoded, filtered, or sent over the network.

### Optimization approach

First trace and decompose TTFT into queue, orchestration, retrieval/tool, tokenization, model prefill, and delivery components. Then optimize the measured bottleneck:

- reduce irrelevant prompt tokens with retrieval, concise history, or context compaction;
- choose a model and serving engine appropriate to the latency target;
- use efficient prefill kernels and hardware with adequate memory bandwidth;
- tune batching and scheduling for the desired TTFT/throughput balance;
- prewarm models or reduce cold-start cost when applicable;
- stream output promptly and avoid unnecessary buffering;
- cache reusable computation where supported and safe.

Do not reduce context blindly: shorter prompts can lower latency but harm answer quality if they remove needed evidence. Evaluate quality alongside TTFT, TPOT, throughput, and cost.

### Concise interview answer

“The first token often takes longer because the model must prefill the entire prompt before it can produce the logits for the first completion token. That path also includes queueing, routing, retrieval or safety steps, tokenization, and delivery. Once generation starts, the server typically decodes one token at a time using a KV cache, reusing the prefix’s keys and values, so later token intervals can be shorter than the initial wait. I would measure TTFT separately from TPOT and end-to-end latency, trace the full request path, and optimize the dominant bottleneck—often prompt length, queueing, prefill kernels, or orchestration—while monitoring quality and throughput.”

### Revision summary

| Stage | Work |
|---|---|
| Before first token | Request handling, context assembly, optional retrieval/tools, full prompt prefill. |
| First token | Select from final prompt logits and deliver to the client. |
| Subsequent tokens | Incremental decode with cached prior K/V. |
| Metrics | TTFT, TPOT, and end-to-end latency measure different things. |
| Optimization | Trace first; then tune context, queueing, kernels, routing, and delivery. |

<br><br><br>

## Explain Top-p (nucleus) sampling and Top-k sampling. How do they differ?

**Answer:**

### Core idea

**Top-k** and **top-p (nucleus) sampling** are candidate-filtering methods used during next-token decoding. They restrict the vocabulary candidates considered for sampling, after which the remaining logits are renormalized into a probability distribution.

- **Top-k** keeps the \(k\) highest-scoring candidate tokens.
- **Top-p** keeps the smallest set of highest-probability tokens whose cumulative probability reaches or exceeds a chosen threshold \(p\).

Both are typically combined with softmax probabilities and may be used with temperature. They control diversity and candidate support; neither changes model weights or guarantees factual output.

### Top-k step by step

1. Compute next-token logits and convert them to probabilities (including any temperature transform).
2. Rank tokens by probability.
3. Keep the highest \(k\) tokens and mask the rest.
4. Renormalize the remaining probabilities and sample a token.

The candidate-set size is fixed, regardless of whether the distribution is sharply peaked or diffuse.

### Top-p step by step

1. Compute the next-token probability distribution.
2. Sort tokens from highest to lowest probability.
3. Find the smallest prefix whose cumulative probability is at least \(p\).
4. Keep that nucleus, mask the remaining candidates, renormalize, and sample.

The number of retained tokens varies with the distribution. If one token dominates, the nucleus may be small; if probability is spread across many alternatives, it may be larger. Implementations differ in details such as whether the token that crosses the threshold is retained, so exact boundary behavior can be library-specific.

### Comparison

| Property | Top-k | Top-p |
|---|---|---|
| Selection rule | Fixed number \(k\) of highest-probability tokens. | Variable-sized set reaching cumulative probability \(p\). |
| Adapts to distribution shape? | No; set size is fixed. | Yes; set size expands or contracts with uncertainty. |
| Main control | Candidate count. | Probability mass retained. |
| Potential failure | A fixed \(k\) may be too restrictive for diffuse distributions or too permissive for peaked ones. | A poorly chosen \(p\) can leave too few or too many options; result depends on probability calibration and implementation. |
| Common use | Bound the candidate set simply. | Keep an adaptive nucleus of plausible candidates. |

Some systems apply both filters. The order, tie handling, minimum-token constraints, and temperature interaction should be checked in the inference library rather than assumed.

### Example

Suppose the sorted next-token probabilities are \(0.60, 0.20, 0.10, 0.05, 0.05\).

- With top-k \(k=3\), the first three tokens are kept, totaling probability \(0.90\) before renormalization.
- With top-p \(p=0.80\), the smallest prefix reaching at least \(0.80\) is the first two tokens, totaling \(0.80\).

If instead probability were spread more evenly over many tokens, top-p would keep more candidates to reach the threshold, while top-k would still keep exactly three.

### Choosing settings responsibly

For structured extraction, classification, or other tasks where variation is undesirable, use appropriate constrained decoding or validation and test settings for stability. For creative generation, sampling may support useful variation, but excessive diversity can reduce coherence. In either case, compare task success, diversity, error rates, and latency on representative examples. Sampling filters are not substitutes for grounding, output validation, or safety controls.

### Concise interview answer

“Top-k keeps a fixed number of the most probable next tokens; top-p sorts candidates and keeps the smallest set whose cumulative probability reaches a threshold. The retained set under top-p adapts to the distribution—small when one option dominates and larger when probability is diffuse—whereas top-k always retains \(k\) options. The remaining probabilities are renormalized for sampling. Both can be combined with temperature, and their exact ordering and boundary behavior can be implementation-specific. I tune them against task-level quality and diversity; they affect sampling, not the model’s factual knowledge or safety.”

### Revision summary

| Method | One-line rule | Set size |
|---|---|---|
| Top-k | Keep the \(k\) highest-probability tokens. | Fixed. |
| Top-p | Keep the smallest sorted set reaching cumulative mass \(p\). | Variable. |
| After filtering | Renormalize and sample from retained tokens. | Depends on configuration. |
| Key caveat | Changes candidate sampling, not correctness or knowledge. | Evaluate with temperature and task metrics. |

<br><br><br>

## Compare greedy decoding, beam search, top-k, top-p, and temperature sampling. When does each fail?

**Answer:**

### Core idea

**Decoding** is the inference procedure that turns a model’s next-token probability distributions into an output sequence. The model produces logits for the next token; the decoding strategy determines which token or sequence to choose. Different strategies trade off determinism, diversity, search breadth, latency, and suitability for the task.

The methods in this question are not all mutually exclusive:

- Greedy decoding and beam search are search/selection strategies.
- Temperature transforms the sampling distribution.
- Top-k and top-p filter candidates, usually before sampling.

Sampling commonly combines temperature with top-k and/or top-p.

### Strategy comparison

| Strategy | How it works | Strengths | Typical failure modes |
|---|---|---|---|
| Greedy | Select the highest-probability next token at every step. | Fast, deterministic for fixed inputs/settings, simple. | Locally optimal choices can produce globally poor sequences; repetitive or generic text; no diversity. |
| Beam search | Maintain several partial sequences and expand high-scoring continuations, retaining the best-scoring beams. | Searches multiple candidates; useful for some constrained sequence tasks. | More compute/latency; can favor short or generic outputs depending on scoring; may still optimize likelihood rather than usefulness. |
| Temperature sampling | Sample from probabilities after dividing logits by temperature and applying softmax. | Controls randomness/variation. | Low values can be repetitive; high values can produce incoherent or low-probability continuations; not a correctness control. |
| Top-k sampling | Sample only from the fixed \(k\) highest-probability candidates. | Simple bound on candidate pool. | Fixed \(k\) may be too large for a peaked distribution or too small for a diffuse one. |
| Top-p sampling | Sample from the smallest high-probability set reaching cumulative mass \(p\). | Candidate set adapts to distribution concentration. | Poor threshold choice can over-restrict or allow excessive diversity; exact implementation details vary. |

### Greedy decoding

At every step, greedy decoding chooses \(\arg\max_i p_i\). It does not explore alternate continuations. A locally likely token may lead to a low-quality full response, and early choices constrain what can follow. Greedy is often appropriate when deterministic behavior is desirable, but structured output should still be validated, and deterministic does not mean correct.

### Beam search

Beam search tracks a fixed number of candidate sequences (the beam width). At each step it expands candidates and retains high-scoring partial sequences, often using cumulative log probability with length normalization or other constraints. It can improve search for tasks where sequence likelihood aligns with quality, but it is more expensive than greedy decoding and may produce bland or short outputs. For open-ended chat, maximizing likelihood is not necessarily the same as maximizing helpfulness or diversity.

### Sampling and combined controls

Temperature rescales logits:

\[
p_i(T)=\operatorname{softmax}(z_i/T)
\]

Lower \(T\) concentrates probability on high-logit tokens; higher \(T\) flattens it. Top-k then can cap candidate count, while top-p retains enough candidates to reach cumulative probability \(p\). After filtering, probabilities are renormalized and a token is sampled. Since the controls can interact and inference stacks may apply them in a specific order, tune and document the full configuration.

### Practical selection by workload

| Workload | Starting point | Additional safeguards |
|---|---|---|
| JSON or schema-bound extraction | Constrained decoding or low-variance decoding where supported. | Parse and validate schema; retry or return a controlled error if invalid. |
| Creative writing | Sampling with temperature and/or top-p tuned for desired variety. | Evaluate coherence, policy compliance, and user preference. |
| Translation or transcription | Often deterministic or task-specific decoding. | Evaluate exact task metrics and preserve required terminology/format. |
| Code generation | Greedy or sampling depending on use case and candidate selection. | Compile, run tests, sandbox execution, and review security implications. |
| High-stakes advice | Decoding choice alone is insufficient. | Ground in authoritative sources, verify, abstain, and escalate to qualified humans. |

### Evaluation and operations

Compare strategies on a fixed, representative evaluation set with multiple runs for stochastic methods. Measure task success, factuality or groundedness, diversity where desired, output validity, latency, tokens generated, and cost. For sampling, report variance across seeds or repeated runs; a single attractive example is not enough. Keep model version, prompt, tokenizer, and decoding parameters pinned for reproducible comparisons.

### Concise interview answer

“Greedy decoding takes the most likely token each step; beam search tracks multiple high-scoring partial sequences; sampling draws from a probability distribution. Temperature sharpens or flattens that distribution, while top-k keeps a fixed number of candidates and top-p keeps a variable set reaching a cumulative probability threshold. These controls can be combined. Greedy can make locally optimal but globally poor or repetitive text; beam search costs more and may favor generic high-likelihood outputs; sampling can be unstable or incoherent at aggressive settings. I choose based on task goals and evaluate output quality, validity, diversity, latency, and cost, adding deterministic validators or domain-specific checks where correctness matters.”

### Revision summary

| Method | Decision rule | Main risk |
|---|---|---|
| Greedy | Highest-probability token at each step. | Local optimum, repetition, no diversity. |
| Beam search | Keep several high-scoring partial sequences. | More cost; likelihood may not match quality. |
| Temperature | Rescale logits before softmax. | Too low: rigid; too high: noisy. |
| Top-k | Fixed candidate count. | Candidate set may not fit distribution shape. |
| Top-p | Adaptive cumulative-probability set. | Threshold misconfiguration; sampling variability. |
| Senior practice | Match decoding to the task and evaluate repeatedly. | Never treat decoding as a substitute for validation or grounding. |

<br><br><br>

## What are logits, and how are they used in text generation?

**Answer:**

### Core idea

**Logits** are the unnormalized real-valued scores a model produces for possible next tokens. For a vocabulary of size \(V\), the next-token logits are a vector \(z\in\mathbb{R}^{V}\): one score per vocabulary token. A logit is not itself a probability, and its absolute value is generally less meaningful than how it compares with other logits for that same prediction.

At inference, decoding transforms logits—possibly applying temperature, repetition penalties, token constraints, or candidate filtering—then converts the adjusted scores to probabilities and selects or samples a token.

### From logits to a token

The basic conversion uses softmax:

\[
p_i=\operatorname{softmax}(z)_i
=\frac{e^{z_i}}{\sum_{j=1}^{V} e^{z_j}}
\]

The resulting probabilities are non-negative and sum to one. The decoding method then chooses the next token:

1. The model computes hidden states for the current context.
2. An output projection maps the relevant hidden state to \(V\) logits.
3. Optional decoding transforms adjust the logits, for example temperature scaling \(z_i/T\) or masking disallowed tokens.
4. Softmax produces a distribution over permitted candidates.
5. Greedy decoding takes the maximum-probability token, while sampling draws a token according to the distribution (possibly after top-k or top-p filtering).
6. The chosen token is appended to the context and the process repeats until a stop condition is reached.

For a decoder-only model processing a prompt of length \(T\), the model can produce logits at all positions, but the final prompt position’s logits are usually used to choose the first generated token.

### Training connection

During next-token training, logits at each position are compared with the target next token using a loss such as cross-entropy. If the correct next token has low probability, its contribution to the loss is high; gradients update model parameters to improve the distribution. At inference, target tokens are not available—the model uses its generated history.

### Useful properties and caveats

- **Relative scores:** Adding the same constant to every logit leaves the softmax distribution unchanged. This is one reason the vector’s absolute offset is not important.
- **Not probabilities:** A logit can be negative, positive, or any finite real value; it must be normalized (or otherwise transformed) to obtain probabilities.
- **Not calibrated confidence by default:** A high probability for the chosen token is not a calibrated measure that the complete answer is factually reliable.
- **Decoding matters:** Temperature, top-k/top-p, biases, and hard constraints change how logits are converted into outputs. Pin these settings for reproducibility.
- **Numerical stability:** Implementations commonly compute softmax after subtracting the maximum logit, which preserves the distribution while avoiding overflow.
- **Vocabulary and masking:** Special tokens and disallowed tokens may have logits too; serving code can mask candidates according to task or control-flow rules.

### Concise interview answer

“Logits are the model’s raw, unnormalized scores over the vocabulary for the next token. Softmax converts them into a probability distribution. The decoding layer may first apply temperature, top-k/top-p filters, repetition penalties, or constraints, then select the argmax or sample a token. That token is appended to the context and generation repeats. During training, logits are compared with the next-token target using cross-entropy. Logits are not probabilities or calibrated confidence, and a high next-token probability does not guarantee that the generated answer is true.”

### Revision summary

| Term | Remember |
|---|---|
| Logit | Raw, unnormalized score per vocabulary token. |
| Softmax | Converts scores into a normalized probability distribution. |
| Decoding | Transforms/selects from logits or probabilities to choose a token. |
| Training | Cross-entropy compares predicted distribution with next-token target. |
| Caveat | Token probabilities are not calibrated truth confidence for the full answer. |

<br><br><br>

## What are stop tokens in LLMs, and how does an LLM know when to stop generating?

**Answer:**

### Core idea

An LLM generates tokens iteratively, so it needs a **termination condition** to end a response. Common mechanisms include a model-specific end-of-sequence or end-of-turn token, a serving-layer stop sequence, a maximum output-token limit, a tool handoff, or cancellation by the caller. The exact tokens and semantics depend on the model’s training format and serving API.

A model does not “know it is done” in a human sense. It produces a distribution over next tokens; it may generate a learned ending marker, or the application may stop generation when a configured condition is met.

### Learned stop tokens

Many models use dedicated special-token IDs to represent boundaries such as end of sequence, end of assistant turn, or handoff to a tool. These are control markers in the model’s token vocabulary, not merely ordinary words. During training, examples teach the model where such markers commonly occur. At inference, the model can generate one, and the serving runtime interprets it according to the model’s protocol.

Different chat formats may distinguish:

- **End of message:** this message ended, but the assistant turn may continue.
- **End of assistant turn:** the assistant is done responding for now.
- **Handoff marker:** control should be transferred to a tool or another component.

Do not assume these meanings map to identical token IDs across model families.

### Runtime stopping conditions

Generation may stop when:

1. A configured end token or end-of-turn marker is generated.
2. The output matches a configured stop string/sequence.
3. The maximum completion-token budget is reached.
4. A tool call or control-flow marker hands execution to the application.
5. The client cancels the request or the system terminates it due to timeout, policy, or error.

The runtime may strip a stopping marker from displayed text, preserve it in structured output, or expose a reason such as `stop`, `length`, or `tool_calls`. API semantics should be checked rather than inferred.

### Why stopping correctly matters

- **User experience:** Missing an end marker may cause truncated or unexpectedly continued responses.
- **Cost and capacity:** A model that fails to end can consume the output budget and serving resources.
- **Structured formats:** Stopping too early can leave invalid JSON or an incomplete code block; stopping too late can append unwanted text.
- **Tool orchestration:** A tool handoff must be distinguished from a user-facing final answer so the application can execute the requested action safely.
- **Evaluation:** Track stop reasons and incomplete outputs; do not score a length-truncated answer as a normal completion.

### Concise interview answer

“LLMs generate one token at a time and stop through learned control tokens or runtime conditions. A model may emit an end-of-sequence or end-of-turn marker; the serving layer may also stop on a configured string, token limit, tool handoff, cancellation, timeout, or policy decision. The model is not consciously deciding it is finished: it predicts a token sequence, and the model protocol and runtime interpret termination markers. In production I distinguish end-of-message, end-of-turn, and tool-handoff semantics, set output budgets, record stop reasons, and validate that structured outputs were not cut off.”

### Revision summary

| Stop mechanism | Typical meaning |
|---|---|
| EOS/end-of-turn special token | Model-generated control marker ending a sequence or assistant turn. |
| Stop sequence | Runtime pattern that halts generation when matched. |
| Output limit | Safety bound on completion length; may truncate the response. |
| Tool handoff | Control passes to application/tool execution rather than a final answer. |
| Cancellation/timeout | Request ends due to caller or service action. |
| Key caveat | Exact token IDs and API stop semantics are model/provider-specific. |

<br><br><br>

## What is the difference between a stop token and a stop sequence?

**Answer:**

### Core distinction

A **stop token** is a token ID—often a dedicated special token—that has a model- or protocol-defined meaning, such as ending a sequence, ending an assistant turn, or handing control to a tool. A **stop sequence** is a runtime-configured text or token pattern that tells the serving system to stop generation when the pattern appears.

In short: a stop token is part of the model’s token vocabulary and conversation protocol; a stop sequence is commonly an inference/API control configured by the caller or application. The details vary by tokenizer and provider, so always verify the specific API contract.

### Comparison

| Property | Stop token | Stop sequence |
|---|---|---|
| Representation | A specific token ID, often a dedicated special token. | A configured string or token pattern to match in generated output. |
| Origin | Usually defined by model/tokenizer/chat protocol. | Usually supplied as a generation parameter or runtime rule. |
| Semantics | May distinguish message end, assistant-turn end, or tool handoff. | Usually signals “halt when this pattern appears”; it may not carry model-level meaning. |
| Tokenization | Special token may map to one dedicated ID. | A text string may tokenize into one or multiple tokens and may cross chunk boundaries when streaming. |
| Visibility | Often not shown as ordinary user-facing text. | May or may not be included in the returned text, depending on API behavior. |
| Portability | Usually tied to a model family or format. | Syntax and matching behavior vary across serving APIs. |

### Example

A chat model may generate a dedicated end-of-turn token that tells the runtime the assistant has completed its response. Separately, an application could configure `"\nUser:"` as a stop sequence for a legacy prompt format, so generation halts before it begins generating the next speaker’s marker. The first is a protocol token with model-specific semantics; the second is an application-defined text pattern.

This example is illustrative: modern chat APIs may use structured message boundaries instead of visible strings such as `User:`. A stop string should not be used as a substitute for the model’s actual role/control protocol.

### Operational pitfalls

- **Partial matches during streaming:** A stop string may span multiple generated tokens or transport chunks. The serving layer must buffer enough output to detect it without leaking the matched suffix.
- **Overbroad patterns:** A stop sequence that appears naturally in valid content can truncate a response unexpectedly.
- **Token/string mismatch:** The model may emit a special token whose decoded display is not the literal string a client expects.
- **Tool control flow:** A tool-handoff token should trigger a validated tool workflow, not be treated as an ordinary end marker.
- **Truncation versus completion:** Stopping on a configured string or token limit may yield incomplete structured output; report and validate the stop reason.

### Concise interview answer

“A stop token is a model/tokenizer token ID with protocol semantics, such as end-of-turn or tool handoff. A stop sequence is a configured string or token pattern that the serving runtime watches for and uses to halt generation. A special stop token is generally part of the model’s learned chat format, whereas a stop sequence is an application-level control and may tokenize into several pieces. Their visibility and matching behavior are provider-specific. In production I avoid relying on guessed visible markers, handle stop patterns across streaming chunk boundaries, and distinguish normal completion from truncation or tool handoff.”

### Revision summary

| Question | Stop token | Stop sequence |
|---|---|---|
| What is it? | Special/model-protocol token ID. | Runtime-configured text/token pattern. |
| Who defines it? | Model/tokenizer/chat format. | Caller/API/application configuration. |
| Typical role | End message/turn or hand off control. | Halt generation when a pattern is observed. |
| Main risk | Misinterpreting model-specific control semantics. | Accidental truncation or streaming boundary bugs. |

<br><br><br>

## What are skip connections (residual connections) in Transformers?

**Answer:**

### Core idea

A **skip connection**, or **residual connection**, adds a sublayer’s input to its transformed output rather than requiring the sublayer to replace the entire representation:

\[
y=x+F(x)
\]

Here \(x\) is the input to a sublayer and \(F(x)\) is its transformation, such as attention or a feed-forward network (often with normalization applied according to the block design). The path that carries \(x\) directly around \(F\) is the skip connection; \(F(x)\) is the residual update.

### Why Transformers use residual connections

- **Information preservation:** A sublayer can refine a representation without having to reconstruct every useful feature from scratch.
- **Gradient flow:** During backpropagation, the identity path gives gradients a direct route through deep networks, helping optimization.
- **Incremental refinement:** Stacked layers can learn updates to prior hidden states rather than unrelated replacement representations.

This is especially valuable in deep Transformer stacks, where many attention and FFN sublayers are composed.

### Residuals in a Transformer block

A simplified pre-norm decoder block can be written:

\[
X' = X+\operatorname{Attention}(\operatorname{Norm}(X))
\]
\[
Y = X'+\operatorname{FFN}(\operatorname{Norm}(X'))
\]

Each sublayer output is added to its input, preserving the hidden-state shape so the next operation can continue. Other models use post-norm, parallel residual, gated residual, or other arrangements; check the architecture rather than assuming this exact ordering.

### Why residuals help gradients

For \(y=x+F(x)\), the derivative includes an identity contribution:

\[
\frac{\partial y}{\partial x}=I+\frac{\partial F(x)}{\partial x}
\]

The identity term can help gradients propagate even when the sublayer’s transformation has a small or poorly conditioned derivative. It does not eliminate vanishing/exploding gradients or guarantee stable training, but it gives optimization a useful direct path.

### Residual connection versus related concepts

| Concept | Meaning |
|---|---|
| Residual/skip connection | Adds a sublayer’s input to its output. |
| Residual branch | The learned transformation \(F(x)\) that updates the representation. |
| Normalization | Rescales activations; often used near residual sublayers but is a separate operation. |
| Dense/skip connection across many layers | Connects non-adjacent layers; not the same as the standard per-sublayer Transformer residual. |

### Practical considerations

- Residual addition requires compatible tensor shapes; projection shortcuts or architecture-specific adapters may be needed when dimensions differ.
- Norm placement and residual scaling affect activation and gradient behavior, especially in very deep models.
- Residual paths do not make a network’s output interpretable; layers can still transform representations in complex ways.
- When reproducing a checkpoint, residual ordering, normalization, scaling, and precision must match the model configuration.

### Concise interview answer

“A residual or skip connection adds a sublayer’s input to its output, \(y=x+F(x)\). In a Transformer, attention and FFN sublayers typically update the hidden state through these additive paths. This lets layers refine existing representations and gives gradients an identity route through deep stacks, improving optimization. Residuals are distinct from normalization, and the exact pre-norm, post-norm, or scaled-residual arrangement varies by architecture. They help training but do not by themselves guarantee stability or interpretability.”

### Revision summary

| Point | Remember |
|---|---|
| Formula | \(y=x+F(x)\). |
| Purpose | Preserve information and support direct gradient flow. |
| Transformer use | Commonly wraps attention and FFN sublayers. |
| Distinction | Normalization is related but separate. |
| Caveat | Ordering and scaling vary by architecture; residuals are not a guarantee of stability. |

<br><br><br>

## What is the difference between open-source and closed-source LLMs? When would you choose one over the other?

**Answer:**

### First clarify the terminology

“Open-source” and “closed-source” are often used casually for model availability, but they can hide important distinctions. A model may expose downloadable **weights** without publishing its training data, complete training code, or full reproducibility details. Its license may impose restrictions. A hosted model may expose only an API while the provider keeps weights and implementation private.

For a careful comparison, ask what is actually available: weights, architecture/configuration, tokenizer, inference code, training code, training data and provenance, evaluation details, and license rights. Use **open-weight** when weights are available but the broader system is not fully open.

### Trade-off comparison

| Dimension | Open-weight/self-hostable model | Closed/hosted model |
|---|---|---|
| Access | Weights may be downloadable and runnable on chosen infrastructure, subject to license. | Usually accessed through a provider API or managed service. |
| Control | Greater control over deployment, version pinning, fine-tuning, and serving configuration. | Provider controls model updates and serving implementation; API options define the available control. |
| Operations | Team owns hardware, capacity, upgrades, security, and serving reliability. | Provider manages much of the infrastructure; customer still owns integration, governance, and fallback design. |
| Data handling | Can support isolated or on-prem deployments, but the operator is responsible for controls. | Data is sent to the provider under its terms and configuration; assess retention, residency, and contractual guarantees. |
| Customization | May allow fine-tuning, quantization, and architecture-level serving changes, subject to license and capability. | Customization may be limited to prompts, tools, or provider-supported fine-tuning. |
| Cost profile | Upfront/ongoing GPU, engineering, and utilization costs; can be attractive at sustained high volume. | Usage-based pricing and less infrastructure ownership; may be economical for variable or lower workloads. |
| Capability and support | Quality and tooling vary by model and ecosystem. | Often offers strong managed capabilities, updates, documentation, and support, but details vary by provider. |
| Portability/vendor dependence | More deployment control but still dependency on a model, tokenizer, runtime, and license. | API/provider dependency can be substantial; abstraction and portability testing can mitigate it. |

Neither option is inherently more secure, private, capable, or cheaper. Those properties depend on the model, license, deployment, contract, workload, and operating controls.

### How to choose

Start from requirements and evidence:

1. **Quality:** Evaluate candidate models on representative tasks, languages, edge cases, and safety cases.
2. **Data governance:** Determine data sensitivity, residency, retention, provider training policy, audit requirements, and regulatory constraints.
3. **Latency and throughput:** Test realistic concurrency, p95/p99 latency, context lengths, and output lengths.
4. **Total cost of ownership:** Include tokens or API charges, GPUs, networking, storage, utilization, engineering, on-call, upgrades, and compliance.
5. **Customization and control:** Decide whether fine-tuning, quantization, constrained serving, or strict model version pinning is required.
6. **Operational capacity:** Assess whether the team can operate inference infrastructure and respond to failures.
7. **License and provenance:** Review permitted uses, redistribution, fine-tuning rights, attribution, and data provenance with appropriate legal review.
8. **Resilience and lock-in:** Plan provider or model fallback, abstraction boundaries, evaluation parity, and migration paths.

### Example decision

A startup validating a low-volume feature may choose a hosted model to avoid operating GPUs and to iterate quickly, after reviewing its data-handling terms. A company with strict on-premises requirements or sustained high throughput may evaluate open-weight models on its own infrastructure. It must include GPU capacity, serving expertise, model quality, license obligations, and security ownership in the comparison. A hybrid design can route different workloads to different models, but adds routing, evaluation, monitoring, and failure-handling complexity.

### Common misconceptions

- Downloadable weights do not necessarily mean the model is fully open-source or that training can be reproduced.
- Self-hosting does not automatically make data private; logs, telemetry, access controls, and operators still matter.
- A hosted API does not automatically mean weaker security; contractual and technical controls must be examined.
- Open-weight does not always mean unrestricted commercial use; license terms can be material.
- A lower per-token price or free weight download does not equal lower total cost of ownership.
- Provider abstraction does not guarantee portability: prompts, tool schemas, tokenizers, safety behavior, and output formats can differ.

### Concise interview answer

“I first distinguish open-source from open-weight: downloadable weights alone do not guarantee access to training data, code, reproducibility, or unrestricted licensing. A self-hostable model offers more control over versions, deployment, and customization but transfers GPU capacity, reliability, security, and operations to the team. A hosted closed model reduces infrastructure burden and may provide strong managed capabilities, but requires careful review of data handling, provider dependence, cost, and update control. I choose using task-specific quality evaluations, data-governance requirements, latency and throughput tests, total cost of ownership, license rights, and the team’s operational capacity. For some products, a hybrid or fallback strategy is justified, provided its extra complexity is measured and tested.”

### Revision summary

| Decision factor | Ask |
|---|---|
| Openness | Are weights, code, data, tokenizer, and license actually available? |
| Quality | Which candidate meets task and safety targets on representative evaluations? |
| Governance | Where does data go, how is it retained, and what controls/contracts apply? |
| Operations | Can the team serve, scale, secure, monitor, and upgrade a self-hosted model? |
| Economics | What is full TCO at expected and peak utilization? |
| Portability | How will version changes, provider failures, and migration be handled? |

<br><br><br>

## What is the difference between encoder-only, decoder-only, and encoder-decoder Transformer architectures?

**Answer:**

### Core distinction

The three Transformer families differ mainly in their **attention pattern**, **information flow**, and the task objective they are naturally suited to:

- **Encoder-only** models build contextual representations of an input using bidirectional self-attention.
- **Decoder-only** models use causal self-attention to predict or generate a sequence from left to right.
- **Encoder-decoder** models encode an input sequence, then generate an output sequence conditioned on the encoder representations through cross-attention.

These are architectural tendencies rather than hard limits on task capability. A task can often be formulated for more than one architecture, but the model’s training objective and interface affect how naturally it fits.

### Architecture comparison

| Architecture | Attention and information flow | Common training objective | Typical tasks |
|---|---|---|---|
| Encoder-only | Bidirectional self-attention: each input token can use context on both sides. | Often masked language modeling or another representation-learning objective. | Classification, token labeling, reranking, retrieval embeddings, and input understanding. |
| Decoder-only | Causal self-attention: each position uses only the prefix. | Commonly autoregressive next-token prediction, followed by task/instruction post-training as applicable. | Text/code generation, chat, and prompt-formulated tasks. |
| Encoder-decoder | Encoder uses bidirectional self-attention; decoder uses causal self-attention and cross-attends to encoder outputs. | Sequence-to-sequence denoising or conditional generation objectives. | Translation, summarization, speech/text transformation, and other input-to-output tasks. |

### How each works

**Encoder-only:** The input is embedded and processed with bidirectional attention. The resulting contextual vectors can represent the whole input, and a task-specific head may classify a pooled representation or label each token. Because a token can attend to tokens on both sides, this structure is useful for understanding a complete input. It does not natively generate left-to-right text in the same manner as a causal decoder, though it can be adapted for other objectives.

**Decoder-only:** The input prompt is processed with a causal mask. The model predicts the next token, appends the selected token, and repeats. During training, all positions can be computed in parallel under a causal mask, while the target is shifted so each position predicts the next token. Decoder-only models are flexible for generative interfaces, but generation is sequential and long prompts/outputs have serving costs.

**Encoder-decoder:** The encoder reads the source sequence and produces contextual states. The decoder generates the target sequence using causal self-attention over its own prefix and cross-attention to encoder states. This explicitly separates source understanding from target generation and is natural when there is a distinct input and output sequence.

### Choosing an architecture

| Requirement | Natural starting point | Why |
|---|---|---|
| Classify or represent a complete text input | Encoder-only | Bidirectional context and compact task heads are convenient. |
| Open-ended continuation or chat | Decoder-only | Next-token generation directly matches the task interface. |
| Transform one sequence into another | Encoder-decoder | Encoder conditions a separate autoregressive output stream. |
| Retrieval embeddings | Often encoder-style or a dedicated embedding model | Training can directly shape representations for similarity or relevance. |

The choice should be based on task quality, latency, throughput, memory, available checkpoints, deployment support, and data. A larger or newer model is not automatically a better architecture fit.

### Common misconceptions

- “Encoder” and “decoder” do not simply mean input and output in every architecture; the attention mask and objective define their roles.
- Decoder-only models can perform many understanding tasks when formatted as conditional generation, but may be less efficient than a purpose-built encoder for some workloads.
- Encoder-decoder models are not inherently more accurate; their suitability depends on the task and training.
- Modern LLMs frequently modify the original Transformer blocks, so architecture labels do not specify every detail.

### Concise interview answer

“Encoder-only Transformers use bidirectional self-attention to build representations of a complete input and are commonly used for classification, tagging, and embeddings. Decoder-only Transformers use causal self-attention and next-token prediction, making them natural for autoregressive generation and chat. Encoder-decoder models encode a source sequence bidirectionally and generate a target sequence with a causal decoder that cross-attends to the encoder states, which suits translation and other sequence-to-sequence tasks. I choose based on the task’s information flow and measured quality, efficiency, and deployment constraints—not only on model size.”

### Revision summary

| Type | Mask pattern | Mental model |
|---|---|---|
| Encoder-only | Bidirectional self-attention | Understand/represent the full input. |
| Decoder-only | Causal self-attention | Continue a prefix one token at a time. |
| Encoder-decoder | Bidirectional encoder + causal decoder + cross-attention | Transform a source sequence into a target sequence. |

<br><br><br>

## What is KV cache, and how does it speed up inference?

**Answer:**

### Core idea

The **key/value (KV) cache** stores attention keys and values already computed for previous tokens during autoregressive inference. When a decoder-only LLM generates a new token, it can reuse cached K/V states for the prefix instead of recomputing the projections for every earlier token at every decode step.

The cache is an inference-time optimization: it does not change model weights, token probabilities, or the causal attention rule. It trades additional memory for less repeated computation and lower per-token decode work.

### Without a cache

Suppose the prompt has \(T\) tokens and the model has generated \(n\) more. A naive approach could rerun the model over all \(T+n\) tokens to predict each next token. Across generation, this repeats substantial computation on the same prefix. In particular, past tokens’ key and value projections are recomputed even though those states have not changed.

### With a cache

1. **Prefill:** Process the full prompt. Each layer computes keys and values for its tokens and stores them.
2. **First selection:** Use the final prompt position’s logits to choose the first output token.
3. **Incremental decode:** Feed the new token through the model. At each layer, compute Q/K/V for the new token, append its K/V to the cache, and let its query attend to cached prior K/V plus its own position.
4. **Repeat:** Select another token and reuse the expanded cache until generation stops.

For causal attention, a new token needs to attend to the prefix, but past tokens do not need to be recomputed or updated because they cannot attend to future tokens.

### What is stored?

Each Transformer layer retains key and value tensors for the active sequence. A simplified cache shape is approximately:

\[
[B,\;H_{KV},\;T,\;d_h]
\]

for keys and another tensor of the same size for values, where \(B\) is batch size, \(H_{KV}\) is the number of key/value heads, \(T\) is cached sequence length, and \(d_h\) is head dimension. Exact layouts vary by runtime and architecture.

### Benefits and costs

| Benefit | Cost or limitation |
|---|---|
| Avoids recomputing prior K/V projections at every generated token. | Uses memory proportional to active context and batch size. |
| Improves incremental decode efficiency and often inter-token latency. | Long contexts and high concurrency can make cache memory a serving bottleneck. |
| Enables efficient token-by-token generation. | Cache allocation, fragmentation, and movement require runtime management. |
| Works naturally with causal attention. | Does not eliminate the cost of prompt prefill or all attention operations. |

The cache helps most in repeated decode steps. It does not make a long prompt free: prefill still processes the prompt, and the query for each generated token still attends over the relevant cached history.

### Production considerations

- Estimate cache use using actual layer count, KV-head count, head dimension, precision, context, and concurrency.
- Choose batch size and maximum sequence lengths together; increasing one can reduce capacity for the other.
- Consider GQA/MQA, cache quantization, paging/block allocation, prefix reuse, and admission control where supported.
- Monitor GPU memory, cache occupancy, allocation failures, queueing, TTFT, and TPOT under realistic workloads.
- Ensure cache entries are isolated by request/session and invalidated correctly; incorrect prefix reuse can leak or mix context.

### Concise interview answer

“A KV cache stores the keys and values from previous tokens at each Transformer layer during autoregressive inference. Prefill computes them for the prompt once. For each new token, the model computes the new Q/K/V, appends K/V to the cache, and the new query attends over cached history instead of recomputing all prior projections. This reduces repeated decode work and improves generation efficiency, but cache memory grows with sequence length, batch size, layers, KV heads, head dimension, and precision. It does not eliminate prompt-prefill cost or the need to budget GPU memory; serving systems use techniques such as GQA, quantization, paging, and admission control to manage the trade-off.”

### Revision summary

| Phase | KV behavior |
|---|---|
| Prefill | Compute and cache K/V for prompt tokens. |
| Decode step | Compute new token states; attend to cached prefix; append new K/V. |
| Benefit | Avoid repeated computation of old key/value projections. |
| Cost | Cache memory grows with tokens, layers, KV heads, batch, and dtype. |
| Caveat | Prefill still costs compute; cache is not free or shared indiscriminately. |

<br><br><br>

## Estimate the KV cache memory needed to serve a large model. How does it constrain batch size and context length?

**Answer:**

### Memory formula

To estimate KV-cache memory, count one key and one value vector for every cached token, every layer, and every key/value head. If tensors use \(b\) bytes per element:

\[
M_{\text{KV}}
=2 \times L \times B \times T \times H_{KV} \times d_h \times b
\]

where:

- \(2\) accounts for keys and values,
- \(L\) is the number of Transformer layers,
- \(B\) is the number of active sequences in the batch,
- \(T\) is the cached sequence length (prompt plus generated tokens),
- \(H_{KV}\) is the number of key/value heads,
- \(d_h\) is the dimension per head,
- \(b\) is bytes per cache element (for example, 2 for a 16-bit cache).

Since \(H_{KV}d_h\) is the total KV width per layer, the formula can also be written:

\[
M_{\text{KV}}=2LBT\,d_{\text{KV}}\,b,\qquad d_{\text{KV}}=H_{KV}d_h
\]

For standard multi-head attention, \(H_{KV}\) is often equal to the query-head count. For GQA or MQA, \(H_{KV}\) is smaller, which reduces cache memory.

### Worked example

Assume a hypothetical model has:

- \(L=80\) layers,
- \(H_{KV}=8\) key/value heads,
- \(d_h=128\),
- batch size \(B=1\),
- cached context \(T=32{,}768\) tokens,
- BF16/FP16 cache \(b=2\) bytes.

Then:

\[
M_{\text{KV}}
=2\times80\times1\times32{,}768\times8\times128\times2
=10{,}737{,}418{,}240\text{ bytes}
\]

That is approximately **10.74 GB decimal** or **10 GiB** for one sequence, before allocator overhead, temporary activations, model weights, runtime buffers, and other memory consumers. At batch size 8 and the same sequence length, the raw cache estimate is approximately **80 GiB**, illustrating why concurrency and long contexts quickly exhaust GPU memory.

This example intentionally specifies eight KV heads. If the same model used 64 KV heads with all other values unchanged, the cache would be eight times larger. Parameter count alone is not enough to estimate KV-cache size.

### How it constrains serving

KV cache scales linearly with \(B\) and \(T\). If the memory budget is fixed, supporting longer contexts leaves room for fewer concurrent sequences; increasing concurrency may require a smaller context limit or more GPUs. The usable capacity is lower than total device memory because the system also stores weights, runtime state, activations/workspaces, communication buffers, and fragmentation reserve.

The maximum batch is often not a single fixed number: requests have different prompt and generation lengths, and continuous batching changes active sequence composition over time. Capacity planning should use realistic length distributions and peak concurrency, not only an average prompt.

### Estimation checklist

1. Read the model configuration: layer count, KV-head count, head dimension, and any layer-specific variation.
2. Choose the maximum cached token count as prompt plus generated tokens (and any multimodal positions represented in the cache).
3. Use the actual KV-cache dtype, not automatically the model-weight dtype.
4. Multiply by concurrent active sequences or per-rank allocation as appropriate.
5. Add weights, workspace, runtime, communication, and fragmentation overhead separately.
6. Validate with the serving engine’s measured memory profile and account for tensor/pipeline parallel sharding or replication.

### Ways to reduce cache pressure

| Technique | Effect | Trade-off |
|---|---|---|
| Grouped-query or multi-query attention | Fewer KV heads than query heads. | Requires a model architecture trained/configured for it. |
| Lower-precision or quantized KV cache | Fewer bytes per cached value. | Possible quality/numerical effects and kernel constraints. |
| Paged/block-based allocation | Reduces allocation waste and supports flexible sequence lengths. | Runtime complexity; does not change the raw information requirement. |
| Prefix caching | Reuses identical prefix state across requests where safe. | Requires exact prefix matching and strict tenant/session isolation. |
| Admission control and limits | Prevents overload by bounding contexts and active requests. | May queue, reject, or truncate requests. |
| Context selection/compression | Reduces tokens entering the model. | Can remove useful evidence; evaluate quality and faithfulness. |

### Concise interview answer

“I estimate KV cache as \(2LBT H_{KV}d_hb\): keys and values, across layers, active sequences, cached tokens, KV heads, head dimension, and bytes per element. For an 80-layer model with 8 KV heads, head dimension 128, BF16 cache, one 32K-token sequence, it is about 10 GiB before weights and runtime overhead; batch eight would be about 80 GiB. GQA/MQA can reduce this because they reduce KV heads. Cache grows linearly with both context and concurrency, so those compete for GPU memory. I use the real model configuration and dtype, add all non-cache allocations, profile the actual serving engine, and plan using request-length distributions and peak load.”

### Revision summary

| Variable | Meaning | Scaling |
|---|---|---|
| \(L\) | Number of layers | Linear |
| \(B\) | Concurrent sequences | Linear |
| \(T\) | Cached tokens per sequence | Linear |
| \(H_{KV}d_h\) | KV width per layer | Linear |
| \(b\) | Bytes per element | Linear |
| Leading factor 2 | Keys plus values | Doubles the per-state storage |
| Capacity effect | Context and batch share memory budget | Longer contexts reduce concurrency |

<br><br><br>

## KV Cache Compression

**Answer:**

### Core idea

**KV-cache compression** reduces the memory or bandwidth required to retain attention keys and values during autoregressive inference. It is important because cache usage grows with active tokens, layers, KV heads, and concurrent sequences. Compression can reduce bytes per element, reduce the number of cached states, or avoid storing redundant data.

The techniques differ in whether they change representation precision, cache length, or the model’s attention architecture. They can affect quality and latency, so they should be measured on the target workload.

### Main approaches

| Approach | How it reduces cache use | Main trade-off |
|---|---|---|
| Lower-precision KV storage | Store K/V in fewer bits/bytes, such as FP8 or quantized formats. | Quantization error can affect attention and output quality; kernel support and scaling metadata matter. |
| GQA/MQA architecture | Store K/V for fewer heads while multiple query heads share them. | Requires a model designed or trained for the sharing pattern; not a transparent runtime change for arbitrary weights. |
| Eviction or sliding-window cache | Retain only recent tokens or selected positions. | Discarded history may contain information needed later; task quality can degrade. |
| Token selection/compression | Keep important tokens or compress their representations. | Selection may be wrong; compression adds algorithmic and evaluation complexity. |
| Paged/block cache management | Allocate K/V in blocks and reduce fragmentation/waste. | Improves utilization rather than reducing the mathematical bytes per stored token. |
| Prefix sharing | Reuse cache state for identical prompt prefixes where permitted. | Only works for matching prefixes and requires robust isolation and lifecycle management. |

These options can be combined, but their effects are not always additive. For example, quantizing an already compressed cache can create additional error.

### Quantized KV cache

Quantization maps higher-precision values to a lower-bit representation, often with per-tensor, per-channel, or per-block scales. Conceptually, a value \(x\) is represented by a quantized integer \(q\) and scale \(s\), so an approximation is \(\hat{x}=s q\) (possibly with a zero point or more involved scheme). The cache uses fewer bytes, but attention consumes approximate K/V values.

Important questions include:

- Is key and value quantization symmetric or different?
- What granularity and scaling metadata are stored?
- Are outliers handled robustly?
- Does the inference kernel dequantize efficiently or support the format directly?
- How does quality change at long contexts and high concurrency?

The effective memory reduction must include quantization metadata, alignment, allocator overhead, and whether temporary higher-precision copies are materialized.

### Eviction and selective retention

An unbounded cache grows with the generated sequence. A sliding-window strategy keeps only the most recent \(W\) tokens, bounding cache length, but can lose information from earlier context. Other strategies retain selected “important” tokens, sink tokens, or compressed summaries. These approaches change what history the model can attend to and are not equivalent to exact full-context caching.

They are appropriate only when the model/runtime supports the strategy and evaluation shows acceptable quality for the use case. Long-conversation benchmarks should test references to early details, topic changes, distractors, and multi-step dependencies.

### Memory impact example

With the earlier formula \(M_{\text{KV}}=2LBT H_{KV}d_hb\), reducing cache precision from 2 bytes per element to 1 byte approximately halves raw K/V storage, before scales and alignment. Reducing KV-head count by a factor of four approximately quarters the cache for the same \(L,B,T,d_h,b\). A sliding window caps \(T\), but may discard needed history. Paged allocation can reduce fragmentation but does not reduce the raw bytes for every live cached element.

### Production rollout

1. Establish a baseline with representative prompts, output lengths, concurrency, and quality metrics.
2. Measure raw cache bytes and total GPU memory in the actual serving runtime.
3. Apply one compression strategy at a time where possible.
4. Evaluate quality, long-context retrieval, latency/TPOT, throughput, and failure rates.
5. Test peak concurrency and allocation behavior, not only single-request memory.
6. Roll out gradually with a rollback path and monitor quality and resource metrics.

### Concise interview answer

“KV-cache compression reduces the memory footprint or allocation waste of the keys and values retained during autoregressive inference. Lower-precision or quantized cache reduces bytes per element; GQA/MQA reduce the number of KV heads; eviction or sliding windows reduce the number of retained tokens; paging improves allocation efficiency; and prefix sharing reuses identical cached prefixes when isolation is safe. These are not equivalent: quantization approximates values, eviction changes available context, and paging primarily reduces fragmentation. I evaluate quality—especially long-context behavior—alongside memory, TPOT, throughput, and concurrency, and verify that the serving kernels actually realize the expected savings.”

### Revision summary

| Technique | Reduces | Main risk/limit |
|---|---|---|
| KV quantization | Bytes per K/V element | Approximation error and kernel overhead |
| GQA/MQA | Number of KV heads | Architecture-dependent |
| Sliding window/eviction | Cached token count | Loses older context |
| Token compression/selection | Stored states | Selection/compression errors |
| Paging | Fragmentation/wasted allocation | Does not shrink raw live cache |
| Prefix reuse | Duplicate cache computation/storage | Exact matching and strict isolation required |

<br><br><br>

## What is model distillation, and how is it used with LLMs?

**Answer:**

### Core idea

**Knowledge distillation** trains a smaller or more efficient **student** model to reproduce useful behavior from a larger **teacher** model. The aim is to transfer selected capabilities into a model that may have lower inference cost, latency, memory requirements, or deployment footprint. Distillation is a training strategy, not merely weight compression, and success depends on which capabilities and data the student is taught to imitate.

For LLMs, “distillation” can refer to several procedures: training on teacher-generated input/output examples, matching teacher probability distributions (soft targets), transferring intermediate representations, or combining teacher supervision with human-labeled data and task-specific objectives. The exact method should be specified.

### Common distillation pipeline

1. **Define the target workload and constraints.** Identify the capabilities that must be retained, acceptable quality loss, deployment environment, latency, and cost targets.
2. **Choose a teacher and student.** The teacher should perform well on the intended tasks; the student may be smaller, faster, or architecturally suitable for deployment.
3. **Create representative training examples.** Use curated real examples, teacher-generated responses, and/or labeled data, while controlling privacy, provenance, licensing, and coverage.
4. **Train the student.** The student may learn from teacher responses using supervised fine-tuning, match teacher distributions with a distillation loss, or combine several signals. The student’s tokenizer and architecture determine what can be transferred directly.
5. **Evaluate against the teacher and requirements.** Compare task quality, robustness, safety, calibration, latency, memory, and cost. Include edge cases and cases where the teacher itself is unreliable.
6. **Deploy with monitoring and rollback.** A student should be promoted only if its end-to-end trade-offs meet the product’s acceptance criteria.

### Hard targets versus soft targets

**Response distillation** often trains the student on teacher-generated text as target sequences. It is relatively simple to use with a teacher API, but the student learns only from the examples and responses provided; it does not see the teacher’s full probability distribution.

**Logit or distribution distillation** uses teacher probabilities (“soft targets”) over candidate tokens. A common objective combines student cross-entropy with a divergence such as KL divergence between teacher and student distributions, optionally using a distillation temperature. Soft targets can convey relative preference among alternatives, but require access to teacher logits and compatible tokenization/output spaces in many implementations.

Other methods may match hidden states or attention-related representations, but differing architectures can make direct alignment difficult. These are possible techniques, not requirements for every distillation project.

### Why distill an LLM?

- **Lower inference cost:** A smaller student may require fewer accelerator resources per request.
- **Lower latency:** Smaller or specialized models can respond faster, especially for high-volume tasks.
- **Deployment flexibility:** A distilled model may fit on-device, at the edge, or in a restricted environment.
- **Capacity planning:** Specialized students can handle routine requests, while a larger teacher is reserved for difficult cases.
- **Knowledge transfer:** Teacher outputs can provide supervision where human labels are limited, subject to quality and rights constraints.

### Limitations and failure modes

- **Capability gap:** A student may not reproduce rare, complex, or long-horizon reasoning examples represented poorly in distillation data.
- **Teacher error transfer:** Incorrect, biased, or unsafe teacher outputs can become student targets.
- **Coverage and distribution shift:** A narrow synthetic dataset can cause overfitting and weak generalization.
- **Tokenizer/architecture mismatch:** Logit-level or hidden-state transfer may not be directly possible across incompatible vocabularies or structures.
- **Mode imitation:** The student may mimic style without acquiring robust task behavior; teacher response text is not proof of internal capability transfer.
- **Safety and memorization:** Synthetic data may expose sensitive content or reproduce source material; review data provenance and evaluate leakage.
- **Benchmark leakage:** Teacher-generated examples derived from evaluation data can contaminate measurement and inflate apparent performance.

### Distillation versus related techniques

| Technique | What changes | Primary goal |
|---|---|---|
| Distillation | Trains a student from teacher behavior or signals. | Transfer capability into a more efficient model. |
| Quantization | Represents a model’s weights/activations with lower precision. | Reduce memory and often improve serving efficiency without a new student architecture. |
| Pruning | Removes or sparsifies parameters/structures. | Reduce model size or computation, with possible quality loss. |
| Fine-tuning | Updates a model using task/domain examples. | Adapt behavior or knowledge; it may or may not involve a teacher. |

These approaches can be combined, but each has separate quality and implementation trade-offs.

### Example: routing routine support requests

A team may distill a strong hosted teacher into a smaller student for frequent, well-bounded support classification or response drafting. The team should create a diverse training set that includes ambiguous, adversarial, and abstention cases; verify teacher labels; and compare the student to the teacher and a deterministic baseline. A sensible serving policy can use the student for routine requests and route low-confidence or high-impact cases to a larger model or human reviewer. This preserves a cost/latency advantage without assuming the student matches the teacher on every case.

### Concise interview answer

“Distillation trains a smaller student to reproduce selected behavior of a larger teacher, with the goal of lower inference cost, latency, memory, or deployment footprint. For LLMs this may use teacher-generated response examples, soft probability targets, or representation-level losses; response distillation is possible through an API, whereas logit matching generally needs teacher distributions and compatible tokenization. The main risks are copying teacher errors, narrow data coverage, student failure on complex or rare cases, and privacy or evaluation contamination in synthetic data. I define the target workload first, curate and audit distillation data, compare the student on representative quality and safety evaluations, and use routing or escalation when the student is outside its validated capability envelope.”

### Revision summary

| Concept | Remember |
|---|---|
| Teacher | Larger or stronger model providing supervision. |
| Student | Smaller/efficient model trained to imitate selected teacher behavior. |
| Signals | Generated responses, soft token distributions, or representations. |
| Goal | Lower latency, cost, memory, or enable edge/on-device deployment. |
| Risks | Teacher errors, weak coverage, capability loss, privacy, and contamination. |
| Senior practice | Define workload, audit data, evaluate quality and safety, and route hard cases. |

<br><br><br>

## What is Mixture of Experts (MoE), and how does it work in models like Mixtral?

**Answer:**

### Core idea

A **Mixture of Experts (MoE)** layer contains multiple expert subnetworks and a learned **router** that chooses which expert or experts process each token. Rather than sending every token through one dense feed-forward network (FFN), the layer conditionally activates a subset of its experts. This can increase total parameter capacity without activating every expert’s parameters for every token.

In many Transformer MoE designs, attention remains dense while some or all FFN sublayers are replaced by routed experts. “MoE model” therefore does not necessarily mean every part of the network is sparse.

### A token’s path through an MoE layer

For token representation \(x\), a router computes scores over \(E\) experts, often with a learned projection and softmax:

\[
p(x)=\operatorname{softmax}(W_r x)
\]

A routing rule selects \(k\) experts, such as top-1 or top-2. The selected expert FFNs process the token, and their outputs are combined, often weighted by normalized router scores:

\[
y=\sum_{e\in\operatorname{TopK}(p(x))}g_e(x)\,F_e(x)
\]

where \(F_e\) is expert \(e\)'s transformation and \(g_e(x)\) is its routing weight. Exact routing, normalization, and residual placement vary across architectures. Routing is commonly performed per token, so different tokens in the same sequence may use different experts.

### Example: Mixtral-style routing

In the commonly described Mixtral 8x7B design, MoE feed-forward layers provide eight experts and route each token to two experts. The selected experts’ outputs are combined for that token. The “8x7B” label describes the expert configuration, not eight independent full models being run for every token: only a subset of expert FFNs is activated per token, while shared components such as attention also contribute to the model.

The exact active-parameter accounting depends on what is counted, including shared layers and routing components. The important interview point is the distinction between **total stored parameters** and **parameters activated per token**.

### Why use MoE?

- **Higher capacity per unit of active compute:** The model can store many experts but activate only a few for each token.
- **Conditional specialization:** Different experts may learn useful patterns for different kinds of tokens or tasks, though specialization is not guaranteed to be clean or human-interpretable.
- **Scaling options:** MoE can increase total parameter count while keeping per-token expert computation lower than activating all experts.

### Costs and failure modes

| Benefit | Cost or risk |
|---|---|
| Sparse expert activation can lower active FFN compute relative to a similarly sized dense model. | All or many expert weights may still need to be stored, loaded, or distributed, so memory is not proportional only to active parameters. |
| Experts may provide conditional capacity. | Router imbalance can overload a few experts while others are underused. |
| Compute can scale with selected experts rather than all experts. | Token dispatch and all-to-all communication across devices can dominate latency. |
| Large total capacity can coexist with fewer active parameters per token. | Expert capacity limits can cause token dropping, rerouting, or additional complexity if poorly configured. |
| Different tokens can take different expert paths. | Variable routing makes execution less uniform and can complicate batching, kernels, and tail-latency management. |

Training commonly includes mechanisms or objectives to encourage load balance, but their exact form varies. A model can have low nominal active FLOPs yet run slowly if routing requires expensive communication or poorly utilized hardware. Conversely, an optimized runtime and well-distributed routing can make sparse activation effective.

### MoE compared with a dense model

| Property | Dense Transformer | MoE Transformer |
|---|---|---|
| FFN path per token | Usually the same dense FFN is activated for every token. | Router selects a subset of expert FFNs for each token. |
| Total parameter capacity | All layer parameters belong to the active computation path. | Total expert parameters may be much larger than the subset activated per token. |
| Compute | More predictable per token for a fixed shape. | Can reduce active expert compute, but routing and communication add overhead. |
| Memory | Stores dense model weights. | May need to store/distribute many experts even though only some are active per token. |
| Serving | Relatively regular dense matrix operations. | Requires efficient routing, expert placement, load balancing, and communication. |

### Concise interview answer

“An MoE Transformer replaces selected dense FFN layers with multiple expert FFNs and a learned router. For each token, the router scores experts, selects one or a few, and combines their outputs. This allows a model to have high total parameter capacity while activating only a subset of expert parameters per token. Mixtral is a familiar example: its sparse FFN layers route each token to two of eight experts. The trade-off is that active FLOPs do not tell the whole serving story: expert weights still consume memory, and routing imbalance, dispatch, and inter-device communication can hurt throughput and tail latency. I would evaluate quality, active compute, memory footprint, routing balance, and real serving latency together.”

### Revision summary

| Term | Remember |
|---|---|
| Experts | Alternative FFN subnetworks in a layer. |
| Router | Scores experts and chooses a subset for each token. |
| Active parameters | Parameters used for one token’s computation; distinct from total stored parameters. |
| Main advantage | Conditional capacity with fewer active FFN computations per token. |
| Main challenge | Weight memory, load balancing, dispatch, and communication. |
| Production metric | Measure end-to-end throughput and tail latency, not just active FLOPs. |

<br><br><br>

## What is the difference between dense and sparse models?

**Answer:**

### Core distinction

In a **dense model**, the standard parameterized operations for a layer are generally applied to every input token or activation. A **sparse model** uses only a subset of possible parameters, connections, experts, or attention positions for a given input or operation. “Sparse” is an umbrella term: it may describe conditional computation, zero-valued/pruned weights, or sparse attention, and these are different design choices.

For LLMs, the most common interview contrast is **dense versus sparse MoE**:

- A dense FFN applies its full feed-forward network to each token.
- A sparse MoE FFN routes each token to only a subset of expert networks.

The model may still have dense attention, embeddings, or other components.

### Different meanings of sparsity

| Sparsity type | What is sparse? | Example |
|---|---|---|
| Conditional/MoE sparsity | Which expert parameter blocks are activated for a token. | Top-2 routing among many FFN experts. |
| Weight sparsity/pruning | Which individual weights or structured blocks are retained/used. | Pruning weights or using block-sparse matrix operations. |
| Sparse attention | Which query-key position pairs interact. | Local, sliding-window, or selected-token attention. |
| Activation sparsity | Which activations are nonzero or selected. | ReLU-induced zeros or routed computation. |

These approaches can coexist. An MoE model is sparse in expert activation even if each selected expert is a dense MLP. A model with sparse attention may still use dense FFNs.

### Compute, parameter count, and memory are different

Sparse models are often designed to reduce **active computation**, but the savings do not automatically apply to all resource categories:

- **Total parameters** count the model weights that exist.
- **Active parameters per token** count weights used for that token’s forward computation.
- **Compute (FLOPs)** depends on active operations and implementation.
- **Memory** depends on which weights and caches must be resident or accessible.
- **Latency/throughput** depends on kernels, batching, communication, and hardware utilization.

For example, an MoE model may activate two experts out of many for each token, reducing expert computation versus activating all experts. But it may still need to store or distribute weights for all experts. If experts are spread across devices, routing can introduce communication overhead that reduces the realized speedup.

### Dense versus sparse comparison

| Dimension | Dense | Sparse |
|---|---|---|
| Operations per token | Regular, predictable activation of the layer’s weights. | Input-dependent or structure-dependent subset of operations. |
| Hardware efficiency | Often maps well to highly optimized dense matrix multiplication. | May save theoretical work but can underutilize hardware if sparsity patterns are irregular. |
| Memory | Weight footprint follows dense parameter count. | May still require storage for all candidate weights; structured sparsity can reduce storage if the format/runtime supports it. |
| Throughput | Easier to batch uniformly. | Can vary with routing, sparsity pattern, or communication. |
| Complexity | Simpler execution and capacity planning. | Needs routing, sparse kernels, load balancing, or sparse storage formats. |
| Quality trade-off | More uniform compute path. | Conditional capacity may help, but performance depends on training and routing. |

### When sparse designs make sense

Sparse computation is attractive when the hardware and runtime can exploit the chosen sparsity and when its systems overhead is justified. MoE can be useful for scaling model capacity under a constrained active-compute budget. Sparse attention can help long-context processing when the task does not require full all-to-all token interaction. Weight pruning can reduce deployment cost when supported by efficient structured kernels.

Do not assume any sparse design is faster merely because it performs fewer nominal operations. Benchmark representative batch sizes, sequence lengths, concurrency, memory use, quality, and tail latency on the actual hardware.

### Concise interview answer

“Dense means the layer’s full parameterized operation is applied to each token; sparse means only a subset of parameters or interactions is used. In MoE, a router activates selected expert FFNs per token; in sparse attention, only selected token pairs interact; in pruning, some weights are removed or skipped. These are distinct forms of sparsity. Sparse models can reduce active FLOPs, but total parameters and memory may remain large, and irregular execution, routing, or communication can erase latency gains. I compare dense and sparse alternatives using end-to-end quality, memory, throughput, hardware utilization, and p95/p99 latency—not FLOPs alone.”

### Revision summary

| Measure | Dense model | Sparse model |
|---|---|---|
| Active computation | Most/all designated layer weights per token. | Input- or structure-dependent subset. |
| Total parameters | Usually close to active layer parameters. | Can greatly exceed active parameters. |
| Memory | Predictable dense weight storage. | May still store all experts/weights. |
| Speed | Efficient dense kernels. | Depends on sparsity structure and runtime support. |
| Critical caveat | More compute may be regular and efficient. | Fewer FLOPs do not guarantee lower latency or cost. |

<br><br><br>

## How does DeepSeek-V4 work?

**Answer:**

### Start with a careful scope statement

The name **DeepSeek-V4** refers to a specific model family, so its exact architecture and specifications should be answered from the current official technical report, model card, and inference code. The repository’s cited [DeepSeek-V4 explainer](https://outcomeschool.com/blog/decoding-deepseek-v4) describes it as a long-context Mixture-of-Experts (MoE) family with hybrid compressed attention. However, I could not verify those version-specific details against a primary DeepSeek-V4 report or model repository during this update. Treat the details below as **claims from that third-party explainer**, not independently confirmed official specifications; verify them against primary sources before quoting exact figures in an interview.

### Reported high-level design

According to the explainer, the design targets efficient processing of very long contexts by combining:

1. **MoE feed-forward layers:** A router activates only selected experts per token, increasing total model capacity without running every expert for each token.
2. **Hybrid long-context attention:** The explainer describes two attention mechanisms interleaved across layers:
   - **Compressed Sparse Attention (CSA):** groups/compresses token KV representations and uses a learned indexer to select a smaller set of compressed entries for attention.
   - **Heavily Compressed Attention (HCA):** compresses groups more aggressively and applies dense attention over the resulting shorter sequence.
3. **Recent-token window:** The explainer says the design also retains a small window of recent uncompressed KV entries to preserve local detail that compression might blur.
4. **Attention sinks and normalization:** It describes learnable sink logits and RMSNorm on query/compressed-KV representations as part of the attention design.
5. **Residual-path changes:** It reports Manifold-Constrained Hyper-Connections (mHC), intended to expand and mix residual streams while constraining the mixing transformation for stability.
6. **Training and post-training changes:** It reports use of the Muon optimizer for most parameters, FP4 quantization-aware training in selected components, domain-specialist training, and on-policy distillation into a unified model.

This is a high-level account of a reported design, not enough to reproduce the model. Exact tensor shapes, routing policies, compression operators, training schedules, evaluation protocols, and serving implementation must come from primary technical documentation.

### How the reported attention could reduce long-context cost

With standard full attention over \(N\) tokens, each query can score against \(N\) keys, producing roughly \(N^2\) query-key interactions. A KV cache also grows with the number of retained tokens. The explainer’s reported approach reduces the set of representations used for long-range attention:

- **CSA** first compresses groups of token states, then uses a learned indexer to select a sparse subset of compressed entries.
- **HCA** uses more aggressive compression and attends densely over the much shorter compressed sequence.
- A **recent-token branch** preserves fine-grained local context.

Conceptually, this trades exhaustive token-level access for compressed summaries plus selective access. The expected benefit is lower long-context compute and cache footprint; the risk is losing details or retrieving the wrong compressed entries. The exact quality/cost behavior must be validated on long-range retrieval, reasoning, and distractor-heavy tests.

### What to emphasize in a senior interview

- **Problem framing:** Long prompts and agent histories raise prefill compute, KV-cache memory, latency, and cost.
- **Architectural approach:** Reported hybrid compression combines broad compressed coverage with sparse fine-grained selection and a local recent-token path.
- **MoE trade-off:** Active expert compute can be lower than total parameter count suggests, but model weights, routing, load balancing, and inter-device communication still affect serving cost.
- **Systems implication:** Architecture-level savings need matching kernels, indexing, cache management, and efficient distributed execution to show up in measured latency and throughput.
- **Evaluation requirement:** Compare against a baseline at the same context length and workload, measuring quality, recall of relevant evidence, latency, throughput, and KV-cache bytes.
- **Evidence discipline:** Clearly separate official model-card/report facts from third-party explanations and avoid repeating benchmark or cost claims without their exact methodology.

### Version-specific figures: use only with attribution

The cited explainer gives particular parameter counts, context length, pretraining-token counts, and relative compute/cache comparisons for named variants. Because I could not confirm these figures in a primary DeepSeek-V4 publication here, I would not present them as settled specifications. In an interview, either cite the official report/model card and its measurement setup, or say that the figures are reported by a secondary source and need verification.

### Concise interview answer

“DeepSeek-V4 is a version-specific question, so I would anchor exact details in its current official technical report and model card. The third-party explainer linked from this repository describes a long-context MoE design that combines Compressed Sparse Attention—compressed KV entries plus learned sparse selection—with more aggressively compressed dense attention, interleaved with a recent-token window. It also reports residual-path, optimizer, low-precision-training, and on-policy-distillation changes. The system-level objective is to reduce long-context compute and KV-cache use while preserving quality. I would treat exact parameter counts, context limits, and speedup figures as unverified until checked against primary sources, then evaluate the model on long-context retrieval, quality, latency, throughput, and memory under comparable workloads.”

### Revision summary

| Reported element | Intended role | Evidence caveat |
|---|---|---|
| MoE | Conditional expert computation. | Verify model config and routing details in official sources. |
| CSA | Compress KV states, then sparse-select entries. | Detailed mechanism described by a secondary explainer. |
| HCA | Aggressively compress and attend densely over shorter sequence. | Verify exact compression and layer schedule. |
| Recent-token branch/sink logits | Preserve local detail and allow attention to allocate less mass to context. | Treat exact configuration as reported, not independently confirmed. |
| mHC, Muon, FP4 QAT, OPD | Reported residual, optimizer, precision, and post-training choices. | Confirm against primary technical report before quoting. |
| Interview principle | Explain goal, mechanism, trade-offs, and evaluation. | Do not state unsupported version-specific metrics as fact. |

<br><br><br>

## What is Flash Attention?

**Answer:**

### Core idea

**FlashAttention** is an exact (up to normal floating-point implementation differences) and **IO-aware attention algorithm**. It computes the standard attention result while reducing data movement between high-bandwidth memory (such as GPU HBM) and fast on-chip SRAM. Instead of materializing the full \(N\times N\) attention-score matrix in high-bandwidth memory, it processes query, key, and value tiles and uses an online softmax computation to accumulate the result.

The key insight is that attention performance is often limited not only by arithmetic but also by moving intermediate data. FlashAttention reorganizes the calculation to use GPU memory hierarchy more efficiently.

### Standard attention’s memory problem

For queries \(Q\), keys \(K\), and values \(V\), standard scaled dot-product attention is:

\[
\operatorname{softmax}\left(\frac{QK^\top}{\sqrt{d_k}}+M\right)V
\]

An implementation that materializes the score matrix stores \(N\times N\) scores per head, applies masking and softmax, then multiplies by \(V\). For long sequences, this intermediate can be very large and requires substantial reads and writes to high-bandwidth memory. The underlying full-attention arithmetic still involves all query-key pairs, but avoidable intermediate-memory traffic can dominate runtime.

### Tiling and online softmax intuition

FlashAttention divides \(Q\), \(K\), and \(V\) into blocks that fit in fast on-chip memory. For each query block, it iterates over key/value blocks, computes partial score tiles, and updates a numerically stable running softmax normalization and weighted-value accumulator. It does not need to store the complete \(N\times N\) matrix in HBM.

The online softmax tracks, for each query row, a running maximum \(m\), normalization sum \(\ell\), and weighted value accumulator \(o\). When a new score block is processed, these quantities are rescaled consistently so the final result matches the full softmax-weighted sum. This allows a mathematically equivalent result without retaining every score at once.

### What it improves—and what it does not

| Aspect | FlashAttention effect |
|---|---|
| Attention result | Computes standard dense attention, subject to floating-point ordering differences. |
| Memory traffic | Reduces HBM reads/writes by using tiling and on-chip memory efficiently. |
| Intermediate storage | Avoids materializing the full attention matrix in HBM. |
| Arithmetic complexity | Full attention still has roughly \(O(N^2d)\) computation in sequence length/hidden dimension. |
| Context length | Can make longer sequences more practical, but does not itself make attention sparse or linear-time. |
| Training/inference | Can accelerate supported attention workloads; benefits depend on hardware, shapes, dtype, and implementation. |

FlashAttention versions and related kernels evolve to improve parallelism, hardware utilization, and support for different GPUs and attention patterns. “FlashAttention” should not be confused with a new learned attention mechanism or a different model objective.

### Engineering considerations

- Kernel speedups depend on sequence length, head dimension, dtype, batch size, GPU generation, and whether the workload is training, prefill, or decoding.
- Model/runtime compatibility matters; the optimized kernel must support the model’s mask, layout, and precision.
- Numerically equivalent algorithms can differ slightly due to floating-point accumulation order; validate outputs and gradients within appropriate tolerances.
- Benchmarks should include end-to-end workload metrics, not just kernel microbenchmarks.
- For long contexts, combine efficient attention kernels with KV-cache planning, batching, and realistic quality evaluation.

### Concise interview answer

“FlashAttention is an IO-aware exact attention algorithm that improves GPU memory efficiency. Standard implementations may materialize an \(N\times N\) attention matrix in HBM. FlashAttention tiles Q/K/V into blocks that fit in on-chip SRAM and uses online softmax to accumulate the final weighted values without writing the full matrix to HBM. This substantially reduces memory traffic and can improve speed and usable sequence length. It does not change the mathematical dense-attention operation into sparse or linear attention: full pairwise compute remains roughly quadratic in sequence length. Actual gains depend on hardware, shapes, dtype, and kernel support.”

### Revision summary

| Point | Remember |
|---|---|
| FlashAttention | IO-aware, tiled implementation of standard attention. |
| Main technique | On-chip tiling plus numerically stable online softmax. |
| Main benefit | Less HBM traffic and no full score-matrix materialization in HBM. |
| Complexity caveat | Dense attention still has quadratic pairwise sequence work. |
| Not the same as | Sparse attention, a new attention objective, or a model architecture. |
| Production practice | Benchmark supported shapes and end-to-end latency/throughput. |

<br><br><br>

## What is Cross-Entropy Loss?

**Answer:**

### Core idea

**Cross-entropy loss** measures how well a predicted probability distribution \(p\) matches a target distribution \(q\). In classification and language modeling, it penalizes the model when it assigns low probability to the correct target. Training uses the loss to compute gradients that update model parameters.

For target distribution \(q\) and prediction \(p\):

\[
H(q,p)=-\sum_{i=1}^{C}q_i\log p_i
\]

If the target is one-hot for class \(y\), this reduces to:

\[
L=-\log p_y
\]

Thus, confidently assigning a low probability to the correct class incurs a large loss.

### Cross-entropy in next-token training

For an LLM vocabulary of size \(V\), the model produces logits \(z_t\) at each position. Softmax gives the predicted token distribution \(p_t\). Given the correct next-token target \(y_t\), the per-position loss is:

\[
L_t=-\log p_t(y_t)
\]

For a sequence, training typically aggregates this loss across valid target positions (often averaging while excluding padding or ignored tokens). Inputs and targets are shifted so the representation at position \(t\) predicts token \(t+1\). The exact reduction, masking, and weighting are training-configuration details.

The gradient of softmax cross-entropy with respect to a logit has the familiar form \(p_i-q_i\) for the corresponding target distribution. This pushes probability toward the target and away from alternatives, with the size of the update depending on the model output and optimization setup.

### Example

Suppose the correct next token is `Paris`.

- Model A assigns \(p(\text{Paris})=0.8\), giving loss \(-\log(0.8)\approx0.223\).
- Model B assigns \(p(\text{Paris})=0.1\), giving loss \(-\log(0.1)\approx2.303\).

Model B receives a much larger penalty because it gave the correct token much less probability. The loss evaluates the target probability, not whether a single sampled completion happens to look fluent.

### Why use cross-entropy?

- It is differentiable and pairs naturally with softmax classification.
- It gives a principled penalty based on the probability assigned to the observed target.
- It can train models over large vocabularies and many sequence positions.
- Its average is related to the model’s negative log-likelihood and perplexity; lower cross-entropy generally corresponds to lower perplexity on the same tokenized evaluation data.

### Limitations and practical caveats

- **Objective versus product quality:** Lower next-token loss does not guarantee better instruction following, groundedness, reasoning, safety, or user value.
- **Data dependence:** Loss depends on tokenizer, data distribution, filtering, and target construction. Comparisons require compatible evaluation data and tokenization.
- **Class imbalance and weighting:** Frequent tokens dominate aggregate training statistics; data mixtures, weighting, or other objectives may be used, with trade-offs.
- **Label smoothing:** Replacing one-hot targets with softened distributions can regularize training, but changes the target objective.
- **Ignored tokens and masks:** Padding, prompt tokens, and special positions may be included or excluded according to the loss mask; a masking bug can train on the wrong positions.
- **Numerical stability:** Implementations generally use a stable log-softmax/cross-entropy kernel rather than explicitly exponentiating large raw logits.
- **Exposure mismatch:** Teacher-forced training conditions on ground-truth prefixes, whereas generation conditions on model outputs; sequence-level errors can still accumulate.

### Cross-entropy versus related terms

| Term | Relationship |
|---|---|
| Negative log-likelihood | For a one-hot observed target, per-example cross-entropy is the negative log probability assigned to that target. |
| Entropy \(H(q)\) | Uncertainty in the target distribution itself; it does not compare the model prediction to the target. |
| KL divergence \(D_{KL}(q\|p)\) | \(H(q,p)=H(q)+D_{KL}(q\|p)\); for fixed target \(q\), minimizing cross-entropy also minimizes this KL term. |
| Perplexity | \(\exp(\text{average token cross-entropy})\), under the stated tokenization and evaluation setup. |

### Concise interview answer

“Cross-entropy measures the negative log probability the model assigns to the target. With a one-hot class target \(y\), it is \(-\log p_y\); in an LLM, each position’s vocabulary distribution is scored against the next token, and losses are aggregated over valid positions. It is differentiable and trains the model by pushing probability toward observed targets. Lower token-level cross-entropy is useful for language-model evaluation, but it does not guarantee better downstream behavior, grounding, or safety. I also verify target shifting, loss masks, tokenizer consistency, and evaluation-data comparability.”

### Revision summary

| Concept | Remember |
|---|---|
| Formula | \(H(q,p)=-\sum_i q_i\log p_i\). |
| One-hot target | Loss is \(-\log p(\text{correct target})\). |
| LLM use | Score next-token probability at each valid sequence position. |
| Perplexity | Exponential of average token cross-entropy. |
| Training caveat | Teacher forcing and sequence loss do not guarantee generated-task quality. |
| Debug checks | Target shift, padding/loss masks, tokenizer, and reduction. |

<br><br><br>

## What is Grouped-Query Attention (GQA), and how does it differ from Multi-Head Attention (MHA)?

**Answer:**

### Core idea

**Grouped-Query Attention (GQA)** is an attention design with multiple query heads but fewer key/value (KV) heads. Groups of query heads share the same K/V heads. It is a middle ground between standard multi-head attention (MHA), where each query head typically has its own K/V head, and multi-query attention (MQA), where all query heads share one K/V head.

The main serving motivation is to reduce KV-cache memory and memory bandwidth during autoregressive inference while retaining multiple query heads.

### How it works

In standard MHA, the model projects hidden states into \(H_Q\) query heads and typically \(H_{KV}=H_Q\) key/value heads. Each query head attends using its corresponding K/V representation.

In GQA, \(H_{KV}<H_Q\). Query heads are partitioned into groups, and each group uses a shared K/V head. If there are 32 query heads and 8 KV heads, for example, each KV head serves 4 query heads. The exact mapping and implementation are model-specific.

Each query head still computes attention scores against the K/V sequence it is assigned to; the K/V projections and cache entries are shared across that group. The result is not the same as merging the query heads into one head.

### Comparison

| Design | Query heads | KV heads | Cache implication |
|---|---:|---:|---|
| MHA | Multiple | Usually equal to query heads | Largest KV cache among these common designs. |
| GQA | Multiple | Fewer than query heads | Intermediate cache size; each KV head serves a query-head group. |
| MQA | Multiple | One shared KV head | Smallest KV cache, but the strongest sharing constraint. |

For the same layer count, batch, sequence length, head dimension, and cache dtype, raw KV-cache size is proportional to the number of KV heads:

\[
M_{\text{KV}}=2LBT H_{KV}d_hb
\]

Thus, reducing \(H_{KV}\) from 32 to 8 reduces the raw K/V cache for those dimensions by a factor of four. Actual total memory and speedups also depend on runtime layouts, model configuration, and hardware kernels.

### Trade-offs

- **Memory and bandwidth:** Fewer K/V heads reduce cache storage and can reduce the amount of K/V data read during decoding.
- **Model quality:** Sharing K/V representations constrains the design relative to independent MHA heads. GQA is a quality/efficiency compromise, not a guarantee of identical behavior.
- **Compute:** Query-side work remains multiple-headed; GQA’s main gains are often in KV storage and bandwidth rather than eliminating all attention computation.
- **Compatibility:** GQA is part of the model architecture and checkpoint. Converting an existing MHA model to GQA is not simply changing an inference flag; weights and quality may require adaptation.
- **Serving support:** Realized gains depend on kernels and runtimes that handle grouped heads efficiently.

### Concise interview answer

“GQA keeps multiple query heads but uses fewer key/value heads, with each KV head shared by a group of query heads. Standard MHA typically has one KV head per query head; MQA shares a single KV head across all queries. GQA sits between them, reducing KV-cache size roughly in proportion to the reduced KV-head count and often lowering decode memory bandwidth, while preserving more query diversity than MQA. The trade-off is shared K/V representations and architecture-specific checkpoint/runtime support. I compare quality, cache memory, throughput, and latency on the target serving workload.”

### Revision summary

| Point | Remember |
|---|---|
| GQA structure | Many Q heads, fewer shared KV heads. |
| Compared with MHA | Reduces KV-head count and cache size. |
| Compared with MQA | Less aggressive sharing; more KV heads. |
| Memory relationship | KV cache is linear in \(H_{KV}\). |
| Main trade-off | Inference efficiency versus K/V representation flexibility. |

<br><br><br>

## How does Sliding Window Attention work?

**Answer:**

### Core idea

**Sliding Window Attention** restricts each token’s attention to a local window of nearby positions instead of all tokens in the sequence. In a causal decoder, a token at position \(t\) may attend to itself and up to \(W-1\) preceding positions, where \(W\) is the window size. As generation advances, that window slides forward.

This reduces long-sequence attention work and, in windowed implementations, can bound the amount of local KV history needed by a layer. It changes what context is directly accessible, so it is an architectural trade-off rather than a lossless replacement for full attention.

### Masking pattern

For causal sliding-window attention, the mask allows a key position \(j\) for query position \(i\) only when:

\[
\max(1,i-W+1)\le j\le i
\]

Positions outside this local range are masked before softmax. For sequence length \(T\), full causal attention has a triangular number of allowed token pairs, while a fixed window limits each query to at most \(W\) keys, making the interaction count roughly \(O(TW)\) rather than \(O(T^2)\) when \(W\ll T\).

### How the window slides

When processing tokens incrementally:

1. The model computes the new token’s query, key, and value.
2. The query attends to keys/values retained for the recent window.
3. The new key/value is appended.
4. Entries older than the window may be dropped for that local-attention layer.

Some models combine local attention with global or compressed-attention layers, retain selected older tokens, or use different windows across layers. “Sliding-window model” therefore does not necessarily mean every layer forgets everything older than the same fixed number of tokens.

### Example

With \(W=4\), position 6 in a causal sequence may attend to positions 3, 4, 5, and 6. Position 7 may attend to 4, 5, 6, and 7. A nearby dependency can be modeled directly, while position 7 cannot directly attend to position 1 in that layer. Information from position 1 might still influence later states indirectly through intermediate representations or through a separate global pathway, depending on architecture.

### Benefits and limitations

| Benefit | Limitation |
|---|---|
| Reduces attention interactions for long sequences when \(W\ll T\). | Long-range dependencies may be inaccessible directly in a local layer. |
| Can bound local KV-cache length per layer. | Other global layers or retained-token mechanisms may still consume memory. |
| Often preserves nearby linguistic/code context well. | A fixed window may not match the distance of relevant evidence. |
| Enables predictable local attention patterns. | Quality depends on window size, layer design, training, and task. |

### Where it is useful

Sliding windows can be useful for long documents, streaming, or local-pattern tasks where recent context is especially valuable. Multi-layer stacks can propagate information farther than one window, but this is not equivalent to direct global attention in a single layer. Systems requiring precise retrieval of distant facts may need global attention, retrieval, recurrent memory, compressed context, or a hybrid architecture.

For production, evaluate both local and long-range tasks: retrieval of early facts, cross-document references, code dependencies, and performance under distractors. Measure compute, cache memory, latency, and quality for realistic sequence lengths.

### Concise interview answer

“Sliding-window attention masks each token so it can attend only to a bounded neighborhood, usually the current and recent preceding tokens in a causal decoder. With window \(W\), each query interacts with at most \(W\) keys, reducing full-attention sequence scaling from roughly \(O(T^2)\) to \(O(TW)\) for that layer. During streaming decode, old local KV entries can be evicted as the window advances. It improves long-sequence efficiency but limits direct access to distant context, so many designs combine it with global or compressed pathways. I would validate long-range task quality and actual cache/latency savings rather than assuming a larger window alone solves context use.”

### Revision summary

| Concept | Remember |
|---|---|
| Window | Each query sees only a bounded local range. |
| Causal condition | Recent keys up through the current token; no future tokens. |
| Complexity | Roughly \(O(TW)\) interactions when \(W\ll T\). |
| Benefit | Lower local attention work and potentially bounded cache. |
| Trade-off | Distant evidence is not directly visible in that layer. |
| Common design | Combine local windows with global/compressed pathways. |

<br><br><br>

## How do Attention Sinks work?

**Answer:**

### Core idea

**Attention sinks** are early tokens that attract substantial attention even when they are not semantically relevant to the current query. In decoder-only Transformers, the initial token or a small number of prefix tokens can receive high attention because of how causal attention and softmax normalization behave during training. These tokens can act as stable destinations for attention mass.

The term also appears in **StreamingLLM-style** inference, where retaining a small set of initial “sink” tokens plus a recent sliding window can support stable streaming generation without retaining the entire history. These are related observations and techniques, but “attention sink” can refer to the learned attention behavior or to explicit cache-retention strategies.

### Why sink behavior appears

For each query, attention softmax distributes probability across available keys so the weights sum to one. If the query has no strongly relevant key, it must still allocate its attention somewhere. Certain prefix positions can become consistent recipients. The exact explanation depends on model training and architecture; the important practical point is that these prefix states may help stabilize attention behavior.

### Sink tokens and streaming cache

In a standard KV cache, memory grows with the full prompt and generated history. A streaming strategy can preserve:

- a small set of initial sink-token K/V states, and
- a sliding window of the most recent tokens.

Older non-sink entries can then be removed, keeping cache size bounded while retaining stable prefix anchors and recent local context. This can work well for some streaming workloads, but it does not preserve all long-range information from evicted tokens.

### Benefits and limitations

| Benefit | Limitation |
|---|---|
| Can stabilize streaming behavior when using a bounded cache. | Does not retain all old content or guarantee recall of evicted details. |
| Keeps a small set of prefix states that may serve as attention destinations. | Sink positions need not contain semantically useful information. |
| Can combine with a recent-token window. | Results depend on model, prompt format, cache policy, and workload. |

### Distinguish sinks from ordinary attention

In standard attention, softmax weights over allowed keys sum to one. Some specialized architectures may add learned sink logits or other mechanisms that permit attention mass to flow to an implicit sink, but this is a particular design—not a universal property of every Transformer. Do not equate that mechanism with simply keeping initial tokens in a streaming cache.

### Production evaluation

Test long-running sessions for stability, latency, cache growth, and quality. Include queries that require remembering facts from before the sliding window, as well as requests that do not need old context. If exact long-term memory is required, store and retrieve that information explicitly rather than relying on sink tokens to preserve it.

### Concise interview answer

“An attention sink is a prefix token or small set of positions that attracts attention mass even when it is not semantically relevant. In streaming inference, a related technique retains those initial K/V states plus a recent sliding window and evicts older cache entries, bounding memory while preserving stable attention anchors and local context. This can improve streaming stability, but it is not a memory system: evicted information may no longer be accessible. I distinguish learned sink behavior from explicit sink-token cache policies and evaluate recall, stability, and cache use on the target workload.”

### Revision summary

| Term | Remember |
|---|---|
| Attention sink | Prefix position that can attract attention despite low semantic relevance. |
| Streaming use | Keep sink K/V plus recent window; evict older states. |
| Benefit | Bounded cache and potentially more stable streaming. |
| Limitation | Does not preserve all distant facts or replace external memory. |
| Caveat | Implicit sink-logit mechanisms are architecture-specific. |

<br><br><br>

## How does Rotary Position Embedding (RoPE) work, and why is it preferred over learned positional embeddings?

**Answer:**

### Core idea

**Rotary Position Embedding (RoPE)** injects position information into attention by rotating pairs of query and key dimensions according to each token’s position. Rather than adding a position vector to the token embedding, RoPE transforms the query and key vectors used to compute attention scores.

The resulting query-key dot product depends on the relative offset between positions, giving attention a representation of order and distance. RoPE is widely used in decoder-only LLMs, but it is not universally superior to learned absolute embeddings; the choice depends on architecture, training, context range, and implementation.

### How the rotation works

For each two-dimensional pair of components, a position-dependent rotation is applied. In a 2D plane, rotation by angle \(\theta\) is:

\[
R(\theta)=
\begin{bmatrix}
\cos\theta & -\sin\theta\\
\sin\theta & \cos\theta
\end{bmatrix}
\]

Different dimension pairs use different frequencies. For a vector at position \(m\), RoPE applies a rotation \(R_m\) to its query and key:

\[
\tilde q_m=R_m q_m,\qquad \tilde k_n=R_n k_n
\]

Then their attention score is:

\[
\tilde q_m^\top\tilde k_n
=q_m^\top R_m^\top R_n k_n
=q_m^\top R_{n-m}k_n
\]

Because \(R_m^\top R_n\) depends on the relative position difference \(n-m\), the attention score carries relative-position information.

### Why many models use it

- **Relative-position effect:** The query-key interaction naturally depends on position offsets.
- **No learned absolute-position lookup table in the basic form:** Position is applied through rotations rather than adding one learned vector per absolute position.
- **Efficient integration:** RoPE can be applied to Q/K within attention and is compatible with common decoder inference patterns.
- **Empirical effectiveness:** It has worked well in many LLM architectures.

These are reasons it is popular, not proof it is always preferable. Some models use learned absolute embeddings, relative biases, ALiBi-like methods, or other positional schemes.

### Context-length caveats

RoPE does not guarantee reliable extrapolation to arbitrary sequence lengths. Frequencies were trained over a particular position range; using much longer positions can change attention behavior and degrade quality. Long-context extensions may rescale or modify frequencies, use interpolation, or apply other training/adaptation techniques. These changes must be compatible with the checkpoint and evaluated on long-context tasks.

RoPE configuration is part of model compatibility. Incorrect position IDs, scaling parameters, rotary dimensions, or layout can silently reduce quality. During cached decoding, positions must continue correctly as the sequence grows.

### Comparison with learned absolute embeddings

| Property | RoPE | Learned absolute position embeddings |
|---|---|---|
| Position injection | Rotates query/key dimensions in attention. | Adds a learned position vector to token representations. |
| Position relation | Dot products encode relative offsets. | Directly associates vectors with absolute positions; relative relations must be learned. |
| Position parameters | Basic RoPE uses fixed frequency structure rather than a learned vector table for each position. | Learns a position table over configured positions. |
| Extrapolation | Requires care; not automatically reliable beyond training range. | Learned table is typically limited to its trained/configured range unless adapted. |
| Trade-off | Efficient and widely adopted in decoder LLMs. | Simple and flexible within supported positions. |

### Concise interview answer

“RoPE applies position-dependent rotations to pairs of query and key dimensions. When rotated Q and K are dotted, the score depends on the relative position offset, so order information enters attention directly rather than being added as a learned absolute position vector. It is popular because it integrates efficiently with attention and works well in many decoder LLMs. But it is not universally better, and standard RoPE does not guarantee arbitrary-length extrapolation. Context extension requires compatible frequency scaling or adaptation and evaluation; position IDs and RoPE configuration must match the checkpoint.”

### Revision summary

| Concept | Remember |
|---|---|
| Mechanism | Rotate paired Q/K dimensions according to position. |
| Relative effect | \(R_m^\top R_n=R_{n-m}\), so scores encode relative offsets. |
| Why popular | Efficient attention integration and empirical success in many LLMs. |
| Compared with learned absolute | Rotates Q/K rather than adding a learned vector per position. |
| Key caveat | Does not guarantee long-context extrapolation. |
| Engineering check | Match RoPE parameters, layout, and position IDs to the checkpoint. |

<br><br><br>

## Explain Layer Normalization

**Answer:**

### Core idea

**Layer Normalization (LayerNorm)** normalizes the activations of a feature vector using statistics computed across its feature dimensions, then applies learned scale and shift parameters. In a Transformer, it helps control activation scales and supports stable optimization across deep layers.

For a hidden vector \(x\in\mathbb{R}^{d}\), LayerNorm typically computes:

\[
\mu=\frac{1}{d}\sum_{i=1}^{d}x_i,\qquad
\sigma^2=\frac{1}{d}\sum_{i=1}^{d}(x_i-\mu)^2
\]

\[
\operatorname{LN}(x)_i
=\gamma_i\frac{x_i-\mu}{\sqrt{\sigma^2+\epsilon}}+\beta_i
\]

Here \(\gamma\) and \(\beta\) are learned per-feature scale and bias, and \(\epsilon\) prevents division by zero.

### What is normalized?

For Transformer activations shaped \([B,T,d_{\text{model}}]\), LayerNorm is typically applied over the feature dimension \(d_{\text{model}}\) independently for each batch item and token position. It does not compute statistics across the batch or across sequence positions in the standard LayerNorm configuration. This differs from BatchNorm, whose statistics are based on a batch dimension and can behave differently between training and inference.

### Why Transformers use it

- **Activation-scale control:** Keeps hidden-state distributions in a manageable range.
- **Optimization support:** Can improve training stability and convergence in deep networks.
- **Per-token operation:** Standard LayerNorm does not require batch-wide statistics, making it suitable for variable batch sizes and autoregressive inference.
- **Learned flexibility:** \(\gamma\) and \(\beta\) allow the model to rescale and shift normalized features.

LayerNorm does not make the network’s outputs independent or guarantee stable training. It is one part of a design that also includes residual connections, initialization, optimizer settings, precision, and architecture-specific normalization placement.

### LayerNorm placement

LayerNorm may be applied before or after a Transformer sublayer:

- **Pre-LayerNorm:** Normalize the sublayer input, then apply attention/FFN and add the residual.
- **Post-LayerNorm:** Apply the sublayer and residual addition, then normalize the result.

The placement changes optimization and gradient-flow properties and is covered separately in the pre-norm question. When loading or reproducing a model, normalization type and placement must match the checkpoint.

### Comparison with related normalization

| Method | Statistics | Typical use/consideration |
|---|---|---|
| LayerNorm | Mean and variance across features for each example/token. | Common Transformer normalization; has learned scale and bias in standard form. |
| RMSNorm | Root-mean-square across features, typically without mean subtraction. | Simpler normalization used by many modern LLMs. |
| BatchNorm | Batch statistics for each feature/channel. | Common in convolutional/vision networks; batch-dependent behavior differs from LayerNorm. |

### Practical considerations

- \(\epsilon\), accumulation precision, placement, and affine parameters affect numerical behavior.
- Fused kernels can improve serving/training efficiency but must preserve the intended computation.
- Mixed precision can create numerical issues if statistics are accumulated at insufficient precision.
- RMSNorm and LayerNorm are not interchangeable without matching the model’s training and weights.
- Normalization should be evaluated as part of the complete architecture, not changed as a standalone tweak.

### Concise interview answer

“LayerNorm normalizes each hidden vector across its feature dimensions: it subtracts the feature mean, divides by the standard deviation with an epsilon, then applies learned scale and bias. In a Transformer tensor \([B,T,d]\), it is typically applied independently to each token’s \(d\)-dimensional vector, not across the batch. It helps control activation scale and supports optimization of deep networks without batch-dependent statistics. LayerNorm is distinct from RMSNorm, and its pre- or post-sublayer placement is an architectural choice that must match the checkpoint.”

### Revision summary

| Element | Recall |
|---|---|
| Normalize over | Feature dimensions of each token/example. |
| Formula | Center by mean; scale by standard deviation plus \(\epsilon\). |
| Learnable parameters | Per-feature \(\gamma\) and \(\beta\). |
| Transformer role | Activation-scale control and optimization support. |
| Distinction | Not BatchNorm; RMSNorm omits mean-centering in its common form. |
| Compatibility | Match epsilon, precision, affine parameters, and placement to the model. |

<br><br><br>

## Explain RMSNorm (Root Mean Square Layer Normalization)

**Answer:**

### Core idea

**RMSNorm (Root Mean Square Layer Normalization)** normalizes a hidden vector by its root-mean-square magnitude, typically without subtracting the vector’s mean. It is a normalization layer used in many modern Transformer architectures. Like LayerNorm, it helps control activation scale; unlike standard LayerNorm, it does not center activations around zero.

For \(x\in\mathbb{R}^{d}\), a common RMSNorm form is:

\[
\operatorname{RMSNorm}(x)_i
=\gamma_i\frac{x_i}{\sqrt{\frac{1}{d}\sum_{j=1}^{d}x_j^2+\epsilon}}
\]

Here \(\gamma_i\) is a learned per-feature scale and \(\epsilon\) is a small stabilizing constant. Some variants differ in bias, scaling, or epsilon placement; match the checkpoint’s implementation.

### How it differs from LayerNorm

LayerNorm subtracts the mean, then scales by standard deviation:

\[
\operatorname{LN}(x)_i
=\gamma_i\frac{x_i-\mu}{\sqrt{\sigma^2+\epsilon}}+\beta_i
\]

RMSNorm instead scales by the root mean square and typically keeps the mean component:

| Property | LayerNorm | RMSNorm |
|---|---|---|
| Center by mean? | Yes, in the standard form. | No, typically. |
| Scale statistic | Standard deviation after centering. | Root mean square of activations. |
| Learned parameters | Commonly scale \(\gamma\) and bias \(\beta\). | Commonly scale \(\gamma\), often no bias. |
| Compute | Mean, variance, normalization, affine transform. | Mean square, root, scale, affine transform. |
| Effect | Controls shift and scale. | Primarily controls scale. |

### Why use RMSNorm?

- **Simpler computation:** It avoids mean-centering and variance calculation, which can reduce operations and support efficient kernels.
- **Scale control:** It normalizes the magnitude of the hidden vector, which can help stabilize deep network training.
- **Empirical suitability:** Many LLM architectures train effectively with it.
- **Implementation efficiency:** Fused RMSNorm kernels are common in accelerator-serving stacks.

The practical speedup is workload- and hardware-dependent; normalization is only one part of total inference cost. RMSNorm is not automatically more accurate or more stable than LayerNorm for every model.

### Placement in Transformers

RMSNorm is often used in pre-norm Transformer blocks, where the normalized input is passed to attention or the FFN before a residual addition. The normalization type and placement are architectural choices learned and validated with the checkpoint; swapping LayerNorm for RMSNorm at inference is not a safe drop-in change.

### Practical considerations

- Epsilon affects numerical behavior, especially for small magnitudes and mixed precision.
- Accumulating the mean-square statistic at insufficient precision can create numerical instability.
- Some implementations use scale-only parameters; others may include additional variants.
- Weight loading must match parameter shape, normalization order, and any scaling convention.
- Benchmark fused kernels on the target hardware instead of assuming theoretical operation savings translate directly to end-to-end speed.

### Concise interview answer

“RMSNorm scales a hidden vector by its root-mean-square magnitude, usually applying a learned per-feature gain but not subtracting the mean. LayerNorm instead centers by the mean and divides by standard deviation, commonly with both gain and bias. RMSNorm gives activation-scale control with a simpler statistic, which can be efficient and works well in many modern LLMs. The difference is not just a runtime toggle: normalization type, epsilon, parameters, and placement must match the trained checkpoint, and performance gains should be measured on the actual serving stack.”

### Revision summary

| Concept | Remember |
|---|---|
| RMS statistic | \(\sqrt{\operatorname{mean}(x^2)+\epsilon}\). |
| Centering | RMSNorm typically does not subtract the mean. |
| Parameters | Usually learned scale \(\gamma\); often no bias. |
| Motivation | Scale control with a simpler computation. |
| Caveat | Match exact variant, epsilon, precision, and placement to model weights. |

<br><br><br>

## Why do modern Transformers use Pre-LayerNorm (Pre-Norm) instead of Post-LayerNorm?

**Answer:**

### Core distinction

**Pre-LayerNorm (Pre-Norm)** normalizes a layer’s input before applying its transformation, then adds the transformed output through a residual connection. **Post-LayerNorm (Post-Norm)** applies the transformation and residual addition first, then normalizes the resulting hidden state.

For a sublayer \(F\), a simplified pre-norm form is:

\[
y=x+F(\operatorname{Norm}(x))
\]

A simplified post-norm form is:

\[
y=\operatorname{Norm}(x+F(x))
\]

Real Transformer blocks may use LayerNorm or RMSNorm, attention/FFN-specific details, residual scaling, or other variants; these equations illustrate the ordering.

### Why Pre-Norm is common in modern LLMs

Pre-Norm provides a direct identity residual path from input to output. In deep stacks, this often improves gradient flow and makes optimization less sensitive to depth and initialization than the classic Post-Norm layout. This can make training very deep Transformers more stable and reduce the need for aggressive warmup or specialized stabilization techniques in some settings.

The residual stream can carry information forward unchanged while each sublayer learns a normalized update. This is a useful optimization property, not a guarantee of stable training or superior quality for every architecture.

### Trade-offs and caveats

| Aspect | Pre-Norm | Post-Norm |
|---|---|---|
| Norm placement | Before attention/FFN transformation. | After residual addition. |
| Residual path | Contains a direct identity route around the sublayer. | Output is normalized after the addition. |
| Deep optimization | Often easier to optimize in very deep stacks. | Can have more challenging gradient behavior without suitable initialization/stabilization. |
| Hidden-state scale | Residual stream can accumulate scale across layers; final normalization is often used. | Each block output is normalized. |
| Compatibility | Common in many modern decoder LLMs. | Used in the original Transformer and other architectures. |

The comparison depends on architecture and training recipe. Post-Norm can work well with appropriate design; Pre-Norm is a common practical choice, not a universal theorem that it is always better.

### Final normalization

Pre-Norm models commonly include a final normalization before the language-model output head. This helps control the representation passed to the vocabulary projection after residual updates across many blocks. Whether and how it is used is checkpoint-specific.

### Production and implementation implications

- When loading pretrained weights, reproduce the exact norm type, placement, residual scaling, and final-normalization behavior.
- Do not convert a Post-Norm checkpoint to Pre-Norm merely by moving a layer; the weights were trained under a different computation.
- Compare training stability, convergence, activation statistics, and downstream quality when designing a new architecture.
- In inference, normalization placement affects correctness as well as efficiency; fused kernels must preserve semantics.

### Concise interview answer

“Pre-Norm applies normalization before attention or the FFN and then adds the sublayer result to the residual stream: \(x+F(\operatorname{Norm}(x))\). Post-Norm normalizes after the residual addition: \(\operatorname{Norm}(x+F(x))\). Pre-Norm preserves a more direct identity path for gradients through deep stacks and is often easier to optimize, which is why it is common in modern LLMs. But it is not universally superior; Post-Norm can work with an appropriate recipe. The exact norm type, placement, residual scaling, and final norm are part of the checkpoint architecture and must be reproduced.”

### Revision summary

| Point | Remember |
|---|---|
| Pre-Norm | Normalize before sublayer; then residual add. |
| Post-Norm | Residual add first; normalize afterward. |
| Common motivation | Direct residual path can improve deep-network optimization. |
| Caveat | Training recipe and architecture determine results; neither is universally best. |
| Compatibility | Do not move normalization around when serving an existing checkpoint. |

<br><br><br>

## What are scaling laws (Chinchilla), and how do they guide model size vs training data decisions?

**Answer:**

### Core idea

**Scaling laws** are empirical relationships describing how model performance—often measured by validation loss—changes as training compute, model size, data quantity, and sometimes data quality are scaled. They help teams reason about resource allocation and estimate promising training configurations, but they are fitted approximations over studied regimes, not guarantees about downstream product quality.

The **Chinchilla** result is associated with compute-optimal language-model training under a fixed training-compute budget. It highlighted that some large models had been trained on too few tokens relative to their parameter count; for the compute budget, a smaller model trained on substantially more data could achieve lower loss.

### The compute allocation problem

Training cost grows with both the number of model parameters \(N\) and the number of training tokens \(D\). A simplified dense Transformer estimate is:

\[
C\propto N D
\]

The exact constant and total cost depend on architecture, sequence lengths, attention, hardware utilization, optimizer, and training procedure. Under a fixed compute budget \(C\), choosing a very large \(N\) leaves fewer resources for training tokens \(D\), while choosing a smaller model permits more token updates. Scaling-law experiments estimate which balance minimizes a chosen loss within the measured regime.

Chinchilla’s widely discussed compute-optimal findings are often summarized as scaling model size and training tokens together, with roughly 20 training tokens per parameter as a useful approximate rule of thumb for the studied setup. This is not a universal requirement or a law for every architecture, dataset, inference budget, or training objective. Newer models and compute-optimal regimes can differ.

### What the law does—and does not—tell you

| It can help with | It cannot guarantee |
|---|---|
| Estimating validation-loss trends as compute/data/model size change. | A specific level of reasoning, instruction following, or application success. |
| Avoiding severely undertrained large models under a compute budget. | That all training tokens are equally useful or legally/ethically appropriate. |
| Comparing candidate pretraining allocations within a studied regime. | That the “20 tokens per parameter” heuristic applies universally. |
| Planning pretraining experiments and budget. | That a model should be trained rather than fine-tuned, distilled, or used via API. |

Loss scaling is only one part of product decisions. Inference cost, latency, context length, reliability, safety, data governance, and task-specific evaluations may dominate.

### Data quality and effective tokens

Token count alone is an incomplete measure. Duplicates, low-quality data, contamination, domain mismatch, licensing constraints, and multilingual balance affect how useful the training data is. A smaller amount of clean, relevant, diverse data can be more valuable for a particular task than a larger noisy corpus, though pretraining benefits and data scaling are empirical. Track data provenance and quality as well as token count.

### Training versus inference economics

Compute-optimal pretraining under a fixed training budget does not necessarily produce the best total lifecycle choice. A larger model may cost more per inference request; a smaller model trained on more data may be cheaper to serve; a distilled student may be better for high-volume workloads. Conversely, a model intended for a small number of high-value requests may justify different trade-offs.

### How to use scaling laws responsibly

1. Define the objective: validation loss, downstream task quality, or a business metric.
2. Fit or consult scaling results relevant to the architecture, data mixture, tokenizer, and training regime.
3. Allocate compute across parameters, tokens, and experiment runs; include data quality and training stability.
4. Evaluate downstream capability and safety separately from pretraining loss.
5. Estimate inference cost and deployment constraints, not just training compute.
6. Document uncertainty and re-evaluate when changing data, architecture, objective, or scale regime.

### Concise interview answer

“Scaling laws empirically relate model loss to model size, training data, and compute. Chinchilla’s compute-optimal result showed that, for a fixed training budget in its studied regime, some models were too large and undertrained; allocating more compute to training tokens with a smaller model could lower loss. The commonly cited roughly 20 tokens per parameter is a rule of thumb from that setup, not a universal law. I use scaling trends to narrow training experiments, while accounting for data quality, architecture, and uncertainty. I then evaluate downstream quality, safety, and inference economics separately, because lower pretraining loss does not guarantee a better production system.”

### Revision summary

| Concept | Remember |
|---|---|
| Scaling law | Empirical trend linking loss to scale variables such as parameters, tokens, and compute. |
| Chinchilla insight | Balance model size and data; large models can be undertrained. |
| Rule of thumb | About 20 tokens/parameter is commonly cited for its regime, not universal. |
| Main use | Guide compute allocation and experiment planning. |
| Caveat | Loss scaling is not downstream/product quality; data quality matters. |

<br><br><br>

## Your LLM keeps ignoring your instructions. How do you make it follow structured output formats?

**Answer:**

### Start with diagnosis, not prompt escalation

When an LLM ignores structured-output instructions, treat it as a reliability problem across the request path—not only a wording problem. First determine whether the failure is malformed syntax, schema violation, missing fields, wrong values, extra prose, truncation, or a tool/API integration error. Capture representative failures and measure baseline pass rates.

### A robust implementation approach

1. **Define a precise schema.** Specify required fields, types, enums, bounds, nullability, and cross-field constraints. Keep the requested output shape as simple as possible.
2. **Use native constrained output when available.** Prefer provider-supported structured output, JSON Schema mode, grammar constraints, or function/tool calling when it enforces the desired structure. Confirm the provider’s exact guarantees and unsupported schema features.
3. **Make instructions unambiguous.** Provide a short schema-aligned task description and a valid example only if it resolves ambiguity. Do not rely on “return JSON only” as the sole control.
4. **Validate outside the model.** Parse the response and validate it with a typed schema or validator. Check business constraints and authorization in application code.
5. **Handle failure explicitly.** On parse or validation failure, capture a safe diagnostic, optionally make a bounded repair/retry with the validation errors, and then return a controlled error or escalate. Do not silently coerce invalid values into success.
6. **Protect against truncation.** Set an adequate output-token budget, detect length-based termination, and reject incomplete JSON or partial objects.
7. **Evaluate systematically.** Test representative inputs, adversarial cases, long outputs, optional fields, multilingual content, and provider/model changes. Track schema-validity and semantic-correctness separately.

### Example

Suppose the application expects:

```json
{
  "category": "billing",
  "priority": 2,
  "needs_human_review": false
}
```

The validator should check that `category` belongs to the allowed enum, `priority` is an integer in range, and `needs_human_review` is a boolean. Valid JSON can still contain an incorrect category, so syntax/schema validation must be paired with task-quality evaluation. Any action taken from the result should still pass deterministic authorization and business rules.

### When constrained decoding is unavailable

Use the strongest available API mode, then parse and validate. A bounded repair attempt can ask the model to transform the invalid response into the exact schema while preserving meaning, but repaired output must be validated again. For critical workflows, prefer deterministic extraction, a smaller constrained model, or a human-review path over unbounded retries.

### Security and operational guardrails

- Treat model output as untrusted input; never execute generated code or SQL or grant permissions based solely on a field the model produced.
- Do not place secrets in prompts to make a format work.
- Limit retries to avoid cost loops and repeated side effects.
- Log schema version, model/prompt version, validation result, and safe failure metadata while minimizing sensitive-content retention.
- Make schema and prompt changes versioned so regressions can be reproduced and rolled back.

### Concise interview answer

“I first classify the failure—parse error, schema mismatch, semantic error, truncation, or integration issue. I define a narrow schema and use native constrained output or tool calling when supported, but I still parse and validate every response in application code. I check both structural and business rules, detect length truncation, and use only bounded repair retries followed by revalidation; otherwise I return a controlled failure or escalate. I test validity and semantic correctness separately across edge and adversarial cases. Model-generated fields are untrusted and cannot replace authorization or deterministic business logic.”

### Revision summary

| Layer | Action |
|---|---|
| Contract | Define a precise, minimal schema and constraints. |
| Generation | Use native constrained output/tool calling when available. |
| Validation | Parse and validate structure and business rules in code. |
| Recovery | Detect truncation; bounded repair/retry; controlled failure otherwise. |
| Evaluation | Track structural validity separately from semantic correctness. |
| Security | Never use model output alone for authorization or unsafe execution. |

<br><br><br>

## Your LLM-powered tool hits the context window limit on long documents. How do you handle it?

**Answer:**

### Diagnose the actual limit

First determine which limit is being hit: model input context, total input-plus-output request budget, provider request-size limit, tool/database limit, or application memory/latency limit. Capture the model and tokenizer version, serialized prompt token count, requested output budget, and termination/error reason. A character count is not an accurate token count.

### Do not send the whole document by default

If a document exceeds the context budget, the solution is usually to select and process relevant content rather than repeatedly increasing the prompt:

1. **Tokenize and inspect the document.** Use the target model’s tokenizer after applying the real chat template. Identify document structure, headings, tables, code blocks, and multimodal content.
2. **Define the task.** Is the user asking a question, requesting a summary, extracting fields, or requiring whole-document synthesis? Different tasks need different plans.
3. **Choose a processing strategy.**
   - For targeted questions, use retrieval: split into coherent chunks, index them, retrieve relevant passages, and rerank.
   - For whole-document summaries or extraction, use hierarchical/map-reduce processing: analyze sections, retain structured intermediate results with citations, then synthesize.
   - For ongoing conversations, compact older turns into a validated summary and keep recent turns plus relevant retrieved memory.
4. **Budget the final prompt.** Include only needed instructions and evidence, reserve output tokens, and account for tool/schema overhead.
5. **Preserve provenance and boundaries.** Carry section, page, or byte offsets and source IDs through chunking so answers can cite exact evidence.
6. **Handle incomplete coverage honestly.** If the workflow could not inspect all relevant sections, report the limitation or ask for a narrower query rather than implying full-document review.

### Selecting the right strategy

| Need | Strategy | Important caveat |
|---|---|---|
| Answer a specific question in a long corpus | RAG with metadata filters and reranking | Retrieval can miss evidence; evaluate recall and grounding. |
| Summarize an entire long document | Hierarchical summary over sections, then synthesis | Intermediate summaries can lose details; preserve references and verify claims. |
| Extract repeated structured fields | Chunked extraction with schema validation and deterministic merge | Detect duplicates, conflicting values, and missing sections. |
| Analyze cross-document or multi-hop relationships | Iterative retrieval, query decomposition, or graph/structured methods | More steps add latency and orchestration failure modes. |
| Continue a long chat | Recent-turn window plus compacted summary/external memory | Summary may omit facts; test recall of important details. |

### Reliability, security, and cost

- Chunk by semantic/document boundaries where possible; overlap can help at boundaries but excessive overlap creates redundant retrieval.
- Retrieve with user/tenant permissions applied before content reaches the model.
- Do not treat retrieved document instructions as trusted system instructions; defend against indirect prompt injection.
- Validate summaries and extracted records against source spans, especially for legal, financial, or medical use.
- Bound recursive calls, retries, and output sizes; map/reduce workflows can multiply token costs.
- Measure coverage, retrieval recall, answer faithfulness, extraction completeness, latency, and cost end to end.

### Example

For a 500-page policy manual and the question “What approvals are required for an international purchase?”, index section-aware chunks with page metadata. Retrieve and rerank passages about purchasing, geography, and approval thresholds; include only the selected evidence in the prompt. Ask for an answer with citations to page/section IDs, validate that cited IDs were retrieved, and abstain if evidence conflicts or is missing. For a request to summarize the entire manual, instead summarize each section and synthesize the section summaries while retaining links to source passages.

### Concise interview answer

“I first identify whether the failure is the model context window, total request budget, provider payload limit, or an application/tool limit, and count tokens with the actual model tokenizer and serialized prompt. I then choose by task: retrieve and rerank relevant chunks for targeted questions, use hierarchical processing for whole-document analysis, and compact conversation history for long chats. I preserve source IDs and citations, enforce access controls before retrieval, reserve output budget, and bound calls. Finally, I evaluate coverage, retrieval recall, faithfulness, completeness, latency, and cost. If the workflow did not inspect enough evidence, it should say so rather than imply comprehensive review.”

### Revision summary

| Step | Action |
|---|---|
| Diagnose | Identify exact limit and count with the deployed tokenizer/template. |
| Choose strategy | RAG for targeted queries; hierarchical processing for whole-document tasks. |
| Budget | Keep relevant context and reserve output/tool overhead. |
| Preserve evidence | Maintain source spans, citations, and permission metadata. |
| Guardrail | Detect incomplete coverage, bound calls, validate results, and abstain when needed. |
| Measure | Evaluate completeness/faithfulness, latency, and cost end to end. |

<br><br><br>

## Your LLM does not admit when it does not know the answer. How do you make it say "I don't know"?

**Answer:**

### Frame the problem as calibrated abstention

The goal is not merely to add “say I don’t know” to the prompt. The system needs to distinguish cases where it has sufficient evidence to answer from cases where evidence is missing, conflicting, stale, or outside the model’s validated capability. This is a **selective prediction** problem: answer when the estimated risk is acceptable; abstain, ask a clarifying question, retrieve more evidence, or escalate otherwise.

An LLM’s fluent style is not a reliable confidence signal. A self-reported confidence number may be poorly calibrated, so abstention should be based on task-specific evidence and measured decision thresholds wherever possible.

### Diagnose why it is guessing

Inspect representative failures and identify whether:

- the fact is absent from model knowledge or stale;
- retrieval failed to find the required evidence;
- retrieved passages are irrelevant or contradictory;
- the question is ambiguous or missing necessary details;
- the model is instructed or rewarded to always produce an answer;
- the model can answer but is poorly calibrated on this domain;
- a tool call, parser, or application fallback turns failure into a guess.

This determines whether the fix belongs in retrieval, prompt/schema, model adaptation, evaluation, or product flow.

### Build an abstention path

1. **Define answerability.** Specify what evidence is sufficient, what sources are authoritative, and which questions must be declined or escalated.
2. **Ground answers.** For changing or private facts, retrieve authorized source passages or call a trusted system rather than relying on parametric memory.
3. **Require evidence-linked responses.** Ask the model to cite retrieved source IDs or quote supporting spans, then validate that the cited evidence exists and is relevant.
4. **Detect evidence gaps.** Use retrieval scores and coverage indicators as signals, but calibrate thresholds against labeled examples; similarity alone is not proof of answerability.
5. **Use a structured outcome.** Return an answer, an explicit abstention reason/category, or a request for clarification. Keep these states distinct in the application API.
6. **Escalate by risk.** Route high-impact or ambiguous cases to a qualified reviewer rather than lowering the abstention threshold just to increase answer rate.

### Prompting and training

Instructions can help by defining the evidence standard and giving examples of when to abstain. Fine-tuning or preference training can improve behavior on a carefully curated set containing answerable, unanswerable, ambiguous, and conflicting-evidence cases. However, prompt wording or fine-tuning alone cannot guarantee calibrated uncertainty. Evaluation and runtime evidence checks remain necessary.

### Measure the quality-abstention trade-off

Track metrics such as:

- **Coverage:** fraction of questions the system answers.
- **Selective risk/error rate:** error rate among questions it chooses to answer.
- **Abstention precision/recall:** whether it abstains appropriately on unanswerable questions without refusing answerable ones.
- **Groundedness/citation validity:** whether claims are supported by authorized sources.
- **Calibration:** whether confidence or evidence scores correspond to observed correctness.
- **Task and cohort breakdowns:** performance by domain, language, user group, and consequence level.

Choose thresholds based on risk: a low-stakes FAQ can tolerate a higher answer coverage than a medical, legal, or financial decision-support system.

### Example

For an internal policy assistant, if retrieval returns no current policy passage, the system should not infer the reimbursement limit from general language-model knowledge. It can say, “I can’t verify the current limit from the available policy documents,” ask for the relevant region or date, or route to HR. If two authorized policies conflict, it should cite the conflict and escalate rather than arbitrarily selecting one.

### Concise interview answer

“I treat ‘I don’t know’ as a calibrated abstention problem, not a prompt-only fix. I first classify whether failures come from missing knowledge, poor retrieval, ambiguity, conflicting evidence, or an application fallback. For knowledge that must be current, I ground answers in authorized sources, require evidence-linked claims, and define explicit answer/clarify/abstain/escalate outcomes. Retrieval scores or model confidence are only signals and must be calibrated on representative data. I measure answer coverage alongside selective error, abstention performance, and groundedness, setting stricter thresholds for higher-risk use cases.”

### Revision summary

| Principle | Action |
|---|---|
| Don’t trust fluency | A confident tone is not evidence or calibrated confidence. |
| Ground facts | Retrieve authoritative, current data for changing/private knowledge. |
| Define abstention | Specify when to answer, clarify, refuse, or escalate. |
| Validate evidence | Check citations and support, not just output format. |
| Measure trade-off | Track coverage and error/abstention quality together. |
| Risk-sensitive threshold | Require stronger evidence for higher-impact decisions. |

<br><br><br>

## Your LLM generates responses that are too verbose. How do you control response length?

**Answer:**

### Diagnose the source of verbosity

First determine whether the excess length comes from the model, prompt, context, reasoning/tool traces exposed to the user, a client rendering issue, or an output limit that is too generous. Measure response-token distributions and identify which task types or prompt versions are affected.

### Control length at multiple layers

1. **Define a measurable target.** Specify a word/token range, number of bullets, sentence count, or field-level limits appropriate to the task. “Be concise” is subjective.
2. **Simplify the output contract.** Request only the fields and evidence needed. A schema with short fields can reduce unnecessary prose.
3. **Use a concise prompt instruction.** Give the expected audience, level of detail, and format; include a short example only if it resolves ambiguity.
4. **Set a generation budget.** Configure a reasonable maximum output-token limit. This is a hard cap, not a guarantee of a complete or coherent short response.
5. **Use structured or constrained output.** For summaries or extraction, request a fixed schema, bullet limit, or labeled sections and validate it.
6. **Post-process conservatively.** Truncate only where safe; do not blindly cut a response mid-sentence or remove caveats that are safety-critical. If a length violation occurs, use a bounded rewrite request and revalidate.
7. **Evaluate quality and completeness.** Ensure shorter answers still preserve required facts, uncertainty, citations, and safety information.

### Decoding settings are secondary

Temperature and top-p/top-k affect token selection diversity, not a reliable word-count target. Lower temperature does not inherently produce shorter answers. The main controls are task instructions, output structure, token budgets, and validation.

### Example

For customer-support responses, define an output contract such as: “Answer in at most three short bullet points; include the next action; cite the policy section if used; if evidence is missing, say so.” Set a completion budget based on observed tokenization, then measure both the percentage meeting the length target and whether the answer still resolves the customer’s issue. For safety-sensitive content, do not remove warnings or escalation instructions simply to meet a shorter limit.

### Concise interview answer

“I first measure verbosity by task and trace whether it comes from prompt design, excessive context, exposed tool traces, or generation settings. I make the desired length measurable—such as a word/token cap, bullet count, or concise schema—then set a suitable output-token budget and validate the response. Temperature is not a length control. If outputs exceed the target, I can use a bounded rewrite step, but I preserve required facts, citations, and safety caveats and test completeness as well as length. I monitor token consumption and user task success, not just average response size.”

### Revision summary

| Layer | Control |
|---|---|
| Requirement | Specify measurable length and necessary content. |
| Prompt/schema | Ask for only required sections/fields. |
| Generation | Set max output tokens; do not treat as completeness guarantee. |
| Post-processing | Bounded rewrite/validation; avoid unsafe truncation. |
| Evaluation | Measure length compliance and answer completeness together. |
| Common mistake | Expect temperature alone to control response length. |

<br><br><br>

## Your LLM memorized proprietary training data and leaks it in responses. How do you prevent this?

**Answer:**

### Treat it as a data-security incident

If an LLM emits proprietary training data, first determine the scope and impact: which content was exposed, to whom, through which model or application path, and whether it is still reproducible. Follow the organization’s incident-response, legal, privacy, and customer-notification procedures. Do not rely on a prompt telling the model to keep secrets.

### Identify the leakage path

Possible sources include:

- memorization and extraction from model weights;
- retrieval of documents the user is not authorized to access;
- conversation history, caches, logs, or shared prefixes crossing tenant boundaries;
- fine-tuning or synthetic-data pipelines containing confidential examples;
- prompt injection causing disclosure of data included in context;
- application code returning internal tool output or debug traces.

Distinguish model memorization from retrieval or application leakage; mitigations differ.

### Prevention and containment

1. **Minimize sensitive training data.** Avoid including secrets or unnecessary proprietary records in training; use data governance, provenance checks, deduplication, and approved retention policies.
2. **Protect training and fine-tuning pipelines.** Restrict dataset and checkpoint access, use least privilege, secure artifacts, and prevent sensitive prompts or outputs from entering unmanaged logs.
3. **Apply privacy-preserving methods where appropriate.** Differential privacy can reduce memorization risk under defined assumptions, but has privacy-utility and implementation trade-offs; it is not an automatic guarantee.
4. **Enforce access control outside the model.** Apply authorization before retrieval and tool access. Never put all tenant data in the prompt and rely on the model to choose what it may reveal.
5. **Isolate state and caches.** Key caches by tenant and full security context; prevent cross-user prefix reuse unless isolation and authorization are proven.
6. **Use data-loss controls.** Scan inputs and outputs for secrets or protected content, with carefully designed rules to limit false positives and avoid logging the sensitive value itself.
7. **Red-team extraction.** Test direct and multi-turn extraction, prompt injection, training-data inference, and cross-tenant access using controlled canary data and approved procedures.
8. **Plan response actions.** Revoke exposed credentials, remove or restrict affected data, disable the affected feature/model path, rotate artifacts or keys as necessary, and assess whether retraining or unlearning is feasible.

### Why output filters alone are insufficient

Pattern filters can catch known secrets and policy violations, but they cannot reliably detect every paraphrase or memorized passage. Prompt instructions are not a security boundary, and retrieval permission checks cannot remove information already memorized in model weights. Layer defenses and reduce sensitive data exposure at training and system-design time.

### Evaluation and governance

Track leakage-test success, sensitive-data false negatives/positives, authorization violations, and incident recurrence. Preserve necessary audit evidence while minimizing sensitive-content retention. Document data sources, training runs, model versions, access controls, retention, and remediation decisions.

### Concise interview answer

“I would treat a proprietary-data leak as a security incident and first determine whether it came from model memorization, retrieval authorization, shared state/cache, logs, or tool/application code. Prevention is layered: minimize sensitive training data, govern fine-tuning datasets and checkpoints, enforce tenant and user permissions before retrieval or tools, isolate caches, and apply output DLP plus adversarial extraction tests. Differential privacy may help under explicit assumptions but trades off utility and is not a blanket guarantee. If exposure occurred, follow incident response, contain the path, rotate affected secrets, assess notification obligations, and determine whether data removal, model replacement, or retraining is required. Prompt instructions alone are not a security control.”

### Revision summary

| Risk source | Primary control |
|---|---|
| Training memorization | Data minimization, governance, privacy techniques, extraction evaluation. |
| RAG access leak | Authorization before retrieval and source-level filtering. |
| Shared cache/state | Tenant-scoped keys, isolation, and safe invalidation. |
| Prompt injection | Treat retrieved/user content as untrusted; least-privilege tools. |
| Incident | Contain, investigate, preserve safe evidence, notify as required, remediate. |
| Key principle | Defense in depth; no single prompt or filter guarantees confidentiality. |

<br><br><br>

## Your LLM coding assistant generates outdated code using deprecated libraries. How do you fix it?

**Answer:**

### Diagnose why the code is outdated

An LLM may rely on stale training data, ambiguous package names, old examples in the prompt or retrieval corpus, or unsupported assumptions about the project’s runtime. First reproduce the issue and capture the model/version, prompt, dependency versions, generated code, and relevant error or deprecation warning. Determine whether the package was actually deprecated, which version introduced the change, and what replacement is supported.

### Ground generation in the project’s current environment

1. **Inspect the repository and lockfiles.** Identify language/runtime version, installed package versions, framework conventions, and existing APIs.
2. **Use authoritative, versioned documentation.** Retrieve official docs or API references for the exact dependency version; include the version in the prompt and context.
3. **Provide a constrained task contract.** Ask the model to use only APIs available in the pinned version, preserve existing patterns, and state assumptions. For migration work, specify the target version.
4. **Expose tools where appropriate.** A coding agent can inspect package metadata, search local symbols, run type checks or tests, and query approved documentation sources. Tool results must be treated as evidence and validated.
5. **Check generated code automatically.** Run formatter, linter, type checker, unit/integration tests, and static analysis. Fail closed if required validation fails rather than presenting code as verified.
6. **Review security and compatibility.** Confirm license, API behavior, dependency support, and avoid blindly installing packages or executing generated scripts.

### Retrieval and prompt design

RAG over official documentation can reduce stale API usage, but only if documents are versioned and retrieval filters for the project’s exact dependency version. A prompt should not just say “use the latest API”: “latest” may differ from the application’s pinned version. Include package/version constraints and request citations or links to the API documentation used.

### Evaluation and maintenance

Create a regression suite with representative coding tasks involving deprecated APIs, migration boundaries, and version-specific behavior. Measure compilation/type-check/test pass rate, deprecation warnings, unsupported API use, and security defects. Refresh documentation indexes and dependency metadata when the project upgrades; pin model/prompt versions and monitor performance after changes.

### Example

If the assistant generates an API removed in `library` version 3 while the repository is locked to version 2, the system should not upgrade the dependency implicitly. It should either generate code compatible with v2 using v2 documentation or propose a separately reviewed migration to v3, including manifest/lockfile changes and tests. The CI pipeline validates the chosen path.

### Concise interview answer

“I first verify the deprecation and identify the project’s actual runtime and pinned dependency versions. Then I ground the assistant in version-matched official documentation and repository context rather than relying on a vague ‘latest API’ instruction. I give it tools to inspect the codebase and run tests, but I treat generated code as untrusted: lint, type-check, test, and review it before merging. For an upgrade, I make the dependency migration explicit and test it separately. I add regression evaluations for deprecated APIs and refresh versioned documentation as dependencies change.”

### Revision summary

| Step | Control |
|---|---|
| Diagnose | Verify deprecation, model version, package version, and failure evidence. |
| Ground | Use repository lockfiles and official docs for the exact version. |
| Constrain | State target runtime/API versions; don’t say only “latest.” |
| Validate | Compile, lint, type-check, test, and security-review output. |
| Maintain | Version docs/prompts and evaluate dependency-upgrade regressions. |

<br><br><br>

## Your tokenizer splits important domain terms into meaningless subword pieces. How do you fix it?

**Answer:**

### Diagnose and quantify the problem

Subword fragmentation is not automatically a model failure. First use the exact deployed tokenizer to inspect how domain terms, abbreviations, identifiers, and multilingual text are split. Measure token count, truncation rate, retrieval behavior, task accuracy, latency, and cost on representative examples. Check whether the issue is merely cosmetic segmentation or is measurably harming the downstream task.

### Start with low-risk mitigations

1. **Preserve terms in preprocessing.** Avoid normalization or cleaning steps that alter case, punctuation, Unicode, or separators important to the domain.
2. **Add definitions or aliases to context.** A controlled glossary can map abbreviations, product codes, and synonyms to canonical meanings.
3. **Use retrieval and metadata.** For specialized knowledge, retrieve authoritative passages and exact-match identifiers rather than expecting the tokenizer to encode domain semantics.
4. **Improve task examples.** Prompt with representative terminology and examples, while keeping context within budget.
5. **Evaluate an alternative model/tokenizer.** If fragmentation materially affects quality or token cost, benchmark models with better coverage for the domain and language.

### When tokenizer adaptation is justified

Adding domain-specific tokens or retraining a tokenizer can reduce sequence length and make frequent terms atomic, but it is a model adaptation project:

- new token IDs need corresponding embedding and output-projection weights;
- added vectors need initialization and training/adaptation so the model learns their use;
- tokenizer, model, and serving artifacts must be versioned and shipped together;
- fine-tuning must cover inflections, contexts, and interactions with existing vocabulary;
- evaluation must verify quality improvement and avoid regressions on general text.

Simply adding a token to a tokenizer without compatible model weights does not teach the model what that token means. Replacing the tokenizer wholesale is even riskier because token IDs no longer align with the trained embedding matrix.

### Decision framework

| Option | Best when | Main trade-off |
|---|---|---|
| Keep tokenizer; add glossary/context | Fragmentation is modest and knowledge can be supplied. | Uses prompt/context tokens and may need retrieval. |
| Hybrid keyword + semantic retrieval | Exact identifiers and conceptual similarity both matter. | Requires index/ranking engineering. |
| Choose a domain-strong model | Another model offers better measured coverage/quality. | Migration, licensing, cost, and behavior differences. |
| Add tokens and adapt weights | Frequent domain terms create measurable cost/quality problems and training is feasible. | Requires training, compatibility management, and broad regression testing. |

### Concise interview answer

“I first quantify whether token fragmentation actually harms task quality, context usage, or cost using the model’s exact tokenizer. I check preprocessing, then try low-risk options such as preserving terminology, supplying a glossary, retrieval, and hybrid exact/semantic search. I may benchmark a model with better domain coverage. Only if the benefit justifies the cost would I add tokens or retrain the tokenizer, because token IDs must align with learned embedding and output weights; new vectors need initialization and adaptation. I would version the tokenizer/model together and evaluate both domain gains and general-capability regressions.”

### Revision summary

| Principle | Action |
|---|---|
| Measure first | Inspect segmentation and prove quality/cost impact. |
| Low-risk fixes | Preserve text, glossary, retrieval, hybrid search, alternative model. |
| Tokenizer changes | Require matching embedding/output weights and training. |
| Compatibility | Ship tokenizer and model as one versioned artifact. |
| Regression control | Test domain terms plus general language/code performance. |

<br><br><br>

## Your Transformer's KV cache grows too large during long sequence generation. How do you manage memory?

**Answer:**

### Diagnose before changing the model

The KV cache grows with the number of active sequences and cached tokens. First measure cache bytes per sequence and total GPU memory under realistic prompt lengths, output lengths, batch/concurrency, and model configuration. Separate KV memory from model weights, activations/workspaces, communication buffers, and allocator fragmentation. Check whether the runtime is holding completed or abandoned request caches longer than necessary.

For a decoder with \(L\) layers, batch \(B\), cached tokens \(T\), \(H_{KV}\) key/value heads, head dimension \(d_h\), and \(b\) bytes per element:

\[
M_{\text{KV}}\approx 2LBT H_{KV}d_hb
\]

The factor 2 accounts for keys and values. This makes the primary levers explicit: lower \(B\), \(T\), \(H_{KV}\), or \(b\), or improve allocation/reuse.

### Practical mitigation hierarchy

1. **Set admission control and limits.** Bound maximum context and output tokens, limit simultaneous sequences, apply per-tenant quotas, and reject or queue requests before GPU memory is exhausted.
2. **Reduce unnecessary context.** Use retrieval, conversation compaction, or context selection so the model sees relevant information rather than an unbounded transcript. Validate quality so compression does not remove needed evidence.
3. **Use efficient cache allocation.** Paged/block-based KV allocation reduces fragmentation and supports variable-length requests. It improves utilization but does not reduce bytes required for every live token.
4. **Choose suitable attention architecture.** GQA/MQA use fewer KV heads than query heads and can substantially reduce cache size. This is generally a model/checkpoint property, not a harmless runtime switch.
5. **Use lower-precision KV storage.** FP8 or quantized KV cache reduces bytes per entry, but assess quality, scale metadata, kernel support, and long-context behavior.
6. **Reuse safe prefixes.** Prefix caching can avoid duplicate prefill and cache work for identical prefixes, but cache keys must include the complete security context and tenant isolation requirements.
7. **Consider cache eviction or sliding windows.** Keep recent tokens or selected sink tokens when supported, understanding that evicted details may no longer be accessible.
8. **Scale or shard when appropriate.** Tensor/model parallelism or additional accelerators can increase capacity, but adds communication, operational cost, and complexity.

### Preserve correctness and isolation

Cache optimization must not mix user or tenant states. Ensure cache entries are scoped to the exact prompt prefix, model version, positional configuration, and relevant security identity; expire them on completion or cancellation. Avoid reusing a cache across requests unless prefix equivalence and authorization are guaranteed.

For eviction, quantization, or context compression, evaluate long-range recall, answer quality, time-per-output-token, throughput, memory use, and tail latency. Include requests that depend on early context, not only recent-turn examples.

### Example

If a service serves 32K-token histories with a large concurrent batch, cache memory can dominate even though model weights fit. First, profile live cache allocation and request-length distribution. Then enforce a context budget, retrieve only relevant older conversation facts, use the model’s supported GQA configuration, and enable paged cache allocation. If memory is still constrained, test KV quantization and reduce concurrency or shard the workload. Compare task quality and p95/p99 latency at peak load before rollout.

### Concise interview answer

“I would profile KV memory separately from weights and workspaces, using the model’s layer count, KV-head count, head dimension, dtype, active sequence lengths, and concurrency. The cache scales approximately as \(2LBT H_{KV}d_hb\), so context length and batch compete for memory. I’d first enforce admission and token limits and remove irrelevant history through retrieval or compaction, then use paged allocation, GQA/MQA, lower-precision cache, and safe prefix reuse where supported. Eviction or sliding windows can bound memory but may lose long-range information. I’d validate memory savings against quality, latency, throughput, and tenant isolation.”

### Revision summary

| Lever | Effect | Caveat |
|---|---|---|
| Context selection | Fewer cached tokens \(T\) | Must retain needed evidence. |
| Admission/batch limits | Fewer concurrent sequences \(B\) | Queue/reject under load. |
| GQA/MQA | Fewer KV heads \(H_{KV}\) | Architecture/checkpoint-specific. |
| KV quantization | Fewer bytes \(b\) | Quality and kernel validation required. |
| Paged cache | Less fragmentation | Does not shrink live-token data. |
| Eviction/window | Caps retained tokens | Older details may be lost. |

<br><br><br>

## Your Transformer runs out of memory on long documents due to quadratic self-attention. How do you scale it?

**Answer:**

### Confirm which memory is exhausted

“Long-document OOM” can come from several places: attention intermediates during prefill, KV cache during generation, model weights, activations for training, or allocator fragmentation. Capture the failing sequence length, batch, dtype, attention implementation, peak memory, and whether the failure occurs in training, prompt prefill, or decoding. The fix depends on the phase.

For full attention over \(T\) tokens, the pairwise score matrix has \(T^2\) entries per head. Standard full-attention interactions therefore grow roughly quadratically in sequence length. During training, storing activations adds further memory; during inference, KV cache grows roughly linearly with retained tokens and concurrency.

### Scale the application before changing architecture

For a single question over a long corpus, sending the entire corpus is often unnecessary. Use token-aware chunking, retrieve relevant passages, rerank, and pass only the evidence needed. For whole-document tasks, process sections hierarchically and synthesize results with source references. This reduces both prompt size and attention work, though retrieval/summary coverage must be tested.

### Inference optimizations

- **Use FlashAttention or an equivalent efficient kernel.** It reduces memory traffic and avoids materializing the full attention matrix in HBM, while retaining dense-attention pairwise compute.
- **Reduce batch or sequence length.** Apply admission control and reserve output tokens; monitor the quality cost of context truncation.
- **Manage KV cache.** Use GQA/MQA, cache quantization, paging, prefix reuse, or bounded windows where supported.
- **Use context selection.** Retrieval, compaction, or summarization reduces prompt prefill and cache size.
- **Scale across accelerators.** Sharding can increase available memory but introduces communication and operational costs.

### Training optimizations

If training or fine-tuning is the OOM source, consider activation checkpointing/rematerialization, microbatching with gradient accumulation, mixed precision, sequence packing, and model/data parallel strategies. These trade compute, throughput, numerical behavior, or engineering complexity for memory. Ensure that checkpointing and distributed configuration are compatible with the model and optimizer.

### Architectural options for very long contexts

| Approach | How it helps | Trade-off |
|---|---|---|
| Sliding-window/local attention | Limits each token to a neighborhood, reducing pairwise interactions. | Distant information is not directly accessible in that layer. |
| Sparse/block attention | Computes only selected attention connections. | Pattern may miss relevant links; kernels must exploit sparsity. |
| Hierarchical/compressed attention | Compresses or summarizes segments before global processing. | Compression can lose detail and needs task evaluation. |
| State-space/recurrent or hybrid models | Avoids full all-pairs attention in some designs. | Different architecture, behavior, checkpoint availability, and tooling. |

These are architectural/model choices; changing a mask at inference is not generally equivalent to a model trained for that attention pattern.

### Rollout and measurement

Benchmark representative document lengths and concurrency. Track peak memory, prefill latency, TTFT, decode TPOT, throughput, cost, retrieval recall, answer faithfulness, and long-range task quality. Test early/middle/late document facts and distractors. Apply one major optimization at a time and keep a rollback path.

### Concise interview answer

“I first identify whether the OOM is from training activations, attention intermediates during prefill, or the KV cache during decode. For dense attention, pairwise interactions grow roughly as \(T^2\), while KV memory grows with context and concurrency. I’d reduce unnecessary input with retrieval or hierarchical processing, use an IO-efficient kernel such as FlashAttention, adjust batch/sequence limits, and manage cache with GQA, quantization, or paging. If the workload genuinely needs very long global context, I’d evaluate sparse, sliding-window, or compressed-attention architectures trained for that behavior. I’d compare memory and latency savings against long-range quality, retrieval coverage, and cost.”

### Revision summary

| OOM phase | Typical levers |
|---|---|
| Training activations | Checkpointing, microbatching, mixed precision, parallelism. |
| Prefill attention | Efficient kernels, shorter/retrieved context, sparse/hierarchical architecture. |
| Decode KV cache | GQA/MQA, quantization, paging, context/batch limits, eviction. |
| Application input | Chunking, retrieval, summarization, hierarchical synthesis. |
| Required validation | Peak memory, latency, throughput, and long-range task quality. |

<br><br><br>

## Your distilled student model fails on the complex reasoning that the teacher model handled. How do you close the gap?

**Answer:**

### Diagnose the capability gap

First determine what “fails on reasoning” means with a failure taxonomy: missing domain knowledge, multi-step planning, arithmetic, tool use, long-context retrieval, instruction following, or robustness. Build a representative evaluation set and compare teacher and student on both final answers and intermediate task behavior. Check for data contamination, teacher errors, and whether the student’s deployment settings differ from evaluation.

Distillation compresses behavior into a smaller model; it does not guarantee that every teacher capability transfers, especially rare or long-horizon reasoning.

### Improve the transfer data

- **Curate hard examples.** Oversample tasks where the student fails, but maintain representative easy and safety cases to prevent regressions.
- **Use verified targets.** Validate teacher solutions with executable tests, symbolic checkers, trusted references, or expert review where possible.
- **Improve coverage and diversity.** Include varied reasoning paths, problem formulations, difficulty levels, languages, and edge cases—not only polished canonical traces.
- **Filter low-quality demonstrations.** Teacher traces can be verbose, wrong, or unnecessarily complex; retain useful supervision, not mere length.
- **Protect evaluation integrity.** Keep held-out test sets separate from teacher generation and training data.

### Choose the right distillation signal

If available, **soft-target/logit distillation** gives the student information about alternatives, not only the teacher’s chosen token. When teacher logits are unavailable, high-quality response distillation can still help, but performance depends on examples and coverage. Intermediate representation matching may be useful when architectures are compatible; it is not required and can be hard across different tokenizers or model structures.

For multi-step tasks, train on intermediate supervision only when it improves observable task performance and is appropriate to expose. Alternatives include outcome-based signals, verifiable rewards, tool-use demonstrations, or decomposed subtask supervision. Do not equate generating a long rationale with actually solving the task.

### Adjust the student and system design

- Increase student capacity or use a stronger starting checkpoint if the gap is irreducible under the current model size.
- Continue pretraining on relevant data when the issue is domain knowledge; use supervised fine-tuning when it is task behavior.
- Use curriculum or staged training from simpler to harder examples, then re-evaluate transfer.
- Give the student tools (calculator, code execution in a safe sandbox, retrieval) for tasks where deterministic computation or external evidence is better than internal recall.
- Route high-complexity or low-confidence requests to the teacher or a human; distillation need not imply one model handles every case.

### Measure what improved

Compare student and teacher on exact-match/verifiable correctness, robustness, calibration/abstention, tool success, latency, memory, and cost. Include repeated runs for stochastic generation. Establish acceptance thresholds for the use case; a student may be valuable even with a gap if the gap is bounded and routing catches hard cases.

### Concise interview answer

“I’d first break the reasoning failures into categories and reproduce them on a held-out evaluation set. Then I’d improve the distillation data with verified, diverse hard examples and check that teacher outputs are correct; if available, soft logits can transfer more than a single sampled answer. I’d consider curriculum, task/outcome supervision, tool use, or a stronger/larger student depending on whether the gap is knowledge, reasoning, or compute. I would not assume longer chain-of-thought fixes it. Finally, measure capability and safety against the teacher and use routing or human escalation for cases outside the student’s validated envelope.”

### Revision summary

| Failure cause | Response |
|---|---|
| Poor or narrow teacher data | Curate, verify, diversify, and target hard cases. |
| Lost distribution information | Use soft targets/logits if compatible and available. |
| Student capacity limit | Larger/stronger student or specialized routing. |
| Computation/knowledge need | Tools, retrieval, domain continued pretraining. |
| Evaluation contamination | Maintain isolated held-out sets. |
| Residual gap | Route difficult cases; do not overclaim parity. |

<br><br><br>

## After RLHF alignment, your LLM became safer but lost capability on hard tasks. How do you manage the alignment tax?

**Answer:**

### Define and verify the regression

The **alignment tax** is a capability or utility regression that can accompany alignment/post-training intended to improve helpfulness, safety, or preference satisfaction. First verify the effect with a controlled comparison: same base checkpoint, prompts, decoding configuration, evaluation sets, and scoring. Separate genuine capability loss from changed refusal behavior, verbosity, calibration, or benchmark variance.

Build a slice-based evaluation that includes hard in-distribution tasks, benign requests near safety boundaries, clearly disallowed requests, multilingual cases, and adversarial prompts. Track capability and safety jointly rather than optimizing one aggregate score.

### Diagnose where the tax comes from

Possible causes include preference data that over-penalizes uncertainty or technical detail, reward-model bias, over-optimization against a proxy, data imbalance, distribution shift, or an evaluation that rewards unsafe compliance. Inspect examples and labels, compare pre/post-training behavior, and use multiple evaluators and human review.

### Mitigation strategies

1. **Improve preference and demonstration data.** Include high-quality hard-task examples and distinguish harmful assistance from benign technical work.
2. **Balance objectives deliberately.** Use capability, helpfulness, and safety evaluations/rewards with explicit constraints or weights; avoid assuming a single scalar reward captures all values.
3. **Tune alignment strength.** Reduce over-optimization, adjust training duration/regularization, or use a less destructive adaptation strategy while monitoring safety.
4. **Preserve capability with replay or mixed data.** Include high-quality pretraining/task examples during post-training to reduce forgetting, while respecting data provenance and safety.
5. **Improve reward modeling.** Add diverse comparisons, expert review, counterexamples, and reward-model stress tests; check for systematic preferences for refusals or generic answers.
6. **Use targeted behavior rather than blanket refusal.** Train calibrated refusal boundaries and safe-completion behavior so allowed hard tasks remain answerable.
7. **Use system-level controls.** For high-risk actions, combine model behavior with policy checks, tools, permissions, and human review rather than forcing the model to solve all safety through broad refusals.

### Decision and release criteria

Define minimum safety and capability thresholds for each deployment domain. A model should not be released solely because safety benchmarks improved if critical benign tasks regressed, nor because capability improved if harmful behavior rose. Use staged rollout, red-team testing, monitoring, and rollback criteria.

### Concise interview answer

“I would first confirm the alignment tax with a controlled, slice-based evaluation, separating capability loss from increased refusal, changed calibration, or scoring variance. Then I’d inspect preference data, reward-model behavior, and optimization strength. Mitigations include better-balanced and expert-reviewed data, replay of capability examples, less aggressive optimization, targeted refusal boundaries, and system-level policy/tool controls. I would track safety and hard-task utility together with predefined thresholds, red-team the boundary cases, and only deploy through a staged rollout with rollback criteria. Alignment should improve safe behavior without treating blanket refusal as success.”

### Revision summary

| Step | Goal |
|---|---|
| Confirm regression | Controlled before/after evaluations and failure slices. |
| Diagnose | Data, reward model, optimization, or evaluation issue. |
| Mitigate | Balance data/objectives, replay capability, tune alignment strength. |
| Avoid shortcut | Do not equate more refusal with better alignment. |
| Release | Joint safety/capability gates, staged rollout, monitoring, rollback. |

<br><br><br>

## Your RLHF-trained LLM is gaming the reward model instead of being genuinely helpful. How do you fix reward hacking?

**Answer:**

### Core idea

**Reward hacking** occurs when a model finds outputs or behaviors that score well under a reward model or proxy objective without delivering the intended real-world value. In RLHF, the reward model is an imperfect approximation of human preferences; optimizing it strongly can exploit its blind spots. The result may look polished or score highly while being unhelpful, unsafe, evasive, or factually wrong.

### Diagnose the exploit

1. Collect examples with high reward but poor human/task outcomes.
2. Categorize the exploit: verbosity, sycophancy, refusal overuse, format gaming, citation fabrication, reward-model artifacts, or benchmark-specific tricks.
3. Check reward-model calibration and disagreement with expert/human judgments on the affected slices.
4. Determine whether the issue comes from preference data, reward-model training, policy optimization, or the evaluation itself.

Do not respond by simply adding a penalty for the observed string or behavior; the policy may find a new proxy loophole.

### Mitigation

- **Improve preference data:** Add targeted comparisons for hacked behaviors and include diverse raters, domain experts, and difficult edge cases.
- **Strengthen reward-model evaluation:** Use held-out adversarial tests, calibration checks, subgroup analyses, and independent judges; monitor reward-model overoptimization.
- **Constrain optimization:** Reduce update magnitude or training duration, regularize toward a reference policy where appropriate, and monitor capability and safety as optimization proceeds.
- **Use verifiable rewards where possible:** For math, code, or structured tasks, incorporate unit tests, exact checks, or environment outcomes rather than relying solely on subjective reward.
- **Use multiple signals and hard constraints:** Combine preference reward with factuality, safety, task success, and policy constraints, while checking for new conflicts.
- **Red-team continuously:** Generate examples that exploit known reward features and test whether the policy remains robust under distribution shift.
- **Preserve human oversight:** Require expert review for high-impact deployments and create an incident/rollback path.

### Example

If the reward model prefers detailed answers, the policy may learn to produce long, confident responses with fabricated citations. Add preference examples where concise, evidence-supported answers beat verbose unsupported ones; validate citations against actual sources; score task correctness separately; and test across domains. A word-count penalty alone could make the model terse but still wrong, so evaluate the intended outcome rather than the surface feature.

### Monitoring and release

Track reward score alongside human preference, task completion, factuality, refusal correctness, safety incidents, and distributional shifts. A rising reward with falling task quality is a warning that optimization is exploiting the proxy. Use staged deployment, canaries, and rollback thresholds; do not treat reward-model score as the sole release criterion.

### Concise interview answer

“Reward hacking means the policy optimizes the reward model’s proxy rather than the intended human or task outcome. I’d identify high-reward/low-quality examples, categorize the exploit, and inspect reward-model calibration and preference-data gaps. Then I’d add targeted, diverse comparisons, use verifiable task rewards where possible, constrain optimization against a reference policy, and evaluate with independent human and task metrics. I’d red-team for new loopholes and monitor reward alongside real outcomes; a surface-level penalty can just move the exploit. Deployment needs staged rollout and rollback criteria.”

### Revision summary

| Principle | Action |
|---|---|
| Detect | Find high-reward examples that fail real task/human quality. |
| Diagnose | Identify data, reward model, optimizer, or benchmark weakness. |
| Improve signal | Targeted preferences, expert input, verifiable rewards. |
| Limit exploit pressure | Regularization, conservative optimization, hard constraints. |
| Validate | Independent evaluations and ongoing red teaming. |
| Monitor | Reward score plus real task, safety, and human outcomes. |

<br><br><br>

## Your chatbot loses context after 10 turns in a conversation. How do you maintain a long conversation context?

**Answer:**

### Diagnose the context failure

“Losing context” may mean the conversation exceeded the model’s token window, the application stopped sending older turns, history was truncated incorrectly, a summary omitted important facts, or the model received the information but failed to retrieve/use it. Inspect the serialized prompt and token counts at each turn, the truncation/compaction policy, and a reproducible case before changing the model.

The context window is not persistent memory: the model only conditions on information present in the current request or made available through an external memory system.

### Design a layered conversation memory

1. **Keep the recent-turn window.** Include the latest exchanges verbatim to preserve immediate references, corrections, and conversational flow.
2. **Maintain a compact, structured summary.** Summarize durable facts, user preferences, unresolved tasks, and key decisions from older turns. Separate user-provided facts from model inferences and include timestamps or provenance where useful.
3. **Use external memory for durable or searchable information.** Store permitted facts/events or conversation segments with user/tenant scope and metadata; retrieve only what is relevant to the current turn.
4. **Preserve task state explicitly.** For multi-step workflows, store structured state (completed steps, constraints, tool results) rather than expecting a prose summary to serve as a database.
5. **Rebuild context every turn.** Assemble system instructions, relevant memory, recent messages, retrieved evidence, and output budget using the target tokenizer.

### Memory policy and trust

Decide what should be remembered, for how long, and how users can inspect, correct, or delete it. Do not silently store sensitive information. Apply access controls before retrieval, isolate tenants, encrypt data appropriately, and define retention policies. Treat retrieved memory as context, not as higher-priority instructions; it may be stale or malicious.

Summaries can distort or omit information. Preserve source references for important claims, refresh summaries from the conversation rather than repeatedly summarizing summaries when feasible, and allow correction when the user says “that’s no longer true.”

### Context assembly and token budgeting

- Count tokens after applying the actual chat template; role markers, tools, and retrieved memory also consume budget.
- Reserve output tokens and avoid filling the entire window with background.
- Prefer relevant context to a full transcript; retrieve by semantic and exact-match signals when appropriate.
- Resolve conflicts by freshness, provenance, and explicit user correction; do not merge contradictory memories silently.
- Detect when required context is missing and ask a clarifying question instead of improvising.

### Evaluation

Build multi-turn tests for references to early facts, corrections, topic changes, conflicting or outdated memory, and deletion requests. Measure answer accuracy, memory retrieval precision/recall, token use, latency, cost, privacy violations, and user correction rate. A larger context window may help, but should be compared with a memory design under realistic traffic.

### Concise interview answer

“I’d first inspect the actual prompt and compaction path to see whether history is truncated, omitted, summarized poorly, or present but unused. I would not send the entire transcript forever. I’d keep recent turns verbatim, maintain a concise and provenance-aware summary, store durable facts or workflow state externally when appropriate, and retrieve only relevant memories on each turn. The context builder must be token-aware, reserve output budget, resolve stale/conflicting facts safely, and enforce user/tenant permissions. I’d evaluate long-range recall, corrections, topic changes, privacy, latency, and cost—and ask for clarification when the needed context is absent.”

### Revision summary

| Memory layer | Purpose |
|---|---|
| Recent turns | Preserve local conversational detail. |
| Summary | Carry compressed durable context. |
| External retrieval | Recall relevant facts/events beyond prompt history. |
| Structured state | Track workflow progress and constraints reliably. |
| Governance | Scope, consent, correction, deletion, retention, access control. |
| Evaluation | Test early references, updates, conflicts, and privacy—not only turn count. |

<br><br><br>

## Your chatbot fails when users switch topics mid-conversation. How do you handle topic switches?

**Answer:**

### Diagnose the failure mode

When a user changes topics, the chatbot may over-weight the previous turn, carry stale retrieved context, reuse the wrong task state, or fail to recognize a new intent. Reproduce the issue with topic-switch examples and inspect the conversation history, memory summary, retrieval results, tool state, and prompt instructions.

### Make topic and task state explicit

- **Detect a new intent or topic.** Use the model or a lightweight classifier to identify whether the user is continuing, refining, correcting, or starting a new task. Treat this as a signal, not an irreversible decision.
- **Separate conversational history from active task state.** Store active workflow state in structured fields with clear lifecycle; do not let an old task’s constraints silently govern unrelated requests.
- **Use scoped memory.** Keep facts that remain globally relevant separate from topic-specific context. Retrieve topic-specific memory only when the new query indicates relevance.
- **Reset or reframe context when appropriate.** Start a new task context or summarize prior discussion briefly, while preserving user preferences that are still applicable.
- **Ask when ambiguous.** If the new request could be a follow-up or a new subject and the distinction affects the answer, ask a short clarification.

### Prompt and orchestration design

Represent messages with role and timestamps, summarize conversations by topic or task, and mark which facts are active, stale, or superseded. Retrieval queries should be built from the current user request rather than blindly from the full transcript. Tool calls and their outputs should be associated with the relevant task so a previous tool result is not reused as if it applied to the new topic.

### Example

If a user discusses travel plans and then asks, “How do I reset my password?”, the assistant should recognize a likely new support topic, avoid injecting travel details into the answer, and retrieve account-help content. A persistent preference such as “keep answers concise” may still apply, but the travel itinerary should not. If the user instead asks, “What about the second city?”, that is likely a continuation and should use the travel context.

### Evaluation and safeguards

Test explicit subject changes, subtle follow-ups, pronouns, corrections, multiple concurrent tasks, and switches after long tool workflows. Measure intent classification, stale-context use, task completion, clarification rate, and privacy leakage. Do not indiscriminately erase all history; retain only context relevant to the new request and permitted by the memory policy.

### Concise interview answer

“I’d distinguish continuation, refinement, correction, and a new topic, using intent detection as a routing signal and clarification when ambiguity matters. I’d keep active workflow state separate from general conversation memory, scope summaries and retrieved memories by topic, and build retrieval from the current request instead of the entire transcript. On a clear switch, I’d reset or reframe task-specific context while retaining applicable user preferences. I’d test follow-ups and abrupt switches to catch stale-context errors and measure both task success and unnecessary clarification.”

### Revision summary

| Problem | Control |
|---|---|
| Old topic dominates | Detect topic/intent change; reframe active context. |
| Wrong memory retrieved | Scope memory and retrieval to current task. |
| Workflow state leaks | Store state explicitly with lifecycle and task ID. |
| Ambiguous transition | Ask a clarifying question when consequential. |
| Validation | Test follow-up, switch, correction, and multi-task conversations. |

<br><br><br>

## Your QA system always generates an answer even when no answer exists in the context. How do you detect unanswerable questions?

**Answer:**

### Define answerability from evidence

An unanswerable question is one for which the provided or retrieved context does not contain sufficient, valid evidence to support the requested answer. The system should not infer that a fluent model response is supported simply because it sounds plausible. Define what counts as sufficient evidence for each task and whether external knowledge is allowed.

### Use an evidence-aware pipeline

1. **Retrieve candidate evidence.** Search the authorized corpus using semantic and lexical methods where useful.
2. **Assess coverage and relevance.** Determine whether the retrieved passages actually address every part of the question; a high similarity score alone is not proof.
3. **Check answer support.** Ask the model to answer only from the provided evidence and identify which spans support each claim.
4. **Apply an abstention decision.** Use calibrated retrieval/entailment signals, model output, and task rules to choose answer, clarify, or abstain.
5. **Validate citations and claims.** Confirm cited passages exist and support the stated answer; reject fabricated citations.
6. **Return a clear outcome.** Say that the evidence is insufficient, ask for missing details, or route to a trusted source rather than guessing.

### Detection signals and calibration

Useful signals include retrieval recall estimates, passage relevance, entailment or support scores, disagreement across evidence, source freshness, and the model’s structured answerability judgment. None is reliable in isolation. Calibrate thresholds on labeled answerable/unanswerable examples that reflect production questions and the cost of false answers versus false abstentions.

Track:

- answer accuracy on answerable questions;
- abstention precision and recall on unanswerable questions;
- selective risk among answered cases;
- citation validity and claim-level support;
- coverage and user resolution rate;
- performance by domain, language, and risk level.

### Example

If the context says a policy applies to domestic purchases but the question asks about international purchases, the model should not extrapolate the same rule. It should state that the provided context does not specify the international case, cite the limitation, and request the relevant policy or route to an authoritative source.

### Concise interview answer

“I define answerability as whether the available authorized evidence sufficiently supports the requested claims. I retrieve evidence, check coverage and relevance, require claim-linked citations, and use calibrated abstention thresholds rather than relying on similarity or self-reported model confidence alone. If evidence is missing, conflicting, stale, or incomplete, the system asks a clarification or abstains. I evaluate answer accuracy and abstention precision/recall together, plus citation support and selective risk, with thresholds based on the harm of a false answer.”

### Revision summary

| Stage | Check |
|---|---|
| Evidence | Is relevant, authorized context present? |
| Coverage | Does it answer every part of the question? |
| Support | Are claims entailed by cited spans? |
| Decision | Answer, clarify, or abstain using calibrated thresholds. |
| Metrics | Accuracy, abstention quality, coverage, citation validity, selective risk. |

<br><br><br>

## Your summarization system hallucinated facts not in the original article. How do you fix it?

**Answer:**

### Treat it as a faithfulness failure

A summary can be fluent yet include claims unsupported by the source. First reproduce the issue and determine whether the fact was introduced by the model, copied from other context, inferred beyond the article, or created during chunk aggregation. Preserve the source version, prompt, model settings, and output for diagnosis.

### Reduce unsupported generation

1. **Clarify the contract.** Require the summary to include only information supported by the source and to preserve uncertainty, attribution, dates, and qualifiers.
2. **Constrain input context.** Ensure the model sees the correct article version and does not receive unrelated or stale retrieved text.
3. **Use source-grounded extraction.** For factual summaries, first extract key claims with source spans, then synthesize from those claims. For long articles, summarize sections with provenance and combine them carefully.
4. **Validate claims against the source.** Split the summary into atomic factual claims and check entailment/support using source comparison, rules, a separate evaluator, or human review for high-risk content.
5. **Retain citations or offsets.** Link important summary statements to paragraphs, page numbers, or character spans so unsupported additions are easier to detect.
6. **Use abstention for ambiguity.** If a detail is missing or unclear, omit it or say the source does not specify it instead of filling the gap from general knowledge.

### Evaluate systematically

Create a regression set containing negation, numbers, dates, named entities, causal claims, conflicting statements, and source passages that do not contain the answer. Measure factual consistency/faithfulness separately from coverage, fluency, and concision. Human review remains important where an invented fact could cause harm.

For long documents, map/reduce summarization can compound errors: a hallucinated intermediate summary may be treated as source truth by later stages. Keep references to original sections and, where possible, verify final claims against the original article rather than only against intermediate summaries.

### Example

If the article says “the trial may begin in June,” a summary saying “the trial begins in June” removes uncertainty. Add tests for modal language and preserve attribution and hedging. A claim-level checker should compare the summary against the source and flag the stronger assertion for revision.

### Concise interview answer

“I’d reproduce the failure and separate source-grounding issues from contamination by unrelated context or errors in hierarchical summarization. I’d make the output contract explicit, keep the prompt tied to the correct source, extract claims with provenance before synthesizing, and validate atomic summary claims against the original text. For long documents, I’d verify final claims against source spans rather than trusting intermediate summaries. I’d evaluate faithfulness separately from coverage and readability, with targeted tests for dates, numbers, negation, attribution, and uncertainty.”

### Revision summary

| Risk | Mitigation |
|---|---|
| Model adds outside knowledge | Instruct source-only; isolate source context; abstain on gaps. |
| Qualifier lost | Preserve uncertainty, attribution, dates, and modality. |
| Long-document compounding | Keep source spans and verify final claims against original. |
| Unnoticed fabrication | Claim-level support checks and human review by risk. |
| Evaluation gap | Measure faithfulness separately from coverage/fluency. |

<br><br><br>

## Your text generation repeats phrases in long outputs. How do you fix repetition?

**Answer:**

### Diagnose the repetition

First determine whether repetition is caused by decoding settings, prompt/context loops, duplicated retrieved passages, an incorrect stop condition, training-data behavior, or a generation bug that appends the same tokens repeatedly. Reproduce with fixed inputs and settings, then inspect token-level output and the full assembled prompt.

### Fix the likely causes

- **Remove duplicated context.** Deduplicate conversation history and retrieved chunks; avoid feeding a previous summary repeatedly without updating it.
- **Set a clear task and structure.** Define sections, length, and what information each section should contain. For long generation, produce bounded sections and track completed content.
- **Check stop conditions and streaming assembly.** Ensure end markers are handled correctly and the client does not append retransmitted chunks twice.
- **Tune decoding carefully.** Repetition penalties or no-repeat n-gram constraints may help in some tasks; adjust temperature/top-p only as part of a measured experiment. These heuristics can damage legitimate repetition in code, lists, or exact quotations.
- **Use staged generation for long outputs.** Generate an outline, then sections with a shared state of completed points; perform a deduplication/edit pass and validate it.
- **Improve training or prompt examples.** If repetition is systematic, investigate model quality and representative examples instead of masking every symptom with stronger penalties.

### Trade-offs

Repetition penalties can suppress repeated tokens but may also penalize important names, technical terms, or necessary code syntax. N-gram blocking can prevent valid repeated phrases. Lower temperature is not a universal fix and may make a repetitive pattern more deterministic. Select controls based on the content type and quality metrics.

### Evaluation

Measure repeated n-gram rate or semantic redundancy alongside completeness, factuality, coherence, and task success. Include long-form prose, code, enumerations, and cases where repetition is expected, such as a repeated variable name. Test at realistic output lengths and multiple sampling seeds.

### Concise interview answer

“I’d first isolate whether repetition comes from duplicated prompt/retrieval context, incorrect stream assembly or stopping, decoding, or a model-level issue. I’d remove duplicate context, define a sectioned output plan, verify token-stream handling, and then test decoding controls such as repetition penalties with safeguards because they can suppress legitimate code or terminology. For long documents I’d generate bounded sections and run a deduplication pass while checking completeness. I’d measure redundancy alongside factuality and task success rather than optimizing a repetition metric alone.”

### Revision summary

| Cause | Fix |
|---|---|
| Duplicate history/retrieval | Deduplicate and inspect context assembly. |
| Stream bug | Check chunk IDs, buffering, retries, and append logic. |
| Decode loop/stop issue | Verify stop tokens, limits, and termination path. |
| Sampling behavior | Tune penalties/filters carefully; test legitimate repetition. |
| Long output | Sectioned generation plus quality-checked deduplication. |
| Metric | Redundancy plus completeness, coherence, and correctness. |

<br><br><br>

## Transformers work on text, so can they also understand images?

**Answer:**

### Short answer

Yes. The Transformer is a sequence-processing architecture, not a text-only architecture. To use it with images, a system converts image content into representations—often patches, visual tokens, or features from a vision encoder—and supplies those representations to Transformer layers. A vision-language model learns to connect visual representations with text so it can perform tasks such as image question answering, captioning, and visual retrieval.

The model does not receive a human-like image “as is.” It receives pixel-derived tensors or tokens produced by a preprocessing and vision-encoding pipeline.

### Common architecture patterns

1. **Vision Transformer (ViT):** Split an image into patches, project each patch into a vector, add position information, and process the patch sequence with Transformer layers. A task head can classify the image or produce other outputs.
2. **Vision encoder plus language model:** A vision encoder converts image regions or patches into features. A projection or adapter maps them into a space the language model can consume, and the language model generates a text response.
3. **Jointly trained vision-language model:** Image and text representations are aligned or fused during training, supporting cross-modal matching, retrieval, captioning, or question answering.
4. **Cross-attention or unified token models:** Text may attend to visual features through cross-attention, or modalities may be represented as a combined sequence of tokens. Designs differ by model.

### How image input reaches a Transformer

A typical image-question-answering path is:

1. Decode and preprocess the image, including resizing, cropping, normalization, or tiling.
2. Encode pixels into patches/features or visual tokens.
3. Add positional or spatial information so the model can represent locations and relationships.
4. Project visual features into the representation space expected by the multimodal model.
5. Combine them with text instructions/question using the model’s fusion mechanism.
6. Generate an answer or other output, often autoregressively for a language-decoder model.

High-resolution images may be split into multiple crops or produce many visual tokens. This can improve detail but increases latency, memory, and context consumption. Image dimensions, crop policy, and model support should be considered as part of the serving budget.

### What “understand” means

“Understand” is shorthand for performing learned visual tasks—not evidence of human-like perception or guaranteed correctness. Models may miss small text, spatial relationships, fine-grained attributes, or details obscured by resolution. They can also hallucinate objects or infer unsupported facts. Performance depends on image quality, preprocessing, training data, and task.

### Production evaluation and safeguards

- Evaluate on representative images, lighting, layouts, languages, and edge cases—not only generic caption benchmarks.
- Test small objects, charts, screenshots, document tables, and OCR-like text separately.
- Measure answer correctness, grounding in image evidence, latency, visual-token usage, and cost.
- Use deterministic OCR or specialized vision tools when exact text extraction or measurement is required.
- For high-impact tasks, request evidence or bounding regions where supported and use human review.
- Treat images as untrusted input; they may contain prompt-injection text or sensitive content, so apply safety and privacy controls.

### Concise interview answer

“Yes. Transformers can process images after an image encoder or patchification step turns pixels into a sequence of visual vectors or tokens. A ViT processes patches with self-attention; a vision-language system may project image features into a language model or use cross-attention/joint multimodal tokens so text can condition on visual content. The architecture learns visual-text relationships from data, but ‘understand’ does not guarantee accurate perception: resolution, small text, spatial reasoning, and hallucination remain failure modes. In production I evaluate the target image distribution, budget visual tokens and latency, use OCR or specialized tools where exactness matters, and add grounding and review for high-risk use.”

### Revision summary

| Question | Recall |
|---|---|
| Transformer is text-only? | No; it can process any sequence-like representation. |
| Image representation | Patches, visual tokens, or encoder features. |
| Fusion | Vision encoder + projection, cross-attention, or unified multimodal tokens. |
| Output | Classification, retrieval, captioning, or autoregressive text. |
| Caveat | Visual capability is task-dependent and can hallucinate or miss details. |
| Engineering | Evaluate image distribution, resolution, latency, safety, and cost. |

<br><br><br>

## Small Language Models (SLMs)

**Answer:**

### Core idea

A **Small Language Model (SLM)** is a language model with a comparatively smaller parameter count and/or resource footprint than larger general-purpose LLMs. “Small” has no universal parameter threshold. The useful definition is operational: a model that can meet a target workload within tighter memory, latency, energy, or deployment constraints.

An SLM may be pretrained from scratch, fine-tuned, or distilled from a larger teacher. Smaller size alone does not determine capability; data quality, architecture, training, post-training, tokenizer, and task specialization matter.

### Why use an SLM?

- **Lower inference cost and latency** for suitable workloads.
- **Edge or on-device deployment** where connectivity, privacy, or device constraints matter.
- **Higher throughput per accelerator** for high-volume, bounded tasks.
- **Task specialization** through fine-tuning, retrieval, or constrained output.
- **Reduced dependency on external APIs** when self-hosted operation is desirable.

### Trade-offs versus larger models

| Dimension | SLM | Larger LLM |
|---|---|---|
| Memory/compute | Lower in many configurations. | Higher, often requiring more accelerator resources. |
| Latency/throughput | Can be favorable for supported workloads. | May handle more complex prompts but with greater serving cost. |
| Capability breadth | Often narrower, especially on complex or rare tasks. | Often broader, though not guaranteed for every domain. |
| Deployment | Better suited to edge, private, or constrained environments. | More likely to require managed APIs or larger serving clusters. |
| Adaptation | Can specialize efficiently, but has limited capacity. | Can offer more headroom, with higher cost and operational complexity. |

These are tendencies, not guarantees. Compare models on the same task and deployment conditions.

### Production pattern: cascade or route

A practical system can use an SLM for routine classification, extraction, or FAQ requests and route uncertain, complex, or high-risk cases to a larger model or human reviewer. Routing should be based on calibrated confidence/evidence and measured cost-quality trade-offs, not on model size alone. For some tasks, deterministic code or a compact traditional model may be better than either LLM.

### Evaluation considerations

Measure task-specific accuracy, robustness, calibration/abstention, safety, latency, throughput, memory, energy/cost, and maintenance burden. Include long-tail inputs and distribution shift. For on-device models, evaluate thermal behavior, battery use, quantization effects, and offline operation. Ensure licensing and data governance match the deployment.

### Concise interview answer

“An SLM is a comparatively compact language model, with ‘small’ best understood relative to the workload and deployment budget rather than a fixed parameter cutoff. It can offer lower latency, cost, memory, and on-device deployment, but may have less capability on complex or long-tail tasks. I evaluate it on representative data and actual hardware, including quality, safety, latency, throughput, and total cost. A common production design uses an SLM for routine requests and routes difficult or uncertain cases to a larger model or human reviewer, with explicit evaluation and fallback logic.”

### Revision summary

| Point | Remember |
|---|---|
| Definition | Compact model relative to workload; no universal size cutoff. |
| Benefits | Lower memory, cost, latency, and deployment footprint. |
| Trade-off | May lose breadth or robustness on complex/rare tasks. |
| Common pattern | SLM first, route hard/uncertain cases to larger model or human. |
| Decision basis | Task and hardware evaluation, not parameter count alone. |

<br><br><br>

## Large Reasoning Models (LRMs)

**Answer:**

### Core idea

**Large Reasoning Models (LRMs)** is a broad, product- and research-used label for models optimized or trained to spend more inference-time computation on multi-step problem solving. They may generate intermediate reasoning, sample or search over candidate solutions, use verification or tool feedback, or apply specialized post-training such as reinforcement learning on problems with checkable outcomes.

There is no universally standardized technical definition of “LRM,” and the label does not guarantee correct reasoning. Some systems expose reasoning traces; others keep internal traces hidden or use search/verification without displaying them.

### How reasoning capability may be improved

Common approaches include:

- **Reasoning-focused supervised fine-tuning:** Train on examples of challenging problems and solution processes or structured intermediate steps.
- **Reinforcement learning or outcome-based training:** Optimize solutions using verifiable rewards such as correct math answers, passing tests, or tool outcomes.
- **Inference-time compute:** Allow more tokens, multiple candidate attempts, search, decomposition, or verifier passes before returning an answer.
- **Tool use:** Use calculators, code execution, retrieval, or databases for operations and evidence the model should not approximate from memory.
- **Verification:** Check intermediate or final results with independent tests, constraints, or domain-specific validators.

These methods are not mutually exclusive and differ by model. A longer chain of text is not itself proof of stronger reasoning; the important outcome is reliable task performance.

### Benefits and costs

| Benefit | Cost or risk |
|---|---|
| Better performance on some complex multi-step tasks. | More tokens and higher latency/cost when using extended inference. |
| Can use verification or search to catch mistakes. | Verifiers may share model biases or be exploitable. |
| Useful for coding, math, planning, and analysis. | Can still hallucinate, fail silently, or overthink simple tasks. |
| Adaptive compute can spend more effort on hard inputs. | Requires routing, budgets, stopping rules, and evaluation. |

### Choosing and evaluating an LRM

Use task-specific evaluations with verifiable outcomes where possible. Measure pass rate, calibration, robustness, tool correctness, latency, token consumption, and cost. Compare against a simpler model plus deterministic tools; the system with the longest reasoning trace is not automatically best. For user-facing products, return a concise answer and relevant evidence rather than exposing sensitive or unnecessary internal reasoning.

### Concise interview answer

“An LRM is a loosely used term for a model or system optimized to solve complex tasks through stronger reasoning behavior or more inference-time computation. Techniques may include reasoning-focused training, outcome-based reinforcement learning, search, tool use, and verification. The term has no single standardized definition, and longer reasoning does not guarantee correctness. I evaluate actual task success and calibration against simpler baselines while measuring latency and token cost, and I use tools or verifiers for checkable operations rather than trusting a generated rationale by itself.”

### Revision summary

| Concept | Remember |
|---|---|
| LRM | Informal category emphasizing multi-step problem solving/inference-time compute. |
| Methods | Specialized training, RL, search, tools, and verification. |
| Caveat | No standard definition; reasoning traces are not proof of correctness. |
| Trade-off | Potentially stronger hard-task performance versus extra latency/cost. |
| Evaluation | Verifiable task success, calibration, robustness, latency, and cost. |

<br><br><br>

## Jev and System One Models

**Answer:**

### Source wording and ambiguity

The source heading says **“Jev and System One Models.”** “System One” is commonly used as shorthand for fast, intuitive cognition in dual-process theories, contrasted with slower, more deliberative “System Two.” However, **“Jev” is unclear in this heading** and may be a typo, an emerging term, or a reference that cannot be identified from the heading alone. I will not silently rewrite it or claim a settled technical definition for “Jev.” If the source intended a particular model or paper, its surrounding citation would be needed to identify it.

### System 1 and System 2 as an analogy

In the popular dual-process framing:

- **System 1** describes fast, automatic, low-effort responses.
- **System 2** describes slower, effortful, deliberate reasoning.

These are conceptual categories in cognitive science, not literal modules inside a Transformer. They can be used as an analogy for AI systems that route simple requests to a quick model and allocate extra computation, tools, search, or verification to harder tasks. The analogy should not be mistaken for evidence that an LLM has human cognitive systems or conscious deliberation.

### Engineering interpretation

A practical “fast path / deliberate path” design can:

1. Use a smaller/cheaper model or deterministic logic for simple requests.
2. Estimate difficulty or uncertainty using validated signals.
3. Route complex cases to a stronger model, additional inference-time budget, retrieval, or tools.
4. Verify outputs and stop when budget or quality conditions are met.
5. Escalate high-risk or unresolved cases to a human.

Routing adds its own error and latency modes. A classifier can send a hard query down the fast path or waste expensive reasoning on an easy one, so evaluate routing recall, quality, latency, and cost.

### Concise interview answer

“I interpret ‘System One’ as the fast, intuitive side of a dual-process analogy and ‘System Two’ as slower, deliberate problem solving. For AI, that can inspire a cascade: use a fast path for routine requests and spend more compute, tools, or verification on difficult ones. But those are cognitive metaphors, not literal Transformer subsystems. The source’s word ‘Jev’ is ambiguous, so I would ask for the intended reference rather than invent a definition. In engineering I would evaluate routing mistakes and total quality/latency/cost.”

### Revision summary

| Term | Careful interpretation |
|---|---|
| System 1 | Fast, automatic cognition in a conceptual dual-process model. |
| System 2 | Slower, effortful deliberation in that model. |
| AI analogy | Fast model/path versus extra compute, tools, search, and verification. |
| “Jev” | Ambiguous source wording; do not assume or invent its meaning. |
| Caveat | Human cognition metaphor, not proof of an LLM’s internal cognitive architecture. |

<br><br><br>

## What are Autoregressive Models?

**Answer:**

### Core idea

An **autoregressive model** predicts or generates each element of a sequence conditioned on the elements that came before it. “Auto” means the model’s previous outputs become inputs for later predictions. In language modeling, an autoregressive model factorizes the sequence probability as:

\[
P(x_1,\ldots,x_T)=\prod_{t=1}^{T}P(x_t\mid x_1,\ldots,x_{t-1})
\]

At each step, the model predicts the next token from the prefix. During generation, the selected token is appended to the prefix and used to predict the next one.

### Training and inference

For next-token training, a sequence is shifted so the model uses tokens \(x_1,\ldots,x_{t-1}\) to predict \(x_t\). A causal mask prevents access to future tokens. Training can compute all positions in parallel because of this mask and shifted targets; inference generation remains sequential because each next token depends on the token chosen at the previous step.

The model is typically trained with cross-entropy/negative log-likelihood over target tokens. During training, the actual previous tokens are supplied (teacher forcing); during inference, the model conditions on its own generated tokens.

### Example

Given the prefix “The weather today is,” the model produces a probability distribution for the next token. If it selects “ sunny,” that token is appended, and the model then predicts what follows. It continues until it emits a stop token or reaches a configured limit.

### Strengths and trade-offs

| Strength | Trade-off |
|---|---|
| Directly models sequence likelihood and supports flexible continuation. | Generation is sequential, which limits output-token parallelism. |
| One model can generate text/code and perform prompt-formulated tasks. | Errors in early generated tokens can affect later continuations. |
| Training positions can be parallelized with causal masking. | Long context still adds attention and KV-cache costs. |
| Straightforward next-token objective and sampling interface. | Likelihood optimization does not guarantee truth, helpfulness, or task success. |

Autoregression is not synonymous with a particular architecture, although decoder-only Transformers are the dominant autoregressive LLM design. Other sequence models can also be autoregressive.

### Concise interview answer

“An autoregressive model factorizes a sequence into conditional next-element probabilities: each token is predicted from the preceding tokens. In an LLM, training shifts targets and uses a causal mask, usually optimizing next-token cross-entropy. Training can compute positions in parallel, but at inference each selected token is appended and the next token is generated sequentially. This makes generation flexible, but introduces token-by-token latency and means early errors can propagate. Autoregressive describes the factorization/objective, not exclusively the Transformer architecture.”

### Revision summary

| Concept | Remember |
|---|---|
| Factorization | \(P(x_{1:T})=\prod_t P(x_t\mid x_{<t})\). |
| Training | Predict shifted next tokens under causal masking. |
| Inference | Append selected token and repeat sequentially. |
| Teacher forcing | Training uses true prior tokens; generation uses model outputs. |
| Caveat | Likelihood and fluent continuation do not guarantee correctness. |

<br><br><br>

## Explain the difference between autoregressive and masked language modeling.

**Answer:**

### Core distinction

**Autoregressive language modeling** predicts tokens from the preceding prefix. **Masked language modeling (MLM)** hides or corrupts selected tokens and trains the model to reconstruct them from surrounding context, which may include both left and right context.

The difference is the training objective and information flow—not simply whether one model is “generative” and the other is not.

### Training objectives

For tokens \(x_1,\ldots,x_T\), an autoregressive objective factorizes sequence probability:

\[
P(x_1,\ldots,x_T)=\prod_{t=1}^{T}P(x_t\mid x_1,\ldots,x_{t-1})
\]

It typically uses a causal attention mask and next-token cross-entropy. At training time, positions can be computed in parallel under the mask; at generation time, output tokens are generated sequentially.

Masked language modeling selects positions \(M\), corrupts or masks their tokens, and predicts the original tokens:

\[
L_{\text{MLM}}
=-\sum_{t\in M}\log P(x_t\mid \tilde{x}_{1:T})
\]

where \(\tilde{x}\) is the corrupted input. Since the model may use context on both sides of a masked position, MLM commonly uses bidirectional encoder attention. The exact corruption scheme can include mask tokens, random replacements, or unchanged tokens.

### Comparison

| Property | Autoregressive LM | Masked LM |
|---|---|---|
| Prediction target | Next token in sequence. | Selected masked/corrupted input tokens. |
| Context for prediction | Prefix only, using causal masking. | Often both left and right context. |
| Typical architecture | Decoder-only Transformer. | Encoder-only Transformer. |
| Natural strength | Open-ended left-to-right generation. | Contextual representations and understanding tasks. |
| Inference for generation | Repeated next-token decoding. | Not inherently a left-to-right generator; generation requires adaptation or another decoding procedure. |
| Example family | GPT-style decoder LMs. | BERT-style encoder LMs. |

These are common pairings, not strict architectural laws. Models may combine objectives, use span corruption, or employ other training formulations.

### Why the distinction matters

Autoregressive models naturally support chat and continuation because their training objective matches sequential generation. MLMs learn representations using both sides of a context, which can be advantageous for classification, tagging, and embeddings. For production, the choice affects serving behavior, latency, output format, and how the task should be formulated.

Neither objective guarantees factuality or task correctness. Evaluate on the intended downstream task rather than assuming an objective alone determines quality.

### Concise interview answer

“Autoregressive language modeling predicts each token from its left prefix and factorizes sequence probability as a product of next-token conditionals. It uses causal masking and is naturally suited to sequential generation. Masked language modeling corrupts selected tokens and predicts them using surrounding context, often bidirectionally, making it natural for encoder representations and understanding tasks. Their common Transformer pairings are decoder-only and encoder-only, respectively, but these are conventions rather than absolute rules. I choose based on the task’s information-flow and generation requirements, then evaluate downstream performance.”

### Revision summary

| Objective | Sees | Predicts | Natural use |
|---|---|---|---|
| Autoregressive | Prefix only | Next token | Generation/continuation |
| Masked LM | Often left and right context | Masked/corrupted tokens | Representations/understanding |
| Shared caveat | Objective is not a quality guarantee | Evaluate target task | Choose architecture and serving accordingly |

<br><br><br>

## Proximal Policy Optimization (PPO)

**Answer:**

### Core idea

**Proximal Policy Optimization (PPO)** is an on-policy policy-gradient reinforcement-learning algorithm. It updates a policy using trajectories sampled from a recent version of that policy while limiting how far the update moves from the behavior policy. PPO is commonly associated with RLHF pipelines that optimize a language model against a learned reward model, though PPO itself is a general RL method.

### PPO clipped objective

Let \(\pi_\theta(a_t\mid s_t)\) be the current policy and \(\pi_{\text{old}}\) the policy that generated the sampled action. The probability ratio is:

\[
r_t(\theta)=\frac{\pi_\theta(a_t\mid s_t)}
{\pi_{\text{old}}(a_t\mid s_t)}
\]

PPO’s clipped surrogate objective is commonly written:

\[
L^{\text{CLIP}}(\theta)
=\mathbb{E}_t\left[
\min\left(r_t(\theta)\hat A_t,\,
\operatorname{clip}(r_t(\theta),1-\epsilon,1+\epsilon)\hat A_t\right)
\right]
\]

where \(\hat A_t\) is an advantage estimate and \(\epsilon\) limits the incentive for large probability-ratio changes. Implementations often include value-function and entropy terms and may use additional KL regularization.

### PPO in an RLHF workflow

1. Sample prompts and generate responses from the current policy.
2. Score responses with a reward model or other reward signal.
3. Estimate advantages, often using a value model and methods such as generalized advantage estimation.
4. Update the policy using PPO over collected trajectories, typically with a reference-model KL penalty to constrain drift.
5. Repeat, monitoring reward, KL, capability, safety, and reward hacking.

The exact pipeline varies. PPO is not the reward model; it is the optimization algorithm that updates the policy based on sampled actions and reward/advantage estimates.

### Why clip updates?

Large policy changes can make the policy diverge from the data distribution that produced the trajectories, destabilizing learning. The clipped objective limits the benefit of moving the probability ratio beyond a range. It is a practical trust-region-like heuristic, not a strict mathematical guarantee that every update is safe or monotonic.

### Strengths and challenges

| Strength | Challenge |
|---|---|
| Uses sampled outcomes and can optimize non-differentiable reward signals. | Requires policy rollouts, making training compute-intensive. |
| Clipping helps constrain update size. | Sensitive to reward quality, advantage estimation, and hyperparameters. |
| Flexible for language-model post-training. | Can exploit reward-model errors or reduce capabilities. |
| General RL method with extensive study. | Requires careful stability monitoring and reference/KL management. |

### Concise interview answer

“PPO is an on-policy policy-gradient method that updates a policy using trajectories sampled from its recent version. It forms an importance ratio between current and behavior-policy probabilities and clips the surrogate objective so large changes receive limited incentive. In RLHF, the model generates responses, a reward model scores them, advantages are estimated, and PPO updates the policy, often with a KL penalty to a reference model. PPO is distinct from the reward model and does not prevent reward hacking by itself; rollout cost, reward quality, stability, and capability regressions need active monitoring.”

### Revision summary

| Term | Remember |
|---|---|
| PPO | On-policy policy-gradient optimization. |
| Ratio | Current-policy probability divided by behavior-policy probability. |
| Clip | Limits incentives for large probability changes. |
| RLHF use | Optimize sampled LM responses against reward/advantage signals. |
| Caveat | Clipping is not a guarantee against instability or reward hacking. |

<br><br><br>

## Direct Preference Optimization (DPO)

**Answer:**

### Core idea

**Direct Preference Optimization (DPO)** is a preference-learning method that trains a language model directly from preference comparisons, typically chosen versus rejected responses, without separately training a reward model and running an online RL algorithm such as PPO in the standard formulation.

DPO uses a reference policy and a preference objective derived from the relationship between reward maximization and KL-regularized policy optimization. It encourages the policy to assign relatively higher likelihood to preferred responses and lower likelihood to rejected ones, while controlling drift relative to the reference.

### Data format and intuition

A common training example contains:

- a prompt \(x\),
- a preferred response \(y_w\),
- a less-preferred response \(y_l\).

The objective compares the policy’s relative log-probability ratios for the chosen and rejected answers against a reference policy \(\pi_{\text{ref}}\). A common DPO loss is:

\[
L_{\text{DPO}}
=-\mathbb{E}\left[
\log\sigma\left(
\beta\left[
\log\frac{\pi_\theta(y_w\mid x)}{\pi_{\text{ref}}(y_w\mid x)}
-\log\frac{\pi_\theta(y_l\mid x)}{\pi_{\text{ref}}(y_l\mid x)}
\right]\right)
\right]
\]

where \(\sigma\) is the sigmoid and \(\beta\) controls the strength of the preference/reference trade-off under the chosen convention.

### Typical workflow

1. Start from a supervised or pretrained policy and select a reference policy.
2. Collect high-quality preference pairs for representative prompts.
3. Tokenize chosen/rejected responses and compute their sequence log probabilities under current and reference policies.
4. Optimize the DPO loss so preferred responses gain relative probability.
5. Evaluate preference quality, capability retention, safety, calibration, and distribution shift.

### DPO compared with PPO-based RLHF

| Dimension | DPO | PPO-style RLHF |
|---|---|---|
| Preference signal | Chosen/rejected pairs directly. | Reward model scores sampled policy outputs. |
| Separate reward model | Not required in the standard DPO objective. | Typically trained and used. |
| Online rollouts during optimization | Standard DPO is generally offline on fixed preference data. | Policy rollouts are part of the loop. |
| Engineering complexity | Often simpler and more stable operationally. | More moving pieces: rollout, reward, value/advantage, policy updates. |
| Limitation | Quality and coverage of static preference data constrain learning. | Reward-model error, rollout cost, and reward hacking risks. |

DPO is not “preference learning without any assumptions.” It still depends on preference-data quality, reference choice, objective assumptions, and training hyperparameters. Variants exist, so implementation details may differ.

### When DPO is a good fit

DPO can be attractive when reliable preference pairs are available and a simpler offline training loop is desirable. PPO or other online methods may be preferable when the task benefits from exploration, environment interaction, or rewards that can be evaluated on fresh rollouts. Compare methods on the same held-out tasks and constraints rather than assuming one universally dominates.

### Concise interview answer

“DPO trains a policy directly from preference pairs—chosen and rejected responses—using a reference policy and an objective that increases the preferred response’s relative likelihood while controlling drift. In the standard formulation it avoids a separately trained reward model and an online PPO rollout loop, which can simplify training. Its performance still depends on preference-data quality, coverage, reference choice, and hyperparameters; static data may not cover new policy behaviors. I compare DPO with PPO or other methods using held-out capability, safety, preference, and robustness evaluations.”

### Revision summary

| Point | Remember |
|---|---|
| Data | Prompt plus chosen/rejected response pair. |
| Mechanism | Relative policy/reference log-probability objective. |
| Advantage | Often simpler offline alternative to reward-model + PPO loop. |
| Limitation | Fixed preference data coverage and quality bound results. |
| Distinction | DPO is not itself a reward model or a guarantee against alignment failures. |

<br><br><br>

## Group Relative Policy Optimization (GRPO)

**Answer:**

### Core idea

**Group Relative Policy Optimization (GRPO)** is a policy-optimization method used in some reasoning-model training pipelines. Instead of relying on a separate learned value/critic model in the common PPO-style setup, GRPO samples a group of responses for a prompt and uses their relative rewards to form an advantage signal. This can reduce critic-model memory and training complexity, though it still requires rollouts, reward computation, and careful optimization.

### Group-relative signal

For a prompt, sample \(G\) outputs and score each with reward \(r_i\). A simplified group-normalized advantage is:

\[
\hat A_i=\frac{r_i-\operatorname{mean}(r_1,\ldots,r_G)}
{\operatorname{std}(r_1,\ldots,r_G)+\epsilon}
\]

The policy is then optimized with a clipped policy-gradient-style objective and often a KL constraint/penalty relative to a reference policy. Real GRPO implementations may include token-level masks, length handling, reward components, and other terms; the exact published formulation should be checked for a specific system.

### Why use group-relative rewards?

- **No separate critic in the common formulation:** Avoids the memory and training overhead of a value model.
- **Natural for verifiable tasks:** Group responses can be compared using outcome rewards such as correct answers or passing tests.
- **Relative learning signal:** Responses that score better than the group baseline receive positive relative advantage, while lower-scoring ones receive less.

### Trade-offs and limitations

| Benefit | Risk or cost |
|---|---|
| Lower critic-model overhead. | Still needs multiple sampled rollouts per prompt, which can be expensive. |
| Works with outcome/verifiable rewards. | Reward quality and task verifiability determine the signal. |
| Relative baseline can reduce some variance. | Group reward variance can be small or misleading; normalization choices matter. |
| Useful for reasoning optimization. | Can reward hacking, verbosity, or benchmark overfitting if reward is a poor proxy. |

Group-relative reward is not a substitute for good reward design. If every sample in a group is wrong, the best one may still receive a positive relative signal; absolute correctness checks and reward thresholds can matter.

### Concise interview answer

“GRPO is a policy-optimization approach that samples a group of responses for each prompt and uses their relative rewards—often normalized within the group—to form advantages. In its common form it avoids a separate value/critic model, reducing that overhead, while retaining policy-gradient-style updates and often a reference-policy constraint. It is useful with verifiable reasoning rewards, but it still incurs rollout cost and depends heavily on reward quality. Relative ranking alone can favor the least-wrong answer even if all samples fail, so I would use absolute checks, held-out evaluations, and reward-hacking monitoring.”

### Revision summary

| Concept | Remember |
|---|---|
| Sampling | Generate a group of responses per prompt. |
| Advantage | Compare each reward to group statistics. |
| Critic | Common GRPO formulations avoid a separate value model. |
| Strength | Useful with outcome/verifiable reward signals. |
| Caveat | Relative best can still be wrong; rollouts and reward design remain costly. |

<br><br><br>

## Recursive Language Models (RLMs)

**Answer:**

### Clarify the term

**Recursive Language Model (RLM)** is a newer and somewhat overloaded term. In recent research discussions, it often refers to an inference-time approach in which an LLM treats a large prompt or corpus as an external environment, inspects it programmatically, decomposes the task, and recursively invokes model calls on relevant portions rather than placing the entire input into one context window. Other uses of “recursive language model” may refer to different architectures or methods, so identify the paper/system being discussed before making claims.

The answer below uses the recent **recursive inference over long context** meaning, not a claim that RLM is a universally standardized model family.

### Basic execution pattern

1. **Keep the large input outside the model context.** Store it in a variable, document store, or environment that can be queried.
2. **Give the model tools to inspect it.** It may search, slice, filter, summarize, or programmatically analyze sections.
3. **Decompose the task.** The model chooses which parts to inspect and what subquestions to answer.
4. **Recursively call a model on selected pieces.** Subcalls operate on smaller chunks or targeted evidence, potentially returning summaries or structured results.
5. **Aggregate and verify.** The outer model combines results, follows source references, and produces the final response.

Unlike naive chunk-and-summarize, the model may decide which regions to inspect based on intermediate findings. Unlike simply increasing context length, only selected content is passed into each call.

### Why this can help

- Keeps each individual call within a manageable context budget.
- Supports programmatic access to documents much larger than one prompt.
- Lets the system allocate inference compute to relevant sections.
- Can combine symbolic processing (search, code, filtering) with language-model judgment.

### Limitations and production concerns

- **Coverage risk:** The model may fail to inspect a critical section or make a poor selection.
- **Orchestration cost:** Recursive calls can multiply latency, token usage, and failure points.
- **State and reproducibility:** Track subcalls, inputs, outputs, source offsets, budgets, and model versions.
- **Prompt injection:** Treat documents as untrusted data; do not allow content to override system policy or gain tool permissions.
- **Error propagation:** A subcall summary can be wrong and then contaminate later synthesis.
- **Stopping and budgets:** Enforce depth, call-count, token, time, and monetary budgets; detect loops and provide a graceful failure.
- **Evaluation:** Measure source coverage, answer faithfulness, retrieval/selection recall, cost, and latency against simpler RAG or long-context baselines.

### Compare with common alternatives

| Approach | How it handles large inputs | Main trade-off |
|---|---|---|
| Long-context model | Places more tokens in one request. | Simpler orchestration, but higher prefill/cache cost and possible position sensitivity. |
| RAG | Retrieves top relevant chunks for a query. | Efficient targeted retrieval; may miss multi-hop or unexpected evidence. |
| Hierarchical summarization | Summarizes chunks then combines summaries. | Covers broad content, but compression can lose details. |
| Recursive LM approach | Model iteratively inspects and invokes calls on selected data. | Adaptive access, but more orchestration, cost, and coverage risk. |

### Concise interview answer

“RLM is a relatively new and overloaded term; in recent long-context work it often means keeping a large input outside the prompt and letting an LLM inspect it through search, slicing, code, and recursive subcalls on selected pieces. The outer process decomposes the task and aggregates results, avoiding a single enormous context. This can improve scalability and adaptive evidence selection, but adds call cost, latency, coverage risk, state management, and prompt-injection concerns. I would compare it with RAG and hierarchical summarization, bound recursion with explicit budgets, preserve source offsets, and evaluate evidence coverage and answer faithfulness.”

### Revision summary

| Concept | Remember |
|---|---|
| Term status | New/overloaded; state which definition or paper you mean. |
| Core pattern | External large context + programmatic inspection + recursive model calls. |
| Benefit | Selective access beyond a single prompt budget. |
| Risk | Missed evidence, compounded errors, cost/latency, loop and injection risks. |
| Evaluation | Coverage and faithfulness versus RAG/long-context baselines. |

<br><br><br>

## Continual Learning in LLMs

**Answer:**

### What it means

**Continual learning** is a model's ability to learn from new data or tasks over time without losing previously acquired capabilities. For LLMs, this can mean sequentially adapting a model to new domains, languages, policies, or tasks as information arrives, rather than retraining from scratch on a fixed, complete dataset.

It is important to distinguish updating model weights from updating the knowledge available to an application. Many needs for “learning new information” are better served by retrieval, tools, or an external memory than by changing the model itself.

### The central challenge: catastrophic forgetting

If a model is fine-tuned only on new data, its parameters may shift in ways that improve the new task but damage performance on earlier tasks. This is **catastrophic forgetting**. Other concerns include distribution shift, noisy or malicious data, privacy, reproducibility, and the cost of validating each update.

### Common approaches

| Approach | How it helps | Trade-off |
|---|---|---|
| Replay or rehearsal | Mix representative earlier examples with new data. | Requires storing, selecting, and governing replay data; may raise privacy concerns. |
| Regularization | Penalize changes to parameters considered important to prior tasks. | Importance estimates and constraints can be imperfect; may limit adaptation. |
| Parameter-efficient adapters | Learn task/domain-specific LoRA or adapter parameters while leaving the base mostly fixed. | Adds routing/versioning complexity and does not by itself ensure old behavior is preserved. |
| Modular or expert-based models | Add or route to components for new capabilities. | More inference, routing, and deployment complexity. |
| Retrieval and external memory | Add or update facts in an indexed store without changing model weights. | Retrieval quality, access controls, freshness, and grounding become critical. |
| Periodic retraining | Rebuild from a curated, mixed dataset and validate a new version. | More expensive and slower, but can provide a clearer release and rollback process. |

### A responsible production workflow

1. Define whether the need is new factual knowledge, changed behavior, or a new task; select retrieval, fine-tuning, or retraining accordingly.
2. Curate and version data with provenance, licensing, privacy controls, and contamination checks.
3. Keep a representative regression suite for previous capabilities, safety, and important edge cases.
4. Train a candidate and compare it with the current model on both new-task metrics and regression evaluations.
5. Deploy through staged rollout, monitor drift and failures, preserve rollback capability, and retain the prior model and data lineage.

Continual learning should not be assumed to happen merely because a deployed model sees conversations. A model only changes if the system deliberately updates its weights or persistent external state, and both mechanisms need explicit governance.

### Concise interview answer

“Continual learning means adapting a model to sequentially arriving data or tasks while retaining earlier capabilities. The central difficulty is catastrophic forgetting: updating on new examples can degrade prior behavior. Approaches include replay, regularization, parameter-efficient adapters, modular components, and periodic retraining. If the requirement is only to make current facts available, retrieval or an external memory is often safer than changing weights. In production I would version data and models, test both new performance and regressions, monitor drift, and provide staged rollout and rollback.”

### Revision summary

| Idea | Remember |
|---|---|
| Goal | Learn new tasks/data while retaining old capabilities. |
| Main failure | Catastrophic forgetting. |
| Techniques | Replay, regularization, adapters, modularity, retraining. |
| Alternative | Retrieval for changing knowledge without weight updates. |
| Operations | Provenance, regression tests, monitoring, staged rollout, rollback. |

<br><br><br>

## What is Recursive Self-Improvement (RSI)?

**Answer:**

### Definition and careful framing

**Recursive self-improvement (RSI)** describes a hypothetical or engineered feedback loop in which an AI system contributes to improving a later version of itself, and that improved version can contribute to further improvements. The word “recursive” refers to repeated improvement cycles, not simply a model reflecting on its answer once.

The term covers a wide range of claims. It is useful to distinguish present-day automation of bounded development tasks from stronger claims that an AI system can autonomously and reliably improve its own general intelligence. The latter is not established by a model generating code, passing a benchmark, or assisting researchers.

### What a bounded loop could look like

1. A system proposes a change—for example, a code optimization, data curation rule, or training configuration.
2. Sandboxed tools run tests, static checks, benchmarks, and security evaluations.
3. Human reviewers or predefined gates approve, reject, or revise the candidate.
4. A versioned candidate is deployed to a controlled environment and monitored.
5. Evidence informs a subsequent development cycle.

This is an **AI-assisted engineering loop** when proposals and experiments are automated but humans, fixed objectives, and external evaluation remain in control. It does not imply the system independently changes its own objectives, obtains resources, or safely deploys arbitrary modifications.

### Why improvement is difficult to establish

- **Metric overfitting:** A system may optimize the measured benchmark while degrading real-world performance.
- **Evaluation dependence:** If it can see or influence the evaluator, apparent progress may reflect leakage or reward hacking.
- **Distribution shift:** A change can help selected tasks while harming capabilities or safety elsewhere.
- **Causal attribution:** Reproducible experiments are needed to show that a change caused improvement.
- **Human and compute bottlenecks:** Data quality, hardware, experiment time, and validation may limit the rate of progress.
- **Compounding failures:** Automated changes can propagate bugs or vulnerabilities unless isolated and reversible.

### Engineering safeguards for bounded systems

Use isolated sandboxes, least-privilege tool access, immutable logs, reproducible builds, held-out evaluations, independent review, resource limits, staged deployment, and rollback. Keep the system unable to alter its evaluation criteria or bypass approval gates. Measure capability, reliability, safety, cost, and robustness together rather than relying on one score.

### Concise interview answer

“Recursive self-improvement is a proposed loop where an AI system helps create an improved successor that can help with later improvements. Today, it is important to separate bounded AI-assisted engineering—such as proposing code changes that are sandbox-tested and reviewed—from stronger claims of autonomous, general intelligence takeoff, which are not demonstrated just by code generation or benchmark gains. The hard parts are reliable evaluation, metric gaming, regressions, security, and causal attribution. Any practical loop needs independent held-out tests, strict permissions, human approval, reproducibility, resource limits, and rollback.”

### Revision summary

| Distinction | Remember |
|---|---|
| RSI | Repeated system-assisted improvement across versions. |
| Not equivalent to | One-shot self-critique, code generation, or a benchmark score increase. |
| Evidence needed | Reproducible, independent evaluation across capabilities and risks. |
| Risks | Metric gaming, regressions, security issues, unbounded resource use. |
| Safeguards | Sandboxes, permissions, human gates, logs, staged rollout, rollback. |

<br><br><br>

## How do Diffusion Language Models (DLMs) work?

**Answer:**

### Core idea

A **diffusion language model (DLM)** adapts the diffusion principle—iteratively denoising a corrupted sample—to discrete text tokens or other discrete representations. Instead of always generating one token after another from left to right, a common DLM formulation starts with a sequence that is partly or fully masked/corrupted and repeatedly predicts or refines multiple positions.

“DLM” is not one single architecture or decoding algorithm. Discrete diffusion models differ in their corruption process, parameterization, training loss, and sampling procedure; some related methods operate on continuous embeddings rather than directly on discrete tokens.

### Training and inference at a high level

1. **Corrupt data:** Select a noise level or timestep and apply a transition such as masking or replacing tokens.
2. **Learn to reverse corruption:** Train a neural model to predict clean tokens, the corruption/noise, or a reverse transition from the noisy sequence and timestep.
3. **Initialize generation:** Start from a highly corrupted or masked sequence, often with a target length or a mechanism to determine length.
4. **Iteratively denoise:** Predict and reveal, revise, or sample tokens over several refinement steps.
5. **Stop:** Return the final sequence when the sampling schedule is complete or a stopping criterion is met.

Because multiple positions may be updated together, the method can expose parallelism across positions. However, each refinement step may still require a model call, and the number of steps, sequence length, and implementation determine actual latency and compute.

### Comparison with autoregressive generation

| Dimension | Autoregressive LM | Diffusion LM |
|---|---|---|
| Typical generation | Append next token from a prefix. | Iteratively refine a noisy or masked sequence. |
| Conditioning | Naturally left-to-right. | Can condition on both sides or global sequence structure, depending on the method. |
| Parallelism | Token generation is sequential, though prompt prefill is parallel. | Multiple positions may be refined in a step. |
| Editing/infill | Requires specialized methods or prompting. | Iterative denoising can naturally support infilling or revision in some designs. |
| Complexity | Mature training and serving ecosystem. | Sampling schedules and discrete reverse processes add design complexity. |

Parallel position updates do not automatically make a DLM faster: multiple denoising iterations can be expensive, and autoregressive serving benefits from optimized kernels and KV caching. Performance must be measured at matched quality and output length.

### Strengths and open challenges

Potential benefits include iterative refinement, flexible infilling, and opportunities for parallel token updates. Challenges include designing effective discrete corruption and reverse processes, controlling output length, achieving high-quality few-step sampling, and building competitive training and serving infrastructure. As with other models, output quality and safety require task-specific evaluation.

### Concise interview answer

“A diffusion language model learns to reverse a corruption process on text. During training, tokens are masked or otherwise noised at different timesteps and the model learns to recover clean text or the reverse transition. At inference it starts from a noisy sequence and iteratively denoises, potentially refining several positions per step rather than strictly appending one token at a time. This can support parallel refinement and infilling, but each denoising iteration costs compute, so it is not automatically faster than a well-optimized autoregressive model. DLMs are a family of formulations, so I would specify the corruption and sampling method when comparing results.”

### Revision summary

| Stage | Remember |
|---|---|
| Forward/noising | Corrupt or mask clean tokens. |
| Training | Learn clean-token prediction or reverse transitions at timesteps. |
| Sampling | Initialize noisy sequence, then iteratively denoise/refine. |
| Potential advantage | Parallel position refinement and flexible infilling. |
| Caveat | Multiple steps cost compute; “DLM” covers varied methods. |

<br><br><br>

## How Does LLM Watermarking Work?

**Answer:**

### Goal and basic mechanism

**LLM watermarking** embeds a detectable statistical signal in generated text so that, given an appropriate detector and sometimes a secret key, one can estimate whether text likely came from a particular generation system or process. A common token-level approach subtly biases token selection during generation—for example, favoring a keyed subset of candidate tokens at each step—so that the output contains a measurable statistical pattern.

The signal is typically designed to be hard to notice while remaining detectable across enough generated tokens. Detection estimates evidence for or against the watermark; it does not reveal the model’s full provenance with certainty.

### Watermarking approaches

- **Generation-time statistical watermark:** Modify token sampling using a secret key or pseudorandom token partition, then test generated tokens for the expected bias.
- **Watermark in a representation or output channel:** Embed a signal in formats such as images or audio; these methods are modality-specific and are not the same as a text-token watermark.
- **Provenance metadata or signatures:** Attach verifiable metadata to content. This can provide stronger attribution when preserved, but metadata may be stripped and requires a trusted signing and verification process.

These are related provenance strategies, but “watermarking” does not guarantee that all AI-generated content is marked or that all marked content can be attributed to one model.

### Detection and limitations

A statistical detector may compute a score such as the excess frequency of favored tokens relative to a null expectation, then report a thresholded confidence or p-value. Interpretation depends on detector assumptions, the key, tokenization, sample length, and whether the text was transformed.

| Factor | Effect |
|---|---|
| Short text | Too few tokens for a reliable statistical signal. |
| Paraphrasing or translation | Can weaken, remove, or distort the pattern. |
| Editing and mixed authorship | Makes attribution ambiguous. |
| Sampling settings and model changes | May change detectability or false-positive rates. |
| Public detector/key leakage | Can enable evasion or imitation. |
| Human-written text | A statistical detector can still make false-positive errors. |

Watermarks can also impose quality or diversity costs if the sampling bias is too strong. A detector should be calibrated on representative human and generated text, report uncertainty, and avoid treating a score as proof of authorship.

### Responsible use

Use watermarking as one signal in a broader provenance and content-integrity system, not as the sole basis for high-stakes decisions. Communicate false-positive and false-negative risks, protect keys, test robustness to ordinary editing and adversarial transformations, and keep human review for consequential attribution.

### Concise interview answer

“A text watermark introduces a subtle, usually keyed statistical bias into token generation and uses a detector to test whether the resulting text has the expected pattern. Detection is probabilistic: it needs enough text and can be weakened by paraphrasing, translation, editing, or key leakage, and it can produce false positives. Watermarks may also trade off against text quality. I treat them as one provenance signal alongside signed metadata and operational records, calibrate detectors on realistic data, and never treat a watermark score alone as proof of authorship.”

### Revision summary

| Point | Remember |
|---|---|
| Purpose | Statistical evidence of a generation process, not guaranteed proof. |
| Mechanism | Often bias token selection using a secret/keyed pattern. |
| Detector | Tests for a statistically unusual token pattern. |
| Weaknesses | Short text, paraphrase, editing, key leakage, false positives. |
| Practice | Combine with provenance controls; communicate uncertainty. |

<br><br><br>

## How do RNNs and Transformers differ?

**Answer:**

### Architectural difference

A **recurrent neural network (RNN)** processes a sequence one step at a time, carrying a hidden state from earlier steps to later ones. At position \(t\), the state is updated from the current input and previous state:

\[
h_t=f(x_t,h_{t-1})
\]

A **Transformer** uses attention to compute contextual representations by relating positions in a sequence. In a decoder-only language model, a causal mask restricts each position to attend only to itself and earlier positions; encoder-style Transformers can attend bidirectionally.

### Practical comparison

| Dimension | RNN | Transformer |
|---|---|---|
| Sequence processing | Recurrent dependency across time steps. | Attention across positions, subject to masks. |
| Training parallelism | Limited across sequence positions because each state depends on the previous one. | Many position computations can be parallelized during training. |
| Long-range dependencies | Can be difficult to retain; gradients may vanish or explode, though LSTM/GRU gates help. | Direct attention paths help model relationships, subject to context and compute limits. |
| Inference | Sequential state update; compact state can be efficient for streaming. | Autoregressive decoding is sequential across new tokens; KV caching avoids recomputing prior keys/values. |
| Compute and memory | Often linear in sequence length with compact recurrent state. | Standard full attention has quadratic sequence-length compute and memory during prefill. |
| Typical use | Streaming/time-series and compact sequence models. | Modern large-scale language and multimodal models. |

These are general tendencies. Optimized attention, linear-attention variants, recurrent memory, and hybrid architectures change particular trade-offs. RNNs do not inherently have a fixed-size context in every possible implementation, and Transformers do not inherently process an unbounded sequence.

### Choosing between them

For large-scale language modeling, Transformers are effective because training can parallelize across tokens and attention provides flexible contextual interactions. For tight-memory streaming tasks or small devices, a recurrent or hybrid model may be attractive because it can maintain a compact state. The right comparison includes end-to-end accuracy, latency, throughput, memory, sequence length, and hardware—not architecture labels alone.

### Concise interview answer

“An RNN updates a hidden state sequentially, so each time step depends on the previous state; this gives a compact streaming state but limits parallelism across a training sequence and can make long-range learning difficult. A Transformer uses attention to connect positions, enabling much more parallel training and flexible context, but standard full attention has quadratic prefill cost and autoregressive decoding still proceeds token by token. KV caching helps inference. Transformers dominate many large language models, while RNNs and hybrids can still suit compact or streaming workloads. I choose based on measured quality, latency, memory, and sequence requirements.”

### Revision summary

| Architecture | Core mechanism | Key trade-off |
|---|---|---|
| RNN | Recurrent hidden state \(h_t=f(x_t,h_{t-1})\). | Compact state, sequential computation. |
| Transformer | Attention across positions. | Parallel training, costly full attention at long lengths. |
| RNN long-range support | LSTM/GRU gates help preserve information. | Not a guarantee of unlimited memory. |
| Transformer inference | Causal generation plus KV cache. | New tokens still decode sequentially. |
| Selection | Evaluate on target hardware and workload. | Do not choose on architecture name alone. |

<br><br><br>
