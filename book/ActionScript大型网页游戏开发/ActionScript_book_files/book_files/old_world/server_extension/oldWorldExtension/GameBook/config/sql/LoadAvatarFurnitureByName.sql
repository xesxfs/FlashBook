-- Used to load the furniture of an avatar
select
    af.id,
    af.furnitureid,
    af.rowposition,
    af.columnposition,
    af.inworld
from
    avatar_furniture af,
    avatar a
where
    af.avatarid = a.id and
    a.name = :name