/* animais.pl - jogo de identifica��o de animais.

    inicia com ?- iniciar.     */

iniciar :- hipotese(Animal),
        write('Eu acho que o animal �: '),
        write(Animal),
        nl,
        undo.

/* hip�teses a serem testadas */
hipotese(chita)   :- chita, !.
hipotese(tigre)   :- tigre, !.
hipotese(girafa)   :- girafa, !.
hipotese(zebra)     :- zebra, !.
hipotese(avestruz)   :- avestruz, !.
hipotese(pinguim)   :- pinguim, !.
hipotese(albatroz) :- albatroz, !.
hipotese(desconhecido).             /* sem diagn�stico */

/* Regras de identifica��o dos animais */
chita :- mam�fero,
           carn�voro,
           verificar(tem_cor_castanho_claro_para_marrom_alaranjado),
           verificar(tem_manchas_escuras).
                   
tigre :- mam�fero,
         carn�voro,
         verificar(tem_cor_castanho_claro_para_marrom_alaranjado),
         verificar(tem_listras_pretas).
                 
girafa :- ungulado,
           verificar(tem_pesco�o_longo),
           verificar(tem_pernas_longas).
                   
zebra :- ungulado,
         verificar(tem_listras_pretas).

avestruz :- p�ssaro,
           verificar(n�o_voa),
           verificar(tem_pesco�o_longo).
                   
pinguim :- p�ssaro,
           verificar(n�o_voa),
           verificar(nada),
           verificar(�_preto_e_branco).
                   
albatroz :- p�ssaro,
             verificar(aparece_no_conto_do_velho_marinheiro),
             verificar(voa_bem).

/* regras de classifica��o */
mam�fero    :- verificar(tem_cabelo), !.
mam�fero    :- verificar(d�_leite).

p�ssaro      :- verificar(tem_penas), !.
p�ssaro      :- verificar(voa),verificar(p�e_ovos).
                         
carn�voro :- verificar(come_carne), !.
carn�voro :- verificar(tem_dentes_pontudos),
             verificar(tem_garras),
             verificar(tem_olhos_frontais).
                         
ungulado :- mam�fero,verificar(tem_cascos), !.
ungulado :- mam�fero,verificar(rumina).

/* Como fazer perguntas */
perguntar(Quest�o) :-
    write('O animal tem o seguinte atributo: '),
    write(Quest�o),
    write(' (s|n) ? '),
    read(Resposta),
    nl,
    ( (Resposta == sim ; Resposta == s)
      ->
       assert(yes(Quest�o)) ;
       assert(no(Quest�o)), fail).

:- dynamic yes/1,no/1.

/*
(Condi��o -> A��o_se_verdadeira ; A��o_se_falsa)

(8 =:= 4*2? -> write("sim") ; write("n�o")).
*/

/* Como verificar algo */
verificar(S) :-
   (yes(S) % tem yes?
    ->
    true ;  % se sim: retorna true
    (no(S) % n�o tem yes. Verifica tem no?
     ->
     fail ; % se sim:  para o fluxo de execu��o
     perguntar(S)% se n�o tem yes e nem no, deve perguntar
    )
   ).

/* Desfaz todas as afirma��es sim / n�o */
undo :- retract(yes(_)),fail.
undo :- retract(no(_)),fail.
undo.
