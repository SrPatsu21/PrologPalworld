% BASE DE DADOS
% pal(Número, Nome, [Tipos], Habilidade, [Trabalhos], [Drop], VidaBase, AtaqueBase, DefesaBase, Montaria).
:- [base_palworld].

%-------------------------------------------------------------------------------------------------------------------------------%
% Tipos disponíveis

tipos_possiveis(ListaTipos) :-
    findall(Tipo, (pal(_, _, Tipos, _, _, _, _, _, _, _), member(Tipo, Tipos)), TiposRepetidos),
    sort(TiposRepetidos, ListaTipos).

% Trabalhos disponíveis
trabalhos_possiveis(ListaTrabalhos) :-
    findall(Trabalho, (pal(_, _, _, _, Trabalhos, _, _, _, _, _), member(Trabalho, Trabalhos)), TrabalhosRepetidos),
    sort(TrabalhosRepetidos, ListaTrabalhos).

% Extrai todos os tipos possíveis da lista de Pals restantes
tipos_possiveis(Pals, TiposUnicos) :-
    findall(Tipo, (member(Nome, Pals), pal(_, Nome, Tipos, _, _, _, _, _, _, _), member(Tipo, Tipos)), TodosTipos),
    sort(TodosTipos, TiposUnicos).

% Extrai todos os trabalhos possíveis da lista de Pals restantes
trabalhos_possiveis(Pals, TrabalhosUnicos) :-
    findall(Trabalho, (member(Nome, Pals), pal(_, Nome, _, _, Trabalhos, _, _, _, _, _), member(Trabalho, Trabalhos)), TodosTrabalhos),
    sort(TodosTrabalhos, TrabalhosUnicos).

%-------------------------------------------------------------------------------------------------------------------------------%
% Predicado principal
iniciar_especialista :-
    write('Pense em um Pal e eu tentarei adivinhar quem é.'), nl,
    tipos_possiveis(ListaTipos),
    trabalhos_possiveis(ListaTrabalhos),
    findall(Nome, pal(_, Nome, _, _, _, _, _, _, _, _), ListaPals),
    intercalar(ListaTipos, ListaTrabalhos, PerguntasBase),
    ListaPerguntas = [montaria | PerguntasBase],
    perguntar_caracteristicas(ListaPerguntas, ListaPals, [], [], _ResultadoFinal),
    limpar_variaveis.

%-------------------------------------------------------------------------------------------------------------------------------%
% Auxiliares

%Intercala perguntas
intercalar([], [], [vida, ataque, defesa]).
intercalar([H1|T1], [], [tipo-H1|Resto]) :-
    intercalar(T1, [], Resto).
intercalar([], [H2|T2], [trabalho-H2|Resto]) :-
    intercalar([], T2, Resto).
intercalar([H1|T1], [H2|T2], [tipo-H1, trabalho-H2|Resto]) :-
    intercalar(T1, T2, Resto).

% Nenhum Pal restante
perguntar_caracteristicas([], [], _, _, []) :-
    tentar_adivinhar([], []).

% Pergunta restantes, com apenas 1 possibilidade
perguntar_caracteristicas(_, [Pal], _, _, [ResultadoFinal]) :-
    tentar_adivinhar([Pal], [ResultadoFinal]).

% Nenhuma pergunta restante, com 1 ou mais Pals
perguntar_caracteristicas([], Pals, _, _, ResultadoFinal) :-
    Pals \= [],
    tentar_adivinhar(Pals, ResultadoFinal).

