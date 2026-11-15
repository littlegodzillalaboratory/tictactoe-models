version ?= 0.9.0-pre.0

ci: clean lint gen-all

define python_venv
	. .venv/bin/activate && $(1)
endef

deps:
	python3 -m venv .venv
	$(call python_venv,python3 -m pip install -r requirements.txt)
	$(call deps_extra)

rmdeps:
	rm -rf .venv/

deps-extra-apt:
	apt-get update
	apt-get install -y markdownlint

deps-upgrade:
	python3 -m venv .venv
	$(call python_venv,python3 -m pip install -r requirements-dev.txt)
	$(call python_venv,pip-compile --upgrade)

clean:
	rm -rf stage/

lint:
	shellcheck scripts/*.sh

gen:
	@if [ -z "$(BOARD_SIZE)" ]; then \
		echo "BOARD_SIZE is required. Example: make gen BOARD_SIZE=3" >&2; \
		exit 1; \
	fi
	MODEL_VERSION="$(version)" ./scripts/generate-model.sh "$(BOARD_SIZE)"

gen-all:
	MODEL_VERSION="$(version)" ./scripts/generate-models.sh

.PHONY: ci deps rmdeps deps-extra-apt deps-upgrade clean lint gen gen-all
