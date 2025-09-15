VENV_DIR := .venv/PY-VENV
REQUIREMENTS_FILE := requirements.txt

.PHONY: init lint help

init: $(REQUIREMENTS_FILE)
	@ln -sf $(CURDIR)/.hooks/pre-commit.sh .git/hooks/pre-commit
	@if [ ! -d "$(VENV_DIR)" ]; then \
		python3 -m venv $(VENV_DIR); \
	fi
	@. $(VENV_DIR)/bin/activate && pip install --upgrade pip && pip install -r $(REQUIREMENTS_FILE)

lint:
	@. $(VENV_DIR)/bin/activate && \
	find scripts -type f -name '*.sh' -print0 | xargs -0 -r shellcheck -e SC2034 --

help:
	@echo "Available targets:"
	@echo "  init          - Set up py venv and install requirements"
	@echo "  lint          - Run shellcheck on all shell scripts files"
	@echo "  help          - Show this help message"

