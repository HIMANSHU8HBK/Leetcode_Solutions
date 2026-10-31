# 06. Vector Databases and Embeddings

Source entries are in their original order. Use the space after each heading to draft an answer.

## What are embeddings in the context of AI engineering?

**Answer:**

### Definition and purpose

An **embedding** is a numeric representation of an item—such as text, an image, audio, or a user/product—that maps it to a vector in a learned space. The representation is useful when relationships relevant to a task are reflected in vector geometry: items with related meanings or functions may be closer under a chosen similarity or distance measure.

In AI engineering, embeddings are commonly used to retrieve semantically related documents, cluster or classify content, deduplicate items, recommend candidates, or compare multimodal inputs. For text retrieval, an embedding model encodes a query and candidate passages; a search system ranks vectors using a compatible metric, often followed by metadata filtering or reranking.

### Important qualifications

Embedding similarity is not a guarantee of factual correctness, entailment, or relevance to every query. Results depend on the model’s training objective, domain, language, input formatting, chunking, and distance metric. A semantically nearby passage may still be outdated, contradictory, or not answer the question. Evaluate retrieval on representative queries and use evidence-grounded generation, filters, or reranking where the application requires them.

### Concise interview answer

“An embedding is a learned vector representation of an item. Its geometry is trained so that relationships useful for a task—often semantic similarity—can be measured with operations such as cosine similarity or dot product. Embeddings support retrieval, clustering, classification, and recommendations, but closeness is only a relevance signal, not proof of truth or entailment. I choose and evaluate the model, preprocessing, and metric against the actual use case.”

### Revision summary

| Concept | Takeaway |
|---|---|
| Representation | An item encoded as a vector. |
| Geometry | Similarity/distance approximates relationships learned for a task. |
| Uses | Retrieval, clustering, classification, deduplication, recommendations. |
| Limitation | Similarity is not truth, entailment, or guaranteed relevance. |

<br><br><br>

## How do embedding models convert text to vectors?

**Answer:**

### Typical encoding path

An embedding model converts text through a learned pipeline; exact details vary by architecture and provider:

1. **Normalize and format the input:** Apply the model’s expected query/document prefixes, separators, or instruction format when specified. Avoid arbitrary transformations that change meaning.
2. **Tokenize:** Convert text into token IDs using the model’s tokenizer, often with special tokens and a maximum sequence length. Long inputs may be truncated or must be split into chunks according to the application’s strategy.
3. **Compute contextual representations:** A neural encoder (commonly a Transformer) processes token embeddings with positional information and contextual layers, producing hidden-state vectors for tokens.
4. **Pool to a fixed-size vector:** Combine token states using the architecture’s prescribed method, such as a designated token, mean pooling with an attention mask, or another pooling head.
5. **Project and optionally normalize:** A trained projection may produce the final embedding dimension. Some models normalize vectors to unit length; this must match how the model is intended to be searched.

The result is a fixed-dimensional vector for the input text, not a literal dictionary definition or a guarantee that every semantic relation is encoded. Training determines which distinctions the space captures.

### Consistency is essential

Use the same model version, tokenizer, input conventions, pooling, and normalization for corpus documents and queries unless the model explicitly provides different query/document encoders. Keep track of model/version and preprocessing so embeddings can be reproduced. Changing any of these can shift the vector space, which may require re-embedding and rebuilding or migrating the index. Select the similarity metric expected by the model; cosine and dot product rank equivalently only under particular normalization conditions.

### Concise interview answer

“The text is formatted as required, tokenized, and passed through a neural encoder that produces contextual token states. The model then pools those states—using its specified pooling method—and may project or normalize the resulting vector. Token limits and prefixes matter. I use consistent model versions and preprocessing for documents and queries and match the search metric to the model’s training and normalization, then evaluate retrieval quality end to end.”

### Revision summary

| Stage | Operation |
|---|---|
| Input preparation | Model-specific formatting and tokenization. |
| Encoding | Contextual neural representations for tokens. |
| Pooling | Convert token states to one fixed-size vector. |
| Output | Optional projection/normalization; fixed-dimensional embedding. |
| Operational rule | Keep model, preprocessing, and metric consistent across indexing and querying. |

<br><br><br>

## What is Contrastive Learning, and how is it used to train embedding models?

**Answer:**

### Core idea

**Contrastive learning** trains a representation model by bringing related examples closer in its embedding space and separating unrelated examples. For text embeddings, a positive pair might be a query and a passage that answers it; negatives might be passages that are irrelevant to that query. The exact definition of a “positive” or “negative” comes from the task and training data.

A common training setup encodes both members of each pair, computes a similarity score (often cosine similarity or dot product), and applies a contrastive objective such as InfoNCE. The loss increases the score of positive pairs relative to other candidates in the batch or an explicit negative set. In-batch negatives make training efficient, but can include false negatives—examples that are actually relevant.

### Why it helps retrieval

At inference, queries and documents can be encoded independently and compared efficiently. If training pairs represent the target retrieval task, the model learns a space in which relevant candidates tend to rank above irrelevant ones. Hard negatives—plausible but non-answering candidates—can teach useful distinctions, provided they are checked for accidental relevance.

Contrastive training is only as good as its pair construction, negative sampling, and evaluation. It may learn shortcuts from duplicate text, source artifacts, or biased labels. Evaluate on held-out queries and realistic candidates, inspect false negatives and hard negatives, and measure ranking quality rather than relying only on training loss.

### Concise interview answer

“Contrastive learning teaches an embedding model to assign higher similarity to related pairs than to unrelated ones. For retrieval, I can train on query-passage positives and sampled negatives using a contrastive loss such as InfoNCE. This shapes the vector space so relevant passages rank well at inference. The quality depends on representative positives and careful negative sampling—especially avoiding false negatives—and I validate with held-out retrieval metrics and error analysis.”

### Revision summary

| Component | Role |
|---|---|
| Positive pair | Example relationship the model should retrieve or recognize. |
| Negative candidates | Teach the model which alternatives should rank lower. |
| Contrastive loss | Rewards positive similarity relative to negatives. |
| Main data risk | False negatives, shortcuts, and biased pair construction. |
| Evaluation | Held-out ranking metrics and retrieval error analysis. |

<br><br><br>

## What is the difference between sparse and dense embeddings?

**Answer:**

### Representation and matching

**Sparse representations** assign weights to a large vocabulary or feature space, with most dimensions zero. A classic example is TF-IDF; learned sparse models such as expansion-based retrievers can also assign weights to terms. Matching commonly relies on shared weighted terms, which makes the contribution of particular words relatively interpretable.

**Dense embeddings** are typically fixed-size, lower-dimensional vectors with most values nonzero. A neural model maps text into a continuous space where semantically related inputs can be close even when they do not share exact terms.

| Property | Sparse | Dense |
|---|---|---|
| Main matching signal | Weighted token/feature overlap. | Learned vector similarity. |
| Strength | Exact terms, identifiers, rare names, lexical transparency. | Paraphrases and semantic similarity. |
| Typical weakness | Vocabulary mismatch and limited synonym handling unless expansion is learned. | May miss exact strings or blur distinctions such as codes and numbers. |
| Storage/search | Inverted indexes are common; cost depends on nonzero postings. | Vector index/storage; cost depends on dimensions and index design. |

These are tendencies rather than absolutes: learned sparse systems can generalize, and dense systems can handle lexical retrieval when trained well. Many production systems combine both through **hybrid search**, then fuse or rerank their candidate lists.

### Concise interview answer

