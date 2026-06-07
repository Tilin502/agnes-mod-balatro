--- STEAMODDED HEADER
--- MOD_NAME: Agnes Tachuelas
--- MOD_ID: agnes_mod
--- MOD_AUTHOR: [FAMILIA BALATREZ]
--- MOD_DESCRIPTION: Comodin y Etiqueta.
--- PREFIX: agnes
--- VERSION: 1.0.0

-- ATLAS DE IMÁGENES (SPRITES CORREGIDOS)
SMODS.Atlas {
    key = "atlas_agnes",
    path = "agnes_comodin.png", -- Corregido para que coincida con tu archivo real
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = "atlas_etiqueta",
    path = "etiqueta_proyeccion.png", 
    px = 34,
    py = 34
}

-- COMODÍN: AGNES 
SMODS.Joker {
    key = 'agnes',
    name = 'Agnes Tachuelas',
    loc_txt = {
        name = 'Agnes Tachuelas',
        text = {
            "Suma {X:mult,C:white} X0.5 {} Mult por cada",
            "{C:attention}Etiqueta de Proyección{} acumulada.",
            "{C:inactive}(Actualmente {X:mult,C:white} X#1# {} Mult)"
        }
    },
    
    config = { extra = { etiquetas_acumuladas = 0, Xmult_bono = 0.5 } },
    rarity = 2,
    atlas = 'atlas_agnes', 
    pos = { x = 0, y = 0 },
    cost = 6,
    blueprint_compat = true,

    -- Actualiza el texto de la carta en tiempo real
    loc_vars = function(self, info_queue, card)
        local multi_actual = 1 + (card.ability.extra.etiquetas_acumuladas * card.ability.extra.Xmult_bono)
        return { vars = { multi_actual } }
    end,

    -- Lógica durante la partida
    calculate = function(self, card, context)
        -- EFECTO 1: Sumar el multiplicador al calcular los puntos
        if context.joker_main and card.ability.extra.etiquetas_acumuladas > 0 then
            local mult_total = 1 + (card.ability.extra.etiquetas_acumuladas * card.ability.extra.Xmult_bono)
            return {
                message = 'X' .. mult_total .. ' Mult!',
                Xmult_mod = mult_total
            }
        end

        -- EFECTO 2: Entregar la Etiqueta al ganar la ronda (1 mano, 0 descartes)
        if context.end_of_round and not context.blueprint then
            local manos_restantes = G.GAME.current_round.hands_left
            local descartes_restantes = G.GAME.current_round.discards_left
            
            if manos_restantes == 1 and descartes_restantes == 0 then
                card.ability.extra.etiquetas_acumuladas = card.ability.extra.etiquetas_acumuladas + 1
                -- Ajustado al formato interno obligatorio de Steamodded: tag_[prefix]_[key]
                add_tag(Tag('tag_agnes_proyeccion')) 
                return {
                    message = '¡Proyectada!',
                    colour = G.C.GREEN
                }
            end
        end
    end
}
-- ETIQUETA: ETIQUETA DE PROYECCIÓN
SMODS.Tag {
    key = 'proyeccion',
    name = 'Etiqueta de Proyección',
    atlas = 'atlas_etiqueta', 
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Etiqueta de Proyección',
        text = {
            "Añade un {C:attention}Paquete Gratis{} a",
            "la siguiente tienda.",
            "Consérvala para potenciar a",
            "{C:attention}Agnes Tachuelas{}."
        }
    },
    config = { type = 'store_tag' },
    
    -- Funcionalidad al activarse en la tienda
    apply = function(self, tag, context)
        -- El juego usa obligatoriamente 'shop_final_pass' al generar los estantes de la tienda
        if context.type == 'shop_final_pass' then
            
            -- REGLA: El ID real en el código es 'p_buffoon_1'
            local paquete = create_card('Booster', G.shop_booster, nil, nil, nil, true, nil, 'p_buffoon_1')
            paquete.cost = 0 
            G.shop_booster:emplace(paquete)
            
            -- Animación verde de activación
            tag:yep('+', G.C.GREEN, function() return true end)
            
            return true -- Devuelve 'true' para avisarle al juego que la etiqueta ya se consumió y debe borrarse
        end
    end
}