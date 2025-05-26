% BASE DE DADOS
% pal(Número, Nome, [Tipos], Habilidade, [Trabalhos], Drop, VidaBase, AtaqueBase, DefesaBase).
:- [base_palworld].

%-------------------------------------------------------------------------------------------------------------------------------%
% Tipos disponíveis
tipos_possiveis(ListaTipos) :-
    findall(Tipo, (pal(_, _, Tipos, _, _, _, _, _, _), member(Tipo, Tipos)), TiposRepetidos),
    sort(TiposRepetidos, ListaTipos).

% Trabalhos disponíveis
trabalhos_possiveis(ListaTrabalhos) :-
    findall(Trabalho, (pal(_, _, _, _, Trabalhos, _, _, _, _), member(Trabalho, Trabalhos)), TrabalhosRepetidos),
    sort(TrabalhosRepetidos, ListaTrabalhos).

%-------------------------------------------------------------------------------------------------------------------------------%
% Predicado principal
iniciar_especialista :-
    write('Pense em um Pal e eu tentarei adivinhar quem é.'), nl,
    tipos_possiveis(ListaTipos),
    trabalhos_possiveis(ListaTrabalhos),
    findall(Nome, pal(_, Nome, _, _, _, _, _, _, _), ListaPals),
    intercalar(ListaTipos, ListaTrabalhos, ListaPerguntas),
    perguntar_caracteristicas(ListaPerguntas, ListaPals, [], [], ResultadoFinal),
    limpar_variaveis.

%-------------------------------------------------------------------------------------------------------------------------------%
% Auxiliares
intercalar([], [], [vida, ataque, defesa]).
intercalar([H1|T1], [], [tipo-H1|Resto]) :-
    intercalar(T1, [], Resto).
intercalar([], [H2|T2], [trabalho-H2|Resto]) :-
    intercalar([], T2, Resto).
intercalar([H1|T1], [H2|T2], [tipo-H1, trabalho-H2|Resto]) :-
    intercalar(T1, T2, Resto).

perguntar_caracteristicas(_, [Unico], _, _, [Unico]) :-

perguntar_caracteristicas([], [], _, _, []) :-

perguntar_caracteristicas([], [Unico], _, _, [Unico]) :-

perguntar_caracteristicas([], Pals, _TiposConfirmados, _TrabalhosConfirmados, ResultadoFinal) :-
    Pals \= [],
    tentar_adivinhar(Pals, ResultadoFinal).

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