“Sparse embeddings represent text with weights on vocabulary or feature dimensions, usually mostly zero, so retrieval is driven by weighted term overlap. Dense embeddings use compact, mostly nonzero vectors and a learned similarity space, which helps match paraphrases. Sparse retrieval is strong for exact terms and identifiers; dense retrieval is strong for semantic matches. Because they fail differently, I often evaluate hybrid retrieval and choose based on the query and corpus.”

### Revision summary

| Type | Useful when | Typical retrieval |
|---|---|---|
| Sparse | Exact terms, rare words, codes, transparent lexical matches. | Inverted index / weighted term scoring. |
| Dense | Semantic similarity and paraphrases. | Nearest-neighbor vector search. |
| Hybrid | Queries need both exact and semantic evidence. | Candidate fusion or reranking. |

<br><br><br>

## Explain cosine similarity, dot product, and Euclidean distance for vector search.

**Answer:**

### The three measures

For vectors \(x,y\in\mathbb{R}^d\):

- **Dot product:** \(x\cdot y=\sum_i x_i y_i\). It increases with directional agreement and vector magnitudes. Magnitude can therefore affect ranking.
- **Cosine similarity:** \(\frac{x\cdot y}{\|x\|\|y\|}\). It measures angular alignment and ignores overall magnitude. It is undefined for a zero vector, which systems must handle explicitly.
- **Euclidean distance (L2):** \(\|x-y\|_2=\sqrt{\sum_i(x_i-y_i)^2}\). Smaller distance means closer vectors and is affected by both direction and magnitude.

### When rankings are equivalent

If all compared vectors are unit-normalized, cosine similarity equals the dot product. Also, for unit-normalized \(x\) and \(y\),
\[
\|x-y\|_2^2=2-2(x\cdot y),
\]
so maximizing dot product/cosine is equivalent to minimizing Euclidean distance. Without the relevant normalization, these measures can rank candidates differently.

Use the metric expected by the embedding model and the vector index; do not normalize vectors automatically if magnitude is meaningful or the model’s training objective expects unnormalized dot products. Check the database API’s convention: some indexes expose distance (lower is better), while applications may report a similarity score (higher is better). Benchmark ranking quality with the chosen metric and verify normalization and zero-vector handling.

### Concise interview answer

“Dot product measures aligned components and is magnitude-sensitive. Cosine similarity normalizes by vector lengths, so it measures direction. Euclidean distance measures straight-line separation and is lower for closer vectors. For unit-normalized vectors, cosine and dot-product rankings agree, and Euclidean distance gives an equivalent ranking through the squared-distance identity. I match the metric and normalization to how the model was trained and the index is configured.”

### Revision summary

| Metric | Interpretation | Ranking convention |
|---|---|---|
| Dot product | Alignment plus magnitude. | Larger is more similar. |
| Cosine | Angular alignment. | Larger is more similar. |
| Euclidean/L2 | Straight-line separation. | Smaller is closer. |
| Unit-normalized vectors | Cosine = dot product; L2 ranking is equivalent. | Verify model/index assumptions. |

<br><br><br>

## What is a vector database, and how does it differ from a traditional database?

**Answer:**

### Definition

A **vector database** stores vectors and associated records or metadata, and supports similarity search to find the nearest candidates to a query vector. It commonly provides vector indexes (often approximate nearest-neighbor indexes), metadata filtering, persistence, updates, and operational features such as replication or access control. Exact capabilities vary by product; a vector database may be purpose-built or a vector-search feature in a broader database.

### Comparison with traditional databases

A traditional relational database is optimized for structured records, transactions, exact predicates, joins, and constraints. A full-text search engine is optimized for term-based retrieval. Vector search instead ranks records by distance or similarity in an embedding space. These systems solve different retrieval problems and often coexist:

| Requirement | Commonly suitable system capability |
|---|---|
| Exact IDs, transactions, relational constraints | Relational/transactional database. |
| Lexical term matching | Full-text/inverted-index search. |
| Semantic nearest-neighbor retrieval | Vector index or vector database. |
| Combined retrieval | Hybrid search or coordinated systems with candidate fusion. |

A vector database does not understand meaning on its own; the embedding model defines the representation. Similarity scores are not automatically calibrated probabilities or evidence of factual support. Production design still needs tenant isolation, metadata/index consistency, backup and recovery, filtering semantics, deletion handling, and measured recall/latency.

### Concise interview answer

“A vector database stores embeddings with records or metadata and retrieves nearest neighbors under a chosen metric, usually through an ANN index. A traditional relational database excels at exact queries, transactions, joins, and constraints; full-text search excels at lexical matching. Vector search addresses semantic similarity, but depends on the embedding model and does not guarantee correctness. Many systems combine these stores or retrieval modes and evaluate their operational and ranking trade-offs.”

### Revision summary

| System | Primary strength |
|---|---|
| Relational database | Structured data, transactions, exact predicates, joins. |
| Full-text search | Token/term matching and lexical ranking. |
| Vector database/index | Similarity search over embedding vectors. |
| Key caveat | Embeddings and indexes do not replace data governance or relevance evaluation. |

<br><br><br>

## How does Approximate Nearest Neighbor (ANN) search work?

**Answer:**

### Exact nearest-neighbor search

Given a query vector and \(N\) stored vectors, exact search computes the selected distance or similarity to every candidate and returns the best \(k\). This gives an exact ranking under that metric, but typically requires work proportional to \(N\) times the vector dimension per query, which can be costly at scale.

### Approximate search

**Approximate Nearest Neighbor (ANN)** indexes organize vectors so queries can inspect a promising subset rather than scan the entire collection. Depending on the index family, the system may navigate a graph of nearby vectors, probe selected clusters/lists, or use another compressed/search structure. It then scores the candidates it visits and returns the top \(k\) among those candidates.

ANN trades some recall for lower latency, memory, or compute. It can miss a true exact neighbor because the search is incomplete; the returned candidates are not necessarily the exact global top \(k\). Common controls include index construction parameters and query-time search breadth, but parameter names and behavior differ by implementation.

### How to use it responsibly

Build an exact-search baseline on a representative sample or benchmark where feasible, then compare ANN’s recall@k and latency at realistic query rates, filters, and data distributions. Tune search effort against a target quality/latency budget; increase effort if recall is too low, or improve indexing, filtering, sharding, or candidate reranking if latency is too high. Track memory, build time, update behavior, and tail latency as well as average query speed.

### Concise interview answer

“ANN uses an index to search a promising subset of vectors instead of comparing the query with every vector. Index families may navigate proximity graphs or probe selected partitions; the candidates are then ranked with the configured distance metric. This reduces query cost at the price of possible missed neighbors. I benchmark recall@k against exact search and tune search breadth for the production latency, memory, filter, and throughput requirements.”

### Revision summary

| Search mode | Result | Trade-off |
|---|---|---|
| Exact k-NN | True top \(k\) under the metric. | Typically scans all candidates. |
| ANN | Approximate top \(k\). | Faster/cheaper potential, but may lose recall. |
| Evaluation | Compare to exact baseline. | Measure recall@k, latency, throughput, memory, and filtered behavior. |

<br><br><br>

## Compare HNSW, IVF, and flat indexes. How do you pick one, and what does recall@k cost in latency?

**Answer:**

### Index choices

- **Flat (exact) index:** Scores every vector and returns the true nearest neighbors under the configured metric. It is the simplest baseline and avoids ANN recall loss, but query work grows with the collection size and vector dimension.
- **HNSW (Hierarchical Navigable Small World):** Builds a multi-layer proximity graph and searches by navigating links toward likely neighbors. It often offers strong query speed and recall, at the cost of graph memory and index-build/update work. Behavior depends on implementation and parameters such as graph connectivity and query search breadth.
- **IVF (Inverted File):** Clusters vectors into coarse partitions and searches selected lists near the query’s assigned centroid(s). It can reduce the number of vectors scored, and often supports compressed variants, but recall depends on the partitioning and how many lists are probed. Training/building the quantizer and handling skew or changing distributions are considerations.

