-- Used to update the avatar's hairstyle
update
    avatar
set
    hairstyle = :clothingId
where
    id = :avatarId