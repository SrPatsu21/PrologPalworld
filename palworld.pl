% DATABASE
% pal(Número, Nome, Tipos, Trabalhos, Montaria, Passivas).
pal(1, lamball, [neutro], [trabalho_manual, transporte, agricultura], nao, [fluffy_shield]).
pal(2, cattiva, [neutro], [trabalho_manual, transporte, coleta, mineracao], nao, [cat_helper]).
pal(3, chikipi, [neutro], [coleta, agricultura], nao, [egg_layer]).
pal(4, lifmunk, [grama], [plantio, trabalho_manual, corte, producao_medicinal, coleta], nao, [lifmunk_recoil]).
pal(5, foxparks, [fogo], [acendimento], nao, [foxparks_partner]).
pal(20, rushoar, [terra], [mineracao], sim, [hard_head]).
pal(26, direhowl, [neutro], [transporte], sim, [direhowl_rider]).
pal(33, mossanda, [grama], [corte, transporte], sim, [grenadier_panda]).
pal(47, galeclaw, [vento], [transporte], sim, [galeclaw_rider]).
pal(61, kitsun, [fogo], [acendimento], sim, [clear_mind]).
pal(65, surfent, [agua], [transporte], sim, [swift_swimmer]).
pal(90, mammorest, [terra], [corte, mineracao], sim, [gaia_crusher]).
pal(103, grizzbolt, [eletrico], [geracao_eletricidade, trabalho_manual, transporte, corte], sim, [yellow_tank]).
pal(110, jetragon, [dragao], [coleta], sim, [aerial_missile]).


%-------------------------------------------------------------------------------------------------------------------------------%
% Filtros
% Predicado para buscar por nome
% buscar_por_nome(+Nome, -Numero, -Tipo, -Trabalhos, -Montaria, -Passivas)
buscar_por_nome(Nome, Numero, Tipo, Trabalhos, Montaria, Passivas) :-
    pal(Numero, Nome, Tipo, Trabalhos, Montaria, Passivas).

% Predicado para buscar por tipo
% buscar_por_tipo(+Tipo, -ListaNomes)
buscar_por_tipo(Tipo, ListaNomes) :-
    findall(Nome, (pal(_, Nome, Tipos, _, _, _), member(Tipo, Tipos)), ListaNomes).

% Predicado para buscar por multiplos tipos
% buscar_por_tipos(+ListaTipos, -ListaNomes)
buscar_por_tipos(ListaTipos, ListaNomes) :-
    findall(Nome, (pal(_, Nome, Tipos, _, _, _), subset(ListaTipos, Tipos)), ListaNomes).

% Predicado para buscar por uma habilidade de trabalho específica
% buscar_por_trabalho(+Trabalho, -ListaNomes)
buscar_por_trabalho(Trabalho, ListaNomes) :-
    findall(Nome, (pal(_, Nome, _, Trabalhos, _, _), member(Trabalho, Trabalhos)), ListaNomes).

% Predicado para buscar por multiplas habilidades
% buscar_por_trabalhos(+ListaTrabalhos, -ListaNomes)
buscar_por_trabalhos(ListaTrabalhos, ListaNomes) :-
    findall(Nome, (pal(_, Nome, _, Trabalhos, _, _), subset(ListaTrabalhos, Trabalhos)), ListaNomes).

% Predicado para buscar Pals montáveis
% buscar_por_montaria(-ListaNomes)
buscar_por_montaria(ListaNomes) :-
    findall(Nome, pal(_, Nome, _, _, sim, _), ListaNomes).

% Predicado para buscar por número
% buscar_por_numero(+Numero, -Nome, -Tipo, -Trabalhos, -Montaria, -Passivas)
buscar_por_numero(Numero, Nome, Tipo, Trabalhos, Montaria, Passivas) :-
    pal(Numero, Nome, Tipo, Trabalhos, Montaria, Passivas).

%-------------------------------------------------------------------------------------------------------------------------------%
% Lista de todos os tipos possíveis
tipos_possiveis([fogo, agua, planta, eletrico, gelo, terra, ar, metal, sombrio, psiquico]).

