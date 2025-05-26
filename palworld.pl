% Base de conhecimento dos Pals
pal(lamball) :-
    verificar(tipo_neutro),
    verificar(trabalho_manual),
    verificar(transporte),
    verificar(agricultura),
    verificar(passiva_fluffy_shield),
    verificar(nao_montavel).

pal(cattiva) :-
    verificar(tipo_neutro),
    verificar(trabalho_manual),
    verificar(transporte),
    verificar(coleta),
    verificar(mineracao),
    verificar(passiva_cat_helper),
    verificar(nao_montavel).

pal(chikipi) :-
    verificar(tipo_neutro),
    verificar(coleta),
    verificar(agricultura),
    verificar(passiva_egg_layer),
    verificar(nao_montavel).

pal(lifmunk) :-
    verificar(tipo_grama),
    verificar(plantio),
    verificar(trabalho_manual),
    verificar(corte),
    verificar(producao_medicinal),
    verificar(coleta),
    verificar(passiva_lifmunk_recoil),
    verificar(nao_montavel).

pal(foxparks) :-
    verificar(tipo_fogo),
    verificar(acendimento),
    verificar(passiva_foxparks_partner),
    verificar(nao_montavel).

pal(rushoar) :-
    verificar(tipo_terra),
    verificar(mineracao),
    verificar(passiva_hard_head),
    verificar(montavel).

pal(direhowl) :-
    verificar(tipo_neutro),
    verificar(transporte),
    verificar(passiva_direhowl_rider),
    verificar(montavel).

pal(mossanda) :-
    verificar(tipo_grama),
    verificar(corte),
    verificar(transporte),
    verificar(passiva_grenadier_panda),
    verificar(montavel).

pal(galeclaw) :-
    verificar(tipo_vento),
    verificar(transporte),
    verificar(passiva_galeclaw_rider),
    verificar(montavel).

pal(kitsun) :-
    verificar(tipo_fogo),
    verificar(acendimento),
    verificar(passiva_clear_mind),
    verificar(montavel).

pal(surfent) :-
    verificar(tipo_agua),
    verificar(transporte),
    verificar(passiva_swift_swimmer),
    verificar(montavel).

pal(mammorest) :-
    verificar(tipo_terra),
    verificar(corte),
    verificar(mineracao),
    verificar(passiva_gaia_crusher),
    verificar(montavel).

pal(grizzbolt) :-
    verificar(tipo_eletrico),
    verificar(geracao_eletricidade),
    verificar(trabalho_manual),
    verificar(transporte),
    verificar(corte),
    verificar(passiva_yellow_tank),
    verificar(montavel).

pal(jetragon) :-
    verificar(tipo_dragao),
    verificar(coleta),
    verificar(passiva_aerial_missile),
    verificar(montavel).

% Regras principais
iniciar :-
    pal(Pal),
    write('Eu acho que o Pal é: '), write(Pal), nl,
    undo.

iniciar :-
    write('Não consegui identificar o Pal com base nas respostas.'), nl,
    undo.

% Sistema de perguntas
:- dynamic yes/1, no/1.

verificar(Fato) :-
    yes(Fato), !.

verificar(Fato) :-
    no(Fato), !, fail.

verificar(Fato) :-
    perguntar(Fato).

perguntar(Fato) :-
    traduzir(Fato, Pergunta),
    format('O Pal possui: ~w (s/n)? ', [Pergunta]),
    read(Resposta),
    nl,
    (Resposta == s ; Resposta == sim ->
        assertz(yes(Fato));
        assertz(no(Fato)), fail).

undo :- retract(yes(_)), fail.
undo :- retract(no(_)), fail.
undo.

% Traduções para perguntas mais legíveis
traduzir(tipo_fogo, 'tipo Fogo').
traduzir(tipo_agua, 'tipo Água').
traduzir(tipo_grama, 'tipo Grama').
traduzir(tipo_terra, 'tipo Terra').
traduzir(tipo_vento, 'tipo Vento').
traduzir(tipo_eletrico, 'tipo Elétrico').
traduzir(tipo_dragao, 'tipo Dragão').
traduzir(tipo_neutro, 'tipo Neutro').

traduzir(trabalho_manual, 'habilidade Trabalho Manual').
traduzir(transporte, 'habilidade Transporte').
traduzir(agricultura, 'habilidade Agricultura').
traduzir(coleta, 'habilidade Coleta').
traduzir(mineracao, 'habilidade Mineração').
traduzir(plantio, 'habilidade Plantio').
traduzir(corte, 'habilidade Corte').
traduzir(producao_medicinal, 'habilidade Produção Medicinal').
traduzir(acendimento, 'habilidade Acendimento').
traduzir(geracao_eletricidade, 'habilidade Geração de Eletricidade').

traduzir(passiva_fluffy_shield, 'passiva Fluffy Shield').
traduzir(passiva_cat_helper, 'passiva Cat Helper').
traduzir(passiva_egg_layer, 'passiva Egg Layer').
traduzir(passiva_lifmunk_recoil, 'passiva Lifmunk Recoil').
traduzir(passiva_foxparks_partner, 'passiva Foxparks Partner').
traduzir(passiva_hard_head, 'passiva Hard Head').
traduzir(passiva_direhowl_rider, 'passiva Direhowl Rider').
traduzir(passiva_grenadier_panda, 'passiva Grenadier Panda').
traduzir(passiva_galeclaw_rider, 'passiva Galeclaw Rider').
traduzir(passiva_clear_mind, 'passiva Clear Mind').
traduzir(passiva_swift_swimmer, 'passiva Swift Swimmer').
traduzir(passiva_gaia_crusher, 'passiva Gaia Crusher').
traduzir(passiva_yellow_tank, 'passiva Yellow Tank').
traduzir(passiva_aerial_missile, 'passiva Aerial Missile').

traduzir(montavel, 'montaria SIM').
traduzir(nao_montavel, 'montaria NÃO').