--- STEAMODDED HEADER
--- MOD_NAME: LeJoker
--- MOD_ID: LeJoker
--- MOD_AUTHOR: [jagodben]
--- MOD_DESCRIPTION: A Joker that starts at X1 Mult and adds X0.23 Mult everytime a Black King is triggered.

----------------------------------------------
------------MOD CODE -------------------------

local MOD_ID = "LeJoker"

local set_spritesref = Card.set_sprites
function Card:set_sprites(_center, _front)
    set_spritesref(self, _center, _front)
    if _center then
        if _center.set then
            if (_center.set == 'Joker') and _center.atlas then
                self.children.center.atlas = G.ASSET_ATLAS
                    [(_center.atlas or (_center.set == 'Joker') and _center.set) or 'centers']
                self.children.center:set_sprite_pos(_center.pos)
            end
        end
    end
end

SMODS.Atlas({
   key = "modicon",
   path = "lejoker_icon.png",
   px = 32,
   py = 32
 })

function SMODS.INIT.LeJoker()
    local lejoker_localization = {
        name = "LeJoker",
        text = {
            "Each played Black King adds {X:mult,C:white}#1#X {} Mult",
            "Currently {X:mult,C:white}X#2# {} Mult"
        }
    }

    local lejoker = SMODS.Joker:new(
        "LeJoker",
        "j_lejoker",
        {
            set = "Joker",
            extra = {
                current_Xmult = 1,
                Xmult_mod = 0.23,
            }
        },
        {x = 0, y = 0},
        lejoker_localization,
        3,
        8
    )

    lejoker:register()

    SMODS.Sprite:new("j_lejoker", SMODS.findModByID(MOD_ID).path, "j_lejoker.png", 71, 95, "asset_atli"):register()

    local generate_UIBox_ability_tableref = Card.generate_UIBox_ability_table
    function Card:generate_UIBox_ability_table()
    if self.ability.set == 'Joker' and self.ability.name == 'LeJoker' then
        if type(self.ability.extra) ~= "table" or 
           self.ability.extra.current_Xmult == nil or self.ability.extra.Xmult_mod == nil then
            self.ability.extra = {
                current_Xmult = 1,
                Xmult_mod = 0.23,
            }
        end

        local loc_vars = {
            self.ability.extra.Xmult_mod,
            self.ability.extra.current_Xmult
        }

        local badges = {}

        if self.ability.set == 'Joker' and self.bypass_discovery_ui then
            badges.force_rarity = true
        end

        if self.sticker then
            loc_vars.sticker = self.sticker
        end

        return generate_card_ui(self.config.center, nil, loc_vars, nil, badges, nil, nil, nil)
    else
        return generate_UIBox_ability_tableref(self)
    end
end

    SMODS.Jokers.j_lejoker.calculate = function(self, context)
        
        if SMODS.end_calculate_context(context) then
            return {
                Xmult = self.ability.extra.current_Xmult, 
                card = self
            }
        end
        return nil
    end
end

local calculate_jokerref = Card.calculate_joker
function Card:calculate_joker(context)
    local ret_val = calculate_jokerref(self, context) 

    if self.ability.set == "Joker" and self.ability.name == "LeJoker" and not self.debuff then

        if type(self.ability.extra) ~= "table" or 
           self.ability.extra.current_Xmult == nil or self.ability.extra.Xmult_mod == nil then
            self.ability.extra = {
                current_Xmult = 1,
                Xmult_mod = 0.23,
            }
        end

        if context.cardarea == G.play and not context.repetition then
            local card = context.other_card or context.card or nil
            
            if card.get_id and card.base and card.base.suit then
                local is_king = card:get_id() == 13
                local is_clubs_or_spades = card:is_suit('Clubs') or card:is_suit('Spades')

                if is_king and (is_clubs_or_spades) then
                    if not context.blueprint then
                        self.ability.extra.current_Xmult = self.ability.extra.current_Xmult + self.ability.extra.Xmult_mod
                        return { message = localize('k_upgrade_ex'), card = self }
                    end
                end
            end
        end
    end

    return ret_val
end

----------------------------------------------
------------MOD CODE END----------------------