| Index | Search approach | Typical trade-off |
|---|---|---|
| Flat | Scan all vectors exactly. | Highest exactness; query cost scales with collection size. |
| HNSW | Navigate a proximity graph. | Strong recall/latency potential; larger graph memory and build cost. |
| IVF | Probe selected coarse clusters. | Lower candidate count and optional compression; recall depends on probes and partition quality. |

### Choosing and tuning

Start with flat search on a representative dataset or sample to establish the exact top-\(k\) baseline. Then benchmark index candidates against the actual vector count, dimension, update rate, filters, concurrency, and hardware. Measure recall@k alongside p50/p95/p99 latency, throughput, memory, build time, and update cost. A higher recall target usually requires more search work—such as broader graph exploration or probing more IVF lists—so latency and compute can increase, though the exact curve is workload- and implementation-dependent.

Choose the index that satisfies the application’s minimum recall and latency SLOs within memory and operational constraints. Validate filtered queries separately because filters can change both candidate availability and search behavior. Do not select solely from a generic rule such as “HNSW is always best”; production measurements decide.

### Concise interview answer

“Flat search is exact but scans all vectors. HNSW searches a proximity graph and can give high recall with low latency, using more memory and build effort. IVF searches selected coarse clusters, reducing candidates but requiring tuning of list probes and partition quality. I establish a flat-search baseline, then benchmark recall@k, tail latency, memory, updates, filters, and throughput on representative production workloads. Raising recall generally costs additional search work, so I choose against explicit SLOs rather than a universal index preference.”

### Revision summary

| Decision input | Why it matters |
|---|---|
| Collection size and dimensions | Determine exact-scan and index costs. |
| Memory budget | Often limits graph or uncompressed structures. |
| Recall/latency SLO | Sets acceptable ANN search effort. |
| Filters and updates | Can alter index behavior and operational fit. |
| Benchmark | Compare exact baseline and ANN under production-like load. |

<br><br><br>

## How does an Embedding Cache work?

**Answer:**

### Basic operation

An **embedding cache** stores the vector computed for a previously seen input so the system can reuse it instead of invoking the embedding model again. The request is normalized into a cache key; on a hit, the cached vector is returned, and on a miss, the input is embedded and the result is stored subject to the cache policy.

The key must capture every factor that can change the embedding: canonical input text, model and version, tokenizer or preprocessing version, query/document mode or instruction prefix, and any relevant normalization/configuration. A key based only on raw text can return stale or incompatible vectors after a model or preprocessing change. Cache entries also need an appropriate TTL or invalidation policy, size/eviction strategy, and observability for hit rate, latency, cost, and errors.

### Correctness and privacy

Canonicalization should be conservative: stripping harmless whitespace may be safe for a particular pipeline, but lowercasing, punctuation removal, or other transformations can change meaning or the model input. Keep tenant or access scope in the key or cache boundary when isolation requires it. Do not let a shared cache expose one tenant’s sensitive input or derived embedding to another tenant. Encrypt and retain cached data according to the system’s data policy; embeddings can still encode information about their source.

### Concise interview answer

“An embedding cache maps a canonicalized input and its embedding configuration to a stored vector. A cache hit avoids repeated model inference, reducing latency and embedding cost; a miss computes and stores the vector. The key must include model/version and preprocessing details, and the system needs TTL or invalidation, bounded eviction, and hit-rate monitoring. I also preserve tenant isolation and treat cached text and vectors as governed data.”

### Revision summary

| Element | Responsibility |
|---|---|
| Cache key | Include input and all embedding-version/configuration details. |
| Hit/miss | Reuse the vector or compute and store it. |
| Invalidation | Expire entries when model or preprocessing changes. |
| Operations | Bound memory; track hit rate, cost, latency, and errors. |
| Safety | Enforce tenant boundaries and data-retention controls. |

<br><br><br>

## How do you choose the right embedding model for your use case?

**Answer:**

### Choose against the retrieval task

There is no universally best embedding model. Start by specifying what “relevant” means for the application: query and document types, languages, corpus size and domain, expected query style, metadata constraints, freshness, latency budget, and whether vectors must remain in a particular hosting environment.

### Selection process

1. **Build a representative evaluation set:** Collect real or carefully designed queries, relevant passages, graded judgments where possible, and difficult negatives. Split so near-duplicates and source leakage do not inflate results.
2. **Check task fit:** Compare models on retrieval metrics such as Recall@k, MRR, or nDCG at the values that matter to the downstream application. Evaluate relevant language, domain, short/long queries, and document lengths.
3. **Use the documented interface correctly:** Apply required query/document prefixes, tokenizer limits, chunking, and similarity metric. Some models use asymmetric query and passage encoding.
4. **Measure system constraints:** Record embedding dimension, inference latency/throughput, memory and index footprint, rate limits, cost, batch behavior, deployment/privacy requirements, and version stability.
5. **Test end-to-end:** Evaluate filtered/hybrid retrieval and reranking or answer quality, not just embedding benchmarks. Inspect false positives and missed relevant candidates.
6. **Plan production updates:** Confirm reproducibility, version pinning, re-embedding strategy, rollback, and monitoring before rollout.

Select the simplest model that meets quality and operational acceptance criteria. A small benchmark lead may not justify a large increase in cost, latency, data-transfer risk, or migration complexity.

### Concise interview answer

“I choose an embedding model by benchmarking it on representative queries and relevance judgments from the actual use case. I compare Recall@k, MRR or nDCG across important slices, then measure end-to-end retrieval quality, latency, throughput, dimension/storage cost, privacy constraints, and versioning. I follow the model’s query/document formatting and metric requirements and plan migration and rollback. Generic leaderboard performance is useful for shortlisting, not a substitute for in-domain evaluation.”

### Revision summary

| Selection dimension | Example check |
|---|---|
| Relevance | Recall@k, MRR, nDCG, error analysis, downstream answer support. |
| Coverage | Domain, language, query length, document length, filters. |
| Operations | Latency, throughput, dimensions, memory, price, hosting. |
| Integration | Prefixes, chunking, metric, versioning, migration/rollback. |

<br><br><br>

## What is embedding dimensionality, and how does it affect performance and cost?

**Answer:**

### Meaning

The **dimensionality** of an embedding is the number of numeric components in its vector. A model that emits a \(d\)-dimensional vector represents each item with \(d\) values. For \(N\) vectors stored with \(b\) bytes per component, the raw vector payload is approximately \(N\times d\times b\) bytes, before IDs, metadata, index structures, replication, and storage overhead.

### Effects and trade-offs

- **Storage and memory:** Higher dimensions increase raw vector storage linearly and often increase index memory.
- **Compute and latency:** Distance calculations involve the dimensions being compared, so larger vectors can increase query and indexing work; actual latency also depends on index, hardware, batching, and implementation.
- **Representation capacity:** More dimensions can provide a richer learned representation, but the dimension alone does not determine quality. Training objective, data, and task fit matter.
- **Bandwidth and cost:** Larger vectors increase movement between storage, memory, and compute and may raise managed-service costs or transfer overhead.

Some models support a trained dimensionality-reduction or truncation option, but arbitrary truncation or projection can harm retrieval quality. Test any dimension change on the target evaluation set. Dimension is part of the vector schema; vectors of different dimensions cannot be directly compared in a standard fixed-dimensional index and should not be mixed as if they shared the same embedding space.

