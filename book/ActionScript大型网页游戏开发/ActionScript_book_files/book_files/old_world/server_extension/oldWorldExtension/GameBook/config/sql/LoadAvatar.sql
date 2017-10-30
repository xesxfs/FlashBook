-- Used on initial login of an avatar to find all their basic details
select
    id,
    hairstyle,
    clothingtop,
    clothingbottom,
    shoes,
    money,
    gender
from
    avatar
where
    name = :name and
    pword = :password