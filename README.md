#

## INSTALL

```
sudo apt-add-repository ppa:swi-prolog/stable
sudo apt-get update
sudo apt-get install swi-prolog
```

## RUN

```
swipl -s palworld.pl
```

## TESTE

### Pesquisas
```
buscar_por_nome(lamball, Numero, Tipo, Trabalhos, Montaria, Passivas).
```
Numero = 1,
Tipo = neutro,
Trabalhos = [trabalho_manual, transporte, agricultura],
Montaria = nao,
Passivas = [fluffy_shield].


```
buscar_por_tipo(neutro, ListaNomes).
```
ListaNomes = [lamball, cattiva, chikipi, direhowl].


```
buscar_por_tipos([neutro], ListaNomes).
```
ListaNomes = [lamball, cattiva, chikipi, direhowl]


```
buscar_por_trabalho(mineracao, ListaNomes).
```
ListaNomes = [cattiva, rushoar, mammorest].


```
buscar_por_trabalhos([transporte, corte], ListaNomes).
```
ListaNomes = [mossanda, grizzbolt].


```
buscar_por_montaria(ListaNomes).
```
ListaNomes = [rushoar, direhowl, mossanda, galeclaw, kitsun, surfent, mammorest, grizzbolt, jetragon].


```
buscar_por_numero(103, Nome, Tipo, Trabalhos, Montaria, Passivas).
```
Nome = grizzbolt,
Tipo = eletrico,
Trabalhos = [geracao_eletricidade, trabalho_manual, transporte, corte],
Montaria = sim,
Passivas = [yellow_tank].

### Pal Akinator

```
akinator.
```

