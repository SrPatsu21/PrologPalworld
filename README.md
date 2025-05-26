# Sistema especilista em Pals de Palworld

## INSTALAR

```
sudo apt-add-repository ppa:swi-prolog/stable
sudo apt-get update
sudo apt-get install swi-prolog
```

## RODAR

```
swipl -s palworld.pl
```

## COMO USAR

### Pesquisas

**OBS: o jogo esta em desenvolvimento entao os resultados apresentados na documentacao podem ser diferentes dos reais mas o formato do retorno nao.**

- Buscar pelo nome:

    ```sh
    buscar_por_nome(lamball, Numero, Tipo, Trabalhos, Montaria, Passivas).
    ```

    Numero = 1, Tipo = neutro, Trabalhos = [trabalho_manual, transporte, agricultura], Montaria = nao, Passivas = [fluffy_shield].

    ou voce pode evitar o retorno de alguns parametros substituindo eles por _.

    ```sh
    buscar_por_nome(lamball, Numero, Tipo, _, _, Passivas).
    ```

    Numero = 1, Tipo = [neutro], Passivas = [fluffy_shield].

- Buscar por tipo:

    ```sh
    buscar_por_tipo(neutro, ListaNomes).
    ```

    ListaNomes = [lamball, cattiva, chikipi, direhowl].

- Buscar pos lista de tipo:

    ```sh
    buscar_por_tipos([neutro], ListaNomes).
    ```

    ListaNomes = [lamball, cattiva, chikipi, direhowl]

- Buscar por trabalho:

    ```sh
    buscar_por_trabalho(mineracao, ListaNomes).
    ```

    ListaNomes = [cattiva, rushoar, mammorest].

- Buscar por trabalhos:

    ```sh
    buscar_por_trabalhos([transporte, corte], ListaNomes).
    ```

    ListaNomes = [mossanda, grizzbolt].

- Buscar por montaria:

    ```sh
    buscar_por_montaria(ListaNomes).
    ```

    ListaNomes = [rushoar, direhowl, mossanda, galeclaw, kitsun, surfent, mammorest, grizzbolt, jetragon].

- Busca por numero

    ```sh
        buscar_por_numero(103, Nome, Tipo, Trabalhos, Montaria, Passivas).
    ```

    Nome = grizzbolt,
    Tipo = eletrico,
    Trabalhos = [geracao_eletricidade, trabalho_manual, transporte, corte],
    Montaria = sim,
    Passivas = [yellow_tank].

### Iniciar o especialista em Pal

```sh
iniciar_especialista.
```
