# Python Code Conventions

Essential Python patterns and industry-standard best practices.

> **Template Instructions**:
> - Replace `{package_name}` with your package name
> - Replace `{DomainModel}`, `{Service}` with your actual class names
> - Customize tool configurations in `pyproject.toml` section
> - Remove this instruction block after customization

## Project Setup Philosophy

### Package Management
**Use `uv`** for all dependency management:
- Faster than pip/poetry
- Better dependency resolution
- Modern Python tooling

```bash
# Install dependencies
uv sync

# Add new dependency
uv add requests

# Add dev dependency
uv add --dev pytest
```

### Project Structure
**Start with `pyproject.toml`** - modern Python standard (PEP 621):
- All metadata in one place
- No `setup.py` or `setup.cfg`
- Better tool integration
- Clear dependency declaration

### Virtual Environments
**Projects MUST run in a virtual environment**:

```bash
# Create virtual environment
uv venv

# Activate (Unix/macOS)
source .venv/bin/activate

# Activate (Windows)
.venv\Scripts\activate

# Install dependencies
uv sync
```

**Never install packages globally** - always use project-specific virtual environments.

## Code Style

### Naming
- **Modules/Packages**: `lowercase_with_underscores`
- **Classes**: `PascalCase`
- **Functions/Variables**: `snake_case`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private**: `_leading_underscore`

### Import Organization
```python
# 1. Standard library
import asyncio
from pathlib import Path

# 2. Third-party packages
import httpx
from pydantic import BaseModel

# 3. Local imports
from {package_name}.domain import models
```

Use `ruff format` for automatic formatting.

## Type Hints

**Always use type hints** - recommended to enforce with `mypy` strict mode:

```python
# ✅ Good
def process_items(self, items: list[Item]) -> list[Result]:
    pass

async def fetch_data(self) -> AsyncIterator[Record]:
    pass

# ❌ Bad
def process(data):
    pass
```

## Immutability

Use frozen dataclasses and Pydantic models:

```python
from dataclasses import dataclass
from pydantic import BaseModel, ConfigDict

@dataclass(frozen=True)
class {DomainModel}:
    id: str
    name: str

class AppConfig(BaseModel):
    model_config = ConfigDict(frozen=True)
    api_key: str
    timeout: int = 30
```

## Error Handling

### Exception Chaining
**Always chain exceptions** to preserve context:

```python
# ✅ Good
try:
    data = json.loads(line)
except json.JSONDecodeError as err:
    raise ValidationError(f"Invalid JSON at line {n}") from err

# ❌ Bad
except json.JSONDecodeError:
    raise ValidationError("Invalid JSON")
```

### Guard Clauses
Use early returns:

```python
# ✅ Good
def process(item: Item) -> Result:
    if not item.is_valid():
        raise ValueError("Invalid item")

    # Happy path without nesting
    return self._transform(item)

# ❌ Bad
def process(item: Item) -> Result:
    if item.is_valid():
        return self._transform(item)
    else:
        raise ValueError("Invalid item")
```

## Async Patterns

### Async I/O
```python
import aiofiles

async def read_file(path: Path) -> AsyncIterator[str]:
    async with aiofiles.open(path, 'r') as f:
        async for line in f:
            yield line.strip()
```

### CPU-Bound in Thread Pool
```python
import asyncio

# Run blocking operations in thread pool
result = await asyncio.to_thread(
    cpu_intensive_function,
    arg1, arg2
)
```

## Testing

### Test Organization
```
tests/
├── unit/           # Fast, mocked dependencies
├── integration/    # Real components
└── fixtures/       # Test data
```

### Async Tests
```python
import pytest

@pytest.mark.asyncio
async def test_async_operation():
    result = await async_function()
    assert result is not None
```

Configure pytest with:
```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
```

### Mocking Strategy
Mock only slow/expensive operations:

```python
from unittest.mock import patch, Mock

@patch('module.ExternalService')
async def test_with_mock(mock_service):
    # Use real components where possible
    # Mock only external dependencies
    pass
```

## Documentation

### Docstrings
Google-style for public APIs:

```python
def transform(self, data: list[Item]) -> list[Result]:
    """Transform items into results.

    Args:
        data: Items to transform.

    Returns:
        List of transformation results.

    Raises:
        TransformError: If transformation fails.
    """
```

Focus on **why**, not what the code obviously does.

## Dependency Injection

Pass dependencies through constructors:

```python
# ✅ Good
class {Service}:
    def __init__(
        self,
        repository: Repository,
        cache: Cache,
    ):
        self.repository = repository
        self.cache = cache

# ❌ Bad
class {Service}:
    def __init__(self):
        self.repository = PostgresRepository()  # Hard-coded
```

## Code Quality Tools

**Always use `uv run`** to ensure commands run in project's virtual environment:

```bash
# Format
uv run ruff format src/ tests/

# Lint
uv run ruff check src/ tests/

# Type check
uv run mypy src/

# Test
uv run pytest tests/ --cov={package_name}
```

### Tool Configuration (pyproject.toml)

**Complete pyproject.toml structure**:

```toml
[build-system]
requires = ["setuptools>=68.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "{package_name}"
version = "0.1.0"
description = "Project description"
readme = "README.md"
requires-python = ">=3.10"
authors = [
    {name = "Your Name", email = "your.email@example.com"}
]

dependencies = [
    "pydantic>=2.0.0",
    # Add your dependencies
]

# Modern standard (PEP 735), works with uv
[dependency-groups]
dev = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "pytest-cov>=4.1.0",
    "mypy>=1.5.0",
    "ruff>=0.1.0",
]

# Standard Python packaging, works with pip
[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "pytest-cov>=4.1.0",
    "mypy>=1.5.0",
    "ruff>=0.1.0",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.ruff]
line-length = 100
target-version = "py310"

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "UP",  # pyupgrade
    "B",   # flake8-bugbear
    "SIM", # flake8-simplify
]

[tool.mypy]
python_version = "3.10"
strict = true
warn_return_any = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
addopts = "-v --cov={package_name}"
```

## Common Patterns

### Streaming with Batching
```python
async def _batch_items(self) -> AsyncIterator[list[T]]:
    """Group items into batches."""
    batch = []
    async for item in self.source():
        batch.append(item)
        if len(batch) >= self.batch_size:
            yield batch
            batch = []

    if batch:  # Don't forget partial batch
        yield batch
```

### Context Managers
```python
# Prefer context managers for resource management
async with aiofiles.open(path, 'r') as f:
    content = await f.read()

with resource_manager() as resource:
    resource.process()
```

### List Comprehensions
```python
# ✅ Good: Clear and Pythonic
results = [transform(x) for x in items]

# ❌ Bad: Unnecessary loop
results = []
for x in items:
    results.append(transform(x))
```

But use explicit loops when:
- Logic is complex (>2 lines)
- You need error handling
- Readability suffers

## Python Best Practices

### EAFP over LBYL
"Easier to Ask Forgiveness than Permission":

```python
# ✅ Good: EAFP
try:
    return data['key']
except KeyError:
    return default

# ❌ Bad: LBYL
if 'key' in data:
    return data['key']
else:
    return default
```

### Use Built-ins
```python
# ✅ Good
if item in collection:
    ...

total = sum(values)
items = list(filter(predicate, data))

# ❌ Bad
found = False
for x in collection:
    if x == item:
        found = True

total = 0
for v in values:
    total += v
```

### Avoid Mutable Default Arguments
```python
# ✅ Good
def process(items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    return items

# ❌ Bad
def process(items: list[str] = []) -> list[str]:  # Shared mutable default!
    return items
```

### Use Dataclasses
```python
# ✅ Good
@dataclass(frozen=True)
class Point:
    x: float
    y: float

# ❌ Bad
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __repr__(self):
        return f"Point({self.x}, {self.y})"
    # ... more boilerplate
```

### Explicit is Better than Implicit
```python
# ✅ Good
from pathlib import Path

def read_file(path: Path) -> str:
    with path.open() as f:
        return f.read()

# ❌ Bad
def read_file(p):  # What type? What does it return?
    with open(p) as f:
        return f.read()
```

## Performance

### Generator Expressions for Large Data
```python
# ✅ Good: Memory-efficient
total = sum(len(line) for line in large_file)

# ❌ Bad: Loads everything into memory
total = sum([len(line) for line in large_file])
```

### Use `__slots__` for Many Instances
```python
@dataclass(frozen=True, slots=True)
class Record:
    """Slots reduce memory overhead when creating many instances."""
    id: str
    data: str
```

### Async Concurrency
```python
# ✅ Good: Run I/O operations concurrently
results = await asyncio.gather(
    fetch_user(id1),
    fetch_user(id2),
    fetch_user(id3),
)

# ❌ Bad: Sequential I/O
results = []
for user_id in [id1, id2, id3]:
    results.append(await fetch_user(user_id))
```

---

For project-specific architecture patterns, see project documentation.