### Concise interview answer

“Embedding dimensionality is the number of values in each vector. Raw storage scales as vector count times dimension times bytes per value, and larger vectors generally increase index memory, distance-computation work, and data movement. More dimensions do not automatically mean better retrieval. I choose a model and dimension by measuring retrieval quality against storage, latency, and cost, and I evaluate any supported dimension reduction rather than truncating blindly.”

### Revision summary

| Effect of larger \(d\) | Practical implication |
|---|---|
| Raw vector payload \(\propto Ndb\) | More storage and memory. |
| More components to compare | Potentially more compute and data movement. |
| Representation capacity may change | Quality must be measured, not inferred from dimension. |
| Schema compatibility | Do not mix incompatible dimensions/spaces in one index. |

<br><br><br>

## How do you handle embedding drift when the embedding model is updated?

**Answer:**

### What changes during an embedding update

An updated embedding model can map the same text to a different vector, even when the output dimension is unchanged. The new vectors may occupy a different space, have different score distributions, or alter nearest-neighbor rankings. Query embeddings from one model generally should not be compared with corpus vectors from another unless compatibility has been explicitly established and validated.

### Safe migration

1. **Version the full embedding pipeline:** Record model identifier/revision, tokenizer, input prefixes, preprocessing, pooling, normalization, and metric.
2. **Build an offline comparison:** Re-embed a representative corpus and query set, measure retrieval metrics and score/ranking changes, and inspect important domain slices.
3. **Create a separate versioned index:** Keep old vectors and the new embedding space isolated; do not overwrite or mix vectors just because dimensions match.
4. **Run shadow or dual reads:** Generate new query vectors and search the new index without affecting users, or compare both systems in a controlled rollout. Keep each query/index pair on the matching model version.
5. **Compare against acceptance criteria:** Evaluate relevance, downstream task quality, latency, cost, and safety-sensitive cases. Investigate regressions before promotion.
6. **Switch and retain rollback:** Promote the new model and index atomically or with explicit routing, preserve the old version for rollback, and monitor production quality.
7. **Retire old assets deliberately:** Remove old indexes or cache entries only after the migration and retention policy allow it.

An output dimension change requires a new compatible index/schema and re-embedding; equal dimensions do not prove compatibility. Cache keys and stored records must include model/version so stale vectors cannot be silently reused.

### Concise interview answer

“I treat an embedding-model update as a vector-space migration. I version the model and preprocessing, re-embed into a separate index, and never mix old document vectors with new query vectors without demonstrated compatibility. I compare retrieval and downstream metrics offline, then shadow or dual-read before switching traffic. I retain the old index for rollback and invalidate caches by version. A matching dimension alone does not make two embedding spaces compatible.”

### Revision summary

| Control | Purpose |
|---|---|
| Pipeline versioning | Reproduce how each vector was produced. |
| Separate index | Prevent incompatible vector spaces from mixing. |
| Offline + shadow evaluation | Detect relevance and operational regressions. |
| Versioned cache/routing | Pair queries with matching corpus vectors. |
| Rollback | Restore known-good retrieval if the update degrades quality. |

<br><br><br>

## What are multi-modal embeddings, and how are they generated?

**Answer:**

### Shared representation across modalities

**Multimodal embeddings** represent content from more than one modality—such as text, images, audio, or video—in vector spaces designed to support comparisons across or within those modalities. A common pattern is a dual encoder: separate modality-specific encoders map inputs into a shared space, and training encourages paired or semantically related items (for example, an image and its caption) to have compatible vectors.

Other systems may fuse modalities earlier or later, use a joint encoder, or produce separate vectors per modality. Video embeddings may be formed from sampled frames, audio segments, transcripts, or combinations with temporal information; the exact approach is model- and task-dependent.

### Training and retrieval

Models are trained on aligned multimodal examples with objectives such as contrastive learning, matching, or supervised task losses. At query time, the system encodes inputs using the appropriate modality path and searches compatible vectors—for example, text-to-image retrieval or image-to-text retrieval. A “shared space” supports cross-modal ranking, but scores and quality still require task-specific evaluation; not every multimodal model supports every cross-modal direction equally well.

Respect input limits, modality preprocessing, timestamps, and model-specific instructions. For mixed-modality documents, preserve links between vectors and their source regions so results can be interpreted and grounded. Evaluate retrieval on actual modalities and scenarios, including captions, OCR-heavy images, audio quality, temporal/video coverage, and cross-modal mismatches.

### Concise interview answer

“Multimodal embeddings encode inputs such as text and images into vectors that can be compared within or across modalities. A common design uses separate encoders trained on aligned pairs with a contrastive objective so matching items are close in a shared space. Other designs fuse modalities or produce modality-specific vectors. I choose the model based on the retrieval direction and evaluate real cross-modal queries; shared vectors do not guarantee equally strong performance for every modality or task.”

### Revision summary

| Component | Role |
|---|---|
| Modality encoder(s) | Convert text, image, audio, video, or other inputs to representations. |
| Alignment objective | Relate paired or semantically matching examples. |
| Shared space | Enable selected cross-modal similarity search. |
| Evaluation | Test actual modality pairs and use cases; do not assume universal alignment. |

<br><br><br>

## How do you index and query multi-tenant data in a vector database?

**Answer:**

### Model the isolation boundary first

Multi-tenant vector search must enforce authorization independently of relevance ranking. Decide whether tenants share a physical index with mandatory filters, use separate namespaces/collections, or require separate database resources. The right choice depends on the threat model, tenant count and size distribution, operational limits, and isolation requirements. A metadata filter is not a security boundary unless the database and application enforce it reliably.

### Indexing and query flow

1. **Attach trusted tenant identity at ingestion:** Derive tenant IDs from authenticated server-side context, not arbitrary client-supplied metadata. Validate ownership and permissions before storing each record.
2. **Choose a partition strategy:** Shared indexes can reduce operational overhead but require strict filters and careful filtering performance. Namespaces or per-tenant indexes can improve isolation and lifecycle management, but may increase resource and index-management costs.
3. **Enforce filtering before results leave the trusted boundary:** Every query must include an authorization-scoped tenant constraint. Validate it server-side; do not rely on the client to provide a correct filter.
4. **Avoid cross-tenant side channels and leakage:** Scope caches and query logs appropriately, limit metadata returned, and test that malicious or malformed filters cannot broaden access. Consider isolation of backups, exports, and deletion paths.
5. **Account for scale skew:** Many small tenants and a few very large tenants may call for a hybrid strategy, such as shared partitions for small tenants and dedicated resources for large or regulated tenants.
6. **Test and monitor:** Add negative authorization tests, audit access, verify tenant deletion and retention, and measure recall/latency under realistic filters and tenant skew.

Filtering can alter ANN candidate behavior and recall, so test filtered search directly. For sensitive workloads, use defense in depth: authenticated identity, server-side authorization, database-level controls, and auditability.

### Concise interview answer

“I start with the tenant isolation and threat model, then choose shared filtered indexes, namespaces, or separate resources based on security and scale. Tenant identity must come from trusted server-side authentication. Every ingestion and query is authorization-scoped, and results are filtered before they can cross the trusted boundary. I test bypass attempts, cache and deletion isolation, and ANN quality under filters, then monitor access and tenant-level performance.”

### Revision summary

