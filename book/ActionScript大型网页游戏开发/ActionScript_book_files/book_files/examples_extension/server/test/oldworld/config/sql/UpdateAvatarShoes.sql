-- Used to update the avatar's shoes
update
    avatar
set
    shoes = :clothingId
where
    id = :avatarId