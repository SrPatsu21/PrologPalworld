% BASE DE DADOS
% pal(Número, Nome, [Tipos], Habilidade, [Trabalhos], [Drops], VidaBase, AtaqueBase, DefesaBase, Montaria).
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

% Drops disponíveis
drops_possiveis(ListaDrops) :-
    findall(Drop, (pal(_, _, _, _, _, Drops, _, _, _, _), member(Drop, Drops)), DropsRepetidos),
    sort(DropsRepetidos, ListaDrops).

tipos_possiveis(Pals, TiposConfirmados, TiposPossiveis) :-
    findall(Tipo,
        (member(Pal, Pals), pal(_, Pal, Tipos, _, _, _, _, _, _, _), member(Tipo, Tipos)),
        TodosTipos),
    list_to_set(TodosTipos, TiposUnicos),
    subtract(TiposUnicos, TiposConfirmados, TiposPossiveis).

trabalhos_possiveis(Pals, TrabalhosConfirmados, TrabalhosPossiveis) :-
    findall(Trabalho,
        (member(Pal, Pals), pal(_, Pal, _, _, Trabalhos, _, _, _, _, _), member(Trabalho, Trabalhos)),
        TodosTrabalhos),
    list_to_set(TodosTrabalhos, TrabalhosUnicos),
    subtract(TrabalhosUnicos, TrabalhosConfirmados, TrabalhosPossiveis).

drops_possiveis(Pals, DropsConfirmados, DropsPossiveis) :-
    findall(Drop,
        (member(Pal, Pals), pal(_, Pal, _, _, _, Drops, _, _, _, _), member(Drop, Drops)),
        TodosDrops),
    list_to_set(TodosDrops, DropsUnicos),
    subtract(DropsUnicos, DropsConfirmados, DropsPossiveis).

%-------------------------------------------------------------------------------------------------------------------------------%
% Predicado principal
iniciar_especialista :-
    write('Pense em um Pal e eu tentarei adivinhar quem é.'), nl,
    tipos_possiveis(ListaTipos),
    %write('Tipos possíveis: '), write(ListaTipos), nl,
    trabalhos_possiveis(ListaTrabalhos),
    %write('Trabalhos possíveis: '), write(ListaTrabalhos), nl,
    drops_possiveis(ListaDrops),
    %write('Drops possíveis: '), write(ListaDrops), nl,
    findall(Nome, pal(_, Nome, _, _, _, _, _, _, _, _), ListaPals),
    intercalar(ListaTipos, ListaTrabalhos, PerguntasTipoTrabalho),
    maplist({}/[D, drop-D]>>true, ListaDrops, PerguntasDrops),
    append([[montaria], PerguntasTipoTrabalho, PerguntasDrops, [vida, ataque, defesa]], Perguntas),
    /*
    format('Ordem das perguntas: ~w~n', [Perguntas]),
    */
    perguntar_caracteristicas(Perguntas, ListaPals, [], [], []),
    limpar_variaveis.

%-------------------------------------------------------------------------------------------------------------------------------%
% Auxiliares

%Intercala perguntas
intercalar([], [], []).
intercalar([H1|T1], [], [tipo-H1|Resto]) :-
    intercalar(T1, [], Resto).
intercalar([], [H2|T2], [trabalho-H2|Resto]) :-
    intercalar([], T2, Resto).
intercalar([H1|T1], [H2|T2], [tipo-H1, trabalho-H2|Resto]) :-
    intercalar(T1, T2, Resto).

% Nenhum Pal restante
perguntar_caracteristicas(_, [], _, _, _) :-
    tentar_adivinhar([], []).

% Pergunta restantes, com apenas 1 possibilidade
perguntar_caracteristicas(_, [Pal], _, _, _) :-
    tentar_adivinhar([Pal]).

% Nenhuma pergunta restante, com mais de 1 Pal
perguntar_caracteristicas([], Pals, _, _, _) :-
    Pals \= [],
    tentar_adivinhar(Pals).