| Concern | Control |
|---|---|
| Tenant identity | Set from authenticated server-side context. |
| Isolation choice | Shared filtered index, namespace, or dedicated resource. |
| Query authorization | Enforce tenant scope server-side on every request. |
| Leakage surface | Scope caches, logs, exports, backups, and deletion. |
| Validation | Negative access tests plus filtered recall/latency tests. |

<br><br><br>

## What is quantization of embeddings, and how does it reduce storage costs?

**Answer:**

### Definition and storage effect

**Quantization** represents vector values with fewer bits or a more compact code than the original floating-point representation. For example, storing each component in 8 bits instead of 32 bits reduces the raw vector payload per component from four bytes to one byte, before scale/zero-point metadata, index structures, and implementation overhead. More aggressive schemes may encode vectors into compact codes using learned or data-dependent codebooks.

### Trade-offs

Quantization introduces approximation error. It can reduce memory, storage bandwidth, and sometimes improve search throughput, but may change distances and neighbor rankings. Impact depends on the embedding distribution, quantization method, index, similarity metric, and task. Some systems retain original vectors for reranking a smaller candidate set, trading extra storage/compute for improved final ranking.

### Safe evaluation

1. Establish a full-precision baseline on representative queries.
2. Quantize a copy of the vectors using a method supported by the selected index.
3. Measure recall@k or downstream relevance, latency, throughput, memory, and build cost.
4. Inspect important slices and borderline results; test reranking if recall drops.
5. Promote only if quality remains within acceptance limits and savings are measured in the full index, not just vector payload.

Quantization does not fix a poor embedding model or bad index configuration. Keep a reproducible source or a re-embedding path where storage and retention policies permit.

### Concise interview answer

“Quantization stores embedding components or codes at lower precision, reducing the vector payload and often memory bandwidth. For example, 8-bit components use one quarter of the raw bytes of 32-bit floats, although metadata and index overhead remain. The approximation can change distances and lower recall, so I compare it with a full-precision baseline on real queries, measure end-to-end memory and latency, and consider reranking if quality is affected.”

### Revision summary

| Aspect | Key point |
|---|---|
| Mechanism | Lower precision or compact codes approximate original vectors. |
| Benefit | Reduced vector storage and memory traffic. |
| Cost | Approximation error can change neighbor rankings. |
| Evaluation | Compare recall/relevance and operational metrics with full precision. |
| Mitigation | Rerank candidates or choose a less aggressive quantization. |

<br><br><br>

## How do you benchmark and evaluate embedding model quality?

**Answer:**

### Evaluate retrieval, not just vectors

Embedding quality is task-dependent. Build a benchmark from representative queries and corpus items with relevance judgments—binary or graded—created or reviewed by people who understand the task. Include difficult queries, realistic negatives, language/domain slices, varied lengths, and cases where exact terms matter. Keep evaluation sources and near-duplicates separate from training where possible.

### Metrics and experiment design

- **Recall@k:** Fraction of known relevant items present in the top \(k\); useful when missing a candidate is costly.
- **MRR:** Rewards ranking the first relevant result highly.
- **nDCG@k:** Uses graded relevance and rewards placing highly relevant items near the top.
- **Precision@k:** Fraction of top-\(k\) results judged relevant.
- **Operational metrics:** Query and indexing latency, throughput, memory, and cost.

Compare candidate models using the same corpus, query set, chunking, preprocessing, index settings, filters, and downstream reranker configuration. Where feasible, compare ANN retrieval against exact search to separate embedding/model ranking limitations from ANN recall loss. Evaluate the downstream application too—for RAG, measure evidence support and answer quality, not only nearest-neighbor scores.

Perform error analysis on false positives and misses. A model may score well overall but fail on rare entities, short queries, multilingual inputs, domain terminology, or filtered search. Use a held-out test set for final selection, confidence intervals or repeated runs when appropriate, and version the benchmark so changes are comparable.

### Concise interview answer

“I evaluate embeddings on a representative retrieval benchmark with human relevance judgments, not by inspecting vector distances alone. I compare Recall@k, MRR, nDCG or precision at useful cutoffs, broken down by domain, language, and query type, while measuring latency, throughput, memory, and cost. I hold the corpus and retrieval configuration constant, compare ANN with exact search where possible, and test downstream answer quality and evidence support.”

### Revision summary

| Evaluation layer | What to measure |
|---|---|
| Candidate ranking | Recall@k, MRR, nDCG, Precision@k. |
| Coverage | Domain/language/length/entity slices and hard cases. |
| System | ANN recall, latency, throughput, memory, cost. |
| Application | RAG evidence support and answer quality. |
| Experiment integrity | Human judgments, leakage-resistant holdout, versioned benchmark. |

<br><br><br>

## What is the role of metadata in vector databases?

**Answer:**

### Metadata complements vector similarity

Metadata is structured information stored with a vector or its source record—for example, document ID, tenant, source, author, timestamp, language, category, access policy, or content version. It does not replace the embedding; it gives the retrieval system context for filtering, routing, ranking, display, and governance.

### Common uses

- **Pre-filtering:** Restrict candidates to an authorized tenant, date range, language, document type, or other required scope before or during vector search.
- **Post-filtering and reranking:** Apply business rules, freshness boosts, source preferences, or other ranking adjustments after candidate retrieval. Post-filtering alone can return too few results if the initial candidate set is small.
- **Result handling:** Return IDs, titles, source links, timestamps, or other fields needed to present and ground retrieved content.
- **Operations and lifecycle:** Track source versions, ingestion status, deletion/tombstone state, and provenance for updates, audits, and cleanup.

### Design and correctness

Keep metadata typed, normalized, and limited to fields that support real query or operational needs. Validate it at ingestion; inconsistent types and missing values can produce unreliable filters. Index metadata fields used frequently, but measure the storage and write cost of additional indexes. Enforce authorization with trusted server-side identity and database/application controls—metadata filters are not automatically a security boundary.

For RAG, preserve provenance and document/chunk relationships so retrieved text can be traced to its source and version. Keep metadata filters consistent with the vector index and test filtered recall, latency, tenant isolation, updates, and deletion. Avoid copying unnecessary sensitive data into metadata.

### Concise interview answer

“Metadata adds structured context to vectors. It lets the system filter by tenant, date, language, or document type; return source information; apply business ranking; and manage updates and deletion. I validate and type metadata at ingestion, index only useful filter fields, preserve provenance, and test filtered search performance. For access control, I enforce trusted server-side authorization rather than treating an arbitrary metadata filter as sufficient security.”

### Revision summary

| Metadata role | Example |
|---|---|
| Filtering | Tenant, date, language, category, access scope. |
| Ranking | Freshness or source preference. |
| Result context | Document ID, title, source URL, version. |
| Lifecycle | Ingestion state, update/deletion tracking. |
| Design guardrail | Validate types, minimize sensitive fields, enforce authorization separately. |

<br><br><br>

## How do you handle large-scale vector search with billions of vectors?

**Answer:**

### Design for the workload, not just the vector count

At billion-vector scale, begin by characterizing vector dimension and precision, query rate and concurrency, latency/recall SLOs, update/delete rate, tenant/filter patterns, data locality, and availability requirements. Estimate raw vector storage (\(N\times d\times\) bytes per component), then budget separately for ANN structures, metadata, replication, logs, and rebuild capacity. The index can require substantial additional memory or disk beyond the raw payload.

### Scaling approach