perguntar_caracteristicas([vida|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal) :-
    write('O Pal possui vida base maior ou igual a 100? (sim/nao/nao_sei): '),
    read(Resposta),
    (Resposta == sim ->
        incluir_vida(Pals, PalsFiltrados)
    ; Resposta == nao ->
        excluir_vida(Pals, PalsFiltrados)
    ;
        PalsFiltrados = Pals
    ),
    perguntar_caracteristicas(Resto, PalsFiltrados, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal).

perguntar_caracteristicas([ataque|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal) :-
    write('O Pal possui ataque base maior ou igual a 100? (sim/nao/nao_sei): '),
    read(Resposta),
    (Resposta == sim ->
        incluir_ataque(Pals, PalsFiltrados)
    ; Resposta == nao ->
        excluir_ataque(Pals, PalsFiltrados)
    ;
        PalsFiltrados = Pals
    ),
    perguntar_caracteristicas(Resto, PalsFiltrados, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal).

perguntar_caracteristicas([defesa|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal) :-
    write('O Pal possui defesa base maior ou igual a 100? (sim/nao/nao_sei): '),
    read(Resposta),
    (Resposta == sim ->
        incluir_defesa(Pals, PalsFiltrados)
    ; Resposta == nao ->
        excluir_defesa(Pals, PalsFiltrados)
    ;
        PalsFiltrados = Pals
    ),
    perguntar_caracteristicas(Resto, PalsFiltrados, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal).

%-------------------------------------------------------------------------------------------------------------------------------%
% Funções auxiliares de filtragem
incluir_tipo(Pals, Tipo, PalsFiltrados) :-
    include(tem_tipo(Tipo), Pals, PalsFiltrados).

tem_tipo(Tipo, Nome) :-
    pal(_, Nome, Tipos, _, _, _, _, _, _),
    member(Tipo, Tipos).

excluir_tipo(Pals, Tipo, PalsFiltrados) :-
    exclude(tem_tipo(Tipo), Pals, PalsFiltrados).

incluir_trabalho(Pals, Trabalho, PalsFiltrados) :-
    include(tem_trabalho(Trabalho), Pals, PalsFiltrados).

tem_trabalho(Trabalho, Nome) :-
    pal(_, Nome, _, _, Trabalhos, _, _, _, _),
    member(Trabalho, Trabalhos).

excluir_trabalho(Pals, Trabalho, PalsFiltrados) :-
    exclude(tem_trabalho(Trabalho), Pals, PalsFiltrados).

% Vida Base
incluir_vida(Pals, PalsFiltrados) :-
    include(tem_vida_maior_igual_100, Pals, PalsFiltrados).

excluir_vida(Pals, PalsFiltrados) :-
    exclude(tem_vida_maior_igual_100, Pals, PalsFiltrados).

tem_vida_maior_igual_100(Nome) :-
    pal(_, Nome, _, _, _, _, VidaBase, _, _),
    VidaBase >= 100.

% Ataque Base
incluir_ataque(Pals, PalsFiltrados) :-
    include(tem_ataque_maior_igual_100, Pals, PalsFiltrados).

excluir_ataque(Pals, PalsFiltrados) :-
    exclude(tem_ataque_maior_igual_100, Pals, PalsFiltrados).

tem_ataque_maior_igual_100(Nome) :-
    pal(_, Nome, _, _, _, _, _, AtaqueBase, _),
    AtaqueBase >= 100.

% Defesa Base
incluir_defesa(Pals, PalsFiltrados) :-
    include(tem_defesa_maior_igual_100, Pals, PalsFiltrados).

excluir_defesa(Pals, PalsFiltrados) :-
    exclude(tem_defesa_maior_igual_100, Pals, PalsFiltrados).

tem_defesa_maior_igual_100(Nome) :-
    pal(_, Nome, _, _, _, _, _, _, DefesaBase),
    DefesaBase >= 100.

%-------------------------------------------------------------------------------------------------------------------------------%
listar_pals([]).
listar_pals([H|T]) :-
    write('- '), write(H), nl,
    listar_pals(T).

tentar_adivinhar([], []) :-
    write('Não consegui encontrar um Pal com essas características.'), nl,
    write('Fim do jogo!'), nl.

tentar_adivinhar([Pal], [Pal]) :-
    write('Você está pensando em: '), write(Pal), nl,
    write('Fim do jogo!'), nl.

tentar_adivinhar([Pal|Resto], ResultadoFinal) :-
    format('Você está pensando em ~w? (sim/nao): ', [Pal]),
    read(Resposta),
    (Resposta == sim ->
        ResultadoFinal = [Pal],
        write('Acertei! Fim do jogo!'), nl
    ; Resposta == nao ->
        tentar_adivinhar(Resto, ResultadoFinal)
    ;
        write('Resposta inválida. Por favor, responda com sim ou nao.'), nl,
        tentar_adivinhar([Pal|Resto], ResultadoFinal)
    ).

%-------------------------------------------------------------------------------------------------------------------------------%
% Limpeza
limpar_variaveis :-
    (nb_current(tipos_confirmados, _) -> nb_delete(tipos_confirmados) ; true),
    (nb_current(trabalhos_confirmados, _) -> nb_delete(trabalhos_confirmados) ; true),
    (nb_current(pals_filtrados, _) -> nb_delete(pals_filtrados) ; true).