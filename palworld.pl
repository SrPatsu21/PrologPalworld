% BASE DE DADOS
% pal(Número, Nome, Tipos, Trabalhos, Montaria, Passivas).
:- [base_palworld].

%-------------------------------------------------------------------------------------------------------------------------------%
% Tipos e Trabalhos disponíveis
tipos_possiveis([fogo, agua, grama, eletrico, terra, vento, dragao, neutro]).
trabalhos_possiveis([trabalho_manual, transporte, agricultura, coleta, mineracao, plantio, corte, producao_medicinal, acendimento, geracao_eletricidade]).

%-------------------------------------------------------------------------------------------------------------------------------%
% Filtros
buscar_por_nome(Nome, Numero, Tipo, Trabalhos, Montaria, Passivas) :-
    pal(Numero, Nome, Tipo, Trabalhos, Montaria, Passivas).

buscar_por_tipo(Tipo, ListaNomes) :-
    findall(Nome, (pal(_, Nome, Tipos, _, _, _), member(Tipo, Tipos)), ListaNomes).

buscar_por_tipos(ListaTipos, ListaNomes) :-
    findall(Nome, (pal(_, Nome, Tipos, _, _, _), subset(ListaTipos, Tipos)), ListaNomes).

buscar_por_trabalho(Trabalho, ListaNomes) :-
    findall(Nome, (pal(_, Nome, _, Trabalhos, _, _), member(Trabalho, Trabalhos)), ListaNomes).

buscar_por_trabalhos(ListaTrabalhos, ListaNomes) :-
    findall(Nome, (pal(_, Nome, _, Trabalhos, _, _), subset(ListaTrabalhos, Trabalhos)), ListaNomes).

buscar_por_montaria(ListaNomes) :-
    findall(Nome, pal(_, Nome, _, _, sim, _), ListaNomes).

buscar_por_numero(Numero, Nome, Tipo, Trabalhos, Montaria, Passivas) :-
    pal(Numero, Nome, Tipo, Trabalhos, Montaria, Passivas).

%-------------------------------------------------------------------------------------------------------------------------------%
% Predicado principal
iniciar_especialista. :-
    write('Pense em um Pal e eu tentarei adivinhar quem é.'), nl,
    write('O Pal é montável? (sim/nao/nao_sei): '),
    read(RespMontaria),
    findall(Nome, pal(_, Nome, _, _, _, _), ListaPals),
    filtrar_montaria(ListaPals, RespMontaria, PalsFiltrados),
    tipos_possiveis(ListaTipos),
    trabalhos_possiveis(ListaTrabalhos),
    intercalar(ListaTipos, ListaTrabalhos, ListaPerguntas),
    perguntar_caracteristicas(ListaPerguntas, PalsFiltrados, [], [], ResultadoFinal),
    exibir_resultado(ResultadoFinal),
    limpar_variaveis.

%-------------------------------------------------------------------------------------------------------------------------------%
% Auxiliares
intercalar([], [], []).
intercalar([H1|T1], [], [tipo-H1|Resto]) :- intercalar(T1, [], Resto).
intercalar([], [H2|T2], [trabalho-H2|Resto]) :- intercalar([], T2, Resto).
intercalar([H1|T1], [H2|T2], [tipo-H1, trabalho-H2|Resto]) :- intercalar(T1, T2, Resto).

perguntar_caracteristicas([], Pals, _, _, Pals).
perguntar_caracteristicas(_, [Unico], _, _, [Unico]) :-
    write('Você está pensando em: '), write(Unico), nl,
    write('Fim do jogo!'), nl.

