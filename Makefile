.PHONY: clean init format lint help

help: ## show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s - %s\n", $$1, $$2}'

init: ## setup hooks and install requirements
	@ln -sf $(CURDIR)/.hooks/pre-commit.sh .git/hooks/pre-commit
	@uv sync

update: ## update dependencies and sync
	@uv lock --upgrade
	@uv sync

clean: ## remove cache and virtual environment
	@rm -rf .venv .mypy_cache .ruff_cache

format: ## format scripts
	@find src -type f -name '*.sh' -print0 | xargs -0 -r uv run shfmt -w -i 4
	@uv run ruff format --force-exclude -- src

lint: ## lint scripts
	@find src -type f -name '*.sh' -print0 | xargs -0 -r uv run shellcheck -e SC2034
	@uv run ruff check --force-exclude -- src
	@uv run mypy --pretty -- src
