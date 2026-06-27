# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This is the course repo for Ed Donner's "LLM Engineering" — an 8-week, project-based curriculum. It is **not** a single application: each `weekN/` directory is a self-contained module of Jupyter notebooks (`day1.ipynb` … `day5.ipynb`) plus supporting `.py` modules. Code is written to be run cell-by-cell and tweaked by learners, not deployed. Each week builds skills that culminate in the autonomous multi-agent system in `week8/`.

## Environment & commands

The canonical toolchain is **uv** (an `environment.yml` for conda also exists as a legacy alternative, but prefer uv):

```bash
uv sync                 # install all deps into .venv (Python 3.12)
uv run <script.py>      # run a python file (no manual venv activation needed)
uv add <package>        # add a dependency (instead of pip install)
uv run jupyter lab      # launch notebooks
```

There is **no build, lint, or test suite** — this is course material. "Running" means executing notebook cells or `uv run`-ing a script. Diagnostics for environment issues live in `setup/diagnostics.py` / `setup/diagnostics.ipynb`; `setup/SETUP-new.md` is the full student setup guide.

### Secrets

All notebooks/scripts load credentials via `python-dotenv` (`load_dotenv(override=True)`) from a `.env` file in the repo root. Never read or print `.env` contents. Keys referenced across the codebase include: `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GOOGLE_API_KEY`, `DEEPSEEK_API_KEY`, `GROQ_API_KEY`, `HF_TOKEN`, and the Pushover keys (`PUSHOVER_USER`, `PUSHOVER_TOKEN`) used by the Week 8 messaging agent. Ollama-only paths require no keys.

### Cost-conscious model defaults

When writing or editing course code, keep API spend minimal: prefer `gpt-4.1-nano` for OpenAI and `claude-3-haiku-20240307` for Anthropic unless a lab specifically calls for a larger model. Many labs also offer a free local path via Ollama (`ollama run llama3.2` — **not** llama3.3, which is too large).

## Architecture notes worth knowing before editing

- **Weeks progress in capability.** Roughly: W1 frontier APIs + web scraping; W2 Gradio UIs, multi-model, tools; W3 HuggingFace/open-source + Colab GPUs; W4 code generation; W5 RAG (LangChain + Chroma, see `week5/knowledge-base/`); W6/W7 fine-tuning a price-prediction model (the "pricer", with `wandb` and Modal); W8 the capstone agent framework.

- **Week 8 is the only large multi-file system.** `week8/price_is_right.py` is a Gradio app driven by `deal_agent_framework.py` (`DealAgentFramework`), which orchestrates the agents in `week8/agents/`. Agents subclass a common `Agent` base (`agents/agent.py`) and include `PlanningAgent`, `ScannerAgent`, `FrontierAgent`, `SpecialistAgent`, `EnsembleAgent`, `MessagingAgent`. The system uses a local **ChromaDB** vector store and reads RSS deals via `feedparser`.

- **Modal for remote GPU inference.** `week8/pricer_service2.py`, `pricer_service.py`, `pricer_ephemeral.py`, and `agents/specialist_agent.py` define Modal apps (`modal.App(...)`) that serve a fine-tuned Llama model on a GPU. They depend on Modal secrets (e.g. `huggingface-secret`) and constants like `HF_USER`, `RUN_NAME`, `REVISION` that pin a specific fine-tune — change these together if pointing at a different model. Deploy/run via the Modal CLI, not `uv run`.

- **Gradio is the standard UI layer** across weeks (W2 onward). UI scripts launch with `gr.Blocks`/`launch()`.

## Community contributions

Every week has a `community-contributions/` (or `community_contributions/`) directory holding learners' submitted variants of the labs. These are PR-driven (the repo's git history is almost entirely merged contribution PRs). **Do not refactor, "fix", or touch files under these directories** unless explicitly asked — they are independent student work, not shared code. Course code lives directly in `weekN/`, not in the contribution folders.

## Guides

`guides/01_intro.ipynb` … `14_docker_terraform.ipynb` are standalone reference notebooks (command line, git, async Python, AI APIs + Ollama, frontend, etc.). Treat them as documentation rather than part of any week's project flow.