% Continua perguntando sobre tipos
perguntar_caracteristicas([tipo-Tipo|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados) :-
    length(TiposConfirmados, N),
    ( N >= 2 ->
        perguntar_caracteristicas(Resto, Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados)
    ;
        tipos_possiveis(Pals, TiposConfirmados, TiposPossiveis),
        ( \+ member(Tipo, TiposPossiveis) ->
            perguntar_caracteristicas(Resto, Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados)
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
            perguntar_caracteristicas(Resto, PalsFiltrados, NovosTipos, TrabalhosConfirmados, DropsConfirmados)
        )
    ).

% Continua perguntando sobre trabalhos
perguntar_caracteristicas([trabalho-Trabalho|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados) :-
    trabalhos_possiveis(Pals, TrabalhosConfirmados, TrabalhosPossiveis),
    ( \+ member(Trabalho, TrabalhosPossiveis) ->
        perguntar_caracteristicas(Resto, Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados)
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
        perguntar_caracteristicas(Resto, PalsFiltrados, TiposConfirmados, NovosTrabalhos, DropsConfirmados)
    ).

% Pergunta sobre montaria
perguntar_caracteristicas([montaria|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados) :-
    write('O Pal é uma montaria? (sim/nao/nao_sei): '),
    read(Resposta),
    member(Resposta, [sim, nao, nao_sei]),
    (
        Resposta == sim ->
            incluir_montaria(Pals, PalsFiltrados)
        ; Resposta == nao ->
            excluir_montaria(Pals, PalsFiltrados)
        ; Resposta == nao_sei ->
            PalsFiltrados = Pals
    ),
    perguntar_caracteristicas(Resto, PalsFiltrados, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados).

perguntar_caracteristicas([drop-Drop | Resto], Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados) :-
    drops_possiveis(Pals, DropsConfirmados, DropsPossiveis),
    (
        DropsPossiveis == [] ->
            % Nenhum drop restante relevante, pula direto para os próximos
            perguntar_caracteristicas(Resto, Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados)
        ;
        member(Drop, DropsPossiveis) ->
            format('O Pal dropa ~w? (sim/nao/nao_sei): ', [Drop]),
            read(Resposta),
            member(Resposta, [sim, nao, nao_sei]),
            (
                Resposta == sim ->
                    incluir_drop(Pals, Drop, Filtrados),
                    NewDrops = [Drop | DropsConfirmados]
                ;
                Resposta == nao ->
                    excluir_drop(Pals, Drop, Filtrados),
                    NewDrops = DropsConfirmados
                ;
                Resposta == nao_sei ->
                    Filtrados = Pals,
                    NewDrops = DropsConfirmados
            ),
            perguntar_caracteristicas(Resto, Filtrados, TiposConfirmados, TrabalhosConfirmados, NewDrops)
        ;
            % Drop não está mais entre os possíveis drops → pular essa pergunta
            perguntar_caracteristicas(Resto, Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados)
    ).

% Continua perguntando sobre vida
perguntar_caracteristicas([vida|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados) :-
    write('O Pal possui vida base maior ou igual a 100? (sim/nao/nao_sei): '),
    read(Resposta),
    (Resposta == sim ->
        incluir_vida(Pals, PalsFiltrados)
    ; Resposta == nao ->
        excluir_vida(Pals, PalsFiltrados)
    ;
        PalsFiltrados = Pals
    ),
    perguntar_caracteristicas(Resto, PalsFiltrados, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados).

% Continua perguntando sobre ataque
perguntar_caracteristicas([ataque|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados) :-
    write('O Pal possui ataque base maior ou igual a 100? (sim/nao/nao_sei): '),
    read(Resposta),
    (Resposta == sim ->
        incluir_ataque(Pals, PalsFiltrados)
    ; Resposta == nao ->
        excluir_ataque(Pals, PalsFiltrados)
    ;
        PalsFiltrados = Pals
    ),
    perguntar_caracteristicas(Resto, PalsFiltrados, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados).

% Continua perguntando sobre defesa
perguntar_caracteristicas([defesa|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados) :-
    write('O Pal possui defesa base maior ou igual a 100? (sim/nao/nao_sei): '),
    read(Resposta),
    (Resposta == sim ->
        incluir_defesa(Pals, PalsFiltrados)
    ; Resposta == nao ->
        excluir_defesa(Pals, PalsFiltrados)
    ;
        PalsFiltrados = Pals
    ),
    perguntar_caracteristicas(Resto, PalsFiltrados, TiposConfirmados, TrabalhosConfirmados, DropsConfirmados).

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

incluir_montaria(Pals, PalsFiltrados) :-
    include(tem_montaria, Pals, PalsFiltrados).

% Pal com montaria
tem_montaria(Nome) :-
    pal(_, Nome, _, _, _, _, _, _, _, montaria).

excluir_montaria(Pals, PalsFiltrados) :-
    exclude(tem_montaria, Pals, PalsFiltrados).

incluir_drop(Pals, Drop, PalsFiltrados) :-
    include(tem_drop(Drop), Pals, PalsFiltrados).

tem_drop(Drop, Nome) :-
    pal(_, Nome, _, _, _, Drops, _, _, _, _),
    member(Drop, Drops).

excluir_drop(Pals, Drop, PalsFiltrados) :-
    exclude(tem_drop(Drop), Pals, PalsFiltrados).

%-------------------------------------------------------------------------------------------------------------------------------%
% Resultados

tentar_adivinhar([]) :-
    write('Não consegui encontrar um Pal com essas características.'), nl,
    write('Fim do jogo!'), nl.

tentar_adivinhar([Pal]) :-
    write('Você está pensando em: '), write(Pal), nl,
    write('Fim do jogo!'), nl.

tentar_adivinhar([Pal|Resto]) :-
    format('Você está pensando em ~w? (sim/nao): ', [Pal]),
    read(Resposta),
    (Resposta == sim ->
        write('Acertei! Fim do jogo!'), nl
    ; Resposta == nao ->
        tentar_adivinhar(Resto)
    ;
        write('Resposta inválida. Tente novamente.'), nl,
        tentar_adivinhar([Pal|Resto])
    ).

%-------------------------------------------------------------------------------------------------------------------------------%
% Limpar dados

limpar_variaveis :-
    (nb_current(tipos_confirmados, _) -> nb_delete(tipos_confirmados) ; true),
    (nb_current(trabalhos_confirmados, _) -> nb_delete(trabalhos_confirmados) ; true),
    (nb_current(pals_filtrados, _) -> nb_delete(pals_filtrados) ; true).

%-------------------------------------------------------------------------------------------------------------------------------%
% Pesquisas avancadas

% Buscar pelo nome
pal_por_nome(Nome) :-
    pal(Numero, Nome, Tipos, Habilidade, Trabalhos, Drops, Vida, Ataque, Defesa, Montaria),
    format("~n--- Dados de ~w ---~n", [Nome]),
    format("Número: ~w~nTipos: ~w~nHabilidade: ~w~nTrabalhos: ~w~nDrops: ~w~nVida: ~w~nAtaque: ~w~nDefesa: ~w~nMontaria: ~w~n",
        [Numero, Tipos, Habilidade, Trabalhos, Drops, Vida, Ataque, Defesa, Montaria]).

% Buscar pelo número
pal_por_numero(Numero) :-
    pal(Numero, Nome, Tipos, Habilidade, Trabalhos, Drops, Vida, Ataque, Defesa, Montaria),
    format("~n--- Dados do Pal número ~w ---~n", [Numero]),
    format("Nome: ~w~nTipos: ~w~nHabilidade: ~w~nTrabalhos: ~w~nDrops: ~w~nVida: ~w~nAtaque: ~w~nDefesa: ~w~nMontaria: ~w~n",
        [Nome, Tipos, Habilidade, Trabalhos, Drops, Vida, Ataque, Defesa, Montaria]).

% Buscar pelo trabalho
pals_com_trabalho(Trabalho) :-
    findall(Nome,
        (pal(_, Nome, _, _, Trabalhos, _, _, _, _, _), member(Trabalho, Trabalhos)),
        ListaNomes),
    format("~nPals com o trabalho ~w: ~w~n", [Trabalho, ListaNomes]).

% Buscar pelo drop
pals_com_drop(Drop) :-
    findall(Nome,
        (pal(_, Nome, _, _, _, Drops, _, _, _, _), member(Drop, Drops)),
        ListaNomes),
    format("~nPals que dropam ~w: ~w~n", [Drop, ListaNomes]).