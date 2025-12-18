.PHONY: clean init format lint help

clean:
	@rm -rf .venv .mypy_cache .ruff_cache

init:
	@ln -sf $(CURDIR)/.hooks/pre-commit.sh .git/hooks/pre-commit
	@uv sync --dev

format:
	@find src -type f -name '*.sh' -print0 | xargs -0 -r uv run shfmt -w -i 4
	@uv run ruff format --force-exclude -- src

lint:
	@find src -type f -name '*.sh' -print0 | xargs -0 -r uv run shellcheck -e SC2034
	@uv run ruff check --force-exclude -- src
	@uv run mypy --pretty -- src

help:
	@echo "Available targets:"
	@echo "  clean		- Remove cache and virtual environment"
	@echo "  init       - Set up py venv and install requirements"
	@echo "  lint       - Run lint on all bash and python scripts"
	@echo "  format     - Run format on all bash and python scripts"
	@echo "  help       - Show this help message"