1. **Choose and benchmark an index:** Compare supported ANN families and compression/quantization options against an exact or high-recall baseline on representative samples. Measure filtered recall and tail latency, not just unfiltered average latency.
2. **Partition and shard deliberately:** Partition by a query-relevant key (such as tenant, region, or time) when it reduces search scope without creating extreme skew. Shard to fit storage and throughput requirements; account for scatter/gather cost when a query must fan out.
3. **Use a tiered storage strategy:** Keep hot index structures or frequently accessed data in memory when the SLO requires it, and use SSD/object-backed or compressed tiers where the system supports them. Validate the latency impact of cache misses and cold partitions.
4. **Reduce data and dimension where justified:** Deduplicate, expire obsolete records, use appropriate chunking, and evaluate lower-dimensional or quantized representations. Verify quality impact before adopting compression.
5. **Optimize retrieval stages:** Apply safe metadata prefilters, retrieve a candidate set sized to meet recall needs, and optionally rerank a smaller set with a more expensive model.
6. **Plan ingestion and lifecycle:** Use batch/vectorized ingestion, idempotent writes, incremental index maintenance, and capacity for compaction, rebuilds, rebalancing, and backfills. Avoid full rebuilds as the only update strategy if the required freshness cannot tolerate them.
7. **Operate for resilience:** Monitor per-shard recall/latency, skew, resource utilization, replication lag, and failures. Test backup/restore, failover, rebalancing, and rollback at scale.

Distributed search introduces network and fan-out overhead, and sharding may affect global top-\(k\) ranking. The correct architecture depends on the database’s consistency, filtering, and index semantics; validate with production-shaped load tests.

### Concise interview answer

“I start with workload and SLOs, estimate raw vector plus index, metadata, and replication costs, then benchmark ANN recall and tail latency. At scale I partition and shard to limit search scope, use compression or quantization only after quality testing, optimize ingestion and incremental maintenance, and consider candidate reranking. I also test filtered search, shard skew, fan-out, failover, rebalancing, and rebuild capacity. Billions of vectors require operational lifecycle design, not just a faster nearest-neighbor algorithm.”

### Revision summary

| Area | Scaling consideration |
|---|---|
| Capacity | Vectors, dimensions, precision, index, metadata, replicas, rebuild headroom. |
| Search | ANN recall, filtering, partitioning, fan-out and reranking. |
| Storage | Hot/cold tiers, compression, deduplication, lifecycle deletion. |
| Ingestion | Batch writes, incremental updates, compaction and rebalancing. |
| Reliability | Per-shard SLOs, backup/restore, failover and load testing. |

<br><br><br>

## What is hybrid search (combining keyword search with vector search)?

**Answer:**

### Definition

**Hybrid search** combines lexical retrieval (such as BM25 or another inverted-index method) with dense-vector retrieval. The lexical channel is strong for exact terms, identifiers, product codes, and rare names; the vector channel can find paraphrases and semantically related wording. Their candidate lists or scores are combined to improve coverage.

### Common fusion patterns

- **Candidate union and reranking:** Retrieve candidates independently from both systems, merge/deduplicate them, then rerank with a cross-encoder or another relevance model.
- **Score combination:** Normalize or calibrate lexical and vector scores and combine them with tuned weights. Raw scores may have different scales, so an uncalibrated weighted sum can behave poorly.
- **Rank fusion:** Combine ranked lists, for example with reciprocal rank fusion (RRF), which uses ranks rather than assuming score scales are comparable.

Apply authorization and hard metadata constraints consistently to each retrieval path. Tune candidate depths and fusion parameters using held-out relevance judgments, and evaluate by query type: exact-code lookups, natural-language questions, multilingual queries, and mixed cases. Hybrid retrieval adds index, latency, and operational complexity; use it when the measured gains justify those costs.

### Concise interview answer

“Hybrid search combines keyword retrieval, often BM25, with dense-vector retrieval. Keyword search catches exact names, codes, and terms; dense search catches paraphrases and semantic similarity. I merge candidates and use rank fusion such as RRF, calibrated score fusion, or a reranker. I evaluate each channel and the combined system on labeled queries, enforce the same authorization filters, and tune for relevance and latency rather than assuming hybrid is automatically better.”

### Revision summary

| Channel | Strength |
|---|---|
| Keyword/lexical | Exact terms, identifiers, and rare tokens. |
| Dense vector | Semantic similarity and paraphrase matching. |
| Fusion | Candidate union, calibrated scores, rank fusion, or reranking. |
| Evaluation | Query slices, relevance metrics, latency, filter correctness. |

<br><br><br>

## How do you fine-tune an embedding model for a specific domain?

**Answer:**

### Build supervision from the retrieval task

Fine-tune an embedding model when a representative evaluation shows a persistent domain-specific ranking gap that cannot be addressed adequately by better chunking, query/document formatting, hybrid search, metadata filters, or reranking. Use task-aligned examples: query–relevant-document pairs, graded relevance, and carefully selected hard negatives. Domain text alone is not enough to teach which passages should rank for which queries.

### Training and evaluation workflow

1. **Define the objective and baseline:** Collect representative queries and judgments; measure Recall@k, MRR, nDCG, and relevant slices before training.
2. **Curate trustworthy pairs:** Verify source permissions and labels, include paraphrases and realistic hard negatives, and inspect potential false negatives (a “negative” may actually answer the query).
3. **Split without leakage:** Separate by source, entity, time, or document family so near-duplicate chunks do not appear in both training and evaluation.
4. **Choose adaptation method:** Compare a supported contrastive or ranking objective and parameter-efficient adaptation with full fine-tuning as appropriate. Follow the model’s required input format, pooling, and query/document encoding pattern.
5. **Train conservatively:** Tune learning rate, batch/negative strategy, and training duration; monitor both domain retrieval and general-language regressions. Use a held-out validation set for selection.
6. **Evaluate end to end:** Compare against the original model and retrieval pipeline, including ANN recall, hybrid search, filters, latency, and downstream RAG evidence support.
7. **Deploy as a versioned migration:** Re-embed into a separate index, shadow or canary traffic, keep rollback, and monitor quality drift.

Fine-tuning improves the model’s learned ranking behavior; it does not make stale or unsupported source content true. Continue to use authoritative data and retrieval for factual grounding.

### Concise interview answer

“I fine-tune only after establishing a domain retrieval gap on a representative benchmark. I create query–relevant-passage pairs and carefully reviewed hard negatives, split evaluation by source or entity to avoid leakage, and train with a retrieval-aligned contrastive or ranking objective. I compare against the base model on domain and general metrics, then test the full ANN/RAG pipeline and re-embed into a versioned index for a staged rollout.”

### Revision summary

| Step | Purpose |
|---|---|
| Benchmark first | Confirm the domain gap and set measurable targets. |
| Pair/negative curation | Teach the target relevance relation without false-negative noise. |
| Leakage-resistant split | Measure generalization rather than memorization. |
| Controlled training | Adapt the embedding space while tracking regressions. |
| Full-pipeline rollout | Re-embed, shadow-test, monitor, and retain rollback. |

<br><br><br>

## Your vector database for RAG is consuming too much memory. How do you reduce it?

**Answer:**

### Find the actual memory consumer

Break memory down into raw vectors, ANN index structures, metadata and filter indexes, replicas, caches, ingestion buffers, and concurrent query working sets. Measure peak and steady-state usage by shard and workload; do not assume the vectors themselves dominate. Set a recall and latency target before trading memory for compression.

### Reduce footprint without blindly sacrificing quality

