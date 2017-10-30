-- Used to update the avatar's bottom
update
    avatar
set
    clothingbottom = :clothingId
where
    id = :avatarId