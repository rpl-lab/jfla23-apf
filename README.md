# Artefact JFLA 2023

Cet artefact accompagne l'article **Filtrer sans s'appauvrir : inférer les paramètres constants de modèles réactifs probabilistes** soumis aux JFLA 2023.

_G. Baudart, G. Bussone, L. Mandel, C. Tasson_

## Installation

Les prérequis pour l'installation de l'artefact sont :
- [opam](http://opam.ocaml.org/) avec la version 4.13.1 d'OCaml
- [openblas](https://github.com/xianyi/OpenBLAS) (requis pour Owl)
- [jupyter notebook](https://jupyter.org/) (pour générer certaines figures)


1. Cloner le dépôt et ses sous-modules :

```
$ git clone --recurse-submodules https://github.com/rpl-lab/jfla23-apf.git
```

2. Pour éviter de polluer votre environnement opam, nous recommandons d'utiliser un switch local avec la version 4.13.1 d'OCaml :

```
$ opam switch create ./ 4.13.1
```

3. Installer toutes les dépendances :

```
$ make init
```

## Premiers pas

Le répertoire `radar` contient l'exemple du radar présenté en Section 2.
Il y a deux versions du code selon qu'on utilise APF (`radar_apf.zls`) ou un filtre particulaire (`radar_pf.zls`).
Les deux versions sont quasiment identiques.
Seul l'appel à l'opérateur `infer` est différent.

```
$ diff radar_apf.zls radar_pf.zls
3c3
< open Infer_apf_mm
---
> open Infer_pf
38c38
<     and d = infer { apf_particles=500; apf_mm_particles=200} radar (delta, alpha)
---
>     and d = infer 100000 radar (delta, alpha)
```

Un Makefile permet d'exécuter l'une ou l'autre version.

```
$ make
Usage:
  make exec_apf            #  Launch the radar using APF
  make exec_pf             #  Launch the radar using PF
  make clean               #  Clean
```

Les commandes `make exec_apf` et `make exec_pf` exécutent le radar sur des données générées aléatoirement (les résultats peuvent donc varier d'une exécution à l'autre).
À chaque instant, on affiche l'observation courante et la position estimée sur `stderr`.
On utilise `stdout` pour sauvegarder dans les fichiers `radar_apf.log` et `radar_pf.log` 1000 échantillons de la distribution de `theta` tous les 10 pas de temps.

```
$ make exec_apf
probzeluc -deps -apf -I `zeluc -where`-io -s main radar_apf.zls -o main_apf
mv main_apf.ml main.ml
dune exec ./main.exe | head -n 6  > radar_apf.log
0 obs: (10.000000, 10.000000) X: (10.000000, 10.000000)
1 obs: (10.564251, 9.785522) X: (10.787054, 9.925122)
2 obs: (11.721199, 10.198548) X: (11.843823, 11.082907)
3 obs: (11.104925, 9.458678) X: (11.301106, 9.901853)
4 obs: (10.304054, 10.664873) X: (11.440811, 11.086348)
5 obs: (9.798609, 11.798562) X: (11.508064, 13.358447)
6 obs: (9.925167, 11.034628) X: (10.072817, 11.315459)
7 obs: (10.689631, 11.321984) X: (11.602716, 12.146057)
8 obs: (9.236907, 12.117168) X: (10.611060, 12.063032)
9 obs: (9.366406, 12.431641) X: (9.658461, 12.010533)
10 obs: (10.035358, 13.032434) X: (10.321051, 14.128873)
...
$ more radar_apf.log 
[(0.227483946036,-1.62723082569),(-0.0431923038602,-0.15341926808),(0.15027264859,0.831109279674),(0.867994977552,-0.975503058299),(0.16450489668,0.447589557741),(-1.31139193853,-0.496981018174),(-0.749595381361,-0.481036051673),(-1.31419301861,1.24287328468),(1.57733522826,-0.825589666251),(0.507177826864,-1.30215398153),(-0.115901490303,0.247414701077),(-0.826030595597,-0.346696304294)
...
```

Une fois que les deux fichiers de log sont générés, le notebook Python `plots.ipynb` permet de reproduire la Figure 2 pour visualiser les distributions obtenues pour `theta`.

## Implémentation

### Analyse Statique ([`zelus/compiler/rewrite`](https://github.com/rpl-lab/zelus/tree/8e852daab03caae9c29020331b8c0b22d3842203/compiler/rewrite))

[`apf_cst.ml`](https://github.com/rpl-lab/zelus/blob/8e852daab03caae9c29020331b8c0b22d3842203/compiler/rewrite/apf_cst.ml) associe à une expression l'ensemble des variables constantes qu'elle définit.

[`apf_proba.ml`](https://github.com/rpl-lab/zelus/blob/8e852daab03caae9c29020331b8c0b22d3842203/compiler/rewrite/apf_proba.ml) associe à une expression tirant une variable aléatoire la distribution qu'elle échantillonne.

[`apf_lift.ml`](https://github.com/rpl-lab/zelus/blob/8e852daab03caae9c29020331b8c0b22d3842203/compiler/rewrite/apf_lift.ml) contrôle si une expression est constante et ne dépend pas de variables locales.

### Compilation ([`zelus/compiler/rewrite`](https://github.com/rpl-lab/zelus/tree/8e852daab03caae9c29020331b8c0b22d3842203/compiler/rewrite))

[`apf_infer.ml`](https://github.com/rpl-lab/zelus/blob/8e852daab03caae9c29020331b8c0b22d3842203/compiler/rewrite/apf_infer.ml) compile les appels à `infer`.

[`apf_call.ml`](https://github.com/rpl-lab/zelus/blob/8e852daab03caae9c29020331b8c0b22d3842203/compiler/rewrite/apf_call.ml) compile les appels de nœud.

[`apf_sample.ml`](https://github.com/rpl-lab/zelus/blob/8e852daab03caae9c29020331b8c0b22d3842203/compiler/rewrite/apf_sample.ml) lance l'analyse statique, supprime les équations introduisant des paramètres constants et les rajoute en argument du nœud.

### Assumed Parameter Filter ([`probzelus/probzelus/inference`](https://github.com/rpl-lab/probzelus/tree/e056be0ad5a6e1283ddd9189513364fa2a60d465/probzelus/inference))

[`infer_apf.ml`](https://github.com/rpl-lab/probzelus/blob/e056be0ad5a6e1283ddd9189513364fa2a60d465/probzelus/inference/infer_apf.ml) est l'implémentation modulaire d'APF.

[`infer_apf_mm.ml`](https://github.com/rpl-lab/probzelus/blob/e056be0ad5a6e1283ddd9189513364fa2a60d465/probzelus/inference/infer_apf_mm.ml) spécialise l'implémentation modulaire en utilisant la méthode de correspondance des moments.

[`infer_apf_is.ml`](https://github.com/rpl-lab/probzelus/blob/e056be0ad5a6e1283ddd9189513364fa2a60d465/probzelus/inference/infer_apf_is.ml) spécialise l'implémentation modulaire en utilisant l'échantillonnage préférentiel.

## Évaluation

Les figures d'évaluation peuvent être re-générées en exécutant la commande `make bench` dans le dossier [`probzelus/bench-apf`](https://github.com/rpl-lab/probzelus/tree/e056be0ad5a6e1283ddd9189513364fa2a60d465/bench-apf). 
Elles se trouveront alors dans le dossier `probzelus/bench-apf/plots`, au format PDF.

```
$ cd probzelus/bench-apf
$ make bench
$ ls plots
coin-ess.pdf        radar-ess.pdf        sin-ess.pdf        split-ess.pdf
coin-mse-theta.pdf  radar-mse-theta.pdf  sin-mse-theta.pdf  split-mse-theta.pdf
kalman-mse-x.pdf    radar-mse-x.pdf      sin-mse-x.pdf      split-mse-x.pdf
```

Note : Avec un processeur Intel Core i5-6200U (2.30GHz), les figures mettent environ 35 minutes à être générées.
