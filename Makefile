.DEFAULT_GOAL:=help

init: install_zelus install_probzelus ## Install all dependencies
	opam install -y mtime csv
	
install_zelus: ## Install the local version of Zelus (branch apf)
	opam pin -y -k path zelus

install_probzelus: ## Install the local version of ProbZelus (branch apf)
	opam pin -y -k path probzelus/zelus-libs
	opam pin -y -k path probzelus/probzelus

build:
	cd probzelus/bench-apf; for ex in coin kalman radar sin split; do cd $$ex; for algo in particles importance apf_mm; do cd $$algo; make build; cd ..; done; cd ..; done

run:
	cd probzelus/bench-apf; for ex in coin kalman radar sin split; do cd $$ex; for algo in particles importance apf_mm; do cd $$algo; make raw.csv & cd ..; done; cd ..; done; wait

csv:
	cd probzelus/bench-apf; for ex in coin kalman radar sin split; do cd $$ex; for algo in particles importance apf_mm; do cd $$algo; make error_theta.csv metric_theta.csv error_x.csv; cd ..; done; cd ..; done

pdf:
	cd probzelus/bench-apf; mkdir plots; for ex in coin kalman radar sin split; do cd $$ex; gnuplot *.gp; mv *.pdf ../plots; cd ..; done

bench: ## Generate benchmark figures in probzelus/bench-apf/plots
	make build
	make run
	make csv
	make pdf

help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  make %-20s# %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
