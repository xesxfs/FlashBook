-- Used to update the avatar's top
update
    avatar
set
    clothingtop = :clothingId
where
    id = :avatarId