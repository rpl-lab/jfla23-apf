.DEFAULT_GOAL:=help

init: install_zelus install_probzelus ## Install all dependencies
	opam install -y mtime csv
	
install_zelus: ## Install the local version of Zelus (branch apf)
	opam pin -y -k path zelus

install_probzelus: ## Install the local version of ProbZelus (branch apf)
	opam pin -y -k path probzelus/zelus-libs
	opam pin -y -k path probzelus/probzelus

help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  make %-20s# %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
