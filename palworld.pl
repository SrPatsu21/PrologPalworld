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


% Lista de todos os tipos possíveis
tipos_possiveis([fogo, agua, planta, eletrico, gelo, terra, ar, metal, sombrio, psiquico]).

% Lista de todas as habilidades de trabalho possíveis
trabalhos_possiveis([acendimento, mineracao, corte, plantio, coleta, transporte, resfriamento, aquecimento, iluminacao, defesa]).

% Predicado principal do Akinator
akinator :-
    write('Pense em um Pal e eu tentarei adivinhar quem é.'), nl,
    tipos_possiveis(ListaTipos),
    perguntar_caracteristicas('tipo', ListaTipos, 2, TiposConfirmados),
    trabalhos_possiveis(ListaTrabalhos),
    perguntar_caracteristicas('habilidade de trabalho', ListaTrabalhos, _, TrabalhosConfirmados),
    write('O Pal é montável? (sim/nao/nao_sei): '),
    read(RespMontaria),
    filtrar_pals(TiposConfirmados, TrabalhosConfirmados, RespMontaria, PalsFiltrados),
    exibir_resultado(PalsFiltrados).

% Predicado para perguntar sobre características com limite opcional
perguntar_caracteristicas(_, [], _, []).

perguntar_caracteristicas(TipoCaracteristica, [Caracteristica|Resto], Limite, Confirmados) :-
    (nonvar(Limite), Limite =< 0 ->
        Confirmados = []
    ;
        format('O Pal possui a ~w ~w? (sim/nao/nao_sei): ', [TipoCaracteristica, Caracteristica]),
        read(Resposta),
        (Resposta == sim ->
            (nonvar(Limite) ->
                NovoLimite is Limite - 1
            ;
                NovoLimite = Limite
            ),
            Confirmados = [Caracteristica|ConfirmadosResto]
        ;
            NovoLimite = Limite,
            Confirmados = ConfirmadosResto
        ),
        perguntar_caracteristicas(TipoCaracteristica, Resto, NovoLimite, ConfirmadosResto)
    ).

% Filtra os Pals com base nas características confirmadas
filtrar_pals(TiposConfirmados, TrabalhosConfirmados, RespMontaria, PalsFiltrados) :-
    findall(Nome, (
        pal(_, Nome, Tipos, Trabalhos, Montaria, _),
        inclui_todos(TiposConfirmados, Tipos),
        inclui_todos(TrabalhosConfirmados, Trabalhos),
        (RespMontaria == nao_sei ; Montaria == RespMontaria)
    ), PalsFiltrados).

% Verifica se todos os elementos de Sublista estão em Lista
inclui_todos([], _).
inclui_todos([H|T], Lista) :-
    member(H, Lista),
    inclui_todos(T, Lista).

% Exibe o resultado final
exibir_resultado([]) :-
    write('Não consegui encontrar um Pal com essas características.'), nl,
    write('Fim do jogo!'), nl.

exibir_resultado([Unico]) :-
    write('Você está pensando em: '), write(Unico), nl,
    write('Fim do jogo!'), nl.

exibir_resultado(Pals) :-
    write('Os Pals que correspondem às características são: '), nl,
    listar_pals(Pals),
    write('Fim do jogo!'), nl.

% Lista os Pals encontrados
listar_pals([]).
listar_pals([H|T]) :-
    write('- '), write(H), nl,
    listar_pals(T).