% Base de conhecimento
pal(lamball, neutro, [trabalho_manual, transporte, agricultura], [fluffy_shield]).
pal(cattiva, neutro, [trabalho_manual, transporte, coleta, mineracao], [cat_helper]).
pal(chikipi, neutro, [coleta, agricultura], [egg_layer]).
pal(lifmunk, grama, [plantio, trabalho_manual, corte, producao_medicinal, coleta], [lifmunk_recoil]).
pal(foxparks, fogo, [acendimento], [foxparks_partner]).

% Regra para encontrar o Pal com base nas características
encontra_pal(Tipo, TrabalhosDesejados, PassivasDesejadas, Nome) :-
    pal(Nome, Tipo, Trabalhos, Passivas),
    subset(TrabalhosDesejados, Trabalhos),
    subset(PassivasDesejadas, Passivas).

% pals_por_tipo(+Tipo, -ListaNomes)
pals_por_tipo(Tipo, ListaNomes) :-
    findall(Nome, pal(Nome, Tipo, _, _), ListaNomes).