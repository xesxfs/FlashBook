select
    ab.buddyId,
    a.name
from
    avatar_buddy ab,
    avatar a
where
    ab.buddyId = a.id and
    ab.avatarId = :avatarId