1. **Remove unnecessary data:** Deduplicate repeated chunks, delete expired or superseded records, and avoid storing redundant payload fields in the vector index when they can be fetched from a source store.
2. **Reduce vector payload:** Evaluate a model-supported smaller dimension, lower-precision storage, or product/scalar quantization. Compare retrieval recall and downstream answer quality to the full-precision baseline.
3. **Choose an appropriate index:** Tune ANN structure and search parameters; select a memory-efficient index if its recall/latency profile meets the SLO. Flat exact search may be too costly at large scale, while a graph index may consume substantial memory.
4. **Right-size metadata/indexes:** Keep only useful filter fields, avoid indexing every metadata attribute, and validate whether metadata indexes or payload caches are required.
5. **Use storage tiers and caching deliberately:** Keep hot working sets in memory and move colder data to supported disk-backed tiers; use bounded caches and measure cold-query latency.
6. **Review replication and deployment sizing:** Verify replica count, shard placement, and per-node capacity against availability needs; do not reduce redundancy below the recovery objective without an explicit decision.
7. **Load test and monitor:** Measure recall, tail latency, memory, throughput, and rebuild behavior after each change.

Quantization and lower dimension can change nearest-neighbor rankings. Treat memory optimization as a measured quality/cost trade-off, preserve a reproducible source or re-embedding path, and retain rollback.

### Concise interview answer

“I profile memory by component—vectors, ANN structures, metadata indexes, replicas, and caches—then remove duplicates and expired data first. I evaluate lower precision, quantization, or a smaller supported dimension against a full-precision recall and downstream-quality baseline, and tune the index and metadata fields. I may tier cold data or adjust bounded caches, but I preserve availability targets. Every change is load-tested for recall, tail latency, and memory.”

### Revision summary

| Memory source | Potential action |
|---|---|
| Duplicate/obsolete vectors | Deduplicate and apply retention/deletion policies. |
| Raw vector payload | Quantize or reduce supported dimensions after evaluation. |
| ANN/metadata indexes | Tune index and index only necessary filter fields. |
| Payload/cache/replicas | Fetch payload externally, bound cache, review capacity/replication goals. |
| Validation | Compare recall, downstream answer quality, latency, and recovery. |

<br><br><br>

## Your vector database cannot scale to millions of embeddings. How do you fix the bottleneck?

**Answer:**

### Locate the bottleneck before scaling out

“Cannot scale” can mean slow queries, low throughput, memory exhaustion, slow ingestion, expensive index builds, or poor recall after filters. Establish which limit is binding with workload metrics and traces: vector count and dimension, index type/parameters, p50/p95/p99 latency, QPS/concurrency, CPU, memory, disk I/O, network, filter selectivity, shard skew, and write/update rate. Reproduce the issue with production-shaped data and queries.

### A measured remediation sequence

1. **Check the retrieval pipeline:** Confirm the embedding dimension and metric, avoid unnecessary full scans, and compare ANN results with an exact-search baseline on a representative sample.
2. **Tune the index and query:** Adjust the ANN index or search breadth for the target recall/latency balance; measure filtered queries independently. Reduce candidate fan-out or rerank a smaller candidate set if quality permits.
3. **Reduce waste:** Deduplicate vectors, remove expired records, right-size chunking and dimensions where quality supports it, and avoid storing large payloads redundantly in the index.
4. **Improve ingestion:** Batch and parallelize writes within service limits, use idempotent upserts, and schedule compaction or index maintenance so ingestion does not overwhelm query serving.
5. **Partition or shard when evidence supports it:** Route queries to relevant partitions (for example, tenant or region) where safe. Add shards or capacity only after checking skew, fan-out, network, and global top-\(k\) effects.
6. **Scale resources and architecture:** Increase node resources or replicas for the measured bottleneck, separate read/write workloads if supported, and consider a managed or distributed vector-search design if operational constraints warrant migration.
7. **Validate and prevent recurrence:** Run load tests at expected growth and concurrency, monitor per-shard utilization and SLOs, and keep a rollback plan for index/configuration changes.

Millions of vectors may be manageable in one deployment or may not, depending on dimensions, filters, hardware, and SLOs. Avoid assuming that a larger cluster fixes an inefficient query, skewed partition, or incorrect index configuration.

### Concise interview answer

“I first identify whether the limit is query latency, throughput, memory, ingestion, or index maintenance, using production-shaped load and per-shard metrics. I verify the metric and ANN configuration, tune recall versus search effort, remove redundant data, and optimize batching and filters. Then I partition or add capacity based on the observed bottleneck, accounting for skew and fan-out. I validate with recall, tail latency, throughput, memory, and recovery tests rather than scaling blindly.”

### Revision summary

| Bottleneck | First actions |
|---|---|
| Slow queries | Profile filters, ANN parameters, fan-out, and tail latency. |
| Memory | Inspect vectors, index, metadata, replicas, and caches. |
| Slow ingestion | Batch/idempotent writes; inspect index maintenance and compaction. |
| Uneven shards | Measure skew; rebalance or revise partition strategy. |
| Capacity growth | Load-test expected scale and add resources based on evidence. |

<br><br><br>

## Your new embedding model has different dimensions from the existing vectors in production. How do you handle the mismatch?

**Answer:**

### Do not mix incompatible vectors

A vector index generally expects every vector in a collection to have the same dimension, and similarity search is meaningful only when query and corpus vectors are in a compatible embedding space. A dimension mismatch is therefore a schema and model-version migration—not something to fix by padding, truncating, or coercing vectors without explicit model support and evaluation.

Even equal-dimensional vectors from different model versions may be incompatible. Dimension equality is necessary for many index implementations, but it does not prove that the vectors share a coordinate system or ranking behavior.

### Migration plan

1. **Identify the change:** Record old/new model versions, dimensions, preprocessing, query/document encoding, normalization, metric, and any supported dimension controls.
2. **Create a separate versioned index/schema:** Keep the existing production index available. Store model/version metadata with the new vectors and prevent cross-version query/index pairing.
3. **Re-embed the corpus:** Generate new vectors using the new model’s documented input format. Use a backfill process with checkpoints, idempotency, rate limits, and reconciliation so writes or document changes during migration are not lost.
4. **Dual-write or catch up on updates:** Ensure records created or modified during backfill are represented in both versions, or replay a change log before cutover.
5. **Validate compatibility and quality:** Test vector shape, metric and normalization, coverage, retrieval metrics, filtered queries, downstream quality, and serving cost. Compare against the old index on the same held-out queries.
6. **Shadow, then cut over:** Route test/shadow queries to the new index; promote with version-aware routing or an atomic alias/configuration switch only after acceptance criteria pass.
7. **Retain rollback and retire deliberately:** Preserve the old model/index until the new version is stable and retention requirements allow cleanup. Invalidate embedding caches by model version.

If the new model supports a compatible output-dimension option, that can be assessed, but it does not eliminate the need to verify the representation and quality. Re-embedding is usually the safe default for a different model space.

### Concise interview answer

“I would not pad, truncate, or mix the vectors. I create a separate index for the new model, re-embed the corpus, and ensure updates during backfill are dual-written or replayed. I validate dimensions, preprocessing, metric, retrieval quality, filtered search, and downstream performance, then shadow and cut over with version-aware routing. I retain the old index and model for rollback. Equal dimensions alone do not guarantee compatible embedding spaces.”

### Revision summary

| Requirement | Action |
|---|---|
| Correct vector shape | Use a separate compatible index/schema. |
| Complete data | Backfill plus dual-write/change-log catch-up. |
| Valid retrieval | Pair queries and corpus vectors from the same model space. |
| Safe release | Offline evaluation, shadow traffic, controlled cutover. |
| Recovery | Preserve old index/model and version cache keys. |

<br><br><br>

## Your vector search returns irrelevant results despite high similarity scores. How do you fix it?

**Answer:**

### A high similarity score is not a relevance guarantee

