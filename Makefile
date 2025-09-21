VENV_DIR := .venv/PY-VENV
REQUIREMENTS_FILE := requirements.txt

.PHONY: init format lint help

init: $(REQUIREMENTS_FILE)
	@ln -sf $(CURDIR)/.hooks/pre-commit.sh .git/hooks/pre-commit
	@if [ ! -d "$(VENV_DIR)" ]; then \
		python3 -m venv $(VENV_DIR); \
	fi
	@. $(VENV_DIR)/bin/activate && pip install --upgrade pip && pip install -r $(REQUIREMENTS_FILE)

format:
	@. $(VENV_DIR)/bin/activate && \
	find src -type f -name '*.sh' -print0 | xargs -0 -r shfmt -w -i 4 && \
	ruff format --force-exclude -- src

lint:
	@. $(VENV_DIR)/bin/activate && \
	find src -type f -name '*.sh' -print0 | xargs -0 -r shellcheck -e SC2034 && \
	ruff check --force-exclude -- src && \
	mypy --pretty -- src

help:
	@echo "Available targets:"
	@echo "  init          - Set up py venv and install requirements"
	@echo "  lint          - Run lint on all bash and python scripts"
	@echo "  format        - Run format on all bash and python scripts"
	@echo "  help          - Show this help message"