% Pergunta sobre montaria
perguntar_caracteristicas([montaria|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal) :-
    write('O Pal é uma montaria? (sim/nao/nao_sei): '),
    read(Resposta),
    (Resposta == sim ; Resposta == nao ; Resposta == nao_sei),
    incluir_montaria(Pals, Resposta, PalsFiltrados),
    perguntar_caracteristicas(Resto, PalsFiltrados, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal).

% Continua perguntando sobre tipos
perguntar_caracteristicas([tipo-Tipo|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal) :-
    length(TiposConfirmados, N),
    ( N >= 2 ->
        perguntar_caracteristicas(Resto, Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal)
    ;
        tipos_possiveis(Pals, TiposPossiveis),
        ( \+ member(Tipo, TiposPossiveis) ->
            % Tipo não mais relevante, pula para próxima pergunta
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
        )
    ).

% Continua perguntando sobre trabalhos
perguntar_caracteristicas([trabalho-Trabalho|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal) :-
    trabalhos_possiveis(Pals, TrabalhosPossiveis),
    ( \+ member(Trabalho, TrabalhosPossiveis) ->
        % Trabalho não mais relevante, pula para próxima pergunta
        perguntar_caracteristicas(Resto, Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal)
    ;
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
        perguntar_caracteristicas(Resto, PalsFiltrados, TiposConfirmados, NovosTrabalhos, ResultadoFinal)
    ).

% Continua perguntando sobre vida
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

% Continua perguntando sobre ataque
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

% Continua perguntando sobre defesa
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
    pal(_, Nome, Tipos, _, _, _, _, _, _, _),
    member(Tipo, Tipos).

excluir_tipo(Pals, Tipo, PalsFiltrados) :-
    exclude(tem_tipo(Tipo), Pals, PalsFiltrados).

incluir_trabalho(Pals, Trabalho, PalsFiltrados) :-
    include(tem_trabalho(Trabalho), Pals, PalsFiltrados).

tem_trabalho(Trabalho, Nome) :-
    pal(_, Nome, _, _, Trabalhos, _, _, _, _, _),
    member(Trabalho, Trabalhos).

excluir_trabalho(Pals, Trabalho, PalsFiltrados) :-
    exclude(tem_trabalho(Trabalho), Pals, PalsFiltrados).

% Vida Base
incluir_vida(Pals, PalsFiltrados) :-
    include(tem_vida_maior_igual_100, Pals, PalsFiltrados).

excluir_vida(Pals, PalsFiltrados) :-
    exclude(tem_vida_maior_igual_100, Pals, PalsFiltrados).

tem_vida_maior_igual_100(Nome) :-
    pal(_, Nome, _, _, _, _, VidaBase, _, _, _),
    VidaBase >= 100.

% Ataque Base
incluir_ataque(Pals, PalsFiltrados) :-
    include(tem_ataque_maior_igual_100, Pals, PalsFiltrados).

excluir_ataque(Pals, PalsFiltrados) :-
    exclude(tem_ataque_maior_igual_100, Pals, PalsFiltrados).

tem_ataque_maior_igual_100(Nome) :-
    pal(_, Nome, _, _, _, _, _, AtaqueBase, _, _),
    AtaqueBase >= 100.

% Defesa Base
incluir_defesa(Pals, PalsFiltrados) :-
    include(tem_defesa_maior_igual_100, Pals, PalsFiltrados).

excluir_defesa(Pals, PalsFiltrados) :-
    exclude(tem_defesa_maior_igual_100, Pals, PalsFiltrados).

tem_defesa_maior_igual_100(Nome) :-
    pal(_, Nome, _, _, _, _, _, _, DefesaBase, _),
    DefesaBase >= 100.

incluir_montaria(Pals, sim, PalsFiltrados) :-
    include(tem_montaria, Pals, PalsFiltrados).

incluir_montaria(Pals, nao, PalsFiltrados) :-
    exclude(tem_montaria, Pals, PalsFiltrados).

% mantem a lista igual
incluir_montaria(Pals, nao_sei, Pals).

tem_montaria(Nome) :-
    pal(_, Nome, _, _, _, _, _, _, _, sim).

%-------------------------------------------------------------------------------------------------------------------------------%
% Resultados

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
% Limpar dados

limpar_variaveis :-
    (nb_current(tipos_confirmados, _) -> nb_delete(tipos_confirmados) ; true),
    (nb_current(trabalhos_confirmados, _) -> nb_delete(trabalhos_confirmados) ; true),
    (nb_current(pals_filtrados, _) -> nb_delete(pals_filtrados) ; true).