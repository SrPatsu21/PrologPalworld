% pals.pl - Sistema especialista para identificação de Pals

:- dynamic yes/1, no/1.

/* Entrada principal */
iniciar :-
    hipotese(Pal),
    write('Eu acho que o Pal é: '),
    write(Pal), nl,
    undo.

/* Hipóteses (Pals conhecidos) */
hipotese(lamball) :- lamball, !.
hipotese(cattiva) :- cattiva, !.
hipotese(chikipi) :- chikipi, !.
hipotese(lifmunk) :- lifmunk, !.
hipotese(foxparks) :- foxparks, !.
hipotese(desconhecido).  /* Se nenhuma hipótese for satisfeita */

/* Regras de identificação dos Pals */
lamball :-
    tipo(neutral),
    trabalho([handiwork, transporting, farming]),
    drop([wool, lamball_mutton]),
    nao_montavel.

cattiva :-
    tipo(neutral),
    trabalho([handiwork, gathering, mining, transporting]),
    drop([red_berries]),
    nao_montavel.

chikipi :-
    tipo(neutral),
    trabalho([gathering, farming]),
    drop([egg, chikipi_poultry]),
    nao_montavel.

lifmunk :-
    tipo(grass),
    trabalho([planting, handiwork, lumbering, medicine_production, gathering]),
    drop([berry_seeds, low_grade_medical_supplies]),
    nao_montavel.

foxparks :-
    tipo(fire),
    trabalho([kindling]),
    drop([leather, flame_organ]),
    nao_montavel.

/* Atributos dos Pals */
tipo(Tipo) :-
    verificar(tipo_eh(Tipo)).

trabalho(Lista) :-
    forall(member(T, Lista), verificar(tem_trabalho(T))).

drop(Lista) :-
    forall(member(D, Lista), verificar(drop_eh(D))).

montavel :-
    verificar(eh_montavel).

nao_montavel :-
    verificar(nao_montavel).

/* Perguntas ao usuário */
perguntar(Pergunta) :-
    write('O Pal tem a seguinte característica: '),
    write(Pergunta),
    write('? (s/n) '),
    read(Resposta),
    nl,
    ((Resposta == s ; Resposta == sim)
     ->
        assert(yes(Pergunta)) ;
        assert(no(Pergunta)), fail).

/* Verificação com base no que já foi respondido */
verificar(S) :-
    (yes(S) -> true ;
     no(S)  -> fail ;
     perguntar(S)).

/* Limpa as respostas anteriores */
undo :- retract(yes(_)), fail.
undo :- retract(no(_)), fail.
undo.