.DEFAULT_GOAL:=help

NAME=radar
STEPS=6 # log 10x(STEPS - 1) steps

ZLI=$(wildcard *.zli)
ZCI=$(ZLI:zli=zci)

radar_apf.ml main_apf.ml:
	probzeluc -deps -apf -I `zeluc -where`-io -s main radar_apf.zls -o main_apf

radar_pf.ml main_pf.ml:
	probzeluc -deps -I `zeluc -where`-io -s main radar_pf.zls -o main_pf

exec_apf: radar_apf.ml main_apf.ml ## Launch the radar using APF
	mv main_apf.ml main.ml
	dune exec ./main.exe | head -n $(STEPS) > radar_apf.log

exec_pf: radar_pf.ml main_pf.ml ## Launch the radar using PF
	mv main_pf.ml main.ml
	dune exec ./main.exe | head -n $(STEPS) > radar_pf.log

%.zci: %.zli
	probzeluc $<

clean: ## Clean
	rm -f $(NAME).ml radar_apf.ml main_apf.ml radar_pf.ml main_pf.ml
	rm -f *.zci
	dune clean

.phony: exec_apf exec_pf

help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  make %-20s# %s\n", $$1, $$2 }' $(MAKEFILE_LIST)