Similarity scores are meaningful only relative to the embedding model, metric, normalization, corpus, and query distribution. They are not calibrated probabilities that a passage answers the question. A high score can still surface an irrelevant result when query and passage encoding are mismatched, chunks contain mixed topics, the corpus is noisy, filters are applied incorrectly, or the model overweights shared but unhelpful wording.

### Diagnose the retrieval path

1. **Reproduce and label failures:** Save the exact query, top candidates, scores/ranks, filters, and expected relevant items. Have domain reviewers identify whether results are irrelevant, incomplete, stale, or unauthorized.
2. **Verify representation consistency:** Check that query and document vectors use compatible model versions, prefixes/instructions, preprocessing, pooling, normalization, and distance metric. Confirm dimensions and inspect score direction (distance versus similarity).
3. **Inspect corpus and chunking:** Check duplicates, stale or malformed documents, chunk boundaries, excessive chunk length, missing context, and whether metadata points to the right source.
4. **Separate ANN error from embedding error:** Compare ANN top-k with exact vector search on a representative subset. If exact search is good, tune index/search parameters; if exact results are poor, address the model, data, or query.
5. **Improve candidate generation:** Test query rewriting or expansion, metadata filters, hybrid lexical-plus-dense retrieval, and an appropriate candidate depth. Avoid adding filters that remove relevant evidence.
6. **Rerank and calibrate:** Use a cross-encoder or task-specific reranker on a manageable candidate set when it improves measured quality. Do not select an arbitrary score threshold without calibrating it on labeled data.
7. **Evaluate and monitor:** Measure Recall@k, MRR/nDCG, precision, filtered retrieval, latency, and downstream answer support; track error slices and regressions after changes.

### Concise interview answer

“I would not treat a high similarity score as proof of relevance. I reproduce and label failures, verify model/version and query/document preprocessing, metric and normalization, and inspect chunks, metadata, freshness, and filters. Then I compare ANN against exact search to isolate index recall from embedding quality. Depending on the cause, I fix the corpus or chunking, add hybrid retrieval or query handling, and rerank candidates. I validate with labeled retrieval metrics and downstream evidence quality.”

### Revision summary

| Possible cause | Diagnostic |
|---|---|
| Metric or model mismatch | Verify model version, formats, normalization, and score semantics. |
| ANN misses | Compare to exact search; tune index/search effort. |
| Poor vectors or corpus | Inspect labeled false positives, chunking, duplicates, freshness. |
| Lexical or filter failure | Evaluate hybrid search and filter correctness. |
| Score overinterpretation | Calibrate thresholds and measure ranking quality. |

<br><br><br>

## You deployed a new embedding model, and search quality crashed overnight. How do you handle embedding drift?

**Answer:**

### Stabilize first, then isolate the change

Treat a sudden search-quality drop as a production incident. If the new model/index is affecting users and the old version is available, route traffic back to the known-good model/index while limiting any ongoing impact. Preserve logs, version identifiers, deployment timestamps, and representative failed queries before making more changes.

### Diagnose the regression

1. **Confirm scope and timing:** Compare quality, zero-result rate, latency, score/rank distributions, and failure rates before and after rollout, segmented by query type, language, tenant, and data source.
2. **Check query/index pairing:** Ensure the new query encoder is searching vectors produced by the same model version and preprocessing. A common cause is changing the query model while the corpus still contains old vectors, or mixing vectors in one index.
3. **Inspect the full pipeline:** Verify tokenizer/prefixes, preprocessing, truncation, chunking, pooling, normalization, distance metric, dimension, ANN configuration, metadata filters, and cache invalidation.
4. **Reproduce offline:** Run old and new pipelines on the same versioned corpus and held-out judgments. Compare exact search first where feasible, then ANN, to distinguish representation drift from index/serving regressions.
5. **Check migration completeness:** Look for missing or stale embeddings, failed backfills, unprocessed updates, partial alias switches, and version skew across services.
6. **Fix and gate rollout:** Correct the identified mismatch or regenerate the index. Use shadow/dual reads and canary traffic with explicit retrieval-quality and latency thresholds before promotion.
7. **Keep rollback and monitoring:** Retain the old index/model until stable; alert on quality proxies and operational changes, and use cache keys that include model and preprocessing versions.

Do not assume the new model is inherently worse based only on score changes: similarity scales may shift between models. Judge with relevance rankings and downstream task metrics on the same evaluation set.

### Concise interview answer

“I treat it as an incident and roll back to the known-good model/index if users are affected. Then I compare before/after metrics and verify that query and document vectors use the same model and preprocessing, checking caches, index migration completeness, filters, metric, and ANN settings. I reproduce the change offline against the same relevance judgments, separate exact-search representation quality from ANN/serving issues, and re-promote only through shadow and canary gates with rollback.”

### Revision summary

| Phase | Action |
|---|---|
| Contain | Roll back or route to known-good model/index. |
| Diagnose | Compare slices, versions, preprocessing, caches, filters, and migration. |
| Isolate | Compare old/new exact and ANN retrieval on identical judgments. |
| Promote | Shadow/canary with quality and latency gates. |
| Prevent | Version vectors/caches, monitor and preserve rollback. |

<br><br><br>

## Your semantic search fails for short queries. How do you improve it?

**Answer:**

### Why short queries are difficult

Short queries often contain too little context to identify intent, and a single ambiguous term can map to several topics. They may also be identifiers, product codes, names, or keyword-style searches where exact lexical matching is more useful than semantic similarity. Embedding models can produce a plausible vector for a very short input without resolving its ambiguity.

### Improve the system systematically

1. **Analyze query classes:** Separate short natural-language questions from names, codes, acronyms, and incomplete fragments. Measure relevance by query length and type.
2. **Preserve lexical signals:** Add keyword/BM25 retrieval or hybrid search for exact terms, identifiers, and rare names; do not normalize away punctuation or case when those distinctions matter.
3. **Use context carefully:** Add authorized conversation context or a query rewrite that clarifies intent. If multiple interpretations remain plausible, retrieve across them or ask a clarification question rather than silently assuming one.
4. **Tune the embedding interface:** Follow model-specific query prefixes/instructions, avoid over-aggressive preprocessing, and test a model trained or evaluated for short-query retrieval.
5. **Improve candidate ranking:** Retrieve a broader but bounded candidate set and rerank with the full query/context when this improves measured relevance. Apply metadata constraints only when supported by trusted context.
6. **Use feedback and evaluation:** Build a representative short-query benchmark with relevance judgments, hard negatives, and identifier cases. Compare dense-only, lexical, hybrid, rewrite, and reranking variants using Recall@k, MRR/nDCG, and latency.
7. **Monitor real traffic safely:** Track zero-result and reformulation rates and collect feedback with privacy controls; avoid storing sensitive query text unnecessarily.

### Concise interview answer

“Short queries are ambiguous and often include exact terms that dense embeddings may not handle reliably. I first segment short queries by intent, then benchmark hybrid lexical-plus-vector search, preserving identifiers and punctuation. I can use authorized conversation context, query rewriting, or clarification when intent is unclear, and rerank a broader candidate set when needed. I evaluate on labeled short-query slices with retrieval metrics and latency rather than adding context blindly.”

### Revision summary

| Failure pattern | Response |
|---|---|
| Ambiguous fragment | Use context, rewrite, or ask for clarification. |
| Exact name/code | Add lexical retrieval and preserve exact tokens. |
| Poor dense representation | Test short-query instructions/model and preprocessing. |
| Ranking issue | Expand candidates and evaluate reranking. |
| Validation | Short-query benchmark, relevance metrics, latency, safe monitoring. |

<br><br><br>
