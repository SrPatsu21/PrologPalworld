# Sistema especilista em Pals de Palworld

## INSTALAR

```sh
sudo apt-add-repository ppa:swi-prolog/stable
sudo apt-get update
sudo apt-get install swi-prolog
```

## RODAR

```sh
swipl -s palworld.pl
```

## COMO USAR

### Iniciar o especialista em Pal

```sh
iniciar_especialista.
```

### Pesquisas

**OBS: o jogo e a base de dados esta em desenvolvimento entao os resultados apresentados na documentacao podem ser diferentes dos reais mas o formato do retorno nao.**

- Buscar pelo nome:

    ```sh
    ?- pal_por_nome(cattiva).
    ```

    retorno:

    ```sh
    --- Dados de cattiva ---
    Número: 2
    Tipos: [normal]
    Habilidade: cat_helper
    Trabalhos: [gathering,handiwork,mining,transporting]
    Drops: [red_berries]
    Vida: 70
    Ataque: 70
    Defesa: 70
    Montaria: nao_montaria
    ```

- Buscar pelo numero:

    ```sh
    ?- pal_por_numero(7).
    ```

    retorno:

    ```sh
    --- Dados do Pal número 7 ---
    Nome: sparkit
    Tipos: [electricity]
    Habilidade: static_electricity
    Trabalhos: [generating_electricity,handiwork,transporting]
    Drops: [electric_organ]
    Vida: 60
    Ataque: 70
    Defesa: 75
    Montaria: nao_montaria
    ```

- Buscar pelo trabalho:

    ```sh
    ?- pals_com_trabalho(generating_electricity).
    ```

    retorno:

    ```sh
    Pals com o trabalho generating_electricity: [sparkit,jolthog]
    ```

- Buscar pelo drop:

    ```sh
    ?- pals_com_drop(wool).
    ```

    retorno:

    ```sh
    Pals que dropam wool: [lamball,cremis]
    ```
