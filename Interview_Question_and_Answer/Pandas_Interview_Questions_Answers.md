# Pandas Interview Questions and Answers

**Source conversation:** [Data Scientist Interview Answers](https://chatgpt.com/share/68592856-e81c-8003-ad72-93017bee888b)

Questions follow the supplied order. Assistant answers are copied from the linked conversation and formatted from its rendered headings, lists, tables, and code blocks. Where an answer is related but not specific to the exact scenario, that is noted. Items with no source answer are left unanswered rather than filled with new material.

## Basics of pandas

### Question 1: What is pandas and why is it important in data science?

**Answer copied from the linked conversation:**

Great questions, Himanshu! These concepts are **foundational** to working with pandas in data science. Below is a **comprehensive explanation with examples and a summary table** for quick revision.

---

### ✅ Core Data Structures in Pandas

| Structure | Description |
| --- | --- |
| Series | 1D labeled array – like a column in Excel |
| DataFrame | 2D labeled data structure – like an Excel sheet |

---

### 🔹 What is a Series?

A **pandas Series** is a **one-dimensional labeled array** capable of holding any data type (integers, strings, floats, Python objects, etc.).

```python
import pandas as pd

s = pd.Series([10, 20, 30], index=['a', 'b', 'c'])
print(s)
```

📤 **Output**:

```python
a    10
b    20
c    30
dtype: int64
```

---

### 🔹 What is a DataFrame?

A **DataFrame** is a **two-dimensional**, size-mutable, tabular data structure with labeled axes (rows and columns).

```python
data = {
    'Name': ['Alice', 'Bob', 'Charlie'],
    'Age': [25, 30, 35]
}
df = pd.DataFrame(data)
print(df)
```

📤 **Output**:

```python
Name  Age
0    Alice   25
1      Bob   30
2  Charlie   35
```

---

### ✅ How to Create DataFrame from Different Sources

| Source | Code Example |
| --- | --- |
| List of Lists | pd.DataFrame([[1,2],[3,4]], columns=['A','B']) |
| Dict of Lists | pd.DataFrame({'A': [1, 2], 'B': [3, 4]}) |
| Dict of Series | pd.DataFrame({'A': pd.Series(...), 'B': pd.Series(...)}) |
| Numpy Array | pd.DataFrame(np.array([[1,2], [3,4]]), columns=['X', 'Y']) |
| List of Dicts | pd.DataFrame([{'a': 1, 'b': 2}, {'a': 3, 'b': 4}]) |
| CSV/Excel/SQL | pd.read_csv(), pd.read_excel(), pd.read_sql() |

---

### 🔍 Series vs DataFrame: Comparison Table

| Feature | Series | DataFrame |
| --- | --- | --- |
| Dimensionality | 1D | 2D |
| Axis labels | Single index | Row and column indexes |
| Data type | Homogeneous or mixed | Typically heterogeneous |
| Shape | (n,) | (n, m) |
| Example Use Case | Single column (e.g., Age) | Full dataset (e.g., Name, Age, Salary) |
| Creation | pd.Series([1, 2, 3]) | pd.DataFrame({'col1': [...], ...}) |

---

### ✅ Interview Tip

“I use Series when dealing with a single variable or during vectorized operations. DataFrames are the core structure I work with in all stages — from preprocessing to model evaluation. Understanding both helps me manipulate and analyze data efficiently.”

---

Would you like a **code-based cheat sheet** showing how to convert between Series and DataFrames, or extract columns, rows, and cells efficiently?

### Question 2: What are the core data structures in pandas? Series and DataFrame

**Answer copied from the linked conversation:**

Great questions, Himanshu! These concepts are **foundational** to working with pandas in data science. Below is a **comprehensive explanation with examples and a summary table** for quick revision.

---

### ✅ Core Data Structures in Pandas

| Structure | Description |
| --- | --- |
| Series | 1D labeled array – like a column in Excel |
| DataFrame | 2D labeled data structure – like an Excel sheet |

---

### 🔹 What is a Series?

A **pandas Series** is a **one-dimensional labeled array** capable of holding any data type (integers, strings, floats, Python objects, etc.).

```python
import pandas as pd

s = pd.Series([10, 20, 30], index=['a', 'b', 'c'])
print(s)
```

📤 **Output**:

```python
a    10
b    20
c    30
dtype: int64
```

---

### 🔹 What is a DataFrame?

A **DataFrame** is a **two-dimensional**, size-mutable, tabular data structure with labeled axes (rows and columns).

```python
data = {
    'Name': ['Alice', 'Bob', 'Charlie'],
    'Age': [25, 30, 35]
}
df = pd.DataFrame(data)
print(df)
```

📤 **Output**:

```python
Name  Age
0    Alice   25
1      Bob   30
2  Charlie   35
```

---

### ✅ How to Create DataFrame from Different Sources

| Source | Code Example |
| --- | --- |
| List of Lists | pd.DataFrame([[1,2],[3,4]], columns=['A','B']) |
| Dict of Lists | pd.DataFrame({'A': [1, 2], 'B': [3, 4]}) |
| Dict of Series | pd.DataFrame({'A': pd.Series(...), 'B': pd.Series(...)}) |
| Numpy Array | pd.DataFrame(np.array([[1,2], [3,4]]), columns=['X', 'Y']) |
| List of Dicts | pd.DataFrame([{'a': 1, 'b': 2}, {'a': 3, 'b': 4}]) |
| CSV/Excel/SQL | pd.read_csv(), pd.read_excel(), pd.read_sql() |

---

### 🔍 Series vs DataFrame: Comparison Table

| Feature | Series | DataFrame |
| --- | --- | --- |
| Dimensionality | 1D | 2D |
| Axis labels | Single index | Row and column indexes |
| Data type | Homogeneous or mixed | Typically heterogeneous |
| Shape | (n,) | (n, m) |
| Example Use Case | Single column (e.g., Age) | Full dataset (e.g., Name, Age, Salary) |
| Creation | pd.Series([1, 2, 3]) | pd.DataFrame({'col1': [...], ...}) |

---

### ✅ Interview Tip

“I use Series when dealing with a single variable or during vectorized operations. DataFrames are the core structure I work with in all stages — from preprocessing to model evaluation. Understanding both helps me manipulate and analyze data efficiently.”

---

Would you like a **code-based cheat sheet** showing how to convert between Series and DataFrames, or extract columns, rows, and cells efficiently?

### Question 3: How do you create a DataFrame from lists, dicts, or NumPy arrays?

**Answer copied from the linked conversation:**

Great questions, Himanshu! These concepts are **foundational** to working with pandas in data science. Below is a **comprehensive explanation with examples and a summary table** for quick revision.

---

### ✅ Core Data Structures in Pandas

| Structure | Description |
| --- | --- |
| Series | 1D labeled array – like a column in Excel |
| DataFrame | 2D labeled data structure – like an Excel sheet |

---

### 🔹 What is a Series?

A **pandas Series** is a **one-dimensional labeled array** capable of holding any data type (integers, strings, floats, Python objects, etc.).

```python
import pandas as pd

s = pd.Series([10, 20, 30], index=['a', 'b', 'c'])
print(s)
```

📤 **Output**:

```python
a    10
b    20
c    30
dtype: int64
```

---

### 🔹 What is a DataFrame?

A **DataFrame** is a **two-dimensional**, size-mutable, tabular data structure with labeled axes (rows and columns).

```python
data = {
    'Name': ['Alice', 'Bob', 'Charlie'],
    'Age': [25, 30, 35]
}
df = pd.DataFrame(data)
print(df)
```

📤 **Output**:

```python
Name  Age
0    Alice   25
1      Bob   30
2  Charlie   35
```

---

### ✅ How to Create DataFrame from Different Sources

| Source | Code Example |
| --- | --- |
| List of Lists | pd.DataFrame([[1,2],[3,4]], columns=['A','B']) |
| Dict of Lists | pd.DataFrame({'A': [1, 2], 'B': [3, 4]}) |
| Dict of Series | pd.DataFrame({'A': pd.Series(...), 'B': pd.Series(...)}) |
| Numpy Array | pd.DataFrame(np.array([[1,2], [3,4]]), columns=['X', 'Y']) |
| List of Dicts | pd.DataFrame([{'a': 1, 'b': 2}, {'a': 3, 'b': 4}]) |
| CSV/Excel/SQL | pd.read_csv(), pd.read_excel(), pd.read_sql() |

---

### 🔍 Series vs DataFrame: Comparison Table

| Feature | Series | DataFrame |
| --- | --- | --- |
| Dimensionality | 1D | 2D |
| Axis labels | Single index | Row and column indexes |
| Data type | Homogeneous or mixed | Typically heterogeneous |
| Shape | (n,) | (n, m) |
| Example Use Case | Single column (e.g., Age) | Full dataset (e.g., Name, Age, Salary) |
| Creation | pd.Series([1, 2, 3]) | pd.DataFrame({'col1': [...], ...}) |

---

### ✅ Interview Tip

“I use Series when dealing with a single variable or during vectorized operations. DataFrames are the core structure I work with in all stages — from preprocessing to model evaluation. Understanding both helps me manipulate and analyze data efficiently.”

---

Would you like a **code-based cheat sheet** showing how to convert between Series and DataFrames, or extract columns, rows, and cells efficiently?
Certainly, Himanshu! Here's the **updated table** with **JSON** as a data source added for creating a pandas DataFrame:

---

### ✅ Ways to Create a DataFrame in Pandas – Summary Table

| Source | Code Example |
| --- | --- |
| List of Lists | pd.DataFrame([[1,2],[3,4]], columns=['A','B']) |
| Dict of Lists | pd.DataFrame({'A': [1, 2], 'B': [3, 4]}) |
| Dict of Series | pd.DataFrame({'A': pd.Series(...), 'B': pd.Series(...)}) |
| Numpy Array | pd.DataFrame(np.array([[1,2], [3,4]]), columns=['X', 'Y']) |
| List of Dicts | pd.DataFrame([{'a': 1, 'b': 2}, {'a': 3, 'b': 4}]) |
| JSON (from str) | pd.read_json(json_string) or pd.DataFrame(json.loads(json_string)) |
| CSV/Excel/SQL | pd.read_csv(), pd.read_excel(), pd.read_sql() |

---

### 🔹 Example: Creating a DataFrame from JSON

```python
import pandas as pd
import json

json_data = '[{"a": 1, "b": 2}, {"a": 3, "b": 4}]'
df = pd.read_json(json_data)
print(df)
```

📤 Output:

```python
a  b
0  1  2
1  3  4
```

You can also read from a `.json` file:

`pd.read_json('file.json')`

Let me know if you want a **visual cheat sheet** or real-world examples for each source!

### Question 4: What is the difference between a Series and a DataFrame?

**Answer copied from the linked conversation:**

Great questions, Himanshu! These concepts are **foundational** to working with pandas in data science. Below is a **comprehensive explanation with examples and a summary table** for quick revision.

---

### ✅ Core Data Structures in Pandas

| Structure | Description |
| --- | --- |
| Series | 1D labeled array – like a column in Excel |
| DataFrame | 2D labeled data structure – like an Excel sheet |

---

### 🔹 What is a Series?

A **pandas Series** is a **one-dimensional labeled array** capable of holding any data type (integers, strings, floats, Python objects, etc.).

```python
import pandas as pd

s = pd.Series([10, 20, 30], index=['a', 'b', 'c'])
print(s)
```

📤 **Output**:

```python
a    10
b    20
c    30
dtype: int64
```

---

### 🔹 What is a DataFrame?

A **DataFrame** is a **two-dimensional**, size-mutable, tabular data structure with labeled axes (rows and columns).

```python
data = {
    'Name': ['Alice', 'Bob', 'Charlie'],
    'Age': [25, 30, 35]
}
df = pd.DataFrame(data)
print(df)
```

📤 **Output**:

```python
Name  Age
0    Alice   25
1      Bob   30
2  Charlie   35
```

---

### ✅ How to Create DataFrame from Different Sources

| Source | Code Example |
| --- | --- |
| List of Lists | pd.DataFrame([[1,2],[3,4]], columns=['A','B']) |
| Dict of Lists | pd.DataFrame({'A': [1, 2], 'B': [3, 4]}) |
| Dict of Series | pd.DataFrame({'A': pd.Series(...), 'B': pd.Series(...)}) |
| Numpy Array | pd.DataFrame(np.array([[1,2], [3,4]]), columns=['X', 'Y']) |
| List of Dicts | pd.DataFrame([{'a': 1, 'b': 2}, {'a': 3, 'b': 4}]) |
| CSV/Excel/SQL | pd.read_csv(), pd.read_excel(), pd.read_sql() |

---

### 🔍 Series vs DataFrame: Comparison Table

| Feature | Series | DataFrame |
| --- | --- | --- |
| Dimensionality | 1D | 2D |
| Axis labels | Single index | Row and column indexes |
| Data type | Homogeneous or mixed | Typically heterogeneous |
| Shape | (n,) | (n, m) |
| Example Use Case | Single column (e.g., Age) | Full dataset (e.g., Name, Age, Salary) |
| Creation | pd.Series([1, 2, 3]) | pd.DataFrame({'col1': [...], ...}) |

---

### ✅ Interview Tip

“I use Series when dealing with a single variable or during vectorized operations. DataFrames are the core structure I work with in all stages — from preprocessing to model evaluation. Understanding both helps me manipulate and analyze data efficiently.”

---

Would you like a **code-based cheat sheet** showing how to convert between Series and DataFrames, or extract columns, rows, and cells efficiently?

### Question 5: How do you inspect the first few rows of a DataFrame?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! Data preprocessing is a **core step in every data science pipeline** — and mastering the relevant **Pandas techniques** helps clean, transform, and prepare data efficiently before applying ML algorithms.

Here’s a comprehensive summary of **data preprocessing using Pandas** — with explanations, examples, and a **quick revision table** at the end.

---

### ✅ 1. Loading the Dataset

```python
import pandas as pd

df = pd.read_csv('data.csv')
df.head()
```

---

### ✅ 2. Understanding the Data

```python
df.shape          # (rows, columns)
df.columns        # List of column names
df.info()         # Data types and null counts
df.describe()     # Summary statistics
```

---

### ✅ 3. Handling Missing Values

### 🔹 Detect

```python
df.isnull().sum()        # Count nulls per column
```

### 🔹 Drop

```python
df.dropna()              # Drop rows with any NaN
df.dropna(axis=1)        # Drop columns with any NaN
```

### 🔹 Impute

```python
df.fillna(0)
df['col'].fillna(df['col'].mean(), inplace=True)
```

---

### ✅ 4. Handling Duplicates

```python
df.duplicated().sum()
df.drop_duplicates(inplace=True)
```

---

### ✅ 5. Renaming Columns

```python
df.rename(columns={'old_name': 'new_name'}, inplace=True)
```

---

### ✅ 6. Changing Data Types (Type Casting)

```python
df['date'] = pd.to_datetime(df['date'])
df['col'] = df['col'].astype(int)
```

---

### ✅ 7. Filtering and Subsetting

```python
df[df['col'] > 50]                      # Row filter
df[['col1', 'col2']]                   # Column subset
```

---

### ✅ 8. Feature Engineering

```python
df['new_col'] = df['col1'] / df['col2']  # Derived feature
df['year'] = df['date'].dt.year          # Extract from datetime
```

---

### ✅ 9. Encoding Categorical Variables

```python
pd.get_dummies(df, columns=['category_col'])           # One-hot encoding
df['label_encoded'] = df['category_col'].astype('category').cat.codes
```

---

### ✅ 10. Scaling/Normalization

Usually done with Scikit-learn:

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
df[['scaled_col']] = scaler.fit_transform(df[['col']])
```

---

### ✅ 11. Grouping & Aggregation

```python
df.groupby('category')['value'].mean()
df.groupby(['col1', 'col2']).agg({'value': ['sum', 'mean']})
```

---

### ✅ 12. Merging, Joining, and Concatenation

```python
pd.concat([df1, df2])                        # Stack vertically
pd.merge(df1, df2, on='key')                # SQL-style join
```

---

### ✅ 13. Exporting the Cleaned Data

```python
df.to_csv("cleaned_data.csv", index=False)
```

---

### 🧠 Summary Table: Quick Revision

| Step | Function / Method | Notes |
| --- | --- | --- |
| Load Data | pd.read_csv() | Read CSV, Excel, JSON, etc. |
| Inspect Data | df.info(), df.describe() | Data types, nulls, stats |
| Handle Nulls | dropna(), fillna() | Drop or impute |
| Remove Duplicates | duplicated(), drop_duplicates() |  |
| Rename / Reformat | rename(), astype(), to_datetime() | For consistent formats |
| Filter/Subsets | df[df['x'] > 0], df[['x', 'y']] | Logic-based filtering |
| Feature Engineering | Math ops, dt accessor | New columns |
| Encode Categoricals | get_dummies(), .cat.codes | For ML algorithms |
| Scaling | StandardScaler, MinMaxScaler | Sklearn tools |
| Grouping / Aggregation | groupby(), agg() | For summaries |
| Merge / Join | merge(), concat() | Combining datasets |
| Export | to_csv(), to_excel() | Save preprocessed data |

---

### ✅ Interview Tip:

“In data science projects, I usually start with null handling and type casting, followed by outlier removal, encoding, and scaling. Pandas makes it easy to build repeatable pipelines with readable code.”

---

Would you like a **reusable preprocessing function or pipeline class** using Pandas and Scikit-learn that you can plug into your ML projects?

## Data Selection & Indexing

### Question 6: What is the difference between `.loc[]` and `.iloc[]`?

**Answer copied from the linked conversation:**

Great question, Himanshu! Understanding the difference between `.iloc`, `.loc`, and `.ix` is crucial for working efficiently with **DataFrames** in Pandas — especially during data wrangling and preprocessing tasks in data science projects.

---

### ✅ 1. .iloc[] → Integer-location based indexing

- **Used for**: Selecting rows and columns **by integer position** (like list slicing).
- Syntax: `df.iloc[row_index, column_index]`

### 🔸 Example:

```python
df = pd.DataFrame({'A': [10, 20, 30], 'B': [100, 200, 300]})
print(df.iloc[0])         # First row
print(df.iloc[1, 1])      # Element at (row=1, col=1) → 200
```

---

### ✅ 2. .loc[] → Label-based indexing

- **Used for**: Selecting data **by labels** (row/column names).
- Syntax: `df.loc[row_label, column_label]`

### 🔸 Example:

```python
df = pd.DataFrame({'A': [10, 20, 30]}, index=['x', 'y', 'z'])
print(df.loc['x'])         # Row with index label 'x'
print(df.loc['y', 'A'])    # Value at row 'y', column 'A' → 20
```

---

### ⚠️ 3. .ix[] → Deprecated (Removed in Pandas 1.0)

- **Was used for**: Mixed indexing — both label and integer-based.
- **Don't use `.ix[]`** — it led to ambiguous behavior.
- Use `.loc[]` and `.iloc[]` **explicitly** instead.

---

### 🧠 Summary Table: iloc vs loc vs ix

| Feature | .iloc[] | .loc[] | .ix[] ❌ (Deprecated) |
| --- | --- | --- | --- |
| Type of Index | Integer position | Label name | Mixed (int/label) |
| Syntax | df.iloc[0, 1] | df.loc['row_label', 'col'] | df.ix[1, 'col'] |
| Returns | Scalar, Series, or DataFrame | Scalar, Series, or DataFrame | Same (but ambiguous) |
| Use Case | Row/column by position | Row/column by name | ❌ Do not use |
| Status | ✅ Supported | ✅ Supported | ❌ Deprecated in v0.20+, removed in v1.0 |

---

### ✅ Interview Tip:

"I always use `.iloc` when working with numeric positions during loops or slicing, and `.loc` when I want to filter based on index labels or column names. I avoid `.ix` since it's deprecated and can lead to confusion."

---

Would you like a **practice notebook** or **quiz-style examples** to reinforce this?

### Question 7: How do you select a single column or row in a DataFrame?

**Answer copied from the linked conversation:**

Great question, Himanshu! Understanding the difference between `.iloc`, `.loc`, and `.ix` is crucial for working efficiently with **DataFrames** in Pandas — especially during data wrangling and preprocessing tasks in data science projects.

---

### ✅ 1. .iloc[] → Integer-location based indexing

- **Used for**: Selecting rows and columns **by integer position** (like list slicing).
- Syntax: `df.iloc[row_index, column_index]`

### 🔸 Example:

```python
df = pd.DataFrame({'A': [10, 20, 30], 'B': [100, 200, 300]})
print(df.iloc[0])         # First row
print(df.iloc[1, 1])      # Element at (row=1, col=1) → 200
```

---

### ✅ 2. .loc[] → Label-based indexing

- **Used for**: Selecting data **by labels** (row/column names).
- Syntax: `df.loc[row_label, column_label]`

### 🔸 Example:

```python
df = pd.DataFrame({'A': [10, 20, 30]}, index=['x', 'y', 'z'])
print(df.loc['x'])         # Row with index label 'x'
print(df.loc['y', 'A'])    # Value at row 'y', column 'A' → 20
```

---

### ⚠️ 3. .ix[] → Deprecated (Removed in Pandas 1.0)

- **Was used for**: Mixed indexing — both label and integer-based.
- **Don't use `.ix[]`** — it led to ambiguous behavior.
- Use `.loc[]` and `.iloc[]` **explicitly** instead.

---

### 🧠 Summary Table: iloc vs loc vs ix

| Feature | .iloc[] | .loc[] | .ix[] ❌ (Deprecated) |
| --- | --- | --- | --- |
| Type of Index | Integer position | Label name | Mixed (int/label) |
| Syntax | df.iloc[0, 1] | df.loc['row_label', 'col'] | df.ix[1, 'col'] |
| Returns | Scalar, Series, or DataFrame | Scalar, Series, or DataFrame | Same (but ambiguous) |
| Use Case | Row/column by position | Row/column by name | ❌ Do not use |
| Status | ✅ Supported | ✅ Supported | ❌ Deprecated in v0.20+, removed in v1.0 |

---

### ✅ Interview Tip:

"I always use `.iloc` when working with numeric positions during loops or slicing, and `.loc` when I want to filter based on index labels or column names. I avoid `.ix` since it's deprecated and can lead to confusion."

---

Would you like a **practice notebook** or **quiz-style examples** to reinforce this?

### Question 8: How do you filter rows based on conditions (e.g., `age > 30`)?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! Data preprocessing is a **core step in every data science pipeline** — and mastering the relevant **Pandas techniques** helps clean, transform, and prepare data efficiently before applying ML algorithms.

Here’s a comprehensive summary of **data preprocessing using Pandas** — with explanations, examples, and a **quick revision table** at the end.

---

### ✅ 1. Loading the Dataset

```python
import pandas as pd

df = pd.read_csv('data.csv')
df.head()
```

---

### ✅ 2. Understanding the Data

```python
df.shape          # (rows, columns)
df.columns        # List of column names
df.info()         # Data types and null counts
df.describe()     # Summary statistics
```

---

### ✅ 3. Handling Missing Values

### 🔹 Detect

```python
df.isnull().sum()        # Count nulls per column
```

### 🔹 Drop

```python
df.dropna()              # Drop rows with any NaN
df.dropna(axis=1)        # Drop columns with any NaN
```

### 🔹 Impute

```python
df.fillna(0)
df['col'].fillna(df['col'].mean(), inplace=True)
```

---

### ✅ 4. Handling Duplicates

```python
df.duplicated().sum()
df.drop_duplicates(inplace=True)
```

---

### ✅ 5. Renaming Columns

```python
df.rename(columns={'old_name': 'new_name'}, inplace=True)
```

---

### ✅ 6. Changing Data Types (Type Casting)

```python
df['date'] = pd.to_datetime(df['date'])
df['col'] = df['col'].astype(int)
```

---

### ✅ 7. Filtering and Subsetting

```python
df[df['col'] > 50]                      # Row filter
df[['col1', 'col2']]                   # Column subset
```

---

### ✅ 8. Feature Engineering

```python
df['new_col'] = df['col1'] / df['col2']  # Derived feature
df['year'] = df['date'].dt.year          # Extract from datetime
```

---

### ✅ 9. Encoding Categorical Variables

```python
pd.get_dummies(df, columns=['category_col'])           # One-hot encoding
df['label_encoded'] = df['category_col'].astype('category').cat.codes
```

---

### ✅ 10. Scaling/Normalization

Usually done with Scikit-learn:

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
df[['scaled_col']] = scaler.fit_transform(df[['col']])
```

---

### ✅ 11. Grouping & Aggregation

```python
df.groupby('category')['value'].mean()
df.groupby(['col1', 'col2']).agg({'value': ['sum', 'mean']})
```

---

### ✅ 12. Merging, Joining, and Concatenation

```python
pd.concat([df1, df2])                        # Stack vertically
pd.merge(df1, df2, on='key')                # SQL-style join
```

---

### ✅ 13. Exporting the Cleaned Data

```python
df.to_csv("cleaned_data.csv", index=False)
```

---

### 🧠 Summary Table: Quick Revision

| Step | Function / Method | Notes |
| --- | --- | --- |
| Load Data | pd.read_csv() | Read CSV, Excel, JSON, etc. |
| Inspect Data | df.info(), df.describe() | Data types, nulls, stats |
| Handle Nulls | dropna(), fillna() | Drop or impute |
| Remove Duplicates | duplicated(), drop_duplicates() |  |
| Rename / Reformat | rename(), astype(), to_datetime() | For consistent formats |
| Filter/Subsets | df[df['x'] > 0], df[['x', 'y']] | Logic-based filtering |
| Feature Engineering | Math ops, dt accessor | New columns |
| Encode Categoricals | get_dummies(), .cat.codes | For ML algorithms |
| Scaling | StandardScaler, MinMaxScaler | Sklearn tools |
| Grouping / Aggregation | groupby(), agg() | For summaries |
| Merge / Join | merge(), concat() | Combining datasets |
| Export | to_csv(), to_excel() | Save preprocessed data |

---

### ✅ Interview Tip:

“In data science projects, I usually start with null handling and type casting, followed by outlier removal, encoding, and scaling. Pandas makes it easy to build repeatable pipelines with readable code.”

---

Would you like a **reusable preprocessing function or pipeline class** using Pandas and Scikit-learn that you can plug into your ML projects?

### Question 9: How do you set and reset index in pandas?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! Data preprocessing is a **core step in every data science pipeline** — and mastering the relevant **Pandas techniques** helps clean, transform, and prepare data efficiently before applying ML algorithms.

Here’s a comprehensive summary of **data preprocessing using Pandas** — with explanations, examples, and a **quick revision table** at the end.

---

### ✅ 1. Loading the Dataset

```python
import pandas as pd

df = pd.read_csv('data.csv')
df.head()
```

---

### ✅ 2. Understanding the Data

```python
df.shape          # (rows, columns)
df.columns        # List of column names
df.info()         # Data types and null counts
df.describe()     # Summary statistics
```

---

### ✅ 3. Handling Missing Values

### 🔹 Detect

```python
df.isnull().sum()        # Count nulls per column
```

### 🔹 Drop

```python
df.dropna()              # Drop rows with any NaN
df.dropna(axis=1)        # Drop columns with any NaN
```

### 🔹 Impute

```python
df.fillna(0)
df['col'].fillna(df['col'].mean(), inplace=True)
```

---

### ✅ 4. Handling Duplicates

```python
df.duplicated().sum()
df.drop_duplicates(inplace=True)
```

---

### ✅ 5. Renaming Columns

```python
df.rename(columns={'old_name': 'new_name'}, inplace=True)
```

---

### ✅ 6. Changing Data Types (Type Casting)

```python
df['date'] = pd.to_datetime(df['date'])
df['col'] = df['col'].astype(int)
```

---

### ✅ 7. Filtering and Subsetting

```python
df[df['col'] > 50]                      # Row filter
df[['col1', 'col2']]                   # Column subset
```

---

### ✅ 8. Feature Engineering

```python
df['new_col'] = df['col1'] / df['col2']  # Derived feature
df['year'] = df['date'].dt.year          # Extract from datetime
```

---

### ✅ 9. Encoding Categorical Variables

```python
pd.get_dummies(df, columns=['category_col'])           # One-hot encoding
df['label_encoded'] = df['category_col'].astype('category').cat.codes
```

---

### ✅ 10. Scaling/Normalization

Usually done with Scikit-learn:

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
df[['scaled_col']] = scaler.fit_transform(df[['col']])
```

---

### ✅ 11. Grouping & Aggregation

```python
df.groupby('category')['value'].mean()
df.groupby(['col1', 'col2']).agg({'value': ['sum', 'mean']})
```

---

### ✅ 12. Merging, Joining, and Concatenation

```python
pd.concat([df1, df2])                        # Stack vertically
pd.merge(df1, df2, on='key')                # SQL-style join
```

---

### ✅ 13. Exporting the Cleaned Data

```python
df.to_csv("cleaned_data.csv", index=False)
```

---

### 🧠 Summary Table: Quick Revision

| Step | Function / Method | Notes |
| --- | --- | --- |
| Load Data | pd.read_csv() | Read CSV, Excel, JSON, etc. |
| Inspect Data | df.info(), df.describe() | Data types, nulls, stats |
| Handle Nulls | dropna(), fillna() | Drop or impute |
| Remove Duplicates | duplicated(), drop_duplicates() |  |
| Rename / Reformat | rename(), astype(), to_datetime() | For consistent formats |
| Filter/Subsets | df[df['x'] > 0], df[['x', 'y']] | Logic-based filtering |
| Feature Engineering | Math ops, dt accessor | New columns |
| Encode Categoricals | get_dummies(), .cat.codes | For ML algorithms |
| Scaling | StandardScaler, MinMaxScaler | Sklearn tools |
| Grouping / Aggregation | groupby(), agg() | For summaries |
| Merge / Join | merge(), concat() | Combining datasets |
| Export | to_csv(), to_excel() | Save preprocessed data |

---

### ✅ Interview Tip:

“In data science projects, I usually start with null handling and type casting, followed by outlier removal, encoding, and scaling. Pandas makes it easy to build repeatable pipelines with readable code.”

---

Would you like a **reusable preprocessing function or pipeline class** using Pandas and Scikit-learn that you can plug into your ML projects?

### Question 10: What are multi-level indexes (MultiIndex) and when are they used?

**Source answer:** No corresponding answer was found in the linked conversation.

## Data Cleaning & Missing Values

### Question 11: How do you check for missing values in a DataFrame?

**Answer copied from the linked conversation:**

Great question, Himanshu! ✅ Handling **outliers** and **null values** is a critical step in data preprocessing that directly impacts the performance of your machine learning models.

Below is a comprehensive breakdown of **how to handle outliers and null values using Pandas**, along with examples and a summary table for quick revision.

---

### 🔷 1. Handling Null Values in Pandas

### 🔹 Step 1: Identify Null Values

```python
df.isnull().sum()       # Count nulls per column
df[df.isnull().any(axis=1)]  # Rows with any null value
```

---

### 🔹 Step 2: Drop Nulls

```python
df.dropna()                     # Drop rows with any null
df.dropna(axis=1)               # Drop columns with any null
df.dropna(subset=['col1'])      # Drop rows where 'col1' is null
```

---

### 🔹 Step 3: Impute/Fill Nulls

```python
# Fill with constant
df.fillna(0)

# Fill with statistical values
df['age'].fillna(df['age'].mean(), inplace=True)
df['city'].fillna(df['city'].mode()[0], inplace=True)

# Forward fill / Backward fill
df.fillna(method='ffill', inplace=True)
df.fillna(method='bfill', inplace=True)
```

---

### 🔷 2. Handling Outliers in Pandas

Outliers can distort model predictions, especially in regression problems.

### 🔹 Step 1: Detect Outliers

```python
Q1 = df['col'].quantile(0.25)
Q3 = df['col'].quantile(0.75)
IQR = Q3 - Q1
lower_bound = Q1 - 1.5 * IQR
upper_bound = Q3 + 1.5 * IQR

outliers = df[(df['col'] < lower_bound) | (df['col'] > upper_bound)]
```

```python
from scipy import stats
import numpy as np

z_scores = np.abs(stats.zscore(df['col']))
df_outliers = df[z_scores > 3]
```

---

### 🔹 Step 2: Handle Outliers

- **Remove** outliers:

```python
df_no_outliers = df[(df['col'] >= lower_bound) & (df['col'] <= upper_bound)]
```

- **Cap/Floor (Winsorization)**:

```python
df['col'] = np.where(df['col'] > upper_bound, upper_bound, df['col'])
df['col'] = np.where(df['col'] < lower_bound, lower_bound, df['col'])
```

- **Transform** data to reduce effect:

```python
df['col_log'] = np.log1p(df['col'])  # for skewed positive data
```

---

### 🧠 Summary Table: Nulls and Outliers Handling

| Task | Method | Function / Code |
| --- | --- | --- |
| Identify nulls | Count/locate nulls | df.isnull().sum() |
| Drop nulls | Remove rows/columns | df.dropna(), df.dropna(axis=1) |
| Impute nulls | Replace with value/stats | fillna(0), fillna(df['col'].mean()) |
| Forward/back fill | Time-series / sequential | method='ffill' or 'bfill' |
| Detect outliers (IQR) | Rule-based | IQR = Q3 - Q1 |
| Detect outliers (Z-score) | Statistical | zscore(df['col']) > 3 |
| Remove outliers | Keep only in-bound values | df[(col ≥ LB) & (col ≤ UB)] |
| Cap outliers | Winsorize | np.where(col > UB, UB, col) |
| Transform outliers | Log / sqrt transform | np.log1p(col) |

---

### ✅ Interview Tip:

"I usually start with checking missing values using `df.isnull().sum()`, then impute using mean/median/mode. For outliers, I prefer using IQR or Z-score methods and either cap or remove them depending on business impact."

---

Would you like a **reusable function** to automate missing value imputation and outlier handling in Pandas?

### Question 12: How can you drop or fill missing values? `dropna()`, `fillna()`

**Answer copied from the linked conversation:**

Great question, Himanshu! ✅ Handling **outliers** and **null values** is a critical step in data preprocessing that directly impacts the performance of your machine learning models.

Below is a comprehensive breakdown of **how to handle outliers and null values using Pandas**, along with examples and a summary table for quick revision.

---

### 🔷 1. Handling Null Values in Pandas

### 🔹 Step 1: Identify Null Values

```python
df.isnull().sum()       # Count nulls per column
df[df.isnull().any(axis=1)]  # Rows with any null value
```

---

### 🔹 Step 2: Drop Nulls

```python
df.dropna()                     # Drop rows with any null
df.dropna(axis=1)               # Drop columns with any null
df.dropna(subset=['col1'])      # Drop rows where 'col1' is null
```

---

### 🔹 Step 3: Impute/Fill Nulls

```python
# Fill with constant
df.fillna(0)

# Fill with statistical values
df['age'].fillna(df['age'].mean(), inplace=True)
df['city'].fillna(df['city'].mode()[0], inplace=True)

# Forward fill / Backward fill
df.fillna(method='ffill', inplace=True)
df.fillna(method='bfill', inplace=True)
```

---

### 🔷 2. Handling Outliers in Pandas

Outliers can distort model predictions, especially in regression problems.

### 🔹 Step 1: Detect Outliers

```python
Q1 = df['col'].quantile(0.25)
Q3 = df['col'].quantile(0.75)
IQR = Q3 - Q1
lower_bound = Q1 - 1.5 * IQR
upper_bound = Q3 + 1.5 * IQR

outliers = df[(df['col'] < lower_bound) | (df['col'] > upper_bound)]
```

```python
from scipy import stats
import numpy as np

z_scores = np.abs(stats.zscore(df['col']))
df_outliers = df[z_scores > 3]
```

---

### 🔹 Step 2: Handle Outliers

- **Remove** outliers:

```python
df_no_outliers = df[(df['col'] >= lower_bound) & (df['col'] <= upper_bound)]
```

- **Cap/Floor (Winsorization)**:

```python
df['col'] = np.where(df['col'] > upper_bound, upper_bound, df['col'])
df['col'] = np.where(df['col'] < lower_bound, lower_bound, df['col'])
```

- **Transform** data to reduce effect:

```python
df['col_log'] = np.log1p(df['col'])  # for skewed positive data
```

---

### 🧠 Summary Table: Nulls and Outliers Handling

| Task | Method | Function / Code |
| --- | --- | --- |
| Identify nulls | Count/locate nulls | df.isnull().sum() |
| Drop nulls | Remove rows/columns | df.dropna(), df.dropna(axis=1) |
| Impute nulls | Replace with value/stats | fillna(0), fillna(df['col'].mean()) |
| Forward/back fill | Time-series / sequential | method='ffill' or 'bfill' |
| Detect outliers (IQR) | Rule-based | IQR = Q3 - Q1 |
| Detect outliers (Z-score) | Statistical | zscore(df['col']) > 3 |
| Remove outliers | Keep only in-bound values | df[(col ≥ LB) & (col ≤ UB)] |
| Cap outliers | Winsorize | np.where(col > UB, UB, col) |
| Transform outliers | Log / sqrt transform | np.log1p(col) |

---

### ✅ Interview Tip:

"I usually start with checking missing values using `df.isnull().sum()`, then impute using mean/median/mode. For outliers, I prefer using IQR or Z-score methods and either cap or remove them depending on business impact."

---

Would you like a **reusable function** to automate missing value imputation and outlier handling in Pandas?

### Question 13: How do you identify and handle duplicates?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! Data preprocessing is a **core step in every data science pipeline** — and mastering the relevant **Pandas techniques** helps clean, transform, and prepare data efficiently before applying ML algorithms.

Here’s a comprehensive summary of **data preprocessing using Pandas** — with explanations, examples, and a **quick revision table** at the end.

---

### ✅ 1. Loading the Dataset

```python
import pandas as pd

df = pd.read_csv('data.csv')
df.head()
```

---

### ✅ 2. Understanding the Data

```python
df.shape          # (rows, columns)
df.columns        # List of column names
df.info()         # Data types and null counts
df.describe()     # Summary statistics
```

---

### ✅ 3. Handling Missing Values

### 🔹 Detect

```python
df.isnull().sum()        # Count nulls per column
```

### 🔹 Drop

```python
df.dropna()              # Drop rows with any NaN
df.dropna(axis=1)        # Drop columns with any NaN
```

### 🔹 Impute

```python
df.fillna(0)
df['col'].fillna(df['col'].mean(), inplace=True)
```

---

### ✅ 4. Handling Duplicates

```python
df.duplicated().sum()
df.drop_duplicates(inplace=True)
```

---

### ✅ 5. Renaming Columns

```python
df.rename(columns={'old_name': 'new_name'}, inplace=True)
```

---

### ✅ 6. Changing Data Types (Type Casting)

```python
df['date'] = pd.to_datetime(df['date'])
df['col'] = df['col'].astype(int)
```

---

### ✅ 7. Filtering and Subsetting

```python
df[df['col'] > 50]                      # Row filter
df[['col1', 'col2']]                   # Column subset
```

---

### ✅ 8. Feature Engineering

```python
df['new_col'] = df['col1'] / df['col2']  # Derived feature
df['year'] = df['date'].dt.year          # Extract from datetime
```

---

### ✅ 9. Encoding Categorical Variables

```python
pd.get_dummies(df, columns=['category_col'])           # One-hot encoding
df['label_encoded'] = df['category_col'].astype('category').cat.codes
```

---

### ✅ 10. Scaling/Normalization

Usually done with Scikit-learn:

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
df[['scaled_col']] = scaler.fit_transform(df[['col']])
```

---

### ✅ 11. Grouping & Aggregation

```python
df.groupby('category')['value'].mean()
df.groupby(['col1', 'col2']).agg({'value': ['sum', 'mean']})
```

---

### ✅ 12. Merging, Joining, and Concatenation

```python
pd.concat([df1, df2])                        # Stack vertically
pd.merge(df1, df2, on='key')                # SQL-style join
```

---

### ✅ 13. Exporting the Cleaned Data

```python
df.to_csv("cleaned_data.csv", index=False)
```

---

### 🧠 Summary Table: Quick Revision

| Step | Function / Method | Notes |
| --- | --- | --- |
| Load Data | pd.read_csv() | Read CSV, Excel, JSON, etc. |
| Inspect Data | df.info(), df.describe() | Data types, nulls, stats |
| Handle Nulls | dropna(), fillna() | Drop or impute |
| Remove Duplicates | duplicated(), drop_duplicates() |  |
| Rename / Reformat | rename(), astype(), to_datetime() | For consistent formats |
| Filter/Subsets | df[df['x'] > 0], df[['x', 'y']] | Logic-based filtering |
| Feature Engineering | Math ops, dt accessor | New columns |
| Encode Categoricals | get_dummies(), .cat.codes | For ML algorithms |
| Scaling | StandardScaler, MinMaxScaler | Sklearn tools |
| Grouping / Aggregation | groupby(), agg() | For summaries |
| Merge / Join | merge(), concat() | Combining datasets |
| Export | to_csv(), to_excel() | Save preprocessed data |

---

### ✅ Interview Tip:

“In data science projects, I usually start with null handling and type casting, followed by outlier removal, encoding, and scaling. Pandas makes it easy to build repeatable pipelines with readable code.”

---

Would you like a **reusable preprocessing function or pipeline class** using Pandas and Scikit-learn that you can plug into your ML projects?

### Question 14: How can you detect and handle outliers using pandas?

**Answer copied from the linked conversation:**

Great question, Himanshu! ✅ Handling **outliers** and **null values** is a critical step in data preprocessing that directly impacts the performance of your machine learning models.

Below is a comprehensive breakdown of **how to handle outliers and null values using Pandas**, along with examples and a summary table for quick revision.

---

### 🔷 1. Handling Null Values in Pandas

### 🔹 Step 1: Identify Null Values

```python
df.isnull().sum()       # Count nulls per column
df[df.isnull().any(axis=1)]  # Rows with any null value
```

---

### 🔹 Step 2: Drop Nulls

```python
df.dropna()                     # Drop rows with any null
df.dropna(axis=1)               # Drop columns with any null
df.dropna(subset=['col1'])      # Drop rows where 'col1' is null
```

---

### 🔹 Step 3: Impute/Fill Nulls

```python
# Fill with constant
df.fillna(0)

# Fill with statistical values
df['age'].fillna(df['age'].mean(), inplace=True)
df['city'].fillna(df['city'].mode()[0], inplace=True)

# Forward fill / Backward fill
df.fillna(method='ffill', inplace=True)
df.fillna(method='bfill', inplace=True)
```

---

### 🔷 2. Handling Outliers in Pandas

Outliers can distort model predictions, especially in regression problems.

### 🔹 Step 1: Detect Outliers

```python
Q1 = df['col'].quantile(0.25)
Q3 = df['col'].quantile(0.75)
IQR = Q3 - Q1
lower_bound = Q1 - 1.5 * IQR
upper_bound = Q3 + 1.5 * IQR

outliers = df[(df['col'] < lower_bound) | (df['col'] > upper_bound)]
```

```python
from scipy import stats
import numpy as np

z_scores = np.abs(stats.zscore(df['col']))
df_outliers = df[z_scores > 3]
```

---

### 🔹 Step 2: Handle Outliers

- **Remove** outliers:

```python
df_no_outliers = df[(df['col'] >= lower_bound) & (df['col'] <= upper_bound)]
```

- **Cap/Floor (Winsorization)**:

```python
df['col'] = np.where(df['col'] > upper_bound, upper_bound, df['col'])
df['col'] = np.where(df['col'] < lower_bound, lower_bound, df['col'])
```

- **Transform** data to reduce effect:

```python
df['col_log'] = np.log1p(df['col'])  # for skewed positive data
```

---

### 🧠 Summary Table: Nulls and Outliers Handling

| Task | Method | Function / Code |
| --- | --- | --- |
| Identify nulls | Count/locate nulls | df.isnull().sum() |
| Drop nulls | Remove rows/columns | df.dropna(), df.dropna(axis=1) |
| Impute nulls | Replace with value/stats | fillna(0), fillna(df['col'].mean()) |
| Forward/back fill | Time-series / sequential | method='ffill' or 'bfill' |
| Detect outliers (IQR) | Rule-based | IQR = Q3 - Q1 |
| Detect outliers (Z-score) | Statistical | zscore(df['col']) > 3 |
| Remove outliers | Keep only in-bound values | df[(col ≥ LB) & (col ≤ UB)] |
| Cap outliers | Winsorize | np.where(col > UB, UB, col) |
| Transform outliers | Log / sqrt transform | np.log1p(col) |

---

### ✅ Interview Tip:

"I usually start with checking missing values using `df.isnull().sum()`, then impute using mean/median/mode. For outliers, I prefer using IQR or Z-score methods and either cap or remove them depending on business impact."

---

Would you like a **reusable function** to automate missing value imputation and outlier handling in Pandas?

### Question 15: How do you replace values conditionally in a column?

**Answer copied from the linked conversation:**

Great question, Himanshu! ✅ Handling **outliers** and **null values** is a critical step in data preprocessing that directly impacts the performance of your machine learning models.

Below is a comprehensive breakdown of **how to handle outliers and null values using Pandas**, along with examples and a summary table for quick revision.

---

### 🔷 1. Handling Null Values in Pandas

### 🔹 Step 1: Identify Null Values

```python
df.isnull().sum()       # Count nulls per column
df[df.isnull().any(axis=1)]  # Rows with any null value
```

---

### 🔹 Step 2: Drop Nulls

```python
df.dropna()                     # Drop rows with any null
df.dropna(axis=1)               # Drop columns with any null
df.dropna(subset=['col1'])      # Drop rows where 'col1' is null
```

---

### 🔹 Step 3: Impute/Fill Nulls

```python
# Fill with constant
df.fillna(0)

# Fill with statistical values
df['age'].fillna(df['age'].mean(), inplace=True)
df['city'].fillna(df['city'].mode()[0], inplace=True)

# Forward fill / Backward fill
df.fillna(method='ffill', inplace=True)
df.fillna(method='bfill', inplace=True)
```

---

### 🔷 2. Handling Outliers in Pandas

Outliers can distort model predictions, especially in regression problems.

### 🔹 Step 1: Detect Outliers

```python
Q1 = df['col'].quantile(0.25)
Q3 = df['col'].quantile(0.75)
IQR = Q3 - Q1
lower_bound = Q1 - 1.5 * IQR
upper_bound = Q3 + 1.5 * IQR

outliers = df[(df['col'] < lower_bound) | (df['col'] > upper_bound)]
```

```python
from scipy import stats
import numpy as np

z_scores = np.abs(stats.zscore(df['col']))
df_outliers = df[z_scores > 3]
```

---

### 🔹 Step 2: Handle Outliers

- **Remove** outliers:

```python
df_no_outliers = df[(df['col'] >= lower_bound) & (df['col'] <= upper_bound)]
```

- **Cap/Floor (Winsorization)**:

```python
df['col'] = np.where(df['col'] > upper_bound, upper_bound, df['col'])
df['col'] = np.where(df['col'] < lower_bound, lower_bound, df['col'])
```

- **Transform** data to reduce effect:

```python
df['col_log'] = np.log1p(df['col'])  # for skewed positive data
```

---

### 🧠 Summary Table: Nulls and Outliers Handling

| Task | Method | Function / Code |
| --- | --- | --- |
| Identify nulls | Count/locate nulls | df.isnull().sum() |
| Drop nulls | Remove rows/columns | df.dropna(), df.dropna(axis=1) |
| Impute nulls | Replace with value/stats | fillna(0), fillna(df['col'].mean()) |
| Forward/back fill | Time-series / sequential | method='ffill' or 'bfill' |
| Detect outliers (IQR) | Rule-based | IQR = Q3 - Q1 |
| Detect outliers (Z-score) | Statistical | zscore(df['col']) > 3 |
| Remove outliers | Keep only in-bound values | df[(col ≥ LB) & (col ≤ UB)] |
| Cap outliers | Winsorize | np.where(col > UB, UB, col) |
| Transform outliers | Log / sqrt transform | np.log1p(col) |

---

### ✅ Interview Tip:

"I usually start with checking missing values using `df.isnull().sum()`, then impute using mean/median/mode. For outliers, I prefer using IQR or Z-score methods and either cap or remove them depending on business impact."

---

Would you like a **reusable function** to automate missing value imputation and outlier handling in Pandas?

## Data Manipulation & Transformation

### Question 16: How do you add, update, or delete columns in a DataFrame?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! Data preprocessing is a **core step in every data science pipeline** — and mastering the relevant **Pandas techniques** helps clean, transform, and prepare data efficiently before applying ML algorithms.

Here’s a comprehensive summary of **data preprocessing using Pandas** — with explanations, examples, and a **quick revision table** at the end.

---

### ✅ 1. Loading the Dataset

```python
import pandas as pd

df = pd.read_csv('data.csv')
df.head()
```

---

### ✅ 2. Understanding the Data

```python
df.shape          # (rows, columns)
df.columns        # List of column names
df.info()         # Data types and null counts
df.describe()     # Summary statistics
```

---

### ✅ 3. Handling Missing Values

### 🔹 Detect

```python
df.isnull().sum()        # Count nulls per column
```

### 🔹 Drop

```python
df.dropna()              # Drop rows with any NaN
df.dropna(axis=1)        # Drop columns with any NaN
```

### 🔹 Impute

```python
df.fillna(0)
df['col'].fillna(df['col'].mean(), inplace=True)
```

---

### ✅ 4. Handling Duplicates

```python
df.duplicated().sum()
df.drop_duplicates(inplace=True)
```

---

### ✅ 5. Renaming Columns

```python
df.rename(columns={'old_name': 'new_name'}, inplace=True)
```

---

### ✅ 6. Changing Data Types (Type Casting)

```python
df['date'] = pd.to_datetime(df['date'])
df['col'] = df['col'].astype(int)
```

---

### ✅ 7. Filtering and Subsetting

```python
df[df['col'] > 50]                      # Row filter
df[['col1', 'col2']]                   # Column subset
```

---

### ✅ 8. Feature Engineering

```python
df['new_col'] = df['col1'] / df['col2']  # Derived feature
df['year'] = df['date'].dt.year          # Extract from datetime
```

---

### ✅ 9. Encoding Categorical Variables

```python
pd.get_dummies(df, columns=['category_col'])           # One-hot encoding
df['label_encoded'] = df['category_col'].astype('category').cat.codes
```

---

### ✅ 10. Scaling/Normalization

Usually done with Scikit-learn:

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
df[['scaled_col']] = scaler.fit_transform(df[['col']])
```

---

### ✅ 11. Grouping & Aggregation

```python
df.groupby('category')['value'].mean()
df.groupby(['col1', 'col2']).agg({'value': ['sum', 'mean']})
```

---

### ✅ 12. Merging, Joining, and Concatenation

```python
pd.concat([df1, df2])                        # Stack vertically
pd.merge(df1, df2, on='key')                # SQL-style join
```

---

### ✅ 13. Exporting the Cleaned Data

```python
df.to_csv("cleaned_data.csv", index=False)
```

---

### 🧠 Summary Table: Quick Revision

| Step | Function / Method | Notes |
| --- | --- | --- |
| Load Data | pd.read_csv() | Read CSV, Excel, JSON, etc. |
| Inspect Data | df.info(), df.describe() | Data types, nulls, stats |
| Handle Nulls | dropna(), fillna() | Drop or impute |
| Remove Duplicates | duplicated(), drop_duplicates() |  |
| Rename / Reformat | rename(), astype(), to_datetime() | For consistent formats |
| Filter/Subsets | df[df['x'] > 0], df[['x', 'y']] | Logic-based filtering |
| Feature Engineering | Math ops, dt accessor | New columns |
| Encode Categoricals | get_dummies(), .cat.codes | For ML algorithms |
| Scaling | StandardScaler, MinMaxScaler | Sklearn tools |
| Grouping / Aggregation | groupby(), agg() | For summaries |
| Merge / Join | merge(), concat() | Combining datasets |
| Export | to_csv(), to_excel() | Save preprocessed data |

---

### ✅ Interview Tip:

“In data science projects, I usually start with null handling and type casting, followed by outlier removal, encoding, and scaling. Pandas makes it easy to build repeatable pipelines with readable code.”

---

Would you like a **reusable preprocessing function or pipeline class** using Pandas and Scikit-learn that you can plug into your ML projects?

### Question 17: What is the use of `apply()`, `map()`, and `applymap()` in pandas?

**Source answer:** No corresponding answer was found in the linked conversation.

### Question 18: What’s the difference between `replace()` and `where()`?

**Answer copied from the linked conversation:**

Great question, Himanshu! ✅ Handling **outliers** and **null values** is a critical step in data preprocessing that directly impacts the performance of your machine learning models.

Below is a comprehensive breakdown of **how to handle outliers and null values using Pandas**, along with examples and a summary table for quick revision.

---

### 🔷 1. Handling Null Values in Pandas

### 🔹 Step 1: Identify Null Values

```python
df.isnull().sum()       # Count nulls per column
df[df.isnull().any(axis=1)]  # Rows with any null value
```

---

### 🔹 Step 2: Drop Nulls

```python
df.dropna()                     # Drop rows with any null
df.dropna(axis=1)               # Drop columns with any null
df.dropna(subset=['col1'])      # Drop rows where 'col1' is null
```

---

### 🔹 Step 3: Impute/Fill Nulls

```python
# Fill with constant
df.fillna(0)

# Fill with statistical values
df['age'].fillna(df['age'].mean(), inplace=True)
df['city'].fillna(df['city'].mode()[0], inplace=True)

# Forward fill / Backward fill
df.fillna(method='ffill', inplace=True)
df.fillna(method='bfill', inplace=True)
```

---

### 🔷 2. Handling Outliers in Pandas

Outliers can distort model predictions, especially in regression problems.

### 🔹 Step 1: Detect Outliers

```python
Q1 = df['col'].quantile(0.25)
Q3 = df['col'].quantile(0.75)
IQR = Q3 - Q1
lower_bound = Q1 - 1.5 * IQR
upper_bound = Q3 + 1.5 * IQR

outliers = df[(df['col'] < lower_bound) | (df['col'] > upper_bound)]
```

```python
from scipy import stats
import numpy as np

z_scores = np.abs(stats.zscore(df['col']))
df_outliers = df[z_scores > 3]
```

---

### 🔹 Step 2: Handle Outliers

- **Remove** outliers:

```python
df_no_outliers = df[(df['col'] >= lower_bound) & (df['col'] <= upper_bound)]
```

- **Cap/Floor (Winsorization)**:

```python
df['col'] = np.where(df['col'] > upper_bound, upper_bound, df['col'])
df['col'] = np.where(df['col'] < lower_bound, lower_bound, df['col'])
```

- **Transform** data to reduce effect:

```python
df['col_log'] = np.log1p(df['col'])  # for skewed positive data
```

---

### 🧠 Summary Table: Nulls and Outliers Handling

| Task | Method | Function / Code |
| --- | --- | --- |
| Identify nulls | Count/locate nulls | df.isnull().sum() |
| Drop nulls | Remove rows/columns | df.dropna(), df.dropna(axis=1) |
| Impute nulls | Replace with value/stats | fillna(0), fillna(df['col'].mean()) |
| Forward/back fill | Time-series / sequential | method='ffill' or 'bfill' |
| Detect outliers (IQR) | Rule-based | IQR = Q3 - Q1 |
| Detect outliers (Z-score) | Statistical | zscore(df['col']) > 3 |
| Remove outliers | Keep only in-bound values | df[(col ≥ LB) & (col ≤ UB)] |
| Cap outliers | Winsorize | np.where(col > UB, UB, col) |
| Transform outliers | Log / sqrt transform | np.log1p(col) |

---

### ✅ Interview Tip:

"I usually start with checking missing values using `df.isnull().sum()`, then impute using mean/median/mode. For outliers, I prefer using IQR or Z-score methods and either cap or remove them depending on business impact."

---

Would you like a **reusable function** to automate missing value imputation and outlier handling in Pandas?

### Question 19: How do you rename columns or indexes?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! Data preprocessing is a **core step in every data science pipeline** — and mastering the relevant **Pandas techniques** helps clean, transform, and prepare data efficiently before applying ML algorithms.

Here’s a comprehensive summary of **data preprocessing using Pandas** — with explanations, examples, and a **quick revision table** at the end.

---

### ✅ 1. Loading the Dataset

```python
import pandas as pd

df = pd.read_csv('data.csv')
df.head()
```

---

### ✅ 2. Understanding the Data

```python
df.shape          # (rows, columns)
df.columns        # List of column names
df.info()         # Data types and null counts
df.describe()     # Summary statistics
```

---

### ✅ 3. Handling Missing Values

### 🔹 Detect

```python
df.isnull().sum()        # Count nulls per column
```

### 🔹 Drop

```python
df.dropna()              # Drop rows with any NaN
df.dropna(axis=1)        # Drop columns with any NaN
```

### 🔹 Impute

```python
df.fillna(0)
df['col'].fillna(df['col'].mean(), inplace=True)
```

---

### ✅ 4. Handling Duplicates

```python
df.duplicated().sum()
df.drop_duplicates(inplace=True)
```

---

### ✅ 5. Renaming Columns

```python
df.rename(columns={'old_name': 'new_name'}, inplace=True)
```

---

### ✅ 6. Changing Data Types (Type Casting)

```python
df['date'] = pd.to_datetime(df['date'])
df['col'] = df['col'].astype(int)
```

---

### ✅ 7. Filtering and Subsetting

```python
df[df['col'] > 50]                      # Row filter
df[['col1', 'col2']]                   # Column subset
```

---

### ✅ 8. Feature Engineering

```python
df['new_col'] = df['col1'] / df['col2']  # Derived feature
df['year'] = df['date'].dt.year          # Extract from datetime
```

---

### ✅ 9. Encoding Categorical Variables

```python
pd.get_dummies(df, columns=['category_col'])           # One-hot encoding
df['label_encoded'] = df['category_col'].astype('category').cat.codes
```

---

### ✅ 10. Scaling/Normalization

Usually done with Scikit-learn:

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
df[['scaled_col']] = scaler.fit_transform(df[['col']])
```

---

### ✅ 11. Grouping & Aggregation

```python
df.groupby('category')['value'].mean()
df.groupby(['col1', 'col2']).agg({'value': ['sum', 'mean']})
```

---

### ✅ 12. Merging, Joining, and Concatenation

```python
pd.concat([df1, df2])                        # Stack vertically
pd.merge(df1, df2, on='key')                # SQL-style join
```

---

### ✅ 13. Exporting the Cleaned Data

```python
df.to_csv("cleaned_data.csv", index=False)
```

---

### 🧠 Summary Table: Quick Revision

| Step | Function / Method | Notes |
| --- | --- | --- |
| Load Data | pd.read_csv() | Read CSV, Excel, JSON, etc. |
| Inspect Data | df.info(), df.describe() | Data types, nulls, stats |
| Handle Nulls | dropna(), fillna() | Drop or impute |
| Remove Duplicates | duplicated(), drop_duplicates() |  |
| Rename / Reformat | rename(), astype(), to_datetime() | For consistent formats |
| Filter/Subsets | df[df['x'] > 0], df[['x', 'y']] | Logic-based filtering |
| Feature Engineering | Math ops, dt accessor | New columns |
| Encode Categoricals | get_dummies(), .cat.codes | For ML algorithms |
| Scaling | StandardScaler, MinMaxScaler | Sklearn tools |
| Grouping / Aggregation | groupby(), agg() | For summaries |
| Merge / Join | merge(), concat() | Combining datasets |
| Export | to_csv(), to_excel() | Save preprocessed data |

---

### ✅ Interview Tip:

“In data science projects, I usually start with null handling and type casting, followed by outlier removal, encoding, and scaling. Pandas makes it easy to build repeatable pipelines with readable code.”

---

Would you like a **reusable preprocessing function or pipeline class** using Pandas and Scikit-learn that you can plug into your ML projects?

### Question 20: How do you perform arithmetic operations across DataFrame rows/columns?

**Source answer:** No corresponding answer was found in the linked conversation.

## GroupBy & Aggregation

### Question 21: How does `groupby()` work in pandas?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! The `groupby()` operation in Pandas is one of the most powerful and frequently used tools in data analysis and feature engineering.

---

### ✅ What is groupby() in Pandas?

The `groupby()` operation **splits the data** into groups based on some criteria (column values), **applies a function** (like `mean()`, `sum()`, etc.), and **combines the result**.

👉 It follows the **"Split → Apply → Combine"** paradigm.

---

### 🔷 Common Use Cases for groupby()

- Aggregating statistics (mean, sum, count) for groups
- Segmenting and filtering data
- Transforming data within groups
- Applying custom functions to groups

---

### 🔧 Syntax

```python
df.groupby('column_name').agg_function()
```

---

### ✅ 1. Basic Aggregation Example

```python
import pandas as pd

data = {
    'Department': ['Sales', 'Sales', 'HR', 'HR', 'IT'],
    'Employee': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'Salary': [50000, 60000, 45000, 47000, 70000]
}
df = pd.DataFrame(data)

df.groupby('Department')['Salary'].mean()
```

### Output:

```python
Department
HR       46000.0
IT       70000.0
Sales    55000.0
```

---

### ✅ 2. Multiple Aggregations

```python
df.groupby('Department')['Salary'].agg(['mean', 'max', 'min'])
```

---

### ✅ 3. Group by Multiple Columns

```python
df.groupby(['Department', 'Employee'])['Salary'].sum()
```

---

### ✅ 4. Using reset_index() to Flatten the Result

```python
grouped = df.groupby('Department')['Salary'].mean().reset_index()
```

---

### ✅ 5. Using transform() to Broadcast Aggregated Values Back

```python
df['Dept_Avg_Salary'] = df.groupby('Department')['Salary'].transform('mean')
```

---

### ✅ 6. Filtering Groups

```python
grouped = df.groupby('Department').filter(lambda x: x['Salary'].mean() > 50000)
```

---

### ✅ 7. Applying Custom Functions with apply()

```python
def top_n(df, n=1):
    return df.sort_values('Salary', ascending=False).head(n)

df.groupby('Department').apply(top_n, n=1)
```

---

### 🧠 Summary Table: groupby() in Pandas

| Feature | Description | Example Code |
| --- | --- | --- |
| Basic Grouping | Group by one column | df.groupby('col')['val'].mean() |
| Multiple Aggregations | Perform multiple stats on same group | agg(['mean', 'sum']) |
| Group by Multiple Columns | Hierarchical grouping | df.groupby(['col1', 'col2']) |
| Reset index | Flatten the groupby result | .reset_index() |
| Broadcast Aggregation Result | Add result back to original DataFrame | .transform('mean') |
| Filter Groups | Keep only groups satisfying condition | .filter(lambda x: ...) |
| Custom Function on Group | Apply user-defined logic | .apply(func) |

---

### ✅ Interview Tip

"I use `groupby()` for both exploration and feature engineering. `transform()` is especially useful when I want to compare individual values to their group-level stats."

---

Would you like a cheat sheet or a code snippet for real-world `groupby()` use cases like churn prediction, sales analysis, or customer segmentation?

### Question 22: How do you calculate mean, sum, count for grouped data?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! The `groupby()` operation in Pandas is one of the most powerful and frequently used tools in data analysis and feature engineering.

---

### ✅ What is groupby() in Pandas?

The `groupby()` operation **splits the data** into groups based on some criteria (column values), **applies a function** (like `mean()`, `sum()`, etc.), and **combines the result**.

👉 It follows the **"Split → Apply → Combine"** paradigm.

---

### 🔷 Common Use Cases for groupby()

- Aggregating statistics (mean, sum, count) for groups
- Segmenting and filtering data
- Transforming data within groups
- Applying custom functions to groups

---

### 🔧 Syntax

```python
df.groupby('column_name').agg_function()
```

---

### ✅ 1. Basic Aggregation Example

```python
import pandas as pd

data = {
    'Department': ['Sales', 'Sales', 'HR', 'HR', 'IT'],
    'Employee': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'Salary': [50000, 60000, 45000, 47000, 70000]
}
df = pd.DataFrame(data)

df.groupby('Department')['Salary'].mean()
```

### Output:

```python
Department
HR       46000.0
IT       70000.0
Sales    55000.0
```

---

### ✅ 2. Multiple Aggregations

```python
df.groupby('Department')['Salary'].agg(['mean', 'max', 'min'])
```

---

### ✅ 3. Group by Multiple Columns

```python
df.groupby(['Department', 'Employee'])['Salary'].sum()
```

---

### ✅ 4. Using reset_index() to Flatten the Result

```python
grouped = df.groupby('Department')['Salary'].mean().reset_index()
```

---

### ✅ 5. Using transform() to Broadcast Aggregated Values Back

```python
df['Dept_Avg_Salary'] = df.groupby('Department')['Salary'].transform('mean')
```

---

### ✅ 6. Filtering Groups

```python
grouped = df.groupby('Department').filter(lambda x: x['Salary'].mean() > 50000)
```

---

### ✅ 7. Applying Custom Functions with apply()

```python
def top_n(df, n=1):
    return df.sort_values('Salary', ascending=False).head(n)

df.groupby('Department').apply(top_n, n=1)
```

---

### 🧠 Summary Table: groupby() in Pandas

| Feature | Description | Example Code |
| --- | --- | --- |
| Basic Grouping | Group by one column | df.groupby('col')['val'].mean() |
| Multiple Aggregations | Perform multiple stats on same group | agg(['mean', 'sum']) |
| Group by Multiple Columns | Hierarchical grouping | df.groupby(['col1', 'col2']) |
| Reset index | Flatten the groupby result | .reset_index() |
| Broadcast Aggregation Result | Add result back to original DataFrame | .transform('mean') |
| Filter Groups | Keep only groups satisfying condition | .filter(lambda x: ...) |
| Custom Function on Group | Apply user-defined logic | .apply(func) |

---

### ✅ Interview Tip

"I use `groupby()` for both exploration and feature engineering. `transform()` is especially useful when I want to compare individual values to their group-level stats."

---

Would you like a cheat sheet or a code snippet for real-world `groupby()` use cases like churn prediction, sales analysis, or customer segmentation?

### Question 23: How do you apply custom functions to groups?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! The `groupby()` operation in Pandas is one of the most powerful and frequently used tools in data analysis and feature engineering.

---

### ✅ What is groupby() in Pandas?

The `groupby()` operation **splits the data** into groups based on some criteria (column values), **applies a function** (like `mean()`, `sum()`, etc.), and **combines the result**.

👉 It follows the **"Split → Apply → Combine"** paradigm.

---

### 🔷 Common Use Cases for groupby()

- Aggregating statistics (mean, sum, count) for groups
- Segmenting and filtering data
- Transforming data within groups
- Applying custom functions to groups

---

### 🔧 Syntax

```python
df.groupby('column_name').agg_function()
```

---

### ✅ 1. Basic Aggregation Example

```python
import pandas as pd

data = {
    'Department': ['Sales', 'Sales', 'HR', 'HR', 'IT'],
    'Employee': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'Salary': [50000, 60000, 45000, 47000, 70000]
}
df = pd.DataFrame(data)

df.groupby('Department')['Salary'].mean()
```

### Output:

```python
Department
HR       46000.0
IT       70000.0
Sales    55000.0
```

---

### ✅ 2. Multiple Aggregations

```python
df.groupby('Department')['Salary'].agg(['mean', 'max', 'min'])
```

---

### ✅ 3. Group by Multiple Columns

```python
df.groupby(['Department', 'Employee'])['Salary'].sum()
```

---

### ✅ 4. Using reset_index() to Flatten the Result

```python
grouped = df.groupby('Department')['Salary'].mean().reset_index()
```

---

### ✅ 5. Using transform() to Broadcast Aggregated Values Back

```python
df['Dept_Avg_Salary'] = df.groupby('Department')['Salary'].transform('mean')
```

---

### ✅ 6. Filtering Groups

```python
grouped = df.groupby('Department').filter(lambda x: x['Salary'].mean() > 50000)
```

---

### ✅ 7. Applying Custom Functions with apply()

```python
def top_n(df, n=1):
    return df.sort_values('Salary', ascending=False).head(n)

df.groupby('Department').apply(top_n, n=1)
```

---

### 🧠 Summary Table: groupby() in Pandas

| Feature | Description | Example Code |
| --- | --- | --- |
| Basic Grouping | Group by one column | df.groupby('col')['val'].mean() |
| Multiple Aggregations | Perform multiple stats on same group | agg(['mean', 'sum']) |
| Group by Multiple Columns | Hierarchical grouping | df.groupby(['col1', 'col2']) |
| Reset index | Flatten the groupby result | .reset_index() |
| Broadcast Aggregation Result | Add result back to original DataFrame | .transform('mean') |
| Filter Groups | Keep only groups satisfying condition | .filter(lambda x: ...) |
| Custom Function on Group | Apply user-defined logic | .apply(func) |

---

### ✅ Interview Tip

"I use `groupby()` for both exploration and feature engineering. `transform()` is especially useful when I want to compare individual values to their group-level stats."

---

Would you like a cheat sheet or a code snippet for real-world `groupby()` use cases like churn prediction, sales analysis, or customer segmentation?

### Question 24: What is the difference between `agg()` and `transform()`?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! The `groupby()` operation in Pandas is one of the most powerful and frequently used tools in data analysis and feature engineering.

---

### ✅ What is groupby() in Pandas?

The `groupby()` operation **splits the data** into groups based on some criteria (column values), **applies a function** (like `mean()`, `sum()`, etc.), and **combines the result**.

👉 It follows the **"Split → Apply → Combine"** paradigm.

---

### 🔷 Common Use Cases for groupby()

- Aggregating statistics (mean, sum, count) for groups
- Segmenting and filtering data
- Transforming data within groups
- Applying custom functions to groups

---

### 🔧 Syntax

```python
df.groupby('column_name').agg_function()
```

---

### ✅ 1. Basic Aggregation Example

```python
import pandas as pd

data = {
    'Department': ['Sales', 'Sales', 'HR', 'HR', 'IT'],
    'Employee': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'Salary': [50000, 60000, 45000, 47000, 70000]
}
df = pd.DataFrame(data)

df.groupby('Department')['Salary'].mean()
```

### Output:

```python
Department
HR       46000.0
IT       70000.0
Sales    55000.0
```

---

### ✅ 2. Multiple Aggregations

```python
df.groupby('Department')['Salary'].agg(['mean', 'max', 'min'])
```

---

### ✅ 3. Group by Multiple Columns

```python
df.groupby(['Department', 'Employee'])['Salary'].sum()
```

---

### ✅ 4. Using reset_index() to Flatten the Result

```python
grouped = df.groupby('Department')['Salary'].mean().reset_index()
```

---

### ✅ 5. Using transform() to Broadcast Aggregated Values Back

```python
df['Dept_Avg_Salary'] = df.groupby('Department')['Salary'].transform('mean')
```

---

### ✅ 6. Filtering Groups

```python
grouped = df.groupby('Department').filter(lambda x: x['Salary'].mean() > 50000)
```

---

### ✅ 7. Applying Custom Functions with apply()

```python
def top_n(df, n=1):
    return df.sort_values('Salary', ascending=False).head(n)

df.groupby('Department').apply(top_n, n=1)
```

---

### 🧠 Summary Table: groupby() in Pandas

| Feature | Description | Example Code |
| --- | --- | --- |
| Basic Grouping | Group by one column | df.groupby('col')['val'].mean() |
| Multiple Aggregations | Perform multiple stats on same group | agg(['mean', 'sum']) |
| Group by Multiple Columns | Hierarchical grouping | df.groupby(['col1', 'col2']) |
| Reset index | Flatten the groupby result | .reset_index() |
| Broadcast Aggregation Result | Add result back to original DataFrame | .transform('mean') |
| Filter Groups | Keep only groups satisfying condition | .filter(lambda x: ...) |
| Custom Function on Group | Apply user-defined logic | .apply(func) |

---

### ✅ Interview Tip

"I use `groupby()` for both exploration and feature engineering. `transform()` is especially useful when I want to compare individual values to their group-level stats."

---

Would you like a cheat sheet or a code snippet for real-world `groupby()` use cases like churn prediction, sales analysis, or customer segmentation?

### Question 25: How do you perform multi-level grouping and aggregation?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! The `groupby()` operation in Pandas is one of the most powerful and frequently used tools in data analysis and feature engineering.

---

### ✅ What is groupby() in Pandas?

The `groupby()` operation **splits the data** into groups based on some criteria (column values), **applies a function** (like `mean()`, `sum()`, etc.), and **combines the result**.

👉 It follows the **"Split → Apply → Combine"** paradigm.

---

### 🔷 Common Use Cases for groupby()

- Aggregating statistics (mean, sum, count) for groups
- Segmenting and filtering data
- Transforming data within groups
- Applying custom functions to groups

---

### 🔧 Syntax

```python
df.groupby('column_name').agg_function()
```

---

### ✅ 1. Basic Aggregation Example

```python
import pandas as pd

data = {
    'Department': ['Sales', 'Sales', 'HR', 'HR', 'IT'],
    'Employee': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'Salary': [50000, 60000, 45000, 47000, 70000]
}
df = pd.DataFrame(data)

df.groupby('Department')['Salary'].mean()
```

### Output:

```python
Department
HR       46000.0
IT       70000.0
Sales    55000.0
```

---

### ✅ 2. Multiple Aggregations

```python
df.groupby('Department')['Salary'].agg(['mean', 'max', 'min'])
```

---

### ✅ 3. Group by Multiple Columns

```python
df.groupby(['Department', 'Employee'])['Salary'].sum()
```

---

### ✅ 4. Using reset_index() to Flatten the Result

```python
grouped = df.groupby('Department')['Salary'].mean().reset_index()
```

---

### ✅ 5. Using transform() to Broadcast Aggregated Values Back

```python
df['Dept_Avg_Salary'] = df.groupby('Department')['Salary'].transform('mean')
```

---

### ✅ 6. Filtering Groups

```python
grouped = df.groupby('Department').filter(lambda x: x['Salary'].mean() > 50000)
```

---

### ✅ 7. Applying Custom Functions with apply()

```python
def top_n(df, n=1):
    return df.sort_values('Salary', ascending=False).head(n)

df.groupby('Department').apply(top_n, n=1)
```

---

### 🧠 Summary Table: groupby() in Pandas

| Feature | Description | Example Code |
| --- | --- | --- |
| Basic Grouping | Group by one column | df.groupby('col')['val'].mean() |
| Multiple Aggregations | Perform multiple stats on same group | agg(['mean', 'sum']) |
| Group by Multiple Columns | Hierarchical grouping | df.groupby(['col1', 'col2']) |
| Reset index | Flatten the groupby result | .reset_index() |
| Broadcast Aggregation Result | Add result back to original DataFrame | .transform('mean') |
| Filter Groups | Keep only groups satisfying condition | .filter(lambda x: ...) |
| Custom Function on Group | Apply user-defined logic | .apply(func) |

---

### ✅ Interview Tip

"I use `groupby()` for both exploration and feature engineering. `transform()` is especially useful when I want to compare individual values to their group-level stats."

---

Would you like a cheat sheet or a code snippet for real-world `groupby()` use cases like churn prediction, sales analysis, or customer segmentation?

## Merging, Joining, and Concatenation

### Question 26: What is the difference between `merge()`, `join()`, and `concat()`?

**Answer copied from the linked conversation:**

Great question, Himanshu! Merging and joining DataFrames is a core concept in data preprocessing, especially when working with relational datasets or combining multiple sources of information — very common in **data science pipelines**.

---

### ✅ Part 1: How to Merge and Join DataFrames in Pandas

### 1. Using merge()

The `merge()` function in pandas is similar to SQL joins and allows you to combine rows from two DataFrames based on a **key column**.

```python
pd.merge(left_df, right_df, how='inner', on='key_column')
```

### 🔹 Example:

```python
import pandas as pd

df1 = pd.DataFrame({
    'emp_id': [1, 2, 3],
    'name': ['Alice', 'Bob', 'Charlie']
})

df2 = pd.DataFrame({
    'emp_id': [1, 2, 4],
    'salary': [50000, 60000, 70000]
})

merged_df = pd.merge(df1, df2, how='inner', on='emp_id')
```

📤 **Output**:

```python
emp_id    name  salary
0       1   Alice   50000
1       2     Bob   60000
```

---

### 2. Using join()

The `join()` method is used to combine columns of another DataFrame using **index** or a key column.

```python
df1.join(df2, how='left')
```

### 🔹 Example:

```python
df1 = df1.set_index('emp_id')
df2 = df2.set_index('emp_id')

joined_df = df1.join(df2, how='inner')
```

📤 **Output**:

```python
name  salary
emp_id
1        Alice   50000
2          Bob   60000
```

---

### 3. Using concat()

Use `concat()` when you want to **stack** DataFrames vertically (`axis=0`) or horizontally (`axis=1`).

```python
pd.concat([df1, df2], axis=1)
```

---

### ✅ Part 2: Difference Between Merge and Join in Pandas

| Feature | merge() | join() |
| --- | --- | --- |
| Similar to SQL | Yes (Explicit control over keys) | Partial SQL-like join via index |
| Join Key | Column(s) specified in on | Uses index by default |
| Flexibility | High – can join on multiple columns | Limited – works mainly on index |
| Syntax | pd.merge(df1, df2, on='key') | df1.join(df2) |
| Default Join Type | inner | left |
| Use Case | When keys are columns and you need control | When joining on index |

---

### 🧠 Join Types in Both merge() and join()

| Type | Description |
| --- | --- |
| inner | Only matching keys from both DataFrames |
| left | All rows from left DataFrame, matching from right |
| right | All rows from right DataFrame, matching from left |
| outer | All keys from both; fill missing with NaNs |

---

### ✅ Interview Tip:

“If I need fine control over join keys and conditions (like multiple keys or suffixes for column name conflicts), I prefer `merge()`. For simple index-based joins, especially when working with time series or hierarchically indexed data, `join()` is faster and cleaner.”

---

Would you like real-life examples of merge/join in customer churn, sales forecasting, or fraud detection datasets?

### Question 27: How do you perform inner, left, right, and outer joins in pandas?

**Answer copied from the linked conversation:**

Sure, Himanshu! Here's a **comprehensive summary of different types of joins/merges in Pandas**, including **anti-joins**, in a structured format ideal for quick interview revision. 🧠✅

---

### 🔧 Types of Merge/Join in Pandas

| Join Type | Description | Code Example | Result Contains |
| --- | --- | --- | --- |
| Inner | Only matching rows in both DataFrames | pd.merge(df1, df2, how='inner', on='key') | Intersection of keys |
| Left | All rows from df1, matching rows from df2 | pd.merge(df1, df2, how='left', on='key') | All keys from left (df1), matched from df2 |
| Right | All rows from df2, matching rows from df1 | pd.merge(df1, df2, how='right', on='key') | All keys from right (df2), matched from df1 |
| Outer | All rows from both, NaN where no match exists | pd.merge(df1, df2, how='outer', on='key') | Union of keys from both |
| Cross Join | Cartesian product (all combinations of rows from both) | pd.merge(df1, df2, how='cross') (Pandas 1.2+) | All combinations (n × m rows) |
| Anti Join | Rows from one table where there is no match in the other | See example below | Only non-matching rows |

---

### 🔥 Example: DataFrames

```python
import pandas as pd

df1 = pd.DataFrame({'id': [1, 2, 3], 'name': ['Alice', 'Bob', 'Charlie']})
df2 = pd.DataFrame({'id': [2, 3, 4], 'score': [80, 90, 70]})
```

---

### 🔍 Anti Join in Pandas (Left-only)

**Goal**: Get rows from `df1` where `id` is **not present** in `df2`.

```python
anti_join_df = df1[~df1['id'].isin(df2['id'])]
```

📤 **Output**:

```python
id   name
0   1  Alice
```

You can do **right-only** similarly:

```python
right_only = df2[~df2['id'].isin(df1['id'])]
```

---

### 📋 Summary Table: Merge Types in Pandas

| Join Type | Matching? | Includes Unmatched From | Code Example |
| --- | --- | --- | --- |
| Inner Join | ✅ In both | ❌ | merge(df1, df2, how='inner', on='key') |
| Left Join | ✅ & left-only | ✅ df1 | merge(df1, df2, how='left', on='key') |
| Right Join | ✅ & right-only | ✅ df2 | merge(df1, df2, how='right', on='key') |
| Outer Join | ✅ & all others | ✅ df1 & df2 | merge(df1, df2, how='outer', on='key') |
| Cross Join | ❌ | All row pairs | merge(df1, df2, how='cross') |
| Anti Join | ❌ Only in one | df1 or df2 only | df1[~df1['key'].isin(df2['key'])] |

---

### ✅ Interview Tip:

“In my projects, I often use left joins when working with feature-enriched datasets and anti-joins for identifying unmatched records or anomalies. Knowing how to implement anti-joins manually using `isin()` is very helpful.”

---

Let me know if you'd like a **diagram or visual cheat sheet** to better understand join behavior!

### Question 28: How do you concatenate multiple DataFrames vertically or horizontally?

**Answer copied from the linked conversation:**

Great question, Himanshu! Merging and joining DataFrames is a core concept in data preprocessing, especially when working with relational datasets or combining multiple sources of information — very common in **data science pipelines**.

---

### ✅ Part 1: How to Merge and Join DataFrames in Pandas

### 1. Using merge()

The `merge()` function in pandas is similar to SQL joins and allows you to combine rows from two DataFrames based on a **key column**.

```python
pd.merge(left_df, right_df, how='inner', on='key_column')
```

### 🔹 Example:

```python
import pandas as pd

df1 = pd.DataFrame({
    'emp_id': [1, 2, 3],
    'name': ['Alice', 'Bob', 'Charlie']
})

df2 = pd.DataFrame({
    'emp_id': [1, 2, 4],
    'salary': [50000, 60000, 70000]
})

merged_df = pd.merge(df1, df2, how='inner', on='emp_id')
```

📤 **Output**:

```python
emp_id    name  salary
0       1   Alice   50000
1       2     Bob   60000
```

---

### 2. Using join()

The `join()` method is used to combine columns of another DataFrame using **index** or a key column.

```python
df1.join(df2, how='left')
```

### 🔹 Example:

```python
df1 = df1.set_index('emp_id')
df2 = df2.set_index('emp_id')

joined_df = df1.join(df2, how='inner')
```

📤 **Output**:

```python
name  salary
emp_id
1        Alice   50000
2          Bob   60000
```

---

### 3. Using concat()

Use `concat()` when you want to **stack** DataFrames vertically (`axis=0`) or horizontally (`axis=1`).

```python
pd.concat([df1, df2], axis=1)
```

---

### ✅ Part 2: Difference Between Merge and Join in Pandas

| Feature | merge() | join() |
| --- | --- | --- |
| Similar to SQL | Yes (Explicit control over keys) | Partial SQL-like join via index |
| Join Key | Column(s) specified in on | Uses index by default |
| Flexibility | High – can join on multiple columns | Limited – works mainly on index |
| Syntax | pd.merge(df1, df2, on='key') | df1.join(df2) |
| Default Join Type | inner | left |
| Use Case | When keys are columns and you need control | When joining on index |

---

### 🧠 Join Types in Both merge() and join()

| Type | Description |
| --- | --- |
| inner | Only matching keys from both DataFrames |
| left | All rows from left DataFrame, matching from right |
| right | All rows from right DataFrame, matching from left |
| outer | All keys from both; fill missing with NaNs |

---

### ✅ Interview Tip:

“If I need fine control over join keys and conditions (like multiple keys or suffixes for column name conflicts), I prefer `merge()`. For simple index-based joins, especially when working with time series or hierarchically indexed data, `join()` is faster and cleaner.”

---

Would you like real-life examples of merge/join in customer churn, sales forecasting, or fraud detection datasets?

### Question 29: How do you merge on multiple keys?

**Answer copied from the linked conversation:**

Great question, Himanshu! Merging and joining DataFrames is a core concept in data preprocessing, especially when working with relational datasets or combining multiple sources of information — very common in **data science pipelines**.

---

### ✅ Part 1: How to Merge and Join DataFrames in Pandas

### 1. Using merge()

The `merge()` function in pandas is similar to SQL joins and allows you to combine rows from two DataFrames based on a **key column**.

```python
pd.merge(left_df, right_df, how='inner', on='key_column')
```

### 🔹 Example:

```python
import pandas as pd

df1 = pd.DataFrame({
    'emp_id': [1, 2, 3],
    'name': ['Alice', 'Bob', 'Charlie']
})

df2 = pd.DataFrame({
    'emp_id': [1, 2, 4],
    'salary': [50000, 60000, 70000]
})

merged_df = pd.merge(df1, df2, how='inner', on='emp_id')
```

📤 **Output**:

```python
emp_id    name  salary
0       1   Alice   50000
1       2     Bob   60000
```

---

### 2. Using join()

The `join()` method is used to combine columns of another DataFrame using **index** or a key column.

```python
df1.join(df2, how='left')
```

### 🔹 Example:

```python
df1 = df1.set_index('emp_id')
df2 = df2.set_index('emp_id')

joined_df = df1.join(df2, how='inner')
```

📤 **Output**:

```python
name  salary
emp_id
1        Alice   50000
2          Bob   60000
```

---

### 3. Using concat()

Use `concat()` when you want to **stack** DataFrames vertically (`axis=0`) or horizontally (`axis=1`).

```python
pd.concat([df1, df2], axis=1)
```

---

### ✅ Part 2: Difference Between Merge and Join in Pandas

| Feature | merge() | join() |
| --- | --- | --- |
| Similar to SQL | Yes (Explicit control over keys) | Partial SQL-like join via index |
| Join Key | Column(s) specified in on | Uses index by default |
| Flexibility | High – can join on multiple columns | Limited – works mainly on index |
| Syntax | pd.merge(df1, df2, on='key') | df1.join(df2) |
| Default Join Type | inner | left |
| Use Case | When keys are columns and you need control | When joining on index |

---

### 🧠 Join Types in Both merge() and join()

| Type | Description |
| --- | --- |
| inner | Only matching keys from both DataFrames |
| left | All rows from left DataFrame, matching from right |
| right | All rows from right DataFrame, matching from left |
| outer | All keys from both; fill missing with NaNs |

---

### ✅ Interview Tip:

“If I need fine control over join keys and conditions (like multiple keys or suffixes for column name conflicts), I prefer `merge()`. For simple index-based joins, especially when working with time series or hierarchically indexed data, `join()` is faster and cleaner.”

---

Would you like real-life examples of merge/join in customer churn, sales forecasting, or fraud detection datasets?

### Question 30: What happens when there are mismatched indexes while merging?

**Answer copied from the linked conversation:**

Great question, Himanshu! Merging and joining DataFrames is a core concept in data preprocessing, especially when working with relational datasets or combining multiple sources of information — very common in **data science pipelines**.

---

### ✅ Part 1: How to Merge and Join DataFrames in Pandas

### 1. Using merge()

The `merge()` function in pandas is similar to SQL joins and allows you to combine rows from two DataFrames based on a **key column**.

```python
pd.merge(left_df, right_df, how='inner', on='key_column')
```

### 🔹 Example:

```python
import pandas as pd

df1 = pd.DataFrame({
    'emp_id': [1, 2, 3],
    'name': ['Alice', 'Bob', 'Charlie']
})

df2 = pd.DataFrame({
    'emp_id': [1, 2, 4],
    'salary': [50000, 60000, 70000]
})

merged_df = pd.merge(df1, df2, how='inner', on='emp_id')
```

📤 **Output**:

```python
emp_id    name  salary
0       1   Alice   50000
1       2     Bob   60000
```

---

### 2. Using join()

The `join()` method is used to combine columns of another DataFrame using **index** or a key column.

```python
df1.join(df2, how='left')
```

### 🔹 Example:

```python
df1 = df1.set_index('emp_id')
df2 = df2.set_index('emp_id')

joined_df = df1.join(df2, how='inner')
```

📤 **Output**:

```python
name  salary
emp_id
1        Alice   50000
2          Bob   60000
```

---

### 3. Using concat()

Use `concat()` when you want to **stack** DataFrames vertically (`axis=0`) or horizontally (`axis=1`).

```python
pd.concat([df1, df2], axis=1)
```

---

### ✅ Part 2: Difference Between Merge and Join in Pandas

| Feature | merge() | join() |
| --- | --- | --- |
| Similar to SQL | Yes (Explicit control over keys) | Partial SQL-like join via index |
| Join Key | Column(s) specified in on | Uses index by default |
| Flexibility | High – can join on multiple columns | Limited – works mainly on index |
| Syntax | pd.merge(df1, df2, on='key') | df1.join(df2) |
| Default Join Type | inner | left |
| Use Case | When keys are columns and you need control | When joining on index |

---

### 🧠 Join Types in Both merge() and join()

| Type | Description |
| --- | --- |
| inner | Only matching keys from both DataFrames |
| left | All rows from left DataFrame, matching from right |
| right | All rows from right DataFrame, matching from left |
| outer | All keys from both; fill missing with NaNs |

---

### ✅ Interview Tip:

“If I need fine control over join keys and conditions (like multiple keys or suffixes for column name conflicts), I prefer `merge()`. For simple index-based joins, especially when working with time series or hierarchically indexed data, `join()` is faster and cleaner.”

---

Would you like real-life examples of merge/join in customer churn, sales forecasting, or fraud detection datasets?

## Datetime Handling

### Question 31: How do you convert a column to datetime format?

**Answer copied from the linked conversation:**

Excellent questions—these are **core pandas operations** that are essential for **time series data preprocessing and analysis** in data science interviews.

---

### ✅ 1. How do you convert a column to datetime format?

You can use **`pd.to_datetime()`** to convert a column to datetime.

```python
import pandas as pd

df = pd.DataFrame({'date': ['2023-01-01', '2023-05-12', '2023-12-25']})
df['date'] = pd.to_datetime(df['date'])
print(df.dtypes)
```

✅ **Tip:** If the format is ambiguous or not standard, specify the `format`:

```python
df['date'] = pd.to_datetime(df['date'], format='%d-%m-%Y')
```

---

### ✅ 2. How do you extract year, month, weekday from a datetime column?

Once the column is converted to datetime:

```python
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['weekday'] = df['date'].dt.day_name()   # e.g., 'Monday'
```

You can also extract:

```python
df['day'] = df['date'].dt.day
df['hour'] = df['date'].dt.hour
df['week'] = df['date'].dt.isocalendar().week
df['quarter'] = df['date'].dt.quarter
```

---

### ✅ 3. How do you filter data between two dates?

Assuming `df['date']` is in datetime format:

```python
start = '2023-01-01'
end = '2023-06-30'
filtered_df = df[(df['date'] >= start) & (df['date'] <= end)]
```

Or using `pd.Timestamp` objects:

```python
filtered_df = df[(df['date'] >= pd.Timestamp('2023-01-01')) &
                 (df['date'] <= pd.Timestamp('2023-06-30'))]
```

✅ Tip: Can also filter using **datetime index** (see next point).

---

### ✅ 4. What is a datetime index and how is it useful in time series analysis?

A **DatetimeIndex** makes time series operations fast and intuitive. It’s created when you set a datetime column as the index.

```python
df.set_index('date', inplace=True)
print(df.index)  # DatetimeIndex
```

### 🔹 Benefits of DatetimeIndex:

| Feature | Example |
| --- | --- |
| Time-based slicing | df['2023-01'] or df['2023-01-01':'2023-01-15'] |
| Resampling | df.resample('M').mean() — monthly average |
| Rolling windows | df.rolling(window=3).mean() |
| Time zone handling | df.tz_localize('UTC') |
| Frequency setting | df.asfreq('D') — convert to daily freq |

---

### ✅ Summary Table for Quick Revision

| Task | Method / Attribute | Example Code |
| --- | --- | --- |
| Convert to datetime | pd.to_datetime() | df['date'] = pd.to_datetime(df['date']) |
| Extract year, month, weekday | .dt.year, .dt.month, .dt.day_name() | df['month'] = df['date'].dt.month |
| Filter between dates | Boolean filtering | df[(df['date'] >= '2023-01') & (df['date'] <= ...)] |
| Set datetime index | set_index() | df.set_index('date', inplace=True) |
| Slice by time | Slicing with DatetimeIndex | df['2023-01':'2023-02'] |
| Resample | resample() | df.resample('M').mean() |
| Rolling average/sum | rolling() | df.rolling(3).mean() |
| Change frequency | asfreq() | df.asfreq('D') |

---

Would you like a **cheat sheet PDF** or **interactive notebook** for time series tasks?

### Question 32: How do you extract year, month, weekday from a datetime column?

**Answer copied from the linked conversation:**

Excellent questions—these are **core pandas operations** that are essential for **time series data preprocessing and analysis** in data science interviews.

---

### ✅ 1. How do you convert a column to datetime format?

You can use **`pd.to_datetime()`** to convert a column to datetime.

```python
import pandas as pd

df = pd.DataFrame({'date': ['2023-01-01', '2023-05-12', '2023-12-25']})
df['date'] = pd.to_datetime(df['date'])
print(df.dtypes)
```

✅ **Tip:** If the format is ambiguous or not standard, specify the `format`:

```python
df['date'] = pd.to_datetime(df['date'], format='%d-%m-%Y')
```

---

### ✅ 2. How do you extract year, month, weekday from a datetime column?

Once the column is converted to datetime:

```python
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['weekday'] = df['date'].dt.day_name()   # e.g., 'Monday'
```

You can also extract:

```python
df['day'] = df['date'].dt.day
df['hour'] = df['date'].dt.hour
df['week'] = df['date'].dt.isocalendar().week
df['quarter'] = df['date'].dt.quarter
```

---

### ✅ 3. How do you filter data between two dates?

Assuming `df['date']` is in datetime format:

```python
start = '2023-01-01'
end = '2023-06-30'
filtered_df = df[(df['date'] >= start) & (df['date'] <= end)]
```

Or using `pd.Timestamp` objects:

```python
filtered_df = df[(df['date'] >= pd.Timestamp('2023-01-01')) &
                 (df['date'] <= pd.Timestamp('2023-06-30'))]
```

✅ Tip: Can also filter using **datetime index** (see next point).

---

### ✅ 4. What is a datetime index and how is it useful in time series analysis?

A **DatetimeIndex** makes time series operations fast and intuitive. It’s created when you set a datetime column as the index.

```python
df.set_index('date', inplace=True)
print(df.index)  # DatetimeIndex
```

### 🔹 Benefits of DatetimeIndex:

| Feature | Example |
| --- | --- |
| Time-based slicing | df['2023-01'] or df['2023-01-01':'2023-01-15'] |
| Resampling | df.resample('M').mean() — monthly average |
| Rolling windows | df.rolling(window=3).mean() |
| Time zone handling | df.tz_localize('UTC') |
| Frequency setting | df.asfreq('D') — convert to daily freq |

---

### ✅ Summary Table for Quick Revision

| Task | Method / Attribute | Example Code |
| --- | --- | --- |
| Convert to datetime | pd.to_datetime() | df['date'] = pd.to_datetime(df['date']) |
| Extract year, month, weekday | .dt.year, .dt.month, .dt.day_name() | df['month'] = df['date'].dt.month |
| Filter between dates | Boolean filtering | df[(df['date'] >= '2023-01') & (df['date'] <= ...)] |
| Set datetime index | set_index() | df.set_index('date', inplace=True) |
| Slice by time | Slicing with DatetimeIndex | df['2023-01':'2023-02'] |
| Resample | resample() | df.resample('M').mean() |
| Rolling average/sum | rolling() | df.rolling(3).mean() |
| Change frequency | asfreq() | df.asfreq('D') |

---

Would you like a **cheat sheet PDF** or **interactive notebook** for time series tasks?

### Question 33: How do you filter data between two dates?

**Answer copied from the linked conversation:**

Excellent questions—these are **core pandas operations** that are essential for **time series data preprocessing and analysis** in data science interviews.

---

### ✅ 1. How do you convert a column to datetime format?

You can use **`pd.to_datetime()`** to convert a column to datetime.

```python
import pandas as pd

df = pd.DataFrame({'date': ['2023-01-01', '2023-05-12', '2023-12-25']})
df['date'] = pd.to_datetime(df['date'])
print(df.dtypes)
```

✅ **Tip:** If the format is ambiguous or not standard, specify the `format`:

```python
df['date'] = pd.to_datetime(df['date'], format='%d-%m-%Y')
```

---

### ✅ 2. How do you extract year, month, weekday from a datetime column?

Once the column is converted to datetime:

```python
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['weekday'] = df['date'].dt.day_name()   # e.g., 'Monday'
```

You can also extract:

```python
df['day'] = df['date'].dt.day
df['hour'] = df['date'].dt.hour
df['week'] = df['date'].dt.isocalendar().week
df['quarter'] = df['date'].dt.quarter
```

---

### ✅ 3. How do you filter data between two dates?

Assuming `df['date']` is in datetime format:

```python
start = '2023-01-01'
end = '2023-06-30'
filtered_df = df[(df['date'] >= start) & (df['date'] <= end)]
```

Or using `pd.Timestamp` objects:

```python
filtered_df = df[(df['date'] >= pd.Timestamp('2023-01-01')) &
                 (df['date'] <= pd.Timestamp('2023-06-30'))]
```

✅ Tip: Can also filter using **datetime index** (see next point).

---

### ✅ 4. What is a datetime index and how is it useful in time series analysis?

A **DatetimeIndex** makes time series operations fast and intuitive. It’s created when you set a datetime column as the index.

```python
df.set_index('date', inplace=True)
print(df.index)  # DatetimeIndex
```

### 🔹 Benefits of DatetimeIndex:

| Feature | Example |
| --- | --- |
| Time-based slicing | df['2023-01'] or df['2023-01-01':'2023-01-15'] |
| Resampling | df.resample('M').mean() — monthly average |
| Rolling windows | df.rolling(window=3).mean() |
| Time zone handling | df.tz_localize('UTC') |
| Frequency setting | df.asfreq('D') — convert to daily freq |

---

### ✅ Summary Table for Quick Revision

| Task | Method / Attribute | Example Code |
| --- | --- | --- |
| Convert to datetime | pd.to_datetime() | df['date'] = pd.to_datetime(df['date']) |
| Extract year, month, weekday | .dt.year, .dt.month, .dt.day_name() | df['month'] = df['date'].dt.month |
| Filter between dates | Boolean filtering | df[(df['date'] >= '2023-01') & (df['date'] <= ...)] |
| Set datetime index | set_index() | df.set_index('date', inplace=True) |
| Slice by time | Slicing with DatetimeIndex | df['2023-01':'2023-02'] |
| Resample | resample() | df.resample('M').mean() |
| Rolling average/sum | rolling() | df.rolling(3).mean() |
| Change frequency | asfreq() | df.asfreq('D') |

---

Would you like a **cheat sheet PDF** or **interactive notebook** for time series tasks?

### Question 34: What is a datetime index and how is it useful in time series analysis?

**Answer copied from the linked conversation:**

Excellent questions—these are **core pandas operations** that are essential for **time series data preprocessing and analysis** in data science interviews.

---

### ✅ 1. How do you convert a column to datetime format?

You can use **`pd.to_datetime()`** to convert a column to datetime.

```python
import pandas as pd

df = pd.DataFrame({'date': ['2023-01-01', '2023-05-12', '2023-12-25']})
df['date'] = pd.to_datetime(df['date'])
print(df.dtypes)
```

✅ **Tip:** If the format is ambiguous or not standard, specify the `format`:

```python
df['date'] = pd.to_datetime(df['date'], format='%d-%m-%Y')
```

---

### ✅ 2. How do you extract year, month, weekday from a datetime column?

Once the column is converted to datetime:

```python
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['weekday'] = df['date'].dt.day_name()   # e.g., 'Monday'
```

You can also extract:

```python
df['day'] = df['date'].dt.day
df['hour'] = df['date'].dt.hour
df['week'] = df['date'].dt.isocalendar().week
df['quarter'] = df['date'].dt.quarter
```

---

### ✅ 3. How do you filter data between two dates?

Assuming `df['date']` is in datetime format:

```python
start = '2023-01-01'
end = '2023-06-30'
filtered_df = df[(df['date'] >= start) & (df['date'] <= end)]
```

Or using `pd.Timestamp` objects:

```python
filtered_df = df[(df['date'] >= pd.Timestamp('2023-01-01')) &
                 (df['date'] <= pd.Timestamp('2023-06-30'))]
```

✅ Tip: Can also filter using **datetime index** (see next point).

---

### ✅ 4. What is a datetime index and how is it useful in time series analysis?

A **DatetimeIndex** makes time series operations fast and intuitive. It’s created when you set a datetime column as the index.

```python
df.set_index('date', inplace=True)
print(df.index)  # DatetimeIndex
```

### 🔹 Benefits of DatetimeIndex:

| Feature | Example |
| --- | --- |
| Time-based slicing | df['2023-01'] or df['2023-01-01':'2023-01-15'] |
| Resampling | df.resample('M').mean() — monthly average |
| Rolling windows | df.rolling(window=3).mean() |
| Time zone handling | df.tz_localize('UTC') |
| Frequency setting | df.asfreq('D') — convert to daily freq |

---

### ✅ Summary Table for Quick Revision

| Task | Method / Attribute | Example Code |
| --- | --- | --- |
| Convert to datetime | pd.to_datetime() | df['date'] = pd.to_datetime(df['date']) |
| Extract year, month, weekday | .dt.year, .dt.month, .dt.day_name() | df['month'] = df['date'].dt.month |
| Filter between dates | Boolean filtering | df[(df['date'] >= '2023-01') & (df['date'] <= ...)] |
| Set datetime index | set_index() | df.set_index('date', inplace=True) |
| Slice by time | Slicing with DatetimeIndex | df['2023-01':'2023-02'] |
| Resample | resample() | df.resample('M').mean() |
| Rolling average/sum | rolling() | df.rolling(3).mean() |
| Change frequency | asfreq() | df.asfreq('D') |

---

Would you like a **cheat sheet PDF** or **interactive notebook** for time series tasks?

### Question 35: How do you resample time series data using pandas?

**Answer copied from the linked conversation:**

Resampling is a powerful operation in **pandas** used to **change the frequency** of time series data—either **downsample** (e.g., from daily to monthly) or **upsample** (e.g., from monthly to daily).

---

### ✅ What is Resampling in Pandas?

Resampling involves:

- **Changing the datetime frequency**
- **Aggregating** data (mean, sum, etc.) for downsampling
- **Interpolating or filling** for upsampling

You must have a **`DatetimeIndex`** to use resampling.

---

### 🔹 Syntax:

```python
df.resample('<frequency>').<aggregation>()
```

---

### ✅ Example Dataset

```python
import pandas as pd
import numpy as np

date_rng = pd.date_range(start='2023-01-01', end='2023-01-10', freq='D')
df = pd.DataFrame({'date': date_rng, 'sales': np.random.randint(100, 200, size=(10))})
df.set_index('date', inplace=True)
```

---

### 🔹 1. Downsampling (e.g., from daily to monthly)

```python
monthly_sales = df.resample('M').sum()   # Monthly total sales
weekly_avg = df.resample('W').mean()     # Weekly average
```

📌 Aggregation functions: `mean()`, `sum()`, `min()`, `max()`, `count()`

---

### 🔹 2. Upsampling (e.g., from daily to hourly)

```python
upsampled = df.resample('H').asfreq()       # Insert NaNs
upsampled_ffill = df.resample('H').ffill()  # Forward fill missing values
```

📌 Use `.ffill()` or `.bfill()` to fill missing values.

---

### 🔹 3. Custom aggregation

```python
df.resample('W').agg({'sales': ['sum', 'mean']})
```

---

### 🔹 4. Offset Aliases (Frequencies)

| Alias | Description |
| --- | --- |
| 'D' | Daily |
| 'W' | Weekly |
| 'M' | Month end |
| 'Q' | Quarter end |
| 'Y' | Year end |
| 'H' | Hourly |
| 'T' or 'min' | Minute |
| 'S' | Second |
| 'B' | Business day |

---

### ✅ Summary Table: Resampling in Pandas

| Task | Code Example | Output Description |
| --- | --- | --- |
| Downsample to month end | df.resample('M').sum() | Monthly sum of values |
| Downsample to weekly avg | df.resample('W').mean() | Weekly average |
| Upsample to hourly | df.resample('H').asfreq() | Add hourly rows with NaNs |
| Forward fill after upsample | df.resample('H').ffill() | Fill missing values with previous value |
| Multiple aggregation | df.resample('W').agg(['sum', 'mean']) | Weekly sum and mean |

---

### Bonus: When should you use resampling?

| Use Case | When to Use |
| --- | --- |
| Time series aggregation | To understand weekly/monthly trends |
| Forecasting models (ARIMA, etc.) | Often require regular intervals |
| Missing value handling | Useful with upsampling and .ffill() |
| Rolling windows | Combines well with rolling() |

---

Would you like a **Jupyter Notebook** to practice these time series resampling tasks interactively?

## Sorting & Ranking

### Question 36: How do you sort a DataFrame by column values?

**Answer copied from the linked conversation:**

Great questions! These are fundamental pandas operations frequently used in **data wrangling, EDA**, and **feature engineering**. Here's a comprehensive explanation with examples and a final summary table for quick revision.

---

### ✅ 1. How do you sort a DataFrame by column values?

Use `sort_values()` to sort by **one or more columns**.

```python
import pandas as pd

df = pd.DataFrame({
    'Name': ['Alice', 'Bob', 'Charlie', 'David'],
    'Score': [85, 90, 78, 92]
})

# Sort by Score in ascending order
df_sorted = df.sort_values(by='Score')

# Descending order
df_sorted_desc = df.sort_values(by='Score', ascending=False)
```

🔹 You can also sort by multiple columns:

```python
df.sort_values(by=['Score', 'Name'], ascending=[False, True])
```

---

### ✅ 2. How do you sort by index?

Use `sort_index()` to sort the DataFrame by its **index (rows or columns)**.

```python
# Sort by row index
df_sorted_by_index = df.sort_index()

# Sort by column index
df_sorted_columns = df.sort_index(axis=1)  # axis=1 means sort columns
```

---

### ✅ 3. What is the difference between sort_values() and sort_index()?

| Feature | sort_values() | sort_index() |
| --- | --- | --- |
| Sorts by | One or more column values | Index labels (rows or columns) |
| Use case | Sort by feature/metric (e.g., "Sales") | Sort alphabetically/numerically by index |
| Syntax | df.sort_values(by='col') | df.sort_index() |

---

### ✅ 4. How do you rank values in a column?

Use `rank()` to assign ranks to numeric values.

```python
df['rank'] = df['Score'].rank(method='dense', ascending=False)
```

📌 `method` options:

- `'average'` – average of ranks for ties (default)
- `'min'`, `'max'`, `'first'`, `'dense'`

---

### ✅ 5. How do you find top N rows by column values?

Use `nlargest()` or sort with `head()`:

```python
# Top 2 scores
top_n = df.nlargest(2, 'Score')

# Alternative using sort_values
top_n_alt = df.sort_values(by='Score', ascending=False).head(2)
```

To get **bottom N**, use `nsmallest()`.

---

### ✅ Summary Table: Sorting, Ranking, and Top N in Pandas

| Task | Function/Method | Example Code |
| --- | --- | --- |
| Sort by column values | sort_values(by='col') | df.sort_values(by='Score') |
| Sort by index (rows/columns) | sort_index() | df.sort_index(), df.sort_index(axis=1) |
| Rank column values | rank() | df['rank'] = df['Score'].rank(method='dense') |
| Top N rows by column value | nlargest(n, 'col') | df.nlargest(3, 'Score') |
| Bottom N rows by column value | nsmallest(n, 'col') | df.nsmallest(3, 'Score') |

---

Would you like a **cheat sheet** or visual PDF summarizing core pandas operations before your interview?

### Question 37: How do you sort by index?

**Answer copied from the linked conversation:**

Great questions! These are fundamental pandas operations frequently used in **data wrangling, EDA**, and **feature engineering**. Here's a comprehensive explanation with examples and a final summary table for quick revision.

---

### ✅ 1. How do you sort a DataFrame by column values?

Use `sort_values()` to sort by **one or more columns**.

```python
import pandas as pd

df = pd.DataFrame({
    'Name': ['Alice', 'Bob', 'Charlie', 'David'],
    'Score': [85, 90, 78, 92]
})

# Sort by Score in ascending order
df_sorted = df.sort_values(by='Score')

# Descending order
df_sorted_desc = df.sort_values(by='Score', ascending=False)
```

🔹 You can also sort by multiple columns:

```python
df.sort_values(by=['Score', 'Name'], ascending=[False, True])
```

---

### ✅ 2. How do you sort by index?

Use `sort_index()` to sort the DataFrame by its **index (rows or columns)**.

```python
# Sort by row index
df_sorted_by_index = df.sort_index()

# Sort by column index
df_sorted_columns = df.sort_index(axis=1)  # axis=1 means sort columns
```

---

### ✅ 3. What is the difference between sort_values() and sort_index()?

| Feature | sort_values() | sort_index() |
| --- | --- | --- |
| Sorts by | One or more column values | Index labels (rows or columns) |
| Use case | Sort by feature/metric (e.g., "Sales") | Sort alphabetically/numerically by index |
| Syntax | df.sort_values(by='col') | df.sort_index() |

---

### ✅ 4. How do you rank values in a column?

Use `rank()` to assign ranks to numeric values.

```python
df['rank'] = df['Score'].rank(method='dense', ascending=False)
```

📌 `method` options:

- `'average'` – average of ranks for ties (default)
- `'min'`, `'max'`, `'first'`, `'dense'`

---

### ✅ 5. How do you find top N rows by column values?

Use `nlargest()` or sort with `head()`:

```python
# Top 2 scores
top_n = df.nlargest(2, 'Score')

# Alternative using sort_values
top_n_alt = df.sort_values(by='Score', ascending=False).head(2)
```

To get **bottom N**, use `nsmallest()`.

---

### ✅ Summary Table: Sorting, Ranking, and Top N in Pandas

| Task | Function/Method | Example Code |
| --- | --- | --- |
| Sort by column values | sort_values(by='col') | df.sort_values(by='Score') |
| Sort by index (rows/columns) | sort_index() | df.sort_index(), df.sort_index(axis=1) |
| Rank column values | rank() | df['rank'] = df['Score'].rank(method='dense') |
| Top N rows by column value | nlargest(n, 'col') | df.nlargest(3, 'Score') |
| Bottom N rows by column value | nsmallest(n, 'col') | df.nsmallest(3, 'Score') |

---

Would you like a **cheat sheet** or visual PDF summarizing core pandas operations before your interview?

### Question 38: What is the difference between `sort_values()` and `sort_index()`?

**Answer copied from the linked conversation:**

Great questions! These are fundamental pandas operations frequently used in **data wrangling, EDA**, and **feature engineering**. Here's a comprehensive explanation with examples and a final summary table for quick revision.

---

### ✅ 1. How do you sort a DataFrame by column values?

Use `sort_values()` to sort by **one or more columns**.

```python
import pandas as pd

df = pd.DataFrame({
    'Name': ['Alice', 'Bob', 'Charlie', 'David'],
    'Score': [85, 90, 78, 92]
})

# Sort by Score in ascending order
df_sorted = df.sort_values(by='Score')

# Descending order
df_sorted_desc = df.sort_values(by='Score', ascending=False)
```

🔹 You can also sort by multiple columns:

```python
df.sort_values(by=['Score', 'Name'], ascending=[False, True])
```

---

### ✅ 2. How do you sort by index?

Use `sort_index()` to sort the DataFrame by its **index (rows or columns)**.

```python
# Sort by row index
df_sorted_by_index = df.sort_index()

# Sort by column index
df_sorted_columns = df.sort_index(axis=1)  # axis=1 means sort columns
```

---

### ✅ 3. What is the difference between sort_values() and sort_index()?

| Feature | sort_values() | sort_index() |
| --- | --- | --- |
| Sorts by | One or more column values | Index labels (rows or columns) |
| Use case | Sort by feature/metric (e.g., "Sales") | Sort alphabetically/numerically by index |
| Syntax | df.sort_values(by='col') | df.sort_index() |

---

### ✅ 4. How do you rank values in a column?

Use `rank()` to assign ranks to numeric values.

```python
df['rank'] = df['Score'].rank(method='dense', ascending=False)
```

📌 `method` options:

- `'average'` – average of ranks for ties (default)
- `'min'`, `'max'`, `'first'`, `'dense'`

---

### ✅ 5. How do you find top N rows by column values?

Use `nlargest()` or sort with `head()`:

```python
# Top 2 scores
top_n = df.nlargest(2, 'Score')

# Alternative using sort_values
top_n_alt = df.sort_values(by='Score', ascending=False).head(2)
```

To get **bottom N**, use `nsmallest()`.

---

### ✅ Summary Table: Sorting, Ranking, and Top N in Pandas

| Task | Function/Method | Example Code |
| --- | --- | --- |
| Sort by column values | sort_values(by='col') | df.sort_values(by='Score') |
| Sort by index (rows/columns) | sort_index() | df.sort_index(), df.sort_index(axis=1) |
| Rank column values | rank() | df['rank'] = df['Score'].rank(method='dense') |
| Top N rows by column value | nlargest(n, 'col') | df.nlargest(3, 'Score') |
| Bottom N rows by column value | nsmallest(n, 'col') | df.nsmallest(3, 'Score') |

---

Would you like a **cheat sheet** or visual PDF summarizing core pandas operations before your interview?

### Question 39: How do you rank values in a column?

**Answer copied from the linked conversation:**

Great questions! These are fundamental pandas operations frequently used in **data wrangling, EDA**, and **feature engineering**. Here's a comprehensive explanation with examples and a final summary table for quick revision.

---

### ✅ 1. How do you sort a DataFrame by column values?

Use `sort_values()` to sort by **one or more columns**.

```python
import pandas as pd

df = pd.DataFrame({
    'Name': ['Alice', 'Bob', 'Charlie', 'David'],
    'Score': [85, 90, 78, 92]
})

# Sort by Score in ascending order
df_sorted = df.sort_values(by='Score')

# Descending order
df_sorted_desc = df.sort_values(by='Score', ascending=False)
```

🔹 You can also sort by multiple columns:

```python
df.sort_values(by=['Score', 'Name'], ascending=[False, True])
```

---

### ✅ 2. How do you sort by index?

Use `sort_index()` to sort the DataFrame by its **index (rows or columns)**.

```python
# Sort by row index
df_sorted_by_index = df.sort_index()

# Sort by column index
df_sorted_columns = df.sort_index(axis=1)  # axis=1 means sort columns
```

---

### ✅ 3. What is the difference between sort_values() and sort_index()?

| Feature | sort_values() | sort_index() |
| --- | --- | --- |
| Sorts by | One or more column values | Index labels (rows or columns) |
| Use case | Sort by feature/metric (e.g., "Sales") | Sort alphabetically/numerically by index |
| Syntax | df.sort_values(by='col') | df.sort_index() |

---

### ✅ 4. How do you rank values in a column?

Use `rank()` to assign ranks to numeric values.

```python
df['rank'] = df['Score'].rank(method='dense', ascending=False)
```

📌 `method` options:

- `'average'` – average of ranks for ties (default)
- `'min'`, `'max'`, `'first'`, `'dense'`

---

### ✅ 5. How do you find top N rows by column values?

Use `nlargest()` or sort with `head()`:

```python
# Top 2 scores
top_n = df.nlargest(2, 'Score')

# Alternative using sort_values
top_n_alt = df.sort_values(by='Score', ascending=False).head(2)
```

To get **bottom N**, use `nsmallest()`.

---

### ✅ Summary Table: Sorting, Ranking, and Top N in Pandas

| Task | Function/Method | Example Code |
| --- | --- | --- |
| Sort by column values | sort_values(by='col') | df.sort_values(by='Score') |
| Sort by index (rows/columns) | sort_index() | df.sort_index(), df.sort_index(axis=1) |
| Rank column values | rank() | df['rank'] = df['Score'].rank(method='dense') |
| Top N rows by column value | nlargest(n, 'col') | df.nlargest(3, 'Score') |
| Bottom N rows by column value | nsmallest(n, 'col') | df.nsmallest(3, 'Score') |

---

Would you like a **cheat sheet** or visual PDF summarizing core pandas operations before your interview?

### Question 40: How do you find top N rows by column values?

**Answer copied from the linked conversation:**

Great questions! These are fundamental pandas operations frequently used in **data wrangling, EDA**, and **feature engineering**. Here's a comprehensive explanation with examples and a final summary table for quick revision.

---

### ✅ 1. How do you sort a DataFrame by column values?

Use `sort_values()` to sort by **one or more columns**.

```python
import pandas as pd

df = pd.DataFrame({
    'Name': ['Alice', 'Bob', 'Charlie', 'David'],
    'Score': [85, 90, 78, 92]
})

# Sort by Score in ascending order
df_sorted = df.sort_values(by='Score')

# Descending order
df_sorted_desc = df.sort_values(by='Score', ascending=False)
```

🔹 You can also sort by multiple columns:

```python
df.sort_values(by=['Score', 'Name'], ascending=[False, True])
```

---

### ✅ 2. How do you sort by index?

Use `sort_index()` to sort the DataFrame by its **index (rows or columns)**.

```python
# Sort by row index
df_sorted_by_index = df.sort_index()

# Sort by column index
df_sorted_columns = df.sort_index(axis=1)  # axis=1 means sort columns
```

---

### ✅ 3. What is the difference between sort_values() and sort_index()?

| Feature | sort_values() | sort_index() |
| --- | --- | --- |
| Sorts by | One or more column values | Index labels (rows or columns) |
| Use case | Sort by feature/metric (e.g., "Sales") | Sort alphabetically/numerically by index |
| Syntax | df.sort_values(by='col') | df.sort_index() |

---

### ✅ 4. How do you rank values in a column?

Use `rank()` to assign ranks to numeric values.

```python
df['rank'] = df['Score'].rank(method='dense', ascending=False)
```

📌 `method` options:

- `'average'` – average of ranks for ties (default)
- `'min'`, `'max'`, `'first'`, `'dense'`

---

### ✅ 5. How do you find top N rows by column values?

Use `nlargest()` or sort with `head()`:

```python
# Top 2 scores
top_n = df.nlargest(2, 'Score')

# Alternative using sort_values
top_n_alt = df.sort_values(by='Score', ascending=False).head(2)
```

To get **bottom N**, use `nsmallest()`.

---

### ✅ Summary Table: Sorting, Ranking, and Top N in Pandas

| Task | Function/Method | Example Code |
| --- | --- | --- |
| Sort by column values | sort_values(by='col') | df.sort_values(by='Score') |
| Sort by index (rows/columns) | sort_index() | df.sort_index(), df.sort_index(axis=1) |
| Rank column values | rank() | df['rank'] = df['Score'].rank(method='dense') |
| Top N rows by column value | nlargest(n, 'col') | df.nlargest(3, 'Score') |
| Bottom N rows by column value | nsmallest(n, 'col') | df.nsmallest(3, 'Score') |

---

Would you like a **cheat sheet** or visual PDF summarizing core pandas operations before your interview?

## Exporting & Input/Output

### Question 41: How do you read a CSV/Excel file into pandas?

**Answer copied from the linked conversation:**

Great questions, Himanshu! These concepts are **foundational** to working with pandas in data science. Below is a **comprehensive explanation with examples and a summary table** for quick revision.

---

### ✅ Core Data Structures in Pandas

| Structure | Description |
| --- | --- |
| Series | 1D labeled array – like a column in Excel |
| DataFrame | 2D labeled data structure – like an Excel sheet |

---

### 🔹 What is a Series?

A **pandas Series** is a **one-dimensional labeled array** capable of holding any data type (integers, strings, floats, Python objects, etc.).

```python
import pandas as pd

s = pd.Series([10, 20, 30], index=['a', 'b', 'c'])
print(s)
```

📤 **Output**:

```python
a    10
b    20
c    30
dtype: int64
```

---

### 🔹 What is a DataFrame?

A **DataFrame** is a **two-dimensional**, size-mutable, tabular data structure with labeled axes (rows and columns).

```python
data = {
    'Name': ['Alice', 'Bob', 'Charlie'],
    'Age': [25, 30, 35]
}
df = pd.DataFrame(data)
print(df)
```

📤 **Output**:

```python
Name  Age
0    Alice   25
1      Bob   30
2  Charlie   35
```

---

### ✅ How to Create DataFrame from Different Sources

| Source | Code Example |
| --- | --- |
| List of Lists | pd.DataFrame([[1,2],[3,4]], columns=['A','B']) |
| Dict of Lists | pd.DataFrame({'A': [1, 2], 'B': [3, 4]}) |
| Dict of Series | pd.DataFrame({'A': pd.Series(...), 'B': pd.Series(...)}) |
| Numpy Array | pd.DataFrame(np.array([[1,2], [3,4]]), columns=['X', 'Y']) |
| List of Dicts | pd.DataFrame([{'a': 1, 'b': 2}, {'a': 3, 'b': 4}]) |
| CSV/Excel/SQL | pd.read_csv(), pd.read_excel(), pd.read_sql() |

---

### 🔍 Series vs DataFrame: Comparison Table

| Feature | Series | DataFrame |
| --- | --- | --- |
| Dimensionality | 1D | 2D |
| Axis labels | Single index | Row and column indexes |
| Data type | Homogeneous or mixed | Typically heterogeneous |
| Shape | (n,) | (n, m) |
| Example Use Case | Single column (e.g., Age) | Full dataset (e.g., Name, Age, Salary) |
| Creation | pd.Series([1, 2, 3]) | pd.DataFrame({'col1': [...], ...}) |

---

### ✅ Interview Tip

“I use Series when dealing with a single variable or during vectorized operations. DataFrames are the core structure I work with in all stages — from preprocessing to model evaluation. Understanding both helps me manipulate and analyze data efficiently.”

---

Would you like a **code-based cheat sheet** showing how to convert between Series and DataFrames, or extract columns, rows, and cells efficiently?
Certainly, Himanshu! Here's the **updated table** with **JSON** as a data source added for creating a pandas DataFrame:

---

### ✅ Ways to Create a DataFrame in Pandas – Summary Table

| Source | Code Example |
| --- | --- |
| List of Lists | pd.DataFrame([[1,2],[3,4]], columns=['A','B']) |
| Dict of Lists | pd.DataFrame({'A': [1, 2], 'B': [3, 4]}) |
| Dict of Series | pd.DataFrame({'A': pd.Series(...), 'B': pd.Series(...)}) |
| Numpy Array | pd.DataFrame(np.array([[1,2], [3,4]]), columns=['X', 'Y']) |
| List of Dicts | pd.DataFrame([{'a': 1, 'b': 2}, {'a': 3, 'b': 4}]) |
| JSON (from str) | pd.read_json(json_string) or pd.DataFrame(json.loads(json_string)) |
| CSV/Excel/SQL | pd.read_csv(), pd.read_excel(), pd.read_sql() |

---

### 🔹 Example: Creating a DataFrame from JSON

```python
import pandas as pd
import json

json_data = '[{"a": 1, "b": 2}, {"a": 3, "b": 4}]'
df = pd.read_json(json_data)
print(df)
```

📤 Output:

```python
a  b
0  1  2
1  3  4
```

You can also read from a `.json` file:

`pd.read_json('file.json')`

Let me know if you want a **visual cheat sheet** or real-world examples for each source!

### Question 42: How do you write a pandas DataFrame to CSV or Excel?

**Answer copied from the linked conversation:**

Absolutely, Himanshu! Data preprocessing is a **core step in every data science pipeline** — and mastering the relevant **Pandas techniques** helps clean, transform, and prepare data efficiently before applying ML algorithms.

Here’s a comprehensive summary of **data preprocessing using Pandas** — with explanations, examples, and a **quick revision table** at the end.

---

### ✅ 1. Loading the Dataset

```python
import pandas as pd

df = pd.read_csv('data.csv')
df.head()
```

---

### ✅ 2. Understanding the Data

```python
df.shape          # (rows, columns)
df.columns        # List of column names
df.info()         # Data types and null counts
df.describe()     # Summary statistics
```

---

### ✅ 3. Handling Missing Values

### 🔹 Detect

```python
df.isnull().sum()        # Count nulls per column
```

### 🔹 Drop

```python
df.dropna()              # Drop rows with any NaN
df.dropna(axis=1)        # Drop columns with any NaN
```

### 🔹 Impute

```python
df.fillna(0)
df['col'].fillna(df['col'].mean(), inplace=True)
```

---

### ✅ 4. Handling Duplicates

```python
df.duplicated().sum()
df.drop_duplicates(inplace=True)
```

---

### ✅ 5. Renaming Columns

```python
df.rename(columns={'old_name': 'new_name'}, inplace=True)
```

---

### ✅ 6. Changing Data Types (Type Casting)

```python
df['date'] = pd.to_datetime(df['date'])
df['col'] = df['col'].astype(int)
```

---

### ✅ 7. Filtering and Subsetting

```python
df[df['col'] > 50]                      # Row filter
df[['col1', 'col2']]                   # Column subset
```

---

### ✅ 8. Feature Engineering

```python
df['new_col'] = df['col1'] / df['col2']  # Derived feature
df['year'] = df['date'].dt.year          # Extract from datetime
```

---

### ✅ 9. Encoding Categorical Variables

```python
pd.get_dummies(df, columns=['category_col'])           # One-hot encoding
df['label_encoded'] = df['category_col'].astype('category').cat.codes
```

---

### ✅ 10. Scaling/Normalization

Usually done with Scikit-learn:

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
df[['scaled_col']] = scaler.fit_transform(df[['col']])
```

---

### ✅ 11. Grouping & Aggregation

```python
df.groupby('category')['value'].mean()
df.groupby(['col1', 'col2']).agg({'value': ['sum', 'mean']})
```

---

### ✅ 12. Merging, Joining, and Concatenation

```python
pd.concat([df1, df2])                        # Stack vertically
pd.merge(df1, df2, on='key')                # SQL-style join
```

---

### ✅ 13. Exporting the Cleaned Data

```python
df.to_csv("cleaned_data.csv", index=False)
```

---

### 🧠 Summary Table: Quick Revision

| Step | Function / Method | Notes |
| --- | --- | --- |
| Load Data | pd.read_csv() | Read CSV, Excel, JSON, etc. |
| Inspect Data | df.info(), df.describe() | Data types, nulls, stats |
| Handle Nulls | dropna(), fillna() | Drop or impute |
| Remove Duplicates | duplicated(), drop_duplicates() |  |
| Rename / Reformat | rename(), astype(), to_datetime() | For consistent formats |
| Filter/Subsets | df[df['x'] > 0], df[['x', 'y']] | Logic-based filtering |
| Feature Engineering | Math ops, dt accessor | New columns |
| Encode Categoricals | get_dummies(), .cat.codes | For ML algorithms |
| Scaling | StandardScaler, MinMaxScaler | Sklearn tools |
| Grouping / Aggregation | groupby(), agg() | For summaries |
| Merge / Join | merge(), concat() | Combining datasets |
| Export | to_csv(), to_excel() | Save preprocessed data |

---

### ✅ Interview Tip:

“In data science projects, I usually start with null handling and type casting, followed by outlier removal, encoding, and scaling. Pandas makes it easy to build repeatable pipelines with readable code.”

---

Would you like a **reusable preprocessing function or pipeline class** using Pandas and Scikit-learn that you can plug into your ML projects?

### Question 43: How do you read JSON and SQL data with pandas?

**Answer copied from the linked conversation:**

Certainly, Himanshu! Here's the **updated table** with **JSON** as a data source added for creating a pandas DataFrame:

---

### ✅ Ways to Create a DataFrame in Pandas – Summary Table

| Source | Code Example |
| --- | --- |
| List of Lists | pd.DataFrame([[1,2],[3,4]], columns=['A','B']) |
| Dict of Lists | pd.DataFrame({'A': [1, 2], 'B': [3, 4]}) |
| Dict of Series | pd.DataFrame({'A': pd.Series(...), 'B': pd.Series(...)}) |
| Numpy Array | pd.DataFrame(np.array([[1,2], [3,4]]), columns=['X', 'Y']) |
| List of Dicts | pd.DataFrame([{'a': 1, 'b': 2}, {'a': 3, 'b': 4}]) |
| JSON (from str) | pd.read_json(json_string) or pd.DataFrame(json.loads(json_string)) |
| CSV/Excel/SQL | pd.read_csv(), pd.read_excel(), pd.read_sql() |

---

### 🔹 Example: Creating a DataFrame from JSON

```python
import pandas as pd
import json

json_data = '[{"a": 1, "b": 2}, {"a": 3, "b": 4}]'
df = pd.read_json(json_data)
print(df)
```

📤 Output:

```python
a  b
0  1  2
1  3  4
```

You can also read from a `.json` file:

`pd.read_json('file.json')`

Let me know if you want a **visual cheat sheet** or real-world examples for each source!

### Question 44: How do you handle large datasets with pandas (e.g., in chunks)?

**Answer copied from the linked conversation:**

Improving the performance and memory efficiency of a Python script is **crucial in data science**, especially when working with **large datasets or real-time applications**. Below is a comprehensive answer with examples, tools, and a **quick revision table**.

---

### ✅ How to Improve the Performance of a Python Script

### 🔹 1. Use Built-in Functions & Libraries

Python's built-in functions (like `sum()`, `map()`, `any()`, etc.) are implemented in C and are faster than manual loops.

```python
# Faster than manual sum using a loop
total = sum([i for i in range(1000000)])
```

---

### 🔹 2. Use Vectorized Operations (NumPy, Pandas)

Avoid looping over elements. Use libraries like NumPy and Pandas which are optimized in C.

```python
import numpy as np
a = np.arange(1000000)
b = a * 2  # Vectorized
```

---

### 🔹 3. Use List Comprehensions Instead of Loops

```python
# Better
squares = [x**2 for x in range(1000)]

# Slower
squares = []
for x in range(1000):
    squares.append(x**2)
```

---

### 🔹 4. Avoid Unnecessary Global Variables and Function Calls

Global access is slower. Prefer local variables.

---

### 🔹 5. Use Efficient Data Structures

Use `set` for membership tests, `deque` for fast append/pop, `defaultdict` to avoid KeyErrors.

```python
from collections import defaultdict, deque
d = defaultdict(int)
q = deque([1,2,3])
```

---

### 🔹 6. Use Generators Instead of Lists

Generators save memory and are lazy-loaded.

```python
def gen_nums():
    for i in range(10**6):
        yield i
```

---

### 🔹 7. Use multiprocessing or concurrent.futures

To parallelize CPU-bound tasks.

```python
from multiprocessing import Pool

def square(n): return n * n
with Pool() as p:
    print(p.map(square, range(10)))
```

---

### 🔹 8. Use @lru_cache for Expensive Function Calls

Memoization speeds up repeated function calls.

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def fib(n):
    if n < 2:
        return n
    return fib(n-1) + fib(n-2)
```

---

### 🔹 9. Profile Your Code

Use:

- `cProfile` for performance bottlenecks.
- `line_profiler` for line-by-line profiling.
- `memory_profiler` for memory usage.

---

### ✅ Memory-Efficient Ways to Handle Large Datasets

| Approach | Explanation & Example |
| --- | --- |
| Use chunk loading in Pandas | pd.read_csv('large.csv', chunksize=10000) |
| Use dask for out-of-core data | Works like pandas, supports parallel & distributed computation |
| Use generators | Lazy evaluation, no memory hit |
| Avoid loading unnecessary columns | usecols=['A','B'] while loading data |
| Data type optimization | Downcast float64 to float32, int64 to int32 to save memory |
| Use SQLite/Feather/Parquet | More efficient than CSV in both space & speed |
| Use sparse matrices | scipy.sparse.csr_matrix() for mostly-zero data |

---

### ✅ Quick Revision Table

| Goal | Technique | Tool/Method |
| --- | --- | --- |
| Faster loops | List comprehensions | [x**2 for x in range(n)] |
| Avoid loops | Vectorization | NumPy, Pandas |
| Optimize memory | Generators | yield, generator expressions |
| Parallel processing | Multiprocessing | multiprocessing.Pool, concurrent.futures |
| Avoid recomputation | Memoization | @lru_cache |
| Handle large datasets | Chunk loading | pd.read_csv(..., chunksize=...) |
| Out-of-core computing | Dask | dask.dataframe |
| Efficient storage | Parquet, Feather | pd.read_parquet(), feather.read_table() |
| Debug bottlenecks | Profiling | cProfile, line_profiler, memory_profiler |

---

Would you like a cheat sheet PDF or notebook version for practicing these with code examples?

### Question 45: How do you optimize memory usage when loading large datasets?

**Answer copied from the linked conversation:**

Improving the performance and memory efficiency of a Python script is **crucial in data science**, especially when working with **large datasets or real-time applications**. Below is a comprehensive answer with examples, tools, and a **quick revision table**.

---

### ✅ How to Improve the Performance of a Python Script

### 🔹 1. Use Built-in Functions & Libraries

Python's built-in functions (like `sum()`, `map()`, `any()`, etc.) are implemented in C and are faster than manual loops.

```python
# Faster than manual sum using a loop
total = sum([i for i in range(1000000)])
```

---

### 🔹 2. Use Vectorized Operations (NumPy, Pandas)

Avoid looping over elements. Use libraries like NumPy and Pandas which are optimized in C.

```python
import numpy as np
a = np.arange(1000000)
b = a * 2  # Vectorized
```

---

### 🔹 3. Use List Comprehensions Instead of Loops

```python
# Better
squares = [x**2 for x in range(1000)]

# Slower
squares = []
for x in range(1000):
    squares.append(x**2)
```

---

### 🔹 4. Avoid Unnecessary Global Variables and Function Calls

Global access is slower. Prefer local variables.

---

### 🔹 5. Use Efficient Data Structures

Use `set` for membership tests, `deque` for fast append/pop, `defaultdict` to avoid KeyErrors.

```python
from collections import defaultdict, deque
d = defaultdict(int)
q = deque([1,2,3])
```

---

### 🔹 6. Use Generators Instead of Lists

Generators save memory and are lazy-loaded.

```python
def gen_nums():
    for i in range(10**6):
        yield i
```

---

### 🔹 7. Use multiprocessing or concurrent.futures

To parallelize CPU-bound tasks.

```python
from multiprocessing import Pool

def square(n): return n * n
with Pool() as p:
    print(p.map(square, range(10)))
```

---

### 🔹 8. Use @lru_cache for Expensive Function Calls

Memoization speeds up repeated function calls.

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def fib(n):
    if n < 2:
        return n
    return fib(n-1) + fib(n-2)
```

---

### 🔹 9. Profile Your Code

Use:

- `cProfile` for performance bottlenecks.
- `line_profiler` for line-by-line profiling.
- `memory_profiler` for memory usage.

---

### ✅ Memory-Efficient Ways to Handle Large Datasets

| Approach | Explanation & Example |
| --- | --- |
| Use chunk loading in Pandas | pd.read_csv('large.csv', chunksize=10000) |
| Use dask for out-of-core data | Works like pandas, supports parallel & distributed computation |
| Use generators | Lazy evaluation, no memory hit |
| Avoid loading unnecessary columns | usecols=['A','B'] while loading data |
| Data type optimization | Downcast float64 to float32, int64 to int32 to save memory |
| Use SQLite/Feather/Parquet | More efficient than CSV in both space & speed |
| Use sparse matrices | scipy.sparse.csr_matrix() for mostly-zero data |

---

### ✅ Quick Revision Table

| Goal | Technique | Tool/Method |
| --- | --- | --- |
| Faster loops | List comprehensions | [x**2 for x in range(n)] |
| Avoid loops | Vectorization | NumPy, Pandas |
| Optimize memory | Generators | yield, generator expressions |
| Parallel processing | Multiprocessing | multiprocessing.Pool, concurrent.futures |
| Avoid recomputation | Memoization | @lru_cache |
| Handle large datasets | Chunk loading | pd.read_csv(..., chunksize=...) |
| Out-of-core computing | Dask | dask.dataframe |
| Efficient storage | Parquet, Feather | pd.read_parquet(), feather.read_table() |
| Debug bottlenecks | Profiling | cProfile, line_profiler, memory_profiler |

---

Would you like a cheat sheet PDF or notebook version for practicing these with code examples?

## Real-World & Scenario-Based

### Question 46: You have customer data with duplicate names and mismatched IDs — how will you clean it?

**Note:** Related source answer: general Pandas cleaning/duplicate guidance; it does not specifically resolve ID conflicts.

**Answer copied from the linked conversation:**

Absolutely, Himanshu! Data preprocessing is a **core step in every data science pipeline** — and mastering the relevant **Pandas techniques** helps clean, transform, and prepare data efficiently before applying ML algorithms.

Here’s a comprehensive summary of **data preprocessing using Pandas** — with explanations, examples, and a **quick revision table** at the end.

---

### ✅ 1. Loading the Dataset

```python
import pandas as pd

df = pd.read_csv('data.csv')
df.head()
```

---

### ✅ 2. Understanding the Data

```python
df.shape          # (rows, columns)
df.columns        # List of column names
df.info()         # Data types and null counts
df.describe()     # Summary statistics
```

---

### ✅ 3. Handling Missing Values

### 🔹 Detect

```python
df.isnull().sum()        # Count nulls per column
```

### 🔹 Drop

```python
df.dropna()              # Drop rows with any NaN
df.dropna(axis=1)        # Drop columns with any NaN
```

### 🔹 Impute

```python
df.fillna(0)
df['col'].fillna(df['col'].mean(), inplace=True)
```

---

### ✅ 4. Handling Duplicates

```python
df.duplicated().sum()
df.drop_duplicates(inplace=True)
```

---

### ✅ 5. Renaming Columns

```python
df.rename(columns={'old_name': 'new_name'}, inplace=True)
```

---

### ✅ 6. Changing Data Types (Type Casting)

```python
df['date'] = pd.to_datetime(df['date'])
df['col'] = df['col'].astype(int)
```

---

### ✅ 7. Filtering and Subsetting

```python
df[df['col'] > 50]                      # Row filter
df[['col1', 'col2']]                   # Column subset
```

---

### ✅ 8. Feature Engineering

```python
df['new_col'] = df['col1'] / df['col2']  # Derived feature
df['year'] = df['date'].dt.year          # Extract from datetime
```

---

### ✅ 9. Encoding Categorical Variables

```python
pd.get_dummies(df, columns=['category_col'])           # One-hot encoding
df['label_encoded'] = df['category_col'].astype('category').cat.codes
```

---

### ✅ 10. Scaling/Normalization

Usually done with Scikit-learn:

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
df[['scaled_col']] = scaler.fit_transform(df[['col']])
```

---

### ✅ 11. Grouping & Aggregation

```python
df.groupby('category')['value'].mean()
df.groupby(['col1', 'col2']).agg({'value': ['sum', 'mean']})
```

---

### ✅ 12. Merging, Joining, and Concatenation

```python
pd.concat([df1, df2])                        # Stack vertically
pd.merge(df1, df2, on='key')                # SQL-style join
```

---

### ✅ 13. Exporting the Cleaned Data

```python
df.to_csv("cleaned_data.csv", index=False)
```

---

### 🧠 Summary Table: Quick Revision

| Step | Function / Method | Notes |
| --- | --- | --- |
| Load Data | pd.read_csv() | Read CSV, Excel, JSON, etc. |
| Inspect Data | df.info(), df.describe() | Data types, nulls, stats |
| Handle Nulls | dropna(), fillna() | Drop or impute |
| Remove Duplicates | duplicated(), drop_duplicates() |  |
| Rename / Reformat | rename(), astype(), to_datetime() | For consistent formats |
| Filter/Subsets | df[df['x'] > 0], df[['x', 'y']] | Logic-based filtering |
| Feature Engineering | Math ops, dt accessor | New columns |
| Encode Categoricals | get_dummies(), .cat.codes | For ML algorithms |
| Scaling | StandardScaler, MinMaxScaler | Sklearn tools |
| Grouping / Aggregation | groupby(), agg() | For summaries |
| Merge / Join | merge(), concat() | Combining datasets |
| Export | to_csv(), to_excel() | Save preprocessed data |

---

### ✅ Interview Tip:

“In data science projects, I usually start with null handling and type casting, followed by outlier removal, encoding, and scaling. Pandas makes it easy to build repeatable pipelines with readable code.”

---

Would you like a **reusable preprocessing function or pipeline class** using Pandas and Scikit-learn that you can plug into your ML projects?

### Question 47: How would you calculate rolling averages using pandas?

**Answer copied from the linked conversation:**

Excellent questions—these are **core pandas operations** that are essential for **time series data preprocessing and analysis** in data science interviews.

---

### ✅ 1. How do you convert a column to datetime format?

You can use **`pd.to_datetime()`** to convert a column to datetime.

```python
import pandas as pd

df = pd.DataFrame({'date': ['2023-01-01', '2023-05-12', '2023-12-25']})
df['date'] = pd.to_datetime(df['date'])
print(df.dtypes)
```

✅ **Tip:** If the format is ambiguous or not standard, specify the `format`:

```python
df['date'] = pd.to_datetime(df['date'], format='%d-%m-%Y')
```

---

### ✅ 2. How do you extract year, month, weekday from a datetime column?

Once the column is converted to datetime:

```python
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['weekday'] = df['date'].dt.day_name()   # e.g., 'Monday'
```

You can also extract:

```python
df['day'] = df['date'].dt.day
df['hour'] = df['date'].dt.hour
df['week'] = df['date'].dt.isocalendar().week
df['quarter'] = df['date'].dt.quarter
```

---

### ✅ 3. How do you filter data between two dates?

Assuming `df['date']` is in datetime format:

```python
start = '2023-01-01'
end = '2023-06-30'
filtered_df = df[(df['date'] >= start) & (df['date'] <= end)]
```

Or using `pd.Timestamp` objects:

```python
filtered_df = df[(df['date'] >= pd.Timestamp('2023-01-01')) &
                 (df['date'] <= pd.Timestamp('2023-06-30'))]
```

✅ Tip: Can also filter using **datetime index** (see next point).

---

### ✅ 4. What is a datetime index and how is it useful in time series analysis?

A **DatetimeIndex** makes time series operations fast and intuitive. It’s created when you set a datetime column as the index.

```python
df.set_index('date', inplace=True)
print(df.index)  # DatetimeIndex
```

### 🔹 Benefits of DatetimeIndex:

| Feature | Example |
| --- | --- |
| Time-based slicing | df['2023-01'] or df['2023-01-01':'2023-01-15'] |
| Resampling | df.resample('M').mean() — monthly average |
| Rolling windows | df.rolling(window=3).mean() |
| Time zone handling | df.tz_localize('UTC') |
| Frequency setting | df.asfreq('D') — convert to daily freq |

---

### ✅ Summary Table for Quick Revision

| Task | Method / Attribute | Example Code |
| --- | --- | --- |
| Convert to datetime | pd.to_datetime() | df['date'] = pd.to_datetime(df['date']) |
| Extract year, month, weekday | .dt.year, .dt.month, .dt.day_name() | df['month'] = df['date'].dt.month |
| Filter between dates | Boolean filtering | df[(df['date'] >= '2023-01') & (df['date'] <= ...)] |
| Set datetime index | set_index() | df.set_index('date', inplace=True) |
| Slice by time | Slicing with DatetimeIndex | df['2023-01':'2023-02'] |
| Resample | resample() | df.resample('M').mean() |
| Rolling average/sum | rolling() | df.rolling(3).mean() |
| Change frequency | asfreq() | df.asfreq('D') |

---

Would you like a **cheat sheet PDF** or **interactive notebook** for time series tasks?

### Question 48: How do you pivot data from long to wide format and vice versa?

**Note:** Related source answer: the chat mentions pivot/melt methods but does not give a full long-to-wide tutorial.

**Answer copied from the linked conversation:**

Great request, Himanshu! Here's a **comprehensive summary table** comparing the **most useful attributes and methods** for:

- Python `list`
- NumPy `ndarray`
- Tensor (PyTorch / TensorFlow)
- pandas `DataFrame`

This is ideal for **interview revision**, practical usage, and memory refresh.

---

### ✅ Comparison Table: Attributes and Methods

| Feature / Operation | Python list | NumPy ndarray | Tensor (PyTorch / TF) | pandas DataFrame |
| --- | --- | --- | --- | --- |
| Creation | [1, 2, 3] | np.array([1,2,3]) | torch.tensor([1,2,3]) / tf.constant([1,2,3]) | pd.DataFrame({...}) |
| Shape / Size | len(lst) | .shape, .size, .ndim | .shape, .size, .ndim | .shape, .size, .ndim |
| Data Type | Any | .dtype | .dtype | .dtypes (column-wise) |
| Indexing | lst[0], lst[-1] | arr[0], arr[1:3] | tensor[0], tensor[1:3] | .iloc, .loc, .at, .iat |
| Appending | lst.append(x) | np.append(arr, x) | torch.cat, tf.concat | df.append() or pd.concat() |
| Inserting / Extending | insert(), extend() | np.insert(), np.concatenate() | torch.cat() / torch.stack() | pd.concat(), df.insert() |
| Reshape | ❌ (manual nesting) | .reshape() or .resize() | .reshape() / tf.reshape() | .pivot(), .melt() |
| Transpose | ❌ | .T | .T (PyTorch), tf.transpose() | .T |
| Iteration | for x in lst | for x in arr or .flat | for x in tensor | for index, row in df.iterrows() |
| Aggregation (sum, mean, etc.) | sum(lst) | .sum(), .mean(), .std() | .sum(), .mean() | .sum(), .mean(), .agg() |
| Condition Filtering | [x for x in lst if x > 0] | arr[arr > 0] | tensor[tensor > 0] | df[df['col'] > 0] |
| Vectorized Ops | ❌ manual | arr * 2, arr + arr | tensor * 2, tensor + tensor | df['col'] * 2, broadcasting |
| Missing Values Handling | Manual | np.isnan() | Manual masking | .isna(), .fillna(), .dropna() |
| Copy vs View | Manual | .copy(), views by default | .clone() or detached in TF | .copy(deep=True) |
| Conversion to List | ✅ Native | .tolist() | .tolist() | .values.tolist() |
| Device (CPU/GPU) | ❌ | ❌ | .to('cuda'), .device | ❌ |
| Auto Grad (DL only) | ❌ | ❌ | .requires_grad_(), .grad | ❌ |
| Saving / Loading | pickle, manual | np.save(), np.load() | torch.save(), tf.saved_model | .to_csv(), .read_csv() |

---

### 🔍 Interview Insight:

"Each structure is best suited for a specific use case. I use lists for flexible storage, NumPy for fast numerical computations, tensors for deep learning with GPUs, and pandas for tabular data handling."

---

Would you like a **visual cheat sheet** or PDF version of this table for offline revision before interviews?

### Question 49: What’s the difference between `pivot()` and `melt()`?

**Note:** Related source answer: copied from the chat's Pandas methods comparison.

**Answer copied from the linked conversation:**

Great request, Himanshu! Here's a **comprehensive summary table** comparing the **most useful attributes and methods** for:

- Python `list`
- NumPy `ndarray`
- Tensor (PyTorch / TensorFlow)
- pandas `DataFrame`

This is ideal for **interview revision**, practical usage, and memory refresh.

---

### ✅ Comparison Table: Attributes and Methods

| Feature / Operation | Python list | NumPy ndarray | Tensor (PyTorch / TF) | pandas DataFrame |
| --- | --- | --- | --- | --- |
| Creation | [1, 2, 3] | np.array([1,2,3]) | torch.tensor([1,2,3]) / tf.constant([1,2,3]) | pd.DataFrame({...}) |
| Shape / Size | len(lst) | .shape, .size, .ndim | .shape, .size, .ndim | .shape, .size, .ndim |
| Data Type | Any | .dtype | .dtype | .dtypes (column-wise) |
| Indexing | lst[0], lst[-1] | arr[0], arr[1:3] | tensor[0], tensor[1:3] | .iloc, .loc, .at, .iat |
| Appending | lst.append(x) | np.append(arr, x) | torch.cat, tf.concat | df.append() or pd.concat() |
| Inserting / Extending | insert(), extend() | np.insert(), np.concatenate() | torch.cat() / torch.stack() | pd.concat(), df.insert() |
| Reshape | ❌ (manual nesting) | .reshape() or .resize() | .reshape() / tf.reshape() | .pivot(), .melt() |
| Transpose | ❌ | .T | .T (PyTorch), tf.transpose() | .T |
| Iteration | for x in lst | for x in arr or .flat | for x in tensor | for index, row in df.iterrows() |
| Aggregation (sum, mean, etc.) | sum(lst) | .sum(), .mean(), .std() | .sum(), .mean() | .sum(), .mean(), .agg() |
| Condition Filtering | [x for x in lst if x > 0] | arr[arr > 0] | tensor[tensor > 0] | df[df['col'] > 0] |
| Vectorized Ops | ❌ manual | arr * 2, arr + arr | tensor * 2, tensor + tensor | df['col'] * 2, broadcasting |
| Missing Values Handling | Manual | np.isnan() | Manual masking | .isna(), .fillna(), .dropna() |
| Copy vs View | Manual | .copy(), views by default | .clone() or detached in TF | .copy(deep=True) |
| Conversion to List | ✅ Native | .tolist() | .tolist() | .values.tolist() |
| Device (CPU/GPU) | ❌ | ❌ | .to('cuda'), .device | ❌ |
| Auto Grad (DL only) | ❌ | ❌ | .requires_grad_(), .grad | ❌ |
| Saving / Loading | pickle, manual | np.save(), np.load() | torch.save(), tf.saved_model | .to_csv(), .read_csv() |

---

### 🔍 Interview Insight:

"Each structure is best suited for a specific use case. I use lists for flexible storage, NumPy for fast numerical computations, tensors for deep learning with GPUs, and pandas for tabular data handling."

---

Would you like a **visual cheat sheet** or PDF version of this table for offline revision before interviews?

### Question 50: How would you use pandas to analyze and summarize sales data by region and month?

**Note:** Related source answer: groupby examples; not this exact sales scenario.

**Answer copied from the linked conversation:**

Absolutely, Himanshu! The `groupby()` operation in Pandas is one of the most powerful and frequently used tools in data analysis and feature engineering.

---

### ✅ What is groupby() in Pandas?

The `groupby()` operation **splits the data** into groups based on some criteria (column values), **applies a function** (like `mean()`, `sum()`, etc.), and **combines the result**.

👉 It follows the **"Split → Apply → Combine"** paradigm.

---

### 🔷 Common Use Cases for groupby()

- Aggregating statistics (mean, sum, count) for groups
- Segmenting and filtering data
- Transforming data within groups
- Applying custom functions to groups

---

### 🔧 Syntax

```python
df.groupby('column_name').agg_function()
```

---

### ✅ 1. Basic Aggregation Example

```python
import pandas as pd

data = {
    'Department': ['Sales', 'Sales', 'HR', 'HR', 'IT'],
    'Employee': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'Salary': [50000, 60000, 45000, 47000, 70000]
}
df = pd.DataFrame(data)

df.groupby('Department')['Salary'].mean()
```

### Output:

```python
Department
HR       46000.0
IT       70000.0
Sales    55000.0
```

---

### ✅ 2. Multiple Aggregations

```python
df.groupby('Department')['Salary'].agg(['mean', 'max', 'min'])
```

---

### ✅ 3. Group by Multiple Columns

```python
df.groupby(['Department', 'Employee'])['Salary'].sum()
```

---

### ✅ 4. Using reset_index() to Flatten the Result

```python
grouped = df.groupby('Department')['Salary'].mean().reset_index()
```

---

### ✅ 5. Using transform() to Broadcast Aggregated Values Back

```python
df['Dept_Avg_Salary'] = df.groupby('Department')['Salary'].transform('mean')
```

---

### ✅ 6. Filtering Groups

```python
grouped = df.groupby('Department').filter(lambda x: x['Salary'].mean() > 50000)
```

---

### ✅ 7. Applying Custom Functions with apply()

```python
def top_n(df, n=1):
    return df.sort_values('Salary', ascending=False).head(n)

df.groupby('Department').apply(top_n, n=1)
```

---

### 🧠 Summary Table: groupby() in Pandas

| Feature | Description | Example Code |
| --- | --- | --- |
| Basic Grouping | Group by one column | df.groupby('col')['val'].mean() |
| Multiple Aggregations | Perform multiple stats on same group | agg(['mean', 'sum']) |
| Group by Multiple Columns | Hierarchical grouping | df.groupby(['col1', 'col2']) |
| Reset index | Flatten the groupby result | .reset_index() |
| Broadcast Aggregation Result | Add result back to original DataFrame | .transform('mean') |
| Filter Groups | Keep only groups satisfying condition | .filter(lambda x: ...) |
| Custom Function on Group | Apply user-defined logic | .apply(func) |

---

### ✅ Interview Tip

"I use `groupby()` for both exploration and feature engineering. `transform()` is especially useful when I want to compare individual values to their group-level stats."

---

Would you like a cheat sheet or a code snippet for real-world `groupby()` use cases like churn prediction, sales analysis, or customer segmentation?

## Bonus: Pandas Coding Practice

### Bonus 1: Read a CSV, clean missing data, and summarize the dataset.

**Answer copied from the linked conversation:**

Absolutely, Himanshu! Data preprocessing is a **core step in every data science pipeline** — and mastering the relevant **Pandas techniques** helps clean, transform, and prepare data efficiently before applying ML algorithms.

Here’s a comprehensive summary of **data preprocessing using Pandas** — with explanations, examples, and a **quick revision table** at the end.

---

### ✅ 1. Loading the Dataset

```python
import pandas as pd

df = pd.read_csv('data.csv')
df.head()
```

---

### ✅ 2. Understanding the Data

```python
df.shape          # (rows, columns)
df.columns        # List of column names
df.info()         # Data types and null counts
df.describe()     # Summary statistics
```

---

### ✅ 3. Handling Missing Values

### 🔹 Detect

```python
df.isnull().sum()        # Count nulls per column
```

### 🔹 Drop

```python
df.dropna()              # Drop rows with any NaN
df.dropna(axis=1)        # Drop columns with any NaN
```

### 🔹 Impute

```python
df.fillna(0)
df['col'].fillna(df['col'].mean(), inplace=True)
```

---

### ✅ 4. Handling Duplicates

```python
df.duplicated().sum()
df.drop_duplicates(inplace=True)
```

---

### ✅ 5. Renaming Columns

```python
df.rename(columns={'old_name': 'new_name'}, inplace=True)
```

---

### ✅ 6. Changing Data Types (Type Casting)

```python
df['date'] = pd.to_datetime(df['date'])
df['col'] = df['col'].astype(int)
```

---

### ✅ 7. Filtering and Subsetting

```python
df[df['col'] > 50]                      # Row filter
df[['col1', 'col2']]                   # Column subset
```

---

### ✅ 8. Feature Engineering

```python
df['new_col'] = df['col1'] / df['col2']  # Derived feature
df['year'] = df['date'].dt.year          # Extract from datetime
```

---

### ✅ 9. Encoding Categorical Variables

```python
pd.get_dummies(df, columns=['category_col'])           # One-hot encoding
df['label_encoded'] = df['category_col'].astype('category').cat.codes
```

---

### ✅ 10. Scaling/Normalization

Usually done with Scikit-learn:

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
df[['scaled_col']] = scaler.fit_transform(df[['col']])
```

---

### ✅ 11. Grouping & Aggregation

```python
df.groupby('category')['value'].mean()
df.groupby(['col1', 'col2']).agg({'value': ['sum', 'mean']})
```

---

### ✅ 12. Merging, Joining, and Concatenation

```python
pd.concat([df1, df2])                        # Stack vertically
pd.merge(df1, df2, on='key')                # SQL-style join
```

---

### ✅ 13. Exporting the Cleaned Data

```python
df.to_csv("cleaned_data.csv", index=False)
```

---

### 🧠 Summary Table: Quick Revision

| Step | Function / Method | Notes |
| --- | --- | --- |
| Load Data | pd.read_csv() | Read CSV, Excel, JSON, etc. |
| Inspect Data | df.info(), df.describe() | Data types, nulls, stats |
| Handle Nulls | dropna(), fillna() | Drop or impute |
| Remove Duplicates | duplicated(), drop_duplicates() |  |
| Rename / Reformat | rename(), astype(), to_datetime() | For consistent formats |
| Filter/Subsets | df[df['x'] > 0], df[['x', 'y']] | Logic-based filtering |
| Feature Engineering | Math ops, dt accessor | New columns |
| Encode Categoricals | get_dummies(), .cat.codes | For ML algorithms |
| Scaling | StandardScaler, MinMaxScaler | Sklearn tools |
| Grouping / Aggregation | groupby(), agg() | For summaries |
| Merge / Join | merge(), concat() | Combining datasets |
| Export | to_csv(), to_excel() | Save preprocessed data |

---

### ✅ Interview Tip:

“In data science projects, I usually start with null handling and type casting, followed by outlier removal, encoding, and scaling. Pandas makes it easy to build repeatable pipelines with readable code.”

---

Would you like a **reusable preprocessing function or pipeline class** using Pandas and Scikit-learn that you can plug into your ML projects?

### Bonus 2: Group and aggregate sales data by product and month.

**Answer copied from the linked conversation:**

Absolutely, Himanshu! The `groupby()` operation in Pandas is one of the most powerful and frequently used tools in data analysis and feature engineering.

---

### ✅ What is groupby() in Pandas?

The `groupby()` operation **splits the data** into groups based on some criteria (column values), **applies a function** (like `mean()`, `sum()`, etc.), and **combines the result**.

👉 It follows the **"Split → Apply → Combine"** paradigm.

---

### 🔷 Common Use Cases for groupby()

- Aggregating statistics (mean, sum, count) for groups
- Segmenting and filtering data
- Transforming data within groups
- Applying custom functions to groups

---

### 🔧 Syntax

```python
df.groupby('column_name').agg_function()
```

---

### ✅ 1. Basic Aggregation Example

```python
import pandas as pd

data = {
    'Department': ['Sales', 'Sales', 'HR', 'HR', 'IT'],
    'Employee': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'Salary': [50000, 60000, 45000, 47000, 70000]
}
df = pd.DataFrame(data)

df.groupby('Department')['Salary'].mean()
```

### Output:

```python
Department
HR       46000.0
IT       70000.0
Sales    55000.0
```

---

### ✅ 2. Multiple Aggregations

```python
df.groupby('Department')['Salary'].agg(['mean', 'max', 'min'])
```

---

### ✅ 3. Group by Multiple Columns

```python
df.groupby(['Department', 'Employee'])['Salary'].sum()
```

---

### ✅ 4. Using reset_index() to Flatten the Result

```python
grouped = df.groupby('Department')['Salary'].mean().reset_index()
```

---

### ✅ 5. Using transform() to Broadcast Aggregated Values Back

```python
df['Dept_Avg_Salary'] = df.groupby('Department')['Salary'].transform('mean')
```

---

### ✅ 6. Filtering Groups

```python
grouped = df.groupby('Department').filter(lambda x: x['Salary'].mean() > 50000)
```

---

### ✅ 7. Applying Custom Functions with apply()

```python
def top_n(df, n=1):
    return df.sort_values('Salary', ascending=False).head(n)

df.groupby('Department').apply(top_n, n=1)
```

---

### 🧠 Summary Table: groupby() in Pandas

| Feature | Description | Example Code |
| --- | --- | --- |
| Basic Grouping | Group by one column | df.groupby('col')['val'].mean() |
| Multiple Aggregations | Perform multiple stats on same group | agg(['mean', 'sum']) |
| Group by Multiple Columns | Hierarchical grouping | df.groupby(['col1', 'col2']) |
| Reset index | Flatten the groupby result | .reset_index() |
| Broadcast Aggregation Result | Add result back to original DataFrame | .transform('mean') |
| Filter Groups | Keep only groups satisfying condition | .filter(lambda x: ...) |
| Custom Function on Group | Apply user-defined logic | .apply(func) |

---

### ✅ Interview Tip

"I use `groupby()` for both exploration and feature engineering. `transform()` is especially useful when I want to compare individual values to their group-level stats."

---

Would you like a cheat sheet or a code snippet for real-world `groupby()` use cases like churn prediction, sales analysis, or customer segmentation?

### Bonus 3: Merge two datasets and calculate per-user statistics.

**Answer copied from the linked conversation:**

Great question, Himanshu! Merging and joining DataFrames is a core concept in data preprocessing, especially when working with relational datasets or combining multiple sources of information — very common in **data science pipelines**.

---

### ✅ Part 1: How to Merge and Join DataFrames in Pandas

### 1. Using merge()

The `merge()` function in pandas is similar to SQL joins and allows you to combine rows from two DataFrames based on a **key column**.

```python
pd.merge(left_df, right_df, how='inner', on='key_column')
```

### 🔹 Example:

```python
import pandas as pd

df1 = pd.DataFrame({
    'emp_id': [1, 2, 3],
    'name': ['Alice', 'Bob', 'Charlie']
})

df2 = pd.DataFrame({
    'emp_id': [1, 2, 4],
    'salary': [50000, 60000, 70000]
})

merged_df = pd.merge(df1, df2, how='inner', on='emp_id')
```

📤 **Output**:

```python
emp_id    name  salary
0       1   Alice   50000
1       2     Bob   60000
```

---

### 2. Using join()

The `join()` method is used to combine columns of another DataFrame using **index** or a key column.

```python
df1.join(df2, how='left')
```

### 🔹 Example:

```python
df1 = df1.set_index('emp_id')
df2 = df2.set_index('emp_id')

joined_df = df1.join(df2, how='inner')
```

📤 **Output**:

```python
name  salary
emp_id
1        Alice   50000
2          Bob   60000
```

---

### 3. Using concat()

Use `concat()` when you want to **stack** DataFrames vertically (`axis=0`) or horizontally (`axis=1`).

```python
pd.concat([df1, df2], axis=1)
```

---

### ✅ Part 2: Difference Between Merge and Join in Pandas

| Feature | merge() | join() |
| --- | --- | --- |
| Similar to SQL | Yes (Explicit control over keys) | Partial SQL-like join via index |
| Join Key | Column(s) specified in on | Uses index by default |
| Flexibility | High – can join on multiple columns | Limited – works mainly on index |
| Syntax | pd.merge(df1, df2, on='key') | df1.join(df2) |
| Default Join Type | inner | left |
| Use Case | When keys are columns and you need control | When joining on index |

---

### 🧠 Join Types in Both merge() and join()

| Type | Description |
| --- | --- |
| inner | Only matching keys from both DataFrames |
| left | All rows from left DataFrame, matching from right |
| right | All rows from right DataFrame, matching from left |
| outer | All keys from both; fill missing with NaNs |

---

### ✅ Interview Tip:

“If I need fine control over join keys and conditions (like multiple keys or suffixes for column name conflicts), I prefer `merge()`. For simple index-based joins, especially when working with time series or hierarchically indexed data, `join()` is faster and cleaner.”

---

Would you like real-life examples of merge/join in customer churn, sales forecasting, or fraud detection datasets?
Absolutely, Himanshu! The `groupby()` operation in Pandas is one of the most powerful and frequently used tools in data analysis and feature engineering.

---

### ✅ What is groupby() in Pandas?

The `groupby()` operation **splits the data** into groups based on some criteria (column values), **applies a function** (like `mean()`, `sum()`, etc.), and **combines the result**.

👉 It follows the **"Split → Apply → Combine"** paradigm.

---

### 🔷 Common Use Cases for groupby()

- Aggregating statistics (mean, sum, count) for groups
- Segmenting and filtering data
- Transforming data within groups
- Applying custom functions to groups

---

### 🔧 Syntax

```python
df.groupby('column_name').agg_function()
```

---

### ✅ 1. Basic Aggregation Example

```python
import pandas as pd

data = {
    'Department': ['Sales', 'Sales', 'HR', 'HR', 'IT'],
    'Employee': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'Salary': [50000, 60000, 45000, 47000, 70000]
}
df = pd.DataFrame(data)

df.groupby('Department')['Salary'].mean()
```

### Output:

```python
Department
HR       46000.0
IT       70000.0
Sales    55000.0
```

---

### ✅ 2. Multiple Aggregations

```python
df.groupby('Department')['Salary'].agg(['mean', 'max', 'min'])
```

---

### ✅ 3. Group by Multiple Columns

```python
df.groupby(['Department', 'Employee'])['Salary'].sum()
```

---

### ✅ 4. Using reset_index() to Flatten the Result

```python
grouped = df.groupby('Department')['Salary'].mean().reset_index()
```

---

### ✅ 5. Using transform() to Broadcast Aggregated Values Back

```python
df['Dept_Avg_Salary'] = df.groupby('Department')['Salary'].transform('mean')
```

---

### ✅ 6. Filtering Groups

```python
grouped = df.groupby('Department').filter(lambda x: x['Salary'].mean() > 50000)
```

---

### ✅ 7. Applying Custom Functions with apply()

```python
def top_n(df, n=1):
    return df.sort_values('Salary', ascending=False).head(n)

df.groupby('Department').apply(top_n, n=1)
```

---

### 🧠 Summary Table: groupby() in Pandas

| Feature | Description | Example Code |
| --- | --- | --- |
| Basic Grouping | Group by one column | df.groupby('col')['val'].mean() |
| Multiple Aggregations | Perform multiple stats on same group | agg(['mean', 'sum']) |
| Group by Multiple Columns | Hierarchical grouping | df.groupby(['col1', 'col2']) |
| Reset index | Flatten the groupby result | .reset_index() |
| Broadcast Aggregation Result | Add result back to original DataFrame | .transform('mean') |
| Filter Groups | Keep only groups satisfying condition | .filter(lambda x: ...) |
| Custom Function on Group | Apply user-defined logic | .apply(func) |

---

### ✅ Interview Tip

"I use `groupby()` for both exploration and feature engineering. `transform()` is especially useful when I want to compare individual values to their group-level stats."

---

Would you like a cheat sheet or a code snippet for real-world `groupby()` use cases like churn prediction, sales analysis, or customer segmentation?

### Bonus 4: Use `pivot_table()` to summarize categorical data.

**Source answer:** No corresponding answer was found in the linked conversation.

### Bonus 5: Create rolling 7-day averages on time-series data.

**Answer copied from the linked conversation:**

Excellent questions—these are **core pandas operations** that are essential for **time series data preprocessing and analysis** in data science interviews.

---

### ✅ 1. How do you convert a column to datetime format?

You can use **`pd.to_datetime()`** to convert a column to datetime.

```python
import pandas as pd

df = pd.DataFrame({'date': ['2023-01-01', '2023-05-12', '2023-12-25']})
df['date'] = pd.to_datetime(df['date'])
print(df.dtypes)
```

✅ **Tip:** If the format is ambiguous or not standard, specify the `format`:

```python
df['date'] = pd.to_datetime(df['date'], format='%d-%m-%Y')
```

---

### ✅ 2. How do you extract year, month, weekday from a datetime column?

Once the column is converted to datetime:

```python
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['weekday'] = df['date'].dt.day_name()   # e.g., 'Monday'
```

You can also extract:

```python
df['day'] = df['date'].dt.day
df['hour'] = df['date'].dt.hour
df['week'] = df['date'].dt.isocalendar().week
df['quarter'] = df['date'].dt.quarter
```

---

### ✅ 3. How do you filter data between two dates?

Assuming `df['date']` is in datetime format:

```python
start = '2023-01-01'
end = '2023-06-30'
filtered_df = df[(df['date'] >= start) & (df['date'] <= end)]
```

Or using `pd.Timestamp` objects:

```python
filtered_df = df[(df['date'] >= pd.Timestamp('2023-01-01')) &
                 (df['date'] <= pd.Timestamp('2023-06-30'))]
```

✅ Tip: Can also filter using **datetime index** (see next point).

---

### ✅ 4. What is a datetime index and how is it useful in time series analysis?

A **DatetimeIndex** makes time series operations fast and intuitive. It’s created when you set a datetime column as the index.

```python
df.set_index('date', inplace=True)
print(df.index)  # DatetimeIndex
```

### 🔹 Benefits of DatetimeIndex:

| Feature | Example |
| --- | --- |
| Time-based slicing | df['2023-01'] or df['2023-01-01':'2023-01-15'] |
| Resampling | df.resample('M').mean() — monthly average |
| Rolling windows | df.rolling(window=3).mean() |
| Time zone handling | df.tz_localize('UTC') |
| Frequency setting | df.asfreq('D') — convert to daily freq |

---

### ✅ Summary Table for Quick Revision

| Task | Method / Attribute | Example Code |
| --- | --- | --- |
| Convert to datetime | pd.to_datetime() | df['date'] = pd.to_datetime(df['date']) |
| Extract year, month, weekday | .dt.year, .dt.month, .dt.day_name() | df['month'] = df['date'].dt.month |
| Filter between dates | Boolean filtering | df[(df['date'] >= '2023-01') & (df['date'] <= ...)] |
| Set datetime index | set_index() | df.set_index('date', inplace=True) |
| Slice by time | Slicing with DatetimeIndex | df['2023-01':'2023-02'] |
| Resample | resample() | df.resample('M').mean() |
| Rolling average/sum | rolling() | df.rolling(3).mean() |
| Change frequency | asfreq() | df.asfreq('D') |

---

Would you like a **cheat sheet PDF** or **interactive notebook** for time series tasks?