perguntar_caracteristicas([tipo-Tipo|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal) :-
    length(TiposConfirmados, N),
    ( N >= 2 ->
        perguntar_caracteristicas(Resto, Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal)
    ;
        format('O Pal possui o tipo ~w? (sim/nao/nao_sei): ', [Tipo]),
        read(Resposta),
        (Resposta == sim ->
            incluir_tipo(Pals, Tipo, PalsFiltrados),
            append(TiposConfirmados, [Tipo], NovosTipos)
        ; Resposta == nao ->
            excluir_tipo(Pals, Tipo, PalsFiltrados),
            NovosTipos = TiposConfirmados
        ;
            PalsFiltrados = Pals,
            NovosTipos = TiposConfirmados
        ),
        perguntar_caracteristicas(Resto, PalsFiltrados, NovosTipos, TrabalhosConfirmados, ResultadoFinal)
    ).

perguntar_caracteristicas([trabalho-Trabalho|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal) :-
    format('O Pal possui a habilidade de trabalho ~w? (sim/nao/nao_sei): ', [Trabalho]),
    read(Resposta),
    (Resposta == sim ->
        incluir_trabalho(Pals, Trabalho, PalsFiltrados),
        append(TrabalhosConfirmados, [Trabalho], NovosTrabalhos)
    ; Resposta == nao ->
        excluir_trabalho(Pals, Trabalho, PalsFiltrados),
        NovosTrabalhos = TrabalhosConfirmados
    ;
        PalsFiltrados = Pals,
        NovosTrabalhos = TrabalhosConfirmados
    ),
    perguntar_caracteristicas(Resto, PalsFiltrados, TiposConfirmados, NovosTrabalhos, ResultadoFinal).

%-------------------------------------------------------------------------------------------------------------------------------%
% Funções auxiliares de filtragem
filtrar_montaria(Pals, nao_sei, Pals).
filtrar_montaria(Pals, RespMontaria, PalsFiltrados) :-
    include({RespMontaria}/[Nome]>>pal(_, Nome, _, _, RespMontaria, _), Pals, PalsFiltrados).

tem_montaria(Resp, Nome) :-
    pal(_, Nome, _, _, Resp, _).

incluir_tipo(Pals, Tipo, PalsFiltrados) :-
    include(tem_tipo(Tipo), Pals, PalsFiltrados).

tem_tipo(Tipo, Nome) :-
    pal(_, Nome, Tipos, _, _, _),
    member(Tipo, Tipos).

incluir_trabalho(Pals, Trabalho, PalsFiltrados) :-
    include(tem_trabalho(Trabalho), Pals, PalsFiltrados).

tem_trabalho(Trabalho, Nome) :-
    pal(_, Nome, _, Trabalhos, _, _),
    member(Trabalho, Trabalhos).

excluir_tipo(Pals, Tipo, PalsFiltrados) :-
    exclude(tem_tipo(Tipo), Pals, PalsFiltrados).

excluir_trabalho(Pals, Trabalho, PalsFiltrados) :-
    exclude(tem_trabalho(Trabalho), Pals, PalsFiltrados).

%-------------------------------------------------------------------------------------------------------------------------------%
% Resultado final
exibir_resultado([]) :-
    write('Não consegui encontrar um Pal com essas características.'), nl,
    write('Fim do jogo!'), nl.
exibir_resultado([Unico]) :-
    write('Você está pensando em: '), write(Unico), nl,
    write('Fim do jogo!'), nl.
exibir_resultado(Pals) :-
    sort(Pals, PalsOrdenados),
    write('Os Pals que correspondem às características são: '), nl,
    listar_pals(PalsOrdenados),
    write('Fim do jogo!'), nl.

listar_pals([]).
listar_pals([H|T]) :-
    write('- '), write(H), nl,
    listar_pals(T).

%-------------------------------------------------------------------------------------------------------------------------------%
% Limpeza
limpar_variaveis :-
    (nb_current(tipos_confirmados, _) -> nb_delete(tipos_confirmados) ; true),
    (nb_current(trabalhos_confirmados, _) -> nb_delete(trabalhos_confirmados) ; true),
    (nb_current(pals_filtrados, _) -> nb_delete(pals_filtrados) ; true).