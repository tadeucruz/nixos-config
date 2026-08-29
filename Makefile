# Local validation for this flake, mirroring .github/workflows/check.yml.
#
# `make` (or `make check`) is the pre-commit gate: formatting + evaluation of
# every configuration. Evaluation is cross-platform, so the MacBook can also
# validate the NixOS hosts; only `build-<host>` needs a matching builder.

NIXOS_HOSTS  := citadel prothean legion omega
DARWIN_HOSTS := normandy
HOSTS        := $(NIXOS_HOSTS) $(DARWIN_HOSTS)

# Files nix actually sees: a dirty git tree is copied to the store without
# untracked files, so git-tracked *.nix is exactly the formatter's input.
NIX_FILES = $(shell git ls-files '*.nix')

# nixosConfigurations and darwinConfigurations expose the system closure under
# different attribute paths.
# $(strip) is required: the backslash-newline continuations below expand to a
# leading space, which would corrupt the flake attribute path.
attr = $(strip $(if $(filter $(1),$(DARWIN_HOSTS)),\
darwinConfigurations.$(1).system,\
nixosConfigurations.$(1).config.system.build.toplevel))

.DEFAULT_GOAL := check

# eval-%/build-% are deliberately NOT .PHONY: make skips implicit/pattern rule
# lookup for phony targets, which would turn `make eval-citadel` into a no-op.
# No file by those names exists, so they always run anyway.
.PHONY: help check eval fmt fmt-check git-check update update-check clean

help: ## Show this help
	@echo "Targets:"
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
	  | awk -F':.*?## ' '{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@echo "  \033[36meval-<host>\033[0m      Evaluate a single host"
	@echo "  \033[36mbuild-<host>\033[0m     Build a single host (needs a matching builder)"
	@echo
	@echo "Hosts: $(HOSTS)"

check: fmt-check eval ## Full validation: formatting + evaluation (default)
	@echo "==> all checks passed"

eval: git-check $(addprefix eval-,$(HOSTS)) ## Evaluate every configuration

# Evaluating the .drv path proves the whole module tree evaluates without
# building anything. The hash also lets you diff two revisions: an unchanged
# .drv means the refactor was a no-op.
eval-%: git-check
	@if ! echo '$(HOSTS)' | tr ' ' '\n' | grep -qx '$*'; then \
	  echo "error: unknown host '$*' (known: $(HOSTS))" >&2; exit 1; \
	fi
	@echo "==> eval $*"
	@out="$$(nix eval --raw '.#$(call attr,$*).drvPath')"; echo "    $$out"

build-%: git-check
	@if ! echo '$(HOSTS)' | tr ' ' '\n' | grep -qx '$*'; then \
	  echo "error: unknown host '$*' (known: $(HOSTS))" >&2; exit 1; \
	fi
	@if [ '$(findstring $*,$(NIXOS_HOSTS))' = '$*' ] && [ "$$(uname -s)" = Darwin ]; then \
	  echo "note: building a NixOS host from macOS needs a linux remote builder" >&2; \
	fi
	@echo "==> build $*"
	nix build --no-link --print-out-paths '.#$(call attr,$*)'

fmt: ## Format every tracked .nix file
	@echo "==> nixfmt"
	@nix fmt -- $(NIX_FILES)

fmt-check: ## Fail if any tracked .nix file is unformatted
	@echo "==> nixfmt --check"
	@nix fmt -- --check $(NIX_FILES)

# Flakes copy the git tree to the store *excluding untracked files*, so a new
# module that was never `git add`ed is invisible to nix: eval would silently
# validate the old tree. `git add -N` (intent to add) is enough to expose it.
git-check:
	@untracked="$$(git ls-files --others --exclude-standard -- '*.nix')"; \
	if [ -n "$$untracked" ] && [ -z "$(ALLOW_UNTRACKED)" ]; then \
	  echo "error: untracked .nix files are invisible to nix flake eval:" >&2; \
	  echo "$$untracked" | sed 's/^/  /' >&2; \
	  echo "run 'git add -N <file>' first, or set ALLOW_UNTRACKED=1" >&2; \
	  exit 1; \
	fi

update-check: ## Report available dependency bumps without touching files
	@./scripts/update.sh check

update: ## Apply dependency bumps (flake.lock, Proton, OGC kernel)
	@./scripts/update.sh apply

clean: ## Remove nix build result symlinks
	@rm -fv result result-*
