-- Gives clothing to an avatar
insert into avatar_furniture
(avatarId, furnitureId, rowposition, columnposition, inworld)
values
(:avatarId, :furnitureId, :rowPosition, :columnPosition, :inWorld)