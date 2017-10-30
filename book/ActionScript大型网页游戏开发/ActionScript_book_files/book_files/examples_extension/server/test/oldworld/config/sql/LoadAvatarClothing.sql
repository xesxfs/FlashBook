-- Used to load the clothing of an avatar when they log in
select
    id,
    clothingid
from
    avatar_clothing
where
    avatarid = :avatarId