% Lista de todas as habilidades de trabalho possíveis
trabalhos_possiveis([acendimento, mineracao, corte, plantio, coleta, transporte, resfriamento, aquecimento, iluminacao, defesa]).

% Predicado principal do Akinator
akinator :-
    write('Pense em um Pal e eu tentarei adivinhar quem é.'), nl,
    write('O Pal é montável? (sim/nao/nao_sei): '),
    read(RespMontaria),
    findall(Nome, pal(_, Nome, _, _, _, _), ListaPals),
    filtrar_montaria(ListaPals, RespMontaria, PalsFiltrados),
    tipos_possiveis(ListaTipos),
    trabalhos_possiveis(ListaTrabalhos),
    intercalar(ListaTipos, ListaTrabalhos, ListaPerguntas),
    perguntar_caracteristicas(ListaPerguntas, PalsFiltrados, [], [], ResultadoFinal),
    exibir_resultado(ResultadoFinal).
    limpar_variaveis.

% Intercala duas listas
intercalar([], [], []).
intercalar([H1|T1], [], [tipo-H1|Resto]) :-
    intercalar(T1, [], Resto).
intercalar([], [H2|T2], [trabalho-H2|Resto]) :-
    intercalar([], T2, Resto).
intercalar([H1|T1], [H2|T2], [tipo-H1, trabalho-H2|Resto]) :-
    intercalar(T1, T2, Resto).

% Pergunta sobre características e filtra os Pals
perguntar_caracteristicas([], Pals, _, _, Pals).
perguntar_caracteristicas(_, [Unico], _, _, [Unico]) :-
    write('Você está pensando em: '), write(Unico), nl,
    write('Fim do jogo!'), nl.
perguntar_caracteristicas([tipo-Tipo|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal) :-
    length(TiposConfirmados, N),
    N >= 2,
    perguntar_caracteristicas(Resto, Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal).
perguntar_caracteristicas([tipo-Tipo|Resto], Pals, TiposConfirmados, TrabalhosConfirmados, ResultadoFinal) :-
    length(TiposConfirmados, N),
    N < 2,
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
    perguntar_caracteristicas(Resto, PalsFiltrados, NovosTipos, TrabalhosConfirmados, ResultadoFinal).
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

% Filtra Pals por montaria
filtrar_montaria(Pals, nao_sei, Pals).
filtrar_montaria(Pals, RespMontaria, PalsFiltrados) :-
    include({RespMontaria}/[Nome]>>pal(_, Nome, _, _, RespMontaria, _), Pals, PalsFiltrados).

tem_montaria(Resp, Nome) :-
    pal(_, Nome, _, _, Resp, _).

% Inclui Pals que possuem o tipo especificado
incluir_tipo(Pals, Tipo, PalsFiltrados) :-
    include(tem_tipo(Tipo), Pals, PalsFiltrados).

tem_tipo(Tipo, Nome) :-
    pal(_, Nome, Tipos, _, _, _),
    member(Tipo, Tipos).

% Inclui Pals que possuem a habilidade de trabalho especificada
incluir_trabalho(Pals, Trabalho, PalsFiltrados) :-
    include(tem_trabalho(Trabalho), Pals, PalsFiltrados).

tem_trabalho(Trabalho, Nome) :-
    pal(_, Nome, _, Trabalhos, _, _),
    member(Trabalho, Trabalhos).

% Remove Pals que possuem o tipo especificado
excluir_tipo(Pals, Tipo, PalsFiltrados) :-
    exclude(tem_tipo(Tipo), Pals, PalsFiltrados).

% Remove Pals que possuem a habilidade de trabalho especificada
excluir_trabalho(Pals, Trabalho, PalsFiltrados) :-
    exclude(tem_trabalho(Trabalho), Pals, PalsFiltrados).

% Exibe o resultado final
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

% Lista os Pals encontrados
listar_pals([]).
listar_pals([H|T]) :-
    write('- '), write(H), nl,
    listar_pals(T).

limpar_variaveis :-
    nb_delete(tipos_confirmados),
    nb_delete(trabalhos_confirmados),
    nb_delete(pals_filtrados).